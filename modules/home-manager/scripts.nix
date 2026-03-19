{
  config,
  pkgs,
  ...
}: {
  home.file = {
    "scripts/fontpreview" = {
      source = ./scripts/fontpreview;
      executable = true;
    };
    "scripts/pg-memory-calculator.sh" = {
      source = ./scripts/pg-memory-calculator.sh;
      executable = true;
    };
    "scripts/ranger-font-preview.sh" = {
      source = ./scripts/ranger-font-preview.sh;
      executable = true;
    };
    "scripts/tablet-toggle.sh" = {
      source = ./scripts/tablet-toggle.sh;
      executable = true;
    };
  };
}
