# Dotfiles

Managed by [`home-manager`](https://github.com/nix-community/home-manager).

On a `nix`-enabled system clone this repo to `$HOME/.config/home-manager/`

```bash
mkdir -p ~/.config/home-manager/
cd ~/.config/home-manager/
git clone git@github.com:KGB33/.dotfiles.git .
```

Then switch to the new configuration:
```
home-manager switch
```

# Configuration Organization

The configuration is broken into four parts. `homes/` contains definitions for
home manager configurations. These configurations can enable (or disable)
user-applications defined in `apps/`

Likewise, NixOS system configurations are defined in `systems/`, and can enable
(or disable) system applications defined in `components/`.

If an application needs additional files, then create a directory with the same
name next to the `.nix` file.


```
 flake.nix
 apps
├──  default.nix
├──  nvim.nix
├──  nvim
│   └── ...
├──  ...
└──  ...
 homes
├──  darwin.nix
├──  default.nix
└──  linux.nix
 component
├──  default.nix
└──  ...
 systems
├──  base
│   ├──  configuration.nix
│   └──  ...
├──  geppetto
│   ├──  configuration.nix
│   ├──  hardware-configuration.nix
│   └──  ...
└──  helm
    ├──  configuration.nix
    ├──  hardware-configuration.nix
    └──  ...
```
