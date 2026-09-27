{ pkgs, ... }:

# Custom font configuration for Home Manager
# Add your favorite fonts here

with pkgs; [
  fira-code
  jetbrains-mono
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  # Add more fonts as needed
]
