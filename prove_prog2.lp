%project 1 minizinc
producer(3).
producer_weight_tot(1,0;2,0;3,15;4,0).

#const number_consumer = 2.
consumer(1;2).
consumer_weight(1,10;2,5).
energy(1,0..10;2,0..5).

#const number_switch = 1.
switch(4).
node(1..4).
edge(1,4;2,4;3,4).
%edge(X,Y):- edge(Y,X).

weights(1,4,1;2,4,2;3,4,3).
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