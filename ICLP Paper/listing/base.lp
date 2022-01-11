#program base.

seq((Job, Step - 1), (Job, Step), PT, W) :-     #(\label{prg:base:same_job:begin}#)
                  pro(Job, Step - 1, PT), 
                  window(Job, Step, W).         #(\label{prg:base:same_job:end}#)

seq((Job1, Step1), (Job2, Step2), PT, W) :-
                  assign(Job1, Step1, Machine),
                  assign(Job2, Step2, Machine),
                  pro(Job1, Step1, PT),
                  window(Job1, Step1, V),
                  window(Job2, Step2, W),
    V = #max{W' : assign(J', S', Machine),
                  window(J', S', W'), W' < W}.

sameTW((Job1, Step1), (Job2, Step2), PT, W) :-  #(\label{prg:base:sharing_machine:begin}#)
                  assign(Job1, Step1, Machine),
                  assign(Job2, Step2, Machine),
                  window(Job1, Step1, W),
                  window(Job2, Step2, W),
                  pro(Job1, Step1, PT),
                  Job1 < Job2.                  #(\label{prg:base:sharing_machine:end}#)

#program subproblem(t).

{seq(Op1, Op2, PT, t)} :-
                  sameTW(Op1, Op2, PT, t).

seq(Op2, Op1, PT2, t) :-
                  sameTW(Op1, Op2, PT1, t),
                  pro(Job2, Step2, PT2),
                  Op2 = (Job2, Step2),
                  not seq(Op1, Op2, PT1, t).