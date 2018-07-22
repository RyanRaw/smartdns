#/bin/sh

CURR_DIR=$(cd $(dirname $0);pwd)
VER="`date +"1.%Y.%m.%d-%H%M"`"
SMARTDNS_DIR=$CURR_DIR/../../
SMARTDNS_BIN=$SMARTDNS_DIR/src/smartdns

showhelp()
{
	echo "Usage: make [OPTION]"
	echo "Options:"
	echo " -o               output directory."
	echo " --arch           archtecture."
    echo " --ver            version."
	echo " -h               show this message."
}

build()
{
    ROOT=/tmp/smartdns-deiban
    rm -fr $ROOT
    mkdir -p $ROOT
    cd $ROOT/

    cp $CURR_DIR/DEBIAN $ROOT/ -af
    CONTROL=$ROOT/DEBIAN/control
    mkdir $ROOT/usr/sbin -p
    mkdir $ROOT/etc/smartdns/ -p
    mkdir $ROOT/etc/default/ -p
    mkdir $ROOT/lib/systemd/system/ -p

    sed -i "s/Version:.*/Version: $VER/" $ROOT/DEBIAN/control
    sed -i "s/Architecture:.*/Architecture: $ARCH/" $ROOT/DEBIAN/control
    chmod 0755 $ROOT/DEBIAN/prerm

    cp $SMARTDNS_DIR/etc/smartdns/smartdns.conf  $ROOT/etc/smartdns/
    cp $SMARTDNS_DIR/etc/default/smartdns  $ROOT/etc/default/
    cp $SMARTDNS_DIR/systemd/smartdns.service $ROOT/lib/systemd/system/ 
    cp $SMARTDNS_DIR/src/smartdns $ROOT/usr/sbin
    chmod +x $ROOT/usr/sbin/smartdns

    dpkg -b $ROOT $OUTPUTDIR/smartdns.$VER.$ARCH.deb

    rm -fr $ROOT/
}

main()
{
	OPTS=`getopt -o o:h --long arch:,ver: \
		-n  "" -- "$@"`

	if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

	# Note the quotes around `$TEMP': they are essential!
	eval set -- "$OPTS"

	while true; do
		case "$1" in
		--arch)
			ARCH="$2"
			shift 2;;
        --ver)
            VER="$2"
            shift 2;;
		-o )
			OUTPUTDIR="$2"
			shift 2;;
        -h | --help )
			showhelp
			return 0
			shift ;;
		-- ) shift; break ;;
		* ) break ;;
  		esac
	done

    if [ -z "$ARCH" ]; then
        echo "please input arch."
        return 1;
    fi

    if [ -z "$OUTPUTDIR" ]; then
        OUTPUTDIR=$CURR_DIR;
    fi

    build
}

main $@
exit $?