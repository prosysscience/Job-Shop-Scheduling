 #include "input.lp".

machineTemp(Machine, 0) :- machine(Machine).
machineTemp(Machine, StartTime + ProTime) :- assignment(JobNum, StepNum, Machine, ProTime),
                                             startTime((JobNum, StepNum), StartTime).
% to get when the Macine is free
machineFree(Machine, Time) :- machine(Machine),
                              Time = #max{Temp : machineTemp(Machine, Temp)}.
% To detect in this time which operations are not scheduled yet
unscheduled(JobNum, StepNum) :- operation(JobNum, StepNum),
                                not startTime((JobNum, StepNum), _).
% calaulate the estimate strating time of first operations on the next Time Window
estimateStartTime(JobNum, StepNum, Time) :- unscheduled(JobNum, StepNum),
                                            assignment(JobNum, StepNum, Machine, ProTime),
                                            machineFree(Machine, Time),
                                            not unscheduled(JobNum, StepNum-1).
% calculate estimate strating time of other operations which is max (machine free, finishing time of pre-operation)
estimateStartTime(JobNum, StepNum, Time) :- estimateStartTime(JobNum, StepNum - 1, StartTime1),
                                            longestProTime(JobNum, StepNum - 1, ProTime1),
                                            assignment(JobNum, StepNum, Machine, ProTime2),
                                            machineFree(Machine, Time2),
                                            Time1 = StartTime1 + ProTime1,
                                            Time = (Time1 + Time2 + |Time1 - Time2|) / 2.

scheduled(M) :- M = #count{Operation : startTime(Operation, StartTime)}.

index(JobNum, StepNum, M + N) :- scheduled(M),
                                 estimateStartTime(JobNum, StepNum, StartTime),
                                 longestProTime(JobNum, StepNum, ProTime),
                                 N = #count{JobNum1, StepNum1 : estimateStartTime(JobNum1, StepNum1, StartTime1),
                                                                longestProTime(JobNum1, StepNum1, ProTime1),
                                                                (StartTime1, ProTime1, StepNum1, JobNum1) < (StartTime, ProTime, StepNum, JobNum)}.

% #show index/3.
% #show estimateStartTime/3.
% #show machineFree/2.
% #show assignment(JobNum, StepNum, Machine, StartTime, ProTime, StartTime + ProTime) : assignment(JobNum, StepNum, Machine, ProTime), startTime((JobNum, StepNum), StartTime).
% #show unscheduled/2.