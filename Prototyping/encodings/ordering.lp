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

assign(O,window) :- ops_sort(O,N,window),
                    window_now(window,N),
                    not bottleneck.
assign(O,window) :- mps_sort(O,N,window),
                    window(window).

unscheduled(O,window+1)     :- ops_sort(O,N,window),
                               window_out(window,N),
                               not bottleneck.
unscheduled((I,J),window+1) :- ops_sort((I,J),M,P,NM,K,window),
                               gather(M',L,(I',J),P',NM',A,K,window), I' < I,
                               mps_next(N',K,window), N = N'+A,
                               window_size(window,N+1).
unscheduled((I,J),window+1) :- ops_sort((I,J),M,P,NM,K,window),
                               gather(M',L,(I',J'),P',NM',A,K,window), J != J',
                               mps_next(N',K,window), N = N'+A,
                               window_size(window,N+1).

% refine the operation order by bottleneck machines

assign(O) :- assign(O,window-1),
             bottleneck.

loaded(M,L,N,window)   :- loaded(M,L,0,window-1),
                          window_size(window-1,N).
loaded(M,L-P,N,window) :- loaded(M,L,N+1,window),
                          mps_sort(O,N,window-1),
                          assignment(O,M,P).
loaded(M,L,N,window)   :- loaded(M,L,N+1,window),
                          mps_sort(O,N,window-1),
                          assignment(O,M',P), M != M'.

refine(M,L,0,window)   :- loaded(M,L,0,window), 0 < L.
refine(M,L,N+1,window) :- refine(M,L,N,window),
                          ops_sort(O,N,window),
                          assignment(O,M',P), M != M'.
refine(M,L,N+1,window) :- refine(M,L,N,window),
                          gather(M,L',O,P,N,K,window), L < L'.
refine(M,L,N+1,window) :- refine(M,L',N,window),
                          gather(M,L',O,P,N,K-1,window),
                          mps_next(N',K,window),
                          L = L'-P, 0 < L.
refine(M,L-P,N,window) :- refine(M,L,N,window),
                          gather(M,L,O,P,NM,K-1,window), N < NM,
                          mps_next(N',K,window).

differ(M,L,A,K,window) :- reduce(M,L,K-1,window),
                          gather(M',L',O,P,N',A,K-1,window), M != M',
                          mps_next(O,N,K,window).
differ(M,L,A,K,window) :- differ(M,L,A+1,K,window),
                          gather(M',L',O,P,N',A,K-1,window), M != M'.

reduce(M,L,0,window) :- loaded(M,L,0,window).
reduce(M,L,K,window) :- differ(M,L,0,K,window).
reduce(M,L,K,window) :- gather(M,L',O,P,N',K-1,window), L = L'-P,
                        mps_next(N,K,window).

reduce(M,M,L,K,window)   :- reduce(M,L,K,window),
                            machines(M).
reduce(M,M,L,K,window)   :- reduce(M,L,K,window),
                            reduce(M+1,M',L',K,window), L' < L.
reduce(M,M',L',K,window) :- reduce(M,L,K,window),
                            reduce(M+1,M',L',K,window), L <= L'.

ops_sort(O,M,P,N,0,window)     :- assignment(O,M,P),
                                  ops_sort(O,N,window),
                                  bottleneck.
ops_sort((I,J),M,P,N,K,window) :- ops_sort((I,J),M,P,N,K-1,window),
                                  mps_next((I',J),N',K,window), I' < I.
ops_sort((I,J),M,P,N,K,window) :- ops_sort((I,J),M,P,N,K-1,window),
                                  mps_next((I',J'),N',K,window), J != J'.

select(M,L,O,P,N,K,window) :- refine(M,L,N,window),
                              ops_sort(O,M,P,N,K,window),
                              reduce(1,M,L,K,window).

gather(M,L,O,P,N,K,window)     :- select(M,L,O,P,N,K,window).
gather(M,L,(I,J),P,N,K,window) :- reduce(M,L,K,window),
                                  ops_sort((I,J),M,P,N,K,window),
                                  gather(M',L',(I+1,J),P',N',K,window).

gather(M,L,(1,J),P,N,0,K,window) :- gather(M,L,(1,J),P,N,K,window).
gather(M,L,(I,J),P,N,0,K,window) :- gather(M,L,(I,J),P,N,K,window),
                                    assign((I-1,J)).
gather(M,L,O,P,N,0,K,window)     :- gather(M,L,O,P,N,K,window),
                                    gather(O,K,window).
gather(M,L,(I,J),P,N,A,K,window) :- gather(M,L,(I,J),P,N,K,window),
                                    gather(M',L',(I-1,J),P',N',A-1,K,window).

gather(O,K,window)     :- ops_sort(O,M,P,N,K,window),
                          gather(O,K-1,window).
gather((I,J),K,window) :- mps_next((I-1,J),N,K,window),
                          operation((I,J)).

mps_next(O,N,K,window) :- select(M,L,O,P,NM,K-1,window),
                          mps_sort(O,N-1,window),
                          window_now(window,N).

mps_next(0,0,window) :- reduce(1,M,L,0,window).
mps_next(N,K,window) :- mps_next(O,N,K,window).

mps_sort(O,N,window) :- gather(M,L,O,P,NM,A,K,window),
                        mps_next(N',K,window), N = N'+A,
                        window_now(window,N).

% output predicates

%*
#show unscheduled/2.
#show rescheduled/2.
#show earliest/5.
#show remaining/4.
#show preorder/4.
#show assign/1.
#show refine/4.
#show differ/5.
#show reduce/4.
#show reduce/5.
#show ops_sort/6.
#show select/7.
#show gather/7.
#show gather/8.
#show gather/3.
*%
