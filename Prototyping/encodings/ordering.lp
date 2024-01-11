#program preorder(window).

% determine yet unscheduled and rescheduled operations

rescheduled(O,window) :- unscheduled(O,window).
rescheduled(O,window) :- overlap(O,window), est.

% determine earliest starting times of operations

earliest((0,J),0,0,0,window) :- rescheduled((1,J),window), est.
earliest((I,J),S,P,0,window) :- rescheduled((I+1,J),window),
                                scheduled((I,J),M,P,S), est.
earliest((I,J),S,P,U,window) :- rescheduled((I,J),window),
                                earliest((I-1,J),S1,P1,U1,window),
                                assignment((I,J),M,P), latest(M,T,window),
                                T1 = S1+P1, S = (T+T1+|T-T1|)/2, U = U1+S-T1.

% determine remaining processing times of operations

remaining(O,P,P-U,window)     :- earliest(O,S,P,U,window), last(O),
                                 unscheduled(O,window), mtwr.
remaining((I,J),P,P+U,window) :- earliest((I,J),S,P,U1,window),
                                 remaining((I+1,J),P1,U,window),
                                 unscheduled((I,J),window).

% candidate operations for time window(s)

preorder(O,S,P,window)  :- start(O,S,0), assignment(O,P),
                           unscheduled(O,window), not est.
preorder(O,S,P,window)  :- earliest(O,S,P,U,window),
                           unscheduled(O,window), not mtwr.
preorder(O,-U,P,window) :- remaining(O,P,U,window).

#program ordering(window).

% dynamically determine operations for time window

assign(O,window) :- ops_sort(O,N,window), window_now(window,N),
                    not bottleneck.

unscheduled(O,window+1) :- ops_sort(O,N,window), window_out(window,N),
                           not bottleneck.

% output predicates

%*
#show unscheduled/2.
#show rescheduled/2.
#show earliest/5.
#show remaining/4.
#show preorder/4.
#show ops_sort/3.
*%
