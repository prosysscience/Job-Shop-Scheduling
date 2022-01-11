est(Job, 1, 0) :- operation(Job, 1).        #(\label{prg:assignment_process:est:begin}#)

est(Job, Step, ST + PT) :- est(Job, Step - 1, ST),
                           pro(Job, Step - 1, PT),
                           operation(Job, Step).  #(\label{prg:assignment_process:est:end}#)

index(Job, Step, M) :- est(Job, Step, ST),  #(\label{prg:assignment_process:rank:begin}#)
                       pro(Job, Step, PT),
   M = #count{J', S' : est(J', S', ST'),
                       pro(J', S', PT'),
     (ST', PT', S', J') < (ST, PT, Step, Job)}.   #(\label{prg:assignment_process:rank:end}#)

window(Job, Step, (M+N) / N) :- index(Job, Step, M), #(\label{prg:assignment_process:assign:begin}#)
                                numOpsTW(N).        #(\label{prg:assignment_process:assign:end}#)
