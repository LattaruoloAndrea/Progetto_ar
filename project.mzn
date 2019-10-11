% Use this editor as a MiniZinc scratch book
%git add namefile
%git commit -m ""
%git push origin master
%git pull origin master

include "globals.mzn";
int: N; %number of nodes
int: NP; %number of producer
int: NC; %number of consumer
int: NS; %number of switch
array[1..N, 1..N] of 0..1: adj_mat;
array[1..N, 1..N] of float: w;
array[1..NP] of var int: pw;
array[1..NC] of var int: cw;
array[1..N,1..NC] of var 0..N: path;
array[1..NP] of var 0..1: p;
array[1..NC] of var 0..1: c;

array[1..NP] of int: pp;
array[1..NC] of int: cc;

array[1..N,1..N] of var 0..1: s;

NP = 2;
NC = 1;
NS =1;
N=4;
pw = [15,30];
cw = [10];
pp = [2,3];
cc = [1];
adj_mat = [|
    0, 0, 0, 1,|
    0, 0, 0, 1,|
    0, 0, 0, 1,|
    1, 1, 1, 0 |];
    
w = [|
    0, 0, 0, 1,|
    0, 0, 0, 0.8,|
    0, 0, 0, 1.5,|
    1, 0.8, 1.5, 0 |];

constraint forall(i in 1..NC)(c[i]>=1);

constraint alldifferent_except_0([path[i,j] |i in 1..N, j in 1..NC]);

predicate exists_path_length(int: s, int: t, int: len, int: pathindx) = 
          path[1,pathindx]=s /\ path[len,pathindx]=t /\ forall(i in len+1..N)(path[i,pathindx]=0) /\          
          forall(i in 1..len-1)( adj_mat[path[i,pathindx],path[i+1,pathindx]]=1);
          
predicate exists_path(int: s, int: t, int: pathindx) = exists(len in 2..N)(exists_path_length(s,t,len,pathindx));

constraint forall(j in 1..NC)(exists(i in 1..NP)(exists_path(cc[j],pp[i],j)));

solve satisfy;

output[show(path)];