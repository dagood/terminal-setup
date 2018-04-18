# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
source ~/git-prompt.sh

function do_prompt {
	export PS1="\[\e[0;32m\]## \u\[\e[m\] \[\e[1;34m\]\w\[\e[m\]\[\e[0;32m\]$(set +x; __git_ps1)\n#> \[\e[m\]"
	export PS2="\[\e[0;32m\]#>\[\e[0m\] "
}
PROMPT_COMMAND='do_prompt'

PATH=$PATH:$HOME/.local/bin:$HOME/bin

function add-agent {
	eval $(ssh-agent)
	ssh-add
}

export EDITOR=vim
export PATH

