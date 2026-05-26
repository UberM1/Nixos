# Dendritic nvim configuration
# Auto-imports all plugin modules from this directory
{
  lib,
  pkgs,
  ...
}: let
  # Auto-discover all .nix files except default.nix
  pluginFiles = lib.filterAttrs (name: type:
    type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix")
  (builtins.readDir ./.);

  pluginModules = map (name: ./${name}) (builtins.attrNames pluginFiles);
in {
  imports = pluginModules;

  programs.nixvim = {
    enable = true;

    # Extra plugins not available in nixvim
    extraPlugins = with pkgs.vimPlugins; [
      plenary-nvim
      (pkgs.vimUtils.buildVimPlugin rec {
        pname = "nvim-k8s-crd";
        version = "2024-11-21";
        src = pkgs.fetchFromGitHub {
          owner = "anasinnyk";
          repo = "nvim-k8s-crd";
          rev = "d57f9c6b0ad1e8ab894f2afd6db90c948ca51a8c";
          sha256 = "sha256-BfSSu6m5Q2YHoO2jX9asiv4BFvpcQ4TEFFAiRhkFqL8=";
        };
        meta.homepage = "https://github.com/anasinnyk/nvim-k8s-crd";
        doCheck = false;
      })
    ];

    # Global settings
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Options
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      swapfile = false;
      backup = false;
      undofile = true;

      # Search config
      hlsearch = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;

      # Scroll Config
      scrolloff = 8;
      sidescrolloff = 8;

      signcolumn = "yes";
      updatetime = 50;
      termguicolors = true;
    };

    # Simple plugins
    plugins = {
      web-devicons.enable = true;
      lazygit.enable = true;
    };

    # Key mappings
    keymaps = [
      # Neotree
      {
        mode = "n";
        key = "<leader>e";
        action = ":Neotree toggle<CR>";
        options.desc = "Toggle file explorer";
      }
      {
        mode = "n";
        key = "<leader>o";
        action = ":Neotree focus<CR>";
        options.desc = "Focus file explorer";
      }

      # Split navigation
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
        options.desc = "Move to left split";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
        options.desc = "Move to right split";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
        options.desc = "Move to bottom split";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
        options.desc = "Move to top split";
      }

      # Split navigation with leader key (Space + hjkl)
      {
        mode = "n";
        key = "<leader>h";
        action = "<C-w>h";
        options.desc = "Move to left split";
      }
      {
        mode = "n";
        key = "<leader>l";
        action = "<C-w>l";
        options.desc = "Move to right split";
      }
      {
        mode = "n";
        key = "<leader>j";
        action = "<C-w>j";
        options.desc = "Move to bottom split";
      }
      {
        mode = "n";
        key = "<leader>k";
        action = "<C-w>k";
        options.desc = "Move to top split";
      }

      # Buffer navigation
      {
        mode = "n";
        key = "<leader>bn";
        action = ":bnext<CR>";
        options.desc = "Next buffer";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = ":bprevious<CR>";
        options.desc = "Previous buffer";
      }
      {
        mode = "n";
        key = "<leader>bd";
        action = ":bdelete<CR>";
        options.desc = "Delete buffer";
      }

      # LazyGit
      {
        mode = "n";
        key = "<leader>gg";
        action = ":LazyGit<CR>";
        options.desc = "Open LazyGit";
      }

      # Clear search highlights
      {
        mode = "n";
        key = "<leader>c";
        action = ":nohlsearch<CR>";
        options.desc = "Clear search highlights";
      }
    ];

    # Extra configuration
    extraConfigLua = ''
      -- Manual K8S CRD integration with yamlls
      local k8s_crd = require('nvim-k8s-crd')
      local cache_dir = vim.fn.expand("~/.cache/k8s-schemas/")
      local file_mask = "*.yaml"

      -- Store config
      k8s_crd.config = {
        cache_dir = cache_dir,
        cache_ttl = 86400,
        k8s = {
          file_mask = file_mask,
        },
      }

      -- Get current context and schema path
      local function get_current_context()
        return vim.fn.system("kubectl config current-context"):gsub("%s+", "")
      end

      local current_context = get_current_context()
      local all_json_path = cache_dir .. current_context .. "/all.json"

      -- Configure yamlls with K8S schemas
      local schemas = {
        -- Kustomization files - use glob pattern to match any path
        ["https://json.schemastore.org/kustomization.json"] = {
          "**/kustomization.yaml",
          "**/kustomization.yml",
          "**/Kustomization",
        },
      }

      -- Add all.json if it exists (includes CRDs from cluster)
      if vim.fn.filereadable(all_json_path) == 1 then
        schemas[all_json_path] = file_mask
        vim.notify("K8S CRD schemas loaded from: " .. current_context, vim.log.levels.INFO)
      else
        -- Fallback to kubernetes schema for non-kustomization yamls
        schemas["kubernetes"] = {
          "**/deployment*.yaml",
          "**/service*.yaml",
          "**/configmap*.yaml",
          "**/secret*.yaml",
          "**/ingress*.yaml",
          "**/namespace*.yaml",
          "**/pod*.yaml",
          "**/statefulset*.yaml",
          "**/daemonset*.yaml",
          "**/job*.yaml",
          "**/cronjob*.yaml",
          "**/pvc*.yaml",
          "**/pv*.yaml",
          "**/role*.yaml",
          "**/clusterrole*.yaml",
          "**/serviceaccount*.yaml",
        }
        vim.notify("No CRD schemas found. Run :K8SSchemasGenerate to load schemas from cluster.", vim.log.levels.WARN)
      end

      vim.lsp.config.yamlls = {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml" },
        root_markers = { ".git" },
        settings = {
          yaml = {
            validate = true,
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json"
            },
            schemas = schemas,
          },
        },
      }

      -- Create command to generate schemas
      vim.api.nvim_create_user_command("K8SSchemasGenerate", function()
        vim.notify("Generating K8S CRD schemas... This may take 10-15 seconds.", vim.log.levels.INFO)
        k8s_crd.generate_schemas()

        -- Wait longer for async job to complete
        vim.defer_fn(function()
          if vim.fn.filereadable(all_json_path) == 1 then
            vim.notify("K8S schemas generated successfully. Restarting yamlls...", vim.log.levels.INFO)

            -- Update yamlls config with the new schema
            vim.lsp.config.yamlls.settings.yaml.schemas[all_json_path] = file_mask

            -- Restart yamlls
            for _, client in ipairs(vim.lsp.get_clients()) do
              if client.name == "yamlls" then
                client.stop()
              end
            end
            vim.defer_fn(function()
              vim.cmd("LspStart yamlls")
            end, 500)
          else
            vim.notify("Schema generation still in progress. Check ~/.cache/k8s-schemas/" .. current_context .. "/ for all.json", vim.log.levels.WARN)
          end
        end, 15000)
      end, {})

      -- Auto-start yamlls for yaml files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "yaml",
        callback = function()
          vim.lsp.enable("yamlls")
        end,
      })

      -- Markdown: enable wrap and linebreak for readability
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.breakindent = true
        end,
      })

      -- Highlight on yank
      vim.api.nvim_create_autocmd("TextYankPost", {
        group = vim.api.nvim_create_augroup("highlight_yank", {}),
        pattern = "*",
        callback = function()
          vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
        end,
      })

      -- Auto-refresh neo-tree when focus returns to vim
      local function refresh_neotree()
        local manager_ok, manager = pcall(require, "neo-tree.sources.manager")
        if manager_ok then
          local state = manager.get_state("filesystem")
          if state and state.tree then
            local commands_ok, commands = pcall(require, "neo-tree.sources.filesystem.commands")
            if commands_ok and commands.refresh then
              commands.refresh(state)
            end
          end
        end
      end

      vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
        group = vim.api.nvim_create_augroup("neo_tree_refresh", {}),
        pattern = "*",
        callback = function()
          if vim.fn.getcmdwintype() == "" then
            vim.cmd("checktime")
            vim.defer_fn(refresh_neotree, 100)
          end
        end,
      })

      -- Refresh neo-tree on git operations via GitSigns
      vim.api.nvim_create_autocmd("User", {
        pattern = "GitSignsUpdate",
        callback = function()
          vim.defer_fn(refresh_neotree, 50)
        end,
      })

      -- Manual refresh keymap for neo-tree
      vim.keymap.set("n", "<leader>er", function()
        refresh_neotree()
      end, { desc = "Refresh neo-tree" })

      -- LazyGit ESC quit behavior
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lazygit",
        callback = function()
          vim.keymap.set("t", "<esc>", "<cmd>close<cr>", { buffer = true, silent = true })
        end,
      })

      -- Additional ESC mappings for various plugin windows
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "help", "qf", "lspinfo", "checkhealth" },
        callback = function()
          vim.keymap.set("n", "<esc>", "<cmd>close<cr>", { buffer = true, silent = true })
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
        end,
      })
    '';
  };
}
