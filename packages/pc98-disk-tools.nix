{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  bash,
  makeWrapper,
  python3,
}:

let
  pythonEnv = python3.withPackages (ps: [
  ]);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "pc98-disk-tools";
  version = "0-unstable-2024-11-05";

  src = fetchFromGitHub {
    owner = "barbeque";
    repo = "pc98-disk-tools";
    rev = "b4c6569419691c584357f383645ce02384f75454";
    hash = "sha256-4dWkMA2HSbqX86gXew+nDCOfW0VggLe1D4ZC8Tv/ag4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/pc98-disk-tools}

    install -Dm644 -t $out/share/pc98-disk-tools/ *.py
    for script in $out/share/pc98-disk-tools/*.py; do
      makeWrapper ${lib.getExe pythonEnv} "$out/bin/$(basename "$script" .py)" \
        --add-flag "$script"
    done
  ''
  + lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
    install -Dm644 -t $out/share/pc98-disk-tools/mount-disk-image.sh
    makeWrapper ${lib.getExe bash} $out/bin/mount-disk-image \
      --add-flag "$out/share/pc98-disk-tools/mount-disk-image.sh"
  ''
  + ''

    runHook postInstall
  '';

  meta = {
    description = "Open-source tools for working with common PC98 disk image formats";
    homepage = "https://github.com/barbeque/pc98-disk-tools";
    # No license given
    license = lib.licenses.unfree;
    platforms = lib.platforms.unix;
  };
})
