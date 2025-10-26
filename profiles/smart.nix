{
  config,
  pkgs,
  ...
}:

{
  services.smartd = {
    enable = true;
    notifications = {
      test = true;
      x11.enable = config.services.xserver.enable;
      wall.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    smartmontools
  ];
}
