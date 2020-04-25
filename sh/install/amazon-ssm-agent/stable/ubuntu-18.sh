#!/bin/sh -e

# set to non-interactive
export DEBIAN_FRONTEND=noninteractive

# can use "latest"
SSM_VERSION=latest

SSM_INIT_CONFIG=/etc/amazon/ssm
SSM_INIT_SCRIPT=/etc/init.d/amazon-ssm-agent
SSM_ACTIVATION_FILE=${SSM_INIT_CONFIG}/activation.log


# install prerequisites
apt-get update -y

apt-get install -y \
  apt-utils \
  unzip \
  ca-certificates \
  curl

[ ! -f amazon-ssm-agent.deb ] && \
  curl https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/${SSM_VERSION}/debian_amd64/amazon-ssm-agent.deb \
    -o amazon-ssm-agent.deb

# Install from aws
dpkg -i amazon-ssm-agent.deb

# Generate template
cp -f ${SSM_INIT_CONFIG}/seelog.xml.template ${SSM_INIT_CONFIG}/seelog.xml

# Create daemon script
cat << 'DAEMON_SCRIPT' > ${SSM_INIT_SCRIPT}
#!/bin/sh
### BEGIN INIT INFO
# Provides:          amazon-ssm-agent
# Required-Start:    $network $remote_fs $local_fs
# Required-Stop:     $network $remote_fs $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Stop/start ssm
### END INIT INFO

# Author: Diko Tech Slave <diko316@gmail.com>

PATH=/sbin:/usr/sbin:/bin:/usr/bin

if [ -L $0 ]; then
    SCRIPTNAME=$(/bin/readlink -f $0)
else
    SCRIPTNAME=$0
fi

sysconfig=$(/usr/bin/basename $SCRIPTNAME)

[ -r /etc/default/$sysconfig ] && . /etc/default/$sysconfig

NAME=amazon-ssm-agent
DESC=$NAME
DAEMON=/usr/bin/amazon-ssm-agent
PIDFILE=/var/run/amazon-ssm-agent.pid

[ -x $DAEMON ] || exit 0

DAEMON_ARGS=""

. /lib/init/vars.sh

. /lib/lsb/init-functions

do_start()
{
  start-stop-daemon -v --start --quiet --background --make-pidfile --pidfile $PIDFILE --exec $DAEMON
  RETVAL="$?"
  return "$RETVAL"
}

do_stop()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    start-stop-daemon --stop --quiet --oknodo --retry=TERM/30/KILL/5 --pidfile $PIDFILE --exec $DAEMON
    RETVAL=$?
    [ "$RETVAL" = 2 ] && return 2
    rm -f $PIDFILE
    return "$RETVAL"
}

do_reload() {
    start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
    RETVAL="$?"
    return "$RETVAL"
}

case "$1" in
  start)
        [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC " "$NAME"
        do_start
        case "$?" in
            0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  stop)
        [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
        do_stop
        case "$?" in
            0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
            2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
  status)
        status_of_proc -p "$PIDFILE" "$DAEMON" "$NAME" && exit 0 || exit $?
        ;;
  reload|force-reload)
        log_daemon_msg "Reloading $DESC" "$NAME"
        do_reload
        log_end_msg $?
        ;;
  restart|force-reload)
        log_daemon_msg "Restarting $DESC" "$NAME"
        do_stop
        case "$?" in
            0|1)
                do_start
                case "$?" in
                    0) log_end_msg 0 ;;
                    1) log_end_msg 1 ;; # Old process is still running
                    *) log_end_msg 1 ;; # Failed to start
                esac
                ;;
            *)
                # Failed to stop
                log_end_msg 1
                ;;
        esac
        ;;
  *)
        echo "Usage: $SCRIPTNAME {start|stop|status|restart|reload|force-reload}" >&2
        exit 3
        ;;
esac

exit $RETVAL

DAEMON_SCRIPT

# make it executable
chmod +x ${SSM_INIT_SCRIPT}

# initialize daemon
update-rc.d amazon-ssm-agent defaults

rm -f amazon-ssm-agent.deb

# further step
cat << 'MESSAGE' >&2

Futher step, register current environment as managed (hybrid?) instance.
You will need:
  1. Amazon SSM activation id.
  2. Amazon SSM activation code.
  3. AWS region (e.g. us-east-1, eu-west-3)

Run the shell script code below to activate:



# clear last registration
amazon-ssm-agent -register -clear



# register. beware of required VARIABLES
amazon-ssm-agent \
  -register \
  -code "${SSM_CODE}" \
  -id "${SSM_ID}" \
  -region "${AWS_REGION}"



# start if not yet started
service amazon-ssm-agent status > /dev/null 2>&1 || service amazon-ssm-agent start



# reload service to tak effect
service amazon-ssm-agent reload

MESSAGE

