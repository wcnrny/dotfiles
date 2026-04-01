{ config, pkgs, inputs, ... }:

let
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";
in
{
  imports = [
  inputs.nixvim.homeModules.default
  ];

  home.username = "wcnrny";
  home.homeDirectory = "/home/wcnrny";

  xdg.configFile."hypr" = {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/configs/hypr";
    recursive = true; 
  };

  home.packages = with pkgs; [
    # GUI Apps
    kitty rofi hyprlock swww swaynotificationcenter
    vscode vlc mpv imv viewnior
    yazi thunar 
    inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
    brave vesktop
    
    # Dev Tools
    gcc gnumake cmake bun gdb valgrind # neovim
    lazydocker traefik tmux flex bison ncurses
    bc pkg-config-unwrapped ffmpeg
    unixtools.route python3 nodejs
    zed-editor xchm python314Packages.pip

    # Utils
    fastfetch btop htop fzf bat lsd eza
    pavucontrol pamixer brightnessctl
    grim slurp swappy wl-clipboard
    networkmanagerapplet
    cryptsetup gpu-screen-recorder-gtk
    qemu dos2unix file termius unzip
    mlocate gimp chntpw
    gns3-gui gns3-server inetutils libreoffice
    wtype openpomodoro-cli code-cursor claude-code
    

    # Theming
    papirus-icon-theme nwg-look
    bibata-cursors nordzy-cursor-theme
    cmatrix cava

    networkmanager_dmenu
    rofi-bluetooth

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
      
      update = "nix flake update --flake ~/dotfiles && sudo nixos-rebuild switch --flake ~/dotfiles/#wcnrny";
      switch = "sudo nixos-rebuild switch --flake ~/dotfiles/#wcnrny";
      
      usb-ac = "sudo cryptsetup open /dev/disk/by-uuid/e8d676e5-9516-4197-90d9-b0476abadd70 secure_usb && sudo mount /dev/mapper/secure_usb /mnt/usb_secure && echo 'Vault open.'";
      usb-kapat = "sudo umount /mnt/usb_secure && sudo cryptsetup close secure_usb && echo 'Vault closed.'";
    };

    initContent = ''
      fastfetch
      # eval "$(starship init zsh)"
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share
      export PATH=$PATH:/usr/local/bin
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

  xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = rofi -dmenu -i -p "Wi-Fi" -theme-str 'window {width: 500px;}'
    rofi_highlight = True

    [editor]
    terminal = kitty
    gui_if_available = False
  '';

  programs.git = {
    enable = true;
    settings = {
     user = {
      name = "wcnrny";
      email = "contact@wcnrny.tr";
     };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin-top = 5;
        margin-left = 10;
        margin-right = 10;
        height = 34;
        spacing = 4;
        
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/notification" "pulseaudio" "network" "cpu" "memory" "disk" "battery" "tray" ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
        };
        "hyprland/window" = {
          max-length = 50;
          rewrite = {
            "(.*) - Mozilla Firefox" = "🌎 $1";
            "(.*) - Code" = "💻 $1";
            "(.*) - kitty" = "🖧 $1";
          };
        };
        "cpu" = {
          interval = 2;
          format = "CPU: {usage}%";
        };
        "memory" = {
          interval = 2;
          format = "RAM: {}%";
        };
        "disk" = {
          interval = 30;
          format = "SSD: {percentage_used}%";
          path = "/";
        };
	"pulseaudio" = {
          scroll-step = 5;
          format = "VOL: {volume}%";
          format-muted = "MUTED";
          on-click = "pavucontrol";
          on-click-right = "pamixer -t";
          tooltip = false;
        };
        "network" = {
          format-wifi = "WLAN: {signalStrength}%";
          format-ethernet = "ETH: Bağlı";
          format-disconnected = "Ağ Yok";
          tooltip-format = "{ifname} via {gwaddr}";
        };
        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "BAT: {capacity}%";
          format-charging = "CHG: {capacity}%";
          format-plugged = "AC: {capacity}%";
        };
        "custom/notification" = {
          tooltip = false;
          format = "🔔 {icon}";
          format-icons = {
            notification = "Yeni";
            none = "Boş";
            dnd-notification = "Rahatsız Etme (Yeni)";
            dnd-none = "Rahatsız Etme";
          };
          return-type = "json";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };
        "clock" = {
          format = "{:%H:%M | %d.%m.%Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "monospace";
        font-size: 13px;
        font-weight: bold;
        min-height: 0;
      }
      
      window#waybar {
        background-color: transparent;
      }

      /* Catppuccin Mocha Palette ile Modül Arka Planları */
      #workspaces, #window, #clock, #pulseaudio, #network, #cpu, #memory, #disk, #battery, #tray, #custom-notification {
        background-color: #1e1e2e;
        color: #cdd6f4;
        border-radius: 12px;
        padding: 4px 12px;
        margin: 0px 4px;
        border: 1px solid #313244;
      }

      #workspaces button {
        padding: 0 6px;
        color: #6c7086;
        background: transparent;
      }

      #pulseaudio.muted {
        color: #f38ba8;
      }

      #workspaces button.active {
        color: #cba6f7;
      }

      #custom-notification {
        color: #f9e2af;
      }

      #battery.warning:not(.charging) {
        color: #fab387;
      }

      #battery.critical:not(.charging) {
        background-color: #f38ba8;
        color: #1e1e2e;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      @keyframes blink {
        to {
            background-color: #1e1e2e;
            color: #f38ba8;
        }
      }
    '';
  };

 programs.nixvim = {

    enable = true;


    colorschemes.catppuccin.enable = true;

    plugins.lualine.enable = true;

  }; 

  home.stateVersion = "25.11";
}
