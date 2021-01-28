% #include "input.lp".

machineTemp(Machine, 0) :- machine(Machine).
machineTemp(Machine, StartTime + ProTime) :- assignment(JobNum, StepNum, Machine, ProTime),
                                             startTime((JobNum, StepNum), StartTime).

machineFree(Machine, Time) :- machine(Machine),
                              Time = #max{Temp : machineTemp(Machine, Temp)}.

unscheduled(JobNum, StepNum) :- operation(JobNum, StepNum),
                                not startTime((JobNum, StepNum), _).

estimateStartTime(JobNum, StepNum, Time, 0) :- unscheduled(JobNum, StepNum),
                                               assignment(JobNum, StepNum, Machine, ProTime),
                                               machineFree(Machine, Time),
                                               not unscheduled(JobNum, StepNum-1).
estimateStartTime(JobNum, StepNum, Time, WaitTime + WaitTime1) :- estimateStartTime(JobNum, StepNum - 1, StartTime1, WaitTime1),
                                                                  longestProTime(JobNum, StepNum - 1, ProTime1),
                                                                  assignment(JobNum, StepNum, Machine, ProTime2),
                                                                  machineFree(Machine, Time2),
                                                                  Time1 = StartTime1 + ProTime1,
                                                                  WaitTime2 = Time2 - Time1,
                                                                  WaitTime = (WaitTime2 + |WaitTime2|) / 2,
                                                                  Time = Time1 + WaitTime.

estimateRemainTime(JobNum, StepNum, ProTime- WaitTime)    :- estimateStartTime(JobNum, StepNum, StartTime, WaitTime),
                                                             longestProTime(JobNum, StepNum, ProTime),
                                                             not operation(JobNum, StepNum + 1).
estimateRemainTime(JobNum, StepNum, RemainTime + ProTime) :- estimateRemainTime(JobNum, StepNum + 1, RemainTime),
                                                             longestProTime(JobNum, StepNum, ProTime),
                                                             unscheduled(JobNum, StepNum).

scheduled(M) :- M = #count{Operation : startTime(Operation, StartTime)}.

index(JobNum, StepNum, M + N) :- scheduled(M),
                                 estimateRemainTime(JobNum, StepNum, RemainTime),
                                 longestProTime(JobNum, StepNum, ProTime),
                                 N = #count{JobNum1, StepNum1 : estimateRemainTime(JobNum1, StepNum1, RemainTime1),
                                                                longestProTime(JobNum1, StepNum1, ProTime1),
                                                                (RemainTime1, ProTime1, StepNum1, JobNum1) > (RemainTime, ProTime, StepNum, JobNum)}.

% #show index/3.
% #show estimateRemainTime/3.
% #show estimateStartTime/4.
% #show machineFree/2.
% #show assignment(JobNum, StepNum, Machine, StartTime, ProTime, StartTime + ProTime) : assignment(JobNum, StepNum, Machine, ProTime), startTime((JobNum, StepNum), StartTime).
