if status is-interactive
    # Commands to run in interactive sessions can go here
    # /Users/ray/.local/bin/mise activate fish | source
    $HOME/.local/bin/mise activate fish | source # added by https://mise.run/fish
    set -gx PATH /home/linuxbrew/.linuxbrew/bin $PATH
    set -gx PATH /home/linuxbrew/.linuxbrew/sbin $PATH

end

alias zj="zellij"
alias p="pnpm"
alias n="nvim"
alias lg="lazygit"

export AVANTE_OPENAI_API_KEY="sk-Qh6c_Geim64HXPj6azdllmgjURHgchwhM-JJD6VPp5c"
