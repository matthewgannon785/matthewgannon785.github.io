#include <R.h>
using namespace std;
extern "C" {
  void isOrth(int *x, int *y, int *len, double *sum, int *isorth){
    
    *sum = 0;
    
    for(int i=0; i< *len; i++)
    {
      *sum += (x[i])*(y[i]);
      *isorth = *sum == 0;
      }
    }
  }









