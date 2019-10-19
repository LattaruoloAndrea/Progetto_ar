noninpath(0).

producer(2;3).
producer_weight(2,15;3,30).

consumer(1).
consumer_weight(1,10).

switch(4).

node(1..4).
edge(1,4;4,1;4,2;2,4;4,3;3,4).

weights(1,4,1;4,1,1;4,2,2;2,4,2;4,3,1;3,4,1).
%weights of each arc (X,Y,weigh)

check_switch(Z,U) :- switch(Z), U=1, U<=1.

path(Y,Z) :- edge(Y,Z).
path(Y,X) :- path(Y,Z),check_switch(Z,U), path(Z,X).

check_weight(X,Y) :- consumer_weight(X,Z), producer_weight(Y,W), Z<=W.

final_path(X,Y) :- consumer(X),producer(Y), path(X,Y),check_weight(X,Y).


#show final_path/2.