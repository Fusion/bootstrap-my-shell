# v1.1.0
# If not running interactively, don't do anything

case $- in
    *i*) ;;
      *) return;;
esac

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# -> action continues at ### MAIN <-

# Begin public functions

help() {
    case "$1" in
        short)
    cat << EOB

Short commands:
---------------
ai: aichat <args>
g: gemini
m:  mysql <host> [db]

EOB
        ;;
        vim|nvim)
    printf '%b' "$(cat << EOB

VIM commands:
-------------
navigate
  ${GREEN}<ctr>o${RESET}: jump back to previous location
  ${GREEN}K${RESET}: display information
  ${GREEN}gd${RESET}: go to definition
multi
  ${GREEN}<ctrl>w s${RESET}/${GREEN}<ctrl>w v${RESET}: split
  ${GREEN}<ctrl>p${RESET}: fzf files
  ${YELLOW}:tabedit <filename>${RESET} or ${CYAN}vi -p file1 file2...${RESET} then ${GREEN}gt${RESET}/${GREEN}gT${RESET}
  ${YELLOW}:mksession <sessionname>${RESET} to save, ${YELLOW}:mks!${RESET} to update.
  ${YELLOW}:source <sessionname>${RESET} or ${CYAN}vi -S <sessionname>${RESET} to reopen.
display
  ${GREEN}mb${RESET} ... ${GREEN}zf'b${RESET} to ${UNDERLINE}fold section${RESET}, ${GREEN}zo${RESET} to open, ${GREEN}zc${RESET} to close
  ${YELLOW}:set [no]list${RESET}: display invisible characters
  ${YELLOW}:set diffopt+=iwhite${RESET}: ignore whitespace in diff
reformat
  ${GREEN}i={${RESET} to properly ${UNDERLINE}indent${RESET} current section
misc
  ${GREEN}<ctrl>n${RESET}: auto-complete
  ${CYAN}rvi${RESET}: remote vim edit
  ${YELLOW}:lcd${RESET}: change directory in vim
  ${GREEN}<ctr>v <shit>I${RESET}: start inserting block, until <esc>
  ${YELLOW}:g/^\s*$/d:${RESET} g to all 0+space blank lines and delete
  ${YELLOW}:put =eval(join(getline(1, '$'), '+'))${RESET}: insert eval of join all lines with '+' operator.
  ${YELLOW}:!open %${RESET}: execute open of current file
  ${YELLOW}:norm keys${RESET}: apply to current selection as if visual

EOB
)"
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
    export PATH=/opt/cinc-workstation/embedded/bin:\$PATH
    export GEM_HOME=/opt/cinc-workstation/embedded/lib/ruby/gems
    export GEM_PATH=/opt/cinc-workstation/embedded/lib/ruby/gems

EOB
        ;;
    mise)
    cat << EOB

MISE:
----
Examples:
    mise ls [--installed|--current]
    mise registry
    mise search <target>
    mise use jq@latest
    mise install jq@latest
    mise upgrade --bump
    mise upgrade node@20
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
    export GIT_SSH_COMMAND='ssh -o IdentitiesOnly=yes -i ~/.ssh/root_github_rsa'
    export GIT_SSH_COMMAND='ssh -o IdentitiesOnly=yes -i /root/github_rsa'
Use ad-hoc difftool (e.g. difftastic):
    export GIT_EXTERNAL_DIFF=difft
Amazing tools:
    https://github.com/jnsahaj/lumen
Help:
    https://ohshitgit.com
    git aliases

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
    fzf)
    cat << EOB

fzf:
--------
Examples:
    kill **<TAB>
    ssh **<TAB>
    ls <CTRL>t

EOB
        ;;
    tv)
    cat << EOB

television:
--------
Examples:
    tv # show files and content
    tv list-channels | tv
    tv update-channels
    cat <log file> | tv
    ps | tv
    <ctrl>t: switch channels

EOB
        ;;
    zoxide)
    cat << EOB

zoxide:
--------
Completion/dis-ambiguation:
    z path<SPACE><TAB>

EOB
        ;;
    zellij)
    cat << EOB

zellij:
--------
Quick run:
    cd ~/.config/zellij && make quick3 <group>
    zrf top
<ctrl>g: disable/re-enable zellij mappings
<ctrl>t+s: synchronize panes

EOB
        ;;
    aichat)
    cat << EOB

aichat:
--------
# alias
    a
# execute a command
    aichat -e list c files
# write code
    aichat -c echo server in node.js
# summarize a file or complete directory
    aichat -f dir/ summarize
    aichat -f myfile.md explain
# config
    aichat --info

EOB
        ;;
    fabric)
    cat << EOB

fabric:
--------
# list patterns
    ls $HOME/.config/fabric/patterns
# stdin examples
    pbpaste | fabric -p summarize
# youtube examples
    fabric -y <youtube url> -s -p summarize
    fabric -y <youtube url> -s -p analyze_claims
# website examples
    fabric -u <url> -p summarize

EOB
        ;;
    sops)
    cat << EOB

sops:
-----
Since sops is used to encrypt secrets,
check content of \$HOME/.dotfiles/hooks/pre-commit

EOB
        ;;
    fish)
    cat << EOB

fish:
--------
Set a variable:
    set -gx variable value # g:global x:export
    set -e variable # deletes
    set variable value1 value2 # array
    echo \$variable[2..3]
Manipulations:
    string replace bar baz barbarian
    echo bababa | string match -r 'aba\$'
Math:
    math --base=hex bitxor 0x0F, 0xFF
    math -s0 10.0 / 6.0
No heredocs!
Use 'test' to check for file existence, etc
Use '\$status' for \$?

EOB
        ;;
    tools)
    cat << EOB

aliases:
--------
EOB
alias | grep '^x\-'
        ;;
    *)
    cat << EOB

CFR various help items:
-----------------------
forgit: interactive git -- \`ga\` etc. (for more: \`aliases\`)
dotfiles: manage dotfiles git repo
smug: manage tmux layouts
icd: interactive cd using xplr
refresh_*: re-sync environment
install_*: install important bits
fetch_command <gitorg/gitpkg> <binaryname>: retrieve commands from git

help short: short commands help
help vim: vim help
help dap: nvim debugger help
help mise: mise-en-place help
help chef: various chef configuration info
help kitty: kitty commands and shortcuts
help git: git tips and tricks
help rg: ripgrep help
help sops: sops encrypt help
help fzf: fzf help
help tv: television help
help zoxide: zoxide help
help zellij: zellij layouts
help aichat: aichat help
help fabric: fabric-ai help
help fish: fish help
help tools: x-aliases, etc

EOB
        ;;
        esac
}

refresh_commands() {
    # do not include nushell: too old
    cat <<-EOB > ~/.env.nix
with import <nixpkgs> {}; [
    ncdu # interactive du
    nq # nohup improved
    rlwrap # wrap commands in readline
    git
    tig # yeah gitui and tig suit a different need
    smug # tmuxinator-like
    pdsh # multi ssh
    broot # tree explorer
    tealdeer # short examples
    navi # complete syntax
    pv # pipe progress
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
    [[ -v I_HAVE_USER_BREW || -v I_HAVE_SYS_BREW ]] && {
        for pkg in $(awk 'NR>1 {print $1}' ~/.env.nix | grep -v ']'); do
            brew install $pkg
        done
    }

    [[ $(command -v mise) ]] || {
        curl https://mise.run | sh
        eval "$(mise activate zsh)"
        mise use -g usage
        mkdir -p $HOME/.local/zsh/completions
        mise completion zsh > $HOME/.local/zsh/completions/_mise
        eval "$(mise activate zsh)"
    }

    mise use \
        direnv \
        fzf \
        television \
        hyperfine \
        neovim \
        usage \
        zoxide
}

refresh_atuin() {
    mkdir -p ~/.config/atuin
    cat <<-EOB > ~/.config/atuin/config.toml
search_mode = "daemon-fuzzy"
style = "full"
keymap_mode = "emacs"

[ai]
enabled = true

[daemon]
enabled = true
autostart = true
EOB
}

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
    --[[
    -- load packages for lsp, dap, etc
    { "williamboman/mason.nvim" },
    ]]
    -- status line
    { "itchyny/lightline.vim" },
    -- file icons
    { "nvim-tree/nvim-web-devicons" },
    -- theme
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("cyberdream").setup({
                -- Recommended - see "Configuring" below for more config options
                transparent = true,
                italic_comments = true,
                hide_fillchars = true,
                borderless_telescope = true,
                terminal_colors = true,
            })
            vim.cmd("colorscheme cyberdream") -- set the colorscheme
        end,
    },
    -- align (:EasyAlign)
    { "junegunn/vim-easy-align" },
    --[[
    -- full-on IDE environment
    {
        "ldelossa/nvim-ide",
    },
    ]]
    -- set root directory to file being edited
    {
        "airblade/vim-rooter",
        config = function()
            vim.g.rooter_patterns = { '.git' }
        end,
    },
    -- pop-up notifier
    { "rcarriga/nvim-notify" },
    --[[
    -- preview window for lsp
    { "dnlhc/glance.nvim" },
    -- language server protocol definitions
    { "neovim/nvim-lspconfig" },
    -- load above definitions
    { "williamboman/mason-lspconfig.nvim" },
    -- completions engine
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
    -- lsp provider for completions engine
    { "hrsh7th/cmp-nvim-lsp" },
    -- sane defaults for lsp; may be deprecated
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
    ]]
    -- gui components for lua
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
    -- treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },
    --[[
    -- lsp + treesitter UI
    {
        "ray-x/navigator.lua",
        config = function()
            require 'navigator'.setup({
                mason = true
            })
        end,
    },
    -- invoke fzf from lua
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
    -- databases editor
    { "tpope/vim-dadbod" },
    {
        "kristijanhusak/vim-dadbod-ui",
        config = function()
            vim.g.db_ui_save_location = '~/Cells/db_ui'
        end,
    },
    ]]
    -- display current code context using lsp
    { "SmiteshP/nvim-navic" },
    -- deprecated ui using navic
    {
        "utilyre/barbecue.nvim",
        config = function()
            require('barbecue').setup()
        end,
    },
    -- nice startup screen
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
    -- git diff and merge
    { "sindrets/diffview.nvim" },
    -- memory enhancer
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

refresh_gitconfig() {
    cat <<-EOB > ~/.gitconfig
[user]
    name = Chris F Ravenscroft
    email = chris@voilaweb.com
[init]
    defaultBranch = main
[core]
    compression = 0
    fsmonitor = true
    longpaths = true
    whitespace = -trailing-space,-space-before-tab
    untrackedCache = true
[diff]
    algorithm = histogram
    colorMoved = dimmed-zebra
[difftool]
    prompt = false
[merge]
    tool = meld
    conflictstyle = diff3
[mergetool]
    keepBackup = false
[color]
    ui = true
[column]
    ui = auto
[fetch]
    prune = true
    prunetags = true
[pull]
    rebase = interactive
[push]
    autoSetupRemote = true
[includeIf "gitdir:~/.local/git/"]
    path = ~/.local/git/gitconfig
[rerere]
    enabled = true
[credential]
    helper = cache --timeout=604800
[rerere]
    enabled = true
[rebase]
    autoSquash = true
    autoStash = true
    updateRefs = true
[log]
    abbrevCommit = true
[alias]
    aliases = config --get-regexp ^alias
    undo = reset --soft HEAD~1
    nuke = reset --hard HEAD~1
    stash-all = stash push --include-untracked
    amend = commit --amend --no-edit
    unstage = restore --staged
    lg = log --oneline --graph --decorate --all --abbrev-commit
    fixup = "!f() { TARGET=\$(git rev-parse \$1); git commit --fixup=\$TARGET \${@:2} && GIT_SEQUENCE_EDITOR=true git rebase -i --autostash --autosquash \$TARGET^; }; f"
[credential]
    helper = cache --timeout=86400
[feature]
    manyFiles = true
EOB
}

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

# interactive cd
icd() {
    cd -- "$(xplr)"
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
    refresh_atuin
    refresh_vim
    refresh_smug
}

install_et() {
    sudo apt-get install -y software-properties-common && \
    sudo add-apt-repository ppa:jgmath2000/et && \
    sudo apt-get update && sudo apt-get install -y et
}

# update terminal tab: values from https://www.canva.com/colors/color-meanings/
export PRELINE="\r\033[A"
color() {
    case $1 in
    green)
    echo -e "\033]6;1;bg;red;brightness;127\a"$PRELINE
    echo -e "\033]6;1;bg;green;brightness;255\a"$PRELINE
    echo -e "\033]6;1;bg;blue;brightness;212\a"$PRELINE
    ;;
    red)
    echo -e "\033]6;1;bg;red;brightness;255\a"$PRELINE
    echo -e "\033]6;1;bg;green;brightness;83\a"$PRELINE
    echo -e "\033]6;1;bg;blue;brightness;73\a"$PRELINE
    ;;
    blue)
    echo -e "\033]6;1;bg;red;brightness;13\a"$PRELINE
    echo -e "\033]6;1;bg;green;brightness;152\a"$PRELINE
    echo -e "\033]6;1;bg;blue;brightness;186\a"$PRELINE
    ;;
    khaki)
    echo -e "\033]6;1;bg;red;brightness;240\a"$PRELINE
    echo -e "\033]6;1;bg;green;brightness;230\a"$PRELINE
    echo -e "\033]6;1;bg;blue;brightness;140\a"$PRELINE
    ;;
    gray)
    echo -e "\033]6;1;bg;red;brightness;128\a"$PRELINE
    echo -e "\033]6;1;bg;green;brightness;128\a"$PRELINE
    echo -e "\033]6;1;bg;blue;brightness;128\a"$PRELINE
    ;;
    white)
    echo -e "\033]6;1;bg;red;brightness;255\a"$PRELINE
    echo -e "\033]6;1;bg;green;brightness;255\a"$PRELINE
    echo -e "\033]6;1;bg;blue;brightness;240\a"$PRELINE
    ;;
    *)
    echo "Colors: green, red, blue, khaki, gray, white"
    esac
}
function title {
    echo -ne "\033]0;"$*"\007"
}

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

ssh() {
    if ! command -v scutil >/dev/null 2>&1; then
        command ssh "$@"
        return
    fi
    local dn=$(scutil --dns | awk -F' : ' '/search domain/ && $2 ~ /\./ && $2 !~ /network$/ && $2 !~ /search$/ {print $2; exit}')
    local args=("$@")
    local last_index=$#
    local target="${args[$last_index]}"
    if [[ -n "$target" && "$target" != -* && "$target" != *@*.* && "$target" != *.* ]]; then
        if [[ "$target" == *@* ]]; then
            args[$last_index]="${target%%@*}@${target#*@}.$dn"
        else
            args[$last_index]="${target}.$dn"
        fi
    fi
    command ssh "${args[@]}"
}
et() {
    if ! command -v scutil >/dev/null 2>&1; then
        command et "$@"
        return
    fi
    local dn=$(scutil --dns | awk -F' : ' '/search domain/ && $2 ~ /\./ && $2 !~ /network$/ && $2 !~ /search$/ {print $2; exit}')
    local args=("$@")
    local last_index=$#
    local target="${args[$last_index]}"
    if [[ -n "$target" && "$target" != -* && "$target" != *@*.* && "$target" != *.* ]]; then
        if [[ "$target" == *@* ]]; then
            args[$last_index]="${target%%@*}@${target#*@}.$dn"
        else
            args[$last_index]="${target}.$dn"
        fi
    fi
    command et "${args[@]}"
}

# Begin private functions

_we_like_dialogs() {
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
}

_constants() {
    # We like ansi effects
    RED="\033[0;31m"
    GREEN="\033[0;32m"
    YELLOW="\033[1;33m"
    BLUE="\033[0;34m"
    MAGENTA="\033[0;35m"
    CYAN="\033[0;36m"
    RESET="\033[0m"
    BOLD="\033[1m"
    UNDERLINE="\033[4m"
}

_settings() {
    I_WANT_COMMANDS=true
    I_WANT_PROMPT=true
    I_WANT_PLUGINS=true
    I_WANT_UPDATES=true
 
    # Do we have a setup file overriding some settings?
    [[ -f ~/.env.cfr-setup ]] || {
        st=$(dialog --clear \
            --backtitle "First setup" \
            --title "Missing CFR environment" \
            --menu "Please select a setup option." 14 30 4  0 "No commands." 1 "NIX (sudo)" 2 "Brew (system)" 3 "LinuxBrew (user)" 2>&1 >/dev/tty)
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
            I_WANT_SYS_BREW=true
        ;;
        3)
            I_WANT_USER_BREW=true
        ;;
        esac
        echo
    }


    . ~/.env.cfr-setup
}

_setup_packager() {
    [[ -v I_WANT_NIX ]] && {
        [[ -d /nix ]] || {
            sudo rm -rf ~/.nix* ~/.env.nix
            sh <(curl -L https://nixos.org/nix/install)
        }
        echo I_HAVE_NIX=true >> ~/.env.cfr-setup
        . ~/.env.cfr-setup
    }

    [[ -v I_WANT_USER_BREW ]] && {
        [[ -d $HOME/.linuxbrew ]] || {
            mkdir $HOME/.linuxbrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C $HOME/.linuxbrew
            $HOME/.linuxbrew/bin/brew update
        }
        echo I_HAVE_USER_BREW=true >> ~/.env.cfr-setup
        . ~/.env.cfr-setup
    }

    [[ -v I_WANT_SYS_BREW ]] && {
        [[ -d /opt/homebrew ]] || {
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        }
        echo I_HAVE_SYS_BREW=true >> ~/.env.cfr-setup
        . ~/.env.cfr-setup
    }

    [[ -v I_HAVE_USER_BREW ]] && export PATH=$HOME/.linuxbrew/sbin:$HOME/.linuxbrew/bin:$PATH
    [[ -v I_HAVE_SYS_BREW ]] && eval "$(/opt/homebrew/bin/brew shellenv zsh)"

    $I_HAVE_NIX || $I_HAVE_USER_BREW || $I_HAVE_SYS_BREW || I_WANT_COMMANDS=false
}

_setup_platform() {
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

    # Build nix package list
    nix_platform=""
    [[ "$OS" != "OSX" ]] && {
        read -r -d '' nix_platform <<'EOB'
dstat # better vmstat
EOB
    }
    nix_shell=""
    # See comments below about slowness of plugins
    #[[ "$SHELL" =~ zsh ]] && {
    #    read -r -d '' nix_shell <<'EOB'
    #    zplug # zsh plugins
#EOB
    #}

    $I_WANT_COMMANDS && {
        [[ -f ~/.env.nix ]] || refresh_commands
    }
}

_setup_zsh() {
    # ZSH plugins
    # Alas, this really slows down launching a new session.
    # Specifically, the .zplug/init.zsh section below does.

    #$I_WANT_PLUGINS && {
    #    [[ "$SHELL" =~ zsh ]] && {
    #        [[ -f ~/.zplug/init.zsh ]] || {
    #            curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    #        }
    #    }
    #}
    #
    #[[ -f ~/.zplug/init.zsh ]] && {
    #    source ~/.zplug/init.zsh
    #
    #    zplug 'wfxr/forgit'
    #    zplug "zsh-users/zsh-syntax-highlighting", defer:2
    #
    #    $(zplug check) || {
    #        printf "Install zplug? [y/N]: "
    #        if read -q; then
    #            echo; zplug install
    #        fi
    #    }
    #    zplug load > /dev/null
    #}

    [[ "$SHELL" =~ zsh ]] && { autoload -Uz compinit && compinit; }

    # Auto-source .source-me
    _my_chpwd_running=false
    autoload -U add-zsh-hook
    load-local-conf() {
        if $_my_chpwd_running; then return 0; fi; _my_chpwd_running=true;
        if [[ -f .source-me ]]; then echo "ex'ing .source-me"; source .source-me; fi; _my_chpwd_running=false;
    }
    add-zsh-hook chpwd load-local-conf
 
    # Allow comments
    setopt interactive_comments

    # Preserve history
    setopt SHARE_HISTORY HIST_IGNORE_DUPS
    HISTSIZE=1000
    SAVEHIST=1000
    HISTFILE=~/.zsh_history
    preexec_custom_history() {
        echo "$HOSTNAME $$ $(date "+%Y-%m-%dT%H:%M:%S%z") $1" >> "$HOME/.fullhistory"
    }
    preexec_functions+=(preexec_custom_history)

    fpath=($HOME/.local/zsh/completions $fpath)
}

_setup_prompt() {
    $I_WANT_PROMPT && {
        [[ -f $HOME/.local/bin/oh-my-posh ]] || refresh_prompt
    }

    [[ -d ~/.poshthemes ]] && {
        function zle-line-init() { }
        [[ -f ~/.poshthemes/cfr.omp.json ]] || curl -so ~/.poshthemes/cfr.omp.json https://gist.githubusercontent.com/Fusion/97b8731cef5dd52bbe44ebd45505f2a5/raw/3a609404d8608e6c944376e91f88780025cc3f34/cfr.omp.json
        eval "$($HOME/.local/bin/oh-my-posh init zsh --config ~/.poshthemes/cfr.omp.json)"
    }
}

_setup_hooks() {
    # direnv sources a directory .envrc file
    [[ $(command -v direnv) ]] && {
        eval "$(direnv hook zsh)"
    }

    # quick jump
    [[ $(command -v fasd) ]] && {
        eval "$(fasd --init auto)"
    }

	# Short commands

	[[ $(command -v aichat) ]] && {
	    ai() {
		 [[ "$(head -1 $HOME/.config/aichat/config.yaml | grep AES256)" == "" ]] || { sops -d -i $HOME/.config/aichat/config.yaml }
		aichat $@
	    }
	}

	m() {
	    mysql -h$1 -uroot -p$(cat ~/.secrets/dbpwd) $2 -A
	}

	ntfy() {
	    local msg="$*"
	    curl -s \
		--form-string "token=$PUSHOVER_TOKEN" \
		--form-string "user=$PUSHOVER_USER" \
		--form-string "priority=1" \
		--form-string "message=$msg" \
		https://api.pushover.net/1/messages.json
	}

	[[ -e $HOME/.config/fabric/patterns ]] && {
	    yt() {
		if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
		    echo "Usage: yt [-t | --timestamps] youtube-link"
		    echo "Use the '-t' flag to get the transcript with timestamps."
		    return 1
		fi

		transcript_flag="--transcript"
		if [ "$1" = "-t" ] || [ "$1" = "--timestamps" ]; then
		    transcript_flag="--transcript-with-timestamps"
		    shift
		fi
		local video_link="$1"
		fabric -y "$video_link" $transcript_flag
	    }
	}

	# aerospace
	ff() {
	    aerospace list-windows --all | fzf --bind 'enter:execute(bash -c "aerospace focus --window-id {1}")+abort'
	}

	# Tools
	alias g=gemini
	alias x-marimo='uvx marimo'
	alias x-mcp-inspector='npx @mcpjam/inspector@latest'
}

_setup_vimenv() {
    [[ -f ~/.local/share/nvim/site/autoload/plug.vim  ]] || {
        sh -c 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    }
    [[ -f ~/.config/nvim/init.lua ]] || refresh_vim

    ### END WILDLANDS

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

    [[ $(command -v nvim) ]] && {
        export EDITOR="nvim"
        [[ -f $HOME/.linuxbrew/bin/nvim ]] && {
            alias vi=~/.linuxbrew/bin/nvim
            alias vim=~/.linuxbrew/bin/nvim
        } || {
            [[ -f $HOME/.nix-profile/bin/nvim ]] && {
                alias vi=~/.nix-profile/bin/nvim
                alias vim=~/.nix-profile/bin/nvim
            } || {
                alias vi=nvim
                alias vim=nvim
            }
        }
        alias vimdiff="nvim -d"
    }

    if [[ -f $HOME/.atuin/bin/atuin ]]; then
        . "$HOME/.atuin/bin/env"
        eval "$($HOME/.atuin/bin/atuin init zsh --disable-up-arrow)"
    else
        p=$(which tv)
        if [[ $? -eq 0 ]]; then
            eval "$(tv init zsh)"
        else
            p=$(which fzf)
            if [[ $? -eq 0 ]]; then
                [[ -v I_HAVE_NIX ]] && {
                    sp="$(find /nix/store -maxdepth 1 -type d -name '*-fzf-*' -not -name '*man')"
                    if [[ "$sp" != "" ]]; then
                        while true; do q=$(readlink $p); [[ "" == "$q" ]] && break; p=$q; done; source $sp/bin/../share/fzf/key-bindings.zsh && source $sp/bin/../share/fzf/completion.zsh
                    fi
                }
                [[ -v I_HAVE_USER_BREW ]] && {
                    source $HOME/.linuxbrew/var/homebrew/linked/fzf/shell/key-bindings.zsh
                    source $HOME/.linuxbrew/var/homebrew/linked/fzf/shell/completion.zsh
                }
                [[ -v I_HAVE_SYS_BREW ]] && {
                    source /opt/homebrew/var/homebrew/linked/fzf/shell/key-bindings.zsh
                    source /opt/homebrew/var/homebrew/linked/fzf/shell/completion.zsh
                }
            fi
        fi
    fi
}

_setup_improved_commands() {
    # ls
    [[ $(command -v lsd) ]] && {
        alias ls=lsd
    }

    # asdf versions manager for many packages and languages
    [ -d $HOME/.asdf ] && {
        . $HOME/.asdf/asdf.sh
        fpath=(${ASDF_DIR}/completions $fpath)
    }

    [[ $(command -v mise) ]] && {
        eval "$(mise activate zsh)"
    }

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

    export VISUAL="vim"
    export PAGER="bat"
    [[ $(command -v ncdu) ]] && {
        alias du="ncdu --color dark -rr -x --exclude .git --exclude node_modules"
    }
    [[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm ssh"
    [[ "$TERM" == "rio" ]] && alias ssh="TERM=xterm-256color ssh"
    [[ -d ~/.krew ]] && export PATH="${PATH}:${HOME}/.krew/bin"

    # zoxide
    [[ $(command -v zoxide) ]] && {
        eval "$(zoxide init zsh)"
    }

    # zellij
    function zrf () { zellij run --name "$*" --floating -- zsh -ic "$*";}

    command -v thefuck &>/dev/null && {
        eval $(thefuck --alias)
    }
}

_setup_devenv() {
    #git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
    #git config --global interactive.diffFilter "diff-so-fancy --patch"
    git config --global color.ui true
    git config --global merge.conflictstyle diff3

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


    if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

    # bun completions
    # Not really using bun rn: [ -s "/Users/chris/.bun/_bun" ] && source "/Users/chris/.bun/_bun"
    # export BUN_INSTALL="$HOME/.bun"
    # export PATH="$BUN_INSTALL/bin:$PATH"

    [[ -e $HOME/.local/zshrc ]] && . $HOME/.local/zshrc
    [[ -e $HOME/.secrets.env ]] && {
        [[ "$(head -1 $HOME/.secrets.env | grep AES256)" == "" ]] || { sops -d -i $HOME/.secrets.env }
        . $HOME/.secrets.env
    }
    [[ -f "$HOME/.cargo/env" ]] && { . "$HOME/.cargo/env" }
}

_setup_os_specific() {
    # On Ubuntu, refresh apt db if older than a month
    $I_WANT_UPDATES && {
        [[ -f /var/lib/apt/periodic/update-success-stamp ]] && {
            freshness=$(( $(date +%s) - $(stat -c%Y /var/lib/apt/periodic/update-success-stamp) ))
            [ $freshness -gt 2592000 ] && {
                sudo apt-get update
            }
        }
    }
}

### MAIN

_we_like_dialogs
_constants
_settings
_setup_packager
_setup_platform
_setup_zsh
_setup_prompt
_setup_hooks
_setup_improved_commands
_setup_vimenv
_setup_devenv
_setup_os_specific
