_: {
  # Spotlight skips symlinks, so the default linkApps leaves every
  # home-manager app out of Cmd+Space. copyApps puts real bundles in the
  # same folder, which Spotlight indexes.
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };
}
