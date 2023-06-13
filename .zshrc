# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return;;
esac

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# We like dialogs

[[ -d $HOME/.local/bin ]] || mkdir -p $HOME/.local/bin
export PATH=~/.local/bin:$PATH
command -v dialog &>/dev/null || {
    echo No dialog command. Quickly setting up. You need build-essential or what not.
    pushd /tmp &>/dev/null
    curl -sLO https://invisible-island.net/datafiles/release/dialog.tar.gz \
    && d=$(tar ztvf /tmp/dialog.tar.gz| head -1 | awk '{print $NF}') \
    && tar zxvf dialog.tar.gz &>/dev/null \
    && cd $d \
    && ./configure && make \
    && mv dialog $HOME/.local/bin
    popd &>/dev/null
}

# Toggles

I_WANT_COMMANDS=true
I_WANT_PROMPT=true
I_WANT_PLUGINS=true
I_WANT_UPDATES=true

# Do we have a setup file overring some settings?

[[ -f ~/.env.cfr-setup ]] || {
    st=$(dialog --clear \
        --backtitle "First setup" \
        --title "Missing CFR environment" \
        --menu "Please select a setup option." 14 30 4  0 "No commands." 1 "NIX (sudo)" 2 "LinuxBrew (user)" 2>&1 >/dev/tty)
    reset
    touch ~/.env.cfr-setup
    case $st in
    0)
        cat <<-EOB > ~/.env.cfr-setup
I_WANT_COMMANDS=false
I_WANT_PROMPT=true
I_WANT_PLUGINS=true
I_WANT_UPDATES=false
EOB
    ;;
    1)
        I_WANT_NIX=true
    ;;
    2)
        I_WANT_BREW=true
    ;;
    esac
    echo
}


. ~/.env.cfr-setup

[[ -v I_WANT_NIX ]] && {
    [[ -d /nix ]] || {
        sudo rm -rf ~/.nix* ~/.env.nix
        sh <(curl -L https://nixos.org/nix/install)
    }
    echo I_HAVE_NIX=true >> ~/.env.cfr-setup
    . ~/.env.cfr-setup
}

[[ -v I_WANT_BREW ]] && {
    [[ -d $HOME/.linuxbrew ]] || {
        mkdir $HOME/.linuxbrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $HOME/.linuxbrew
        $HOME/.linuxbrew/bin/brew update
    }
    echo I_HAVE_BREW=true >> ~/.env.cfr-setup
    . ~/.env.cfr-setup
}

[[ -v I_HAVE_BREW ]] && export PATH=$HOME/.linuxbrew/sbin:$HOME/.linuxbrew/bin:$PATH

$I_HAVE_NIX || $I_HAVE_BREW || I_WANT_COMMANDS=false

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
    case "$1" in
        vim|nvim)
    cat << EOB

VIM commands:
-------------
<ctr>o: jump back to previous location
K: display information
gd: go to definition
<ctrl>w s/<ctrl>w v: split
<ctrl>p: fzf files
set [no]list: display invisible characters
rvi: remote vim edit
lcd: change directory in vim
NoIDE: remove IDE / DBUI: sql editor / Sql: NoIDE+DBUI / Dag: NoIDE+dag.toggle

EOB
        ;;
    dap|nvim-dap)
    cat << EOB

DAP:
----
UI:
    `:lua require('dapui').toggle()`
Python:
    Install debugger: `pip3 install debugpy`
    Load: `:lua require('dap-python').setup()`
All:
    Help: `help dap.txt`
    Breakpoint: `:lua require'dap'.set_breakpoint()`
    Run: `lua require'dap'.continue()|run_to_cursor()`
    Step: `lua require'dap'.set_over()|step_into()|step_out()`
    Open console: `lua require'dap'.repl.open()`

EOB
        ;;
    *)
    cat << EOB

CFR various help items:
-----------------------
forgit: interactive git -- \`ga\` etc. (for more: \`aliases\`)
dotfiles: manage dotfiles git repo
smug: manage tmux layouts
icd: interactive cd using ranger
refresh_*: re-sync environment

help vim: vim help
help dap: nvim debugger help

EOB
        ;;
        esac
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


    [[ -v I_HAVE_NIX ]] && {
        defaultprofilepath=$(\ls -l -d -- /nix/store/*-nix-[0-9][.][0-9]*)
        [[ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]] && { source $HOME/.nix-profile/etc/profile.d/nix.sh; }
        /nix/var/nix/profiles/default/bin/nix-env -irf ~/.env.nix
        # make up for losing default profile in some environments
        [[ -f /nix/var/nix/profiles/default ]] || {
            mkdir -p /nix/var/nix/profiles \
            && sudo ln -s $defaultprofilepath /nix/var/nix/profiles/default
        }
    }
    [[ -v I_HAVE_BREW ]] && {
        for pkg in $(awk 'NR>1 {print $1}' ~/.env.nix | grep -v ']'); do
            brew install $pkg
        done
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
    sudo curl -L https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/${posh_bin} -o $HOME/.local/bin/oh-my-posh \
    && sudo chmod +x $HOME/.local/bin/oh-my-posh \
    && mkdir -p ~/.poshthemes \
    && curl -L https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -o ~/.poshthemes/themes.zip \
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
vim.g.mapleader = ','
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'junegunn/vim-easy-align'
Plug 'kevinhwang91/rnvimr'
Plug 'ldelossa/nvim-ide'
Plug 'neovim/nvim-lspconfig'
Plug('williamboman/mason.nvim')
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug('VonHeikemen/lsp-zero.nvim', {['branch'] = 'v2.x'})
Plug 'j-hui/fidget.nvim'
Plug 'ldelossa/nvim-ide'
Plug 'rcarriga/nvim-notify'
Plug 'dnlhc/glance.nvim'
Plug('ibhagwan/fzf-lua', {branch = 'main'})
Plug 'nvim-tree/nvim-web-devicons'
Plug 'sainnhe/gruvbox-material'
Plug 'airblade/vim-rooter'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'mfussenegger/nvim-dap-python'
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
if vim.fn.has('termguicolors') then
    vim.opt.termguicolors = true
end
vim.g.db_ui_save_location = '~/Cells/db_ui'
vim.g.gruvbox_material_background = 'soft'
vim.g.gruvbox_material_better_performance = 1
vim.cmd [[colorscheme gruvbox-material]]
vim.g.rooter_patterns = {'.git'}
local lsp = require('lsp-zero').preset({})
lsp.on_attach(function(client, bufnr)
lsp.default_keymaps({buffer = bufnr})
end)
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
lsp.setup()
require('fidget').setup()
local bufferlist      = require('ide.components.bufferlist')
local explorer        = require('ide.components.explorer')
local outline         = require('ide.components.outline')
local callhierarchy   = require('ide.components.callhierarchy')
local timeline        = require('ide.components.timeline')
local terminal        = require('ide.components.terminal')
local terminalbrowser = require('ide.components.terminal.terminalbrowser')
local changes         = require('ide.components.changes')
local commits         = require('ide.components.commits')
local branches        = require('ide.components.branches')
local bookmarks       = require('ide.components.bookmarks')
require('ide').setup({
    icon_set = "nerd",
    panels = {
        left = "explorer",
        right = "git"
    },
    panel_groups = {
        explorer = { outline.Name, bufferlist.Name, explorer.Name, bookmarks.Name, callhierarchy.Name },
        git = { changes.Name, commits.Name, timeline.Name, branches.Name }
    },
    workspaces = {
        auto_open = 'both',
    },
    panel_sizes = {
        left = 30,
        right = 30,
        bottom = 15
    }
})
local dap = require('dap')
require('dapui').setup()
dap.configurations.python = {
    {
        type = 'python';
        request = 'launch';
        name = "Launch Python file";
        program = "${file}";
        pythonPath = function()
            return 'python3'
        end;
    },
}
vim.api.nvim_exec([[
function! NoIDE()
    let i = 0
    while i < 3
        close 1
        let i += 1
    endwhile
    let i = 0
    while i < 4
        close 2
        let i += 1
    endwhile
endfunction
command! -nargs=0 NoIDE :call NoIDE()
function! Sql()
    NoIDE
    DBUI
endfunction
command! -nargs=0 Sql :call Sql()
function! Dag()
    NoIDE
    lua require("dapui").toggle()
endfunction
command! -nargs=0 Dag :call Dag()
]], false)
vim.keymap.set("n", "<C-p>",
  "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
EOB
}

[[ -f ~/.local/share/nvim/site/autoload/plug.vim  ]] || {
    sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}
[[ -f ~/.config/nvim/init.lua ]] || refresh_vim

rvi() {
    local target
    [[ "$1" == "" ]] && {echo "$0 <host>|server [kill]."; return;}
    [[ $1 == server ]] && {screen nvim --headless --listen 0.0.0.0:6666; return;}
    [[ $1 == *.*  ]] && target=$1 || {
        target="$(grep $1 ~/.ssh/config -A 1 | awk '/HostName/{print $2}')"
        [[ "$target" == "" ]] && target=$1
    }
    action="${2:-start}"
    case $action in
        start)
        [[ "$(ssh $target ps x | grep nvim | grep headless)" == "" ]] && {
            ssh -n $target -- "$([[ -f \$HOME/.nix-profile/bin/nvim ]] && { echo \$HOME/.nix-profile/bin/nvim } || { echo \$HOME/.local/bin/nvim }) --headless --listen 0.0.0.0:6666 &>/dev/null &"
        }
        /Applications/neovide.app/Contents/MacOS/neovide --server $target:6666
        ;;
        stop|kill)
            nvim --server $target:6666 --remote-send ':qa!<CR>'
            return
        ;;
    esac
}

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
    [[ -f $HOME/.local/bin/exa-wrapper.sh ]] || {
        sudo curl -o $HOME/.local/bin/exa-wrapper.sh \
        https://gist.githubusercontent.com/eggbean/74db77c4f6404dd1f975bd6f048b86f8/raw/157d868736f939fdf9c9d235f6f25478d9dbdc02/exa-wrapper.sh \
        && sudo chmod +x $HOME/.local/bin/exa-wrapper.sh
    }
}
[[ -f $HOME/.local/bin/exa-wrapper.sh ]] || {
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
    [[ -f $HOME/.local/bin/certinfo ]] || {
        [[ "$OS" != "OSX" ]] && {
            certinfo_url="$(curl -sL https://api.github.com/repos/pete911/certinfo/releases/latest | jq -r '.assets[].browser_download_url' | grep linux_amd64)"
        } || {
            certinfo_url="$(curl -sL https://api.github.com/repos/pete911/certinfo/releases/latest | jq -r '.assets[].browser_download_url' | grep darwin_arm64)"
        }
        curl -Lo /tmp/certinfo.tgz ${certinfo_url} \
            && sudo tar zxvf /tmp/certinfo.tgz -C $HOME/.local/bin/ certinfo \
            && sudo chmod +x $HOME/.local/bin/certinfo
    }
}

# adjust paths
#
[[ -v I_HAVE_NIX ]] && {
    [[ "$PATH" =~ .nix-profile ]] || export PATH=~/.nix-profile/bin:$PATH
    [[ "$PATH" =~ default ]] || export PATH=/nix/var/nix/profiles/default/bin:$PATH
}

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
[[ -d ~/.krew ]] && export PATH="${PATH}:${HOME}/.krew/bin"

# fzf keys
p=$(which fzf)
if [[ $? -eq 0 ]]; then
    [[ -v I_HAVE_NIX ]] && {
        sp="$(find /nix/store -maxdepth 1 -type d -name '*fzf*' -not -name '*man')"
        if [[ "$sp" != "" ]]; then
            while true; do q=$(readlink $p); [[ "" == "$q" ]] && break; p=$q; done; source $sp/bin/../share/fzf/key-bindings.zsh
        fi
    }
    [[ -v I_HAVE_BREW ]] && {
        source $HOME/.linuxbrew/var/homebrew/linked/fzf/shell/key-bindings.zsh
    }
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

# mackup specials
[[ -d ~/.mackup ]] || {
    mkdir -p ~/.mackup

    cat <<-EOB > ~/.mackup/cfr-dbs
EOB
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


# Weaken security in some ways... but negates the need to run as root at all time
alias sudo='sudo env "PATH=$PATH"'

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
