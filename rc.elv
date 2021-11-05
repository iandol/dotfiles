# elvish shell config — https://elv.sh/learn/tour.html
# see a sample here: https://gitlab.com/zzamboni/dot-elvish/-/blob/master/rc.org

# https://elv.sh/ref/
use re
use str
use path
use math
use epm
use platform

epm:install &silent-if-installed ^
  github.com/muesli/elvish-libs ^
  github.com/zzamboni/elvish-modules ^
  github.com/zzamboni/elvish-themes ^
  github.com/zzamboni/elvish-completions

#use github.com/muesli/elvish-libs/theme/powerline
use github.com/zzamboni/elvish-modules/proxy
use github.com/zzamboni/elvish-modules/alias
use github.com/zzamboni/elvish-completions/git
use github.com/zzamboni/elvish-completions/cd
use github.com/zzamboni/elvish-completions/ssh

# general ENV
if ( has-env PLATFORM ) {
  echo (styled "Elvish V"$version" running on "$E:PLATFORM bold bg-red)
} else {
  set-env PLATFORM (uname -s)
  echo (styled "Elvish V"$version" running on "$E:PLATFORM bold bg-red)
}

# aliases
set alias:dir = ~/.config/elvish/aliases
if ( eq $platform:os "darwin" ) {
  alias:new lm e:ls -alFGh@
  alias:new ll e:ls -alFGh
  alias:new ls e:ls -GF
  edit:add-var manpdf~ [@cmds]{
    each [c]{ man -t $c | open -f -a /System/Applications/Preview.app } $cmds
  }
} elif ( eq $platform:os "linux" ) {
  alias:new ls e:ls --color -GhFLH
  alias:new ll e:ls --color -alFGh
}
alias:new gst e:git status
alias:new gca e:git commit --all
set dl~ = [@a]{ e:curl -C - -O $@a }

# setup brew
if ( and (eq $E:PLATFORM 'Linux') (path:is-dir &follow-symlink /home/linuxbrew/.linuxbrew/bin/) ) {
  echo (styled "Linux brew" bold bg-green)
  paths = [
    /home/linuxbrew/.linuxbrew/bin/
    /home/linuxbrew/.linuxbrew/sbin/
    $@paths
  ]
} elif ( and (eq $E:PLATFORM 'Darwin') (path:is-dir &follow-symlink /home/) ) {
  echo (styled "Configuring Darwin brew..." bold bg-blue)
  set-env HOMEBREW_PREFIX '/usr/local'
  set-env HOMEBREW_CELLAR '/usr/local/Cellar'
}
# paths
paths = [
  ~/bin
  /usr/local/bin
  /usr/local/sbin
  $@paths
  /usr/sbin
  /sbin
  /usr/bin
  /bin
]

each [p]{
  if (not (path:is-dir &follow-symlink $p)) {
    echo (styled "Warning: directory "$p" in $paths no longer exists." bg-red)
	}
} $paths

# chain theme
use github.com/zzamboni/elvish-themes/chain
chain:init
chain:bold-prompt = $true
chain:show-last-chain = $false
chain:glyph[arrow] = "❯"
chain:prompt-segment-delimiters = [ "⟨" "⟩" ]

