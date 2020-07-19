#!/bin/sh
#
# (c) Yoichi Tanibayashi
#
MYNAME=`basename $0`
#########################################

DST="ytani@ssh.ytani.net:public_html/iot"

#########################################

TEMPLATE_FNAME="ipaddr-template.html"
HTML_FNAME=`tempfile -s .html`
SCP_CMD="scp"

#
# functions
#
usage () {
    echo
    echo "    usage: ${MYNAME} [-h]"
    echo
}

tsecho () {
    _DATESTR=`LANG=C date +'%F %T'`
    echo "${_DATESTR} ${MYNAME}: $*"
}

tseval() {
    _CMDLINE=$*
    tsecho eval 
}

#
# main
#
while getopts h OPT; do
    case $OPT in
        h) usage
           exit 0
           ;;
        *) usage
           exit 1
           ;;
    esac
done
shift `expr $OPTIND - 1`

tsecho $*
