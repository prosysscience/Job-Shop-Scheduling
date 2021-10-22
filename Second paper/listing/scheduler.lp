#program base.

seqL((Job1, Step1), (Job1, Step2), PT1)  :- pro(Job1, Step1, PT1), pro(Job1, Step2, PT2),
                                            Step2 = Step1 + 1.

sameMach(Job1, Step1, Job2, Step2) :- assign(Job1, Step1, MachNum),
                                      assign(Job2, Step2, MachNum),
                                      Job1 < Job2.

#program subproblem(t).

 seq(Oper1, (Job2, Step2), PT1, t) :- seqL(Oper1, (Job2, Step2), PT1),
                                      Oper1 = (Job1, Step1),
                                      assignTW(Job2, Step2, t),
                                      assignTW(Job1, Step1, T), T = #max{TT : assignTW(Job, Step, t), TT <= t}.

{seq((Job1, Step1), (Job2, Step2), PT1), t} :- sameMach(Job1, Step1, Job2, Step2),
                                               pro(Job1, Step1, PT1),
                                               assignTW(Job1, Step1, t),
                                               assignTW(Job2, Step2, t).

 seq((Job2, Step2), (Job1, Step1), PT2, t)  :- sameMach(Job1, Step1, Job2, Step2), pro(Job2, Step2, PT2), 
                                               assignTW(Job1, Step1, t),
                                               assignTW(Job2, Step2, t),
                                               not seqM((Job1, Step1), (Job2, Step2), PT1).

 seq((Job1, Step1), (Job2, Step2), PT1, t)  :- sameMach(Job1, Step1, Job2, Step2), pro(Job1, Step1, PT1),
                                               assignTW(Job1, Step1, T),
                                               assignTW(Job2, Step2, t),
                                               T = #max{TT : assignTW(Job, Step, TT), TT < t}.

 seq((Job2, Step2), (Job1, Step1), PT2, t)  :- sameMach(Job1, Step1, Job2, Step2), 
                                               assignTW(Job1, Step1, t),     pro(Job2, Step2, PT2),
                                           	   assignTW(Job2, Step2, T),
                                           	   T = #max{TT : assignTW(Job, Step, TT), TT < t}.

&diff{ 0 - (Job, Step) }  <= 0 :- operation(Job, Step), assignTW(Job, Step, t).

&diff{ Oper1 - Oper2 }    <= -PT :- seq(Oper1, Oper2, PT, t).

&diff{ 0 - (Job, Step) }  <= -ST :- startTime((Jobm, Step), ST),
                                    assignTW(Job, Step, T), T = #max{TT : assignTW(Job, Step, TT), TT < t}.

&diff{ (Job, Step) - 0 }  <= -ST :- startTime((Job, Step), ST),
                                    assignTW(Job, Step, T), T = #max{TT : assignTW(Job, Step, TT), TT < t}.

&diff{ (Job, Step) - bound} <= -PT :- operation(Job, Step), pro(Job, Step, PT),
                                     assignTW(Job, Step, t).

#program opt(b).
#external bound(b).
&diff{ bound  - 0 } 	<= b :- bound(b).