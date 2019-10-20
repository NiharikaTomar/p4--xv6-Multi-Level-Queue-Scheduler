#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"

int
main(int argc, char *argv[])
{
  struct proc *p;
  p = myproc();
  sleep(10);
  printf(1, p->pid);
	exit();
}

