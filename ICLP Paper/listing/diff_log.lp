&diff{ 0 - Op } <= -ST :- startTime(Op, ST, t-1). #(\label{prg:diff_log:freez1:begin}#) #(\label{prg:diff_log:freez1:end}#)
&diff{ Op - 0 } <=  ST :- startTime(Op, ST, t-1). #(\label{prg:diff_log:freez2:begin}#) #(\label{prg:diff_log:freez2:end}#)

&diff{ 0 - (Job, Step) } <= 0 :- window(Job, Step, t). #(\label{prg:diff_log:non_nega:begin}#) #(\label{prg:diff_log:non_nega:end}#)

&diff{ Op1 - Op2 } <= -PT :- seq(Op1, Op2, PT, t). #(\label{prg:diff_log:oper_const:begin}#)

&diff{ (Job, Step) - bound } <= -PT :- pro(Job, Step, PT), #(\label{prg:diff_log:oper_limit:begin}#)
                                       window(Job, Step, t). #(\label{prg:diff_log:oper_limit:end}#)

#program opt(b).
#external bound(b).                                           #(\label{prg:diff_log:oper_min:begin}#)

&diff{ bound - 0 } <= b :- bound(b).                     #(\label{prg:diff_log:oper_min:end}#)