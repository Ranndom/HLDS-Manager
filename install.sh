#!/bin/bash

# Colours.
GREEN="\e[32m"
BLUE="\e[34m"
BLACK="\e[30m"
RESET="\e[0m"

# Ask yes or no.
# Parameters:
# 1: Question to ask.
# 2: Command to run if yes.
# 3: Command to run if no.
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

start() {
	if [ "${2}" == "local" ]; then
		echo "Using local payload"
	else
		download
	fi

	collect_information
}

collect_information() {
	# Ask for a bit of information
	echo -ne "${BLUE}Game server name:${RESET} "
	read server_name
	clear
	echo -ne "${BLUE}Full path to install the server to (without the trailing slash):${RESET} "
	read full_path
	clear
	echo -ne "${BLUE}Start parameters:${RESET} "
	read start_params
	clear
	echo -ne "${BLUE}App ID of server:${RESET} "
	read app_id
	clear
	echo -ne "${BLUE}Full path to directory containing SteamCMD executable - will be downloaded if it doesn't exist (without the trailing slash):${RESET} "
	read steamcmd_exec
	clear
	echo -ne "${BLUE}Install location: $(pwd)/${RESET}"
	read install_location
	clear

	install
}

download() {
	mkdir payload &> /dev/null
	wget https://raw.githubusercontent.com/Ranndom/Source-Start-Scripts/master/payload/script.sh &> /dev/null
	mv script.sh payload/ &> /dev/null
}

install() {
	echo -e "${GREEN}Settings"
	echo -e "${RESET}==============="
	echo -e "${BLUE}Server Name:${RESET} ${server_name}"
	echo -e "${BLUE}Server install location:${RESET} ${full_path}"
	echo -e "${BLUE}Start parameters:${RESET} ${start_params}"
	echo -e "${BLUE}App ID:${RESET} ${app_id}"
	echo -e "${BLUE}SteamCMD:${RESET} ${steamcmd_exec}/steamcmd.sh"
	echo -e "${BLUE}Install location:${RESET} ${install_location}"
	echo -e "${RESET}==============="
	echo " "

	ask_yes_or_no "Are you sure these are correct? (yes/no)" "echo \"Continuing with setup...\"" "collect_information"

	# Check if steamcmd exists.
	if [ -f "${steamcmd_exec}/steamcmd.sh" ]; then
		# Do nothing. SteamCMD exists.
		echo "Found SteamCMD, not redownloading."
		echo " "
	else
		echo "SteamCMD not found, downloading now."
		# Download it to current directory.
		wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz &> /dev/null

		# Extract
		tar -zxvf steamcmd_linux.tar.gz &> /dev/null
		rm steamcmd_linux.tar.gz

		# Make the correct directory.
		mkdir -p ${steamcmd_exec}

		# Move files to the correct directory.
		mv linux32/ steam.sh steamcmd.sh ${steamcmd_exec}
	fi

	touch "${install_location}"
	{
		echo -e "#!/bin/bash"
		echo -e "game_name=\"${server_name}\""
		echo -e "srcds_location=\"${full_path}\""
		echo -e "start_params=\"${start_params}\""
		echo -e "appid=\"${app_id}\""
		echo -e "steamcmd=\"${steamcmd_exec}\""
	} | tee "${install_location}" > /dev/null 2>&1
	cat payload/script.sh | tee -a "${install_location}" > /dev/null 2>&1

	ask_yes_or_no "Delete payload/ directory? (yes/no)" "rm payload -rf" "echo \"Not deleting.\""
	ask_yes_or_no "Delete install.sh? (yes/no)" "rm install.sh -rf" "echo \"Not deleting.\""

	chmod +x ${install_location}
	echo " "
	echo "-=> Installation completed"
	echo " "
	echo "-=> Run ./${install_location} install to install the server to the correct location."
}

case $1 in
	install)
		start
		;;
	*)
		echo "Usage: $0 (install)"
		;;
esac