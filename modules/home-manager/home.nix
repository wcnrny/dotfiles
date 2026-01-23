{ config, pkgs, inputs, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{
  imports = [
  inputs.caelestia-shell.homeManagerModules.default
  ];

  home.username = "wcnrny";
  home.homeDirectory = "/home/wcnrny";

  xdg.configFile."hypr" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/hypr";
    recursive = true; 
  };

  xdg.configFile."quickshell" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/quickshell";
    recursive = true;
  };

  home.packages = with pkgs; [
    # GUI Apps
    kitty rofi waybar hyprlock swww swaynotificationcenter
    discord vscode vlc mpv imv viewnior
    yazi thunar 
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    brave
    
    # Dev Tools
    gcc gnumake cmake bun gdb valgrind neovim
    lazydocker traefik tmux

    # Utils
    fastfetch btop htop fzf bat lsd eza
    pavucontrol pamixer brightnessctl
    grim slurp swappy wl-clipboard
    networkmanagerapplet
    cryptsetup gpu-screen-recorder-gtk

    # Theming
    papirus-icon-theme nwg-look
    bibata-cursors nordzy-cursor-theme
    
    # inputs.caelestia-shell.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -a";
      lt = "lsd --tree";
      g = "git";
      
      nn = "nvim ~/dotfiles/hosts/wcnrny/configuration.nix";
      nh = "nvim ~/dotfiles/modules/home-manager/home.nix"; 
      nf = "nvim ~/dotfiles/flake.nix";
      
      update = "sudo nixos-rebuild switch --flake ~/dotfiles/#wcnrny";
      
      usb-ac = "sudo cryptsetup open /dev/disk/by-uuid/e8d676e5-9516-4197-90d9-b0476abadd70 secure_usb && sudo mount /dev/mapper/secure_usb /mnt/usb_secure && echo 'Vault open.'";
      usb-kapat = "sudo umount /mnt/usb_secure && sudo cryptsetup close secure_usb && echo 'Vault closed.'";
    };

    initContent = ''
      fastfetch
      # eval "$(starship init zsh)"
    '';

    oh-my-zsh = {
      enable = true;
      theme = "crcandy";
      plugins = [ "git" "sudo" "history" ];
    };
  };

  programs.starship.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
     user = {
      name = "wcnrny";
      email = "contact@wcnrny.tr";
     };
    };
  };

  programs.caelestia = {
  enable = true;
  systemd = {
    enable = false; # if you prefer starting from your compositor
    target = "graphical-session.target";
    environment = [];
  };
  settings = {
    bar.status = {
      showBattery = false;
    };
    paths.wallpaperDir = "~/Pictures/Wallpapers";
  };
  cli = {
    enable = true; # Also add caelestia-cli to path
    settings = {
      theme.enableGtk = false;
    };
  };
};

  home.stateVersion = "25.11";
}
