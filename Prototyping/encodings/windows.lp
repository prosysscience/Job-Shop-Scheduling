% configuration constants

#const windows = 1. % number of time windows

#const ordering = 1.   % 1: EST; 2: MTWR; other: start time of a given schedule
#const bottleneck = 0. % 1: order by bottleneck machines; other: ignore machines

#const compress = 1. % 1: activate compression; other: deactivate compression

#const factor = 0.   % numerator of overlapping ratio
#const divisor = 10. % denominator of overlapping ratio

% determine width of time windows

job(J)  :- assignment(J,I,M,P).
jobs(J) :- job(J), not job(J+1).

machine(M)  :- assignment(J,I,M,P).
machines(M) :- machine(M), not machine(M+1).

assignment((I,J),M,P) :- assignment(J,I,M,P).
assignment(O,P)       :- assignment(O,M,P).
operation(O)          :- assignment(O,P).
unscheduled(O,0..1)   :- operation(O).
operations(N)         :- N = #count{O : operation(O)}.

windows(W)   :- operations(N), W = (N+windows-|N-windows|)/2.
window(1..W) :- windows(W).

window_size(N/W) :- operations(N), windows(W).
window_fill(N\W) :- operations(N), windows(W).

overlap_size(K) :- window(2), window_size(H),
                   K = (H*factor + divisor-1)/divisor, 0 < K.
overlap_none    :- windows(W), W < 2.
overlap_none    :- window_size(H), (H*factor + divisor-1)/divisor <= 0.

window_last(0,0).
window_last(W,L) :- window(W), window_size(H), window_fill(F),
                    L = W*H + (W+F-|W-F|)/2.

window(W,K,L)  :- window_last(W-1,K), window_last(W,L+1).
window(W,K..L) :- window(W,K,L).

window_size(W,L-K+1) :- window(W,K,L).

window_late(W,0)   :- windows(W).
window_late(W,M+N) :- window(W), window_size(W+1,M), window_late(W+1,N).

window_now(W,0..M)     :- window_size(W,M+1).
window_out(W,M..M+N-1) :- window_size(W,M), window_late(W,N).

overlap_add(2,N) :- window(2), window_size(1,M), overlap_size(K),
                    N = (M+K-|M-K|)/2.
overlap_add(W,N) :- window(W), window_size(W-1,M), overlap_size(K),
                    overlap_add(W-1,A), L = M+A, N = (L+K-|L-K|)/2.

overlap_now(W,0..N)   :- overlap_add(W,N+1).
overlap_out(2,N..M)   :- overlap_add(2,N), window_size(1,M+1).
overlap_out(W,N..M+A) :- overlap_add(W,N), window_size(W-1,M+1),
                         overlap_add(W-1,A).
overlap_out(W,N)      :- window_now(W,N), overlap_none.

% auxiliary predicates

mtwr :- ordering = 2.
est  :- ordering = 1.
est  :- mtwr.

bottleneck :- bottleneck = 1.

compress :- compress = 1.

upper :- ordering != 0, not est, not bottleneck.

upper(O,M,S) :- assignment(O,M,P), start(O,S,0), upper.

last((I,J)) :- operation((I,J)), not operation((I+1,J)).

% next((I,J),(I+1,J)) :- operation((I,J)), not last((I,J)).
% next((I,J),(1,J+1)) :- last((I,J)), not jobs(J).

latest(M,0,0) :- machine(M).

loaded(M,L,0,0..1) :- machine(M), bottleneck,
                      L = #sum+{P,O : assignment(O,M,P)}.

#program static.

% statically determine operations for time windows

mps_next(M,O,N,K,0) :- select(M,L,O,P,NM,K-1,0),
                       mps_sort(O,N-1,0),
                       window(W,N).

mps_sort(O,N,0) :- gather(M,L,O,P,NM,A,K,0),
                   mps_next(N',K,0), N = N'+A.

assign(O,W) :- ops_sort(O,N,0), window(W,N), not bottleneck.
assign(O,W) :- mps_sort(O,N,0), window(W,N).

unscheduled(O,W) :- assign(O,W), 1 < W.
unscheduled(O,W) :- unscheduled(O,W+1), 1 < W.

% output predicates

#show assign/2.

%*
#show job/1.
#show jobs/1.
#show machine/1.
#show machines/1.
#show assignment/3.
#show assignment/2.
#show operation/1.
#show unscheduled/2.
#show operations/1.
#show windows/1.
#show window/1.
#show window_size/1.
#show window_fill/1.
#show overlap_size/1.
#show overlap_none/0.
#show window_last/2.
#show window/3.
#show window_size/2.
#show window_late/2.
#show window_now/2.
#show window_out/2.
#show overlap_add/2.
#show overlap_now/2.
#show overlap_out/2.
#show mtwr/0.
#show est/0.
#show bottleneck/0.
#show compress/0.
#show upper/0.
#show upper/3.
#show ups_sort/3.
#show last/1.
#show latest/3.
#show loaded/4.
#show mps_next/5.
#show mps_next/3.
#show mps_sort/3.
#show ops_sort/3.
*%
