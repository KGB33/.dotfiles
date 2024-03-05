pushd /etc/nixos
begin 
  sudo nix flake update
  sudo nixos-rebuild switch
end
popd
