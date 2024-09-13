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
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      extraEntries = ''
        menuentry "Windows" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root E6DC-BBCE
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
        '';
    };
  };

  # Set RTC (hardware clock) to local time like windows.
  # Avoid wrong time displayed while using windows
  time.hardwareClockInLocalTime = true;

  # Mount and clean /tmp at boot
  boot.tmp.cleanOnBoot = true;
  boot.tmp.useTmpfs = true;

  # Add kernel modules
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback.out ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback exclusive_caps=1 card_label="Virtual Camera"
  '';

  # Add support for NTFS
  boot.supportedFilesystems = [ "ntfs" ];

  # Networking settings
  networking.hostName = "cave"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  networking.interfaces.enp34s0.useDHCP = true;

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
    videoDrivers = ["nvidia"];
    libinput.enable = true; #
    libinput.touchpad.disableWhileTyping = true;
    desktopManager.xterm.enable = false;
    desktopManager.plasma5.enable = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
    };
    displayManager = {
      defaultSession = "none+i3";
      sessionCommands = "xrandr --output DP-0 --primary --mode 2560x1440 --pos 1080x188 --output DP-2 --mode 1920x1080 --pos 0x0 --rotate left --output DP-4 --mode 1920x1080 --pos 3640x368";
      sddm.enable = true;
    };
  };


  # Enable Lorri (nix-shell replacement)
  services.lorri.enable = true;

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable zsh
  programs.zsh.enable = true;

  # Enable bluetooth
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.flomonster = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
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
    notify-osd
    openssh
    vim
    wget
  ];

  # Add docker
  virtualisation.docker.enable = true;

  # Batery manager (used by i3status-rs)
  services.upower.enable = true;

  # needed for store VSCode auth token
  services.gnome.gnome-keyring.enable = true;

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

  # Enable unfree software
  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

