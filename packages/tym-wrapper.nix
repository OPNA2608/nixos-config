{
  symlinkJoin,
  lib,
  makeWrapper,
  replaceVars,
  tym,

  screenIsSmall ? false,
}:

symlinkJoin {
  pname = "${tym.pname}-wrapped";
  inherit (tym) version;

  nativeBuildInputs = [
    makeWrapper
  ];

  paths = [
    tym
  ];

  postBuild = ''
    rm $out/bin/${tym.meta.mainProgram}

    makeWrapper ${lib.getExe tym} $out/bin/${tym.meta.mainProgram} \
      --add-flags '--use=${
        replaceVars ./tym/templated/config.lua {
          screenIsSmall = lib.trivial.boolToString screenIsSmall;
        }
      }' \
      --add-flags '--theme=${./tym/theme.lua}'
  '';

  meta = lib.attrsets.removeAttrs tym.meta [
    "pos"
    "position"
  ];
}
