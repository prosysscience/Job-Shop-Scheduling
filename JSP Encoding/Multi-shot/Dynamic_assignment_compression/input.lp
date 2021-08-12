#const numOfTimeWindows = 2.
timeWindows(1..numOfTimeWindows).

job      (JobNum)          :- operation (JobNum, StepNum).
step     (StepNum)         :- operation (JobNum, StepNum).
machine  (MachNum)         :- assignment(JobNum, StepNum, MachNum, ProTime).
operation(JobNum, StepNum) :- assignment(JobNum, StepNum, MachNum, ProTime).

numOfJobs(JobNum)      :- job(JobNum), not job(JobNum + 1).
numOfMachines(MachNum) :- machine(MachNum), not machine(MachNum + 1).

numOfOperations(M1)  :- numOfJobs(JobNum), numOfMachines(MachNum), M1 = JobNum * MachNum.
numOfOperPerTWin(M2) :- numOfOperations(M1), M2 = M1 / numOfTimeWindows.

timeWindowsToFill(M) :- numOfOperations(M1), M = M1 \ numOfTimeWindows.
timeWindowsLast(N,M) :- timeWindows(N), timeWindowsToFill(M1), numOfOperPerTWin(M2), M = N * M2 + (N + M1 - |N - M1|) / 2.

operationWindow(1,0..M)   :- timeWindowsLast(1,M+1).
operationWindow(N,M1..M2) :- timeWindowsLast(N-1,M1), timeWindowsLast(N,M2+1).

longestProTime(JobNum, StepNum, LongestProTime) :- operation(JobNum, StepNum),
                                                   LongestProTime = #max{ProTime : assignment(JobNum, StepNum, MachNum, ProTime)}.
