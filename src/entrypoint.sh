#!/bin/bash

set -m
/run/miscellaneous/restore_config.sh

# Run as user "elasticsearch" if the command is "elasticsearch"
if [ "$1" = 'elasticsearch' -a "$(id -u)" = '0' ]; then
	chown -R elasticsearch:elasticsearch /usr/share/elasticsearch/data
	set -- gosu elasticsearch "$@"
	ES_JAVA_OPTS="-Des.network.host=0.0.0.0 -Xms$HEAP_SIZE -Xmx$HEAP_SIZE" $@ &
else
	$@ &
fi

/run/miscellaneous/wait_until_started.sh

/run/user/elastic.sh
/run/user/kibana.sh
/run/user/logstash.sh
/run/user/beats.sh

fg