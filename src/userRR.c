#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
// checking valid input
  if(argc != 5){
    printf(1, "Illegal number of arguments\n");
    exit();
  }

  // arguments to be passed by user
  int userTimeSlice = atoi(argv[1]);
  int iterations = atoi(argv[2]);
  char job[100];
  strcpy(job, argv[1]); 
  int jobCount = atoi(argv[4]);

  for (int i = 0; i < iterations; i++) {

  }

   exit(); 	
}
