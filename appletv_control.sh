#!/bin/bash

set -e

# Exit immediately for unbound variables.
set -u

# start=$(date +%s%N)	# debug
length=$#
device=""
io=""
characteristic=""
option=""
ATV_id="90:DD:5D:A7:02:20"
airplay_credentials="af410b5d7d19bbbb3e7181ab1a3be960de294d06a083721d36d532af2d7bd614:b49b9cd124bab9fa5b8678ab50815d888a601c8cb02e98b185be405dde6e833f:43334636433330452d394538412d343546352d413944322d324538313436443933413333:33383430346133642d373939652d343365312d396339642d306666663435383861653830"
companion_credentials="af410b5d7d19bbbb3e7181ab1a3be960de294d06a083721d36d532af2d7bd614:d8c402ebc00cfcbb788e63e539e651f1ede1df71fa528fdb946c273ca303b0f7:43334636433330452d394538412d343546352d413944322d324538313436443933413333:37366634333666392d653236662d343966652d396438652d643533346431356639613961"

if [ $length -le 1 ]; then
   printf "Usage: $0 Get < AccessoryName > < Characteristic >\n"
   printf "Usage: $0 Set < AccessoryName > < Characteristic > < Value >\n"
   exit -1
fi

# printf "args =$#\n"   # debug
# printf "arg1 =$1\n"   # debug

if [ $length -ge 1 ]; then
    io=$1
   #  printf "io=$io\n"   # debug
fi
if [ $length -ge 2 ]; then
    device=$2
   #  printf "device = ${device}\n"   # debug
fi
if [ $length -ge 3 ]; then
    characteristic=$3
   #  printf "Characteristic = ${characteristic}\n"   # debug
fi
if [ $length -ge 4 ]; then
    option=$4
   #  printf "option = ${option}\n"   # debug
fi

if [ "${io}" == "Get" ]; then
   case $device in
      'Apple TV Power')
         case $characteristic in
            'On')
               # Get Apple TV power state
               ATV_POWER_STATE=$(atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} power_state)
               if [ "${ATV_POWER_STATE}" = "PowerState.On" ]
               then
                  printf "1\n"
               else
                  printf "0\n"
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
               exit -1
               ;;
         esac
         exit 0
         ;;
      'Apple TV Play State')
         case $characteristic in
            'On')
               # Get Apple TV play status
               # If requested when Apple TV is off, it will switch on
               ATV_PLAYING_STATE=$(atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} playing | grep -oP '(?<=Device state: ).*')
               if [ "${ATV_PLAYING_STATE}" = "Playing" ]
               then
                  printf "1\n"
               else
                  printf "0\n"
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
               exit -1
               ;;
         esac
         exit 0
         ;;
      'Apple TV Movie State')
         case $characteristic in
            'On')
               # Get Apple TV play status
               ATV_PLAYING=$(atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} playing )
               ATV_PLAYING_STATE=$(echo "$ATV_PLAYING" | grep -oP '(?<=Device state: ).*')
               ATV_PLAYING_MOVIE=$(echo "$ATV_PLAYING" | grep -oP '(?<=Media type: ).*')
	       if [ "${ATV_PLAYING_STATE}" = "Playing" ]
               then
	              if [ "${ATV_PLAYING_MOVIE}" = "Video" ]
		      then
		         printf "1\n"
	              else
		         printf "0\n"
		      fi
               else
                     printf "0\n"
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
               exit -1
               ;;
         esac
         exit 0
         ;;
      *)
         printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
         exit -1
         ;;
   esac
fi
if [ "${io}" == 'Set' ]; then
   case $device in
      'Apple TV Power')
         case $characteristic in
            'On')
               # Get Apple TV current power state and switch accordingly
               ATV_POWER_STATE=$(atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} power_state)
               if [ "${ATV_POWER_STATE}" = "PowerState.On" ]
               then
                  atvremote --id ${ATV_id} --companion-credentials ${companion_credentials} turn_off
               else
                  atvremote --id ${ATV_id} --companion-credentials ${companion_credentials} turn_on
               fi
               exit 0
               ;;
            *)
               printf "UnHandled Set ${device} Characteristic ${characteristic}"
               exit -1
               ;;
         esac
         exit 0
         ;;
      'Apple TV Play State')
         case $characteristic in
            'On')
               # Toggle between play and pause
               atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} play_pause
               exit 0
               ;;
            *)
               printf "UnHandled Set ${device} Characteristic ${characteristic}"
               exit -1
               ;;
         esac
         exit 0
         ;;
      'Apple TV Movie State')
         case $characteristic in
            'On')
               # Toggle between play and pause
               atvremote --id ${ATV_id} --airplay-credentials ${airplay_credentials} play_pause
               exit 0
               ;;
            *)
               printf "UnHandled Set ${device} Characteristic ${characteristic}"
               exit -1
               ;;
         esac
         exit 0
         ;;
      *)
         printf "UnHandled Get ${device}  Characteristic ${characteristic}\n"
         exit -1
         ;;
   esac
fi
printf "Unknown io command ${io}\n"
exit -1
