#!/bin/bash
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#    script               :  SinusBot-Helper
#    version              :  0.2
#    last modified        :  08. Oktober 2016
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#    author               :  Manuel Hettche
#    copyright            :  (C) 2016 TS3index.com
#    email                :  info@ts3index.com
#    begin                :  01. Oktober 2016
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
# 
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

var_back_title="SinusBot-Helper by TS3index.com"

var_sinusbot_user="sinusbot"
var_sinusbot_path="/opt/sinusbot"
var_sinusbot_file="sinusbot"
var_ytdl_file="youtube-dl"

var_ts3client_source="http://dl.4players.de/ts/releases"

var_listen_host="0.0.0.0"
var_listen_port="8087"

var_architecture="`uname -m`"
var_distribution=""

# Debian Detection (Issue File)
if grep -iq "debian" /etc/issue; then
    var_distribution=debian
fi

# Debian Detection (LSB Release)
if command -v lsb_release &> /dev/null; then
    if lsb_release -a 2> /dev/null | grep -iq "debian"; then
        var_distribution=debian
    fi
fi

# Ubuntu Detection (Issue File)
if grep -iq "ubuntu" /etc/issue; then
    var_distribution=ubuntu
fi

# Ubuntu Detection (LSB Release)
if command -v lsb_release &> /dev/null; then
    if lsb_release -a 2> /dev/null | grep -iq "ubuntu"; then
        var_distribution=ubuntu
    fi
fi

if [ "$var_distribution" == "" ]; then
    whiptail --title "ERROR: Distribution" --backtitle "$var_back_title" --msgbox "Sorry, the distribution is unknown and can not be detected." 10 60
    exit 1
else 
    if [ "$var_distribution" == "debian" ] && [ $(cat /etc/debian_version | awk '{$0=int($0)}1') -lt 8 ]; then
        whiptail --title "ERROR: Distribution" --backtitle "$var_back_title" --msgbox "Sorry, you can not use the program with this Debian version. Please upgrade your system to Debian 8 (Jessie) or higher." 10 60
        exit 1
    fi
fi

if [ "$var_architecture" != "x86_64" ]; then
    whiptail --title "ERROR: Architecture" --backtitle "$var_back_title" --msgbox "Sorry, the architecture '$var_architecture' is not supported. Please use a 64bit system." 10 60
    exit 1
fi

var_doing="$1"

if [ ! -e $var_sinusbot_path/$var_sinusbot_file ]; then
    if (whiptail --title "Check: SinusBot was already installed?" --backtitle "$var_back_title" --yesno "Is the SinusBot already installed on the server?" 10 50) then
        if [ ! -e $var_sinusbot_path/$var_sinusbot_file ]; then
            var_sinusbot_path=""
            while [ "x$var_sinusbot_path" == "x" ]
            do
                var_sinusbot_path=$(whiptail --title "Check: SinusBot was already installed?" --backtitle "$var_back_title" --inputbox "Where is the SinusBot folder?" --nocancel 10 50 "$var_sinusbot_path" 3>&1 1>&2 2>&3)
                if [ ! -e $var_sinusbot_path/$var_sinusbot_file ]; then
                    if (whiptail --title "Check: SinusBot was already installed?" --backtitle "$var_back_title" --yesno "Folder: $var_sinusbot_path\nThe SinusBot could not be found. Do you want to specify a different folder?" 10 50) then
                        var_sinusbot_path=""
                    fi
                fi
            done
        fi
    fi
fi

if [ -e $var_sinusbot_path/$var_sinusbot_file ]; then
    if [ ! -x $var_sinusbot_path/$var_sinusbot_file ]; then
        chmod 755 $var_sinusbot_path/$var_sinusbot_file
    fi
    
    whiptail --title "Check: SinusBot was already installed?" --backtitle "$var_back_title" --msgbox "SinusBot found! \n\n`$var_sinusbot_path/$var_sinusbot_file --version`" 10 60
    while [ "x$var_doing" == "x" ]
    do
        if [ "`ps ax | grep sinusbot | grep SCREEN`" ]; then
            var_doing=$(whiptail --title "What would you like to do?" --backtitle "$var_back_title" --nocancel --radiolist "" 12 75 5 "stop" "Close the SinusBot" ON "log" "SinusBot Live-Log (tail)" OFF "update-sinusbot" "SinusBot update to the new beta version" OFF "update-client" "TS3-Client update to the latest stable version" OFF "update-ytdl" "YouTube-DL update, if exist" OFF 3>&1 1>&2 2>&3)
        else
            var_doing=$(whiptail --title "What would you like to do?" --backtitle "$var_back_title" --nocancel --radiolist "" 12 75 5 "start" "Start the SinusBot" ON "log" "SinusBot Live-Log (tail)" OFF "update-sinusbot" "SinusBot update to the new beta version" OFF "update-client" "TS3-Client update to the latest stable version" OFF "update-ytdl" "YouTube-DL update, if exist" OFF 3>&1 1>&2 2>&3)
        fi
    done
    
    while [ "`id $var_sinusbot_user 2> /dev/null`" == "" ]
    do
        var_sinusbot_user=$(whiptail --title "SinusBot-User" --backtitle "$var_back_title" --inputbox "The user '$var_sinusbot_user' can not be found.\nPlease enter the name of the sinusbot linux-user:" --nocancel 10 60 "$var_sinusbot_user" 3>&1 1>&2 2>&3)
    done
else
    if (whiptail --title "Install" --backtitle "$var_back_title" --yesno "SinusBot can bot be found.\nIn the next step all packages, SinusBot Beta, TeamSpeak 3 Client and YouTube-DL will be installed." 12 50) then
        var_doing="install"
    fi
fi

debian.install_packages () {
    su -c 'apt-get update'
    su -c 'apt-get install -y screen curl wget sudo python libxcursor1 x11vnc xvfb libx11-xcb1 ca-certificates bzip2 psmisc libglib2.0-0 less'
}

centos.install_packages () {
    su -c 'yum update'
    su -c 'yum -y -q install screen curl wget sudo python libxcursor1 x11vnc xvfb libx11-xcb1 ca-certificates bzip2 psmisc libglib2.0-0'
}

install_sinusbot () {
    wget "https://www.sinusbot.com/dl/sinusbot-beta.tar.bz2" -O "$var_sinusbot_path/$var_sinusbot_file.tar.bz2" 2>&1 | stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --title "Download: SinusBot" --backtitle "$var_back_title" --gauge "Please wait..." 10 60 0
    if [ -e "$var_sinusbot_path/$var_sinusbot_file.tar.bz2" ]; then
        tar -xjf "$var_sinusbot_path/$var_sinusbot_file.tar.bz2" -C "$var_sinusbot_path/"
        rm "$var_sinusbot_path/$var_sinusbot_file.tar.bz2"
    else
        whiptail --title "ERROR: SinusBot" --backtitle "$var_back_title" --msgbox "Sorry, the SinusBot can not be downloaded." 10 60
        exit 1
    fi
    cp $var_sinusbot_path/plugin/libsoundbot_plugin.so $var_sinusbot_path/TeamSpeak3-Client-linux_amd64/plugins
    chmod 755 $var_sinusbot_path/$var_sinusbot_file
    chown -R $var_sinusbot_user:$var_sinusbot_user $var_sinusbot_path
}

install_client () {
    var_ts3client_lversion=$(curl -s "$var_ts3client_source/" | grep -Po '(?<=href=")[0-9]+(\.[0-9]+){2,3}(?=/")' | sort -Vr | head -1)
    var_ts3client_dlpath="$var_ts3client_source/$var_ts3client_lversion/TeamSpeak3-Client-linux_amd64-$var_ts3client_lversion.run"
    var_ts3client_status=$(curl -I "$var_ts3client_dlpath" 2>&1 | grep "HTTP/" | awk '{print $2}')
    if [ "$var_ts3client_status" != "200" ]; then
        whiptail --title "ERROR: TeamSpeak 3 Client" --backtitle "$var_back_title" --msgbox "Sorry, the client can not be downloaded.\n\nStatus: $var_ts3client_status\n$var_ts3client_dlpath" 12 60
        exit 1
    else
         wget "$var_ts3client_dlpath" -O "$var_sinusbot_path/TeamSpeak3-Client-linux_amd64-$var_ts3client_lversion.run" 2>&1 | stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --title "Download: TeamSpeak 3 Client" --backtitle "$var_back_title" --gauge "Please wait..." 10 60 0
    fi

    if [ -f "$var_sinusbot_path/TeamSpeak3-Client-linux_amd64-$var_ts3client_lversion.run" ]; then
        whiptail --title "Install: TeamSpeak 3 Client" --backtitle "$var_back_title" --msgbox "Press 'ENTER' and read the TeamSpeak Systems eula.\nAfter that press 'q' and 'y' to continue." 10 60
        cd $var_sinusbot_path
        chmod 777 "$var_sinusbot_path/TeamSpeak3-Client-linux_amd64-$var_ts3client_lversion.run"
        $var_sinusbot_path/TeamSpeak3-Client-linux_amd64-$var_ts3client_lversion.run
        chown -R $var_sinusbot_user:$var_sinusbot_user $var_sinusbot_path/TeamSpeak3-Client-linux_amd64
        echo "$var_ts3client_lversion" > $var_sinusbot_path/TeamSpeak3-Client-linux_amd64/version
        rm $var_sinusbot_path/TeamSpeak3-Client-linux_amd64-$var_ts3client_lversion.run
    else
        whiptail --title "ERROR: TeamSpeak 3 Client" --backtitle "$var_back_title" --msgbox "Sorry, the client can not be installed." 10 60
        exit 1
    fi
}

start_sinusbot () {
    if [ "`ps x | grep SCREEN | grep sinusbot`" ]; then
        whiptail --title "Start: SinusBot" --backtitle "$var_back_title" --msgbox "Sorry, but SinusBot is currently running." 10 60
    else
        if [ -x $var_sinusbot_path/$var_sinusbot_file ]; then
            rm /tmp/.X11-unix/X40 >/dev/null 2>&1
            screen -AmdSU sinusbot sudo -u$var_sinusbot_user $var_sinusbot_path/$var_sinusbot_file
            PCT=0
            (
            while test $PCT != 100; 
            do
                if [ "`ps x | grep SCREEN | grep sinusbot`" ]; then
                    PCT=`expr $PCT + 10`; 
                    echo $PCT;
                else
                    PCT=100; 
                    echo $PCT;
                fi
                sleep 0.5; 
            done; 
            ) | whiptail --title "Start: SinusBot" --backtitle "$var_back_title" --gauge "Please wait..." 10 60 0
            if [ "`ps x | grep SCREEN | grep sinusbot`" ]; then
                whiptail --title "Start: SinusBot" --backtitle "$var_back_title" --msgbox "Successful! SinusBot was started." 10 60
            else
                whiptail --title "Start: SinusBot" --backtitle "$var_back_title" --msgbox "Sorry, but SinusBot can not be started." 10 60
            fi
        else
            whiptail --title "Start: SinusBot" --backtitle "$var_back_title" --msgbox "Sorry, but SinusBot can not be executed." 10 60
        fi
    fi
}

stop_sinusbot () {
    if [ "`ps x | grep SCREEN | grep sinusbot`" ]; then
        ps x | grep SCREEN | grep sinusbot | awk '{print $1}' | while read PID; do
            kill -15 `pgrep -P $PID`
        done
        PCT=0
        (
        while test $PCT != 100; 
        do
            if [ "`ps x | grep SCREEN | grep sinusbot`" ]; then
                PCT=`expr $PCT + 10`; 
                echo $PCT;
            else
                PCT=100; 
                echo $PCT;
            fi
            sleep 0.5; 
        done; 
        ) | whiptail --title "Stop: SinusBot" --backtitle "$var_back_title" --gauge "Please wait..." 10 60 0
        if [ "`ps x | grep SCREEN | grep sinusbot`" ]; then
            whiptail --title "Stop: SinusBot" --backtitle "$var_back_title" --msgbox "Sorry, but SinusBot can not be stopped." 10 60
        else
            whiptail --title "Stop: SinusBot" --backtitle "$var_back_title" --msgbox "Successful! SinusBot was stopped." 10 60
        fi
    else 
        whiptail --title "Stop: SinusBot" --backtitle "$var_back_title" --msgbox "Sorry, but SinusBot is not running." 10 60
    fi
}

if [ "$var_doing" == "install" ]; then
    if [ ! -f /proc/user_beancounters ]; then
        var_listen_host=$(ip -f inet -o addr show eth0|cut -d\  -f 7 | cut -d/ -f 1)
    else
        var_listen_host=$(ip -f inet -o addr show venet0|cut -d\  -f 7 | cut -d/ -f 1)
    fi

    if (! whiptail --title "Check: IP address" --backtitle "$var_back_title" --yesno "Is '$var_listen_host' the main IP address of the server?" 10 50) then
        var_listen_host=""
        while [ "x$var_listen_host" == "x" ]
        do
            var_listen_host=$(whiptail --title "Check: IP address" --backtitle "$var_back_title" --inputbox "Please specify the server IP address:" --nocancel 10 50 3>&1 1>&2 2>&3)
        done
    fi
    
    if (whiptail --title "SinusBot-User" --backtitle "$var_back_title" --yesno --defaultno "The default user is '$var_sinusbot_user'.\nDo you want to change the user?" 10 50) then
        var_sinusbot_user=""
        while [ "x$var_sinusbot_user" == "x" ]
        do
            var_sinusbot_user=$(whiptail --title "SinusBot-User" --backtitle "$var_back_title" --inputbox "Please enter the name of the SinusBot linux-user. If it does not exists, the SinusBot-Helper will create it." --nocancel 10 60 "$var_sinusbot_user" 3>&1 1>&2 2>&3)
        done
    fi
    
    if [ "`id $var_sinusbot_user 2> /dev/null`" == "" ]; then
        adduser --system --disabled-login --no-create-home --group $var_sinusbot_user
    fi
    
    if [ ! -d "$var_sinusbot_path" ]; then
        mkdir --parents "$var_sinusbot_path"
    fi
    
    # Install: Packages
    whiptail --title "Install: Packages" --backtitle "$var_back_title" --msgbox "The necessary packages are installed in the next step.\nPlease confirm the installation if asked." 10 60
    $var_distribution.install_packages
    update-ca-certificates >/dev/null 2>&1
    
    # Install: TeamSpeak 3 Client
    whiptail --title "Install: TeamSpeak 3 Client" --backtitle "$var_back_title" --msgbox "In the next step the TeamSpeak 3 Client will be downloaded and installed." 10 60
    install_client

    # Install: SinusBot
    whiptail --title "Install: SinusBot" --backtitle "$var_back_title" --msgbox "In the next step SinusBot will be downloaded and installed." 10 60
    install_sinusbot
    
    # Install: YouTube-DL
    whiptail --title "Install: YouTube-DL" --backtitle "$var_back_title" --msgbox "In the next step the free library 'YouTube-DL' will be downloaded and installed.\n\nNote: You need the library to play content from YouTube, SoundCloud or other external sources." 12 60
    wget "https://yt-dl.org/downloads/latest/youtube-dl" -O "$var_sinusbot_path/$var_ytdl_file" 2>&1 | stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --title "Download: YouTube-DL" --backtitle "$var_back_title" --gauge "Please wait..." 10 60 0
    if [ -f $var_sinusbot_path/config.ini ]; then
        var_ytdl_path=$(echo "$var_sinusbot_path/$var_ytdl_file" | sed 's_/_\\/_g')
        sed -i "s/YoutubeDLPath = \"\"/YoutubeDLPath = \"$var_ytdl_path\"/g" $var_sinusbot_path/config.ini
    fi
    chmod a+rx $var_sinusbot_path/$var_ytdl_file
    
    # Set: config.ini
    cat <<EOF > $var_sinusbot_path/config.ini
ListenPort = $var_listen_port 
ListenHost = "$var_listen_host" 
TS3Path = "$var_sinusbot_path/TeamSpeak3-Client-linux_amd64/ts3client_linux_amd64"
YoutubeDLPath = "$var_sinusbot_path/$var_ytdl_file"
LogLevel = 3
LogFile = "$var_sinusbot_path/logs/sinusbot.log"
EOF

    mkdir --parents "$var_sinusbot_path/logs/"
    var_sinusbot_password=$($var_sinusbot_path/$var_sinusbot_file --initonly -RunningAsRootIsEvilAndIKnowThat | awk '/password/{ print $10 }' | tr -d "'")
    rm /tmp/.X11-unix/X40 >/dev/null 2>&1
    chown -R $var_sinusbot_user:$var_sinusbot_user $var_sinusbot_path
    
    if [ "x$var_sinusbot_password" != "x" ]; then
        whiptail --title "Installation completed!" --backtitle "$var_back_title" --msgbox "Congratulations!\nSinusBot has been successfully installed.\n\n   Interface:  http://$var_listen_host:8087\n    Username:  admin\n    Password:  $var_sinusbot_password" 12 60
        if (whiptail --title "Installation completed!" --backtitle "$var_back_title" --yesno "If you execute the SinusBot-Helper again, you can start, stop or update the SinusBot.\n\nWould you like to start SinusBot now?" 10 50) then
            start_sinusbot
        fi
    else
        whiptail --title "Installation completed!" --backtitle "$var_back_title" --msgbox "SinusBot has been installed but can not be started." 12 60
    fi
fi

if [ "$var_doing" == "update-sinusbot" ]; then
    var_sinusbot_cversion=$($var_sinusbot_path/$var_sinusbot_file --version | awk '/SinusBot/ { print $2 }')
    var_sinusbot_lversion=$(wget -qO- "https://forum.sinusbot.com/resources/sinusbot-beta.3/" 2>&1 | grep -Po '(?<=SinusBot Beta <span class="muted">)[^< ]+')
    if [ "$var_sinusbot_cversion" != "$var_sinusbot_lversion" ] && [ "$var_sinusbot_lversion" != "" ]; then
        install_sinusbot
        whiptail --title "Update: SinusBot" --backtitle "$var_back_title" --msgbox "SinusBot has been updated! \n\nLatest Version: $var_sinusbot_cversion\n   New Version: $var_sinusbot_lversion" 10 60
    else
        whiptail --title "Update: SinusBot" --backtitle "$var_back_title" --msgbox "You already have the latest version!" 10 60
    fi
fi

if [ "$var_doing" == "update-client" ]; then
    if [ -e $var_sinusbot_path/TeamSpeak3-Client-linux_amd64/version ]; then
        var_ts3client_cversion=$(cat $var_sinusbot_path/TeamSpeak3-Client-linux_amd64/version)
    fi
    var_ts3client_lversion=$(curl -s "$var_ts3client_source/" | grep -Po '(?<=href=")[0-9]+(\.[0-9]+){2,3}(?=/")' | sort -Vr | head -1)
    if [ "$var_ts3client_cversion" != "$var_ts3client_lversion" ] && [ "$var_ts3client_lversion" != "" ]; then
        install_client
        whiptail --title "Update: TeamSpeak 3 Client" --backtitle "$var_back_title" --msgbox "TeamSpeak 3 Client has been updated! \n\nLatest Version: $var_ts3client_cversion\n   New Version: $var_ts3client_lversion" 10 60
    else
        whiptail --title "Update: TeamSpeak 3 Client" --backtitle "$var_back_title" --msgbox "You already have the latest version!" 10 60
    fi
fi

if [ "$var_doing" == "update-ytdl" ]; then
    var_ytdl_path=""
    if [ -e /usr/local/bin/$var_ytdl_file ]; then
        var_ytdl_path="/usr/local/bin/$var_ytdl_file"
    fi
    if [ -e $var_sinusbot_path/$var_ytdl_file ]; then
        var_ytdl_path="$var_sinusbot_path/$var_ytdl_file"
    fi
    if [ -e $var_sinusbot_path/config.ini ]; then
        var_ytdl_configpath=$(cat $var_sinusbot_path/config.ini | sed 's/ //g' | grep -Po '(?<=YoutubeDLPath=")[^\"]+')
        if [ "$var_ytdl_configpath" ] && [ -e $var_ytdl_configpath ]; then
            var_ytdl_path="$var_ytdl_configpath"
        fi
    fi
    if [ -e $var_ytdl_path ]; then
        var_ytdl_cversion="`$var_ytdl_path --version`";
        var_ytdl_lversion="`wget -qO- https://yt-dl.org/latest/version`"
        if [ "$var_ytdl_cversion" != "$var_ytdl_lversion" ] && [ "$var_ytdl_lversion" != "" ]; then
            wget "https://yt-dl.org/downloads/latest/youtube-dl" -O "$var_sinusbot_path/$var_ytdl_file" 2>&1 | stdbuf -o0 awk '/[.] +[0-9][0-9]?[0-9]?%/ { print substr($0,63,3) }' | whiptail --title "Download: YouTube-DL" --backtitle "$var_back_title" --gauge "Please wait..." 10 60 0
            chmod a+rx $var_ytdl_path
            whiptail --title "Update: YouTube-DL" --backtitle "$var_back_title" --msgbox "YouTube-DL has been updated! \n\nLatest Version: $var_ytdl_cversion\n   New Version: $var_ytdl_lversion" 10 60
        else
            whiptail --title "Update: YouTube-DL" --backtitle "$var_back_title" --msgbox "You already have the latest version!" 10 60
        fi
    else
        whiptail --title "Update: YouTube-DL" --backtitle "$var_back_title" --msgbox "Sorry, YouTube-DL can not be found." 10 60
    fi
fi

if [ "$var_doing" == "log" ]; then
    var_logfile_path="$var_sinusbot_path/logs/sinusbot.log"
    if [ -e $var_sinusbot_path/config.ini ]; then
        var_logfile_configpath=$(cat $var_sinusbot_path/config.ini | sed 's/ //g' | grep -Po '(?<=LogFile=")[^\"]+')
        if [ "$var_logfile_configpath" ] && [ -e $var_logfile_configpath ]; then
            var_logfile_path="$var_logfile_configpath"
        fi
    fi
    if [ "$var_logfile_path" ] && [ -e $var_logfile_path ]; then
        tail -f $var_logfile_path
    else
        whiptail --title "SinusBot Live-Log" --backtitle "$var_back_title" --msgbox "Sorry, Logfile can not be found." 10 60
    fi
fi

if [ "$var_doing" == "start" ]; then
    start_sinusbot
fi

if [ "$var_doing" == "stop" ]; then
    stop_sinusbot
fi
