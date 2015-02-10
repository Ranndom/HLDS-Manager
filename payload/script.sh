

# SHOULDN'T NEED TO EDIT BELOW THIS POINT
# <=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=>

# < START HELPER FUNCTIONS >
fn_okay() {
    echo -e "\r\033[K[\e[0;32m  OK  \e[0;39m] $@"
}

fn_fail() {
	echo -e "\r\033[K[\e[0;31m FAIL \e[0;39m] $@"
}

ask_yes_or_no() {
	read -p "${1}: " answer
	answer=$(echo $answer | awk '{print tolower($0)}')

	case ${answer} in
		"yes")
			# Run command 1
			eval "${2}"
			;;
		"no")
			# Run command 2
			eval "${3}"
			;;
		*)
			# Repeat function.
			echo "Answer must be yes or no."
			ask_yes_or_no "${1}" "${2}" "${3}"
			;;
	esac
}
# < END HELPER FUNCTIONS >


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
		sleep 5
		tmux send-keys -t ${game_name} ^C
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

attach() {
	tmuxwc=$(tmux list-sessions 2>&1|grep -v failed|grep -E "^${game_name}:"|wc -l)
	if [ ${tmuxwc} -eq 1 ]; then
		fn_okay "Attaching to ${game_name}."
		tmux attach -t ${game_name}
	else
		fn_fail "${game_name} is not running."
	fi
}

install() {
	${steamcmd}/steamcmd.sh +login anonymous +force_install_dir ${srcds_location}/ +app_update ${appid} +quit

  ask_yes_or_no "Did the installation complete successfully? (yes/no)" "fn_okay \"Installed/Updated server.\" && ask_yes_or_no \"Would you like to install MetaMod and SourceMod onto this server? (yes/no)\" \"install_sourcemod\" \"echo \"Use ${0} start to start the server.\"\"" "install"
}

install_sourcemod() {
	read -p "Game folder (eg. tf, csgo, css): " game_name

	download_sourcemod

	tar -zxvf metamod.tar.gz &> /dev/null
	tar -zxvf sourcemod.tar.gz &> /dev/null

	rm metamod.tar.gz &> /dev/null
	rm sourcemod.tar.gz &> /dev/null

	cp addons/ cfg/ ${srcds_location}/${game_name}/ -rf
	rm addons/ cfg/ -rf

	fn_okay "Successfully installed MetaMod & SourceMod."
}

download_sourcemod() {
  sudo apt-get install wget lynx

	SMPATTERN="http:.*sourcemod-.*-git.*-linux.*"
	SMURL="http://www.sourcemod.net/smdrop/1.6/"
	SMPACKAGE=`lynx -dump "$SMURL" | egrep -o "$SMPATTERN" | tail -1`

	MMPATTERN="http:.*mmsource-.*-git.*-linux.*"
	MMURL="http://sourcemm.net/mmsdrop/1.11/"
	MMPACKAGE=`lynx -dump "$MMURL" | egrep -o "$MMPATTERN" | tail -1`

	wget ${SMPACKAGE} -O sourcemod.tar.gz &> /dev/null
	wget ${MMPACKAGE} -O metamod.tar.gz &> /dev/null

	fn_okay "Downloaded Metamod and Sourcemod"
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
	attach)
		attach
		;;
	update)
		stop
		install
		;;
	*)
		echo "Usage: $0 (start|stop|restart|status|command|attach|update"
		;;
esac