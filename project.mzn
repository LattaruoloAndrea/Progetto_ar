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
var int: cost; %cost total

array[1..N, 1..N] of 0..1: adj_mat;
array[1..N, 1..N] of int: w; % archs weights 
array[1..N] of var int: pt;
array[1..NP] of var int: pw; % producer weights
array[1..NC] of var int: cw; % consumer wights
array[1..NC,1..N] of var 0..N: path;

array[1..NP] of int: pp;
array[1..NC] of int: cc;

array[1..N,1..N] of var 0..1: ss;

constraint forall(j in 1..NC)(alldifferent_except_0([path[j,i] |i in 1..N]));
%I do not need repetitions of node in the path (so avoid cylce)

constraint forall(j in 1..N)(sum(i in 1..N)(ss[i,j])<=1);% for each row
constraint forall(j in 1..N)(sum(i in 1..N)(ss[j,i])<=1);% for each column
% with this two constraint a single switch can be used just for one path

predicate exists_path_length(int: s, int: t, int: len, int: pathindx) = 
          path[pathindx,1]=s /\ path[pathindx,len]=t /\
          forall(i in len+1..N)(path[pathindx,i]=0) /\          
          forall(i in 1..len-1)( adj_mat[path[pathindx,i],path[pathindx,i+1]]=1 /\ 
                                 ss[path[pathindx,i],path[pathindx,i+1]]=1);
          % to put switches on somewhere
predicate exists_path(int: s, int: t, int: pathindx) = exists(len in 2..N)(exists_path_length(s,t,len,pathindx));

constraint forall(j in 1..NC)(exists(i in 1..NP)(exists_path(cc[j],pp[i],j)));
%this constraint looks for paths from each consumer to a producer
 
predicate inside(array[int,int]of var int:a, int:pathindx, int: find) = exists(i in 1..N)(a[pathindx,i] == find );

constraint forall(j in 1..NC)(sum(i in 1..NP)(if inside(path,j,pp[i]) then pt[pp[i]] else 0 endif)>=cw[j]);
% with this constraint I can check wheter the energy provided by the produces is bigger then the energy required by each 
% consumer the case where there is c--s--p--s--p with the following weights (-70)--s--30--s--40 should be fine
%shouldn't work for the case c--s--c--s--p--s--p as (-10)--s--(-70)--s--30--s--50 

constraint cost = sum(i in 1..NC)(sum(j in 1..N-1)(if path[i,j+1] !=0 then sum(k in 1..NP)(if inside(path,i,pp[k]) then pt[pp[k]]*pt[pp[k]] else 0 endif)*w[path[i,j],path[i,j+1]] else 0 endif));

solve minimize cost;

output[show("Path:"),show(path),show("Cost:"), show(cost)];

NP = 2;
NC = 1;
NS =1;
N=4;
pw = [10,30];
pt = [0,10,30,0];
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
    0, 0, 0, 1,|
    0, 0, 0, 2,|
    1, 1, 2, 0 |];