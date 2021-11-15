#!/bin/bash

_i=0
_movie_count=20
_ToDate=$(date +%Y-%m-%d)
_option_1=$1
_arr_count=$#
_torrent_id=$2
_option_2=$2
_myear=$3
_limit=20

GREEN='\033[0;32m'
NC='\033[0m'


if [ ! -z "$5" ];
then
	_limit=$5
fi

function _callYTSapi {

	_urlstatus=`curl -s "https://yts.mx/api/v2/list_movies.json?quality=720p&sort_by=date_added&order_by=desc"`

	if [ $? -eq 0 ];
	then
		_ytsapi=`curl -s "https://yts.mx/api/v2/list_movies.json?quality=720p&sort_by=date_added&order_by=desc&limit=$_limit" | jq . `
	else
		echo "Error: YTS API URL not accessible. (EX: curl \"https://yts.lt/api/v2/list_movies.json?\") "
		exit 99
	fi
}

function _getTorrrentDetails {

	while [ $_movie_count != $_i ]
	do
		_id=$(echo $_ytsapi | jq .data.movies[$_i].id)
		_title=$(echo $_ytsapi | jq .data.movies[$_i].title)
		_year=$(echo $_ytsapi | jq .data.movies[$_i].year)
		_rating=$(echo $_ytsapi | jq .data.movies[$_i].rating)
		_genres=$(echo $_ytsapi | jq .data.movies[$_i].genres[] | cut -d$'\n' -f1,2)
		_url=$(echo $_ytsapi | jq .data.movies[$_i].url)
		_cover_image=$(echo $_ytsapi | jq .data.movies[$_i].medium_cover_image)

		_torrent_url_720p=$(echo $_ytsapi | jq .data.movies[$_i].torrents[0].url)
		_torrent_url_720p_quality=$(echo $_ytsapi | jq .data.movies[$_i].torrents[0].quality)
		_torrent_url_720p_type=$(echo $_ytsapi | jq .data.movies[$_i].torrents[0].type)
		_torrent_url_720p_size=$(echo $_ytsapi | jq .data.movies[$_i].torrents[0].size)
		_torrent_url_720p_date_uploaded=$(echo $_ytsapi | jq .data.movies[$_i].torrents[0].date_uploaded)

     		_torrent_url_1080p=$(echo $_ytsapi | jq .data.movies[$_i].torrents[1].url)
     		_torrent_url_1080p_quality=$(echo $_ytsapi | jq .data.movies[$_i].torrents[1].quality)
        	_torrent_url_1080p_type=$(echo $_ytsapi | jq .data.movies[$_i].torrents[1].type)
        	_torrent_url_1080p_size=$(echo $_ytsapi | jq .data.movies[$_i].torrents[1].size)
        	_torrent_url_1080p_date_uploaded=$(echo $_ytsapi | jq .data.movies[$_i].torrents[1].date_uploaded)

		#_torrent_date=$(echo $_torrent_url_720p_date_uploaded | cut -d' ' -f1| cut -d'"' -f2)

		#if [ $_torrent_date == $_ToDate ];
		#then
			_printDetails
		#fi

		_i=`expr $_i + 1`
	done
}

function _printFullDetails {

	echo -e "-----------------------------------------------------------------------------------------------------------------"
	echo "Movie Title: $_title"
	echo "Torrent ID: $_id"
	echo "URL: $_url"
	echo "Year: $_year"
	echo "Rating: $_rating"
	echo -e "Genres: $(echo $_ytsapi | jq .data.movies[$_i].genres[] | cut -d$'\n' -f1),$(echo $_ytsapi | jq .data.movies[$_i].genres[] | cut -d$'\n' -f2)"
	echo "Cover Image: $_cover_image"
	echo ""
	echo "Torrents:"
	echo -e "\tQuality: $_torrent_url_720p_quality"
	echo -e "\tType: $_torrent_url_720p_type"
	echo -e "\tSize: $_torrent_url_720p_size"
	echo -e "\tUploaded Date: $_torrent_url_720p_date_uploaded"
	echo -e "\tURL: $_torrent_url_720p"
	echo ""
	echo -e "\tQuality: $_torrent_url_1080p_quality"
	echo -e "\tType: $_torrent_url_1080p_type"
	echo -e "\tSize: $_torrent_url_1080p_size"
	echo -e "\tUploaded Date: $_torrent_url_1080p_date_uploaded"
	echo -e "\tURL: $_torrent_url_1080p"
	echo -e "-----------------------------------------------------------------------------------------------------------------"
}

function _printSummaryDetails {

	echo -e "-----------------------------------------------------------------------------------------------------------------"
	echo "Movie Title: $_title"
	echo "Year: $_year"
	echo "Rating: $_rating"
	echo "Torrent ID: $_id"
	echo "URL: $_url"
	echo -e "-----------------------------------------------------------------------------------------------------------------"
}

function _printDetails {


	if [ $_option_1 == "-f" ];
	then
                if [[ $_option_2 == "-y" && $_arr_count -lt 3 ]];
                then
                        echo -e "Usage: yts-torrent -f -y [Year] Ex: yts-torrent -f -y 2020"
			echo -e "-----------------------------------------------------------------------------------------------------------------"
                        exit 0
		elif [[ $_option_2 == "-y" && $_year -eq $_myear ]];
		then
			_printFullDetails
                elif [[ $_option_2 == "-y" && $_year -ne $_myear ]];
                then
                        return
		else
			_printFullDetails
		fi

	elif [ $_option_1 == "-s" ];
	then
                if [[ $_option_2 == "-y" && $_arr_count -lt 3 ]];
                then
                        echo -e "Usage: yts-torrent -s -y [Year] Ex: yts-torrent -s -y 2020"
			echo -e "-----------------------------------------------------------------------------------------------------------------"
                        exit 0
		elif [[ $_option_2 == "-y" && $_year -eq $_myear ]];
		then
			_printSummaryDetails
		elif [[ $_option_2 == "-y" && $_year -ne $_myear ]];
		then
			return
		else
			_printSummaryDetails
		fi

	elif [ $_option_1 == "-d" ];
	then
		if [ $_arr_count -eq 2 ];
		then
			if [ $_id -eq $_torrent_id ];
			then
				echo -e "-----------------------------------------------------------------------------------------------------------------"
                		echo "Movie Title: $_title"
                		echo "URL: $_url"
                		echo "Year: $_year"
                		echo "Rating: $_rating"
                		echo -e "Genres: $(echo $_ytsapi | jq .data.movies[$_i].genres[] | cut -d$'\n' -f1),$(echo $_ytsapi | jq .data.movies[$_i].genres[] | cut -d$'\n' -f2)"
                		echo "Cover Image: $_cover_image"
                		echo ""
                		echo "Torrents:"
               			echo -e "\tQuality: $_torrent_url_720p_quality"
                		echo -e "\tType: $_torrent_url_720p_type"
                		echo -e "\tSize: $_torrent_url_720p_size"
                		echo -e "\tUploaded Date: $_torrent_url_720p_date_uploaded"
                		echo -e "\tURL: $_torrent_url_720p"
                		echo ""
                		echo -e "\tQuality: $_torrent_url_1080p_quality"
                		echo -e "\tType: $_torrent_url_1080p_type"
                		echo -e "\tSize: $_torrent_url_1080p_size"
                		echo -e "\tUploaded Date: $_torrent_url_1080p_date_uploaded"
                		echo -e "\tURL: $_torrent_url_1080p"
				echo -e "-----------------------------------------------------------------------------------------------------------------"
				echo -e "-----------------------------------------------------------------------------------------------------------------"
				
				exit 0
			fi
		else
			echo "Usage: yts-torrent -d [Torrent ID] Ex: yts-torrent -d 23452"
			echo -e "-----------------------------------------------------------------------------------------------------------------"
			exit 0
		fi

	fi
}

function _print_banner {

	echo ""
	echo -e "${GREEN}   :::   ::::::::::::::::::::::  ${NC}  ::::::::::: ::::::::  ::::::::.  ::::::::.  :::::::::: ::::    ::: :::::::::::" 
	echo -e "${GREEN}  :+:   :+:    :+:   :+:    :+:  ${NC}      :+:    :+:    :+: :+:    :+: :+:    :+: :+:        :+:+:   :+:     :+:    " 
	echo -e "${GREEN}  +:+ +:+     +:+   +:+          ${NC}      +:+    +:+    +:+ +:+    +:+ +:+    +:+ +:+        :+:+:+  +:+     +:+    " 
	echo -e "${GREEN}  +#++:      +#+   +#++:++#++    ${NC}      +#+    +#+    +:+ +#++:++#:  +#++:++#:  +#++:++#   +#+ +:+ +#+     +#+    " 
	echo -e "${GREEN}  +#+       +#+          +#+     ${NC}      +#+    +#+    +#+ +#+    +#+ +#+    +#+ +#+        +#+  +#+#+#     +#+    " 
	echo -e "${GREEN} #+#       #+#   #+#    #+#      ${NC}      #+#    #+#    #+# #+#    #+# #+#    #+# #+#        #+#   #+#+#     #+#    " 
	echo -e "${GREEN}###       ###    ########        ${NC}      ###     ########  ###    ### ###    ### ########## ###    ####     ###    " 

}

_print_banner

if [[ $# -eq 0 || $_option_1 == "-h" ]];
then
	echo ""
	echo "Usage: yts-torrent [Option -s -f -d] [Optional -y] "
	echo ""
	echo -e "\tTorrent Summary.........: -s -y [Year] -l [Total Limit|default is 20] Ex: ./yts-torrent.sh -s -y 2019 -l 40"
	echo -e "\tTorrent Full Summary....: -f -y [Year] -l [Total Limit|default is 20] Ex: ./yts-torrent.sh -f -y 2019 -l 40"
	echo -e "\tTorrent Details.........: -d [Torrent ID] Ex: yts-torrent -d 23452"
	echo -e "\tHelp....................: -h"
	echo -e ""
	exit 0
fi

#echo -e "-----------------------------------------------------------------------------------------------------------------"
echo ""
_callYTSapi
_getTorrrentDetails
#echo -e "-----------------------------------------------------------------------------------------------------------------"
echo ""

exit 0
