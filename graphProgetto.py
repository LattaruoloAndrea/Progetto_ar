import random
import subprocess
import time
class graph:

    def __init__(self,s=1,c=1):
        self.min = 1
        self.max = 100
        self.nSwitch = s
        self.nConsumer = c
        self.nProducer = 3*self.nSwitch - self.nConsumer
        self.n = self.nConsumer +self.nSwitch + self.nProducer
        self.edges = 3*self.nSwitch
        self.adjMatrix = [[0 for i in range(self.n)] for j in range(self.n)]
        self.w = [[0 for i in range(self.n)] for j in range(self.n)]
        self.wConsumer = [self.randomRange(self.min,self.max) for i in range(self.nConsumer)]
        self.wProducer =  [self.randomRange(self.min,self.max) for i in range(self.nProducer)]
        self.cc = [i+1 for i in range(self.nConsumer)]
        self.pp = [i+1+self.nConsumer for i in range(self.nProducer)]
        self.pt = [self.wProducer[i-self.nProducer+1] if i>=self.nConsumer and i<self.n-self.nSwitch else 0 for i in range(self.n)]
        self.ss = [i+1+self.nConsumer+self.nProducer for i in range(self.nSwitch)]

    def createGraph(self):
        index_switch = self.n - self.nSwitch
        switch_edges_array = [3 for i in range(self.nSwitch)]
        i = 0
        while self.sum_array(switch_edges_array) != 0:
            if switch_edges_array[i] != 0:
                # choose a random node
                node = self.randomRange(0,self.n-1)
                while node == (i+index_switch) or self.adjMatrix[i+index_switch][node] == 1:
                    node = self.randomRange(0,self.n-1-self.nSwitch)
                if node >= index_switch:
                    #if node is a switch
                    if switch_edges_array[node-index_switch] != 0:
                        #print("SWITCH")
                        self.adjMatrix[i+index_switch][node] = 1
                        self.w[i+index_switch][node] = self.adjMatrix[i+index_switch][node]*self.randomRange(self.min,int(self.max*10/100))
                        self.adjMatrix[node][i+index_switch] = 1
                        self.w[node][i+index_switch] = self.adjMatrix[i+index_switch][node]*self.randomRange(self.min,int(self.max*10/100))
                        switch_edges_array[i] -= 1
                        switch_edges_array[node-index_switch] -= 1
                    else:
                        #print("PASS")
                        # the other swithc is already full
                        pass
                else:
                    #print("CONS, PROD")
                    self.adjMatrix[i+index_switch][node] = 1
                    self.w[i+index_switch][node] = self.adjMatrix[i+index_switch][node]*self.randomRange(self.min,int(self.max*10/100))
                    switch_edges_array[i] -= 1
            else:
                i+=1
        #print("sum: ",self.sum_array(switch_edges_array))
        self.speculateMatrix()
            
    def sum_array(self,array):
        tot = 0
        for i in range(len(array)):
            tot += array[i]
        return tot

    def printMatrix(self):
        for i in range(self.n):
            for j in range(self.n):
                print(self.adjMatrix[i][j],", ", end='')
                if(j== self.n-1):
                    print("\n")
        print("\n")

    def printWeight(self):
        for i in range(self.n):
            for j in range(self.n):
                print(self.w[i][j],", ", end='')
                if(j== self.n-1):
                    print("\n")
        print("\n")

    def switchCompeted(self,x):
        tot = 0
        for i in range(self.n):
            tot = tot + self.adjMatrix[x][i]
        if tot == 3:
            return True
        else:
            return False

    def speculateMatrix(self):
        for i in range(self.n):
            for j in range(self.n):
                self.adjMatrix[i][j] = self.adjMatrix[j][i]
                self.w[i][j] = self.w[j][i]
                
    def filled(self):
        if self.edges != 0:
            return False
        else:
            return True

    def sum(self,array):
        tot = 0
        for i in array:
            tot += i
        return tot

    def randomRange(self,a,b):
        return int(random.random()*(b-a))+a
    
    def create_min(self):
        """NP = 2;
            NC = 1;
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
                1, 1, 2, 0 |];"""
        result = ""
        result += "NP=" + str(self.nProducer) +";\n"
        result += "NC=" + str(self.nConsumer) +";\n"
        result += "N=" + str(self.n) +";\n"
        result += "pw=" + str(self.wProducer) +";\n"
        result += "pt=" + str(self.pt) +";\n"
        result += "cw=" + str(self.wConsumer) +";\n"
        result += "pp=" + str(self.pp) +";\n"
        result += "cc=" + str(self.cc) +";\n"
        result += "adj_mat=" + str(self.matrixMin(self.adjMatrix)) +";\n"
        result += "w=" + str(self.matrixMin(self.w)) +";\n"
        return result
    
    def matrixMin(self,matrix):
        result = "[|\n"
        for i in range(self.n):
            for j in range(self.n):
                if i== self.n-1 and j== self.n-1:
                    result += str(matrix[i][j])+" "
                else:
                    result += str(matrix[i][j])+", "
            if i== self.n-1 and j== self.n-1:
                result += "|"
            else:
                result += "|\n"
        result += "]"
        return result

    def create_asp(self):
        """producer(3).
            producer_weight_tot(1,0;2,0;3,15;4,0).

            #const number_consumer = 2.
            consumer(1;2).
            consumer_weight(1,10;2,5).
            energy(1,0..10;2,0..5).

            #const number_switch = 1.
            switch(4).
            edge(1,4;2,4;3,4).
            %edge(X,Y):- edge(Y,X).

            weights(1,4,1;2,4,2;3,4,3).
            weights(X,Y,W) :- weights(Y,X,W).
            """
        result = ""
        result+= "producer(" + self.create_list(self.pp) +").\n"
        result+= "producer_weight_tot(" +self.couple_list(self.pt) +").\n"
        result+= "#const number_consumer = " + str(self.nConsumer) +".\n"
        result+= "consumer(" + self.create_list(self.cc) +").\n"
        result+= "consumer_weight(" + self.couple_list(self.wConsumer) +").\n"
        result+= "energy(" + self.energy_list() +").\n"
        result+= "#const number_switch = " + str(self.nSwitch) +".\n"
        result+= "switch(" + self.create_list(self.ss) +").\n"
        a,b = self.matrix_list()
        result+= "edge(" + a +").\n"
        result+= "weights(" + b +").\n"
        result+= "weights(X,Y,W) :- weights(Y,X,W).\n"
        return result
    
    def create_list(self,array):
        result = ""
        for i in range(len(array)):
            if i != len(array)-1:
                result += str(array[i]) + ";"
            else:
                result += str(array[i])
        return result
    
    def couple_list(self,array):
        result = ""
        for i in range(len(array)):
            if i != len(array)-1:
                result += str(i+1)+", "+str(array[i]) +"; "
            else:
                result+= str(i+1)+", "+str(array[i])
        return result

    def energy_list(self):
        result = ""
        for i in range(self.nConsumer):
            if i != self.nConsumer-1:
                result+=str(i+1)+",0.."+str(self.wConsumer[i])+"; "
            else:
                result+=str(i+1)+",0.."+str(self.wConsumer[i])
        return result
    
    def matrix_list(self):
        edge = ""
        weight = ""
        for i in range(self.n):
            for j in range(self.n):
                if j<i:
                    if self.adjMatrix[i][j] == 1:
                        edge+= str(j+1) +", "+ str(i+1) +"; "
                        if i>=self.n-self.nSwitch+1 and j>=self.n-self.nSwitch+1:
                            #if two switch are connected I need the other verse
                            edge+= str(i+1) +", "+ str(j+1) +"; "
                    weight+= str(j+1) +", "+ str(i+1)+", " +str(self.w[i][j]) + "; "
        return edge,weight

def create_test(g,occ):
    names_min = create_names("test/test_minizinc",occ,"dzn")
    names_asp = create_names("test/test_asp",occ,"lp")
    create_file(names_min,g.create_min())
    create_file(names_asp,g.create_asp())

def create_file(name,content):
    f= open(name,"w")
    f.write(content)
    f.close()

def create_names(name_file,occ,ext):
    return name_file+"_"+str(occ)+"."+ext

def time_test(n_test=100):
    f = open("clingo_result_test","w")
    for occ in range(n_test):
        bashCommand = "clingo --time-limit=300 " + "progetto.lp " + "test/test_asp_" + str(occ) + ".lp"
        print("test/test_asp_" + str(occ) + ".lp")
        process = subprocess.Popen(bashCommand.split(),stdout=subprocess.PIPE)
        time_start = int(round(time.time()*1000))
        output,error = process.communicate()
        time_end = int(round(time.time()*1000))
        f.write("test_asp" + str(occ) + ".lp\n")
        f.write(str(output)+"\n")
        f.write("Time: "+ str( (int((time_end-time_start)/1000)))+"\n")
    f.close()

def time_test_m(n_test=100):
    path = "MiniZincIDE-2.3.2-bundle-linux"
    f = open("minizinc_result_test","w")
    for occ in range(n_test):
        bashCommand = "minizinc --solver Gecode --time-limit 300000 progetto.mzn "+"test/test_minizinc_" + str(occ) +".dzn"
        print("test/test_mnz_" + str(occ) + ".dzn")
        process = subprocess.Popen(bashCommand.split(),stdout=subprocess.PIPE)
        time_start = int(round(time.time()*1000))
        output,error = process.communicate()
        time_end = int(round(time.time()*1000))
        f.write("test_mnz" + str(occ) + ".dzn\n")
        f.write(str(output)+"\n")
        f.write("Time: "+ str( (int((time_end-time_start)/1000)))+"\n")
    f.close()

def rename():
    for i in range(100):
        name = "test/test_mnz_"+ str(i)+".dnz"
        name1 = "test/test_mnz_"+ str(i)+".dzn"
        f = open(name,"r")
        ff = open(name1,"w")
        content = f.read()
        ff.write(content)
        f.close()
        ff.close()

def gg_test():
    g = graph(3,3)
    g.createGraph()
    number_exception=1
    for i in range(100):
        j = i % 20
        try:
            g = graph(j+1,g.randomRange(1,j+1))
            g.createGraph()
            create_test(g,i)
        except:
             print("exception ", number_exception," on file: ",i)
             number_exception+=1

if __name__ == "__main__":

    #g.printMatrix()
    #g.printWeight()
    # print(g.wConsumer,"\n",g.wProducer,"\n")
    # print(g.create_min(),"\n",g.create_asp())
    # create test100
    gg_test()
    #end creating test
    n_test = 5
    time_test(n_test)
    time_test_m(n_test)