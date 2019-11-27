%project 1 minizinc
producer(2;3;4;5).
producer_weight_tot(1,0;2,5;3,5;4,1;5,1;6,0;7,0).

#const number_consumer = 1.
consumer(1).
consumer_weight(1,10).
energy(1,0..10).

#const number_switch = 2.
switch(6;7).
node(1..7).
integer(0..10).
edge(1,6;2,6;5,6;2,7;3,7;4,7).
%edge(X,Y):- edge(Y,X).

weights(1,6,1;2,6,2;5,6,1;2,7,1;3,7,3;4,7,4).
weights(X,Y,W) :- weights(Y,X,W).


request(C,P,E):- E!=0,consumer(C),producer(P),energy(C,E), E<=T,producer_weight_tot(P,T).
%creo tutte le richieste da un consumatore ad un produttore.

{select_request(C,P,E)}:- request(C,P,E),path(C,P).
%allow any combination of request to be created when there is a path

path(X,Y) :- select_switch(X,_,Y).
path(X,Y) :- X!=Y,select_switch(X,_,W),select_switch(W,_,Y).

:- S = #sum {E,C,P : select_request(C,P,E)},S!=W,W = #sum{V: consumer_weight(K,V)}.
%tolgo tutti i sottoinsiemi che hanno come somma per il consumatore diverso da quanto richiede

:- S = #count {P,C: select_request(C,P,E)},V = #count {P,E,C: select_request(C,P,E)},V!=S.
%tolgo tutti i sottoinsiemi cui P e' stato utilizzato piu di una volta per consumatore

connected_switch(X,S,Y) :- X!=Y,edge(X,S),edge(Y,S),switch(S).

{select_switch(X,S,Y)} number_switch :- connected_switch(X,S,Y).
%allow any combination of switch's orientation to be created, I want exaclty number_switch literals 

:- T = #count{S,X,Y: select_switch(X,S,Y)}, T!=number_switch.
:- L= #count{S: select_switch(X,S,Y)},L!=number_switch.
%tolgo tutti i sottoinsiemi che utilizzano gli switch più di una volta

switch_belong_to(S,C):-paths(C,S).
paths(C,S):-select_switch(C,S,_).
paths(C,S):-C!=W,select_switch(C,_,W),select_switch(W,S,_).

sum_weight(W,C) :- W=#sum{A+B,C : switch_belong_to(S,C),weights(X,S,A),weights(S,Y,B),select_switch(X,S,Y)},consumer(C).

dispersion(S):- S=#sum {F: F=M*W*W,sum_weight(M,C),consumer_weight(C,W)}.
%per ogni soluzione calcolo la dispersione

#minimize {W:dispersion(W)}.
%prendo la soluzione migliore

#show select_request/3.
#show select_switch/3.
#show path/2.
#show dispersion/1.