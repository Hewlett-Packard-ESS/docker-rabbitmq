#!/bin/bash
set -e
ulimit -n 1024

HOSTNAME=$(hostname)
PID_FILE=/storage/mnesia/rabbit\@$HOSTNAME.pid
LOG_FILE=/storage/log/rabbit\@$HOSTNAME.log

function run_cmd()
{
        su rabbitmq -s /bin/sh -c "$1"
}

function start()
{
	mkdir -p /storage/log
	touch $LOG_FILE
	/usr/sbin/rabbitmq-server &

	echo Waiting for RabbitMQ to start...
	while [ ! -f $PID_FILE ]; do 
		sleep 1
		echo Waiting for PID file...
	done
	PID=`cat $PID_FILE`
	echo PID file detected, waiting for PID $PID to start...
	while [ ! kill -0 $PID > /dev/null 2>&1 ]; do
		sleep 1
		echo Waiting for Process to start...
	done 

	echo "Started (PID: $PID)! Tailing $LOG_FILE"
	tail -f $LOG_FILE &
	TAIL_PID=$!

	# Setup clustering..
	if [ ! -z "$CLUSTERED" ] && [ ! -z "$CLUSTERED_WITH" ]; then
		if ! rabbitmqctl cluster_status | grep -q $CLUSTERED_WITH; then
			rabbitmqctl stop_app
			rabbitmqctl reset
			if [ -z "$RAM_NODE" ]; then
                        	rabbitmqctl join_cluster rabbit@$CLUSTERED_WITH
                	else
                        	rabbitmqctl join_cluster --ram rabbit@$CLUSTERED_WITH
                	fi
			rabbitmqctl start_app
		fi
	fi
}

function stop()
{
 	echo Stopping RabbitMQ...
        /usr/sbin/rabbitmqctl stop_app
        /usr/sbin/rabbitmqctl stop
	if [ -z "$TAIL_PID" ]; then
		kill -TERM $TAIL_PID
	fi
	echo Stopped!
        exit 0
}

function restart()
{
        /usr/sbin/rabbitmqctl stop_app
        /usr/sbin/rabbitmqctl start_app
}

trap stop TERM INT
trap restart SIGHUP

start

while true; do
  sleep 1000 & wait
done
