#include "types.h"
#include "user.h"
#include "syscall.h"

int
main(int argc, char *argv[])
{
  // struct proc *p;
  // p = myproc();
  sleep(10);
  printf(1, "%d\n", getpid());
  // printf(1, p->pid);
  exit();
}

