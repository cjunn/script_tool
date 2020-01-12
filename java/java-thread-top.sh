#!/bin/bash
# @Function
# Find out the highest cpu consumed threads of java processes, and print the stack of these threads.
# @github https://github.com/cjunn/script_tool/
# @author cjunn
# @date Sun Jan 12 2020 21:08:58 GMT+0800
#

pid='';
count=5;
#1.Collect script parameters
#2.Check whether PID exists
if [ $# -gt 0 ];
then
	while true; do
		case "$1" in
		-c|--count)
			count="$2"
			shift 2
			;;
		-p|--pid)
			pid="$2"
			shift 2
			;;
		-h|--help)
			usage
			;;
		--)
			shift
			break
			;;
		*)
			if [ -z "$1" ] ; then
				break
			fi
			;;
		esac
	done
fi
if  [ ! -n "$pid" ] ;then
	echo "error: -p is empty"
	exit 1;
fi

function usage(){
	echo <<EOF
Usage: ${PROG} [OPTION]
Find out the highest cpu consumed threads of java processes,
and print the stack of these threads.
Example:
  ${PROG} -p <pid> -c 5      # show top 5 busy java threads info
Output control:
  -p, --pid <java pid>      find out the highest cpu consumed threads from
                            the specified java process.
                            default from all java process.
  -c, --count <num>         set the thread count to show, default is 5.
Miscellaneous:
  -h, --help                display this help and exit.
EOF
}

function worker(){
	#1.Query all threads according to PID.
	#2.Delete header and first line information.
	#3.According to the second column of CPU to sort, reverse display.
	#4.Delete the count + 1 to last column based on the count value.
	#5.Get CPU utilization, TID value, thread used time, and assign them to CPU, TID, time respectively.
	#6.Perform hex conversion on TID.
	#7.Use JDK to monitor all threads of jstack output PID.
	#8.Use awk to regularly query the thread information of tid_hex required.
	#9.Display the stack information of count before thread busy.
	local whilec=0;
	ps -mp $pid -o THREAD,tid,time | sed '1,2d' | sort  -k 2 -n -r |sed $[$count+1]',$d' | awk '{print $2,$8,$9}' | while read cpu tid time
	do
			tid_hex=$(printf "%x" $tid);
			echo "====================== tid:${tid}  tid_hex:${tid_hex}  cpu:${cpu}  time:${time} ======================";
			jstack $pid | awk 'BEGIN {RS = "\n\n+";ORS = "\n\n"} /'${tid_hex}'/ {print $0}'
			echo "";
			echo "";
			whilec=$[$whilec+1];
	done
	if [ $whilec -eq 0 ] ; then
		echo "error : thread not found, make sure pid exists.";
	fi

}
worker
