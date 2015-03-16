#!/bin/bash
set -e
ulimit -n 1024

HOSTNAME=$(hostname)
pid_file=/storage/mnesia/rabbit\@$HOSTNAME.pid
log_file=/storage/log/rabbit\@$HOSTNAME.log

function run_cmd()
{
        su rabbitmq -s /bin/sh -c "$1"
}

function start()
{
	mkdir -p /storage/log
	touch $log_file
	/usr/sbin/rabbitmq-server &

	echo Waiting for RabbitMQ to start...
	while [ ! -f $pid_file ]; do 
		sleep 1
		echo Waiting for pid file...
	done
	pid=`cat $pid_file`
	echo pid file detected, waiting for pid $pid to start...
	while [ ! kill -0 $pid > /dev/null 2>&1 ]; do
		sleep 1
		echo Waiting for Process to start...
	done 

	echo "Started (pid: $pid)! Tailing $log_file"
	tail -f $log_file &
	tail_pid=$!

	# Setup clustering..
	if [ ! -z "$clustered_with" ]; then
		if ! rabbitmqctl cluster_status | grep -q $clustered_with; then
			rabbitmqctl stop_app
			rabbitmqctl reset
			if [ -z "$ram_node" ]; then
                        	rabbitmqctl join_cluster rabbit@$clustered_with
                	else
                        	rabbitmqctl join_cluster --ram rabbit@$clustered_with
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
	if [ -z "$tail_pid" ]; then
		kill -TERM $tail_pid
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
