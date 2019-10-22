
#include "types.h"
#include "user.h"
#include "pstat.h"
#include "syscall.h"

int
main(int argc, char *argv[])
{
// checking valid input
  if(argc != 5){
    printf(1, "Illegal number of arguments\n");
    exit();
  }
  // struct proc *cur_proc;
  // check(getpinfo(&cur_proc) == 0, "getpinfo");

  // arguments to be passed by user
  // int userTimeSlice = atoi(argv[1]);
  // int iterations = atoi(argv[2]);
  // int jobCount = atoi(argv[4]);

  // char job[64];

  // // Loop through the amount of jobs needed to be created
  // for (int i = 0; i < jobCount; i++) {

  //   strcpy(job, argv[3]); 

  //   int cur_pid = fork();
  //   int priority = getpri(cur_pid);
  //   exec(job[0], job);

  //   // Set priority to the highest
  //   setpri(cur_pid, 3);
  //   sleep(userTimeSlice);  
  //   setpri(cur_pid, 0);
  // }

  // for(int i = 0; i < iterations; i++) {
  //    kill(cur_pid[i]);
  // }

  exit(); 	
}
