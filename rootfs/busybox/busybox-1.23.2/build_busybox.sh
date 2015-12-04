#!/bin/bash

SCRIPT_ROOT_PATH=busybox-1.23.2
check_path_match=0

function get_current_path()
{
   CURR_PATH=$(cd `dirname $0`; pwd)
   echo "$CURR_PATH"
}

function check_curr_path()
{
   target_path=$1
   check_path_match=0

   currpath=$(get_current_path)

   parentCatalogue=${currpath##*/}
   if [ "$parentCatalogue" = "$target_path" ]; then
      check_path_match=1
   else
      check_path_match=0
   fi
}

function check_script_place_path()
{
   echo -e "Note:\n\t Please make sure this script is placed in the directory of [ $SCRIPT_ROOT_PATH ]."

   check_curr_path  $SCRIPT_ROOT_PATH
   if [ $check_path_match -ne 1 ]; then
      echo -e "Please enter the prescribed route.\n"
      exit
   else
      echo "Your path is OK."
   fi
}

config_array=()
function init_important_conf_members()
{
   config_array[0]="CONFIG_STATIC=y"
   config_array[1]="CONFIG_CROSS_COMPILER_PREFIX="\"/usr/local/arm/4.3.2/bin/arm-linux-"\""
   config_array[2]="CONFIG_FEATURE_EDITING_VI=y"
   config_array[3]="CONFIG_FEATURE_USERNAME_COMPLETION=y"
}

function print_front_curr_after_lines_contents()
{
   MEMBER=$1
   MODE=$2
   OBJ=$3
   OBJOLD=$4

   echo "MEMBER=$MEMBER, MODE=$MODE, OBJ=$OBJ, OBJOLD=$OBJOLD ================="

   OBJ_IN_LINE=`grep "$MEMBER"  -n $OBJOLD | head -1 | cut -d  ":"  -f  1`   # maybe is "n"/"M"
   let OBJ_FRONT_LINE=$OBJ_IN_LINE-1
   let OBJ_AFTER_LINE=$OBJ_IN_LINE+1

   sed -n -e '1, '"$OBJ_FRONT_LINE"'p' $OBJOLD > $OBJ
   case $MODE in
     y)
        echo "$MEMBER=y" >> $OBJ
        ;;
     m)
        echo "$MEMBER=m" >> $OBJ
        ;;
     n)
        echo "# $MEMBER is not set" >> $OBJ
        ;;
     *)
        echo "$MEMBER=$MODE" >> $OBJ
        ;;
   esac
   sed -n -e ''"$OBJ_AFTER_LINE"', $p' $OBJOLD >> $OBJ

#           L123=10
#           sed -n -e '1, /$LLL/p' $OBJOLD > $OBJ
#           sed -n '1,/'"$L123"'/p' $OBJOLD > $OBJ
#           sed -n "1, '"$L123"'p" $OBJOLD > $OBJ

#           sed -n -e '1, /"'"$LLL"'"/p' $OBJOLD > $OBJ
}

function handle_config_array()
{
   OBJ=$ORIG_SCRIPT_PATH/.config
   OBJOLD=$OBJ.old

   for mem in "${config_array[@]}"; do
      MODE=`echo $mem | awk -F '=' '{print $2}'`
#     MEMB=`cat  $mem | awk -F '=' '{print $1}'`
      MEMB=`echo $mem | awk -F '=' '{print $1}'`

      mv -f $OBJ $OBJOLD
      if [ $MODE = y ]; then
         if [ -n "`grep "^$MEMB=y$" $OBJOLD`" ]; then
            cat $OBJOLD > $OBJ           
         else
            print_front_curr_after_lines_contents $MEMB  $MODE $OBJ $OBJOLD
         fi
      elif [ $MODE = m ]; then
         if [ -n "`grep "^$MEMB=m$" $OBJOLD`" ]; then
            cat $OBJOLD > $OBJ
         else
            print_front_curr_after_lines_contents $MEMB  $MODE $OBJ $OBJOLD
         fi
      elif [ $MODE = n ]; then
         if [ -n "`grep "^# $MEMB is not set$" $OBJOLD`" ]; then
            cat $OBJOLD > $OBJ
         else
            print_front_curr_after_lines_contents $MEMB  $MODE $OBJ $OBJOLD
         fi
      else
         if [ -n "`grep "^$MEMB=$MODE$"  $OBJOLD`" ]; then
            cat $OBJOLD > $OBJ
         else
            print_front_curr_after_lines_contents $MEMB  $MODE $OBJ $OBJOLD
         fi
      fi
   done

   rm -f $OBJOLD
}

function modify_some_configuration()
{
    init_important_conf_members
    handle_config_array   
}

function do_make()
{
   echo -e "\n\nNow, do \"make\""
   sleep 1
   make

   echo -e "A file named busybox is generated"
   sleep 1
}

function do_make_install()
{
   echo -e "\n\nNow, do \"make install\""
   sleep 1
   make install

   echo -e "A file name _install is generated"
   echo -e "\nls -l ./_install"
   ls -l ./_install
   sleep 1
}

function edit_etc_inittab()
{
   ETC_FILE=$1

   echo "::sysinit:/etc/init.d/rcS"						>   $ETC_FILE/inittab
   echo "::askfirst:-/bin/sh"							>>  $ETC_FILE/inittab
   echo "::restart:/sbin/init"							>>  $ETC_FILE/inittab
   echo "::ctrlaltdel:/sbin/reboot"						>>  $ETC_FILE/inittab
   echo "::shutdown:umount-a -r"						>>  $ETC_FILE/inittab
}

function edit_etc_fstab()
{
   ETC_FILE=$1

   echo "#device	mount-point	type	options	dump	fsck	order"	>   $ETC_FILE/fstab
   echo "proc	/proc	proc	defaults	0	0"			>>  $ETC_FILE/fstab
   echo "sysfs	/sys	sysfs	defaults	0	0"			>>  $ETC_FILE/fstab
   echo "tmpfs	/temp	tmpfs	defaults	0	0"			>>  $ETC_FILE/fstab
   echo "tmpfs	/dev	tmpfs	defaults	0	0"			>>  $ETC_FILE/fstab
}

function edit_etc_profile()
{
   ETC_FILE=$1

   echo "#!/bin/sh"								>   $ETC_FILE/profile
   echo "export HOSTNAME=qiu"							>>  $ETC_FILE/profile
   echo "export USER=root"							>>  $ETC_FILE/profile
   echo "export HOME=root"							>>  $ETC_FILE/profile
   echo "export PS1=\"[\$USER@\$HOSTNAME \\W]\#\""				>>  $ETC_FILE/profile
   echo "PATH=/bin:/sbin:/usr/bin:/usr/sbin"					>>  $ETC_FILE/profile
   echo "LD_LIBRARY_PATH=/lib:/usr/lib:\$LD_LIBRARY_PATH"			>>  $ETC_FILE/profile
   echo "export PATH LD_LIBRARY_PAT"						>>  $ETC_FILE/profile
}

function edit_etc_initd_rcS()
{
   ETC_FILE=$1
   INIT_D=$ETC_FILE/init.d

   mkdir -p $INIT_D

   echo "mount -a"								>   $INIT_D/rcS
   echo "mkdir /dev/pts"							>>  $INIT_D/rcS
   echo "mount -t devpts devpts /dev/pts"					>>  $INIT_D/rcS
   echo "echo /sbin/mdev > /proc/sys/kernel/hotplug"				>>  $INIT_D/rcS
   echo "mdev -s"								>>  $INIT_D/rcS

   chmod a+x $INIT_D/rcS
}

function edit_other_file()
{
   mkdir dev  home temp  proc  sys

   echo "because mknod needs sudo permitting. you maybe demand to input sudo password."
   sudo mknod  dev/console c  5  1
   sudo mknod  dev/null    c  1  3

   echo "" >  dev/.gitignore
   echo "" > home/.gitignore
   echo "" > temp/.gitignore
   echo "" > proc/.gitignore
   echo "" >  sys/.gitignore
}

function edit_install_file()
{
   NEWF=etc

   cd ./_install
   mkdir $NEWF

   edit_etc_inittab    $NEWF
   edit_etc_fstab      $NEWF
   edit_etc_profile    $NEWF
   
   edit_etc_initd_rcS  $NEWF

   edit_other_file
}

function execute_proper_business()
{
   objfile=$ORIG_SCRIPT_PATH/.config
   if [ ! -f $objfile ]; then
      echo -e "Please execute the command \"make menuconfig\", then run this script"
      echo -e "you can do like this:"
      echo -e "\t1. make distclean"
      echo -e "\t2. make menuconfig"
      echo -e "\t3. EXIT Configuration by doing nothing BUT save the new configuration."
      echo -e "\t4. ./build_busybox.sh"
      exit
   else
      modify_some_configuration
      do_make
      do_make_install
      edit_install_file
   fi

}

############################################################################
############                       START HERE                   ############
############################################################################

ORIG_SCRIPT_PATH=$(get_current_path)
echo -e "\nORIG_SCRIPT_PATH = $ORIG_SCRIPT_PATH"

check_script_place_path

execute_proper_business

