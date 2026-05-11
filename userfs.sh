#!/bin/bash

if [ -z $1 ]; then
	echo "nu ati introdus durata de timp in care sa actioneze userFS, scrieti un numar (reprezentat in ore) sau apasati enter pentru valoare implicita (1 ora)"
	read runTime_ora
	if [ -z "$runTime_ora" ]; then
		runTime_ora=1
	fi
else
	runTime_ora=$1
fi

runTime=$(expr "$runTime_ora * 3600" | bc )
startTime=$(date +%s)

users=$(awk -F: '$3 >= 1000 { print $1 }' /etc/passwd) # non-system users au UID mai mare decat 1000

while true; do
currentTime=$(date +%s)
timp=$(expr "$currentTime - $startTime" | bc)

if [ "$(echo "$timp >= $runTime" | bc)" -eq 1 ]; then
	echo "scriptul a mers $((timp / 60)) de miunte. se va opri."
	break
fi

	for user in $users; do
	isActive=$( last -n 1 "$user" | grep -q "still logged in" && echo "yes" || echo "no" )
		if [ -n "$user" ];
			then

			if [ ! -d "/home/userFS/$user" ];
			 	then
	                                mkdir -p "/home/userFS/$user"
	                fi

			if [ "$isActive" = "yes" ];
				then
					ps -u "$user" > "/home/userFS/$user/procs.txt"
					if [ -f /home/userFS/$user/lastLogin.txt ];
						then
                            rm "/home/userFS/$user/lastLogin.txt"
					fi
			else
				last -n 1 "$user" | head -n 1 | awk '{print $4 " " $5 " " $6 " " $7}' > /home/userFS/$user/lastLogin.txt
				echo "" > "/home/userFS/$user/procs.txt"
			fi
		fi
	done
sleep 30
echo "actualizat userFS"
done
