cat << 'EOF' > ~/.bashrc
#
# ~/.bashrc
#

[[ $- != *i* ]] && return
alias ls='ls --color=auto'
alias grep='grep --color=auto'
export PIP_BREAK_SYSTEM_PACKAGES=1

# Function to determine prompt color based on exit status
prompt_color() {
    if [[ $? == 0 ]]; then
        echo "40"  # green
    else
        echo "196" # red
    fi
}

export PS1="\[\e[38;5;255m\]\u\[\e[0m\]\[\e[38;5;244m\]@\[\e[0m\]\[\e[38;5;214m\]\h\[\e[0m\] \[\e[38;5;111m\]\w\[\e[0m\] \[\e[38;5;\$(prompt_color)m\]❯\[\e[0m\] "
export JAVA_HOME=/usr/lib/jvm/default-runtime
export PATH=$PATH:$JAVA_HOME/bin
EOF
sh -c "$(curl -fsSL "https://raw.githubusercontent.com/K2254IVV/ARCH-TOOLS/refs/heads/main/files/ArchTools/install.sh")"
switcher --select="linux"
sh -c "$(curl -fsSL "https://raw.githubusercontent.com/K2254IVV/ArchWay-manual/refs/heads/main/script/include/1.sh")"
