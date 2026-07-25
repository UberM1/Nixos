final: prev: {
  kdePackages = prev.kdePackages // {
    dolphin = prev.kdePackages.dolphin.overrideAttrs (oldAttrs: {
      postInstall = (oldAttrs.postInstall or "") + ''
        # Wrap dolphin to rebuild ksycoca cache and set XDG_CONFIG_DIRS
        wrapProgram $out/bin/dolphin \
          --prefix XDG_CONFIG_DIRS : "${prev.kdePackages.plasma-workspace}/etc/xdg" \
          --run "${prev.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental"
      '';
      buildInputs = (oldAttrs.buildInputs or []) ++ [ prev.makeWrapper ];
    });
  };
}
