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
path(X,Y) :- weights(X,Y,_).
path(X,Y) :- X!=Y,path(X,Z),path(Z,Y).
%allow any combination of request to be created

:- S = #sum {E,C,P : select_request(C,P,E)},S!=W,consumer(K), consumer_weight(K,W).
%tolgo tutti i sottoinsiemi che hanno come somma per il consumatore diverso da quanto richiede

:- S = #count {P,C: select_request(C,P,E)},V = #count {P,E,C: select_request(C,P,E)},V!=S.
%tolgo tutti i sottoinsiemi cui P e' stato utilizzato piu di una volta per consumatore

1{select_switch(X,S,Y)} number_switch :- X!=Y,edge(X,S),edge(Y,S).
%allow any combination of switch's orientation to be created, I want exaclty number_switch literals 

%tolgo tutti i sottoinsiemi in cui uno switch e' stato utilizzato piu di una volta


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
%#show select_request/3.
#show select_switch/3.


%--------------------------------------------
%#show path/2.
%#show request/3.


%#show connected_switch/4.
%#show used_switch/1.
%#show final_pathh/3.
%#show su/1.
%#show path_new/3.
%#show path/2.
%#show producer_path/4.
%#show final_path/4.
%#show doom/4.

%for the same value of X need to take the lowest W