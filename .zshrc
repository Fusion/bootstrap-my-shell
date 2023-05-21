# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return;;
esac

# Enter nix shell if needed

#[[ -f $HOME/.nix/nix-user-chroot ]] && {
#    ps | grep nix-user-root &> /dev/null
#    [[ $? -ne 0 ]] && {
#        $HOME/.nix/nix-user-chroot ~/.nix zsh
#    }
#}

# Toggles

I_WANT_COMMANDS=true
I_WANT_PROMPT=true
I_WANT_PLUGINS=true
I_WANT_UPDATES=true

# Do we have a setup file overring some settings?

[[ -f ~/.env.cfr-setup ]] || {
    printf "CFR Environment not setup. Setup full? "
    touch ~/.env.cfr-setup
    if ! read -q; then
        cat <<-EOB > ~/.env.cfr-setup
I_WANT_COMMANDS=false
I_WANT_PROMPT=true
I_WANT_PLUGINS=true
I_WANT_UPDATES=false
EOB
    fi
    echo
}


. ~/.env.cfr-setup

[[ -v I_HAVE_NIX ]] || {
    printf "NIX not installed. Setup? "
    if read -q; then
        printf "\nInstall as root? (not for remote) "
        if read -q; then
            [[ -d /nix ]] || {
              sudo rm -rf ~/.nix* ~/.env.nix
              sh <(curl -L https://nixos.org/nix/install)
            }
        else
            curl -L https://github.com/nix-community/nix-user-chroot/releases/download/1.2.2/nix-user-chroot-bin-1.2.2-i686-unknown-linux-musl -o nix-user-chroot
            chmod +x nix-user-chroot
            mkdir -m 0755 ~/.nix
            ./nix-user-chroot ~/.nix bash -c 'curl -L https://nixos.org/nix/install | sh'
            [[ -d $HOME/.nix ]] && mv nix-user-chroot $HOME/.nix/
        fi
        echo I_HAVE_NIX=true >> ~/.env.cfr-setup
    else
        echo I_HAVE_NIX=false >> ~/.env.cfr-setup
    fi
    . ~/.env.cfr-setup
}


$I_HAVE_NIX || I_WANT_COMMANDS=false

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
dotfiles: manage dotfiles git repo
smug: manage tmux layouts
zcd: interactive cd using ranger
refresh_*: re-sync environment

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

refresh_commands() {
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
    smug # tmuxinator-like
    ranger
    diff-so-fancy
    ${nix_platform}
    ${nix_shell}
]
EOB

    defaultprofilepath=$(\ls -l -d -- /nix/store/*-nix-[0-9][.][0-9]*)
    [[ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]] && { source $HOME/.nix-profile/etc/profile.d/nix.sh; }
    /nix/var/nix/profiles/default/bin/nix-env -irf ~/.env.nix
    # make up for losing default profile in some environments
    [[ -f /nix/var/nix/profiles/default ]] || {
        mkdir -p /nix/var/nix/profiles \
        && sudo ln -s $defaultprofilepath /nix/var/nix/profiles/default
    }
}

$I_WANT_COMMANDS && {
    [[ -f ~/.env.nix ]] || refresh_commands
}

# ZSH plugins

$I_WANT_PLUGINS && {
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
        printf "Install zplug? [y/N]: "
        if read -q; then
            echo; zplug install
        fi
    }
    zplug load > /dev/null
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

$I_WANT_UPDATES && {
    [[ -f /var/lib/apt/periodic/update-success-stamp ]] && {
        freshness=$(( $(date +%s) - $(stat -c%Y /var/lib/apt/periodic/update-success-stamp) ))
        [ $freshness -gt 2592000 ] && {
            sudo apt-get update
        }
    }
}

# Prompt

refresh_prompt() {
    [[ "$OS" != "OSX" ]] && {
        posh_bin=posh-linux-amd64
    } || {
        posh_bin=posh-darwin-arm64
    }
    sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/${posh_bin} -O $HOME/.local/bin/oh-my-posh \
    && sudo chmod +x $HOME/.local/bin/oh-my-posh \
    && mkdir -p ~/.poshthemes \
    && wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip \
    && unzip ~/.poshthemes/themes.zip -d ~/.poshthemes \
    && chmod u+rw ~/.poshthemes/*.omp.* \
    && rm ~/.poshthemes/themes.zip \
    && echo "\nInstall Inconsolata font" \
    && $HOME/.local/bin/oh-my-posh font install \
    && echo Prompt updated.
}

$I_WANT_PROMPT && {
    [[ -f $HOME/.local/bin/oh-my-posh ]] || refresh_prompt
}

[[ -d ~/.poshthemes ]] && {
    eval "$($HOME/.local/bin/oh-my-posh init zsh --config ~/.poshthemes/aliens.omp.json)"
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

refresh_vim() {
    mkdir -p ~/.config/nvim
    cat <<-EOB > ~/.config/nvim/init.lua 
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'junegunn/vim-easy-align'
Plug 'kevinhwang91/rnvimr'
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
vim.cmd [[colorscheme slate]]
EOB
}

[[ -f ~/.local/share/nvim/site/autoload/plug.vim  ]] || {
    sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}
[[ -f ~/.config/nvim/init.lua ]] || refresh_vim

# also, vim everywhere
bindkey -v
[[ -f ~/.inputrc ]] || {
    cat <<-EOB > ~/.inputrc
set editing-mode vi
set keymap vi-insert
EOB
}

# tmux smug goodness
refresh_smug() {
    mkdir -p ~/.config/smug
    cat <<-EOB > ~/.config/smug/trr.yml
session: trr

windows:
  - name: main
    layout: tiled
    commands:
      - ssh voicetest-sip01.convoso.com
      - sudo -s
      - cd /usr/local/opensips_proxy/etc/opensips
    panes:
      - type: horizontal
        commands:
          - ssh voicetest-db02.convoso.com
      - type: horizontal
        commands:
          - ssh voicetest-db01.convoso.com
      - type: horizontal
        commands:
          - ssh voicetest-rtp02.convoso.com
          - sudo -s
          - systemctl --no-pager status rtpengine
      - type: horizontal
        commands:
          - ssh voicetest-rtp01.convoso.com
          - sudo -s
          - systemctl --no-pager status rtpengine
      - type: horizontal
        commands:
          - ssh voicetest-sip02.convoso.com
          - sudo -s
  - name: simulator
    layout: tiled
    commands:
      - ssh cravenscroft@trr-out-sim.convoso.com
      - sudo -s
      - cd /root/sipp
    panes:
      - type: horizontal
        commands:
          - ssh cravenscroft@sink1-las.convoso.com
EOB
}

[[ -d ~/.config/smug ]] || refresh_smug

# ls

$I_WANT_COMMANDS && {
    [[ -f /usr/local/bin/exa-wrapper.sh ]] || {
        sudo curl -o /usr/local/bin/exa-wrapper.sh \
        https://gist.githubusercontent.com/eggbean/74db77c4f6404dd1f975bd6f048b86f8/raw/157d868736f939fdf9c9d235f6f25478d9dbdc02/exa-wrapper.sh \
        && sudo chmod +x /usr/local/bin/exa-wrapper.sh
    }
}
[[ -f /usr/local/bin/exa-wrapper.sh ]] || {
    alias ls="exa-wrapper.sh"
}

# asdf versions manager for many packages and languages
[ -d $HOME/.asdf ] && {
    . $HOME/.asdf/asdf.sh
    fpath=(${ASDF_DIR}/completions $fpath)
}

# kitty integration

if test -n "$KITTY_INSTALLATION_DIR"; then
    export KITTY_SHELL_INTEGRATION="enabled"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
fi

# certinfo

$I_WANT_COMMANDS && {
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
}

# adjust paths
#
[[ "$PATH" =~ .nix-profile ]] || export PATH=~/.nix-profile/bin:$PATH
[[ "$PATH" =~ default ]] || export PATH=/nix/var/nix/profiles/default/bin:$PATH

# Switches

[[ $(command -v nvim) ]] && {
    export EDITOR="nvim"
    [[ -f $HOME/.local/bin/nvim ]] && {
        alias vi=~/.local/bin/nvim
        alias vim=~/.local/bin/nvim
    } || {
        alias vi=~/.nix-profile/bin/nvim
        alias vim=~/.nix-profile/bin/nvim
    }
}
export VISUAL="vim"
export PAGER="bat"
[[ $(command -v ncdu) ]] && {
    alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
}
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm ssh"
export PATH=~/.local/bin:$PATH
[[ -d ~/.krew ]] && export PATH="${PATH}:${HOME}/.krew/bin"

# fzf keys
p=$(which fzf)
if [[ $? -eq 0 ]]; then
    sp="$(find /nix/store -maxdepth 1 -type d -name '*fzf*' -not -name '*man')"
    if [[ "$sp" != "" ]]; then
        while true; do q=$(readlink $p); [[ "" == "$q" ]] && break; p=$q; done; source $sp/bin/../share/fzf/key-bindings.zsh
    fi
fi

# Languages, maybe

[[ -f ~/.asdf/shims/go ]] && {
    export GOPATH=~/go
}
[ ! -z ${GOPATH+x} -a -d $GOPATH/bin ] && export PATH=$GOPATH/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# haskell
[ -f "/Users/chris/.ghcup/env" ] && source "/Users/chris/.ghcup/env" # ghcup-env

# khoj because why note <- see what I did there
[[ $(command -v khoj) ]] && {
    [[ $(command -v tmux) ]] && {
        [[ $(ps aux | grep 'kho[j]') == "" ]] && {
            tmux new-session -d -s khoj 'khoj --no-gui'
        }
    }
}

# interactive cd
icd() {
    local tmpfile="$(mktemp -t tmp.XXXXXX)"
    ranger --choosedir=$tmpfile
    cd -- "$(cat $tmpfile)"
}

refresh_all() {
    refresh_commands
    refresh_prompt
    refresh_vim
    refresh_smug
}

# more git
git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
git config --global interactive.diffFilter "diff-so-fancy --patch"
git config --global color.ui true

# Some self referential work
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
alias dottig="GIT_DIR=$HOME/.dotfiles GIT_WORK_TREE=$HOME tig"
dotfilesnew () {
    mkdir -p ~/.dotfiles \
    && dotfiles init \
    && dotfiles config --local status.showUntrackedFiles no \
    && dotfiles add ~/.zshrc \
    && dotfiles commit -m "Initial commit" \
    && echo "To view tracked files: 'dotfiles ls-files'"
}
dotfilesclone () {
    mkdir -p ~/.dotfiles \
    && dotfiles init \
    && dotfiles config --local status.showUntrackedFiles no \
    && dotfiles remote add origin git@github.com:Fusion/bootstrap-my-shell.git \
    && rm ~/.zshrc \
    && dotfiles pull origin main \
    && echo "To view tracked files: 'dotfiles ls-files'"
}


# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
