{
  config,
  pkgs,
  lib,
  ...
}: {
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

    # Color scheme
    colorschemes.nord.enable = true;

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
      # colorcolumn = "80"; useless rly
      termguicolors = true;
    };

    # Plugins
    plugins = {
      # lualine.enable = true;
      web-devicons.enable = true;
      lazygit.enable = true;

      # Syntax highlighting
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };

      kitty-scrollback = {
        enable = true;
        settings = {
          # Global configuration for all invocations
          status_window = {
            enabled = true;
            autoclose = false;
            show_timer = true;
          };

          keymaps_enabled = true;
          paste_window = {
            highlight_as_normal_win = false;
            yank_register_enabled = true;
          };

          # You can override builtin configurations
          # ksb_builtin_get_text_all = {
          #   kitty_get_text = {
          #     ansi = true;
          #   };
          # };

          # Or create custom configurations
          # myconfig = {
          #   kitty_get_text = {
          #     ansi = false;
          #     extent = "screen";
          #   };
          # };
        };
      };

      # File explorer
      neo-tree = {
        enable = true;
        settings = {
          close_if_last_window = true;
          enable_git_status = true;
          enable_diagnostics = true;
          window = {
            width = 30;
            auto_expandWidth = false;
            mappings = {
              "<esc>" = "close_window";
              "a" = {
                command = "add";
                config = {
                  show_path = "none";
                };
              };
              "A" = "add_directory";
              "d" = "delete";
              "r" = "rename";
              "y" = "copy_to_clipboard";
              "x" = "cut_to_clipboard";
              "p" = "paste_from_clipboard";
              "c" = "copy";
              "m" = "move";
              "q" = "close_window";
            };
          };
          buffers = {
            follow_current_file = {
              enabled = true;
            };
            window = {
              mappings = {
                "<esc>" = "close_window";
                "q" = "close_window";
              };
            };
          };
          filesystem = {
            follow_current_file = {
              enabled = true;
            };
            filtered_items = {
              hide_dotfiles = false;
              hide_gitignored = false;
            };
            use_libuv_file_watcher = true;
            window = {
              mappings = {
                "<esc>" = "close_window";
                "a" = {
                  command = "add";
                  config = {
                    show_path = "none";
                  };
                };
                "A" = "add_directory";
                "d" = "delete";
                "r" = "rename";
                "y" = "copy_to_clipboard";
                "x" = "cut_to_clipboard";
                "p" = "paste_from_clipboard";
                "c" = "copy";
                "m" = "move";
                "q" = "close_window";
              };
            };
          };
        };
      };

      # Fuzzy finder
      telescope = {
        enable = true;
        extensions = {
          fzf-native = {
            enable = true;
            settings = {
              fuzzy = true;
              override_generic_sorter = true;
              override_file_sorter = true;
              case_mode = "smart_case";
            };
          };
        };
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fo" = "oldfiles";
          "<leader>fc" = "grep_string";
          "<leader>fm" = "marks";
          "<leader>fr" = "registers";
          "<leader>fk" = "keymaps";
          "<leader>fs" = "lsp_document_symbols";
          "<leader>fS" = "lsp_workspace_symbols";
        };
        settings = {
          defaults = {
            file_ignore_patterns = [
              "node_modules"
              ".git"
              "dist"
              "build"
              "target"
            ];
            layout_config = {
              horizontal = {
                prompt_position = "top";
                preview_width = 0.55;
              };
              vertical = {
                mirror = false;
              };
              width = 0.87;
              height = 0.80;
              preview_cutoff = 120;
            };
            sorting_strategy = "ascending";
          };
        };
      };

      # Git integration
      gitsigns.enable = true;

      # Formatting
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
          formatters_by_ft = {
            nix = ["alejandra"];
            lua = ["stylua"];
            json = ["prettier"];
            yaml = ["prettier"];
            go = ["gofmt"];
            ruby = ["rubocop"];
            python = ["black"];
            c = ["clang_format"];
            cpp = ["clang_format"];
          };
          formatters = {
            clang_format = {
              command = "clang-format";
              args = ["--style={BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100, Standard: c++20}"];
            };
          };
        };
      };

      # Autocompletion
      cmp = {
        enable = true;
        settings = {
          mapping = {
            "<C-b>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-e>" = "cmp.mapping.abort()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
          };
          sources = [
            {name = "nvim_lsp";}
            {name = "buffer";}
            {name = "path";}
            {name = "luasnip";}
          ];
          formatting = {
            format = ''
              function(entry, vim_item)
                vim_item.menu = ({
                  nvim_lsp = "[LSP]",
                  buffer = "[Buffer]",
                  path = "[Path]",
                  luasnip = "[Snip]",
                })[entry.source.name]
                return vim_item
              end
            '';
          };
        };
      };
      cmp-nvim-lsp.enable = true;
      cmp-buffer.enable = true;
      cmp-path.enable = true;
      luasnip.enable = true;

      # LSP
      lsp = {
        enable = true;
        servers = {
          nixd = {
            enable = true;
            settings = {
              nixpkgs = {
                expr = "import <nixpkgs> { }";
              };
              formatting = {
                command = ["alejandra"];
              };
            };
          };
          lua_ls.enable = true; # Lua LSP
          jsonls.enable = true; # JSON LSP
          yamlls = {
            enable = true;
            autostart = false;
          }; # YAML LSP - will be started by k8s-crd plugin
          solargraph.enable = true; # RAILS LSP
          gopls.enable = true; # GO LSP
          helm_ls.enable = true; # HELM LSP
          pylsp.enable = true; # PYTHON LSP
          clangd.enable = true; # C/C++ LSP
        };

        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gr" = "references";
            "gD" = "declaration";
            "gI" = "implementation";
            "gt" = "type_definition";
            "K" = "hover";
            "<leader>ca" = "code_action";
            "<leader>cr" = "rename";
            "<F2>" = "rename";
          };
          diagnostic = {
            "<leader>cd" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
        };
      };
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
        ["https://json.schemastore.org/kustomization.json"] = "kustomization.yaml",
      }

      -- Add all.json if it exists (includes CRDs)
      if vim.fn.filereadable(all_json_path) == 1 then
        schemas[all_json_path] = file_mask
        vim.notify("K8S CRD schemas loaded from all.json", vim.log.levels.INFO)
      else
        -- Fallback to basic kubernetes schema if CRDs not available
        schemas["kubernetes"] = "/*.yaml"
        vim.notify("K8S CRD schemas not found. Run :K8SSchemasGenerate to enable CRD validation.", vim.log.levels.INFO)
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

      -- fzf extension is automatically loaded by nixvim when enabled
    '';
  };
}
