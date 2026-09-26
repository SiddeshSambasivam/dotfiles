# Caffeinate: menu-bar app that stops the Mac from sleeping, wrapping the
# `caffeinate` command that ships with macOS.
#
# Not in nixpkgs and there is no Homebrew cask. The only release artifact
# is a zipped .app on GitHub, so this unpacks that as-is. To bump it,
# raise version and replace hash with what the build reports.
{ lib, stdenvNoCC, fetchurl, unzip }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "caffeinate";
  version = "1.2.0";

  src = fetchurl {
    url = "https://github.com/LennardKittner/Caffeinate/releases/download/v${finalAttrs.version}/Caffeinate.app.zip";
    hash = "sha256-tWZKHdZ/hJgmYuweJeVAPATHxLjWPGMyikfrkAzBWnk=";
  };

  nativeBuildInputs = [ unzip ];

  # The zip holds Caffeinate.app at its root rather than a wrapper
  # directory, so unpack into the build directory itself.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -R Caffeinate.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Menu-bar app to stop a Mac from sleeping";
    homepage = "https://github.com/LennardKittner/Caffeinate";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    # A prebuilt bundle, not built from source here.
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
