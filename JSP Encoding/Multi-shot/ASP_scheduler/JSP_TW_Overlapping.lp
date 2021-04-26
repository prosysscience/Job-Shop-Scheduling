#const factor = 3.
#const divisor = 10.

#const insert = 0. % change to enable inserting operations into gaps at earlier windows

#program base.

job 	 (JobNum) 			:- operation (JobNum, StepNum).
step 	 (StepNum) 			:- operation (JobNum, StepNum).
machine  (MachNum) 			:- assignment(JobNum, StepNum, MachNum, ProTime).
operation(JobNum, StepNum) 	:- assignment(JobNum, StepNum, MachNum, ProTime).

free(MachNum, 0, 0) :- machine(MachNum).

numOfOperations(M1) 		:- M1 = numOfJobs * numOfMachines.
numOfTimeWindows(TW)		:- TW = #max{TimeWindow : assignToTimeWindow(JobNum, StepNum, TimeWindow)}.
numOfOperPerTWin(M2) 		:- numOfOperations(M1), numOfTimeWindows(TW), M2 = (M1 + TW - 1) / TW.

% *********************************************** To define each operation is assigned to which a machine ********************************************
% {assign(JobNum, StepNum, MachNum) : assignment(JobNum, StepNum, MachNum, ProTime)} = 1 :- operation(JobNum, StepNum).
assign(JobNum, StepNum, MachNum) :- assignment(JobNum, StepNum, MachNum, ProTime), operation(JobNum, StepNum).
% *********************************************** To define each operation is assigned to which a machine ********************************************

% ************************************************* To define the processing time for each operation *************************************************
proTime(JobNum, StepNum, ProTime) 			   :- assign(JobNum, StepNum, MachNum), assignment(JobNum, StepNum, MachNum, ProTime).
% ************************************************* To define the processing time for each operation *************************************************

% ************************************** To Determine the logical dependency for all operations in the same Job **************************************
 seqL((JobNum1, StepNum1), (JobNum1, StepNum2), ProTime1)  :- proTime(JobNum1, StepNum1, ProTime1), proTime(JobNum1, StepNum2, ProTime2),
 															  StepNum2 = StepNum1 + 1.
% ************************************** To Determine the logical dependency for all operations in the same Job **************************************

% ************************************************************ To Get The Maximum Horizon ************************************************************
% maxTime1 (TotalTime) 		:- TotalTime = #sum {ProTime, JobNum, StepNum, MachNum : assignment(JobNum, StepNum, MachNum, ProTime)}.
% ************************************************************ To Get The Maximum Horizon ************************************************************

% ***************************************** To Detect Which Operations are performed with the Same Machine *******************************************
sameMach(JobNum1, StepNum1, JobNum2, StepNum2) :- assign(JobNum1, StepNum1, MachNum),
                                                  assign(JobNum2, StepNum2, MachNum),
                                                  JobNum1 < JobNum2.

% ***************************************** To Detect Which Operations are performed with the Same Machine *******************************************
#program subproblem(t).

% ****************************************************** Overlapping Part *******************************************************

previous(JobNum, StepNum, t) :- assignToTimeWindow(JobNum, StepNum, t-1).
previous(JobNum, StepNum, t) :- overlappedOperation(JobNum, StepNum, t-1).

index(JobNum1, StepNum1, N, t) :- startTime((JobNum1, StepNum1), StartTime1, t-1),
                                  proTime   (JobNum1, StepNum1,  ProTime1),
                                  previous  (JobNum1, StepNum1,  t),
                                  N = #count{JobNum2, StepNum2 : startTime((JobNum2, StepNum2), StartTime2, t-1),
				                                 proTime   (JobNum2, StepNum2,  ProTime2),
				                                 previous  (JobNum2, StepNum2,  t),
							         (StartTime1, ProTime1, StepNum1, JobNum1) < (StartTime2, ProTime2, StepNum2, JobNum2)}.

overlappedOperation(JobNum, StepNum, t) :- index(JobNum, StepNum, N, t), numOfOperPerTWin(M), N < (factor * M / divisor).
no_overlapOperation(JobNum, StepNum, t) :- index(JobNum, StepNum, N, t), numOfOperPerTWin(M), (factor * M / divisor) <= N.

current(JobNum, StepNum, t) :- assignToTimeWindow(JobNum, StepNum, t).
current(JobNum, StepNum, t) :- overlappedOperation(JobNum, StepNum, t).

scheduled(JobNum, StepNum, t) :- no_overlapOperation(JobNum, StepNum, t), insert != 0.
scheduled(JobNum, StepNum, t) :- scheduled(JobNum, StepNum, t-1).

% ****************************************************** Machine availabilities *******************************************************

free(MachNum, 0,    t) :- machine(MachNum), insert != 0.
free(MachNum, Time, t) :- machine(MachNum), insert = 0,
                          free(MachNum, Time1, t-1), 
                          Time2 = #max{0;
                                       StartTime + ProTime : startTime((JobNum, StepNum), StartTime, t-1),
                                                             assignment(JobNum, StepNum,  MachNum, ProTime),
                                                 no_overlapOperation(JobNum, StepNum,  t)},
                          Time = (Time1 + Time2 + |Time1 - Time2|) / 2.

% *************** To Make the order for operations of the same job **********

seq(Operation1, (JobNum2, StepNum2), ProTime1, t) :- seqL(Operation1, (JobNum2, StepNum2), ProTime1),
                                                    assignToTimeWindow(JobNum2, StepNum2, t).

% *************** To Make the order which operation should be performed first, if I have Operations should be performed on the same machine **********

guess(JobNum1, StepNum1, JobNum2, StepNum2, t) :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2),
                                                   current(JobNum1, StepNum1, t),
                                        assignToTimeWindow(JobNum2, StepNum2, t).
guess(JobNum1, StepNum1, JobNum2, StepNum2, t) :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2),
                                        assignToTimeWindow(JobNum1, StepNum1, t),
                                       overlappedOperation(JobNum2, StepNum2, t).
guess(JobNum1, StepNum1, JobNum2, StepNum2, t) :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2),
                                                 scheduled(JobNum1, StepNum1, t),
                                        assignToTimeWindow(JobNum2, StepNum2, t).
guess(JobNum1, StepNum1, JobNum2, StepNum2, t) :- sameMach(JobNum1, StepNum1, JobNum2, StepNum2),
                                        assignToTimeWindow(JobNum1, StepNum1, t),
                                                 scheduled(JobNum2, StepNum2, t).               

{order(JobNum1, StepNum1, JobNum2, StepNum2, t)} :- guess(JobNum1, StepNum1, JobNum2, StepNum2, t).
 order(JobNum2, StepNum2, JobNum1, StepNum1, t)  :- guess(JobNum1, StepNum1, JobNum2, StepNum2, t),
                                                not order(JobNum1, StepNum1, JobNum2, StepNum2, t).

seq((JobNum1, StepNum1), (JobNum2, StepNum2), ProTime1, t) :- order(JobNum1, StepNum1, JobNum2, StepNum2, t),
                                                            proTime(JobNum1, StepNum1, ProTime1).

% ************************ Fix start times for non-overlapped operations from previous time window ************************

&diff{  0 - (JobNum, StepNum)  } <= -StartTime :- startTime((JobNum, StepNum), StartTime, t-1), 
                                                  no_overlapOperation(JobNum, StepNum, t).

&diff{  (JobNum, StepNum) - 0  } <=  StartTime :- startTime((JobNum, StepNum), StartTime, t-1), 
                                                  no_overlapOperation(JobNum, StepNum, t).

output(JobNum, StepNum, StartTime) :- startTime((JobNum, StepNum), StartTime, t-1), no_overlapOperation(JobNum, StepNum, t).

% ************************ Range of start times for current operations ************************

&diff{  0 - (JobNum, StepNum)  } <= -Time :- free(MachNum, Time, t),
                                             assignment(JobNum, StepNum, MachNum, ProTime), 
                                             current(JobNum, StepNum, t).

% &diff{  (JobNum, StepNum) - 0  } <= TotalTime :- maxTime1(TotalTime),
%                                                  assignToTimeWindow(JobNum, StepNum, t).

% ****************************************************** Propagate start times by order of operations *******************************************************

&diff{ Operation1 - Operation2 } <= -ProTime1 :- seq(Operation1, Operation2, ProTime1, t).


% ****************************************************** To minimize the total Completion Time *******************************************************

&diff{ (JobNum, StepNum) - bound } <= -ProTime :- proTime(JobNum, StepNum, ProTime),
                                       assignToTimeWindow(JobNum, StepNum, t).

#program opt(b).
#external bound(b).
&diff{ bound - 0} <= b :- bound(b).

#show.
#show overlappedOperation/3.
%#show no_overlapOperation/3.
%#show index/4.
%#show previous/3.
%#show assignToTimeWindow/3.
%#show no_overlapOperation/3.
%#show bound/1.
%#show output/3.
%#show startTime/3.
%#show free/3.
%#show numOfOperPerTWin/1.
% #show maxTime1/1.
