est(JobNum, 1, 0) :- operation(JobNum, 1).
est(JobNum, StepNum + 1, ST + PT) :- 
                 est(JobNum, StepNum, ST),
                 pro(JobNum, StepNum, PT),
                 operation(JobNum, StepNum + 1).  

index(JobNum, StepNum, N) :- est(JobNum, StepNum, ST), 
                pro(JobNum, StepNum, PT),
                N = #count{JobNum1, StepNum1 : 
                    est(JobNum1, StepNum1, ST1),
                    pro(JobNum1, StepNum1, PT1),
                    (ST1, PT1, StepNum1, JobNum1) < 
                    (ST, PT, StepNum, JobNum)}.  

assignTW(JobNum, StepNum, (N+M) / M) :- index(JobNum, StepNum, N),
                                                  numOperTW(M).  

#show assignTW/3.