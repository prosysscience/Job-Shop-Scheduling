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

estimateRemainTime(JobNum, StepNum, ProTime)              :- operation(JobNum, StepNum), not operation(JobNum, StepNum + 1),
                                                             longestProTime(JobNum, StepNum, ProTime).
estimateRemainTime(JobNum, StepNum, RemainTime + ProTime) :- estimateRemainTime(JobNum, StepNum + 1, RemainTime),
                                                             longestProTime(JobNum, StepNum, ProTime).

index(JobNum, StepNum, N) :- estimateRemainTime(JobNum, StepNum, RemainTime),
                             longestProTime(JobNum, StepNum, ProTime),
                             N = #count{JobNum1, StepNum1 : estimateRemainTime(JobNum1, StepNum1, RemainTime1),
                                                            longestProTime(JobNum1, StepNum1, ProTime1),
                                                            (RemainTime1, ProTime1, StepNum1, JobNum1) > (RemainTime, ProTime, StepNum, JobNum)}.

assignToTimeWindow(JobNum, StepNum, (N+M) / M) :- index(JobNum, StepNum, N), numOfOperPerTWin(M).

#show assignToTimeWindow/3.
%#show index/3.
%#show estimateRemainTime/3.