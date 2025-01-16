{
  machine,
}:

{
  stdenvNoCC,
  substituteAll,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "${machine}-configs";

  src = ./configuration.nix.in;

  dontUnpack = true;
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    cp ${substituteAll {
      inherit (finalAttrs) src;
      inherit machine;
      config = "base";
    }} ./base.nix

    cp ${substituteAll {
      inherit (finalAttrs) src;
      inherit machine;
      config = "full";
    }} ./full.nix

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out base.nix full.nix

    runHook postInstall
  '';
})
