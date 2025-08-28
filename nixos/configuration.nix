# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{

    imports =
        [
            ./hardware-configuration.nix
        ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "nixos";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Oslo";

    services.xserver = {
        enable = true;
        windowManager.i3.enable = true;
        displayManager.gdm.enable = true;
    };

    services.gnome.gnome-keyring.enable = true;
    swapDevices = [ {device = "/swapfile"; size = 8192; } ];

    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };
    services.printing.enable = true;

    hardware.uinput.enable = true;
    services.libinput.enable = true;
    services.kanata = {
        enable = true;
        keyboards.default.configFile = "/etc/nixos/kanata.kbd";
    };

    users.users.ivar = {
        isNormalUser = true;
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
        packages = with pkgs; [
            tree
        ];
    };

    programs.firefox.enable = true;

    services.tlp = {
        enable = true;
        settings = {
            CPU_BOOST_ON_BAT = 0;
            CPU_SCALING_GOVERNOR_ON_BATTERY = "powersave";
            START_CHARGE_THRESH_BAT0 = 90;
            STOP_CHARGE_THRESH_BAT0 = 97;
            RUNTIME_PM_ON_BAT = "auto";
        };
    };

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "discord"
        "steam"
        "steam-unwrapped"
    ];

    programs.steam.enable = true;

    fonts.packages = [
        # add specific ones here
    ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts); # all nerdfonts

    environment.systemPackages = with pkgs; [
        basedpyright
        cargo
        clang-tools
        gcc
        git
        go
        gopls
        lazygit
        neovim
        poetry
        python313
        python313Packages.pip
        python313Packages.pipx
        rustc
        stow
        wget
        alacritty
        discord
        fzf
        godot
        mako
        networkmanagerapplet
        unzip
        xorg.xauth
        picom
        dunst
        xclip
        dmenu
        pulseaudio
        brightnessctl
    ];

    programs.mtr.enable = true;
    programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
    };

    environment.variables = {
        GTK_THEME = "Adwaita:dark";
        QT_QPA_PLATFORMTHEME = "gtk2";
    };

    system.stateVersion = "25.05"; # dont change ever

}
