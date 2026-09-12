# Inline image rendering via kitty's graphics protocol.
#
# nixpkgs ships image-nvim as a luarocks package that propagates the `magick`
# rock built against luajit, so the ImageMagick binding works without any
# extra wiring here. The kitty backend needs no remote control -- it writes
# graphics escape sequences straight to the terminal.
{lib, ...}: {
  programs.nixvim.plugins.image = {
    enable = lib.mkDefault true;
    settings = {
      backend = "kitty";

      # image.nvim defaults to the "magick_cli" processor, which shells out to
      # the ImageMagick binaries and hard-errors when they are missing. They
      # are only on PATH here by accident -- nothing in this repo declares
      # imagemagick. The rock is the one dependency nixpkgs does wire up for
      # us, so use it and depend on nothing implicit.
      processor = "magick_rock";

      integrations = {
        markdown = {
          enabled = true;
          # Images would otherwise sit on top of the text being typed.
          clear_in_insert_mode = true;
          download_remote_images = true;
          only_render_image_at_cursor = false;
          filetypes = ["markdown" "quarto"];

          # image.nvim already matches Obsidian's `![[name.png]]` embeds, but
          # it resolves them relative to the note, and Obsidian stores the
          # file in the vault's attachment folder instead. Fall back to that
          # folder, read out of the vault's own settings so this keeps working
          # if the setting changes or another vault uses a different one.
          resolve_image_path.__raw = ''
            (function()
              local attachment_dirs = {}

              local attachment_dir = function(vault)
                if attachment_dirs[vault] == nil then
                  local ok, settings = pcall(function()
                    local raw = vim.fn.readfile(vault .. "/.obsidian/app.json")
                    return vim.json.decode(table.concat(raw, "\n"))
                  end)
                  attachment_dirs[vault] = (ok and settings and settings.attachmentFolderPath) or false
                end
                return attachment_dirs[vault]
              end

              return function(document_path, image_path, fallback)
                if image_path:match("^data:image") or image_path:sub(1, 1) == "/" then
                  return image_path
                end

                -- `![[name.png|300]]` carries a display width Obsidian strips.
                local name = image_path:gsub("|.*$", "")

                local resolved = fallback(document_path, name)
                if vim.uv.fs_stat(resolved) then return resolved end

                local vault = vim.fs.root(document_path, ".obsidian")
                if vault then
                  local dir = attachment_dir(vault)
                  if dir then
                    local candidate = vault .. "/" .. dir .. "/" .. name
                    if vim.uv.fs_stat(candidate) then return candidate end
                  end
                end

                return resolved
              end
            end)()
          '';
        };
        # Off by default: no notes in these formats, and each one adds a
        # treesitter parser and a redraw path for nothing.
        neorg.enabled = false;
        typst.enabled = false;
        syslang.enabled = false;
        html.enabled = false;
        css.enabled = false;
      };

      max_width_window_percentage = 60;
      max_height_window_percentage = 50;

      # Hide images that other floats (completion, notifications) overlap,
      # otherwise kitty keeps drawing them over whatever is on top.
      #
      # editor_only_render_when_focused is deliberately left at its default of
      # false: it gates rendering on FocusGained, and a window that never
      # reports focus ends up never drawing anything at all.
      window_overlap_clear_enabled = true;
    };
  };
}
