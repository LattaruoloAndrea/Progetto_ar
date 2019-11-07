producer(3).
producer_weight_tot(1,0;2,0;3,10;4,0).

#const number_consumer = 2.
consumer(1;2).
consumer_weight(1,10;2,5).

switch(4).
node(1..4).
edge(1,4;4,2;4,3;).
%edge(X,Y) :- edge(Y,X).

weights(X,Y,W) :- weights(Y,X,W).
weights(4,1,1;4,2,1;4,3,2;).
%weights of each arc (X,Y,weigh)

%use a switch just for one path
%check_switch(Z,U) :- switch(Z), U=1, U<=1.

%path(Y,Z) :- edge(Y,Z).
%path(X,Y) :- path(X,Z),check_switch(Z,U), path(Z,Y).

1{used_switch(S,X,Y)}1 :-switch(S),node(X),node(Y).
%1 {switch_used_only_once(S,X,Y)} 1:- used_switch(S,S,X,_),used_switch(S,S,Y,_).

producer_path(X,Y,T,K) :- edge(X,Y),producer_weight_tot(Y,T),weights(X,Y,K).
producer_path(X,Y,W+L,M+N) :- X!=Y,producer_path(X,Z,W,M),used_switch(Z,X,Y), producer_path(Z,Y,L,N).

check_weight(X,Y,T,W) :- consumer_weight(X,Z), producer_path(X,Y,T,W), Z<=T.

number_consumer {final_path(X,Y,T,P*P*L)} number_consumer :- consumer(X),producer(Y),check_weight(X,Y,T,L),consumer_weight(X,P).


consumer(X) :- final_path(X,Y,T,W).

min(X,F) :- final_path(X,_,_,_),#min{W : final_path(X,Y,T,W)} = F.

doom(X,Y,T,F) :- final_path(X,Y,T,F), min(X,F) .

%write minimize function should use aggregate function?
%#show producer_path/4.
%#show final_path/4.
#show doom/4.

%for the same value of X need to take the lowest W
