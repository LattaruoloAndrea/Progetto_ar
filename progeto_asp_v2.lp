%integer(1..38). % max number sum of each producer's weight

producer(2;3).
producer_weight_tot(1,0;2,10;3,30;4,0).

consumer(1).
consumer_weight(1,10).

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

producer_path(X,Y,T,K) :- edge(X,Y),producer_weight_tot(Y,T),weights(X,Y,K).
producer_path(X,Y,W+L,M+N) :- X!=Y,producer_path(X,Z,W,M), producer_path(Z,Y,L,N).

check_weight(X,Y,T,W) :- consumer_weight(X,Z), producer_path(X,Y,T,W), Z<=T.

final_path(X,Y,T,P*P*L) :- consumer(X),producer(Y),check_weight(X,Y,T,L),consumer_weight(X,P).

1 {doom(X,Y,T,F)} 1 :- final_path(X,Y,T,F), #min{W : final_path(X,Y,T,W)} = F.
%write minimize function should use aggregate function?

#show doom/4.

%for the same value of X need to take the lowest W
