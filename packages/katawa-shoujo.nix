{ stdenv
, lib
, fetchzip
, autoPatchelfHook
, libX11
, libXext
, libXi
, libXmu
, libGL
, libGLU
# Originally used SDL, SDL_compat will work when running natively, but breaks under box64
, SDL
}:

stdenv.mkDerivation rec {
  pname = "katawa-shoujo";
  version = "1.3.1";

  src = fetchzip {
    url = "http://dl.katawa-shoujo.com/gold_${version}/%5b4ls%5d_katawa_shoujo_${version}-%5blinux-x86%5d%5b18161880%5d.tar.bz2";
    hash = "sha256-7qAbzlT/e0lcN+w0vxd60QBCANuHCZ4s/kziRUKYTmA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    libX11
    libXext
    libXi
    libXmu
    libGL
    libGLU
    SDL
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Delete binaries for wrong arch, autoPatchelfHook gets confused by them & less to keep in the store
    rm -rf lib/linux-${if stdenv.hostPlatform.isx86_64 then "i686" else "x86_64"}

    # Remove bundled SDL so the one from buildInputs is picked up.
    # In case that is SDL_compat, supposedly better Wayland support should be available.
    rm lib/linux-${if !stdenv.hostPlatform.isx86_64 then "i686" else "x86_64"}/libSDL-1.2*

    mkdir -p $out/{bin,share/katawa-shoujo}
    cp -R * $out/share/katawa-shoujo

    ln -s $out/share/katawa-shoujo/'Katawa Shoujo.sh' $out/bin/katawa-shoujo

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bishoujo-style visual novel by Four Leaf Studios, built in Ren'Py";
    longDescription = ''
      Katawa Shoujo is a bishoujo-style visual novel set in the fictional Yamaku High School for disabled children,
      located somewhere in modern Japan. Hisao Nakai, a normal boy living a normal life, has his life turned upside down
      when a congenital heart defect forces him to move to a new school after a long hospitalization. Despite his difficulties,
      Hisao is able to find friends—and perhaps love, if he plays his cards right. There are five main paths corresponding
      to the 5 main female characters, each path following the storyline pertaining to that character.

      The story is told through the perspective of the main character, using a first person narrative. The game uses a
      traditional text and sprite-based visual novel model with an ADV text box.

      Katawa Shoujo contains adult material, and was created using the Ren'Py scripting system. It is the product of an
      international team of amateur developers, and is available free of charge under the Creative Commons BY-NC-ND License.
    '';
    homepage = "https://www.katawa-shoujo.com/";
    license = [{
      # https://www.katawa-shoujo.com/about.php
      spdxId = "CC-BY-NC-ND 3.0";
      fullName = "Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported";
      free = false;
      # November 2022: Update to NoDerivs part of the license
      url = "https://ks.renai.us/viewtopic.php?f=13&p=248149#p248149";
    }];
    maintainers = with maintainers; [ OPNA2608 ];
    # Ren'Py runs on alot more but fighting against the Python ecosystem to keep Ren'Py6 maintained & functional isn't something I have the time nor patience for
    platforms = platforms.x86;
    # TODO different src & installPhase for non-Linux
    broken = stdenv.hostPlatform.isWindows || stdenv.hostPlatform.isDarwin;
  };

}
