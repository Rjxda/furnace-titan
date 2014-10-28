#!/bin/bash
# If you're using my script, all you need to do is edit the following lines to work for you.
# Final zip will exist in "build" as "furnace-1.0.0-aosp_hammerhead.zip" for example
# If you are using a non-appended dt.image, you will need to add "--dt path/to/dt.img" and
# the appropriate lines for dtbTool to compile it, if not prebuilt.
export ARCH=arm
if [ "$1" == "local" ]; then
	echo "Local Build"
	build=/home/savoca/Documents/Kernel/build_output
	export CROSS_COMPILE=/home/savoca/Documents/GoogleGCC/arm-eabi-4.7/bin/arm-eabi-
else
	echo "Remote Build"
	build=/home/savoca/downloads/furnace/titan
	export CROSS_COMPILE=/home/savoca/storage/toolchains/arm-eabi-4.7/bin/arm-eabi-
fi
kernel="furnace"
version="1.0.0"
rom="stock"
variant="titan"
config="furnace_defconfig"
kerneltype="zImage"
jobcount="-j$(grep -c ^processor /proc/cpuinfo)"

function cleanme {
	if [ -f arch/arm/boot/"$kerneltype" ]; then
		echo "  CLEAN   ozip"
	fi
	rm -rf ozip/kernel/zImage
	rm -rf ozip/kernel/dt.img
	rm -rf arch/arm/boot/"$kerneltype"
	make clean && make mrproper
	echo "Working directory cleaned..."
}

rm -rf out
mkdir out
mkdir out/tmp
echo "Checking for build..."
if [ -f ozip/kernel/zImage ]; then
	read -p "Previous build found, clean working directory..(y/n)? : " cchoice
	case "$cchoice" in
		y|Y )
			cleanme;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " dchoice
	case "$dchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi
echo "Extracting files..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cp arch/arm/boot/"$kerneltype" ozip/kernel/
	rm -rf ozip/system
	mkdir -p ozip/system/etc
	cp scripts/furnace/install-recovery-2.sh ozip/system/etc/
else
	echo "Nothing has been made..."
	read -p "Clean working directory..(y/n)? : " achoice
	case "$achoice" in
		y|Y )
			cleanme;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
	read -p "Begin build now..(y/n)? : " bchoice
	case "$bchoice" in
		y|Y)
			make "$config"
			make "$jobcount"
			exit 0;;
		n|N )
			exit 0;;
		* )
			echo "Invalid...";;
	esac
fi

echo "Making dt.img..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	dtbToolCM -o ozip/kernel/dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/
	echo "dt.img created"
else
	echo "No build found..."
	exit 0;
fi

echo "Zipping..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cd ozip
	zip -r ../"$kernel"-$version-"$rom"_"$variant".zip .
	mv ../"$kernel"-$version-"$rom"_"$variant".zip $build
	cd ..
	rm -rf out ozip/system
	echo "Done..."
	echo "Output zip: $build/$kernel-$version-$(echo $rom)_$variant.zip"
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi
# Export script by Savoca
