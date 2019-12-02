producer(2;3;4;5;6;7;8;9).
producer_weight_tot(1, 0; 2, 19; 3, 36; 4, 55; 5, 81; 6, 83; 7, 90; 8, 40; 9, 89; 10, 0; 11, 0; 12, 0).
#const number_consumer = 1.
consumer(1).
consumer_weight(1, 51).
energy(1,0..51).
#const number_switch = 3.
switch(10;11;12).
edge(1, 10; 3, 10; 11, 10; 4, 11; 5, 11; 10, 11; 2, 12; 4, 12; 7, 12; ).
weights(1, 10, 8; 3, 10, 8; 4, 11, 9; 5, 11, 2; 10, 11, 7; 2, 12, 8; 4, 12, 2; 7, 12, 6; ).
weights(X,Y,W) :- weights(Y,X,W).

%un producer non puo essere richiesto dallo stesso consumer piu di una volta
%uno stesso consumer non puo fare richieste diverse allo stesso producer
:- S = #sum{W,P : select_request(C,P,_),producer_weight_tot(P,W)}, T = #sum{W,P,C : select_request(C,P,_),producer_weight_tot(P,W)},S!=T.
%tolgo le richieste da un consumatore ad uno stesso produttore

request(C,P,E):- E!=0,consumer(C),producer(P),energy(C,E), E<=T,producer_weight_tot(P,T).
%creo tutte le richieste da un consumatore ad un produttore.

{select_request(C,P,E)}:- request(C,P,E),path(C,P).
%allow any combination of request to be created when there is a path

path(X,Y) :- select_switch(X,_,Y).
path(X,Y) :- X!=Y,select_switch(X,_,W),select_switch(W,_,Y).
path(X,Y) :- X!=Y,select_switch(X,_,W),select_switch(_,W,Y).
%caso in cui connetto due switch

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
%cerco quali switch collegano quale consumer
paths(C,S):-select_switch(C,S,_).
paths(C,S):-C!=W,select_switch(C,_,W),select_switch(W,S,_).

sum_weight(W,C) :- W=#sum{A+B,C : switch_belong_to(S,C),weights(X,S,A),weights(S,Y,B),select_switch(X,S,Y)},consumer(C).
%sommo gli archi in ogni cammino consumer

dispersion(S):- S=#sum {F: F=M*W*W,sum_weight(M,C),consumer_weight(C,W)},S!=0.
%per ogni soluzione calcolo la dispersione

#minimize {W:dispersion(W)}.
%prendo la soluzione migliore

#show select_request/3.
#show select_switch/3.
#show path/2.
#show dispersion/1.