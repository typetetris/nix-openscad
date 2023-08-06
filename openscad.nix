#
# Tests use xvfb to run openscad and use OpenGL/Vulkan/...
# I didn't manage to enable GLX in xvfb so the tests passed. Is it possible to do from the sandbox?
#

{ lib, stdenv
, fetchFromGitHub
, fetchpatch
, qtbase
, qtmultimedia
, qscintilla
, bison
, flex
, eigen
, boost
, libGLU, libGL
, glew
, opencsg
, cgal_5
, mpfr
, gmp
, glib
, pkg-config
, harfbuzz
, gettext
, freetype
, fontconfig
, double-conversion
, lib3mf
, libzip
, mkDerivation
, qtmacextras
, cmake
, spacenavSupport ? stdenv.isLinux, libspnav
, wayland
, wayland-protocols
, qtwayland
, cairo
, mimalloc
, xorg
, tbb

, doCheck ? false
, python3
, xvfb-run
}:

let
  pyenv = python3.withPackages(pkgs: [ pkgs.pip pkgs.setuptools pkgs.numpy pkgs.pillow ]);
  openscad-src = fetchFromGitHub {
    owner = "openscad";
    repo = "openscad";
    rev = "87bf17e53aac352c5f45dbdb05a4e05376512acb";
    hash = "sha256-OtxvhllPfyiu90/B4/O3EYgogdhcaKpj+NPsBHZF5pM=";
    fetchSubmodules = true;
  };
in

mkDerivation rec {
  pname = "openscad";
  version = "2023.07.31";

  src = openscad-src;
  nativeBuildInputs = [ bison flex pkg-config gettext cmake python3 ] ++ lib.optionals doCheck [ pyenv xvfb-run ];

  buildInputs = [
    eigen boost glew opencsg cgal_5 mpfr gmp glib
    harfbuzz lib3mf libzip double-conversion freetype fontconfig
    qtbase qtmultimedia qscintilla cairo mimalloc
    xorg.libXdmcp
    xorg.libSM
    xorg.libICE
    tbb
  ] ++ lib.optionals stdenv.isLinux [ libGLU libGL wayland wayland-protocols qtwayland ]
    ++ lib.optional stdenv.isDarwin qtmacextras
    ++ lib.optional spacenavSupport libspnav
  ;

  inherit doCheck;

  cmakeFlags = [
    "-DVERSION=${version}"
    "-DEXPERIMENTAL=1"
    "-DENABLE_PYTHON=OFF"
  ] ++ lib.optionals (!spacenavSupport) [
    "-DENABLE_SPNAV=OFF"
  ] ++ lib.optionals (!doCheck) [
    "-DENABLE_TESTS=OFF"
  ];

  enableParallelBuilding = true;

  postPatch = lib.optionalString doCheck ''
        mkdir -p build/tests/venv/bin
        ln -s ${pyenv}/bin/python build/tests/venv/bin
        '';

  postInstall = lib.optionalString stdenv.isDarwin ''
    mkdir $out/Applications
    mv $out/bin/*.app $out/Applications
    rmdir $out/bin || true

    mv --target-directory=$out/Applications/OpenSCAD.app/Contents/Resources \
      $out/share/openscad/{examples,color-schemes,locale,libraries,fonts,templates}

    rmdir $out/share/openscad
  '';

  meta = {
    description = "3D parametric model compiler";
    longDescription = ''
      OpenSCAD is a software for creating solid 3D CAD objects. It is free
      software and available for Linux/UNIX, MS Windows and macOS.

      Unlike most free software for creating 3D models (such as the famous
      application Blender) it does not focus on the artistic aspects of 3D
      modelling but instead on the CAD aspects. Thus it might be the
      application you are looking for when you are planning to create 3D models of
      machine parts but pretty sure is not what you are looking for when you are more
      interested in creating computer-animated movies.
    '';
    homepage = "http://openscad.org/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ bjornfor raskin gebner ];
    mainProgram = "openscad";
  };
}
