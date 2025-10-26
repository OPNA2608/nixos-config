{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    editorconfig-checker
    gh
    gitFull
    nixfmt-rfc-style
    lixPackageSets.latest.nixpkgs-review
    pre-commit
    screen
  ];

  programs.nix-index = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = false;
  };
}
