
_test_17:     file format elf32-i386


Disassembly of section .text:

00000000 <workload>:
#else
# define DEBUG_PRINT(x) do {} while (0)
#endif

//char buf[10000]; // ~10KB
int workload(int n, int t) {
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	56                   	push   %esi
   4:	53                   	push   %ebx
   5:	8b 75 08             	mov    0x8(%ebp),%esi
   8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  int i, j = 0;
   b:	bb 00 00 00 00       	mov    $0x0,%ebx
  for (i = 0; i < n; i++) {
  10:	b8 00 00 00 00       	mov    $0x0,%eax
  15:	eb 0c                	jmp    23 <workload+0x23>
    j += i * j + 1;
  17:	89 c2                	mov    %eax,%edx
  19:	0f af d3             	imul   %ebx,%edx
  1c:	8d 5c 1a 01          	lea    0x1(%edx,%ebx,1),%ebx
  for (i = 0; i < n; i++) {
  20:	83 c0 01             	add    $0x1,%eax
  23:	39 f0                	cmp    %esi,%eax
  25:	7c f0                	jl     17 <workload+0x17>
  }

  if (t > 0) sleep(t);
  27:	85 c9                	test   %ecx,%ecx
  29:	7f 07                	jg     32 <workload+0x32>
  for (i = 0; i < n; i++) {
  2b:	b8 00 00 00 00       	mov    $0x0,%eax
  30:	eb 1a                	jmp    4c <workload+0x4c>
  if (t > 0) sleep(t);
  32:	83 ec 0c             	sub    $0xc,%esp
  35:	51                   	push   %ecx
  36:	e8 2c 05 00 00       	call   567 <sleep>
  3b:	83 c4 10             	add    $0x10,%esp
  3e:	eb eb                	jmp    2b <workload+0x2b>
    j += i * j + 1;
  40:	89 c2                	mov    %eax,%edx
  42:	0f af d3             	imul   %ebx,%edx
  45:	8d 5c 1a 01          	lea    0x1(%edx,%ebx,1),%ebx
  for (i = 0; i < n; i++) {
  49:	83 c0 01             	add    $0x1,%eax
  4c:	39 f0                	cmp    %esi,%eax
  4e:	7c f0                	jl     40 <workload+0x40>
  }
  return j;
}
  50:	89 d8                	mov    %ebx,%eax
  52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  55:	5b                   	pop    %ebx
  56:	5e                   	pop    %esi
  57:	5d                   	pop    %ebp
  58:	c3                   	ret    

00000059 <main>:

int
main(int argc, char *argv[])
{
  59:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  5d:	83 e4 f0             	and    $0xfffffff0,%esp
  60:	ff 71 fc             	pushl  -0x4(%ecx)
  63:	55                   	push   %ebp
  64:	89 e5                	mov    %esp,%ebp
  66:	57                   	push   %edi
  67:	56                   	push   %esi
  68:	53                   	push   %ebx
  69:	51                   	push   %ecx
  6a:	81 ec 54 0c 00 00    	sub    $0xc54,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  70:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  76:	50                   	push   %eax
  77:	e8 13 05 00 00       	call   58f <getpinfo>
  7c:	83 c4 10             	add    $0x10,%esp
  7f:	85 c0                	test   %eax,%eax
  81:	75 3b                	jne    be <main+0x65>

  // Push this thread to the bottom
  workload(80000000, 0);
  83:	83 ec 08             	sub    $0x8,%esp
  86:	6a 00                	push   $0x0
  88:	68 00 b4 c4 04       	push   $0x4c4b400
  8d:	e8 6e ff ff ff       	call   0 <workload>

  int i, j, k;
  int c_pid[10];
  // Launch the 4 processes, but process 2 will sleep in the middle
  for (i = 0; i < 10; i++) {
  92:	83 c4 10             	add    $0x10,%esp
  95:	bb 00 00 00 00       	mov    $0x0,%ebx
  9a:	83 fb 09             	cmp    $0x9,%ebx
  9d:	7f 68                	jg     107 <main+0xae>
    c_pid[i] = fork2(2);
  9f:	83 ec 0c             	sub    $0xc,%esp
  a2:	6a 02                	push   $0x2
  a4:	e8 de 04 00 00       	call   587 <fork2>
  a9:	89 c1                	mov    %eax,%ecx
  ab:	89 84 9d c0 f3 ff ff 	mov    %eax,-0xc40(%ebp,%ebx,4)
    int t = 0;
    // Child
    if (c_pid[i] == 0) {
  b2:	83 c4 10             	add    $0x10,%esp
  b5:	85 c0                	test   %eax,%eax
  b7:	74 25                	je     de <main+0x85>
  for (i = 0; i < 10; i++) {
  b9:	83 c3 01             	add    $0x1,%ebx
  bc:	eb dc                	jmp    9a <main+0x41>
  check(getpinfo(&st) == 0, "getpinfo");
  be:	83 ec 0c             	sub    $0xc,%esp
  c1:	68 ec 08 00 00       	push   $0x8ec
  c6:	6a 24                	push   $0x24
  c8:	68 f5 08 00 00       	push   $0x8f5
  cd:	68 f0 09 00 00       	push   $0x9f0
  d2:	6a 01                	push   $0x1
  d4:	e8 58 05 00 00       	call   631 <printf>
  d9:	83 c4 20             	add    $0x20,%esp
  dc:	eb a5                	jmp    83 <main+0x2a>
      if (i % 2 == 1) {
  de:	be 02 00 00 00       	mov    $0x2,%esi
  e3:	89 d8                	mov    %ebx,%eax
  e5:	99                   	cltd   
  e6:	f7 fe                	idiv   %esi
  e8:	83 fa 01             	cmp    $0x1,%edx
  eb:	74 13                	je     100 <main+0xa7>
          t = 64*5; // for this process, give up CPU for one time-slice
      }
      workload(600000000, t);
  ed:	83 ec 08             	sub    $0x8,%esp
  f0:	51                   	push   %ecx
  f1:	68 00 46 c3 23       	push   $0x23c34600
  f6:	e8 05 ff ff ff       	call   0 <workload>
      exit();
  fb:	e8 d7 03 00 00       	call   4d7 <exit>
          t = 64*5; // for this process, give up CPU for one time-slice
 100:	b9 40 01 00 00       	mov    $0x140,%ecx
 105:	eb e6                	jmp    ed <main+0x94>
    } else {
      //setpri(c_pid, 2);
    }
  }

  for (i = 0; i < 20; i++) { 
 107:	c7 85 b4 f3 ff ff 00 	movl   $0x0,-0xc4c(%ebp)
 10e:	00 00 00 
 111:	e9 e5 01 00 00       	jmp    2fb <main+0x2a2>
    sleep(12);
    check(getpinfo(&st) == 0, "getpinfo");
 116:	83 ec 0c             	sub    $0xc,%esp
 119:	68 ec 08 00 00       	push   $0x8ec
 11e:	6a 3d                	push   $0x3d
 120:	68 f5 08 00 00       	push   $0x8f5
 125:	68 f0 09 00 00       	push   $0x9f0
 12a:	6a 01                	push   $0x1
 12c:	e8 00 05 00 00       	call   631 <printf>
 131:	83 c4 20             	add    $0x20,%esp
 134:	e9 ee 01 00 00       	jmp    327 <main+0x2ce>
    
    for (j = 0; j < NPROC; j++) {
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
        if(st.pid[j] == c_pid[0]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 1\n"));
 139:	83 ec 08             	sub    $0x8,%esp
 13c:	68 ff 08 00 00       	push   $0x8ff
 141:	6a 01                	push   $0x1
 143:	e8 e9 04 00 00       	call   631 <printf>
 148:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 10; i++) {
 14b:	be 03 00 00 00       	mov    $0x3,%esi
 150:	e9 da 00 00 00       	jmp    22f <main+0x1d6>
        }
        else if(st.pid[j] == c_pid[1]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 2\n"));
 155:	83 ec 08             	sub    $0x8,%esp
 158:	68 17 09 00 00       	push   $0x917
 15d:	6a 01                	push   $0x1
 15f:	e8 cd 04 00 00       	call   631 <printf>
 164:	83 c4 10             	add    $0x10,%esp
 167:	eb e2                	jmp    14b <main+0xf2>
        }
	else if(st.pid[j] == c_pid[2]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 3\n"));
 169:	83 ec 08             	sub    $0x8,%esp
 16c:	68 2f 09 00 00       	push   $0x92f
 171:	6a 01                	push   $0x1
 173:	e8 b9 04 00 00       	call   631 <printf>
 178:	83 c4 10             	add    $0x10,%esp
 17b:	eb ce                	jmp    14b <main+0xf2>
        }
	else if(st.pid[j] == c_pid[3]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 4\n"));
 17d:	83 ec 08             	sub    $0x8,%esp
 180:	68 47 09 00 00       	push   $0x947
 185:	6a 01                	push   $0x1
 187:	e8 a5 04 00 00       	call   631 <printf>
 18c:	83 c4 10             	add    $0x10,%esp
 18f:	eb ba                	jmp    14b <main+0xf2>
        }
	else if(st.pid[j] == c_pid[4]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 5\n"));
 191:	83 ec 08             	sub    $0x8,%esp
 194:	68 5f 09 00 00       	push   $0x95f
 199:	6a 01                	push   $0x1
 19b:	e8 91 04 00 00       	call   631 <printf>
 1a0:	83 c4 10             	add    $0x10,%esp
 1a3:	eb a6                	jmp    14b <main+0xf2>
        }
	else if(st.pid[j] == c_pid[5]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 6\n"));
 1a5:	83 ec 08             	sub    $0x8,%esp
 1a8:	68 77 09 00 00       	push   $0x977
 1ad:	6a 01                	push   $0x1
 1af:	e8 7d 04 00 00       	call   631 <printf>
 1b4:	83 c4 10             	add    $0x10,%esp
 1b7:	eb 92                	jmp    14b <main+0xf2>
        }
	else if(st.pid[j] == c_pid[6]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 7\n"));
 1b9:	83 ec 08             	sub    $0x8,%esp
 1bc:	68 8f 09 00 00       	push   $0x98f
 1c1:	6a 01                	push   $0x1
 1c3:	e8 69 04 00 00       	call   631 <printf>
 1c8:	83 c4 10             	add    $0x10,%esp
 1cb:	e9 7b ff ff ff       	jmp    14b <main+0xf2>
        }
	else if(st.pid[j] == c_pid[7]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 8\n"));
 1d0:	83 ec 08             	sub    $0x8,%esp
 1d3:	68 a7 09 00 00       	push   $0x9a7
 1d8:	6a 01                	push   $0x1
 1da:	e8 52 04 00 00       	call   631 <printf>
 1df:	83 c4 10             	add    $0x10,%esp
 1e2:	e9 64 ff ff ff       	jmp    14b <main+0xf2>
        }
	else if(st.pid[j] == c_pid[8]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 9\n"));
 1e7:	83 ec 08             	sub    $0x8,%esp
 1ea:	68 bf 09 00 00       	push   $0x9bf
 1ef:	6a 01                	push   $0x1
 1f1:	e8 3b 04 00 00       	call   631 <printf>
 1f6:	83 c4 10             	add    $0x10,%esp
 1f9:	e9 4d ff ff ff       	jmp    14b <main+0xf2>
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 10\n"));
        }
  
        //DEBUG_PRINT((1, "pid: %d\n", st.pid[j]));
        for (k = 3; k >= 0; k--) {
          DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d ticks used %d\n", k, st.ticks[j][k]));
 1fe:	8d 3c 9e             	lea    (%esi,%ebx,4),%edi
 201:	ff b4 bd e8 f7 ff ff 	pushl  -0x818(%ebp,%edi,4)
 208:	56                   	push   %esi
 209:	68 20 0a 00 00       	push   $0xa20
 20e:	6a 01                	push   $0x1
 210:	e8 1c 04 00 00       	call   631 <printf>
	  DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d qtail %d\n", k, st.qtail[j][k]));
 215:	ff b4 bd e8 fb ff ff 	pushl  -0x418(%ebp,%edi,4)
 21c:	56                   	push   %esi
 21d:	68 4c 0a 00 00       	push   $0xa4c
 222:	6a 01                	push   $0x1
 224:	e8 08 04 00 00       	call   631 <printf>
        for (k = 3; k >= 0; k--) {
 229:	83 ee 01             	sub    $0x1,%esi
 22c:	83 c4 20             	add    $0x20,%esp
 22f:	85 f6                	test   %esi,%esi
 231:	79 cb                	jns    1fe <main+0x1a5>
    for (j = 0; j < NPROC; j++) {
 233:	83 c3 01             	add    $0x1,%ebx
 236:	83 fb 3f             	cmp    $0x3f,%ebx
 239:	0f 8f b5 00 00 00    	jg     2f4 <main+0x29b>
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
 23f:	83 bc 9d e8 f3 ff ff 	cmpl   $0x0,-0xc18(%ebp,%ebx,4)
 246:	00 
 247:	74 ea                	je     233 <main+0x1da>
 249:	8b b4 9d e8 f4 ff ff 	mov    -0xb18(%ebp,%ebx,4),%esi
 250:	83 fe 02             	cmp    $0x2,%esi
 253:	7e de                	jle    233 <main+0x1da>
 255:	e8 fd 02 00 00       	call   557 <getpid>
 25a:	39 c6                	cmp    %eax,%esi
 25c:	74 d5                	je     233 <main+0x1da>
        if(st.pid[j] == c_pid[0]){
 25e:	8b 84 9d e8 f4 ff ff 	mov    -0xb18(%ebp,%ebx,4),%eax
 265:	3b 85 c0 f3 ff ff    	cmp    -0xc40(%ebp),%eax
 26b:	0f 84 c8 fe ff ff    	je     139 <main+0xe0>
        else if(st.pid[j] == c_pid[1]){
 271:	3b 85 c4 f3 ff ff    	cmp    -0xc3c(%ebp),%eax
 277:	0f 84 d8 fe ff ff    	je     155 <main+0xfc>
	else if(st.pid[j] == c_pid[2]){
 27d:	3b 85 c8 f3 ff ff    	cmp    -0xc38(%ebp),%eax
 283:	0f 84 e0 fe ff ff    	je     169 <main+0x110>
	else if(st.pid[j] == c_pid[3]){
 289:	3b 85 cc f3 ff ff    	cmp    -0xc34(%ebp),%eax
 28f:	0f 84 e8 fe ff ff    	je     17d <main+0x124>
	else if(st.pid[j] == c_pid[4]){
 295:	3b 85 d0 f3 ff ff    	cmp    -0xc30(%ebp),%eax
 29b:	0f 84 f0 fe ff ff    	je     191 <main+0x138>
	else if(st.pid[j] == c_pid[5]){
 2a1:	3b 85 d4 f3 ff ff    	cmp    -0xc2c(%ebp),%eax
 2a7:	0f 84 f8 fe ff ff    	je     1a5 <main+0x14c>
	else if(st.pid[j] == c_pid[6]){
 2ad:	3b 85 d8 f3 ff ff    	cmp    -0xc28(%ebp),%eax
 2b3:	0f 84 00 ff ff ff    	je     1b9 <main+0x160>
	else if(st.pid[j] == c_pid[7]){
 2b9:	3b 85 dc f3 ff ff    	cmp    -0xc24(%ebp),%eax
 2bf:	0f 84 0b ff ff ff    	je     1d0 <main+0x177>
	else if(st.pid[j] == c_pid[8]){
 2c5:	3b 85 e0 f3 ff ff    	cmp    -0xc20(%ebp),%eax
 2cb:	0f 84 16 ff ff ff    	je     1e7 <main+0x18e>
	else if(st.pid[j] == c_pid[9]){
 2d1:	3b 85 e4 f3 ff ff    	cmp    -0xc1c(%ebp),%eax
 2d7:	0f 85 6e fe ff ff    	jne    14b <main+0xf2>
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 10\n"));
 2dd:	83 ec 08             	sub    $0x8,%esp
 2e0:	68 d7 09 00 00       	push   $0x9d7
 2e5:	6a 01                	push   $0x1
 2e7:	e8 45 03 00 00       	call   631 <printf>
 2ec:	83 c4 10             	add    $0x10,%esp
 2ef:	e9 57 fe ff ff       	jmp    14b <main+0xf2>
  for (i = 0; i < 20; i++) { 
 2f4:	83 85 b4 f3 ff ff 01 	addl   $0x1,-0xc4c(%ebp)
 2fb:	83 bd b4 f3 ff ff 13 	cmpl   $0x13,-0xc4c(%ebp)
 302:	7f 2d                	jg     331 <main+0x2d8>
    sleep(12);
 304:	83 ec 0c             	sub    $0xc,%esp
 307:	6a 0c                	push   $0xc
 309:	e8 59 02 00 00       	call   567 <sleep>
    check(getpinfo(&st) == 0, "getpinfo");
 30e:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 314:	89 04 24             	mov    %eax,(%esp)
 317:	e8 73 02 00 00       	call   58f <getpinfo>
 31c:	83 c4 10             	add    $0x10,%esp
 31f:	85 c0                	test   %eax,%eax
 321:	0f 85 ef fd ff ff    	jne    116 <main+0xbd>
  for (i = 0; i < 10; i++) {
 327:	bb 00 00 00 00       	mov    $0x0,%ebx
 32c:	e9 05 ff ff ff       	jmp    236 <main+0x1dd>
        }
      } 
    }
  }

  for (i = 0; i < 10; i++) {
 331:	bb 00 00 00 00       	mov    $0x0,%ebx
 336:	eb 08                	jmp    340 <main+0x2e7>
    wait();
 338:	e8 a2 01 00 00       	call   4df <wait>
  for (i = 0; i < 10; i++) {
 33d:	83 c3 01             	add    $0x1,%ebx
 340:	83 fb 09             	cmp    $0x9,%ebx
 343:	7e f3                	jle    338 <main+0x2df>
  }

  //printf(1, "TEST PASSED");

  exit();
 345:	e8 8d 01 00 00       	call   4d7 <exit>

0000034a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	53                   	push   %ebx
 34e:	8b 45 08             	mov    0x8(%ebp),%eax
 351:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 354:	89 c2                	mov    %eax,%edx
 356:	0f b6 19             	movzbl (%ecx),%ebx
 359:	88 1a                	mov    %bl,(%edx)
 35b:	8d 52 01             	lea    0x1(%edx),%edx
 35e:	8d 49 01             	lea    0x1(%ecx),%ecx
 361:	84 db                	test   %bl,%bl
 363:	75 f1                	jne    356 <strcpy+0xc>
    ;
  return os;
}
 365:	5b                   	pop    %ebx
 366:	5d                   	pop    %ebp
 367:	c3                   	ret    

00000368 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 368:	55                   	push   %ebp
 369:	89 e5                	mov    %esp,%ebp
 36b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 36e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 371:	eb 06                	jmp    379 <strcmp+0x11>
    p++, q++;
 373:	83 c1 01             	add    $0x1,%ecx
 376:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 379:	0f b6 01             	movzbl (%ecx),%eax
 37c:	84 c0                	test   %al,%al
 37e:	74 04                	je     384 <strcmp+0x1c>
 380:	3a 02                	cmp    (%edx),%al
 382:	74 ef                	je     373 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 384:	0f b6 c0             	movzbl %al,%eax
 387:	0f b6 12             	movzbl (%edx),%edx
 38a:	29 d0                	sub    %edx,%eax
}
 38c:	5d                   	pop    %ebp
 38d:	c3                   	ret    

0000038e <strlen>:

uint
strlen(const char *s)
{
 38e:	55                   	push   %ebp
 38f:	89 e5                	mov    %esp,%ebp
 391:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 394:	ba 00 00 00 00       	mov    $0x0,%edx
 399:	eb 03                	jmp    39e <strlen+0x10>
 39b:	83 c2 01             	add    $0x1,%edx
 39e:	89 d0                	mov    %edx,%eax
 3a0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 3a4:	75 f5                	jne    39b <strlen+0xd>
    ;
  return n;
}
 3a6:	5d                   	pop    %ebp
 3a7:	c3                   	ret    

000003a8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3a8:	55                   	push   %ebp
 3a9:	89 e5                	mov    %esp,%ebp
 3ab:	57                   	push   %edi
 3ac:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 3af:	89 d7                	mov    %edx,%edi
 3b1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 3b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b7:	fc                   	cld    
 3b8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 3ba:	89 d0                	mov    %edx,%eax
 3bc:	5f                   	pop    %edi
 3bd:	5d                   	pop    %ebp
 3be:	c3                   	ret    

000003bf <strchr>:

char*
strchr(const char *s, char c)
{
 3bf:	55                   	push   %ebp
 3c0:	89 e5                	mov    %esp,%ebp
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 3c9:	0f b6 10             	movzbl (%eax),%edx
 3cc:	84 d2                	test   %dl,%dl
 3ce:	74 09                	je     3d9 <strchr+0x1a>
    if(*s == c)
 3d0:	38 ca                	cmp    %cl,%dl
 3d2:	74 0a                	je     3de <strchr+0x1f>
  for(; *s; s++)
 3d4:	83 c0 01             	add    $0x1,%eax
 3d7:	eb f0                	jmp    3c9 <strchr+0xa>
      return (char*)s;
  return 0;
 3d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 3de:	5d                   	pop    %ebp
 3df:	c3                   	ret    

000003e0 <gets>:

char*
gets(char *buf, int max)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	57                   	push   %edi
 3e4:	56                   	push   %esi
 3e5:	53                   	push   %ebx
 3e6:	83 ec 1c             	sub    $0x1c,%esp
 3e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ec:	bb 00 00 00 00       	mov    $0x0,%ebx
 3f1:	8d 73 01             	lea    0x1(%ebx),%esi
 3f4:	3b 75 0c             	cmp    0xc(%ebp),%esi
 3f7:	7d 2e                	jge    427 <gets+0x47>
    cc = read(0, &c, 1);
 3f9:	83 ec 04             	sub    $0x4,%esp
 3fc:	6a 01                	push   $0x1
 3fe:	8d 45 e7             	lea    -0x19(%ebp),%eax
 401:	50                   	push   %eax
 402:	6a 00                	push   $0x0
 404:	e8 e6 00 00 00       	call   4ef <read>
    if(cc < 1)
 409:	83 c4 10             	add    $0x10,%esp
 40c:	85 c0                	test   %eax,%eax
 40e:	7e 17                	jle    427 <gets+0x47>
      break;
    buf[i++] = c;
 410:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 414:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 417:	3c 0a                	cmp    $0xa,%al
 419:	0f 94 c2             	sete   %dl
 41c:	3c 0d                	cmp    $0xd,%al
 41e:	0f 94 c0             	sete   %al
    buf[i++] = c;
 421:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 423:	08 c2                	or     %al,%dl
 425:	74 ca                	je     3f1 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 427:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 42b:	89 f8                	mov    %edi,%eax
 42d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 430:	5b                   	pop    %ebx
 431:	5e                   	pop    %esi
 432:	5f                   	pop    %edi
 433:	5d                   	pop    %ebp
 434:	c3                   	ret    

00000435 <stat>:

int
stat(const char *n, struct stat *st)
{
 435:	55                   	push   %ebp
 436:	89 e5                	mov    %esp,%ebp
 438:	56                   	push   %esi
 439:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 43a:	83 ec 08             	sub    $0x8,%esp
 43d:	6a 00                	push   $0x0
 43f:	ff 75 08             	pushl  0x8(%ebp)
 442:	e8 d0 00 00 00       	call   517 <open>
  if(fd < 0)
 447:	83 c4 10             	add    $0x10,%esp
 44a:	85 c0                	test   %eax,%eax
 44c:	78 24                	js     472 <stat+0x3d>
 44e:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 450:	83 ec 08             	sub    $0x8,%esp
 453:	ff 75 0c             	pushl  0xc(%ebp)
 456:	50                   	push   %eax
 457:	e8 d3 00 00 00       	call   52f <fstat>
 45c:	89 c6                	mov    %eax,%esi
  close(fd);
 45e:	89 1c 24             	mov    %ebx,(%esp)
 461:	e8 99 00 00 00       	call   4ff <close>
  return r;
 466:	83 c4 10             	add    $0x10,%esp
}
 469:	89 f0                	mov    %esi,%eax
 46b:	8d 65 f8             	lea    -0x8(%ebp),%esp
 46e:	5b                   	pop    %ebx
 46f:	5e                   	pop    %esi
 470:	5d                   	pop    %ebp
 471:	c3                   	ret    
    return -1;
 472:	be ff ff ff ff       	mov    $0xffffffff,%esi
 477:	eb f0                	jmp    469 <stat+0x34>

00000479 <atoi>:

int
atoi(const char *s)
{
 479:	55                   	push   %ebp
 47a:	89 e5                	mov    %esp,%ebp
 47c:	53                   	push   %ebx
 47d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 480:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 485:	eb 10                	jmp    497 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 487:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 48a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 48d:	83 c1 01             	add    $0x1,%ecx
 490:	0f be d2             	movsbl %dl,%edx
 493:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 497:	0f b6 11             	movzbl (%ecx),%edx
 49a:	8d 5a d0             	lea    -0x30(%edx),%ebx
 49d:	80 fb 09             	cmp    $0x9,%bl
 4a0:	76 e5                	jbe    487 <atoi+0xe>
  return n;
}
 4a2:	5b                   	pop    %ebx
 4a3:	5d                   	pop    %ebp
 4a4:	c3                   	ret    

000004a5 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a5:	55                   	push   %ebp
 4a6:	89 e5                	mov    %esp,%ebp
 4a8:	56                   	push   %esi
 4a9:	53                   	push   %ebx
 4aa:	8b 45 08             	mov    0x8(%ebp),%eax
 4ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 4b0:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 4b3:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 4b5:	eb 0d                	jmp    4c4 <memmove+0x1f>
    *dst++ = *src++;
 4b7:	0f b6 13             	movzbl (%ebx),%edx
 4ba:	88 11                	mov    %dl,(%ecx)
 4bc:	8d 5b 01             	lea    0x1(%ebx),%ebx
 4bf:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 4c2:	89 f2                	mov    %esi,%edx
 4c4:	8d 72 ff             	lea    -0x1(%edx),%esi
 4c7:	85 d2                	test   %edx,%edx
 4c9:	7f ec                	jg     4b7 <memmove+0x12>
  return vdst;
}
 4cb:	5b                   	pop    %ebx
 4cc:	5e                   	pop    %esi
 4cd:	5d                   	pop    %ebp
 4ce:	c3                   	ret    

000004cf <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4cf:	b8 01 00 00 00       	mov    $0x1,%eax
 4d4:	cd 40                	int    $0x40
 4d6:	c3                   	ret    

000004d7 <exit>:
SYSCALL(exit)
 4d7:	b8 02 00 00 00       	mov    $0x2,%eax
 4dc:	cd 40                	int    $0x40
 4de:	c3                   	ret    

000004df <wait>:
SYSCALL(wait)
 4df:	b8 03 00 00 00       	mov    $0x3,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	ret    

000004e7 <pipe>:
SYSCALL(pipe)
 4e7:	b8 04 00 00 00       	mov    $0x4,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	ret    

000004ef <read>:
SYSCALL(read)
 4ef:	b8 05 00 00 00       	mov    $0x5,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	ret    

000004f7 <write>:
SYSCALL(write)
 4f7:	b8 10 00 00 00       	mov    $0x10,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <close>:
SYSCALL(close)
 4ff:	b8 15 00 00 00       	mov    $0x15,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <kill>:
SYSCALL(kill)
 507:	b8 06 00 00 00       	mov    $0x6,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <exec>:
SYSCALL(exec)
 50f:	b8 07 00 00 00       	mov    $0x7,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <open>:
SYSCALL(open)
 517:	b8 0f 00 00 00       	mov    $0xf,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <mknod>:
SYSCALL(mknod)
 51f:	b8 11 00 00 00       	mov    $0x11,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <unlink>:
SYSCALL(unlink)
 527:	b8 12 00 00 00       	mov    $0x12,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <fstat>:
SYSCALL(fstat)
 52f:	b8 08 00 00 00       	mov    $0x8,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <link>:
SYSCALL(link)
 537:	b8 13 00 00 00       	mov    $0x13,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <mkdir>:
SYSCALL(mkdir)
 53f:	b8 14 00 00 00       	mov    $0x14,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <chdir>:
SYSCALL(chdir)
 547:	b8 09 00 00 00       	mov    $0x9,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	ret    

0000054f <dup>:
SYSCALL(dup)
 54f:	b8 0a 00 00 00       	mov    $0xa,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	ret    

00000557 <getpid>:
SYSCALL(getpid)
 557:	b8 0b 00 00 00       	mov    $0xb,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	ret    

0000055f <sbrk>:
SYSCALL(sbrk)
 55f:	b8 0c 00 00 00       	mov    $0xc,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	ret    

00000567 <sleep>:
SYSCALL(sleep)
 567:	b8 0d 00 00 00       	mov    $0xd,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	ret    

0000056f <uptime>:
SYSCALL(uptime)
 56f:	b8 0e 00 00 00       	mov    $0xe,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	ret    

00000577 <setpri>:
SYSCALL(setpri)
 577:	b8 16 00 00 00       	mov    $0x16,%eax
 57c:	cd 40                	int    $0x40
 57e:	c3                   	ret    

0000057f <getpri>:
SYSCALL(getpri)
 57f:	b8 17 00 00 00       	mov    $0x17,%eax
 584:	cd 40                	int    $0x40
 586:	c3                   	ret    

00000587 <fork2>:
SYSCALL(fork2)
 587:	b8 18 00 00 00       	mov    $0x18,%eax
 58c:	cd 40                	int    $0x40
 58e:	c3                   	ret    

0000058f <getpinfo>:
SYSCALL(getpinfo)
 58f:	b8 19 00 00 00       	mov    $0x19,%eax
 594:	cd 40                	int    $0x40
 596:	c3                   	ret    

00000597 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 597:	55                   	push   %ebp
 598:	89 e5                	mov    %esp,%ebp
 59a:	83 ec 1c             	sub    $0x1c,%esp
 59d:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 5a0:	6a 01                	push   $0x1
 5a2:	8d 55 f4             	lea    -0xc(%ebp),%edx
 5a5:	52                   	push   %edx
 5a6:	50                   	push   %eax
 5a7:	e8 4b ff ff ff       	call   4f7 <write>
}
 5ac:	83 c4 10             	add    $0x10,%esp
 5af:	c9                   	leave  
 5b0:	c3                   	ret    

000005b1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 5b1:	55                   	push   %ebp
 5b2:	89 e5                	mov    %esp,%ebp
 5b4:	57                   	push   %edi
 5b5:	56                   	push   %esi
 5b6:	53                   	push   %ebx
 5b7:	83 ec 2c             	sub    $0x2c,%esp
 5ba:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 5bc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 5c0:	0f 95 c3             	setne  %bl
 5c3:	89 d0                	mov    %edx,%eax
 5c5:	c1 e8 1f             	shr    $0x1f,%eax
 5c8:	84 c3                	test   %al,%bl
 5ca:	74 10                	je     5dc <printint+0x2b>
    neg = 1;
    x = -xx;
 5cc:	f7 da                	neg    %edx
    neg = 1;
 5ce:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 5d5:	be 00 00 00 00       	mov    $0x0,%esi
 5da:	eb 0b                	jmp    5e7 <printint+0x36>
  neg = 0;
 5dc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 5e3:	eb f0                	jmp    5d5 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 5e5:	89 c6                	mov    %eax,%esi
 5e7:	89 d0                	mov    %edx,%eax
 5e9:	ba 00 00 00 00       	mov    $0x0,%edx
 5ee:	f7 f1                	div    %ecx
 5f0:	89 c3                	mov    %eax,%ebx
 5f2:	8d 46 01             	lea    0x1(%esi),%eax
 5f5:	0f b6 92 78 0a 00 00 	movzbl 0xa78(%edx),%edx
 5fc:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 600:	89 da                	mov    %ebx,%edx
 602:	85 db                	test   %ebx,%ebx
 604:	75 df                	jne    5e5 <printint+0x34>
 606:	89 c3                	mov    %eax,%ebx
  if(neg)
 608:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 60c:	74 16                	je     624 <printint+0x73>
    buf[i++] = '-';
 60e:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 613:	8d 5e 02             	lea    0x2(%esi),%ebx
 616:	eb 0c                	jmp    624 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 618:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 61d:	89 f8                	mov    %edi,%eax
 61f:	e8 73 ff ff ff       	call   597 <putc>
  while(--i >= 0)
 624:	83 eb 01             	sub    $0x1,%ebx
 627:	79 ef                	jns    618 <printint+0x67>
}
 629:	83 c4 2c             	add    $0x2c,%esp
 62c:	5b                   	pop    %ebx
 62d:	5e                   	pop    %esi
 62e:	5f                   	pop    %edi
 62f:	5d                   	pop    %ebp
 630:	c3                   	ret    

00000631 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 631:	55                   	push   %ebp
 632:	89 e5                	mov    %esp,%ebp
 634:	57                   	push   %edi
 635:	56                   	push   %esi
 636:	53                   	push   %ebx
 637:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 63a:	8d 45 10             	lea    0x10(%ebp),%eax
 63d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 640:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 645:	bb 00 00 00 00       	mov    $0x0,%ebx
 64a:	eb 14                	jmp    660 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 64c:	89 fa                	mov    %edi,%edx
 64e:	8b 45 08             	mov    0x8(%ebp),%eax
 651:	e8 41 ff ff ff       	call   597 <putc>
 656:	eb 05                	jmp    65d <printf+0x2c>
      }
    } else if(state == '%'){
 658:	83 fe 25             	cmp    $0x25,%esi
 65b:	74 25                	je     682 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 65d:	83 c3 01             	add    $0x1,%ebx
 660:	8b 45 0c             	mov    0xc(%ebp),%eax
 663:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 667:	84 c0                	test   %al,%al
 669:	0f 84 23 01 00 00    	je     792 <printf+0x161>
    c = fmt[i] & 0xff;
 66f:	0f be f8             	movsbl %al,%edi
 672:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 675:	85 f6                	test   %esi,%esi
 677:	75 df                	jne    658 <printf+0x27>
      if(c == '%'){
 679:	83 f8 25             	cmp    $0x25,%eax
 67c:	75 ce                	jne    64c <printf+0x1b>
        state = '%';
 67e:	89 c6                	mov    %eax,%esi
 680:	eb db                	jmp    65d <printf+0x2c>
      if(c == 'd'){
 682:	83 f8 64             	cmp    $0x64,%eax
 685:	74 49                	je     6d0 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 687:	83 f8 78             	cmp    $0x78,%eax
 68a:	0f 94 c1             	sete   %cl
 68d:	83 f8 70             	cmp    $0x70,%eax
 690:	0f 94 c2             	sete   %dl
 693:	08 d1                	or     %dl,%cl
 695:	75 63                	jne    6fa <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 697:	83 f8 73             	cmp    $0x73,%eax
 69a:	0f 84 84 00 00 00    	je     724 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 6a0:	83 f8 63             	cmp    $0x63,%eax
 6a3:	0f 84 b7 00 00 00    	je     760 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 6a9:	83 f8 25             	cmp    $0x25,%eax
 6ac:	0f 84 cc 00 00 00    	je     77e <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6b2:	ba 25 00 00 00       	mov    $0x25,%edx
 6b7:	8b 45 08             	mov    0x8(%ebp),%eax
 6ba:	e8 d8 fe ff ff       	call   597 <putc>
        putc(fd, c);
 6bf:	89 fa                	mov    %edi,%edx
 6c1:	8b 45 08             	mov    0x8(%ebp),%eax
 6c4:	e8 ce fe ff ff       	call   597 <putc>
      }
      state = 0;
 6c9:	be 00 00 00 00       	mov    $0x0,%esi
 6ce:	eb 8d                	jmp    65d <printf+0x2c>
        printint(fd, *ap, 10, 1);
 6d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 6d3:	8b 17                	mov    (%edi),%edx
 6d5:	83 ec 0c             	sub    $0xc,%esp
 6d8:	6a 01                	push   $0x1
 6da:	b9 0a 00 00 00       	mov    $0xa,%ecx
 6df:	8b 45 08             	mov    0x8(%ebp),%eax
 6e2:	e8 ca fe ff ff       	call   5b1 <printint>
        ap++;
 6e7:	83 c7 04             	add    $0x4,%edi
 6ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 6ed:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6f0:	be 00 00 00 00       	mov    $0x0,%esi
 6f5:	e9 63 ff ff ff       	jmp    65d <printf+0x2c>
        printint(fd, *ap, 16, 0);
 6fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 6fd:	8b 17                	mov    (%edi),%edx
 6ff:	83 ec 0c             	sub    $0xc,%esp
 702:	6a 00                	push   $0x0
 704:	b9 10 00 00 00       	mov    $0x10,%ecx
 709:	8b 45 08             	mov    0x8(%ebp),%eax
 70c:	e8 a0 fe ff ff       	call   5b1 <printint>
        ap++;
 711:	83 c7 04             	add    $0x4,%edi
 714:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 717:	83 c4 10             	add    $0x10,%esp
      state = 0;
 71a:	be 00 00 00 00       	mov    $0x0,%esi
 71f:	e9 39 ff ff ff       	jmp    65d <printf+0x2c>
        s = (char*)*ap;
 724:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 727:	8b 30                	mov    (%eax),%esi
        ap++;
 729:	83 c0 04             	add    $0x4,%eax
 72c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 72f:	85 f6                	test   %esi,%esi
 731:	75 28                	jne    75b <printf+0x12a>
          s = "(null)";
 733:	be 70 0a 00 00       	mov    $0xa70,%esi
 738:	8b 7d 08             	mov    0x8(%ebp),%edi
 73b:	eb 0d                	jmp    74a <printf+0x119>
          putc(fd, *s);
 73d:	0f be d2             	movsbl %dl,%edx
 740:	89 f8                	mov    %edi,%eax
 742:	e8 50 fe ff ff       	call   597 <putc>
          s++;
 747:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 74a:	0f b6 16             	movzbl (%esi),%edx
 74d:	84 d2                	test   %dl,%dl
 74f:	75 ec                	jne    73d <printf+0x10c>
      state = 0;
 751:	be 00 00 00 00       	mov    $0x0,%esi
 756:	e9 02 ff ff ff       	jmp    65d <printf+0x2c>
 75b:	8b 7d 08             	mov    0x8(%ebp),%edi
 75e:	eb ea                	jmp    74a <printf+0x119>
        putc(fd, *ap);
 760:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 763:	0f be 17             	movsbl (%edi),%edx
 766:	8b 45 08             	mov    0x8(%ebp),%eax
 769:	e8 29 fe ff ff       	call   597 <putc>
        ap++;
 76e:	83 c7 04             	add    $0x4,%edi
 771:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 774:	be 00 00 00 00       	mov    $0x0,%esi
 779:	e9 df fe ff ff       	jmp    65d <printf+0x2c>
        putc(fd, c);
 77e:	89 fa                	mov    %edi,%edx
 780:	8b 45 08             	mov    0x8(%ebp),%eax
 783:	e8 0f fe ff ff       	call   597 <putc>
      state = 0;
 788:	be 00 00 00 00       	mov    $0x0,%esi
 78d:	e9 cb fe ff ff       	jmp    65d <printf+0x2c>
    }
  }
}
 792:	8d 65 f4             	lea    -0xc(%ebp),%esp
 795:	5b                   	pop    %ebx
 796:	5e                   	pop    %esi
 797:	5f                   	pop    %edi
 798:	5d                   	pop    %ebp
 799:	c3                   	ret    

0000079a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79a:	55                   	push   %ebp
 79b:	89 e5                	mov    %esp,%ebp
 79d:	57                   	push   %edi
 79e:	56                   	push   %esi
 79f:	53                   	push   %ebx
 7a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a3:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a6:	a1 44 0d 00 00       	mov    0xd44,%eax
 7ab:	eb 02                	jmp    7af <free+0x15>
 7ad:	89 d0                	mov    %edx,%eax
 7af:	39 c8                	cmp    %ecx,%eax
 7b1:	73 04                	jae    7b7 <free+0x1d>
 7b3:	39 08                	cmp    %ecx,(%eax)
 7b5:	77 12                	ja     7c9 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b7:	8b 10                	mov    (%eax),%edx
 7b9:	39 c2                	cmp    %eax,%edx
 7bb:	77 f0                	ja     7ad <free+0x13>
 7bd:	39 c8                	cmp    %ecx,%eax
 7bf:	72 08                	jb     7c9 <free+0x2f>
 7c1:	39 ca                	cmp    %ecx,%edx
 7c3:	77 04                	ja     7c9 <free+0x2f>
 7c5:	89 d0                	mov    %edx,%eax
 7c7:	eb e6                	jmp    7af <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7c9:	8b 73 fc             	mov    -0x4(%ebx),%esi
 7cc:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 7cf:	8b 10                	mov    (%eax),%edx
 7d1:	39 d7                	cmp    %edx,%edi
 7d3:	74 19                	je     7ee <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 7d5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 7d8:	8b 50 04             	mov    0x4(%eax),%edx
 7db:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 7de:	39 ce                	cmp    %ecx,%esi
 7e0:	74 1b                	je     7fd <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 7e2:	89 08                	mov    %ecx,(%eax)
  freep = p;
 7e4:	a3 44 0d 00 00       	mov    %eax,0xd44
}
 7e9:	5b                   	pop    %ebx
 7ea:	5e                   	pop    %esi
 7eb:	5f                   	pop    %edi
 7ec:	5d                   	pop    %ebp
 7ed:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 7ee:	03 72 04             	add    0x4(%edx),%esi
 7f1:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f4:	8b 10                	mov    (%eax),%edx
 7f6:	8b 12                	mov    (%edx),%edx
 7f8:	89 53 f8             	mov    %edx,-0x8(%ebx)
 7fb:	eb db                	jmp    7d8 <free+0x3e>
    p->s.size += bp->s.size;
 7fd:	03 53 fc             	add    -0x4(%ebx),%edx
 800:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 803:	8b 53 f8             	mov    -0x8(%ebx),%edx
 806:	89 10                	mov    %edx,(%eax)
 808:	eb da                	jmp    7e4 <free+0x4a>

0000080a <morecore>:

static Header*
morecore(uint nu)
{
 80a:	55                   	push   %ebp
 80b:	89 e5                	mov    %esp,%ebp
 80d:	53                   	push   %ebx
 80e:	83 ec 04             	sub    $0x4,%esp
 811:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 813:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 818:	77 05                	ja     81f <morecore+0x15>
    nu = 4096;
 81a:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 81f:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 826:	83 ec 0c             	sub    $0xc,%esp
 829:	50                   	push   %eax
 82a:	e8 30 fd ff ff       	call   55f <sbrk>
  if(p == (char*)-1)
 82f:	83 c4 10             	add    $0x10,%esp
 832:	83 f8 ff             	cmp    $0xffffffff,%eax
 835:	74 1c                	je     853 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 837:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 83a:	83 c0 08             	add    $0x8,%eax
 83d:	83 ec 0c             	sub    $0xc,%esp
 840:	50                   	push   %eax
 841:	e8 54 ff ff ff       	call   79a <free>
  return freep;
 846:	a1 44 0d 00 00       	mov    0xd44,%eax
 84b:	83 c4 10             	add    $0x10,%esp
}
 84e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 851:	c9                   	leave  
 852:	c3                   	ret    
    return 0;
 853:	b8 00 00 00 00       	mov    $0x0,%eax
 858:	eb f4                	jmp    84e <morecore+0x44>

0000085a <malloc>:

void*
malloc(uint nbytes)
{
 85a:	55                   	push   %ebp
 85b:	89 e5                	mov    %esp,%ebp
 85d:	53                   	push   %ebx
 85e:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 861:	8b 45 08             	mov    0x8(%ebp),%eax
 864:	8d 58 07             	lea    0x7(%eax),%ebx
 867:	c1 eb 03             	shr    $0x3,%ebx
 86a:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 86d:	8b 0d 44 0d 00 00    	mov    0xd44,%ecx
 873:	85 c9                	test   %ecx,%ecx
 875:	74 04                	je     87b <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 877:	8b 01                	mov    (%ecx),%eax
 879:	eb 4d                	jmp    8c8 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 87b:	c7 05 44 0d 00 00 48 	movl   $0xd48,0xd44
 882:	0d 00 00 
 885:	c7 05 48 0d 00 00 48 	movl   $0xd48,0xd48
 88c:	0d 00 00 
    base.s.size = 0;
 88f:	c7 05 4c 0d 00 00 00 	movl   $0x0,0xd4c
 896:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 899:	b9 48 0d 00 00       	mov    $0xd48,%ecx
 89e:	eb d7                	jmp    877 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 8a0:	39 da                	cmp    %ebx,%edx
 8a2:	74 1a                	je     8be <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 8a4:	29 da                	sub    %ebx,%edx
 8a6:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 8a9:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 8ac:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 8af:	89 0d 44 0d 00 00    	mov    %ecx,0xd44
      return (void*)(p + 1);
 8b5:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8b8:	83 c4 04             	add    $0x4,%esp
 8bb:	5b                   	pop    %ebx
 8bc:	5d                   	pop    %ebp
 8bd:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 8be:	8b 10                	mov    (%eax),%edx
 8c0:	89 11                	mov    %edx,(%ecx)
 8c2:	eb eb                	jmp    8af <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	89 c1                	mov    %eax,%ecx
 8c6:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 8c8:	8b 50 04             	mov    0x4(%eax),%edx
 8cb:	39 da                	cmp    %ebx,%edx
 8cd:	73 d1                	jae    8a0 <malloc+0x46>
    if(p == freep)
 8cf:	39 05 44 0d 00 00    	cmp    %eax,0xd44
 8d5:	75 ed                	jne    8c4 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 8d7:	89 d8                	mov    %ebx,%eax
 8d9:	e8 2c ff ff ff       	call   80a <morecore>
 8de:	85 c0                	test   %eax,%eax
 8e0:	75 e2                	jne    8c4 <malloc+0x6a>
        return 0;
 8e2:	b8 00 00 00 00       	mov    $0x0,%eax
 8e7:	eb cf                	jmp    8b8 <malloc+0x5e>
