#!/bin/bash

################################################################

function format_formatText(){

    cols=$(tput cols);
    if (( ${cols} > 70 )); then
        indent=20;
    else
        indent=5;
    fi;
    
    cutString=`expr ${indent} + ${indent}`;

    stringLength=${#format_in};
    stringRows=`expr ${stringLength} / ${cols} + 1`; # +1 to round up.
    charsPerRow=`expr ${#format_in} / ${stringRows} - ${indent}`;

 #   echo -e "Cols: ${cols}\nString Length: ${stringLength}\nSplit: ${stringRows}\nPer row: ${charsPerRow}\n";

    loop=0;
    startAt=0;

    #===================================
    #   change HEAD to change headline.
    #===================================
    head="\033[91m[\033[37mALERT\033[91m]\033[37m";
    echo -e "\033[${indent}G${head}";

    while (( $loop <= $stringRows )); do
        stopAt=`expr ${startAt} + ${charsPerRow}`;

        if [[ ${format_in:0:1} == " " ]]; then
            startAt=`expr ${start} + 1`;
        fi;

        echo -e "\033[${indent}G${format_in:${startAt}:${charsPerRow}}";

        let "startAt+=${charsPerRow}"
        let "loop++";
    done;

}

##############################################################


clear
i=0;
middleLines=`expr $(tput lines) / 2 - 5`;
middleCols=`expr $(tput cols) / 2 - 10`;

tput cup ${middleLines};


function scanFolder(){
	i=0;
	types=(jpg jpeg gif png mp4 avi flv mp3 pl php rb);

	#scanning containing media.
	countMedia=`expr $(ls -l | grep -Eo "(jpg|jpeg|gif|png|mp4|avi|mp3|flv|pl|rb|php|rb)" | wc -l) - 1`;
	if [[ $countMedia > 0 ]]; then
		while (( $i < ${#types[@]} )); do
			count=`expr $(ls -l | grep "${types[$i]}" | wc -l) - 1`;
			if [[ $count == 0 ]]; then count=1; fi;
			fileTypes[$i]="${types[$i]}: ${count}";
			let "i++";
		done;
	fi;
	i=0; #reset counter;

	#looping through all the fileTypes.
	while (( $i < ${#fileTypes[@]} )); do
		
		#echo ${fileTypes[$i]};

		amount=$(echo ${fileTypes[$i]} | cut -d ':' -f 2);
		ext=$(echo ${fileTypes[$i]} | cut -d ':' -f 1);

		if [[ ${amount:1:1} != "-" ]]; then

			case ${ext} in
				'jpg'|'jpeg'|'png')		createFolder="images" ;;
				'avi'|'mp4'|'flv')	 	createFolder="videos" ;;
				'gif') 					createFolder="gifs" ;;
				'mp3') 					createFolder="music" ;;
				'sh') 					createFolder="" ;;
				*) 						createFolder="other" ;;
			esac;

			if [[ ${createFolder} != "" ]]; then
		
				if [[ ! -d sort_${createFolder} ]]; then
					echo -e "\033[92mCreating ${createFolder}\033[0m";
					mkdir sort_${createFolder};
				fi;

			fi;

		fi;

		let "i++";
		sleep .1s;
	done;
}

function alert(){
	indent="\033[${middleCols}G";

	echo -e "\033[37m";
	
	format_in="This script should be placed in the folder where you want to sort all your files. When this runs, the script will create som folders starting with [sort_*] and it'll start sorting all your [media] in the current folder.";
	format_formatText;
	
	tput cup $(tput lines) 0;
	read -p "do you want to start sorting files? [y/n] " start;
	start=${start:0:1};
	if [[ ${start,,} != "y" ]]; then
		echo -e "\033[91mAborting\033[0m";
		exit
	fi;
}


function sortFiles(){
	moved=0;
	for media in *; do
		if [[ ! -d $media ]]; then
			ext=${media##*.}
			case $ext in
			'jpg'|'jpeg'|'png') mv $media sort_images/; let "moved++" ;;
			'mp4') 				mv $media sort_videos/; let "moved++" ;;
			'gif')				mv $media sort_gifs/; let "moved++"   ;;
			'mp3') 				mv $media sort_music/; let "moved++"  ;;
			'sh')				;;
			*)					mv $media sort_other/; let "moved++"  ;;
			esac;
		fi;
	done;
	sleep .5s;
	clear
	tput cup `expr $(tput lines) / 2` 5;
	echo -e "[\033[36mDone\033[37m]\t\033[36m${moved} files moved.\033[0m";
	tput cup $(tput lines)
}


function run(){
	alert;
	scanFolder;
	sortFiles;
}

run;
