#include <R.h>
#include <cstdlib>
using namespace std;
extern "C" {
  void signC(double *x, int *len, double *z) {
   
   *z = 0;
   
   for(int i=0; i< *len; i++){
    while(x[i]>0){
      z[i]=1;
    }
    while (x[i]<0){
      z[i]=-1;
    }
   }
  }
}