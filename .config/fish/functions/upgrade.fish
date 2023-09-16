function upgrade --description 'Updates nixos flake/packages.'
    pushd /etc/nixos/
    begin
        sudo nix flake update
        sudo nixos-rebuild switch
    end
    popd 
end
