#!/usr/bin/env zsh

# this script demonstrates running processes in parallel and waiting for them

timea=(10 11 12)
i=1
printf "\nWill start %i parallel loops\n" ${#timea}
for x in $timea; do
	sleep ${x} &
	pid=$!;PIDS[$i]=${pid} # doesn't work if we assign to array directly!
	printf "Loop: %i PID = %i\n" $i ${PIDS[$i]:-"Unknown"}
	#i=`expr $i + 1`
	((i++)) #https://linuxize.com/post/bash-increment-decrement-variable/
done
echo "Waiting for ${PIDS[*]}"
wait ${PIDS[*]}
unset I PIDS x timea
echo "Finished"
ps