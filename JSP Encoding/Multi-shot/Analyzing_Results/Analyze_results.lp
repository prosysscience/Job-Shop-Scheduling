% ************************************ Constants for configuring the overlap size ***********************

#const factor = 1.
#const divisor = 10.

% ************************************ Constant for configuring insertion into earlier windows **********

#const insert = 1.  % Set to 0 for disabling insertion of operations into gaps at earlier windows

% ************************************ Constants for configuring output of late operations **************

#const outE = 1.  % Show operations that could be inserted into earlier window by gap(earlier, X)
#const outC = 1.  % Show operations that could be put before in current window by gap(current, X)

% ************************************ Domain predicates for machine and operations *********************

numOfOperations(M1)  :- M1 = numOfJobs * numOfMachines.
timeWindow(TW)       :- assignToTimeWindow(JobNum, StepNum, TW).
numOfTimeWindows(TW) :- timeWindow(TW), not timeWindow(TW + 1).
numOfOperPerTWin(M2) :- numOfOperations(M1), numOfTimeWindows(TW), M2 = (M1 + TW - 1) / TW.

unassign(JobNum, StepNum, 1..TimeWindow - 1) :- assignToTimeWindow(JobNum, StepNum, TimeWindow).
assigned(JobNum, StepNum, TimeWindow..TW)    :- assignToTimeWindow(JobNum, StepNum, TimeWindow),
                                                numOfTimeWindows(TW).

available_for_schedule(JobNum, StepNum, TW) :- assignToTimeWindow(JobNum, StepNum, TW).
available_for_schedule(JobNum, StepNum, TW) :- overlappedOperation(JobNum, StepNum, TW).

proTime(JobNum, StepNum, ProTime) :- assignment(JobNum, StepNum, MachNum, ProTime).
assign(JobNum, StepNum, MachNum)  :- assignment(JobNum, StepNum, MachNum, ProTime).
machine(MachNum)                  :- assign(JobNum, StepNum, MachNum).

sameMach(JobNum1, StepNum1, JobNum2, StepNum2)     :- assign(JobNum1, StepNum1, MachNum),
                                                      assign(JobNum2, StepNum2, MachNum),
                                                      JobNum1 < JobNum2.
sameMach(JobNum1, StepNum1, JobNum2, StepNum2, TW) :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2),
                                                      available_for_schedule(JobNum1, StepNum1, TW),
                                                      available_for_schedule(JobNum2, StepNum2, TW).

duration(JobNum, StepNum, MachNum, ST, ET, TW) :- assignment(JobNum, StepNum, MachNum, ProTime),
                                                  startTime((JobNum, StepNum), ST, TW), ET = ST + ProTime.

available_machine(MachNum, TW, M) :- machine(MachNum),
                                     timeWindow(TW),
                                     M = #max{0; ET : duration(JobNum, StepNum, MachNum, ST, ET, TW-1),
                                                      not overlappedOperation(JobNum, StepNum, TW),
                                                      insert = 0}.

% ************************************ One start time from the assigned window on ***********************

bug(defined_ST, (JobNum, StepNum, TW)) :- unassign(JobNum, StepNum, TW),
                                          startTime((JobNum, StepNum), ST, TW).
bug(defined_ST, (JobNum, StepNum, TW)) :- assigned(JobNum, StepNum, TW),
                                          #count{ST : startTime((JobNum, StepNum), ST, TW)} != 1.

% ************************************ Start time of no-overlap operation persists **********************

bug(changed_ST, (JobNum, StepNum, ST1, TW1, ST2, TW2)) :- startTime((JobNum, StepNum), ST1, TW1), TW2 = TW1+1,
                                                          startTime((JobNum, StepNum), ST2, TW2), ST1 != ST2,
                                                          not overlappedOperation(JobNum, StepNum, TW2).

% ************************************ Start after operations of earlier windows ************************

bug(unavailable, (JobNum, StepNum, ST, MachNum, M, TW)) :- available_for_schedule(JobNum, StepNum, TW),
                                                           duration(JobNum, StepNum, MachNum, ST, ET, TW),
                                                           available_machine(MachNum, TW, M), ST < M.

% ************************************ Start after predecessor operation in job *************************

bug(consecutive, (JobNum, StepNum1, ST1, ET1, StepNum2, ST2, TW)) :- duration(JobNum, StepNum1, MachNum, ST1, ET1, TW),
                                                                     startTime((JobNum, StepNum2), ST2, TW),
                                                                     StepNum2 = StepNum1 + 1, ST2 < ET1.

% ************************************ Operations must not overlap on a machine *************************

bug(overlapping, (JobNum1, StepNum1, ST1, ET1, JobNum2, StepNum2, ST2, ET2, TW)) :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2, TW),
                                                                                    duration(JobNum1, StepNum1, MachNum, ST1, ET1, TW),
                                                                                    duration(JobNum2, StepNum2, MachNum, ST2, ET2, TW),
                                                                                    ST2 < ET1, ST1 < ET2.

% ************************************ Number of overlap operations *************************************

bug(number_OP, (TW, N)) :- timeWindow(TW), 1 < TW,
                           numOfOperPerTWin(M), O = factor * M / divisor,
                           N = #count{JobNum, StepNum : overlappedOperation(JobNum, StepNum, TW)}, N != O.

% ************************************ Overlap operation must be in earlier window **********************

bug(window_OP, (JobNum, StepNum, TW)) :- overlappedOperation(JobNum, StepNum, TW),
                                         not available_for_schedule(JobNum, StepNum, TW - 1).
bug(window_OP, (JobNum, StepNum, TW)) :- overlappedOperation(JobNum, StepNum, TW),
                                         numOfTimeWindows(NumTW), NumTW < TW.

% ************************************ Overlap operations follow start time order ***********************

bug(chosen_OP, (JobNum1, StepNum1, ST1, JobNum2, StepNum2, ST2)) :- duration(JobNum1, StepNum1, MachNum1, ST1, ET1, TW - 1),
                                                                    duration(JobNum2, StepNum2, MachNum2, ST2, ET2, TW - 1),
                                                                    (ST1, ET1 - ST1, StepNum1, JobNum1) < (ST2, ET2 - ST2, StepNum2, JobNum2),
                                                                    overlappedOperation(JobNum1, StepNum1, TW),
                                                                    not overlappedOperation(JobNum2, StepNum2, TW).

% ************************************ Check for operations starting later than needed ******************

end_time_machine(MachNum, TW, 0)  :- machine(MachNum),
                                     timeWindow(TW).
end_time_machine(MachNum, TW, ET) :- duration(JobNum, StepNum, MachNum, ST, ET, TW).

previous(MachNum, TW, ET1, ET2) :- end_time_machine(MachNum, TW, ET2), 0 < ET2,
                                   ET1 = #max{ET : end_time_machine(MachNum, TW, ET), ET < ET2}.

lower_bound(JobNum, 1, 0, TW)        :- available_for_schedule(JobNum, 1, TW).
lower_bound(JobNum, StepNum, ET, TW) :- available_for_schedule(JobNum, StepNum, TW),
                                        duration(JobNum, StepNum - 1, MachNum, ST, ET, TW).

bug(waiting, (JobNum, StepNum, ST, MachNum, TW)) :- available_for_schedule(JobNum, StepNum, TW),
                                                    duration(JobNum, StepNum, MachNum, ST, ET, TW),
                                                    not lower_bound(JobNum, StepNum, ST, TW),
                                                    not end_time_machine(MachNum, TW, ST).

insert(JobNum, StepNum, MachNum, ET - ST, LB, ST, TW)  :- duration(JobNum, StepNum, MachNum, ST, ET, TW),
                                                          lower_bound(JobNum, StepNum, LB, TW), LB < ST.
insert(JobNum, StepNum, MachNum, ProTime, LB, ST, TW)  :- before(JobNum, StepNum, MachNum, ProTime, LB, ST, IdleTime, TW),
                                                          IdleTime < ProTime, LB < ST.

before(JobNum1, StepNum1, MachNum, ProTime1, LB, ST, ST2 - ST, TW) :- insert(JobNum1, StepNum1, MachNum, ProTime1, LB, ET2, TW),
                                                                      duration(JobNum2, StepNum2, MachNum, ST2, ET2, TW), LB < ST2,
                                                                      previous(MachNum, TW, ET1, ET2), ET1 <= ST2,
                                                                      ST = (ET1 + LB + |ET1 - LB|)/2.

better(JobNum, StepNum, MachNum, ST, ProTime, OT, IdleTime, TW) :- before(JobNum, StepNum, MachNum, ProTime, LB, OT, IdleTime, TW),
                                                                   startTime((JobNum, StepNum), ST, TW),
                                                                   ProTime <= IdleTime.

gap(earlier, (JobNum, StepNum, ST, ProTime, MachNum, OT, IdleTime, TW)) :- better(JobNum, StepNum, MachNum, ST, ProTime, OT, IdleTime, TW),
                                                                           available_machine(MachNum, TW, M), OT < M.

gap(current, (JobNum, StepNum, ST, ProTime, MachNum, OT, IdleTime, TW)) :- better(JobNum, StepNum, MachNum, ST, ProTime, OT, IdleTime, TW),
                                                                           available_machine(MachNum, TW, M), M <= OT.

% ************************************ Output the bug/2 and gap/2 atoms *********************************

#show bug/2.
#show gap(earlier, X) : gap(earlier, X), outE = 1.
#show gap(current, X) : gap(current, X), outC = 1.
