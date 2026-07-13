{
  lib,
  stdenvNoCC,
  fetchzip,
  steamDisplayName ? "Proton-CachyOS",
  # CPU microarchitecture variant of the release to fetch.
  # "x86_64" is the portable baseline; "x86_64_v3" is optimized for
  # AVX2/BMI2/FMA-capable CPUs (Haswell+/Zen+); "arm64" is also published.
  cpuVariant ? "x86_64_v3",
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-cachyos-bin";
  version = "11.0-20260702-slr";

  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${finalAttrs.version}/proton-cachyos-${finalAttrs.version}-${cpuVariant}.tar.xz";
    hash = "sha256-pbx/WDgpa55WDr1exD4rrNWsRoVkqHIUjzX1PJObxG8=";
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
      --replace-fail "proton-cachyos-${finalAttrs.version}-${cpuVariant}" "${steamDisplayName}"
  '';

  meta = {
    description = ''
      CachyOS's custom Proton fork with performance patches and fixes for various games.

      (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
    '';
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = with lib.licenses; [
      bsd3
      unfree
    ];
    maintainers = with lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
