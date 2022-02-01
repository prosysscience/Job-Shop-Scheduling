#const n = 2.  
width((N + n - 1) / n) :- N = #count{J,S : operation(J,S,M,P)}. 

est(J,1,P,0)      :- operation(J,1,M,P).        
est(J,S,P,P' + T) :- operation(J,S,M,P), est(J,S - 1,P',T).  

index(J,S,N) :- est(J,S,P,T),  
         N = #count{J',S' : est(J',S',P',T'), (T',P',J') < (T,P,J)}.   

window(J,S,(N + W) / W) :- index(J,S,N), width(W). 

