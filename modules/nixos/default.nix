{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.moe-gaming = {
    proton = {
      enable = lib.mkEnableOption "both DW-Proton and Proton-CachyOS compatibility tools for Steam, Heroic, and Lutris";
    };
    dw-proton-bin = {
      enable = lib.mkEnableOption "DW-Proton compatibility tool for Steam, Heroic, and Lutris";
    };
    proton-cachyos-bin = {
      enable = lib.mkEnableOption "Proton-CachyOS compatibility tool for Steam, Heroic, and Lutris";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.moe-gaming.proton.enable {
      moe-gaming.dw-proton-bin.enable = true;
      moe-gaming.proton-cachyos-bin.enable = true;
    })

    (lib.mkIf config.moe-gaming.dw-proton-bin.enable {
      programs.steam.extraCompatPackages = [
        pkgs.dw-proton-bin
      ];

      systemd.user.tmpfiles.rules = [
        "L+ %h/.local/share/Steam/compatibilitytools.d/dw-proton-bin - - - - ${pkgs.dw-proton-bin.steamcompattool}"
      ];
    })

    (lib.mkIf config.moe-gaming.proton-cachyos-bin.enable {
      programs.steam.extraCompatPackages = [
        pkgs.proton-cachyos-bin
      ];

      systemd.user.tmpfiles.rules = [
        "L+ %h/.local/share/Steam/compatibilitytools.d/proton-cachyos-bin - - - - ${pkgs.proton-cachyos-bin.steamcompattool}"
      ];
    })
  ];
}
