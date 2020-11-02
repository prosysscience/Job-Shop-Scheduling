#include "input.lp".

estimateStartTime(JobNum, 1, 0)                             :- operation(JobNum, 1).
estimateStartTime(JobNum, StepNum + 1, StartTime + ProTime) :- estimateStartTime(JobNum, StepNum, StartTime),
                                                               longestProTime(JobNum, StepNum, ProTime),
                                                               operation(JobNum, StepNum + 1).

index(JobNum, StepNum, N) :- estimateStartTime(JobNum, StepNum, StartTime),
                             longestProTime(JobNum, StepNum, ProTime),
                             N = #count{JobNum1, StepNum1 : estimateStartTime(JobNum1, StepNum1, StartTime1),
                                                            longestProTime(JobNum1, StepNum1, ProTime1),
                                                            (StartTime1, ProTime1, StepNum1, JobNum1) < (StartTime, ProTime, StepNum, JobNum)}.
