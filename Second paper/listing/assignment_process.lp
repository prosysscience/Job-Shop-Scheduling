est(Job, 1, 0) :- operation(Job, 1).        #(\label{prg:assignment_process:est:begin}#)

est(Job, Step + 1, ST + PT) :- 
                 est(Job, Step, ST),
                 pro(Job, Step, PT),
                 operation(Job, Step + 1).  #(\label{prg:assignment_process:est:end}#)

index(Job, Step, N) :- est(Job, Step, ST),  #(\label{prg:assignment_process:rank:begin}#)
                       pro(Job, Step, PT),
            N = #count{Job1, Step1 : 
                       est(Job1, Step1, ST1),
                       pro(Job1, Step1, PT1),
                      (ST1, PT1, Step1, Job1) < 
                      (ST, PT, Step, Job)}.   #(\label{prg:assignment_process:rank:end}#)

assignTW(Job, Step, (N+M) / M) :- index(Job, Step, N), #(\label{prg:assignment_process:assign:begin}#)
                                  numOperTW(M).        #(\label{prg:assignment_process:assign:end}#)
