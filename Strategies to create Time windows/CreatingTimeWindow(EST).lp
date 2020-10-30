#const numOfJobs = 4.
#const numOfMachines = 3.
#const numOfTimeWindows =2.
timeWindows(1..numOfTimeWindows).

job 	 (JobNum) 			      :- operation (JobNum, StepNum).
step 	 (StepNum) 			      :- operation (JobNum, StepNum).
machine  (MachNum) 			    :- assignment(JobNum, StepNum, MachNum, ProTime).
operation(JobNum, StepNum) 	:- assignment(JobNum, StepNum, MachNum, ProTime).



numOfOperations(M1) 		:- M1 = numOfJobs * numOfMachines.
numOfOperPerTWin(M2) 		:- numOfOperations(M1), M2 = (M1 + numOfTimeWindows - 1) / numOfTimeWindows.

longestProTime(JobNum, StepNum, LongestProTime) :- operation(JobNum, StepNum),
                                                   LongestProTime = #max{ProTime : assignment(JobNum, StepNum, MachNum, ProTime)}.

estimateStartTime(JobNum, 1, 0)                             :- operation(JobNum, 1).
estimateStartTime(JobNum, StepNum + 1, StartTime + ProTime) :- estimateStartTime(JobNum, StepNum, StartTime),
                                                               longestProTime(JobNum, StepNum, ProTime),
                                                               operation(JobNum, StepNum + 1).

index(JobNum, StepNum, N) :- estimateStartTime(JobNum, StepNum, StartTime),
                             longestProTime(JobNum, StepNum, ProTime),
                             N = #count{JobNum1, StepNum1 : estimateStartTime(JobNum1, StepNum1, StartTime1),
                                                            longestProTime(JobNum1, StepNum1, ProTime1),
                                                            (StartTime1, ProTime1, StepNum1, JobNum1) < (StartTime, ProTime, StepNum, JobNum)}.

assignToTimeWindow(JobNum, StepNum, (N+M) / M) :- index(JobNum, StepNum, N), numOfOperPerTWin(M).

#show assignToTimeWindow/3.