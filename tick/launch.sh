#!/bin/sh
# arguments:
#  - tickerplant port
#  - rdb port
#  - hdb port
#  - rts port

TPP=${1:-5000}
HDBP=${2:-5001}
RDBP=${3:-5002}
RTSP=${4:-5003}

echo TP port: $TPP
echo HDB port: $HDBP
echo RDB port: $RDBP
echo RTS port: $RTSP

kill_processes() {
    echo "Killing all processes"
    kill -9 $TP_JOB $HDB_JOB $RDB_JOB $RTS_JOB $FEED_JOB
    echo "Done!"
    exit 0
}

start_processes() {
    echo "Starting tickerplant..."
    q tick.q sym db -p $1 &
    TP_JOB=$!
    echo TP job: $TP_JOB
    
    echo "Starting HDB..."
    q hdb.q db/sym -p $2 &
    HDB_JOB=$!
    echo HDB job: $HDB_JOB

    echo "Starting RDB..."
    q tick/r.q localhost:$1 localhost:$2 -p $3 &
    RDB_JOB=$!
    echo RDB job $RDB_JOB
    
    # echo "Starting real time subscriber..."
    # q rts.q localhost:$1 -p $4 &
    # RTS_JOB=$!
    # echo RTS job $RTS_JOB

    echo "Starting feedhandler..."
    2>/dev/null 1>&2 python3 feed.py --host localhost --port $1 &
    FEED_JOB=$!
    echo Feed job $FEED_JOB

    trap "kill_processes" INT
}

start_processes $TPP $HDBP $RDBP $FEED_JOB # $RTSP

while [ true ]; do
    sleep 2
done