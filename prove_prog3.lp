%project 1 minizinc
producer(3;4).
producer_weight_tot(1,0;2,0;3,10;4,19;5,0;6,0).

#const number_consumer = 2.
consumer(1;2).
consumer_weight(1,10;2,20).
energy(1,0..10;2,0..20).

#const number_switch = 2.
switch(5;6).
node(1..6).
edge(1,5;3,5;5,6;2,6;6,5;4,6).
%edge(X,Y):-edge(Y,X).

weights(1,5,1;3,5,2;5,6,1;4,6,1;6,5,1;6,2,4).
weights(X,Y,W) :- weights(Y,X,W).

request(C,P,E):- E!=0,consumer(C),producer(P),energy(C,E), E<=T,producer_weight_tot(P,T).
%creo tutte le richieste da un consumatore ad un produttore.

{select_request(C,P,E)}:- request(C,P,E),path(C,P).
%allow any combination of request to be created when there is a path

path(X,Y) :- select_switch(X,_,Y).
path(X,Y) :- X!=Y,select_switch(X,_,W),select_switch(W,_,Y).

%% devo creare gruppi con richieste solo per consumatori ? ?
%% e poi fare la somma ?

:- S = #sum {E,C,P : select_request(C,P,E),consumer(C)},S!=W,W = #sum{V: consumer_weight(K,V)}.
%tolgo tutti i sottoinsiemi che hanno come somma per il consumatore diverso da quanto richiesto

:- S = #count {P,C: select_request(C,P,E)},V = #count {P,E,C: select_request(C,P,E)},V!=S.
%tolgo tutti i sottoinsiemi cui P e' stato utilizzato piu di una volta per consumatore

connected_switch(X,S,Y) :- X!=Y,edge(X,S),edge(Y,S),switch(S).

{select_switch(X,S,Y)} number_switch :- connected_switch(X,S,Y).
%allow any combination of switch's orientation to be created, I want exaclty number_switch literals 

:- T = #count{S,X,Y: select_switch(X,S,Y)}, T!=number_switch.
:- L= #count{S: select_switch(X,S,Y)},L!=number_switch.
%tolgo tutti i sottoinsiemi che utilizzano gli switch più di una volta


%------------------------------------------------------------


%1 {pathh(C,P)} 1 :- #sum {E : path(C,P),select_request(C,P,E)} = S,path(C,P), S==W, consumer_weight(C,W).
%
%new_edge(X,Y,K) :- connected_switch(S,X,Y,K),used_switch(S).
%new_edge(X,Y,K) :- new_edge(Y,X,K).
%path_new(X,Y,K) :- new_edge(X,Y,K).
%path_new(X,Y,K+P) :- X!=Y,path_new(X,Z,K), path_new(Z,Y,P),integer(K),integer(P).

%final_pathh(X,Y,K) :- path_new(X,Y,K), pathh(X,Y),consumer(X),producer(Y).

%connected_switch(S,X,Y,P+K) :- X!=Y,S!=X,S!=Y,switch(S), weights(S,X,P),weights(S,Y,K).

%1{used_switch(S)}1 :- switch(S).

%path(X,Y) :- weights(X,Y,_), producer_weight_tot(Y,_).
%path(X,Y) :- X!=Y,path(X,Z),path(Z,Y).

%check_weight(X,Y,W,T) :- consumer_weight(X,Z), path_new(X,Y,T,W), Z<=W.

%number_consumer {final_path(X,Y,T,P*P*L)} number_consumer :- consumer(X),producer(Y),check_weight(X,Y,T,L),consumer_weight(X,P).

%min(X,F) :- final_path(X,_,_,_),#min{W : final_path(X,Y,T,W)} = F.

%doom(X,Y,T,F) :- final_path(X,Y,T,F), min(X,F).

%write minimize function should use aggregate function?
#show select_request/3.
%#show select_switch/3.
%#show path/2.

%--------------------------------------------

%for the same value of X need to take the lowest W