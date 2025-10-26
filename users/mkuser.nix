{
  id,
  name,
}:

{
  pkgs,
  lib,
  ...
}:

assert id != null;
assert name != null;

let
  mkPasswordPath =
    id:
    let
      passwordPath = id: "/etc/nixos/users/passwords/${id}";
    in
    if !builtins.pathExists (/. + (passwordPath id)) then
      throw ''
        ${passwordPath id} doesn't exist!
        Did you forget to create it with `mkpasswd -m <crypt> > ${passwordPath id}`?
      ''
    else
      (passwordPath id);
in
{
  users.users.${id} = {
    description = name;
    hashedPasswordFile = mkPasswordPath id;
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
}
