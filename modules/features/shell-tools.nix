{...}: {
  programs.btop.enable = true;
  programs.bat.enable = true;
  programs.lazygit = {
    enable = true;
    settings.git.pagers = [
      {
        pager = "delta --paging=never --features=lazygit";
        colorArg = "always";
      }
    ];
  };
}
