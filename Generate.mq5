string symb[]={"EURUSD",
"GBPUSD","AUDUSD","USDJPY","USDCAD"};
int b=50;
int total=10;
int size_out1=35;
int size_out2=35;
int size_out3=35;
int out=30;
input int numpopulation=75;
input double i_tournamentSize = 5;
input bool i_elitism = true;
input double i_uniformRate = 0.5;
input double   i_mutationRate = 0.015;




double maxglobal=-999999999;
int bitlength=0;
int numinputs=0;

#include <Arrays\ArrayObj.mqh>


CAlglib           Alg;
CHighQualityRandStateShell state;


 
class Individual :  public CObject{
   public:
      int defaultGeneLength;
      double genes[];
      bool isFitted;
      double fitness;
      void initIndividual(int idefaultGeneLength); 
      void generateIndividual();
      int size();
      double getGene(int index);
      void setGene(int index, double value);
      double getFitness();
      string ToString();
      bool ReadFitness(int file);
      int tmp;
};
bool Individual::ReadFitness(int id){
   tmp++;
   if (FileIsExist((string)(id+1)+"_result.txt",FILE_COMMON)){
      int filehnd=FileOpen((string)(id+1)+"_result.txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);   
      if (filehnd!=INVALID_HANDLE){
    
         string val=FileReadString(filehnd);
         
            printf(val+" "+id);
         /*if ((double)val>=999999999999){
            val=0;
            val=0;
         }*/
         if (val=="repeat"){
            printf("repeat"+id);
            FileClose(filehnd);
            while(FileIsExist((string)(id+1)+"_result.txt",FILE_COMMON)){
               FileClose(filehnd);
               FileDelete((string)(id+1)+"_result.txt",FILE_COMMON);
            }
            return false;
         }
         isFitted=true;
         fitness=(double)val;
         
         FileClose(filehnd);
         while(FileIsExist((string)(id+1)+"_result.txt",FILE_COMMON)){
               FileClose(filehnd);
               FileDelete((string)(id+1)+"_result.txt",FILE_COMMON);
         }
      }else{
         
      }
   }
   
   return true;
    
   
}
string Individual::ToString(){
   string ret="";
   int tmp=0;
   int top=(8*4);
   string bitval="";
   int xta=size();
   for (int x=0;x<xta;x++){      
      ret+=(string)getGene(x)+",";      
   }
   return ret;
}
double Individual::getFitness() {
        double ret=0;
       
        
          
       
        
        if (fitness>=0){
         ret=fitness;
        }else{
         ret=fitness*-1;
        }
        ret=fitness;
        return ret;
    }
    
void Individual::setGene(int index, double value) {
        genes[index] = value;
        fitness = 0;
}
double Individual::getGene(int index) {
      return genes[index];
}
int Individual::size() {
      return ArraySize(genes);
}
void Individual::generateIndividual() {
      for (int i = 0; i < size(); i++) {            
           
           
            Alg.HQRndRandomize(&state);
            double rand1=UniformValue(-1,1);
           
            
            double gene = rand1;
            genes[i] = gene;
      }
   }
        
void Individual::initIndividual(int idefaultGeneLength){
   defaultGeneLength=idefaultGeneLength;
   fitness = 0;
   isFitted=false;
   tmp=0;
   ArrayResize(genes,defaultGeneLength);   
}

class Population{
   public:
   
   Individual individuals[];
   void initPopulation(int populationSize, bool initialise);
   Individual* getIndividual(int index);
   Individual* getFittest();
   int size();
   void saveIndividual(int index, Individual &indiv);
   void removezero();
   
};
void Population::removezero(){
   for (int x=0;x<size();x++){
      Individual *ind=getIndividual(x);
      if(ind.getFitness()==0){
         individuals[x]=max;
      }
      
   }
}
void Population::saveIndividual(int index, Individual &indiv) {
        individuals[index] = indiv;
 }
int Population::size() {
        return ArraySize(individuals);        
        }

Individual* Population::getFittest() {
        Individual *fittest;        
        fittest = &individuals[0];
        /*for (int i = 0; i < size(); i++) {
         fittest = &individuals[i];
         if (fittest.getFitness()!=0.0)break;
        }
        */
       
        for (int i = 0; i < size(); i++) {
            if (fittest.getFitness() <= getIndividual(i).getFitness() && getIndividual(i).getFitness()!=0.0) {            
                fittest = getIndividual(i);
            }
        }
        return fittest;
    }
    
Individual* Population::getIndividual(int index) {   
         Individual *ind;
         ind=&individuals[index];
        return ind;
    }
    
void Population::initPopulation(int populationSize, bool initialise) {
       
        ArrayResize(individuals,populationSize);
       
        if (initialise) {
           
            for (int i = 0; i < size(); i++) {
                Individual *newIndividual = new Individual();
                newIndividual.initIndividual(bitlength);
                newIndividual.generateIndividual();
                saveIndividual(i, newIndividual);
            }
        }
}

class Algorithm {
     public:
      double uniformRate ;
      double mutationRate;
      int tournamentSize ;
      bool elitism ;
      void initAlgorithm();    
      void mutate(Individual &indiv);
      Population* evolvePopulation(Population &pop);
      Individual* crossover(Individual &indiv1, Individual &indiv2);
      Individual* tournamentSelection(Population &pop);
};

void Algorithm::initAlgorithm(){
       uniformRate =i_uniformRate;
       mutationRate =i_mutationRate;
       tournamentSize = i_tournamentSize;
       elitism = i_elitism;
}


Individual* Algorithm::crossover(Individual &indiv1, Individual &indiv2) {
        Individual *newSol = new Individual();
        newSol.initIndividual(bitlength);        
        for (int i = 0; i < indiv1.size(); i++) {        
            Alg.HQRndRandomize(&state);
            double rand1=UniformValue(-1,1);
            
            if (rand1 <= uniformRate) {
                newSol.setGene(i, indiv1.getGene(i));
            } else {
                newSol.setGene(i, indiv2.getGene(i));
            }
        }
        return newSol;
    }

void Algorithm::mutate(Individual &indiv) {
       
        for (int i = 0; i < indiv.size(); i++) {
            Alg.HQRndRandomize(&state);
            double rand1=UniformValue(0,1);
            
            if (rand1 <= mutationRate) {
               
                Alg.HQRndRandomize(&state);
                double rand1=UniformValue(0,2);                
                double gene = indiv.getGene(i)*rand1;
                indiv.setGene(i, gene);
            }
        }
    }
        
 
  Individual* Algorithm::tournamentSelection(Population &pop) {
       
        Population *tournament = new Population();
        tournament.initPopulation(tournamentSize, false);
       
        for (int i = 0; i < tournamentSize; i++) {
             
            Alg.HQRndRandomize(&state);
            double rand1=UniformValue(0,1);;                             
            
            int randomId = (int) (rand1 * pop.size());
            
            tournament.saveIndividual(i, pop.getIndividual(randomId));
        }
       
        Individual *fittest = tournament.getFittest();
        return fittest;
    }        

 Individual max;
Population* Algorithm::evolvePopulation(Population &pop) {
        Population *newPopulation = new Population;
        newPopulation.initPopulation(pop.size(), false);
       
        if (elitism) {
           
            
           
            
            if (pop.getFittest().getFitness()>maxglobal){
            
               printf("MAX FITTED:"+pop.getFittest().getFitness());
               maxglobal=pop.getFittest().getFitness();
               max=pop.getFittest();
               
               string filename;
               if (newPopulation.getIndividual(0).fitness>=0){
                  filename="UPBEST.best";
               }else{
                  filename="DOWNBEST.best";
               }
               FileDelete("UPBEST.best",FILE_COMMON);
               FileDelete("DOWNBEST.best",FILE_COMMON);
               int filehnd=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
               FileWrite(filehnd,max.ToString());
               FileClose(filehnd);      
            }
           
            newPopulation.saveIndividual(0, max);                                    
        }
       
        int elitismOffset;
        if (elitism) {
            elitismOffset = 1;
        } else {
            elitismOffset = 0;
        }
       
       
        for (int i = elitismOffset; i < pop.size(); i++) {
            Individual indiv1 = tournamentSelection(pop);
            Individual indiv2 = tournamentSelection(pop);
            Individual newIndiv = crossover(indiv1, indiv2);
            newPopulation.saveIndividual(i, newIndiv);
        }
       
        for (int i = elitismOffset; i < newPopulation.size(); i++) {
            mutate(newPopulation.getIndividual(i));
        }      
        for (int i = 0; i < newPopulation.size(); i++) {
            newPopulation.getIndividual(i).isFitted=false;
        }      
        return newPopulation;
    }

int BinaryToInt(string binary){ 
  int out=0;
  if(StringLen(binary)==0){return(0);}
  for(int i=0;i<StringLen(binary);i++){
    if(StringSubstr(binary,i,1)=="1"){
      out+=int(MathPow(2,StringLen(binary)-i-1));
    }else{
      if(StringSubstr(binary,i,1)!="0"){
        
      }
    }
  }
  return(out);
}

string IntToBinary(int i){ 
  if(i==0) return "0";
  if(i<0) return "-" + IntToBinary(-i);
  string out="";
  for(;i!=0;i/=2) out=string(i%2)+out;
  return(out);
}
bool populationfinished=false;

Population *pop;
Algorithm *algorithm;


void setpoptofiles(Population &pop){
   
   for (int x=0;x<pop.size();x++){
     
      
      Individual *ind=pop.getIndividual(x);
      int filehnd=FileOpen((string)(x+1)+".ttt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
      FileWrite(filehnd,ind.ToString());
      FileClose(filehnd);      
      msteps++;
   }

}
int msteps=0;
int moldstep=0;
bool isprimero=true;
bool run=false;

void OnTimer(){
  
  
   if (isprimero){
      printf("primero");
      isprimero=false;         
      pop=new Population();      
      pop.initPopulation(numpopulation,true);  
      algorithm = new Algorithm();
      algorithm.initAlgorithm();
      setpoptofiles(pop);
     
     
     
      run=false;
      return;      
   }else{
   
       bool allfitted=true;
      
       for (int x=0;x<pop.size();x++){
            Individual *ind=pop.getIndividual(x);   
            if (ind.isFitted==false || FileIsExist((string)(x+1)+"_result.txt",FILE_COMMON)){
           
               allfitted=false;
  
               if (ind.ReadFitness(x)){
               
               }else{
           
                 
                 
                  Individual *ind=pop.getIndividual(x);
                  int filehnd=FileOpen((string)(x+1)+".ttt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON);
                  FileWrite(filehnd,ind.ToString());
                  FileClose(filehnd);      
               }
                              
               
            }            
       }
     
       if (allfitted){         
        
        
         string filter="*.txt";
         string file_name;
         long search_handle=FileFindFirst(filter,file_name,FILE_COMMON);

         if(search_handle!=INVALID_HANDLE)
   
         { run=false;
            return;
         }
         pop = algorithm.evolvePopulation(pop);       
         setpoptofiles(pop);
         moldstep=msteps;
         printf("EVOLVED");
       }
   }            
   
run=false;
}
bool finishedallgenerations(){
   bool ret=false;      
   if(FileIsExist((string)(msteps-1)+"_result.txt",FILE_COMMON)){
      ret=true;
      Sleep(100);
   }else{
      
   }
   return ret;
   

}
int OnInit()
  {
 
   
   
   numinputs=backbars*2*totalorders;   
   
   int TOTALINTNUMBERS=(numinputs*size_out1)+(size_out1*size_out2)+(size_out2*size_out3)+(size_out3*out);
  
  
   
   bitlength=TOTALINTNUMBERS;
   
   
   EventSetMillisecondTimer(1500);   
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }

void OnTick()
  {
      
   
  }


bool isValidSymbol(int x,int y){

  
   
   
  
   bool retorno = true;
   
   string val1;
   string val2;           
   val1 = moneda(x);
   val2=moneda(y);            
   
   MqlRates rates[];
   int cp=CopyRates(val1+val2,_Period,0,1,rates);
   if (cp==-1){
      retorno=false;
   }
   return retorno;
}


string moneda(int index){
 
 
 
   switch(index)
     {
      case 0: return "USD";
      case 1: return "EUR";
      case 2: return "GBP";
      case 3: return "CHF";
      case 4: return "JPY";
      case 5: return "AUD";
      case 6: return "CAD";
      case 7: return "NZD";
      
      }
      return "";
  }  
  
  double UniformValue(double min,double max)
  {
   Alg.HQRndRandomize(&state)
   if(max>min)
      return Alg.HQRndUniformR(&state)*(max-min)+min;
   else
      return Alg.HQRndUniformR(&state)*(min-max)+max;
  }