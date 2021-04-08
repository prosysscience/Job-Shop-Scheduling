#const factor = 3.
#const divisor = 10.

numOfOperations(M1)  :- M1 = numOfJobs * numOfMachines.
numOfTimeWindows(TW) :- TW = #max{TimeWindow : assignToTimeWindow(JobNum, StepNum, TimeWindow)}.
numOfOperPerTWin(M2) :- numOfOperations(M1), numOfTimeWindows(TW), M2 = (M1 + TW - 1) / TW.


operation(JobNum, StepNum) 	:- assignment(JobNum, StepNum, MachNum, ProTime).
proTime(JobNum, StepNum, ProTime) :- assign(JobNum, StepNum, MachNum), assignment(JobNum, StepNum, MachNum, ProTime).
assign(JobNum, StepNum, MachNum)  :- assignment(JobNum, StepNum, MachNum, ProTime), operation(JobNum, StepNum).

sameMach(JobNum1, StepNum1, JobNum2, StepNum2) :- assign(JobNum1, StepNum1, MachNum),
                                                  assign(JobNum2, StepNum2, MachNum),
                                                  JobNum1 < JobNum2.

% ************************************ One start time from the assigned window on ***********************

bug(st, (JobNum, StepNum, TW)) :- assignToTimeWindow(JobNum, StepNum, TimeWindow), 
                               TW = 1..TimeWindow-1, startTime((JobNum, StepNum), ST, TW).

bug(st, (JobNum, StepNum, TW)) :- assignToTimeWindow(JobNum, StepNum, TimeWindow), numOfTimeWindows(NumTimeWindow),
                               TW = TimeWindow..NumTimeWindow, #count{ST : startTime((JobNum, StepNum), ST, TW)} != 1.

% ************************************ First Check in Matrin's email ************************************

bug(changed_ST, (JobNum, StepNum, ST1, TW1, ST2, TW2)) :- startTime((JobNum, StepNum), ST1, TW1),
                                                          startTime((JobNum, StepNum), ST2, TW2), TW2 = TW1+1, ST1 != ST2,
                                                    not overlappedOperation(JobNum, StepNum, TW2).

% ************************************ Second Check in Matrin's email ************************************

bug(chosen_op, (JobNum1, StepNum1, ST1, JobNum2, StepNum2, ST2)) :- startTime((JobNum1, StepNum1), ST1, TW - 1), proTime(JobNum1, StepNum1, ProTime1),
                                                                    startTime((JobNum2, StepNum2), ST2, TW - 1), proTime(JobNum2, StepNum2, ProTime2),
                                                                    (ST1, ProTime1, StepNum1, JobNum1) < (ST2, ProTime2, StepNum2, JobNum2),
                                                                    overlappedOperation(JobNum1, StepNum1, TW),
                                                                    not overlappedOperation(JobNum2, StepNum2, TW).

% ************************************ Size of overlap must fit ************************************

bug(number_op, (1,N))  :- N = #count{JobNum, StepNum : overlappedOperation(JobNum, StepNum, 1)}, N != 0.
bug(number_op, (TW,N)) :- numOfTimeWindows(NumTW), TW = 2..NumTW,
                          numOfOperPerTWin(M), O = factor * M / divisor,
                          N = #count{JobNum, StepNum : overlappedOperation(JobNum, StepNum, TW)}, N != O.

% ************************************ Third Check in Matrin's email ************************************
available_for_schedule(JobNum, StepNum, TW) :- assignToTimeWindow(JobNum, StepNum, TW).
available_for_schedule(JobNum, StepNum, TW) :- overlappedOperation(JobNum, StepNum, TW).

machine(MachNum) :- assign(JobNum, StepNum, MachNum).

available_machine(MachNum, TW, M) :- machine(MachNum), numOfTimeWindows(NumTW), TW = 1..NumTW,
                                     M = #max{0; ST + ProTime : startTime((JobNum, StepNum), ST, TW-1),
                                                            proTime(JobNum, StepNum, ProTime),
                                                            assign(JobNum, StepNum, MachNum),
                                                        not overlappedOperation(JobNum, StepNum, TW)}.

bug(unavailable, (JobNum, StepNum, ST, TW, MachNum, M)) :- available_for_schedule(JobNum, StepNum, TW), assign(JobNum, StepNum, MachNum),
                                                           available_machine(MachNum, TW, M), startTime((JobNum, StepNum), ST, TW), ST < M.


bug(consecutive, (JobNum, StepNum1, ST1, ProTime1, StepNum2, ST2, TW)) :- startTime((JobNum, StepNum1), ST1, TW),
                                                                          startTime((JobNum, StepNum2), ST2, TW), StepNum2 = StepNum1 + 1,
                                                                          proTime(JobNum, StepNum1, ProTime1), ST2 < ST1 + ProTime1.


bug(overlap, (JobNum1, StepNum1, ST1, ProTime1, JobNum2, StepNum2, ST2, ProTime2, MachNum, TW)) :-
                 available_for_schedule(JobNum1, StepNum1, TW),
                 available_for_schedule(JobNum2, StepNum2, TW), JobNum1 < JobNum2,
                 assign(JobNum1, StepNum1, MachNum), 
                 assign(JobNum2, StepNum2, MachNum),
                 startTime((JobNum1, StepNum1), ST1, TW),
                 startTime((JobNum2, StepNum2), ST2, TW),
                 proTime(JobNum1, StepNum1, ProTime1),
                 proTime(JobNum2, StepNum2, ProTime2),
                 ST2 < ST1 + ProTime1,
                 ST1 < ST2 + ProTime2.



#show bug/2.