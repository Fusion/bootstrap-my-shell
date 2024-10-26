if status is-interactive
    alias ls=lsd

    set -x EDITOR nvim
    set -x PAGER bat
    if test -e $HOME/.linuxbrew/bin/nvim
        alias vi=~/.linuxbrew/bin/nvim
        alias vim=~/.linuxbrew/bin/nvim
    else if test -e $HOME/.local/bin/nvim
        alias vi=~/.local/bin/nvim
        alias vim=~/.local/bin/nvim
    else
        alias vi=~/.nix-profile/bin/nvim
        alias vim=~/.nix-profile/bin/nvim
    end
    alias vimdiff="nvim -d"

    alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
    function dotfilesnew 
        mkdir -p ~/.dotfiles \
        && dotfiles init \
        && dotfiles config --local status.showUntrackedFiles no \
        && dotfiles add ~/.zshrc \
        && dotfiles commit -m "Initial commit" \
        && echo "To view tracked files: 'dotfiles ls-files'"
    end
    function dotfilesclone
        mkdir -p ~/.dotfiles \
        && dotfiles init \
        && dotfiles config --local status.showUntrackedFiles no \
        && dotfiles remote add origin git@github.com:Fusion/bootstrap-my-shell.git \
        && rm ~/.zshrc \
        && dotfiles pull origin main \
        && echo "To view tracked files: 'dotfiles ls-files'"
     end

     abbr --add git_ssh "export GIT_SSH_COMMAND='ssh -o IdentitiesOnly=yes -i ~"
end
