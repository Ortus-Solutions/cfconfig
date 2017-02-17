#!/bin/sh

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin
CF_DIR=$(cd "$(dirname "$0")"; pwd)/..
MULTI_SERVER="false"
VERSION="11"

osname=`uname`
if [ "$osname" != "Darwin" ]; then
id | grep -w root > /dev/null 2>&1 || {
	echo "$0 must be run as root"
	exit 1
}
fi


install_linux() {
	if [ "$OS" = "RedHat" ]; then
		if [ -d /etc/rc.d/init.d ]; then

			 INITDIR=/etc/rc.d/init.d

		elif [ -d /etc/init.d ]; then

			 INITDIR=/etc/init.d
		else
			echo "Error, could not find your init script directory"
			exit 1
		fi
	else
		# SuSE; services only in /etc/init.d
		if [ -d /etc/init.d ]; then

			 INITDIR=/etc/init.d

		else
			echo "Error, could not find your init script directory"
			exit 1
		fi	
	fi
	

	if [ "$MULTI_SERVER" = "false" ]; then 

	   [ -f $INITDIR/coldfusion_$VERSION ] && {
		echo "ColdFusion $VERSION appears to already be set up to start on boot"
		exit 2
	   }
	elif [ "$MULTI_SERVER" = "true" ]; then 
	   [ -f $INITDIR/coldfusion$VERSIONmulti ] && {
		echo "ColdFusion $VERSION (multiserver) appears to already be set up to start on boot"
		exit 2
	   }
        fi

	
	echo "Creating the ColdFusion $VERSION start script "
	if [ "$MULTI_SERVER" = "false" ]; then 
	     STARTSCRIPT=coldfusion_$VERSION
	     cp -f $CF_DIR/bin/sysinit $INITDIR/$STARTSCRIPT
	     chmod 755 $INITDIR/$STARTSCRIPT
        else	     
	     STARTSCRIPT=coldfusion$VERSIONmulti
	     cp -f $CF_DIR/bin/cf-multi-startup $INITDIR/$STARTSCRIPT
	fi

	
	if [ -x /sbin/chkconfig ]; then
		echo "Adding ColdFusion $VERSION start/kill links"
		/sbin/chkconfig --add $STARTSCRIPT > /dev/null 2>&1
	fi
	
	echo "Install complete"
}

uninstall_linux() {
	
	if [ "$MULTI_SERVER" = "false" ]; then 
	     STARTSCRIPT=coldfusion_$VERSION
	else
	     STARTSCRIPT=coldfusion$VERSIONmulti
	fi

	RMFILE=
	if [ -f /etc/rc.d/init.d/$STARTSCRIPT ]; then
	
		RMFILE=/etc/rc.d/init.d/$STARTSCRIPT

	elif [ -f /etc/init.d/$STARTSCRIPT ]; then

		RMFILE=/etc/init.d/$STARTSCRIPT

	else
		echo "ColdFusion $VERSION does not appear to be added to your init system"
		exit 2

	fi

	if [ -x /sbin/chkconfig ]; then
		echo "Removing ColdFusion $VERSION start/kill links"
		/sbin/chkconfig --del $STARTSCRIPT > /dev/null 2>&1
	fi

	echo "Removing the ColdFusion $VERSION start script $RMFILE"
	rm -f $RMFILE

	echo "Uninstall complete"
}


install_sun() {

	if [ "$MULTI_SERVER" = "false" ]; then 
	     STARTSCRIPT=coldfusion_$VERSION
	else
	     STARTSCRIPT=coldfusion$VERSIONmulti
	fi

	[ -f /etc/init.d/$STARTSCRIPT ] && {
		echo "ColdFusion $VERSION appears to already be set up to start on boot"
		exit 2
	}

	echo "Creating the ColdFusion $VERSION start script /etc/init.d/$STARTSCRIPT"
	if [ "$MULTI_SERVER" = "false" ]; then 
	   cp -f $CF_DIR/bin/sysinit /etc/init.d/$STARTSCRIPT
        else
	   cp -f $CF_DIR/bin/cf-multi-startup /etc/init.d/$STARTSCRIPT
        fi

	
	echo "Adding ColdFusion $VERSION start/kill links"
	ln -s /etc/init.d/$STARTSCRIPT /etc/rc3.d/S25$STARTSCRIPT
	ln -s /etc/init.d/$STARTSCRIPT /etc/rc1.d/K19$STARTSCRIPT

	echo "Install complete"
}

uninstall_sun() {
	if [ "$MULTI_SERVER" = "false" ]; then 
	     STARTSCRIPT=coldfusion_$VERSION
	else
	     STARTSCRIPT=coldfusion$VERSIONmulti
	fi

	[ -f /etc/init.d/$STARTSCRIPT ] || {
		echo "ColdFusion $VERSION does not appear to be added to your init system"
		exit 2
	}

	DIRPATH=/etc/rc3.d:/etc/rc1.d:/etc/init.d
	OLDIFS="$IFS"
	IFS=":"

	for DIR in $DIRPATH
	do
        		for RMFILE in `ls $DIR/*$STARTSCRIPT 2> /dev/null`
        		do
                		[ -f "$RMFILE" ] && {
				echo "Removing $RMFILE"
                        			rm -f $RMFILE
                		}
        		done
	done

	IFS="$OLDIFS"

	echo "Uninstall complete"
}


install_mac() {

	if [ -f /Library/StartupItems/ColdFusion$VERSION ]; then
		echo "ColdFusion $VERSION appears to already be set up to start on boot"
		exit 2
	fi

	if [ "$MULTI_SERVER" = "false" ]; then 
		echo "Creating the ColdFusion $VERSION start script /Library/StartupItems/ColdFusion$VERSION/ColdFusion$VERSION"
		mkdir /Library/StartupItems/ColdFusion$VERSION 
		cp -f $CF_DIR/bin/cf-standalone-startup /Library/StartupItems/ColdFusion$VERSION/ColdFusion$VERSION
		cp -f $CF_DIR/bin/StartupParameters.plist /Library/StartupItems/ColdFusion$VERSION/StartupParameters.plist
		chmod 544 /Library/StartupItems/ColdFusion$VERSION/*
		chown root:wheel /Library/StartupItems/ColdFusion$VERSION/*   
	else 
		echo "Creating the ColdFusion $VERSION Multi-server start script /Library/StartupItems/ColdFusion$VERSIONMulti/ColdFusion$VERSIONMulti"
		mkdir /Library/StartupItems/ColdFusion$VERSIONMulti 
		cp -f $CF_DIR/bin/cf-multi-startup /Library/StartupItems/ColdFusion$VERSIONMulti/ColdFusion$VERSIONMulti
		cp -f $CF_DIR/bin/StartupParameters.plist /Library/StartupItems/ColdFusion$VERSIONMulti/StartupParameters.plist
		chmod 544 /Library/StartupItems/ColdFusion$VERSIONMulti/*
		chown root:wheel /Library/StartupItems/ColdFusion$VERSIONMulti/*  	
	fi		
	echo "Install complete"
}

uninstall_mac() {

	if [ "$MULTI_SERVER" = "false" ]; then 
	   if [ -f /Library/StartupItems/ColdFusion$VERSION ]; then
		echo "ColdFusion $VERSION does not appear to be added to your init system"
		exit 2
	   fi

	   rm -rf /Library/StartupItems/ColdFusion$VERSION 

	   echo "Uninstall complete"
	else
	   if [ -f /Library/StartupItems/ColdFusion$VERSIONMulti ]; then
		echo "ColdFusion $VERSION Multi-server does not appear to be added to your init system"
		exit 2
	   fi

	   rm -rf /Library/StartupItems/ColdFusion$VERSIONMulti

	   echo "Uninstall complete"
	fi
}

#Here we go - 

case `uname` in

	SunOS)
		OS=Solaris
		INSTALL=install_sun
		UNINSTALL=uninstall_sun
		
	;;

	Linux)
		INSTALL=install_linux
		UNINSTALL=uninstall_linux

		if [ -f /etc/redhat-release ]; then
			OS=RedHat
		elif [ -f /etc/SuSE-release ]; then
			OS=SuSE
		elif [ -f /etc/UnitedLinux-release ]; then
			OS=SuSE
		else
			echo "Sorry, only Red Hat and SuSE Linux are supported."
			exit 1
		fi
	;;

	Darwin)
		INSTALL=install_mac
		UNINSTALL=uninstall_mac
	;;
	
	*)
	
	echo "Sorry, your OS: `uname` is unsupported for Init system configuration, skipping."
	exit 1
	;;

esac

ARG=$1

[ -z "$ARG" ] && ARG=usage

case $ARG in

	install)	
		$INSTALL
	;;

	uninstall)
		$UNINSTALL
	;;

	*)
		echo "Usage:$0 (install|uninstall)"
	;;

esac

exit 0
