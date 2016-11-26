#!/bin/bash
SUMMARY_PATH=summary.txt
rm -rf ${SUMMARY_PATH}

SLEEP_TIME=0.5
for NUM_PROCESS in '100'
do
TIME_PATH=time_${NUM_PROCESS}.txt
rm -rf ${TIME_PATH}

    for i in `seq 1 $NUM_PROCESS`;
    do
        # collect timing of each user
        less logs/${NUM_PROCESS}_${i}_s_${SLEEP_TIME}.log |grep "#" | awk '{print $2}'>> ${TIME_PATH}
    done

    # write to the summary
    awk '{sum+=$1}END{printf "N_process='$NUM_PROCESS'\tSum=%d\tCount=%d\tAve=%.2f\n",sum,NR,sum/NR}' ${TIME_PATH} >> ${SUMMARY_PATH}
done
