#!/bin/bash

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache

DIR=~/android/hellfire
ROMDIR=$DIR/out/target/product/

# get current path
reldir=`dirname $0`
cd $reldir
DIR=`pwd`

# Colorize and add text parameters
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

THREADS="16"
DEVICE="$1"
EXTRAS="$2"

echo -e "${bldblu} Set CCACHE ${txtrst}"
ccache -M 50

# get current version
MAJOR=$(cat $DIR/vendor/hf/config/common.mk | grep 'PRODUCT_VERSION_MAJOR = *' | sed  's/PRODUCT_VERSION_MAJOR = //g')
MINOR=$(cat $DIR/vendor/hf/config/common.mk | grep 'PRODUCT_VERSION_MINOR = *' | sed  's/PRODUCT_VERSION_MINOR = //g')
MAINTENANCE=$(cat $DIR/vendor/hf/config/common.mk | grep 'PRODUCT_VERSION_MAINTENANCE = *' | sed  's/PRODUCT_VERSION_MAINTENANCE = //g')
VERSION=$MAJOR.$MINOR$MAINTENANCE

# if we have not extras, reduce parameter index by 1
if [ "$EXTRAS" == "true" ] || [ "$EXTRAS" == "false" ]
then
   SYNC="$2"
   UPLOAD="$3"
else
   SYNC="$3"
   UPLOAD="$4"
fi

# get time of startup
res1=$(date +%s.%N)

# we don't allow scrollback buffer
echo -e '\0033\0143'
clear

# decide what command to execute
case "$EXTRAS" in
   threads)
       echo -e "${bldblu}Please write desired threads followed by [ENTER] ${txtrst}"
       read threads
       THREADS=$threads;;
   clean)
       echo -e ""
       echo -e "${bldblu}Cleaning intermediates and output files ${txtrst}"
       make clean > /dev/null;;
esac

# sync with latest sources
echo -e ""
if [ "$SYNC" == "true" ]
then
   echo -e "${bldblu}Fetching latest sources ${txtrst}"
   repo sync -j"$THREADS"
   echo -e ""
fi

# setup environment
echo -e "${bldblu}Setting up environment ${txtrst}"
. build/envsetup.sh

# lunch device
echo -e ""
echo -e "${bldblu}Starting compilation ${txtrst}"
brunch "cm_$DEVICE-userdebug" -j6;

echo -e ""

# finished? get elapsed time
res2=$(date +%s.%N)
echo "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds) ${txtrst}"
