clear
green=`tput setaf 46`
reset=`tput sgr0`
echo "${green}
 ██╗    ██╗██╗  ██╗ ██████╗  █████╗ ███╗   ███╗██╗
 ██║    ██║██║  ██║██╔═══██╗██╔══██╗████╗ ████║██║
 ██║ █╗ ██║███████║██║   ██║███████║██╔████╔██║██║
 ██║███╗██║██╔══██║██║   ██║██╔══██║██║╚██╔╝██║██║
 ╚███╔███╔╝██║  ██║╚██████╔╝██║  ██║██║ ╚═╝ ██║██║
  ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
      TAKE BACK YOUR PRIVACY ANDROID VERSION
"
red=`tput setaf 196`
reset=`tput sgr0`
echo "$red}"Do you want remove whoami-android-version? [Y,n]"${reset}"
read -s input
if [[ $input == "N" || $input == "n" ]]; then
        green=`tput setaf 46`
        reset=`tput sgr0`
        echo "${green}"Whoami-android-version is not removed ! ${red}{ User cancel the process  }${green}" ${reset}" && exit 1
fi
        red=`tput setaf 196`
        reset=`tput sgr0`
        echo "${red}"Do you want remove Tor? [Y,n]"${reset}"
        read -s input
        if [[ $input == "Y" || $input == "y" ]]; then
                 apt-get remove tor -y
                 green=`tput setaf 46`
                 reset=`tput sgr0`
                 echo "${green}"Tor is removed !" ${reset}"
        elif [[ $input == "N" || $input == "n" ]]; then
                 red=`tput setaf 196`
                 reset=`tput sgr0`
                 echo "${red}"Tor is not removed"${reset}"


fi
        red=`tput setaf 196`
        reset=`tput sgr0`
        echo "${red}"Do you want remove Proxychains? [Y,n]"${reset}"
        read -s input
        if [[ $input == "Y" || $input == "y" ]]; then
                 apt-get remove proxychains -y
                 green=`tput setaf 46`
                 reset=`tput sgr0`
                 echo "${green}"Proxychains is removed !"${reset}"
         elif [[ $input == "N" || $input == "n" ]]; then
                 red=`tput setaf 196`
                 reset=`tput sgr0`
                 echo "${red}"Proxychains is not removed"${reset}"
fi

red=`tput setaf 196`
        reset=`tput sgr0`
        echo "${red}"Do you want remove Curl? [Y,n]"${reset}"
        read -s input
        if [[ $input == "Y" || $input == "y" ]]; then
                 apt-get remove curl -y
                 green=`tput setaf 46`
                 reset=`tput sgr0`
                 echo "${green}"Curl is removed !"${reset}"
         elif [[ $input == "N" || $input == "n" ]]; then
                 red=`tput setaf 196`
                 reset=`tput sgr0`
                 echo "${red}"Curl is not removed"${reset}"
fi
        echo "${red}"Write the whoami-android-version  file path {ex:/root/Desktop/whoami}"${reset}"
        read path
if      cd $path ; then
        rm -fr $path
        green=`tput setaf 46`
        reset=`tput sgr0`
        echo "${green}"All tool required has been successfuly removed !" ${reset}"

else    clear && green=`tput setaf 46`
reset=`tput sgr0`
echo "${red}
 ██╗    ██╗██╗  ██╗ ██████╗  █████╗ ███╗   ███╗██╗
 ██║    ██║██║  ██║██╔═══██╗██╔══██╗████╗ ████║██║
 ██║ █╗ ██║███████║██║   ██║███████║██╔████╔██║██║
 ██║███╗██║██╔══██║██║   ██║██╔══██║██║╚██╔╝██║██║
 ╚███╔███╔╝██║  ██║╚██████╔╝██║  ██║██║ ╚═╝ ██║██║
  ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝
     TAKE BACK YOUR PRIVACY ANDROID VERSION
"   && echo ${red}UNINSTALL IS FAIL WRONG PATH!${reset} && exit 1
fi
