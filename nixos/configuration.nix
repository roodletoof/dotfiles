# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
	imports =
		[
			/etc/nixos/hardware-configuration.nix
		];

	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking.hostName = "nixos";
	networking.networkmanager.enable = true;

	time.timeZone = "Europe/Oslo";

    services.gnome.gnome-keyring.enable = true;

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
    programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
    };
    services.greetd = {
        enable = true;
        settings = {
            default_session = {
                command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
                user = "greeter";
            };
        };
    };
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

	environment.systemPackages = with pkgs; [
        grim
        slurp
        wl-clipboard
        mako
        unzip

		neovim
		git
		lazygit
		wget
		stow

		go
		gopls

        fzf

		python313
		python313Packages.pip
		python313Packages.pipx
		poetry
		basedpyright

		rustc
		cargo

		gcc
		clang-tools
	];

	programs.mtr.enable = true;
	programs.gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};

	system.stateVersion = "25.05"; # dont change ever

}

