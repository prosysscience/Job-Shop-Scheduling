#program subproblem(t).

 seq(Oper1, (Job1, Step2), PT1, t) :-                        #(\label{prg:sub_pro:logic_seq:begin}#)
                  seqL(Oper1, (Job1, Step2), PT1),
                  Oper1 = (Job1, Step1),
                  assignTW(Job1, Step2, t),
                  assignTW(Job1, Step1, T), 
          T = #max{TT : assignTW(Job1, Step1, TT), TT <= t}. #(\label{prg:sub_pro:logic_seq:end}#)

{seq((Job1, Step1), (Job2, Step2), PT1, t)} :-               #(\label{prg:sub_pro:mach_same_W1:begin}#)
                  sameMach(Job1, Step1, Job2, Step2),
                  pro(Job1, Step1, PT1),
                  assignTW(Job1, Step1, t),
                  assignTW(Job2, Step2, t).                  #(\label{prg:sub_pro:mach_same_W1:end}#)

 seq((Job2, Step2), (Job1, Step1), PT2, t) :-                #(\label{prg:sub_pro:mach_same_W2:begin}#)
                  sameMach(Job1, Step1, Job2, Step2), 
                  pro(Job1, Step1, PT1),
                  pro(Job2, Step2, PT2), 
                  assignTW(Job1, Step1, t),
                  assignTW(Job2, Step2, t),
              not seq((Job1, Step1), (Job2, Step2), PT1, t). #(\label{prg:sub_pro:mach_same_W2:end}#)

 seq((Job1, Step1), (Job2, Step2), PT1, t) :-              #(\label{prg:sub_pro:mach_diff_W1:begin}#)
                  sameMach(Job1, Step1, Job2, Step2), 
                  pro(Job1, Step1, PT1),
                  assignTW(Job1, Step1, T),
                  assignTW(Job2, Step2, t),
              T = #max{TT : assignTW(Job, Step, TT), TT < t}. #(\label{prg:sub_pro:mach_diff_W1:end}#)

 seq((Job2, Step2), (Job1, Step1), PT2, t) :-                 #(\label{prg:sub_pro:mach_diff_W2:begin}#)
                  sameMach(Job1, Step1, Job2, Step2), 
                  pro(Job2, Step2, PT2),
                  assignTW(Job1, Step1, t),
                  assignTW(Job2, Step2, T),
              T = #max{TT : assignTW(Job, Step, TT), TT < t}. #(\label{prg:sub_pro:mach_diff_W2:end}#)
