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
  services.xserver.xkb = {
    layout = "tr";
  };
  services.thermald.enable = true; # Intel CPU'lar için termal yönetim (AMD ise bunu kaldır)
  services.power-profiles-daemon.enable = false;
  services.tlp = {
   enable = true;
   settings = {
     CPU_SCALING_GOVERNOR_ON_AC = "performance";
     CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
     CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
     CPU_BOOST_ON_BAT = 0;
    };
  };
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.auto-optimise-store = true;


  networking.hostName = "wcnrny";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "172.16.0.6" "1.1.1.1" "1.0.0.1" "8.8.8.8" ];
  networking.hosts = {
    "127.0.0.1" = ["luxly.local" "docs.luxly.local" "aku-test.com" ];
  };
  networking.wireguard = {
  	enable = true;
	#interfaces."wg0" = {
	#mtu = 1420;
	#postSetup = ''
    #${pkgs.iptables}/bin/iptables -t mangle -A FORWARD -o wg0 -p tcp \
     # --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
  #'';
  #postShutdown = ''
   # ${pkgs.iptables}/bin/iptables -t mangle -D FORWARD -o wg0 -p tcp \
    #  --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
  #'';
#	};
  };
  services.resolved.enable = true;
  services.flatpak.enable = true;
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
    daemon = {
      settings = {
      bip = "10.100.0.1/16";
      default-address-pools = [
	{ base = "10.200.0.0/16"; size = 24; }
	];
      };
    };
  };

  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x,o+rx";
  };
  services.xserver.enable = true;
  services.gvfs.enable = true;
  services.displayManager.sddm = {
    enable = true;
   # xserver.enable = true;
   # wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    # theme = "sddm-astronaut-theme";
    extraPackages = with pkgs; [
      # sddm-astronaut
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qt5compat
    ];
  };

   nixpkgs.config.android_sdk.accept_license = true;


  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 80 443 3000 ];
  allowedUDPPortRanges = [
    { from = 4000; to = 4007; }
    { from = 8000; to = 8010; }
    { from = 50000; to = 65000; }
  ];
  allowedUDPPorts = [ 3478 3479 443 8801 8802 ];
	};

  services.openssh.enable = true;
  services.pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };
  services.blueman.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  #services.desktopManager.gnome.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", GROUP="plugdev"
  '';
  
  programs.zsh.enable = true;
  programs.gpu-screen-recorder.enable = true;

  users.groups.ubridge = {};
  users.groups.plugdev = {};

  users.users.wcnrny = {
    isNormalUser = true;
    description = "Software Enthusiast";
    extraGroups = [ "networkmanager" "wheel" "video" "docker" "kvm" "libvirtd" "ubridge" "dialout" "uucp" "plugdev" "adbusers"  ];
    shell = pkgs.zsh;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [
    git vim wget curl
    sddm-astronaut
    libsForQt5.qt5.qtgraphicaleffects
    host dig bind
    wireguard-tools
    ubridge
    gns3-gui
    gns3-server
    jq
    android-studio
  ];

  system.stateVersion = "25.11";
}
