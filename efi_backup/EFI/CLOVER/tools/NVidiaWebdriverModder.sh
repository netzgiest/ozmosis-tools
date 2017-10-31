#!/bin/sh
script_ver="1.0"
script_author="Marchrius"

working_dir="/tmp"
debug="0"

function pathtofile() {
  (
  cd $(dirname $1)         # or  cd ${1%/*}
  echo $(pwd)/$(basename $1) # or  echo $PWD/${1##*/}
  )
}

function usage {
	echo "Usage:"
	echo "--skip-version-check                Replace the NVDARequiredOS key in NVDAStartup.kext to work with an unsupported version. Use only if there isn't an update at the moment."
	echo "WebDriver-xxx.xx.xxlxx.pkg          Modify the file to install it on unsupported machine."
	echo ""
}

echo "Author $script_author. Verision $script_ver"
 
if [ "$1" == "" ]; then
	echo "No pkg. Pass it as argument"
	usage
	exit 1
fi

if [ "$1" == "--skip-version-check" ]; then
	if [ "$(whoami)" != "root" ]; then
		echo "This option need root permissions"
		exit 1
	fi

	current_build_version="$(sw_vers -buildVersion)"

	kext_build_version=$(/usr/libexec/PlistBuddy -c "Print:IOKitPersonalities:NVDAStartup:NVDARequiredOS" /System/Library/Extensions/NVDAStartup.kext/Contents/Info.plist)

	echo "System build version : $current_build_version"
	echo "Kext build version   : $kext_build_version"

	if [ "$current_build_version" == "$kext_build_version" ];then
		echo "The version is ok"
		exit 0
	fi

    echo "Patching Info.plist..."
	/usr/libexec/PlistBuddy -c "Set:IOKitPersonalities:NVDAStartup:NVDARequiredOS $current_build_version" /System/Library/Extensions/NVDAStartup.kext/Contents/Info.plist
	if [ "$?" != "0" ];then
		echo "Error while changing the NVDARequiredOS key."
        exit 1
	fi

	touch /System/Library/Extensions/NVDAStartup.kext/Contents/Info.plist
    if [ "$?" != "0" ];then
            echo "Error while touching Info.plist.."
            exit 1
    fi

    echo "Rebuilding kernelcache ..."
    if [ "$debug" != "1" ];then
        kextcache -system-prelinked-kernel
    fi

    if [ "$?" != "0" ];then
        echo "Error while recreating kernelcache. Relaunch the script or reinstall the driver."
        exit 1
    fi

    echo "Rebuilding system caches ..."
    if [ "$debug" != "1" ];then
        kextcache -system-caches
    fi
    if [ "$?" != "0" ];then
        echo "Error while recreating system caches. Relaunch the script or reinstall the driver."
        exit 1
    fi

    echo "Setting NVRAM boot-args ..."
	current_boot_args="$(nvram boot-args 2>&1)"
	if [ "$?" == "1" ];then
		current_boot_args=""
	else
		current_boot_args="$(nvram boot-args | awk -F '\t' '{ print $2 }')"
	fi

	has_kextdevmode="$(echo $current_boot_args | grep kext-dev-mode=1)"
    if [ "$has_kextdevmode" == "" ];then
		current_boot_args="$current_boot_args kext-dev-mode=1"
	fi

	has_nvdrv1="$(echo $current_boot_args | grep nv_drv=1)"
	has_nvdrv0="$(echo $current_boot_args | grep nv_drv=0)"
	if [ "$has_nvdrv1" == "" ];then
        if [ "$has_nvdrv0" == "" ];then
			current_boot_args="$current_boot_args nv_drv=1"
		fi
	fi
    nvram boot-args="$current_boot_args"

	echo "All jobs done!"
	exit 0
fi

nvidia_pkg="$1"

if [ "${nvidia_pkg##*.}" != "pkg" ];then
	echo "${nvidia_pkg##*/} is not a pkg file"
	exit 1
fi

nvidia_pkg_dir="${nvidia_pkg##*/}"
nvidia_pkg_dir="${nvidia_pkg_dir%.*}"

path_nvidia_pkg="$(pathtofile "$nvidia_pkg")"
path_nvidia_pkg="${path_nvidia_pkg%/*}"

echo "File: $nvidia_pkg"
echo "Path: $path_nvidia_pkg"

echo "Clearing old directories (if any)..."
rm -rf "$working_dir/$nvidia_pkg_dir"

echo "Expanding pkg file..."
pkgutil --expand "$nvidia_pkg" "$working_dir/$nvidia_pkg_dir"

echo "Patching Distribution file..."
cat "$working_dir/$nvidia_pkg_dir/Distribution" | sed -e "s/InstallationCheck();//" >> "$working_dir/$nvidia_pkg_dir/DistributionNew"
mv "$working_dir/$nvidia_pkg_dir/DistributionNew" "$working_dir/$nvidia_pkg_dir/Distribution"

echo "Recreating pkg file in $path_nvidia_pkg directory..."
pkgutil --flatten "$working_dir/$nvidia_pkg_dir" "$path_nvidia_pkg/$nvidia_pkg_dir"_mod.pkg

echo "Clearing temp files..."
rm -rf "$working_dir/$nvidia_pkg_dir"

echo "All jobs done!"
