#!/usr/bin/env bash
#
# auto-cpufreq daemon removal script
# reference: https://github.com/AdnanHodzic/auto-cpufreq

echo -e "\n------------------ Running auto-cpufreq daemon removal script ------------------"

if [[ $EUID != 0 ]]; then
	echo -e "\nERROR\nMust be run as root (i.e: 'sudo $0')\n"
	exit 1
fi


# First argument is the "sv" path, second argument is the "service" path
rm_sv() {
    echo -e "\n* Stopping auto-cpufreq daemon (runit) service"
    sv stop auto-cpufreq

    echo -e "\n* Removing auto-cpufreq daemon (runit) unit files"
    rm -rf "$1"/sv/auto-cpufreq
    rm -rf "$2"/service/auto-cpufreq
}

# Remove service for runit
if [ "$(ps h -o comm 1)" = "runit" ];then
	if [ -f /etc/os-release ];then
		eval "$(cat /etc/os-release)"
		separator
		case $ID in
			void)
				rm_sv /etc /var ;;
			artix)
				rm_sv /etc/runit /run/runit ;;
			*)
				echo -e "\n* Runit init detected but your distro is not supported\n"
				echo -e "\n* Please open an issue on https://github.com/AdnanHodzic/auto-cpufreq\n"

		esac
	fi
# Remove service for openrc
else
    echo -e "\n* Stopping auto-cpufreq daemon (openrc) service"
    rc-service auto-cpufreq stop

    echo -e "\n* Disabling auto-cpufreq daemon (openrc) at boot"
    rc-update del auto-cpufreq

    echo -e "\n* Removing auto-cpufreq daemon (openrc) unit file"
    rm /etc/init.d/auto-cpufreq
fi
