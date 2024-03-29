complete -c pueue -n "__fish_use_subcommand" -s c -l config -d 'Path to a specific pueue config file to use. This ignores all other config files' -r -F
complete -c pueue -n "__fish_use_subcommand" -s p -l profile -d 'The name of the profile that should be loaded from your config file' -r
complete -c pueue -n "__fish_use_subcommand" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_use_subcommand" -s V -l version -d 'Print version information'
complete -c pueue -n "__fish_use_subcommand" -s v -l verbose -d 'Verbose mode (-v, -vv, -vvv)'
complete -c pueue -n "__fish_use_subcommand" -f -a "add" -d 'Enqueue a task for execution'
complete -c pueue -n "__fish_use_subcommand" -f -a "remove" -d 'Remove tasks from the list. Running or paused tasks need to be killed first'
complete -c pueue -n "__fish_use_subcommand" -f -a "switch" -d 'Switches the queue position of two commands. Only works on queued and stashed commands'
complete -c pueue -n "__fish_use_subcommand" -f -a "stash" -d 'Stashed tasks won\'t be automatically started. You have to enqueue them or start them by hand'
complete -c pueue -n "__fish_use_subcommand" -f -a "enqueue" -d 'Enqueue stashed tasks. They\'ll be handled normally afterwards'
complete -c pueue -n "__fish_use_subcommand" -f -a "start" -d 'Resume operation of specific tasks or groups of tasks.
By default, this resumes the default group and all its tasks.
Can also be used force-start specific tasks.'
complete -c pueue -n "__fish_use_subcommand" -f -a "restart" -d 'Restart task(s). Identical tasks will be created and by default enqueued. By default, a new task will be created'
complete -c pueue -n "__fish_use_subcommand" -f -a "pause" -d 'Either pause running tasks or specific groups of tasks.
By default, pauses the default group and all its tasks.
A paused queue (group) won\'t start any new tasks.'
complete -c pueue -n "__fish_use_subcommand" -f -a "kill" -d 'Kill specific running tasks or whole task groups. Kills all tasks of the default group when no ids are provided'
complete -c pueue -n "__fish_use_subcommand" -f -a "send" -d 'Send something to a task. Useful for sending confirmations such as \'y\\n\''
complete -c pueue -n "__fish_use_subcommand" -f -a "edit" -d 'Edit the command or path of a stashed or queued task.
The command is edited by default.'
complete -c pueue -n "__fish_use_subcommand" -f -a "group" -d 'Use this to add or remove groups. By default, this will simply display all known groups'
complete -c pueue -n "__fish_use_subcommand" -f -a "status" -d 'Display the current status of all tasks'
complete -c pueue -n "__fish_use_subcommand" -f -a "format-status" -d 'Accept a list or map of JSON pueue tasks via stdin and display it just like "status". A simple example might look like this: pueue status --json | jq -c \'.tasks\' | pueue format-status'
complete -c pueue -n "__fish_use_subcommand" -f -a "log" -d 'Display the log output of finished tasks. When looking at multiple logs, only the last few lines will be shown. If you want to "follow" the output of a task, please use the "follow" subcommand'
complete -c pueue -n "__fish_use_subcommand" -f -a "follow" -d 'Follow the output of a currently running task. This command works like tail -f'
complete -c pueue -n "__fish_use_subcommand" -f -a "wait" -d 'Wait until tasks are finished. This can be quite useful for scripting. By default, this will wait for all tasks in the default group to finish. Note: This will also wait for all tasks that aren\'t somehow \'Done\'. Includes: [Paused, Stashed, Locked, Queued, ...]'
complete -c pueue -n "__fish_use_subcommand" -f -a "clean" -d 'Remove all finished tasks from the list'
complete -c pueue -n "__fish_use_subcommand" -f -a "reset" -d 'Kill all tasks, clean up afterwards and reset EVERYTHING!'
complete -c pueue -n "__fish_use_subcommand" -f -a "shutdown" -d 'Remotely shut down the daemon. Should only be used if the daemon isn\'t started by a service manager'
complete -c pueue -n "__fish_use_subcommand" -f -a "parallel" -d 'Set the amount of allowed parallel tasks. By default, adjusts the amount of the default group'
complete -c pueue -n "__fish_use_subcommand" -f -a "completions" -d 'Generates shell completion files. This can be ignored during normal operations'
complete -c pueue -n "__fish_use_subcommand" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c pueue -n "__fish_seen_subcommand_from add" -s w -l working-directory -d 'Specify current working directory' -r -f -a "(__fish_complete_directories)"
complete -c pueue -n "__fish_seen_subcommand_from add" -s d -l delay -d 'Prevents the task from being enqueued until <delay> elapses. See "enqueue" for accepted formats' -r
complete -c pueue -n "__fish_seen_subcommand_from add" -s g -l group -d 'Assign the task to a group. Groups kind of act as separate queues. I.e. all groups run in parallel and you can specify the amount of parallel tasks for each group. If no group is specified, the default group will be used' -r
complete -c pueue -n "__fish_seen_subcommand_from add" -s a -l after -d 'Start the task once all specified tasks have successfully finished. As soon as one of the dependencies fails, this task will fail as well' -r
complete -c pueue -n "__fish_seen_subcommand_from add" -s l -l label -d 'Add some information for yourself. This string will be shown in the "status" table. There\'s no additional logic connected to it' -r
complete -c pueue -n "__fish_seen_subcommand_from add" -s e -l escape -d 'Escape any special shell characters (" ", "&", "!", etc.). Beware: This implicitly disables nearly all shell specific syntax ("&&", "&>")'
complete -c pueue -n "__fish_seen_subcommand_from add" -s i -l immediate -d 'Immediately start the task'
complete -c pueue -n "__fish_seen_subcommand_from add" -s s -l stashed -d 'Create the task in Stashed state. Useful to avoid immediate execution if the queue is empty'
complete -c pueue -n "__fish_seen_subcommand_from add" -s p -l print-task-id -d 'Only return the task id instead of a text. This is useful when scripting and working with dependencies'
complete -c pueue -n "__fish_seen_subcommand_from add" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from remove" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from switch" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from stash" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from enqueue" -s d -l delay -d 'Delay enqueuing these tasks until <delay> elapses. See DELAY FORMAT below' -r
complete -c pueue -n "__fish_seen_subcommand_from enqueue" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from start" -s g -l group -d 'Resume a specific group and all paused tasks in it. The group will be set to running and its paused tasks will be resumed' -r
complete -c pueue -n "__fish_seen_subcommand_from start" -s a -l all -d 'Resume all groups! All groups will be set to running and paused tasks will be resumed'
complete -c pueue -n "__fish_seen_subcommand_from start" -s c -l children -d 'Also resume direct child processes of your paused tasks. By default only the main process will get a SIGSTART'
complete -c pueue -n "__fish_seen_subcommand_from start" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from restart" -s g -l failed-in-group -d 'Like `--all-failed`, but only restart tasks failed tasks of a specific group. The group will be set to running and its paused tasks will be resumed' -r
complete -c pueue -n "__fish_seen_subcommand_from restart" -s a -l all-failed -d 'Restart all failed tasks accross all groups. Nice to use in combination with `-i/--in-place`'
complete -c pueue -n "__fish_seen_subcommand_from restart" -s k -l start-immediately -d 'Immediately start the tasks, no matter how many open slots there are. This will ignore any dependencies tasks may have'
complete -c pueue -n "__fish_seen_subcommand_from restart" -s s -l stashed -d 'Set the restarted task to a "Stashed" state. Useful to avoid immediate execution'
complete -c pueue -n "__fish_seen_subcommand_from restart" -s i -l in-place -d 'Restart the task by reusing the already existing tasks. This will overwrite any previous logs of the restarted tasks'
complete -c pueue -n "__fish_seen_subcommand_from restart" -l not-in-place -d 'Restart the task by creating a new identical tasks. Only applies, if you have the restart_in_place configuration set to true'
complete -c pueue -n "__fish_seen_subcommand_from restart" -s e -l edit -d 'Edit the tasks\' command before restarting'
complete -c pueue -n "__fish_seen_subcommand_from restart" -s p -l edit-path -d 'Edit the tasks\' path before restarting'
complete -c pueue -n "__fish_seen_subcommand_from restart" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from pause" -s g -l group -d 'Pause a specific group' -r
complete -c pueue -n "__fish_seen_subcommand_from pause" -s a -l all -d 'Pause all groups!'
complete -c pueue -n "__fish_seen_subcommand_from pause" -s w -l wait -d 'Only pause the specified group and let already running tasks finish by themselves'
complete -c pueue -n "__fish_seen_subcommand_from pause" -s c -l children -d 'Also pause direct child processes of a task\'s main process. By default only the main process will get a SIGSTOP. This is useful when calling bash scripts, which start other processes themselves. This operation is not recursive!'
complete -c pueue -n "__fish_seen_subcommand_from pause" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from kill" -s g -l group -d 'Kill all running tasks in a group. This also pauses the group' -r
complete -c pueue -n "__fish_seen_subcommand_from kill" -s s -l signal -d 'Send a UNIX signal instead of simply killing the process. DISCLAIMER: This bypasses Pueue\'s process handling logic! You might enter weird invalid states, use at your own descretion' -r
complete -c pueue -n "__fish_seen_subcommand_from kill" -s a -l all -d 'Kill all running tasks across ALL groups. This also pauses all groups'
complete -c pueue -n "__fish_seen_subcommand_from kill" -s c -l children -d 'Send the SIGTERM signal to all children as well. Useful when working with shell scripts'
complete -c pueue -n "__fish_seen_subcommand_from kill" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from send" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from edit" -s p -l path -d 'Edit the path of the task'
complete -c pueue -n "__fish_seen_subcommand_from edit" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from group; and not __fish_seen_subcommand_from add; and not __fish_seen_subcommand_from remove; and not __fish_seen_subcommand_from help" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from group; and not __fish_seen_subcommand_from add; and not __fish_seen_subcommand_from remove; and not __fish_seen_subcommand_from help" -f -a "add" -d 'Add a group by name'
complete -c pueue -n "__fish_seen_subcommand_from group; and not __fish_seen_subcommand_from add; and not __fish_seen_subcommand_from remove; and not __fish_seen_subcommand_from help" -f -a "remove" -d 'Remove a group by name. This will move all tasks in this group to the default group!'
complete -c pueue -n "__fish_seen_subcommand_from group; and not __fish_seen_subcommand_from add; and not __fish_seen_subcommand_from remove; and not __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c pueue -n "__fish_seen_subcommand_from group; and __fish_seen_subcommand_from add" -s p -l parallel -d 'Set the amount of parallel tasks this group can have' -r
complete -c pueue -n "__fish_seen_subcommand_from group; and __fish_seen_subcommand_from add" -l version -d 'Print version information'
complete -c pueue -n "__fish_seen_subcommand_from group; and __fish_seen_subcommand_from add" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from group; and __fish_seen_subcommand_from remove" -l version -d 'Print version information'
complete -c pueue -n "__fish_seen_subcommand_from group; and __fish_seen_subcommand_from remove" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from group; and __fish_seen_subcommand_from help" -l version -d 'Print version information'
complete -c pueue -n "__fish_seen_subcommand_from group; and __fish_seen_subcommand_from help" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from status" -s g -l group -d 'Only show tasks of a specific group' -r
complete -c pueue -n "__fish_seen_subcommand_from status" -s j -l json -d 'Print the current state as json to stdout. This does not include the output of tasks. Use `log -j` if you want everything'
complete -c pueue -n "__fish_seen_subcommand_from status" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from format-status" -s g -l group -d 'Only show tasks of a specific group' -r
complete -c pueue -n "__fish_seen_subcommand_from format-status" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from log" -s l -l lines -d 'Only print the last X lines of each task\'s output. This is done by default if you\'re looking at multiple tasks' -r
complete -c pueue -n "__fish_seen_subcommand_from log" -s j -l json -d 'Print the resulting tasks and output as json. By default only the last lines will be returned unless --full is provided. Take care, as the json cannot be streamed! If your logs are really huge, using --full can use all of your machine\'s RAM'
complete -c pueue -n "__fish_seen_subcommand_from log" -s f -l full -d 'Show the whole output. This is the default if only a single task is being looked at'
complete -c pueue -n "__fish_seen_subcommand_from log" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from follow" -s l -l lines -d 'Only print the last X lines of the output before following' -r
complete -c pueue -n "__fish_seen_subcommand_from follow" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from wait" -s g -l group -d 'Wait for all tasks in a specific group' -r
complete -c pueue -n "__fish_seen_subcommand_from wait" -s a -l all -d 'Wait for all tasks across all groups and the default group'
complete -c pueue -n "__fish_seen_subcommand_from wait" -s q -l quiet -d 'Don\'t show any log output while waiting'
complete -c pueue -n "__fish_seen_subcommand_from wait" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from clean" -s g -l group -d 'Only clean tasks of a specific group' -r
complete -c pueue -n "__fish_seen_subcommand_from clean" -s s -l successful-only -d 'Only clean tasks that finished successfully'
complete -c pueue -n "__fish_seen_subcommand_from clean" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from reset" -s c -l children -d 'Send the SIGTERM signal to all children as well. Useful when working with shell scripts'
complete -c pueue -n "__fish_seen_subcommand_from reset" -s f -l force -d 'Don\'t ask for any confirmation'
complete -c pueue -n "__fish_seen_subcommand_from reset" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from shutdown" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from parallel" -s g -l group -d 'Set the amount for a specific group' -r
complete -c pueue -n "__fish_seen_subcommand_from parallel" -s h -l help -d 'Print help information'
complete -c pueue -n "__fish_seen_subcommand_from completions" -s h -l help -d 'Print help information'
