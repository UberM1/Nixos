{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.lsd = {
    enable = true;
    colors = {
      user = "#${config.lib.stylix.colors.base0D}";
      group = "#${config.lib.stylix.colors.base0E}";
      permission = {
        read = "#${config.lib.stylix.colors.base0B}";
        write = "#${config.lib.stylix.colors.base09}";
        exec = "#${config.lib.stylix.colors.base08}";
        exec-sticky = "#${config.lib.stylix.colors.base0E}";
        no-access = "#${config.lib.stylix.colors.base03}";
        octal = "#${config.lib.stylix.colors.base0A}";
        acl = "#${config.lib.stylix.colors.base0C}";
        context = "#${config.lib.stylix.colors.base0C}";
      };
      date = {
        hour-old = "#${config.lib.stylix.colors.base0B}";
        day-old = "#${config.lib.stylix.colors.base0A}";
        older = "#${config.lib.stylix.colors.base03}";
      };
      size = {
        none = "#${config.lib.stylix.colors.base03}";
        small = "#${config.lib.stylix.colors.base0B}";
        medium = "#${config.lib.stylix.colors.base0A}";
        large = "#${config.lib.stylix.colors.base09}";
      };
      inode = {
        valid = "#${config.lib.stylix.colors.base0E}";
        invalid = "#${config.lib.stylix.colors.base08}";
      };
      links = {
        valid = "#${config.lib.stylix.colors.base0E}";
        invalid = "#${config.lib.stylix.colors.base08}";
      };
      tree-edge = "#${config.lib.stylix.colors.base03}";
    };
  };

  programs.bat.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {
      enable = true;
      styles = {
        command = "fg=#${config.lib.stylix.colors.base0D}";
        builtin = "fg=#${config.lib.stylix.colors.base0D}";
        alias = "fg=#${config.lib.stylix.colors.base0C}";
        function = "fg=#${config.lib.stylix.colors.base0D}";
        unknown-token = "fg=#${config.lib.stylix.colors.base08}";
        reserved-word = "fg=#${config.lib.stylix.colors.base0E}";
        path = "fg=#${config.lib.stylix.colors.base0A},underline";
        globbing = "fg=#${config.lib.stylix.colors.base0A}";
        single-quoted-argument = "fg=#${config.lib.stylix.colors.base0B}";
        double-quoted-argument = "fg=#${config.lib.stylix.colors.base0B}";
        dollar-quoted-argument = "fg=#${config.lib.stylix.colors.base0B}";
        back-quoted-argument = "fg=#${config.lib.stylix.colors.base0C}";
        commandseparator = "fg=#${config.lib.stylix.colors.base09}";
        redirection = "fg=#${config.lib.stylix.colors.base09}";
        arg0 = "fg=#${config.lib.stylix.colors.base05}";
        default = "fg=#${config.lib.stylix.colors.base05}";
        comment = "fg=#${config.lib.stylix.colors.base03}";
      };
    };

    history = {
      size = 1000;
      save = 1000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    sessionVariables = {
      PATH = "$HOME/.rbenv/bin:\${KREW_ROOT:-$HOME/.krew}/bin:$PATH";
      GOPATH = "$HOME/go";
      DOCKER_HOST = "unix://$HOME/.colima/docker.sock";
      TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE = "/var/run/docker.sock";
      DISABLE_SPRING = "true";
      KUBECONFIG = "$HOME/.kube/letsbit-htz-stage.yaml:$HOME/.kube/letsbit-htz-tools.yaml:$HOME/.kube/letsbit-htz-prod.yaml";
      TERM = "xterm-kitty";
      RUBY_CONFIGURE_OPTS = "--with-openssl-dir=/opt/homebrew/opt/openssl@3 --with-readline-dir=/opt/homebrew/opt/readline --with-libyaml-dir=/opt/homebrew/opt/libyaml";
      EDITOR = "nvim";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      GEM_HOME = "$HOME/.local/share/gem/ruby/3.3.0";
      GEM_PATH = "$HOME/.local/share/gem/ruby/3.3.0";
      PYENV_ROOT = "$HOME/.pyenv";
    };

    shellAliases = {
      cupp = "python3 ~/Tools/cupp/cupp.py";
      vpnlb = "sudo sysctl net.ipv6.conf.all.disable_ipv6=0;sudo openvpn /etc/openvpn/lb.ovpn";
      vpnesco = "sudo openvpn /etc/openvpn/matiasuberti-aws.ovpn";
      vpnhtb = "sudo sysctl net.ipv6.conf.all.disable_ipv6=0;sudo openvpn /etc/openvpn/academy-regular.ovpn";
      aseprite = "steam steam://rungameid/431730;exit";
    };

    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "ruby"
        "rails"
        "bundler"
        "golang"
        "vscode"
        "macos"
        "brew"
        "fzf"
      ];
    };

    initContent = ''
      autoload -U +X bashcompinit && bashcompinit
      autoload -U +X compinit && compinit

      typeset -U path PATH
      path=(~/.local/bin $path)
      path=(~/go/bin $path)
      path=(~/scripts $path)
      path=(~/.local/share/gem/ruby/3.3.0/bin $path)
      path=(~/perl5/bin $path)
      export PATH

      export FREEDESKTOP_MIME_TYPES_PATH=/opt/homebrew/share/mime/packages/freedesktop.org.xml
      export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

      PERL5LIB="$HOME/perl5/lib/perl5''${PERL5LIB:+:''${PERL5LIB}}"; export PERL5LIB;
      PERL_LOCAL_LIB_ROOT="$HOME/perl5''${PERL_LOCAL_LIB_ROOT:+:''${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
      PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
      PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;

      zstyle ':completion::complete:*' gain-privileges 1
      zstyle ':completion:*' auto-description 'specify: %d'
      zstyle ':completion:*' completer _expand _complete _correct _approximate
      zstyle ':completion:*' format 'Completing %d'
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' menu select=2
      zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
      zstyle ':completion:*' matcher-list ''' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
      zstyle ':completion:*' menu select=long
      zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
      zstyle ':completion:*' use-compctl false
      zstyle ':completion:*' verbose true
      zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

      # rbenv initialization
      if command -v rbenv >/dev/null 2>&1; then
        eval "$(rbenv init - zsh)"
      fi

      # Add local Bundler bin to PATH when present
      _add_bundle_bin() {
        if [ -d ".bundle/bin" ] && [[ ":$PATH:" != *":$PWD/.bundle/bin:"* ]]; then
          export PATH="$PWD/.bundle/bin:$PATH"
        fi
      }
      chpwd_functions+=(_add_bundle_bin)
      _add_bundle_bin

      # Extract nmap information
      function extractPorts(){
        ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
        ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
        echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
        echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
        echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
        echo $ports | tr -d '\n' | xclip -sel clip
        echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
        cat extractPorts.tmp; rm extractPorts.tmp
      }

      # RDP connection for Hyprland (detached)
      function rdp() {
        xfreerdp /dynamic-resolution /clipboard \
          /sound:sys:pulse /cert:ignore /network:auto \
          /gfx:AVC444 /fonts "$@" &>/dev/null & disown
      }

      # Load custom functions
      if [ -f "$HOME/.zsh_functions" ]; then
        source "$HOME/.zsh_functions"
      fi
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = lib.concatStrings [
        "[▓](#${config.lib.stylix.colors.base01})"
        "$os"
        "$username"
        "[](bg:#${config.lib.stylix.colors.base02} fg:#${config.lib.stylix.colors.base01})"
        "$directory"
        "[ ](fg:#${config.lib.stylix.colors.base02})"
      ];

      line_break = {
        disabled = false;
      };

      username = {
        show_always = true;
        style_user = "bg:#${config.lib.stylix.colors.base01}";
        style_root = "bg:#${config.lib.stylix.colors.base0E}";
        format = "[   $user]($style)";
        disabled = false;
      };

      os = {
        style = "bg:#${config.lib.stylix.colors.base0E}";
      };

      directory = {
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $path ]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base03}";
        format = "[ $symbol ($version) ]($style)";
      };

      python = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base03}";
        format = "[ $symbol ($version) ]($style)";
      };

      docker_context = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base0D}";
        format = "[ $symbol $context ]($style) $path";
      };

      elixir = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      elm = {
        symbol = "  ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      git_branch = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[$all_status$ahead_behind ]($style)";
      };

      golang = {
        symbol = "  ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      haskell = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      java = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      julia = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      nodejs = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      nim = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      rust = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      scala = {
        symbol = " ";
        style = "bg:#${config.lib.stylix.colors.base02}";
        format = "[ $symbol ($version) ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#${config.lib.stylix.colors.base0D}";
        format = "[  $time ]($style)";
      };

      character = {
        success_symbol = "[ ➜](#${config.lib.stylix.colors.base0D})";
        error_symbol = "[ ➜](bold red)";
      };

      cmd_duration = {
        min_time = 500;
        format = " [$duration](#${config.lib.stylix.colors.base0D})";
      };
    };
  };
}
