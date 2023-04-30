# Bootstrapping a new environment

A bit complex, because `.zshrc` itself contains the necessary aliases.

Suggested:

```bash
dotfilesclone () {
    mkdir -p ~/.dotfiles \
    && dotfiles init \
    && dotfiles config --local status.showUntrackedFiles no \
    && dotfiles remote add origin git@github.com:Fusion/bootstrap-my-shell.git \
    && rm ~/.zshrc \
    && dotfiles pull origin main \
    && dotfiles branch -m main \
    && echo "To view tracked files: 'dotfiles ls-files'"
}
dotfilesclone
```

