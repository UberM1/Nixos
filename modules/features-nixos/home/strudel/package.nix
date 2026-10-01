# Strudel REPL built as a static site from the upstream monorepo
{
  lib,
  stdenvNoCC,
  fetchgit,
  nodejs_24,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "strudel";
  version = "0-unstable-2026-09-29";

  src = fetchgit {
    url = "https://codeberg.org/uzu/strudel.git";
    rev = "c57320a2dea420c319ef66ce9af3e2b7c46479ba";
    hash = "sha256-ooni81f+5hs82PI03A+TWqyi/YJlKdy6NPTp7cS9XlQ=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 2;
    hash = "sha256-nQmhK/mP8DlJcZFjvwGhDFjgw00FaydNH7rppPVuQr4=";
  };

  nativeBuildInputs = [nodejs_24 pnpm_10 pnpmConfigHook];

  env.SITE_URL = "http://localhost:4321/";

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r website/dist $out
    runHook postInstall
  '';

  meta = {
    description = "Live coding patterns on the web, a port of TidalCycles";
    homepage = "https://strudel.cc";
    license = lib.licenses.agpl3Plus;
  };
})
