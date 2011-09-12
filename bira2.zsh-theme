# ZSH Theme - Preview: http://gyazo.com/8becc8a7ed5ab54a0262a470555c3eed.png
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}⚡%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'
local rvm_ruby='%{$fg[red]%}‹$(rvm-prompt i v g)›%{$reset_color%}'
local git_branch='$(git_prompt_info)%{$reset_color%}'
local vcsinfo='${vcs_info_msg_0_}'

PROMPT="╭─${user_host} ${current_dir} ${rvm_ruby} ${vcsinfo} $(bzr_prompt_info) ${git_branch}
╰─%B$%b "
RPS1="${return_code}"

## Git integration
#Customized git status, oh-my-zsh currently does not allow render dirty status before branch
git_custom_status() {
	local cb=$(current_branch)
	if [ -n "$cb" ]; then
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}

## Bazaar integration
parse_bzr_branch() {
	BZR_CB=`bzr nick 2> /dev/null | grep -v "ERROR" | cut -d ":" -f2 | awk -F / '{print "bzr::"$1}'`
	if [ -n "$BZR_CB" ]; then
		BZR_DIRTY=""
		[[ -n `bzr status` ]] && BZR_DIRTY="%{$fg[red]%}⚡%{$reset_color%}"
		echo "$ZSH_THEME_GIT_PROMPT_PREFIX$BZR_CB$BZR_DIRTY$ZSH_THEME_GIT_PROMPT_SUFFIX"
	fi
}
