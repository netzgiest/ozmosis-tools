#!/bin/sh
gDebug=0
# gCodecsinstalled
# gCodecVendor
# gCodecDevice
# gCodecName
# gCodec

# get installed codec/revision
gCodecsInstalled=$(ioreg -rxn IOHDACodecDevice | grep VendorID | awk '{ print $4 }' | sed -e 's/ffffffff//')
gCodecsVersion=$(ioreg -rxn IOHDACodecDevice | grep RevisionID| awk '{ print $4 }')
gVoodooInstalled=$(kextstat |grep VoodooHDA| awk '{ print $2 }')
if [[ $gVoodooInstalled = 0 ]]; then
	echo Please disable VoodooHDA!
	exit 1
else
	echo No VoodooHDA detected!
fi

# no codecs detected
if [ -z "${gCodecsInstalled}" ]; then
    echo "No audio codec detected"
    exit 1
fi

# initialize variables
intel=n
amd=n
nvidia=n
realtek=n
unknown=n
alternate=n

# find realtek codecs
index=0
version=($gCodecsVersion)
for codec in $gCodecsInstalled
do

# sort vendors and devices
case ${codec:2:4} in

    8086 ) Codecintelhdmi=$codec; intel=y
    ;;
    1002 ) Codecamdhdmi=$codec; amd=y
    ;;
    10de ) Codecnvidiahdmi=$codec; nvidia=y
    ;;
    10ec ) Codecrealtekaudio=$codec; Versionrealtekaudio=${version[$index]}; realtek=y
    ;;
    *) Codecunknownaudio=$codec; unknown=y
    ;;

esac
index=$((index + 1))
done

# special names
if [ $realtek = y ]; then
    gCodecVendor=${Codecrealtekaudio:2:4}
    gCodecDevice=${Codecrealtekaudio:6:4}

# debug
    if [ ${gCodecDevice:0:1} = 0 ]; then
        gCodecName=${gCodecDevice:1:3}
    fi

    if [ $gCodecDevice = "0899" ]; then
        gCodecName=898
    fi

    if [ $gCodecDevice = "0900" ]; then
        gCodecName=1150
    fi

#  validate_realtek codec
    case "$gCodecName" in
    269|255|882|883|885|887|888|889|891|892|898|1150 )

# confirm codec, go button
    while true
    do
    read -p "Confirm Realtek ALC$gCodecName (y/n): " choice3
    case "$choice3" in
        [yY]* ) gCodec=$gCodecName; gCodecvalid=y; break;;
        [nN]* ) break;;
    * ) echo "Try again...";;
    esac
    done
    ;;

    * ) 
    ;;
    esac

fi
echo --------------------------------------------------------------------------------
echo "wait for Download to begin... "
if [ ${gCodecName} = 255 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-255.zip?raw=true"
fi

if [ ${gCodecName} = 269 ]; then
	echo Sorry, this Codec is not yet supported :/ 
fi

if [ ${gCodecName} = 882 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-882.zip?raw=true"
fi

if [ ${gCodecName} = 883 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-883.zip?raw=true"
fi

if [ ${gCodecName} = 885 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-885.zip?raw=true"
fi

if [ ${gCodecName} = 887 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-887.zip?raw=true"
fi	

if [ ${gCodecName} = 888 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-888.zip?raw=true"
fi

if [ ${gCodecName} = 889 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-889.zip?raw=true"
fi

if [ ${gCodecName} = 891 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-891.zip?raw=true"
fi

if [ ${gCodecName} = 892 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-892.zip?raw=true"
fi

if [ ${gCodecName} = 898 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-898.zip?raw=true"
fi

if [ ${gCodecName} = 1150 ]; then
	open "https://github.com/Fredde2209/AppleALC-kexts-for-Bios/blob/master/AppleALC-1150.zip?raw=true"
fi
echo --------------------------------------------------------------------------------