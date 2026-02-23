if status is-interactive
    # Commands to run in interactive sessions can go here
    # /Users/ray/.local/bin/mise activate fish | source
    $HOME/.local/bin/mise activate fish | source # added by https://mise.run/fish
end

if test -f /home/linuxbrew/.linuxbrew/etc/fish/completions/brew.fish
    source /home/linuxbrew/.linuxbrew/etc/fish/completions/brew.fish
    elif test -f $HOME/.linuxbrew/etc/fish/completions/brew.fish
    source $HOME/.linuxbrew/etc/fish/completions/brew.fish
end

set -gx PATH /home/linuxbrew/.linuxbrew/bin $PATH
set -gx PATH /home/linuxbrew/.linuxbrew/sbin $PATH

alias z="zellij"
alias p="pnpm"
alias n="nvim"
alias lg="lazygit"
