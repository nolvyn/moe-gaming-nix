{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.moe-gaming = {
    dw-proton-bin = {
      enable = lib.mkEnableOption "DW-Proton compatibility tool for Steam, Heroic, and Lutris";
    };
  };

  config = lib.mkIf config.moe-gaming.dw-proton-bin.enable {
    programs.steam.extraCompatPackages = [
      pkgs.dw-proton-bin
    ];

    systemd.user.tmpfiles.rules = [
      "L+ %h/.local/share/Steam/compatibilitytools.d/dw-proton-bin - - - - ${pkgs.dw-proton-bin.steamcompattool}"
    ];
  };
}
