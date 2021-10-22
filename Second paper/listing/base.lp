#program base.

seqL((Job1, Step1), (Job1, Step2), PT1)  :-     #(\label{prg:base:same_job:begin}#)
                  pro(Job1, Step1, PT1), 
                  pro(Job1, Step2, PT2),
                  Step2 = Step1 + 1.            #(\label{prg:base:same_job:end}#)

sameMach(Job1, Step1, Job2, Step2) :-           #(\label{prg:base:sharing_machine:begin}#)
                  assign(Job1, Step1, MachNum),
                  assign(Job2, Step2, MachNum),
                  Job1 < Job2.                  #(\label{prg:base:sharing_machine:end}#)

