# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"
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

case "$(uname -s)" in
    Linux)
        export OS=Linux
        export OSNAMES=(linux)
    ;;
    Darwin)
        export OS=OSX
        export OSNAMES=(darwin osx macos macosx)
    ;;
    *)
    ;;
esac
case "$(uname -m)" in
    arm64)
        export ARCHVENDOR=arm
        case "$OS" in
            Linux)
                export ARCHNAMES=(arm64)
            ;;
            Darwin)
                export ARCHNAMES=(arm64 amd64 x86_64 x64)
            ;;
        esac
    ;;
    x86_64)
        export ARCHVENDOR=intel
        export ARCHNAMES=(amd64 x86_64 x64)
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
set diffopt+=iwhite: ignore whitespace in diff
rvi: remote vim edit
lcd: change directory in vim
<ctr>v <shit>I: start inserting block, until <esc>
:g/^\s*$/d: g to all 0+space blank lines and delete
:put =eval(join(getline(1, '$'), '+')): insert eval of join all lines with '+' operator.
:!open %: execute open of current file
NoIDE: remove IDE / DBUI: sql editor / Sql: NoIDE+DBUI / Dag: NoIDE+dag.toggle

EOB
        ;;
    dap|nvim-dap)
    cat << EOB

DAP:
----
UI:
    :lua require('dapui').toggle()
Python:
    Install debugger: pip3 install debugpy
    Load: :lua require('dap-python').setup()
All:
    Help: help dap.txt
    Breakpoint: :lua require'dap'.set_breakpoint()
    Run: lua require'dap'.continue()|run_to_cursor()
    Step: lua require'dap'.set_over()|step_into()|step_out()
    Open console: lua require'dap'.repl.open()

EOB
        ;;
    chef)
    cat << EOB

CHEF:
-----
Ruby:
    export PATH=\$PATH:/opt/chef-workstation/embedded/bin
    export GEM_HOME=/opt/chef-workstation/embedded/lib/ruby/gems
    export GEM_PATH=/opt/chef-workstation/embedded/lib/ruby/gems

EOB
        ;;
    kitty)
    cat << EOB

KITTY:
----
<ctrl><shit><right click>: open output in pager
<ctrl><shit>h: scrollback in pager
<ctrl><shit>z: previous shell prompt
<ctrl><shit>l: next layout
<ctrl><shit>[: prev window
<ctrl><shit>f: move window forward
<ctrl><shit>u: insert unicode
<ctrl><shit><esc>: kitty shell

EOB
        ;;
    git)
    cat << EOB

GIT:
----
Enforce git key:
    export GIT_SSH_COMMAND='ssh -o IdentitiesOnly=yes -i ~/.ssh/<key>'
Use ad-hoc difftool (e.g. difftastic):
    export GIT_EXTERNAL_DIFF=difft

EOB
        ;;
    rg)
    cat << EOB

ripgrep:
--------
Examples:
    rg 'hello world'
    rg 'hello world' -tjs # .js files only
    rg 'hello world' -Tjs # except .js files
    rg '\bword\b'         # pattern to look up a word between blank spaces
Use '-l' and '-L' to show files including/not including pattern.

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
fetch_command <gitorg/gitpkg> <binaryname>: retrieve commands from git

help vim: vim help
help dap: nvim debugger help
help chef: various chef configuration info
help kitty: kitty commands and shortcuts
help git: git tips and tricks
help rg: ripgrep help

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
    difftastic
    pdsh
    zellij
    xplr
    nushell
    lazygit
    ${nix_platform}
    ${nix_shell}
]
EOB


    [[ -v I_HAVE_NIX ]] && {
        defaultprofilepath=$(\ls -d -- /nix/store/*-nix-[0-9][.][0-9]*)
        [[ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]] && { source $HOME/.nix-profile/etc/profile.d/nix.sh; }
        # make up for losing default profile in some environments
        [[ -f /nix/var/nix/profiles/default ]] || {
            mkdir -p /nix/var/nix/profiles \
            && sudo ln -s $defaultprofilepath /nix/var/nix/profiles/default
        }
        /nix/var/nix/profiles/default/bin/nix-env -irf ~/.env.nix
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
    zplug "zsh-users/zsh-syntax-highlighting", defer:2

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
    eval "$($HOME/.local/bin/oh-my-posh init zsh --config ~/.poshthemes/montys.omp.json)"
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
    # pre-neovim 1.0 workaround
    [[ -f ~/.local/share/nvim/lazy/neogit/lua/neogit/lib/hl.lua ]] && sr=~/.local/share/nvim/lazy/neogit/lua/neogit/lib/hl.lua
    [[ "$sr" == "" ]] || {
        sed -i .bak -e 's/local color.*/local color = vim.api.nvim_get_hl_by_name(name, true)/' -e 's/local exists.*/local exists, hl = pcall(vim.api.nvim_get_hl_by_name, hl_name, true)/' $sr
    }
    #
    mkdir -p ~/.config/nvim
    cat <<-EOB > ~/.config/nvim/init.lua 
-- config v1.6
vim.g.mapleader = ','
if vim.fn.has('termguicolors') then
    vim.opt.termguicolors = true
end

function CommandToStartifyTable(command)
    return function()
        local cmd_output = vim.fn.systemlist(command .. " 2>/dev/null")
        local files =
            vim.tbl_map(
            function(v)
                return {line = v, path = v}
            end,
            cmd_output
        )
        return files
    end
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    checker = { enabled = true, frequency = 86400 },
    { "williamboman/mason.nvim" },
    { "itchyny/lightline.vim" },
    { "nvim-tree/nvim-web-devicons" },
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_background = 'soft'
            vim.g.gruvbox_material_better_performance = 1
            vim.cmd [[colorscheme gruvbox-material]]
        end,
    },
    { "junegunn/vim-easy-align" },
    { "kevinhwang91/rnvimr" },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    },
    {
        "ldelossa/nvim-ide",
    },
    {
        "airblade/vim-rooter",
        config = function()
            vim.g.rooter_patterns = { '.git' }
        end,
    },
    { "rcarriga/nvim-notify" },
    { "dnlhc/glance.nvim" },
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason-lspconfig.nvim" },
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
            })
        end,
    },
    { "hrsh7th/cmp-nvim-lsp" },
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v2.x",
        config = function()
            local lsp = require('lsp-zero').preset({})
            lsp.on_attach(function(_, bufnr)
                lsp.default_keymaps({ buffer = bufnr })
            end)
            require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())
            lsp.setup()
        end,
    },
    {
        "ray-x/guihua.lua",
        build = "cd lua/fzy && make",
        config = function()
            require 'guihua.maps'.setup({
                maps = {
                    close_view = '<esc>'
                }
            })
        end,
    },
    {
        "ray-x/navigator.lua",
        config = function()
            require 'navigator'.setup({
                mason = true
            })
        end,
    },
    { "L3MON4D3/LuaSnip" },
    {
        "mfussenegger/nvim-dap",
        config = function()
            local dap = require('dap')
            dap.configurations.python = {
                {
                    type = 'python',
                    request = 'launch',
                    name = "Launch Python file",
                    program = "",
                    pythonPath = function()
                        return 'python3'
                    end,
                },
            }
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        config = function()
            require('dapui').setup()
        end,
    },
    { "mfussenegger/nvim-dap-python" },
    {
        "ibhagwan/fzf-lua",
        branch = "main",
        config = function()
            vim.keymap.set("n", "<C-p>",
                "<cmd>lua require('fzf-lua').files()<CR>", { silent = true })
            vim.keymap.set("n", "<C-\\\\>",
                "<cmd>lua require('fzf-lua').buffers()<CR>", { silent = true })
        end,
    },
    { "tpope/vim-dadbod" },
    {
        "kristijanhusak/vim-dadbod-ui",
        config = function()
            vim.g.db_ui_save_location = '~/Cells/db_ui'
        end,
    },
    {
        "kristijanhusak/vim-dadbod-completion",
        config = function()
            vim.api.nvim_exec(
                [[
                    autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
                    autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })
                ]],
                false
            )
        end,
    },
    { "SmiteshP/nvim-navic" },
    {
        "utilyre/barbecue.nvim",
        config = function()
            require('barbecue').setup()
        end,
    },
    {
        "mhinz/vim-startify",
        config = function()
            vim.g.startify_custom_header = { "~~ Chris' Stuff ~~" }
            vim.g.startify_lists = {
                { type = 'sessions', header = {'Sessions'} },
                { type = 'files', header = {'MRU'} },
                { type = "dir", header = {'MRU ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t')} },
                { type = 'bookmarks', header = {'Bookmarks'} },
                { type = 'commands', header = {'Commands'} }},
                { type = CommandToStartifyTable("git ls-files -m"), header = {'Git modified'} },
                { type = CommandToStartifyTable("git ls-files -o --exclude-standard"), header = {'Git untracked'} }


        end,
    },
    { "sindrets/diffview.nvim" },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            x = {
                name = "Database",
                u = { "<Cmd>DBUIToggle<Cr>", "Toggle UI" },
                f = { "<Cmd>DBUIFindBuffer<Cr>", "Find buffer" },
                r = { "<Cmd>DBUIRenameBuffer<Cr>", "Rename buffer" },
                q = { "<Cmd>DBUILastQueryInfo<Cr>", "Last query info" },
            },
        }
    },
})


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

function Open_nvim_ide_panels()
    if InstanceIde == nil then
        InstanceIde = require('ide')
        InstanceIde.setup({
            icon_set = "nerd",
            panels = {
                left = "explorer",
                right = "git"
            },
            panel_groups = {
                explorer = {
                    require('ide.components.outline').Name,
                    require('ide.components.bufferlist').Name,
                    require('ide.components.explorer').Name,
                    require('ide.components.bookmarks').Name,
                    require('ide.components.callhierarchy').Name,
                },
                git = {
                    require('ide.components.changes').Name,
                    require('ide.components.commits').Name,
                    require('ide.components.timeline').Name,
                    require('ide.components.branches').Name,
                },
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
    end
    local ws = require('ide.workspaces.workspace_registry').get_workspace(vim.api.nvim_get_current_tabpage())
    if ws ~= nil then
        ws.open_panel(require('ide.panels.panel').PANEL_POS_BOTTOM)
        ws.open_panel(require('ide.panels.panel').PANEL_POS_LEFT)
        ws.open_panel(require('ide.panels.panel').PANEL_POS_RIGHT)
    end
end

function Close_nvim_ide_panels()
    if InstanceIde ~= nil then
        local ws = require('ide.workspaces.workspace_registry').get_workspace(vim.api.nvim_get_current_tabpage())
        if ws ~= nil then
            ws.close_panel(require('ide.panels.panel').PANEL_POS_BOTTOM)
            ws.close_panel(require('ide.panels.panel').PANEL_POS_LEFT)
            ws.close_panel(require('ide.panels.panel').PANEL_POS_RIGHT)
        end
    end
end

vim.api.nvim_exec([[
command! -nargs=0 IDE lua Open_nvim_ide_panels()
command! -nargs=0 NoIDE lua Close_nvim_ide_panels()
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
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^w' backward-kill-word

# missing shell completions

refresh_completions() {
    dst=$(printf "%s\n" "${fpath[@]}" | grep misc)
    [[ "$dst" == "" ]] && {
        echo "I need to know where zplug misc completions are located."
        return
    }
    [[ -d /tmp/sh-manpage-completions ]] || {
        cd /tmp && git clone https://github.com/fusion/sh-manpage-completions.git
    }
    cd /tmp/sh-manpage-completions
    echo "##########################################################"
    echo "# Note:                                                  #"
    echo "# If you see an error about FlexLexer.h, you need to:    #"
    echo "#     sudo apt install libfl-dev                         #"
    echo "##########################################################"
    for cmd in $(\ls /usr/share/man/man1); do
        cmdname=$cmd
        cmd=${cmd%.gz*}
        cmd=${cmd%.1*}
        [[ "$cmd" == "[" ]] && { continue; }
        command -v $cmd &>/dev/null && {
            ./run.sh /usr/share/man/man1/$cmdname
        }
    done
    cp -f completions/zsh/* $dst/
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
[[ -f $HOME/.local/bin/exa-wrapper.sh ]] && {
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
    alias vimdiff="nvim -d"
}
export VISUAL="vim"
export PAGER="bat"
[[ $(command -v ncdu) ]] && {
    alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
}
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm ssh"
[[ "$TERM" == "rio" ]] && alias ssh="TERM=xterm-256color ssh"
[[ -d ~/.krew ]] && export PATH="${PATH}:${HOME}/.krew/bin"

# fzf keys
p=$(which fzf)
if [[ $? -eq 0 ]]; then
    [[ -v I_HAVE_NIX ]] && {
        sp="$(find /nix/store -maxdepth 1 -type d -name '*-fzf-*' -not -name '*man')"
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

# hello tailscale
alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

# meld
alias meld="open -W -a Meld $@"

# Fabric?
[[ $(command -v fab2) ]] && {
_complete_fab2() {
    collection_arg=''
    if [[ "${words}" =~ "(-c|--collection) [^ ]+" ]]; then
        collection_arg=$MATCH
    fi
    reply=( $(fab2 ${=collection_arg} --complete -- ${words}) )
}
compctl -K _complete_fab2 + -f fab2
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

# c-specific
gitprep() {
    [[ -f ./git_ssh ]] && { export GIT_SSH=./git_ssh; } || {
        [[ -f ./keys/git_ssh ]] && { export GIT_SSH=./keys/git_ssh; } || {
            [[ "$SSH_AGENT_PID" == "" ]] && eval `ssh-agent -k`
            eval `ssh-agent -s`
            ssh-add ~/.ssh/github-convoso-opensips
        }
    }
}

gitid() {
    [[ "$SSH_AGENT_PID" == "" ]] && eval `ssh-agent -k`
    eval `ssh-agent -s`
    [[ "$1" == "1" ]] && ssh-add ~/.ssh/cfr_id_ed25519
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

# man
man() { command man $@ | col -bx | bat -l man -p }

# more commands
fetch_command() {
    [[ "$2" == "" ]] && { echo "Please provide <gitrepo>/<gitpkg> <binaryname>"; return; }
    pkgurl=""
    curl -s "https://api.github.com/repos/$1/releases/latest" | jq -r '.assets[] .browser_download_url' \
    | while read pkgname; do
        [[ "$pkgname" == *"gz" ]] || { continue; }
        for osname in ${OSNAMES[@]}; do
            for archname in ${ARCHNAMES[@]}; do
                [[ "$(echo $pkgname | grep $osname | grep $archname)" != "" ]] && { pkgurl=$pkgname; break; }
            done
        done
    done
    [[ "$pkgurl" == "" ]] && { echo "Unable to retrieve usable package name"; return; }
    wrkdir=$(mktemp -d)
    cd $wrkdir
    curl -s -LO $pkgurl
    tar zxvf *gz &>/dev/null
    [[ "$OS" == "Linux" ]] && {
        binary=$(find . -perm /111 -type f -name $2) 2>/dev/null
    } || {
        binary=$(find . -perm +111 -type f -name $2) 2>/dev/null
    }
    [[ "$binary" == "" ]] && {
        echo "Could not find requested binary\nAvailable:"
        ls -R
        return
    }
    cp $binary ~/.local/bin/
    echo "$2 installed to ~/.local/bin"
}

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


if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# bun completions
[ -s "/Users/chris/.bun/_bun" ] && source "/Users/chris/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"
