assignToTimeWindow(JobNum, StepNum, M) :- index(JobNum, StepNum, N), operationWindow(M, N).

#show assignToTimeWindow/3.
