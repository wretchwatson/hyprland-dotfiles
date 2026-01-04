# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

# Aliases
alias ll='eza -l --icons'
alias la='eza -la --icons'
alias ls='eza --icons'
alias cat='bat'
alias grep='grep --color=auto'
alias c='clear'
alias h='history'

# Pacman kısayolları
alias up='sudo pacman -Syu'          # Sistem güncelle
alias in='sudo pacman -S --needed'   # Paket kur
alias un='sudo pacman -R'            # Paket kaldır
alias uns='sudo pacman -Rs'          # Paket + bağımlılıkları kaldır
alias search='pacman -Ss'            # Paket ara
alias info='pacman -Si'              # Paket bilgisi
alias list='pacman -Q'               # Kurulu paketler
alias qm='pacman -Qs'                # Kurulu paketi ara
alias clean='sudo pacman -Sc'        # Cache temizle
alias orphan='sudo pacman -Rs $(pacman -Qtdq)' # Yetim paketleri kaldır

# Paru kısayolları (AUR)
alias pup='paru -Syu'                # Sistem + AUR güncelle
alias pin='paru -S'                  # AUR paket kur
alias psearch='paru -Ss'             # AUR paket ara
alias pinfo='paru -Si'               # AUR paket bilgisi
alias pclean='paru -Sc'              # AUR cache temizle
alias pupgrade='paru -Sua'           # Sadece AUR güncelle

#Nano kısayolları
alias n='nano'
alias sn='sudo nano'

# Zoxide (Better cd)
eval "$(zoxide init zsh)"

# FZF Keybindings
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# Keybindings
# bindkey '^[[A' history-substring-search-up
# bindkey '^[[B' history-substring-search-down
bindkey ';5C' forward-word
bindkey ';5D' backward-word

# Path
export PATH=$HOME/bin:/usr/local/bin:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
