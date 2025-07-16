#!/bin/bash

# add in: /usr/bin/set-cpufreq.sh
# sudo chmod +x /usr/bin/set-cpufreq.sh
#➜  ~ sudo systemctl daemon-reload
#➜  ~ sudo systemctl enable set-cpufreq.service
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
	cpufreq-set -c "${cpu##*/cpu}" -g performance
done
