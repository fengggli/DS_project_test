#!/bin/bash
# create the results directory
RESULT_PATH=results
mkdir -pv ${RESULT_PATH}

SUMMARY_PATH=${RESULT_PATH}/summary.txt
rm -rf ${SUMMARY_PATH}

SLEEP_TIME=0.5
for NUM_PROCESS in 10 20 50 100 150 200
do
    echo 'process requests = '$NUM_PROCESS''
    TIME_PATH=${RESULT_PATH}/time_${NUM_PROCESS}.txt
    rm -f ${TIME_PATH}
    for i in `seq 1 $NUM_PROCESS`;
    do
        # collect timing of each user
        less logs/${NUM_PROCESS}_${i}_s_${SLEEP_TIME}.log |grep "#" | awk '{print $2}'>> ${TIME_PATH}
    done

    # write to the summary
    #awk '{sum+=$1}END{printf "N_process=%d\tSum=%d\tCount=%d\tAvg=%.2f\n",'$NUM_PROCESS',sum,NR,sum/NR}' ${TIME_PATH} >> ${SUMMARY_PATH}
    awk '{sum+=$1}END{printf "N_process=%d\tAvg=%.2f ms\n",'$NUM_PROCESS',sum/NR}' ${TIME_PATH} >> ${SUMMARY_PATH}
done
