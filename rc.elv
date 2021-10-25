# elvish shell config — https://elv.sh/learn/tour.html
# see a sample here: https://gitlab.com/zzamboni/dot-elvish/-/blob/master/rc.org

# https://elv.sh/ref/
use re
use str
use path
use math
use epm

# aliases
fn ls [@a]{ e:ls -alGhFeLH $@a }
fn ll [@a]{ e:ls -alFGh $@a }
fn gst [@a]{ e:git status $@a }
fn gca [@a]{ e:git commit --all $@a }
fn dl [@a]{ e:curl -C - -O }

# paths
paths = [
  ~/bin
  /usr/local/bin
  /usr/local/sbin
  /usr/sbin
  /sbin
  /usr/bin
  /bin
]

each [p]{
  if (not (path:is-dir &follow-symlink $p)) {
    echo (styled "Warning: directory "$p" in $paths no longer exists." red)
  }
} $paths


epm:install &silent-if-installed ^
  github.com/muesli/elvish-libs ^
  github.com/zzamboni/elvish-modules

use github.com/zzamboni/elvish-modules/proxy
use github.com/muesli/elvish-libs/theme/powerline

fn manpdf [@cmds]{
  each [c]{
    man -t $c | open -f -a /System/Applications/Preview.app
  } $cmds
}

