#!/bin/bash

general_info() {
	local temp=$(vcgencmd measure_temp | awk -F "=" '{print $2}')
	local time=$(date | awk '{print $4}')
	local uptime=$(uptime | awk -F "," '{print $1}' | awk -F " " '{print $3 $4}')
	
	printf ">> general"
	printf "\n"
	printf "    %-20s%s" "Temperature:" $temp
	printf "\n"
	printf "    %-20s%s (%s)" "Time:" "$time" "$uptime"
	printf "\n"
}

# clocks info
clocks_info() {
	printf ">> clocks\n"
	for src in arm . core . . h264 isp v3d uart . pwm emmc pixel vec . hdmi dpi
	do
		if [ $src == "." ]; then
			printf "\n"
			continue
		fi
		local freqHz=$(vcgencmd measure_clock $src | awk -F "=" '{print $2}')
		local freqMHz="$(($freqHz/10**6)) MHz"
		label=$src
		if [ $src == "core" ]; then
			label="gpu"
		elif [ $src == "arm" ];	then
			label="cpu"
		fi
		printf "    %-8s %-15s" "$label:" "$freqMHz"
	done
	printf "\n"
}

voltage_info() {
	printf ">> voltage\n"
	for id in core sdram_c sdram_i sdram_p
	do
		local volts=$(vcgencmd measure_volts $id | awk -F "=" '{print $2}')
		local label=$id
		if [ $id == "core" ]; then
			label="CPU/GPU"
		elif [ $id == "sdram_c" ]; then
			label="Memory (controller)"
		elif [ $id == "sdram_i" ]; then
			label="Memory (I/O)"
		elif [ $id == "sdram_p" ]; then
			label="Memory (physical)"
		fi
		
		printf "    %-20s %-6s\n" "$label:" "$volts"
	done
}

# codecs info
codecs_info() {
	printf ">> codecs status\n"
	for codec in H264 MPG4 MPG2 WVC1 MJPG WMV9
	do
		local status=$(vcgencmd codec_enabled $codec | awk -F "=" '{print $2}')
		printf "    %-20s %-10s\n" "$codec:" "$status"
	done
}

display_header() {
	printf "=================================\n"
	printf "Raspberry PI information (v1.0.0)\n"
	printf "=================================\n"
}

application_loop() {
	while 
		display_header
		printf "\n"
		general_info
		printf "\n"
		clocks_info
		printf "\n"
		voltage_info
		printf "\n"
		codecs_info
		printf "\n"
		if [ $flags_keep -eq 0 ]; then
			break
		fi
		sleep 1
		clear
	do
		:
	done
}

#--#--#--#--#--#--#--#--#--#--#
# application entry point
#--#--#--#--#

flags_keep=0
if [ $# -gt 0 ]; then
	if [ $1 == "-k" ] || [ $1 == "--keep" ]; then
		flags_keep=1
	fi
fi

if [ $flags_keep -eq 1 ]; then
	clear
fi

application_loop