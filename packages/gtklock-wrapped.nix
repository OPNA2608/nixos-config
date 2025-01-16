{
  stdenvNoCC,
  lib,
  makeWrapper,
  writeText,
  gtklock,
  gtklock-packages ? [],
}:

let
  gtklock-config = writeText "gtklock-config.ini" (lib.generators.toINI {} {
    main = {
      modules = lib.strings.concatMapStringsSep ";" (data: "${lib.getLib data.pkg}/lib/gtklock/${data.module}.so") gtklock-packages;
    };
  });
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "${gtklock.pname}-wrapped";
  inherit (gtklock) version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  nativeBuildInputs = [
    makeWrapper
  ];

	installPhase = ''
    runHook preInstall

		mkdir -p $out/bin
		makeWrapper ${lib.getExe gtklock} $out/bin/${gtklock.meta.mainProgram} \
      --add-flags '--config ${gtklock-config}'

    runHook postInstall
  '';

  meta = {
    inherit (gtklock.meta) description longDescription homepage license platforms mainProgram;
  };
})
