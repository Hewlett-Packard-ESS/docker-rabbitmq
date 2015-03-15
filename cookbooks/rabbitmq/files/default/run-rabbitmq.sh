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
	if [ -z "$CLUSTERED" ]; then
		# Not clustered, just start
        	/usr/sbin/rabbitmq-server &
	else
		if [ -z "$CLUSTERED_WITH" ]; then
			# Is clustered, but not specified who to cluster with
        		/usr/sbin/rabbitmq-server &
		else
               		/usr/sbin/rabbitmq-server &
                	rabbitmqctl stop_app
                	if [ -z "$RAM_NODE" ]; then
                        	rabbitmqctl join_cluster rabbit@$CLUSTERED_WITH
                	else
                        	rabbitmqctl join_cluster --ram rabbit@$CLUSTERED_WITH
                	fi
                	rabbitmqctl start_app

		fi
	fi
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
}

function stop()
{
 	echo Stopping RabbitMQ...
        /usr/sbin/rabbitmqctl stop
	if [ -z "$TAIL_PID" ]; then
		kill -TERM $TAIL_PID
	fi
	echo Stopped!
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
