{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lime-juice";
  version = "0.2.1-unstable-2026-03-18";

  src = fetchFromGitHub {
    owner = "EK720";
    repo = "lime-juice";
    rev = "ec7e4bd993ff60b726cc5e3d04649bc939077e19";
    hash = "sha256-bWVLK20q+3Uo7NgrrYhWUscZsyBfrTgANcJPwcc8TDU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin juice juice-img

    runHook postInstall
  '';

  meta = {
    description = "C++ port of Tomyun's 'Juice' de/recompiler for PC-98 games using the ADV engine";
    homepage = "https://github.com/EK720/lime-juice";
    license = lib.licenses.unfree;
    mainProgram = "juice";
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.unix;
  };
})
