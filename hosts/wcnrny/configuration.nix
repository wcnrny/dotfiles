{ config, pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = 1; };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  networking.hostName = "wcnrny";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
  networking.hosts = {
    "127.0.0.1" = ["luxly.local" "docs.luxly.local"];
  };
  services.resolved.enable = true;

  services.zapret = {
    enable = true;
    params = [ "--dpi-desync=fake,disorder2" "--dpi-desync-split-pos=1" "--dpi-desync-ttl=0" "--dpi-desync-fooling=md5sig,badseq" "--dpi-desync-repeats=6" ];
    whitelist = [ "discord.com" "discord.gg" "discordapp.com" "discordapp.net" ];
  };

  time.timeZone = "Europe/Istanbul";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "trq";

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
  
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      sddm-astronaut
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qt5compat
    ];
  };

  services.openssh.enable = true;
  services.pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };
  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  
  programs.zsh.enable = true;
  programs.gpu-screen-recorder.enable = true;

  users.users.wcnrny = {
    isNormalUser = true;
    description = "Software Enthusiast";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" ];
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    git vim wget curl
    sddm-astronaut
    libsForQt5.qt5.qtgraphicaleffects
  ];

  system.stateVersion = "25.11";
}
