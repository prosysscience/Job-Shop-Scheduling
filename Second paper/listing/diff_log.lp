&diff{ 0 - (Job, Step) } <= 0 :- operation(Job, Step),        #(\label{prg:diff_log:non_nega:begin}#)
                                 assignTW(Job, Step, t).      #(\label{prg:diff_log:non_nega:end}#)

&diff{ 0 - (Job, Step) } <= -ST :-                            #(\label{prg:diff_log:freez1:begin}#)
                            startTime((Job, Step), ST, t-1).  #(\label{prg:diff_log:freez1:end}#)

&diff{ (Job, Step) - 0 } <=  ST :-                            #(\label{prg:diff_log:freez2:begin}#)
                            startTime((Job, Step), ST, t-1).  #(\label{prg:diff_log:freez2:end}#)

&diff{ Oper1 - Oper2 }   <= -PT :- seq(Oper1, Oper2, PT, t).  #(\label{prg:diff_log:oper_const:begin}#)


&diff{ (Job, Step) - bound} <= -PT :- pro(Job, Step, PT),     #(\label{prg:diff_log:oper_limit:begin}#)
                                      assignTW(Job, Step, t). #(\label{prg:diff_log:oper_limit:end}#)

#program opt(b).
#external bound(b).                                           #(\label{prg:diff_log:oper_min:begin}#)
&diff{ bound  - 0 } 	<= b :- bound(b).                     #(\label{prg:diff_log:oper_min:end}#)