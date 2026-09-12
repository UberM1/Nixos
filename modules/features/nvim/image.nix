# Inline image rendering via kitty's graphics protocol.
#
{lib, ...}: {
  programs.nixvim.plugins.image = {
    enable = lib.mkDefault true;
    settings = {
      backend = "kitty";

      processor = "magick_rock";

      integrations = {
        markdown = {
          enabled = true;
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
