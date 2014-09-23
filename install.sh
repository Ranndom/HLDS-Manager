#!/bin/bash
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

download() {
	mkdir payload &> /dev/null
	wget https://thecyberteknetwork.com/~ranndom/payload/script.sh &> /dev/null
	mv script.sh payload/ &> /dev/null
}

install() {
	# Ask for a bit of information
	read -p "Game server name: " server_name
	read -p "Full path to directory containing srcds_run (without the trailing slash): " full_path
	read -p "Start parameters: " start_params
	read -p "App ID of server: " app_id
	read -p "Full path to directory containing SteamCMD executable (without the trailing slash): " steamcmd_exec
	echo " "

	# Check if steamcmd exists.
	if [ -f "${steamcmd_exec}/steamcmd.sh" ]; then
		# Do nothing. SteamCMD exists.
		echo "Found SteamCMD, not redownloading."
		echo " "
	else
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

	echo "Settings"
	echo "==============="
	echo "Server Name: ${server_name}"
	echo "SRCDS Run: ${full_path}"
	echo "Start parameters: ${start_params}"
	echo "App ID: ${app_id}"
	echo "SteamCMD: ${steamcmd_exec}/steamcmd.sh"
	echo "==============="
	echo " "

	read -p "Install location: $(pwd)/" install_location

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

	delete_payload

	#rm payload -rf

}

delete_payload() {
	read -p "Delete payload/ directory? (yes/no): " delete_payload
	delete_payload=$(echo $delete_payload | awk '{print tolower($0)}')

	case ${delete_payload} in
		"yes")
			# delete payload directory
			rm payload -rf
			delete_script
			;;
		"no")
			# do nothing
			delete_script
			;;
		*)
			# repeat function.
			echo "Answer must be yes or no."
			delete_payload
			;;
	esac
}

delete_script() {
	read -p "Delete install.sh? (yes/no): " delete_script
	delete_script=$(echo $delete_payload | awk '{print tolower($0)}')

	case ${delete_script} in
		"yes")
			# delete payload directory
			rm install.sh -rf
			next
			;;
		"no")
			# do nothing
			next
			;;
		*)
			# repeat function.
			echo "Answer must be yes or no."
			delete_script
			;;
	esac
}

next() {
	chmod +x ${install_location}
	echo " "
	echo "Installation completed"
	echo "======================"
	echo " "
	echo "Run ./${install_location} install to install the server to the correct location."
}

case $1 in
	install)
		if [ "${2}" == "local" ]; then
			echo "Using local payload"
		else
			download
		fi
		install
		;;
	*)
		echo "Usage: $0 (install)"
		;;
esac