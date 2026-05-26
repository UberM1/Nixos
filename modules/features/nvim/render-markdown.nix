{lib, ...}: {
  programs.nixvim.plugins.render-markdown = {
    enable = lib.mkDefault true;
    settings = {
      file_types = ["markdown"];
      render_modes = ["n" "c"];
      heading = {
        enabled = true;
        icons = ["󰲡 " "󰲣 " "󰲥 " "󰲧 " "󰲩 " "󰲫 "];
      };
      code = {
        enabled = true;
        style = "full";
        border = "thin";
      };
      bullet = {
        enabled = true;
        icons = ["●" "○" "◆" "◇"];
      };
      checkbox = {
        enabled = true;
        unchecked = {icon = "󰄱 ";};
        checked = {icon = "󰄵 ";};
      };
      link = {
        enabled = true;
        hyperlink = "󰌹 ";
        wiki = {icon = "󱗖 ";};
      };
    };
  };
}
