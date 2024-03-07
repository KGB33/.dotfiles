pushd /etc/nixos
begin 
  sudo nix flake update
  sudo nixos-rebuild switch
end
popd

pushd ~/.config/home-manager/
begin 
  nix flake update
  home-manager switch
end
popd
