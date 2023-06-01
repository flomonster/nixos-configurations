# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Support ntfs
  boot.supportedFilesystems = [ "ntfs" ];

  # Mount and clean /tmp at boot
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;

  # Networking settings
  networking.hostName = "laptop"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable i3 Desktop Environment.
  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true; # Enable touchpad
    libinput.touchpad.disableWhileTyping = true;
    desktopManager.xterm.enable = false;
    desktopManager.plasma5.enable = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
  };

  services.xserver.displayManager = {
    defaultSession = "none+i3";
    sddm.enable = true;
  };

  # Enable Lorri (nix-shell replacement)
  services.lorri.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flomonster = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" "libvirtd" ];
    createHome = true;
    home = "/home/flomonster";
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    firefox
    git
    home-manager
    openssh
    vim
    wget
    notify-osd
    virt-manager
  ];

  # Add docker
  virtualisation.docker.enable = true;

  # Add libvirt
  virtualisation.libvirtd.enable = true;
  programs.dconf.enable = true;

  # Enable zsh
  programs.zsh.enable = true;

  # Batery manager (used by i3status-rs)
  services.upower.enable = true;

  # needed for store VSCode auth token
  services.gnome.gnome-keyring.enable = true;

  # System auto upgrade
  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  # System auto garbage collect
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

