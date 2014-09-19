adbmaster
=========
Bash script to simplify adb command usage.

This is a  helpful bash utility for working with multiple devices at the same time.

#Command line options' description:
no options
  ==> show connected devices.

option [ -l(logcat) ]  arg [ file_suffix ]
  ==> Runs adb logcat on all connected devices and save output to files (file name:                                          device_name_date_log_tag.log) in logs directory

option [ -i ] arg [ device_index ] 
  ==> Sets device_index for device whose logcat is required.

option [ -c(clear) ]  arg [ device_index ] 
  ==> Runs adb pm clear command on device shown at device_index(which is passed as   parameter to this option) shown         in connected devices. Depends upon -p option)

option [ -p(package) ] arg [ package_name ]
  ==> Sets package_name on which adb pm clear command will be run.

option [ -h(help) ] arg none
  ==> Shows help for this tool.


# note: order of the options is important.

    adbmaster -i device_index -l file_suffix ==> logs device at index: device_index.

    adbmaster -l file_suffix -i device_index ==> logs all devices.

    adbmaster -l file_suffix ==> logs all devices.

    adbmaster -p package_name -c device_index ==> executes

    adbmaster -c device_index -p package_name ==> fails

  
