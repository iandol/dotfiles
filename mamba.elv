# MAMBA Environment Utilites for Elvish
#
# Copyright © 2023
#   Ian Max Andolina
#
# Activation & deactivation methods for working with Mamaba virtual
# environments in Elvish.  Will not allow invalid Virtual
# Environments to be activated.

use str
use re
use path
use cmds # my utility module

var root = $E:HOME/micromamba # we can update this later
var envs = $root/envs
nop ?(var venvs = [(e:ls $envs)])

fn get-envs {
	set envs = $root/envs
}

fn get-venvs {
	get-envs
	set venvs = [(e:ls $envs)]
}

fn process-script {|@in|
	get-venvs
	each {|line|
		set @line = (str:split " " $line)
		if (eq $line[0] "export") {
			var @parts = (str:split "=" $line[1])
			if (cmds:not-match $parts[0] "^PATH") {
				var p1 = (str:trim $parts[0] "'\"" )
				var p2 = (str:trim $parts[1] "'\"")
				try { set-env $p1 $p2 } catch { echo "Cannot set-env" }
			}
		} elif (eq $line[0] ".") {
			var p = (str:trim $line[1] '"')
			if (cmds:is-file $p) {
				try {
					var @newin = (e:cat $p | from-lines)
					#echo 'process-script: ' $newin
				} catch {
					echo "Cannot source "$p
				}
			} else {
				echo "File not found: "$p
			}
		}
	} $@in
}

fn list-envs {
	get-venvs
	echo "Mamba ENVS in "$envs": "
	put $@venvs
}

fn activate {|name|
	get-venvs
	if (cmds:is-member $venvs $name) {
		set-env CONDA_PREFIX $envs/$name
		cmds:prepend-to-path $root/condabin
		cmds:prepend-to-path $E:CONDA_PREFIX/bin
		var in = []
		try { set in = [(micromamba shell activate -s zsh $name)] } catch { }
		if (cmds:not-empty $in) { process-script $in }
		set-env '_OLD_PATH' $E:PATH
		if (cmds:not-empty $E:PYTHONHOME) {
			set-env _OLD_PYTHONHOME $E:PYTHONHOME
			unset-env PYTHONHOME
		}
		echo (styled "Mamba Environment <<"$name">> Activated!" bold italic magenta)
	} else { echo "Environment "$name" not found." }
}
set edit:completion:arg-completer[mamba:activate] = {|@args|
	get-envs
	e:ls $envs
}

fn deactivate {
	get-venvs
	var in = []
	try { var in = [(micromamba shell deactivate -s zsh)] } catch { }
	if (cmds:not-empty $in) { process-script $in }
	each {|in| unset-env $in } [_THIS_ENV VIRTUAL_ENV MAMBA_ENV CONDA_DEFAULT_ENV CONDA_PREFIX CONDA_PROMPT_MODIFIER CONDA_SHLVL]
	cmds:remove-from-path 'micromamba/'
	if (cmds:not-empty $E:_OLD_PYTHONHOME) {
		set-env PYTHONHOME $E:_OLD_PYTHONHOME
		unset-env _OLD_PYTHONHOME
	}
	echo (styled "Mamba Deactivated!" bold italic magenta)
}
