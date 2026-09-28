{ config, pkgs, lib, ... }:

{
  # General packages module
  
  home.packages = with pkgs; [
    # System utilities
    htop
    tmux
    wget
    curl
    jq
    yq
    
    # File management
    rclone
    tree
    duf
    ncdu
    
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
    net-tools
    iproute2
    dnsutils
    mtr
    nmap
    
    # Security
    gnupg
    pass
    
    # Development tools
    make
    cmake
    autoconf
    automake
    pkg-config
    
    # Version control
    mercurial
    
    # Containers
    docker-client
    podman
    
    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.poetry
    
    # Media
    ffmpeg
    imagemagick
    
    # Office
    libreoffice
  ];
}
