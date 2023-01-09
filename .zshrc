# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return;;
esac

# Toggles

I_WANT_COMMANDS=true
I_WANT_PROMPT=false
I_WANT_PLUGINS=true
I_WANT_UPDATES=true

[[ -d /nix ]] || {
  sh <(curl -L https://nixos.org/nix/install)
}

case "$(uname)" in
    Linux)
        export OS=Linux
    ;;
    Darwin)
        export OS=OSX
    ;;
    *)
    ;;
esac

help() {
  cat << EOB

CFR various help items:
-----------------------
forgit: interactive git -- \`ga\` etc. (for more: \`aliases\`)

EOB
}

# Build nix package list

nix_platform=""
[[ "$OS" != "OSX" ]] && {
    read -r -d '' nix_platform <<'EOB'
    dstat # better vmstat
    usql # universal sql client
EOB
}
nix_shell=""
[[ "$SHELL" =~ zsh ]] && {
    read -r -d '' nix_shell <<'EOB'
    zplug # zsh plugins
EOB
}

[[ I_WANT_COMMANDS ]] && {
  [[ -f ~/.env.nix ]] || {
    cat <<-EOB > ~/.env.nix
with import <nixpkgs> {}; [
    bat # deluxe cat
    fd # faster than find
    fasd # super cd
    fzf # fast fuzzy finder
    ripgrep # fast grep
    exa # improved ls
    navi # cheatsheet for many shell command needs
    tldr # man
    viddy # watch on steroids
    jq # JSON
    up # edit from stdin, e.g. lshw |& ./up
    ncdu # interactive du
    nq # nohup improved
    rlwrap # wrap commands in readline
    grex # regex commonality builder
    neovim # super vim
    direnv # run .envrc in current directory
    git
    gitui
    clac # rpm calculator
    jc # output to json
    ${nix_platform}
    ${nix_shell}
]
EOB

    defaultprofilepath=$(\ls -d /nix/store/*-nix-*)
    source ~/.nix-profile/etc/profile.d/nix.sh
    nix-env -irf ~/.env.nix
    # make up for losing default profile in some environments
    [[ -f /nix/var/nix/profiles/default ]] || {
         mkdir -p /nix/var/nix/profiles \
         && ln -s $defaultprofilepath /nix/var/nix/profiles/default
    }
  }
}

# ZSH plugins

[[ I_WANT_PLUGINS ]] && {
  [[ "$SHELL" =~ zsh ]] && {
    [[ -f ~/.zplug/init.zsh ]] || {
      curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    }
  }
}

[[ -f ~/.zplug/init.zsh ]] && {
  source ~/.zplug/init.zsh

  zplug 'wfxr/forgit'

  $(zplug check) || {
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
  }
  zplug load
}

[[ "$SHELL" =~ zsh ]] && { autoload -Uz compinit && compinit; }

# Preserve history

setopt SHARE_HISTORY HIST_IGNORE_DUPS
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
preexec_custom_history() {
  echo "$HOSTNAME $$ $(date "+%Y-%m-%dT%H:%M:%S%z") $1" >> "$HOME/.fullhistory"
}
preexec_functions+=(preexec_custom_history)

# On Ubuntu, refresh apt db if older than a month

[[ I_WANT_UPDATES ]] && {
  [[ -f /var/lib/apt/periodic/update-success-stamp ]] && {
      freshness=$(( $(date +%s) - $(stat -c%Y /var/lib/apt/periodic/update-success-stamp) ))
      [ $freshness -gt 2592000 ] && {
          sudo apt-get update
      }
  }
}

# Prompt

[[ I_WANT_PROMPT ]] && {
  [[ -f /usr/local/bin/oh-my-posh ]] || {
    [[ "$OS" != "OSX" ]] && {
      posh_bin=posh-linux-amd64
    } || {
      posh_bin=posh-darwin-arm64
    }
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/${posh_bin} -O /usr/local/bin/oh-my-posh \
    && sudo chmod +x /usr/local/bin/oh-my-posh \
    && mkdir ~/.poshthemes \
    && wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip \
    && unzip ~/.poshthemes/themes.zip -d ~/.poshthemes \
    && chmod u+rw ~/.poshthemes/*.omp.* \
    && rm ~/.poshthemes/themes.zip \
    && echo "Install Inconsolata font" \
    && oh-my-posh font install \
    && echo yes
  }
}

[[ -d ~/.poshthemes ]] && {
  eval "$(oh-my-posh init zsh --config ~/.poshthemes/aliens.omp.json)"
}

# direnv sources a directory .envrc file

[[ $(command -v direnv) ]] && {
  eval "$(direnv hook zsh)"
}

# quick jump

[[ $(command -v fasd) ]] && {
  eval "$(fasd --init auto)"
}

# nvim goodness

[[ -f ~/.local/share/nvim/site/autoload/plug.vim  ]] || {
	sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
	       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}
[[ -f ~/.config/nvim/init.lua ]] || {
    mkdir -p ~/.config/nvim
    cat <<-EOB > ~/.config/nvim/init.lua 
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'junegunn/vim-easy-align'
vim.call('plug#end')
vim.opt.mouse = "v"
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.pastetoggle = "<F2>"
vim.opt.list = true
vim.opt.listchars = "tab:>.,trail:.,extends:#,nbsp:."
EOB
}

# ls

[[ -f /usr/local/bin/exa-wrapper.sh ]] || {
    sudo curl -o /usr/local/bin/exa-wrapper.sh \
    https://gist.githubusercontent.com/eggbean/74db77c4f6404dd1f975bd6f048b86f8/raw/157d868736f939fdf9c9d235f6f25478d9dbdc02/exa-wrapper.sh \
    && sudo chmod +x /usr/local/bin/exa-wrapper.sh
}
alias ls="exa-wrapper.sh"

# certinfo

[[ -f /usr/local/bin/certinfo ]] || {
    [[ "$OS" != "OSX" ]] && {
        certinfo_url="$(curl -sL https://api.github.com/repos/pete911/certinfo/releases/latest | jq -r '.assets[].browser_download_url' | grep linux_amd64)"
    } || {
        certinfo_url="$(curl -sL https://api.github.com/repos/pete911/certinfo/releases/latest | jq -r '.assets[].browser_download_url' | grep darwin_arm64)"
    }
    curl -Lo /tmp/certinfo.tgz ${certinfo_url} \
        && sudo tar zxvf /tmp/certinfo.tgz -C /usr/local/bin/ certinfo \
        && sudo chmod +x /usr/local/bin/certinfo
}

# Switches

export EDITOR="nvim"
export VISUAL="vim"
export PAGER="bat"
alias vi=~/.nix-profile/bin/nvim
alias vim=~/.nix-profile/bin/nvim
alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm ssh"
export PATH=~/.local/bin:$PATH
[[ -d ~/.krew ]] && export PATH="${PATH}:${HOME}/.krew/bin"

# Languages, maybe

[[ -f ~/.asdf/shims/go ]] && {
    export GOPATH=~/go
}
[ ! -z ${GOPATH+x} -a -d $GOPATH/bin ] && export PATH=$GOPATH/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ "$PATH" =~ .nix-profile ]] || export PATH=~/.nix-profile/bin/:$PATH
[[ "$PATH" =~ default ]] || export PATH=/nix/var/nix/profiles/default/bin:$PATH

# haskell
[ -f "/Users/chris/.ghcup/env" ] && source "/Users/chris/.ghcup/env" # ghcup-env

# Some self referential work
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias dottig="GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME tig"
[[ -d ~/.dotfiles ]] || {
    mkdir -p ~/.dotfiles \
    && dotfiles init \
    && dotfiles config --local status.showUntrackedFiles no \
    && dotfiles add ~/.zshrc \
    && dotfiles commit -m "Initial commit" \
    && echo "To view tracked files: 'dotfiles ls-files'"
}


# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
