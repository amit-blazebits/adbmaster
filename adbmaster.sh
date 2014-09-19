#!/bin/bash
#******************formatting*****************#
DGray='\e[1;30m'
Blue='\e[0;34m'
Green='\e[0;32m'     
Red='\e[0;31m'     
NC='\e[0m' # No Color]'
#*********************************************#
#************Note*****************************#
#no options ==> show connected devices.

#option [ -l(logcat) ] arg [ file_suffix ] ==> Runs adb logcat on all connected devices and save output to files (file name: device_name_date_log_tag.log) in ~/adbmaster/logs directory

#option [ -i ] arg [ device_index ] ==> Sets device_index for device whose logcat is required.

#option [ -c(clear) ] arg [ device_index ] ==> Runs adb pm clear command on device shown at device_index(which is passed as parameter to this option) shown in connected devices. It doesn't work without -p option.

#option [ -p(package) ] arg [ package_name ] ==> Sets package_name on which adb pm clear command will be run.

#option [ -h(help) ] arg none ==> Shows help for this tool.


#Order of the options is important
#adbmaster -i device_index -l file_suffix ==> logs device at index: device_index.

#adbmaster -l file_suffix -i device_index ==> logs all devices.

#adbmaster -l file_suffix ==> logs all devices.

#adbmaster -p package_name -c device_index ==> executes

#adbmaster -c device_index -p package_name ==> fails
#*********************************************#

devices=`adb devices | grep 'device$' | cut -f1`

pids=""


stop_all_adb_logcat()
{
    echo "stopping all adb logcats..." 

    for pid in $pids
    do  
        echo "Killing $pid"
        kill -TERM $pid
    done
}

tool_help(){
    echo ""
    echo "********HELP********"
    echo "This tool create ~/adbmaster/logs directory"
    echo ""
    echo "NO OPTIONS ==> List all devices." 
    echo "-l (logcat) [file_suffix] ==> Runs adb logcat on all connected devices and save output to files (file name: device_name_date_log_tag.log) in ~/adbmaster/logs directory"
    echo "-i (logcat with device_index) [device_index] ==> Sets device_index for device whose logcat is required."
    echo "-c (clear) [device_index] ==> Runs adb pm clear command on device shown at device_index(which is passed as parameter to this option) shown in connected devices. It doesn't work without -p option."
    echo "-p (package) [package_name] ==> Sets package_name on which adb pm clear command will be run."
    echo "-h (help) ==> Shows help for this tool."
    echo "********************"
    echo ""
}

adb_logcat_log(){
    echo -e  "${Grey}adb_logcat_log${NC}"

    LOG_DIRECTORY=~/adbmaster/logs
    
    if [[ ! -d "${LOG_DIRECTORY}" && ! -L "${LOG_DIRECTORY}" ]] ; then
         
        #Needs write permissions on the $LOG_DRECTORY
        mkdir -p $LOG_DIRECTORY
    fi
    cd $LOG_DIRECTORY
    
    #logcat with index
    if [[ ! -z $DEVICE_INDEX_FOR_LOG ]]; then
        
        DEVICE_ID=$(get_device_id_at_index "$DEVICE_INDEX_FOR_LOG")
        DEVICE_NAME=$(get_device_name_at_index "$DEVICE_INDEX_FOR_LOG")
        
       if [ -z "$DEVICE_ID" ] ; then
            echo "${Red}problem in logging device at index $DEVICE_INDEX_FOR_LOG, stopping..."
            return 
        fi  
 
        log_file="${DEVICE_NAME}_`date +%d_%m_%H:%M:%S`_${LOG_TAG}.log"
        echo -e "${Green}Logging device $DEVICE_NAME to $log_file in $LOG_DIRECTORY${NC}"
        adb -s $DEVICE_ID logcat -v threadtime > "$log_file" &
        pids="$pids $!"
    
    else # logcat all
    
        for device in $devices
        do
            device_name=`adb -s $device shell getprop ro.product.model | tr -d '\r'`
            device_name=$(echo $device_name | sed -e 's/\r//g')
    
            log_file="${device_name}_`date +%d_%m_%H:%M:%S`_${LOG_TAG}.log"
            echo -e  "${Green}Logging device $device_name to $log_file in $LOG_DIRECTORY${NC}"

            adb -s $device logcat -v threadtime > "$log_file" &
            pids="$pids $!"
        done
    
    fi

}


list_devices(){
    echo ""
    echo -e  "${Blue}****Connected devices****${NC}"
    DEVICE_INDEX=0;
    for device in $devices
    do

        name=`adb -s $device shell getprop ro.product.model | tr -d '\r'`
        name=$(echo $name | sed -e 's/\r//g')
        
        echo -e  "${Blue}${DEVICE_INDEX}) $device $name ${NC}"

        DEVICE_INDEX=$((DEVIEC_INDEX+1))

    done
    echo -e "${Blue}************************* ${NC}"
}


get_device_id_at_index(){
    REQUIRED_DEVICE_INDEX=$1
    DEVICE_INDEX_COUNTER=0;
    for device in $devices
    do
        if [ "$REQUIRED_DEVICE_INDEX" -eq "$DEVICE_INDEX_COUNTER" ] ; then
            echo $device
            break
        fi
        DEVICE_INDEX_COUNTER=$((DEVIEC_INDEX_COUNTER+1))

    done

}

get_device_name_at_index(){
    REQUIRED_DEVICE_INDEX=$1
    DEVICE_INDEX_COUNTER=0;
    for device in $devices
    do
        if [ "$REQUIRED_DEVICE_INDEX" -eq "$DEVICE_INDEX_COUNTER" ] ; then
            name=`adb -s $device shell getprop ro.product.model | tr -d '\r'`
            name=$(echo $name | sed -e 's/\r//g')
            echo $name
            break
        fi
        DEVICE_INDEX_COUNTER=$((DEVIEC_INDEX_COUNTER+1))

    done

}

pm_clear_device_with_index(){
    echo -e  "${Grey}pm_clear_device_with_index ${NC}"
    DEVICE_ID=$(get_device_id_at_index $1)
    DEVICE_NAME=$(get_device_name_at_index $1) 

    if [ -z "$PACKAGE_NAME" ] ; then
        echo -e  "${Red}package name not found, stopping...${NC}"
        return 
    fi

    if [ -z "$DEVICE_ID" ] ; then
        echo -e  "${Red}problem in clearing ${PACKAGE_NAME} for device at index ${1}, stopping...${NC}"
        return 
    fi
    
    echo -e  "${Green}clearing package ${PACKAGE_NAME} in device ${DEVICE_ID} ${DEVICE_NAME} ${NC}"

#TODO ask is user wants to go ahead with pm clear
    adb -s ${DEVICE_ID} shell pm clear ${PACKAGE_NAME}
}


list_devices

while getopts l:c:p:h:i:? opts; do
   case ${opts} in
      l)    LOG_TAG=${OPTARG} 
            adb_logcat_log $LOG_TAG                
            ;;
      i)    DEVICE_INDEX_FOR_LOG=${OPTARG}
            ;;
      c)    DEVICE_INDEX=${OPTARG}
            pm_clear_device_with_index $DEVICE_INDEX 
            ;;  
      p)    PACKAGE_NAME=${OPTARG}
            ;;  
      h | ?)    tool_help
            ;;  
      *)    tool_help
            ;;  
   esac
done

trap stop_all_adb_logcat INT 

wait

