# Source Server script for use with SteamPipe games.

# Copyright (c) 2014, Ranndom
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the <organization> nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# [  OK  ]
fn_okay(){
    echo -e "\r\033[K[\e[0;32m  OK  \e[0;39m] $@"
}

# [ FAIL ]
fn_fail(){
	echo -e "\r\033[K[\e[0;31m FAIL \e[0;39m] $@"
}

start() {
	tmuxwc=$(tmux list-sessions 2>&1|grep -v failed|grep -E "^${game_name}:"|wc -l)
	if [ ${tmuxwc} -eq 1 ]; then
		fn_fail "${game_name} is already running."
	else
		fn_okay "Starting ${game_name}."
		sleep 1
		tmux new-session -d -s ${game_name} "${srcds_location}/srcds_run ${start_params}"
	fi
}

stop() {
	tmuxwc=$(tmux list-sessions 2>&1|grep -v failed|grep -E "^${game_name}:"|wc -l)
	if [ ${tmuxwc} -eq 0 ]; then
		fn_fail "${game_name} is not running."
	else
		fn_okay "Stopping ${game_name}."
		sleep 1
		tmux send-keys -t ${game_name} "quit" ENTER
	fi
}

status() {
	tmuxwc=$(tmux list-sessions 2>&1|grep -v failed|grep -E "^${game_name}:"|wc -l)
	if [ ${tmuxwc} -eq 1 ]; then
		fn_okay "${game_name} is currently online."
	else
		fn_fail "${game_name} is currently offline."
	fi
}

command() {
	tmuxwc=$(tmux list-sessions 2>&1|grep -v failed|grep -E "^${game_name}:"|wc -l)
	if [ ${tmuxwc} -eq 1 ]; then
		tmux send-keys -t ${game_name} "$*" ENTER
	else
		fn_fail "${game_name} is not running."
	fi
}

console() {
	tmuxwc=$(tmux list-sessions 2>&1|grep -v failed|grep -E "^${game_name}:"|wc -l)
	if [ ${tmuxwc} -eq 1 ]; then
		fn_okay "Attaching to ${game_name}."
		echo "To detach from the console, press Ctrl + B and then D, DO NOT PRESS Ctrl + C under any circumstances!"
		sleep 3
		tmux attach -t ${game_name}
	else
		fn_fail "${game_name} is not running."
	fi
}

install() {
	# Run SteamCMD.

	${steamcmd}/steamcmd.sh +login anonymous +force_install_dir ${srcds_location}/ +app_update ${appid} +quit

	clear
	fn_okay "Installed/Updated server."
	echo "Use $0 start to start the server."
}

case $1 in
	start)
		start
		;;
	stop)
		stop
		;;
	restart)
		fn_okay "Attempting restart of ${game_name}."
		stop
		sleep 2
		start
		;;
	status)
		status
		;;
	command)
		command ${*:2}
		;;
	console)
		console
		;;
	install)
		install
		;;
	update)
		stop
		install
		;;
	*)
		echo "Usage: $0 (start|stop|restart|status|command|console|install|update)"
		;;
esac