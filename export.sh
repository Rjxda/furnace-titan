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
version="1.1.2"
rom="stock"
variant="titan"
config="furnace_defconfig"
kerneltype="zImage"
jobcount="-j$(grep -c ^processor /proc/cpuinfo)"
ps=2048
base_offset=0x00000000
ramdisk_offset=0x01000000
tags_offset=0x00000100
cmdline="console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 vmalloc=400M utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags"

function cleanme {
	if [ -f arch/arm/boot/"$kerneltype" ]; then
		echo "  CLEAN   ozip"
	fi
	rm -rf ozip/boot.img
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
	cp arch/arm/boot/"$kerneltype" out/"$kerneltype"
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
	dtbToolCM -o out/dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/
	echo "dt.img created"
else
	echo "No build found..."
	exit 0;
fi

echo "Making boot.img..."
if [ -f out/"$kerneltype" ]; then
	mkbootimg --kernel out/"$kerneltype" --ramdisk resources/initramfs.img --cmdline "$cmdline" --pagesize $ps --base $base_offset --ramdisk_offset $ramdisk_offset --tags_offset $tags_offset --dt out/dt.img --output ozip/boot.img
	if [ -z ozip/boot.img ]; then
		echo "mkbootimg failed..."
		exit 0;
	fi
else
	echo "No $kerneltype found..."
	exit 0;
fi

echo "Zipping..."
if [ -f arch/arm/boot/"$kerneltype" ]; then
	cd ozip
	zip -r ../"$kernel"-$version-"$rom"_"$variant".zip .
	mv ../"$kernel"-$version-"$rom"_"$variant".zip $build
	cd ..
	rm -rf out
	echo "Done..."
	echo "Output zip: $build/$kernel-$version-$(echo $rom)_$variant.zip"
	exit 0;
else
	echo "No $kerneltype found..."
	exit 0;
fi
# Export script by Savoca
