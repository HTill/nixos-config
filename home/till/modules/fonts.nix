{ pkgs, ... }:

# Font configuration module
with pkgs; [
  # Monospace fonts
  fira-code
  jetbrains-mono
  cascade-code  # Good alternative
  
  # Sans-serif fonts
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  
  # Google Fonts
  roboto
  open-sans
  
  # Powerline symbols for shells
  powerline-fonts
  
  # Nerd Fonts (for icons in terminals)
  # nerd-fonts.fira-code
  # nerd-fonts.jetbrains-mono
  
  # Microsoft Fonts (optional)
  # ttf-ms-fonts
]
