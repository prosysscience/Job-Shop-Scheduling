#program compress(window).

% use idle machines to reduce start times for operations in current time window

occupy(M,O,S,T,1,N,window) :- occupy(M,O,S,T,1,1,window-1),
                              current(N,window),
                              previous(O,window).
occupy(M,O,S,T,1,N,window) :- occupy(M,O,S,T,K,1,window-1),
                              occupy(M,O',S',T',K-1,1,window-1),
                              current(O',N',window),
                              current(N,window),
                              previous(O,window).
occupy(M,O,S,T,K,N,window) :- occupy(M,O,S,T,K',1,window-1),
                              occupy(M,O',S',T',K'-1,1,window-1),
                              occupy(M,O',S',T',K-1,N,window),
                              current(N,window).
occupy(M,0,0,0,K,N,window) :- occupy(M,0,0,0,K,N+1,window),
                              current(O,N,window),
                              assignment(O,M',P), M' != M.
occupy(M,O,S,T,K,N,window) :- insert(M,O,S,T,K-1,N+1,O',T',P,window).
occupy(M,O,S,T,1,N,window) :- insert(M,O',S',T1,1,N+1,O,T2,P,window),
                              S = (T1+T2+|T1-T2|)/2, T = S+P.
occupy(M,O,S,T,K,N,window) :- target(M,O',S',T',K-1,N+1,O,S,T,window).
occupy(M,O,S,T,K,N,window) :- target(M,O,S,T,K,N+1,O',S',T',window).
occupy(M,O,S,T,K,N,window) :- occupy(M,O,S,T,K,N+1,window), K' = K+1,
                              occupy(M,O',S',T',K',N+1,window),
                              occupy(M,O',S',T',K',N,window).

before((1,J),0,window) :- current((1,J),N,window).
before((I,J),T,window) :- current((I,J),N,window),
                          occupy(M,(I-1,J),S,T,K,N+1,window).

insert(M,0,0,0,K,N,O,T,P,window)     :- occupy(M,0,0,0,K,N,window),
                                        current(O,N-1,window),
                                        before(O,T,window),
                                        assignment(O,M,P).
insert(M,O',S',T',K,N,O,T2,P,window) :- occupy(M,O',S',T',K,N,window),
                                        insert(M,O1,S1,T1,K+1,N,O,T2,P,window),
                                        S = (T1+T2+|T1-T2|)/2, S' < S+P.

target(M,O',S',T',K,N,O,S,T,window) :- occupy(M,O',S',T',K,N,window),
                                       insert(M,O1,S1,T1,K+1,N,O,T2,P,window),
                                       S = (T1+T2+|T1-T2|)/2, T = S+P, T <= S'.

bound(1,T,window) :- occupy(1,O,S,T,1,1,window).
bound(M,T,window) :- occupy(M,O,S,T1,1,1,window),
                     bound(M-1,T2,window),
                     T = (T1+T2+|T1-T2|)/2.

start((I,J),S,window) :- occupy(M,(I,J),S,T,K,1,window).
