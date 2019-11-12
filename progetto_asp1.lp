producer(3).
producer_weight_tot(1,0;2,0;3,10;4,0).

#const number_consumer = 2.
consumer(1;2).
consumer_weight(1,10;2,5).

switch(4).
node(1..4).
edge(1,4;4,2;4,3;).
edge(X,Y):-edge(Y,X).

weights(X,Y,W) :- weights(Y,X,W).
weights(4,1,1;4,2,1;4,3,2;).

1{ used_switch(S,X,Y,K+P,N+M)} number_switch :- X!=Y, switch(S), weights(X,S,K), weights(Y,S,P), producer_weight_tot(X,N),producer_weight_tot(Y,M).

path_new(X,Y,K,P) :- used_switch(_,X,Y,K,P).
path_new(X,Y,K+N,P+M-U) :- X!=Y,path_new(X,Z,_,_), path_new(Z,Y,_,_),used_switch(_,X,Z,K,P),used_switch(_,Y,Z,N,M), producer_weight_tot(Z,U).

path(X,Y) :- weights(X,Y,_), producer_weight_tot(Y,_).
path(X,Y) :- X!=Y,path(X,Z),path(Z,Y).

check_weight(X,Y,W,T) :- consumer_weight(X,Z), path_new(X,Y,T,W), Z<=W.

number_consumer {final_path(X,Y,T,P*P*L)} number_consumer :- consumer(X),producer(Y),check_weight(X,Y,T,L),consumer_weight(X,P).

min(X,F) :- final_path(X,_,_,_),#min{W : final_path(X,Y,T,W)} = F.

doom(X,Y,T,F) :- final_path(X,Y,T,F), min(X,F).

%write minimize function should use aggregate function?
%#show used_switch/5.
%#show path_new/4.
%#show path/2.
%#show producer_path/4.
%#show final_path/4.
#show doom/4.

%for the same value of X need to take the lowest W