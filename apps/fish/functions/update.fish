pushd /etc/nixos
begin 
  sudo nix flake update
  # sudo nixos-rebuild switch
  nh os switch /etc/nixos
end
popd

pushd ~/.config/home-manager/
begin 
  nix flake update
  # home-manager switch
  nh home switch ~/.config/home-manager/
end
popd
