# Bootstrapping a new environment

A bit complex, because `.zshrc` itself contains the necessary aliases.

Suggested:

```bash
alias dotfiles="git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
dotfilesclone () {
    mkdir -p ~/.dotfiles \
    && dotfiles init \
    && dotfiles config --local status.showUntrackedFiles no \
    && dotfiles remote add origin git@github.com:Fusion/bootstrap-my-shell.git \
    && rm -f ~/.zshrc \
    && dotfiles pull origin main \
    && dotfiles branch -m main \
    && echo "To view tracked files: 'dotfiles ls-files'"
}
dotfilesclone
```

# Cleanup

```bash
sudo rm -rf /nix .env.cfr-setup .env.nix $HOME/.nix-profile
```
