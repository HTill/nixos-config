{ config, pkgs, lib, ... }:

{
  # General packages module (without editors)
  
  home.packages = with pkgs; [
    # System utilities
    htop
    tmux
    nano
    wget
    curl
    jq
    yq
    
    # File management
    rclone
    tree
    duf  # Better df
    ncdu  # Disk usage analyzer
    
    # Text processing
    sed
    awk
    grep
    
    # Compression
    zip
    unzip
    tar
    gzip
    xz
    
    # Networking
    net-tools  # ifconfig, netstat
    iproute2  # ip
    dnsutils  # dig, nslookup
    mtr
    nmap
    
    # Security
    gnupg
    pass  # Password manager
    
    # Development tools
    make
    cmake
    autoconf
    automake
    pkg-config
    
    # Version control (Git is in git.nix)
    mercurial
    
    # Containers
    docker-client
    podman
    
    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.poetry
    
    # Rust (optional)
    # rustc
    # cargo
    
    # JavaScript (optional)
    # nodejs
    # yarn
    # pnpm
    
    # Java (optional)
    # jdk
    
    # Go (optional)
    # go
    
    # Database clients
    postgresql
    mysql
    redis
    
    # Cloud tools
    awscli2
    
    # Media
    ffmpeg
    imagemagick
    
    # Office
    libreoffice
    
    # GUI tools (if using X11/Wayland)
    # firefox
    # thunderbird
    # gimp
    # inkscape
  ];
}
