{
  lib,
  stdenvNoCC,
  fetchzip,
  steamDisplayName ? "DW-Proton",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dw-proton-bin";
  version = "11.0-15";

  src = fetchzip {
    url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-${finalAttrs.version}/dwproton-${finalAttrs.version}-x86_64.tar.xz";
    hash = "sha256-vF5O5sR1/zr1+06SraznN4u8eRtp47bVYxj0ntCZIwQ=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    echo "${finalAttrs.pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  preFixup = ''
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "dwproton-${finalAttrs.version}-x86_64" "${steamDisplayName}"
  '';

  meta = {
    description = ''
      Dawn Winery's custom Proton fork with fixes for various games.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    license = with lib.licenses; [
      bsd3
      unfree
    ];
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
