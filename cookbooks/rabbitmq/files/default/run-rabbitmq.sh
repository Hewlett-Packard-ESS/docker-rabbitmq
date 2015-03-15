#!/bin/bash
ulimit -n 1024

HOSTNAME=$(hostname)
PID_FILE="/storage/mnesia/rabbit\@$HOSTNAME.pid"

function run_cmd()
{
        su rabbitmq -s /bin/sh -c "$1"
}

function start()
{
	if [ -z "$CLUSTERED" ]; then
		# Not clustered, just start
        	/usr/sbin/rabbitmq-server >/dev/null &
	else
		if [ -z "$CLUSTERED_WITH" ]; then
			# Is clustered, but not specified who to cluster with
        		/usr/sbin/rabbitmq-server >/dev/null &
		else
               		/usr/sbin/rabbitmq-server -detached
                	rabbitmqctl stop_app
                	if [ -z "$RAM_NODE" ]; then
                        	rabbitmqctl join_cluster rabbit@$CLUSTERED_WITH
                	else
                        	rabbitmqctl join_cluster --ram rabbit@$CLUSTERED_WITH
                	fi
                	rabbitmqctl start_app

		fi
	fi
	rabbitmqctl wait $PID_FILE
	tail -f /storage/log/rabbit\@$HOSTNAME.log &
	parent=$!
}

function stop()
{
        /usr/sbin/rabbitmqctl stop
	kill -TERM $parent
        exit 0
}

function restart()
{
        /usr/sbin/rabbitmqctl restart
}

trap stop TERM INT
trap restart SIGHUP

start

while true; do
  sleep 1000 & wait
done
