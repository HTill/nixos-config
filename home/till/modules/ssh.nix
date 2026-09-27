{ config, pkgs, lib, ... }:

{
  # SSH configuration module
  
  # Enable SSH agent
  services.gpg-agent = {
    enable = true;
    sshSupport = true;
  };

  # SSH configuration
  ssh = {
    enable = true;
    
    # Start SSH agent
    startAgent = true;
    
    # Known hosts
    knownHosts = {
      github.com = {
        hostName = "github.com";
        user = "HTill";
        port = 22;
      };
      gitlab.com = {
        hostName = "gitlab.com";
        user = "HTill";
        port = 22;
      };
    };
    
    # SSH config file settings
    extraConfig = ''
      Host *
        ServerAliveInterval 60
        TCPKeepAlive yes
        
      Host github.com
        User HTill
        IdentityFile ~/.ssh/id_ed25519_github
        
      Host gitlab.com
        User HTill
        IdentityFile ~/.ssh/id_ed25519_gitlab
    '';
  };

  # SSH packages
  home.packages = with pkgs; [
    openssh
    sshfs
    sshpass
    keychain  # SSH agent manager
  ];

  # Environment variables
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent.socket";
}
