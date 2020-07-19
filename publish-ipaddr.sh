#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`
MYDIR=`dirname $0`
#########################################

DST="ytani@ssh.ytani.net:public_html/iot"

#########################################
# variables
#
TITLE=`hostname`
PORT=
TEMPLATE_FNAME="ipaddr-template.html"
OBJ_FNAME="ipaddr-`hostname`"
SCP_CMD="scp"
SRCDIR=$MYDIR

TEMPLATE_PATH="${SRCDIR}/${TEMPLATE_FNAME}"

KEYWD_TITLE="{{ title }}"
KEYWD_IP="{{ ipaddr }}"
KEYWD_PORT="{{ port }}"
KEYWD_TEXT1="{{ text1 }}"
KEYWD_TEXT2="{{ text2 }}"

#########################################
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} [-t title(hostname)] [-p port] [-s template] [text1] [text2]"
    echo
}

tsecho () {
    _TSECHO_DATESTR=`LANG=C date +'%F %T'`
    echo "${_TSECHO_DATESTR} ${MYNAME}: $*"
}

tseval() {
    _TSEVAL_CMDLINE=$*
    tsecho $_TSEVAL_CMDLINE
    eval $_TSEVAL_CMDLINE
}

mk_html() {
    _OBJ=$1
    _TITLE=$2
    _IP=$3
    _PORT=$4
    _TEXT1=$5
    _TEXT2=$6

    if [ -z "$_IP" ]; then
        return 1
    fi
    if [ -n "$_PORT" ]; then
        _PORT=":$_PORT"
    fi

    sed -e "s/$KEYWD_TITLE/$_TITLE/g" $TEMPLATE_PATH \
        | sed -e "s/$KEYWD_IP/$_IP/g" \
        | sed -e "s/$KEYWD_PORT/$_PORT/g" \
        | sed -e "s/$KEYWD_TEXT1/$_TEXT1/g" \
        | sed -e "s/$KEYWD_TEXT2/$_TEXT2/g" > $_OBJ
}

publish_html() {
    _OBJ=$1
    if [ -z "$_OBJ" ]; then
        return 1
    fi

    _CMDLINE="$SCP_CMD $_OBJ $DST"
    tseval $_CMDLINE
}

#########################################
# main
#
tsecho "TEMPLATE_PATH=$TEMPLATE_PATH"
if [ ! -f $TEMPLATE_PATH ]; then
    tsecho "$TEMPLATE_PATH: no such file"
    exit 1
fi

IPADDRS=`ifconfig -a | grep inet | grep -v inet6 | grep -v '127.0.0.1' | sed 's/^ *//' | cut -d ' ' -f 2`

while getopts t:p:h:f:s: OPT; do
    case $OPT in
        t) TITLE=$OPTARG ;;
        p) PORT=$OPTARG ;;
        s) TEMPLATE_PATH=$OPTARG ;;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`

TEXT1=$1
TEXT2=$2

for ip in $IPADDRS; do
    if [ -z "$PORT" ]; then
        OBJ_PATH="/tmp/${OBJ_FNAME}-${ip}.html"
    else
        OBJ_PATH="/tmp/${OBJ_FNAME}-${ip}-${PORT}.html"
    fi

    mk_html $OBJ_PATH "$TITLE" "$ip" "$PORT" "$TEXT1" "$TEXT2"
    if [ $? -ne 0 ]; then
        tsecho "ERROR($?)"
        exit 1
    fi

    publish_html $OBJ_PATH
    if [ $? -ne 0 ]; then
        tsecho "ERROR($?)"
        exit 1
    fi

    #rm -v $OBJ_PATH
done
