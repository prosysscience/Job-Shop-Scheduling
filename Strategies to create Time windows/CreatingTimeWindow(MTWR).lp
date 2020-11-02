#include "input.lp".

estimateRemainTime(JobNum, StepNum, ProTime)              :- operation(JobNum, StepNum), not operation(JobNum, StepNum + 1),
                                                             longestProTime(JobNum, StepNum, ProTime).
estimateRemainTime(JobNum, StepNum, RemainTime + ProTime) :- estimateRemainTime(JobNum, StepNum + 1, RemainTime),
                                                             longestProTime(JobNum, StepNum, ProTime).

index(JobNum, StepNum, N) :- estimateRemainTime(JobNum, StepNum, RemainTime),
                             longestProTime(JobNum, StepNum, ProTime),
                             N = #count{JobNum1, StepNum1 : estimateRemainTime(JobNum1, StepNum1, RemainTime1),
                                                            longestProTime(JobNum1, StepNum1, ProTime1),
                                                            (RemainTime1, ProTime1, StepNum1, JobNum1) > (RemainTime, ProTime, StepNum, JobNum)}.
