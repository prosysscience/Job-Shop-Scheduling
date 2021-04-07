#const factor = 3.
#const divisor = 10.
%*
changedST(JobNum, StepNum, ST1, TW1, ST2, TW2) :- startTime((JobNum, StepNum), ST1, TW1), startTime((JobNum, StepNum), ST2, TW2), ST1 < ST2, TW1 < TW2,
												  not overlappedOperation(JobNum, StepNum, _).
*%
numOfOperations(M1) 		:- M1 = numOfJobs * numOfMachines.
numOfTimeWindows(TW)		:- TW = #max{TimeWindow : assignToTimeWindow(JobNum, StepNum, TimeWindow)}.
numOfOperPerTWin(M2) 		:- numOfOperations(M1), numOfTimeWindows(TW), M2 = (M1 + TW - 1) / TW.


operation(JobNum, StepNum) 	:- assignment(JobNum, StepNum, MachNum, ProTime).
proTime(JobNum, StepNum, ProTime) :- assign(JobNum, StepNum, MachNum), assignment(JobNum, StepNum, MachNum, ProTime).
assign(JobNum, StepNum, MachNum)  :- assignment(JobNum, StepNum, MachNum, ProTime), operation(JobNum, StepNum).

sameMach(JobNum1, StepNum1, JobNum2, StepNum2) :- assign(JobNum1, StepNum1, MachNum),
                                                  assign(JobNum2, StepNum2, MachNum),
                                                  JobNum1 < JobNum2.

% ************************************ One start time from the assigned window on ***********************

bug_ST(JobNum, StepNum, TW) :- assignToTimeWindow(JobNum, StepNum, TimeWindow), 
                               TW = 1..TimeWindow-1, startTime((JobNum, StepNum), ST, TW).
% bug(st,(JobNum, StepNum, TW)) :- assignToTimeWindow(JobNum, StepNum, TimeWindow), 
%                                  TW = 1..TimeWindow-1, startTime((JobNum, StepNum), ST, TW).
bug_ST(JobNum, StepNum, TW) :- assignToTimeWindow(JobNum, StepNum, TimeWindow), numOfTimeWindows(NumTimeWindow),
                               TW = TimeWindow..NumTimeWindow, #count{ST : startTime((JobNum, StepNum), ST, TW)} != 1.

% ************************************ First Check in Matrin's email ************************************
changed_ST(JobNum, StepNum, ST1, TW1, ST2, TW2) :- startTime((JobNum, StepNum), ST1, TW1),
                                                   startTime((JobNum, StepNum), ST2, TW2), TW2 = TW1+1, ST1 != ST2,
                                                   not overlappedOperation(JobNum, StepNum, TW2).
% bug(changed_ST,(JobNum, StepNum, ST1, TW1, ST2, TW2)) :- startTime((JobNum, StepNum), ST1, TW1),
%                                                    startTime((JobNum, StepNum), ST2, TW2), TW2 = TW1+1, ST1 != ST2,
%                                                    not overlappedOperation(JobNum, StepNum, TW2).

% ************************************ Second Check in Matrin's email ************************************
bug_chosen_op(JobNum1, StepNum1, ST1, JobNum2, StepNum2, ST2) :- startTime((JobNum1, StepNum1), ST1, TW - 1), proTime(JobNum1, StepNum1, ProTime1),
                                                                 startTime((JobNum2, StepNum2), ST2, TW - 1), proTime(JobNum2, StepNum2, ProTime2),
                                                                 (ST1, ProTime1, StepNum1, JobNum1) < (ST2, ProTime2, StepNum2, JobNum2),
								 overlappedOperation(JobNum1, StepNum1, TW),
						             not overlappedOperation(JobNum2, StepNum2, TW).

% ************************************ Size of overlap must fit ************************************

bug_number_op(1,N)  :- N = #count{JobNum, StepNum : overlappedOperation(JobNum, StepNum, 1)}, N != 0.
bug_number_op(TW,N) :- numOfTimeWindows(NumTW), TW = 2..NumTW,
                       numOfOperPerTWin(M), O = factor * M / divisor,
                       N = #count{JobNum, StepNum : overlappedOperation(JobNum, StepNum, TW)}, N != O.

% ************************************ Third Check in Matrin's email ************************************
available_for_schedule(JobNum, StepNum, TW) :- assignToTimeWindow(JobNum, StepNum, TW).
available_for_schedule(JobNum, StepNum, TW) :- overlappedOperation(JobNum, StepNum, TW).

machine(MachNum) :- assign(JobNum, StepNum, MachNum).

available_machine(MachNum, TW, M) :- machine(MachNum), numOfTimeWindows(NumTW), TW = 1..NumTW,
                                     #max{0; ST + ProTime : startTime((JobNum, StepNum), ST, TW-1),
                                                            proTime(JobNum, StepNum, ProTime),
                                                            assign(JobNum, StepNum, MachNum),
                                                        not overlappedOperation(JobNum, StepNum, TW)}.

bug_unavailable(JobNum, StepNum, ST, TW, MachNum, M) :- available_for_schedule(JobNum, StepNum, TW), assign(JobNum, StepNum, MachNum),
                                                        available_machine(MachNum, TW, M), startTime((JobNum, StepNum), ST, TW), ST < M.

%*
bug(consecutive,(JobNum, StepNum1, ST1, ProTime1, StepNum2, ST2, TW)) :- startTime((JobNum, StepNum1), ST1, TW),
                                                                         startTime((JobNum, StepNum2), ST2, TW), StepNum2 = StepNum1 + 1,
                                                                         proTime(JobNum, StepNum1, ProTime1), ST2 < ST1 + ProTime1.


bug(overlap,(JobNum1, StepNum1, ST1, ProTime1, JobNum2, StepNum2, ST2, ProTime2, MachNum, TW)) :-
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
%*

% ****************************************************************************************************


%*
bug_sameJob(JobNum, StepNum1, ST1, StepNum2, ST2) :- available_for_schedule(JobNum, StepNum2, TW2), 
													 available_for_schedule(JobNum, StepNum1, TW1),
													 startTime((JobNum, StepNum2), ST2, TW2), not overlappedOperation(JobNum, StepNum1, TW2),
													 startTime((JobNum, StepNum1), ST1, TW1), proTime(JobNum, StepNum1, ProTime1),
													 TW1 = TW2 - 1, StepNum2 = StepNum1 + 1, ST2 < ST1 + ProTime1.


bug_sameMach(JobNum1, StepNum1, ST1, JobNum2, StepNum2, ST2) :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2),
																available_for_schedule(JobNum1, StepNum1, TW1), startTime((JobNum1, StepNum1), ST1, TW1),
				  												available_for_schedule(JobNum2, StepNum2, TW2), startTime((JobNum2, StepNum2), ST2, TW2),
				  												not overlappedOperation(JobNum1, StepNum1, TW2),
																proTime(JobNum1, StepNum1, ProTime1), TW1 < TW2, ST2 < ST1 + ProTime1.

bug_sameMach(JobNum1, StepNum1, ST1, JobNum2, StepNum2, ST2) :- sameMach(JobNum2, StepNum2, JobNum1, StepNum1),
																available_for_schedule(JobNum1, StepNum1, TW1), startTime((JobNum1, StepNum1), ST1, TW1),
				  												available_for_schedule(JobNum2, StepNum2, TW2), startTime((JobNum2, StepNum2), ST2, TW2),
				  												not overlappedOperation(JobNum1, StepNum1, TW2),
																proTime(JobNum1, StepNum1, ProTime1), TW1 < TW2, ST2 < ST1 + ProTime1.
*%

%#show bug_overlapped/3.
%#show expected_overlapped_number/2.
%#show expected_overlapped/3.
#show changed_ST/6.
#show bug_sameJob/5.
#show bug_sameMach/6.
#show bug_chosen_op/6.
%*
expected_overlapped_number(TW, N) :- assignToTimeWindow(JobNum, StepNum, TW-1),
									 N = #count{expected_overlapped(JobNum, StepNum, TW) : assignment(JobNum, StepNum, _, _)}.


previous(JobNum, StepNum, TW) :- assignToTimeWindow(JobNum, StepNum, TW - 1).
previous(JobNum, StepNum, TW) :- expected_overlapped(JobNum, StepNum, TW - 1).

index(JobNum1, StepNum1, N, TW) :- startTime((JobNum1, StepNum1), StartTime1, TW-1), TW = 2,
                                   proTime   (JobNum1, StepNum1,  ProTime1),
                                   previous  (JobNum1, StepNum1,  TW),
                                   N = #count{JobNum2, StepNum2 : startTime((JobNum2, StepNum2), StartTime2, TW-1),
				                                 proTime   (JobNum2, StepNum2,  ProTime2),
				                                 previous  (JobNum2, StepNum2,  TW),
							         (StartTime1, ProTime1, StepNum1, JobNum1) < (StartTime2, ProTime2, StepNum2, JobNum2)}.

expected_overlapped(JobNum, StepNum, TW) :- index(JobNum, StepNum, N, TW), numOfOperPerTWin(M), N < (factor * M / divisor).

*%
%bug_overlapped(JobNum, StepNum, TW) :- expected_overlapped(JobNum, StepNum, TW), not overlappedOperation(JobNum, StepNum, TW), TW = 2.