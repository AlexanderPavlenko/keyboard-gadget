#!/bin/bash

# This script will setup a simple HID keyboard gadget via ConfigFS.
# In order to use it, you must have kernel >= 3.19 and configfs enabled
# when the kernel was compiled (it usually is).

set -xe

DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
cd "$DIR"

# variables and strings
CONFIG=/sys/kernel/config/usb_gadget
MANUFACTURER="Some Company"                                       #  manufacturer attribute
SERIAL="Frosted Flakes"                                           #  device serial number
IDPRODUCT="0xa4ac"                                                #  hex product ID, issued by USB Group
IDVENDOR="0x0525"                                                 #  hex vendor ID, assigned by USB Group
PRODUCT="Emulated HID Keyboard"                                   #  cleartext product description
CONFIG_NAME="Configuration 1"                                     #  name of this configuration
MAX_POWER_MA=120                                                  #  max power this configuration can consume in mA
PROTOCOL=1                                                        #  1 for keyboard. see usb spec
SUBCLASS=1                                                        #  it seems either 1 or 0 works, dunno why
REPORT_LENGTH=8                                                   #  number of bytes per report
DESCRIPTOR="${DIR}/kybd-descriptor.bin"  #  binary blob of report descriptor, see HID class spec
UDC=$(ls /sys/class/udc)                                                     #  name of the UDC driver to use (found in /sys/class/udc/)

# gadget configuration
#modprobe libcomposite                                             #  load configfs
#mount none /config -t configfs                                    #  mount configfs as type configfs at /config
mkdir -p "${CONFIG}/keyboardgadget"                           #  make a new gadget skeleton
cd "${CONFIG}/keyboardgadget"                              #  cd to gadget dir
mkdir -p configs/c.1                                                 #  make the skeleton for a config for this gadget
mkdir -p functions/hid.usb0                                          #  add hid function (will fail if kernel < 3.19, which hid was added in)
echo $PROTOCOL > functions/hid.usb0/protocol                      #  set the HID protocol
echo $SUBCLASS > functions/hid.usb0/subclass                      #  set the device subclass
echo $REPORT_LENGTH > functions/hid.usb0/report_length            #  set the byte length of HID reports
cat $DESCRIPTOR > functions/hid.usb0/report_desc                  #  write the binary blob of the report descriptor to report_desc; see HID class spec
mkdir -p strings/0x409                                               #  setup standard device attribute strings
mkdir -p configs/c.1/strings/0x409
echo $IDPRODUCT > idProduct
echo $IDVENDOR > idVendor
echo $SERIAL > strings/0x409/serialnumber
echo $MANUFACTURER > strings/0x409/manufacturer
echo $PRODUCT > strings/0x409/product
echo $CONFIG_NAME > configs/c.1/strings/0x409/configuration
echo $MAX_POWER_MA > configs/c.1/MaxPower
ln -nfs functions/hid.usb0 configs/c.1                              #  put the function into the configuration by creating a symlink

# binding
echo $UDC > UDC                                                   #  bind gadget to UDC driver (brings gadget online). This will only
                                                                  #  succeed if there are no gadgets already bound to the driver. Do
                                                                  #  lsmod and if there's anything in there like g_*, you'll need to
                                                                  #  rmmod it before bringing this gadget online. Otherwise you'll get
                                                                  #  "device or resource busy."
