#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "x86.h"
#include "pstat.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;


//queue declaration
struct proc *q0[NPROC]= {[0 ... NPROC-1] = 0};
struct proc *q1[NPROC]= {[0 ... NPROC-1] = 0};
struct proc *q2[NPROC]= {[0 ... NPROC-1] = 0};
struct proc *q3[NPROC]= {[0 ... NPROC-1] = 0};

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;

  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");

  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();

  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;
  p->priority = 3;
  p->ticksUsed[3] = 0;
  q3[0] = p;
  p->qtail[3] = 1;
  // cprintf("In UserInit setting to 1: %d\n", p->qtail[3]);

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// removing a process from the queue
struct proc**
delete(struct proc **queue, int pid){
  int position_in_queue = -1;
  for (int i = 0; i < NPROC; i++) {
    if (queue[i]->pid == pid) {
      position_in_queue = i;
      break;
    }
  }
  if (position_in_queue != -1) {
    // temp array to store queue data
    for(int i = position_in_queue; i < NPROC; i++){
      queue[i] = queue[i+1];
    }
    queue[NPROC-1] = 0;
  }
  return queue;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  
  if (curproc->priority == 3) {
    delete(q3, curproc->pid);
    // Resetting timer tick
    curproc->ticksUsed[3] = 0;
  } else if (curproc->priority == 2) {
    delete(q2, curproc->pid);
    // Resetting timer tick
    curproc->ticksUsed[2] = 0;
  } else if (curproc->priority == 1) {
    delete(q1, curproc->pid);
    // Resetting timer tick
    curproc->ticksUsed[1] = 0;
  } else if (curproc->priority == 0) {
    delete(q0, curproc->pid);
    // Resetting timer tick
    curproc->ticksUsed[0] = 0;
  }
  
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  // struct proc *p = ptable.proc;
  struct cpu *c = mycpu();
  c->proc = 0;

  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    start:
    if (q3[0] != 0) {
      for(int k = 0; k < NPROC; k++) {
        // Priority queue 3
        if (q3[k] != 0) {
          p = q3[k];
          if(p->state == RUNNABLE) {
            // Switch to chosen process. It is the process's job
            // to release ptable.lock and then reacquire it
            // before jumping back to us.
            if(p->ticksUsed[3] < 8) {
              c->proc = p;
              switchuvm(p);
              p->state = RUNNING;
              swtch(&(c->scheduler), p->context);
              switchkvm();

              p->ticksUsed[3]++;
              p->ticks[3]++;

              //cprintf("PID %d In scheduler ticks: %d\n",p->pid, p->ticksUsed[3]);
              if(p->ticksUsed[3] == 8) {
                delete(q3, p->pid);
                // Resetting timer tick
                p->ticksUsed[3] = 0;
                // Add to the end of the queue
                for(int i = 0; i < NPROC; i++){
                  if(q3[i] == 0){
                    q3[i] = p;
                    break;
                  }
                }
                p->qtail[3]++;
                //cprintf("PID %d In scheduler qtail: %d\n",p->pid, p->qtail[3]);
                // Process is done running for now.
                // It should have changed its p->state before coming back.
              }
                c->proc = 0;
                goto start;
            }
          } else if (q3[k+1] != 0){
            continue;
          } else {
            break;
          }
        }
      }
    }

    if (q2[0] != 0) {
      for(int k = 0; k < NPROC; k++) {
        // Priority queue 2
        if (q2[k] != 0) {
          p = q2[k];
          if(p->state == RUNNABLE) {
            // Switch to chosen process. It is the process's job
            // to release ptable.lock and then reacquire it
            // before jumping back to us.
            if(p->ticksUsed[2] < 12) {
              c->proc = p;
              switchuvm(p);
              p->state = RUNNING;
              swtch(&(c->scheduler), p->context);
              switchkvm();

              p->ticksUsed[2]++;
              p->ticks[2]++;
              //cprintf("PID %d In scheduler ticks: %d\n",p->pid, p->ticksUsed[2]);
              if(p->ticksUsed[2] == 12) {
                delete(q2, p->pid);
                // Resetting timer tick
                p->ticksUsed[2] = 0;
                // Add to the end of the queue
                for(int i = 0; i < NPROC; i++){
                  if(q2[i] == 0){
                    q2[i] = p;
                    break;
                  }
                }
                p->qtail[2]++;
                //cprintf("PID %d In scheduler qtail: %d\n",p->pid, p->qtail[2]);
                // Process is done running for now.
                // It should have changed its p->state before coming back. 
              }
              c->proc = 0;
              goto start;
            }
          } else if (q2[k+1] != 0){
            continue;
          } else {
            break;
          }
        }
      }
    }

    if (q1[0] != 0) {
      for(int k = 0; k < NPROC; k++) {
        // Priority queue 1
        if (q1[k] != 0) {
          p = q1[k];
          if(p->state == RUNNABLE) {
            // Switch to chosen process. It is the process's job
            // to release ptable.lock and then reacquire it
            // before jumping back to us.
            if(p->ticksUsed[1] < 16) {
              c->proc = p;
              switchuvm(p);
              p->state = RUNNING;
              swtch(&(c->scheduler), p->context);
              switchkvm();

              p->ticksUsed[1]++;
              p->ticks[1]++;

              if(p->ticksUsed[1] == 16) {
                delete(q1, p->pid);
                // Resetting timer tick
                p->ticksUsed[1] = 0;
                // Add to the end of the queue
                for(int i = 0; i < NPROC; i++){
                  if(q1[i] == 0){
                    q1[i] = p;
                    break;
                  }
                }
                p->qtail[1]++;
                // Process is done running for now.
                // It should have changed its p->state before coming back. 
              }
              c->proc = 0;
              goto start;
            }
          } else if (q1[k+1] != 0){
            continue;
          } else {
            break;
          }
        }
      }
    }

    if (q0[0] != 0) {
      for(int k = 0; k < NPROC; k++) {
        // Priority queue 0
        if (q0[k] != 0) {
          p = q0[k];
          if(p->state == RUNNABLE) {
            // Switch to chosen process. It is the process's job
            // to release ptable.lock and then reacquire it
            // before jumping back to us.
            if(p->ticksUsed[0] < 20) {
              c->proc = p;
              switchuvm(p);
              p->state = RUNNING;
              swtch(&(c->scheduler), p->context);
              switchkvm();

              p->ticksUsed[0]++;
              p->ticks[0]++;

              if(p->ticksUsed[0] == 20) {
                delete(q0, p->pid);
                // Resetting timer tick
                p->ticksUsed[0] = 0;
                // Add to the end of the queue
                for(int i = 0; i < NPROC; i++){
                  if(q0[i] == 0){
                    q0[i] = p;
                    break;
                  }
                }
                p->qtail[0]++;
                // Process is done running for now.
                // It should have changed its p->state before coming back.
              }
                c->proc = 0;
                goto start;
            }
          } else if (q0[k+1] != 0){
            continue;
          } else {
            break;
          }
        }
      }
    }
    release(&ptable.lock);
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();

  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    if(p->state == SLEEPING && p->chan == chan){
      p->state = RUNNABLE;

      if (p->priority == 3) {
        delete(q3, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q3[i] == 0){
            q3[i] = p;
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[3] = 0;
        p->qtail[3]++;
      } else if (p->priority == 2) {
        delete(q2, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q2[i] == 0){
            q2[i] = p;
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[2] = 0;
        p->qtail[2]++;
        // cprintf("PID %d In wakeup1: %d\n",p->pid, p->qtail[2]);
      } else if (p->priority == 1) {
        delete(q1, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q1[i] == 0){
            q1[i] = p;
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[1] = 0;
        p->qtail[1]++;
      } else if (p->priority == 0) {
        delete(q0, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q0[i] == 0){
            q0[i] = p;
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[0] = 0;
        p->qtail[0]++;
      }
    }
  }
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

// Set priority system call
int setpri(int PID, int pri){
  int out = -1;
  struct proc *p;

  if (pri < 0 || pri > 3) {
    return out;
  }

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == PID){
      if (pri == 3) {
        delete(q3, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q3[i] == 0){
            q3[i] = p;
            break;
          }
        }
      } else if (pri == 2) {
        delete(q2, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q2[i] == 0){
            q2[i] = p;
            break;
          }
        }
      } else if (pri == 1) {
        delete(q1, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q1[i] == 0){
            q1[i] = p;
            break;
          }
        }
      } else if (pri == 0) {
        delete(q0, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q0[i] == 0){
            q0[i] = p;
            break;
          }
        }
      }
      p->priority = pri;
      p->ticksUsed[pri] = 0;
      p->qtail[pri]++;
      // cprintf("In setpri: %d\n", p->qtail[pri]);
      out = 0;
    }
  }
  release(&ptable.lock);
  return out;
}

// Get priority system call
int getpri(int PID){

  int pri = -1;
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == PID){
        pri = p->priority;
        break;
    }
  }
  return pri;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  struct proc *p = myproc();
  return fork2(getpri(p->pid));
}

// fork 2 has original fork implementation in addition
// to setting the desired priority of a process
int
fork2(int pri)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  if (pri < 0 || pri > 3) {
    return -1;
  }

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;

  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;
  // Set desired priority
  np->priority = pri;
  // Set qtails, ticks, and ticksUsed to zero at each priority
  for (int i = 0; i < 4; i++){
    np->qtail[i] = 0;
    np->ticks[i] = 0;
    np->ticksUsed[i] = 0;
  }
  // Insert the process in the queue and increment qtail
  if (pri == 3) {
      for(int i = 0; i < NPROC; i++){
        if(q3[i] == 0){
          q3[i] = np;
          break;
        }
      }
      np->qtail[3]++;
  } else if (pri == 2){
      for(int i = 0; i < NPROC; i++){
        if(q2[i] == 0){
          q2[i] = np;
          break;
        }
      }
      np->qtail[2]++;
      // cprintf("PID %d In fork2 qtail: %d\n", np->pid, np->qtail[2]);
  } else if (pri == 1){
      for(int i = 0; i < NPROC; i++){
        if(q1[i] == 0){
          q1[i] = np;
          break;
        }
      }
      np->qtail[1]++;
  } else if (pri == 0){
      for(int i = 0; i < NPROC; i++){
        if(q0[i] == 0){
          q0[i] = np;
          break;
        }
      }
      np->qtail[0]++;
  }

  release(&ptable.lock);
  return pid;
}

int getpinfo(struct pstat *mystruct){
  if (mystruct == 0) {
    return -1;
  }

  struct proc *p = ptable.proc;
  acquire(&ptable.lock);

  for(int i = 0; i < NPROC; i++){

    if (p[i].state == UNUSED || p[i].state == EMBRYO || p[i].state == ZOMBIE){
      mystruct->inuse[i] = 0;
    } else {
      mystruct->inuse[i] = 1;
    }
    mystruct->pid[i] = p[i].pid;
    mystruct->state[i] = p[i].state;
    mystruct->priority[i] = p[i].priority;
    for (int j = 0; j < 4; j++) {
      mystruct->ticks[i][j] = p[i].ticks[j];
      mystruct->qtail[i][j] = p[i].qtail[j];
    }
  }
  release(&ptable.lock);
  return 0;
}
