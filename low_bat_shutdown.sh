
#!/bin/bash
# LiPoPi
# Shut down the Pi if the GPIO goes high indicating low battery

# GPIO Port
gpio_port="15"

# Enable GPIO
if [ ! -d "/sys/class/gpio/gpio$gpio_port" ]; then
  echo $gpio_port > /sys/class/gpio/export || { echo -e "Can't access GPIO $gpio_port" 1>&2; exit 1; }
fi

# Set it to input
echo "in" > /sys/class/gpio/gpio$gpio_port/direction || { echo -e "Can't set GPIO $gpio_port to an input" 1>&2; exit 1; }

# Set it as active high
echo 0 > /sys/class/gpio/gpio$gpio_port/active_low || { echo -e "Can't set GPIO $gpio_port to active high" 1>&2; exit 1; } # Productive
#echo 1 > /sys/class/gpio/gpio$gpio_port/active_low || { echo -e "Can't set GPIO $gpio_port to active high" 1>&2; exit 1; } # DEBUG

# If its low (low battery light is on), shutdown
if [ "`cat /sys/class/gpio/gpio$gpio_port/value`" != 1 ]; then
  echo "`date`: Battery is getting low. (Check 1) - Checking again in 5 seconds"
  sleep 5
  if [ "`cat /sys/class/gpio/gpio$gpio_port/value`" != 1 ]; then
  	echo "`date`: Battery is still low... (Check 2) - checking again in 10 seconds"
  	sleep 10
	if [ "`cat /sys/class/gpio/gpio$gpio_port/value`" != 1 ]; then
  		echo "`date`: Battery is low! (Check 3). Shutting down."
	  	sleep 1
		/sbin/shutdown -h now || { echo -e "Can't halt the system" 1>&2; exit 1; } # Comment out for debugging
	fi
  fi
else
 echo "`date`: Battery is good. Keep on running..."
fi

exit 0
