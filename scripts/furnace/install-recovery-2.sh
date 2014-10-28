#!/system/bin/sh
kernel=$(uname -r)

if [ "$kernel" = "3.4.42-furnace" ]; then
	echo "furnace kernel detected!" | tee /dev/kmsg
elif [ "$kernel" = "3.4.42-furnace-dirty" ]; then
	echo "furnace-dirty kernel detected!" | tee /dev/kmsg
else
	echo "unknown kernel detected!" tee /dev/kmsg
	exit 1
fi

if [ -e /sys/module/msm_hotplug/enabled ]; then
	echo "1" > /sys/module/msm_hotplug/enabled
	echo "1" > /sys/module/msm_hotplug/suspend_max_cpus
	echo "600000" > /sys/module/msm_hotplug/suspend_max_freq
else
	echo "0" > /sys/devices/system/cpu/cpu0/rq-stats/hotplug_disable
fi
