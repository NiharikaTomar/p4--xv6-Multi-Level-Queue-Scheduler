
_test_16:     file format elf32-i386


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

  if (t > 0){
  27:	85 c9                	test   %ecx,%ecx
  29:	7f 07                	jg     32 <workload+0x32>
    //printf(1, "SLEEP\n");
    sleep(t);
  }
  for (i = 0; i < n; i++) {
  2b:	b8 00 00 00 00       	mov    $0x0,%eax
  30:	eb 1a                	jmp    4c <workload+0x4c>
    sleep(t);
  32:	83 ec 0c             	sub    $0xc,%esp
  35:	51                   	push   %ecx
  36:	e8 1c 04 00 00       	call   457 <sleep>
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
  6a:	81 ec 34 0c 00 00    	sub    $0xc34,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  70:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  76:	50                   	push   %eax
  77:	e8 03 04 00 00       	call   47f <getpinfo>
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
  int c_pid[2];
  // Launch the 4 processes, but process 2 will sleep in the middle
  for (i = 0; i < 2; i++) {
  92:	83 c4 10             	add    $0x10,%esp
  95:	bb 00 00 00 00       	mov    $0x0,%ebx
  9a:	83 fb 01             	cmp    $0x1,%ebx
  9d:	7f 66                	jg     105 <main+0xac>
    c_pid[i] = fork2(0);
  9f:	83 ec 0c             	sub    $0xc,%esp
  a2:	6a 00                	push   $0x0
  a4:	e8 ce 03 00 00       	call   477 <fork2>
  a9:	89 c1                	mov    %eax,%ecx
  ab:	89 84 9d e0 f3 ff ff 	mov    %eax,-0xc20(%ebp,%ebx,4)
    int t = 0;
    // Child
    if (c_pid[i] == 0) {
  b2:	83 c4 10             	add    $0x10,%esp
  b5:	85 c0                	test   %eax,%eax
  b7:	74 25                	je     de <main+0x85>
  for (i = 0; i < 2; i++) {
  b9:	83 c3 01             	add    $0x1,%ebx
  bc:	eb dc                	jmp    9a <main+0x41>
  check(getpinfo(&st) == 0, "getpinfo");
  be:	83 ec 0c             	sub    $0xc,%esp
  c1:	68 dc 07 00 00       	push   $0x7dc
  c6:	6a 27                	push   $0x27
  c8:	68 e5 07 00 00       	push   $0x7e5
  cd:	68 20 08 00 00       	push   $0x820
  d2:	6a 01                	push   $0x1
  d4:	e8 48 04 00 00       	call   521 <printf>
  d9:	83 c4 20             	add    $0x20,%esp
  dc:	eb a5                	jmp    83 <main+0x2a>
      if (i % 2 == 1) {
  de:	be 02 00 00 00       	mov    $0x2,%esi
  e3:	89 d8                	mov    %ebx,%eax
  e5:	99                   	cltd   
  e6:	f7 fe                	idiv   %esi
  e8:	83 fa 01             	cmp    $0x1,%edx
  eb:	75 05                	jne    f2 <main+0x99>
          t = 12; // for this process, give up CPU for one time-slice
  ed:	b9 0c 00 00 00       	mov    $0xc,%ecx
      }
      workload(600000000, t);
  f2:	83 ec 08             	sub    $0x8,%esp
  f5:	51                   	push   %ecx
  f6:	68 00 46 c3 23       	push   $0x23c34600
  fb:	e8 00 ff ff ff       	call   0 <workload>
      exit();
 100:	e8 c2 02 00 00       	call   3c7 <exit>
    } else {
      //setpri(c_pid, 2);
    }
  }

  for (i = 0; i < 12; i++) { 
 105:	c7 85 d4 f3 ff ff 00 	movl   $0x0,-0xc2c(%ebp)
 10c:	00 00 00 
 10f:	e9 d7 00 00 00       	jmp    1eb <main+0x192>
    sleep(20);
    check(getpinfo(&st) == 0, "getpinfo");
 114:	83 ec 0c             	sub    $0xc,%esp
 117:	68 dc 07 00 00       	push   $0x7dc
 11c:	6a 40                	push   $0x40
 11e:	68 e5 07 00 00       	push   $0x7e5
 123:	68 20 08 00 00       	push   $0x820
 128:	6a 01                	push   $0x1
 12a:	e8 f2 03 00 00       	call   521 <printf>
 12f:	83 c4 20             	add    $0x20,%esp
 132:	e9 e0 00 00 00       	jmp    217 <main+0x1be>
    
    for (j = 0; j < NPROC; j++) {
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
        if(st.pid[j] == c_pid[0]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 1\n"));
 137:	83 ec 08             	sub    $0x8,%esp
 13a:	68 ef 07 00 00       	push   $0x7ef
 13f:	6a 01                	push   $0x1
 141:	e8 db 03 00 00       	call   521 <printf>
 146:	83 c4 10             	add    $0x10,%esp
 149:	e9 8f 00 00 00       	jmp    1dd <main+0x184>
        }
        else if(st.pid[j] == c_pid[1]){
          DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD 2\n"));
 14e:	83 ec 08             	sub    $0x8,%esp
 151:	68 07 08 00 00       	push   $0x807
 156:	6a 01                	push   $0x1
 158:	e8 c4 03 00 00       	call   521 <printf>
 15d:	83 c4 10             	add    $0x10,%esp
 160:	eb 7b                	jmp    1dd <main+0x184>
        }
  
        //DEBUG_PRINT((1, "pid: %d\n", st.pid[j]));
        for (k = 3; k >= 0; k--) {
          DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d ticks used %d\n", k, st.ticks[j][k]));
 162:	8d 3c 9e             	lea    (%esi,%ebx,4),%edi
 165:	ff b4 bd e8 f7 ff ff 	pushl  -0x818(%ebp,%edi,4)
 16c:	56                   	push   %esi
 16d:	68 50 08 00 00       	push   $0x850
 172:	6a 01                	push   $0x1
 174:	e8 a8 03 00 00       	call   521 <printf>
	  DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d qtail %d\n", k, st.qtail[j][k]));
 179:	ff b4 bd e8 fb ff ff 	pushl  -0x418(%ebp,%edi,4)
 180:	56                   	push   %esi
 181:	68 7c 08 00 00       	push   $0x87c
 186:	6a 01                	push   $0x1
 188:	e8 94 03 00 00       	call   521 <printf>
        for (k = 3; k >= 0; k--) {
 18d:	83 ee 01             	sub    $0x1,%esi
 190:	83 c4 20             	add    $0x20,%esp
 193:	85 f6                	test   %esi,%esi
 195:	79 cb                	jns    162 <main+0x109>
    for (j = 0; j < NPROC; j++) {
 197:	83 c3 01             	add    $0x1,%ebx
 19a:	83 fb 3f             	cmp    $0x3f,%ebx
 19d:	7f 45                	jg     1e4 <main+0x18b>
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
 19f:	83 bc 9d e8 f3 ff ff 	cmpl   $0x0,-0xc18(%ebp,%ebx,4)
 1a6:	00 
 1a7:	74 ee                	je     197 <main+0x13e>
 1a9:	8b b4 9d e8 f4 ff ff 	mov    -0xb18(%ebp,%ebx,4),%esi
 1b0:	83 fe 02             	cmp    $0x2,%esi
 1b3:	7e e2                	jle    197 <main+0x13e>
 1b5:	e8 8d 02 00 00       	call   447 <getpid>
 1ba:	39 c6                	cmp    %eax,%esi
 1bc:	74 d9                	je     197 <main+0x13e>
        if(st.pid[j] == c_pid[0]){
 1be:	8b 84 9d e8 f4 ff ff 	mov    -0xb18(%ebp,%ebx,4),%eax
 1c5:	3b 85 e0 f3 ff ff    	cmp    -0xc20(%ebp),%eax
 1cb:	0f 84 66 ff ff ff    	je     137 <main+0xde>
        else if(st.pid[j] == c_pid[1]){
 1d1:	3b 85 e4 f3 ff ff    	cmp    -0xc1c(%ebp),%eax
 1d7:	0f 84 71 ff ff ff    	je     14e <main+0xf5>
  for (i = 0; i < 2; i++) {
 1dd:	be 03 00 00 00       	mov    $0x3,%esi
 1e2:	eb af                	jmp    193 <main+0x13a>
  for (i = 0; i < 12; i++) { 
 1e4:	83 85 d4 f3 ff ff 01 	addl   $0x1,-0xc2c(%ebp)
 1eb:	83 bd d4 f3 ff ff 0b 	cmpl   $0xb,-0xc2c(%ebp)
 1f2:	7f 2d                	jg     221 <main+0x1c8>
    sleep(20);
 1f4:	83 ec 0c             	sub    $0xc,%esp
 1f7:	6a 14                	push   $0x14
 1f9:	e8 59 02 00 00       	call   457 <sleep>
    check(getpinfo(&st) == 0, "getpinfo");
 1fe:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 204:	89 04 24             	mov    %eax,(%esp)
 207:	e8 73 02 00 00       	call   47f <getpinfo>
 20c:	83 c4 10             	add    $0x10,%esp
 20f:	85 c0                	test   %eax,%eax
 211:	0f 85 fd fe ff ff    	jne    114 <main+0xbb>
  for (i = 0; i < 2; i++) {
 217:	bb 00 00 00 00       	mov    $0x0,%ebx
 21c:	e9 79 ff ff ff       	jmp    19a <main+0x141>
        }
      } 
    }
  }

  for (i = 0; i < 2; i++) {
 221:	bb 00 00 00 00       	mov    $0x0,%ebx
 226:	eb 08                	jmp    230 <main+0x1d7>
    wait();
 228:	e8 a2 01 00 00       	call   3cf <wait>
  for (i = 0; i < 2; i++) {
 22d:	83 c3 01             	add    $0x1,%ebx
 230:	83 fb 01             	cmp    $0x1,%ebx
 233:	7e f3                	jle    228 <main+0x1cf>
  }

  //printf(1, "TEST PASSED");

  exit();
 235:	e8 8d 01 00 00       	call   3c7 <exit>

0000023a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 23a:	55                   	push   %ebp
 23b:	89 e5                	mov    %esp,%ebp
 23d:	53                   	push   %ebx
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 244:	89 c2                	mov    %eax,%edx
 246:	0f b6 19             	movzbl (%ecx),%ebx
 249:	88 1a                	mov    %bl,(%edx)
 24b:	8d 52 01             	lea    0x1(%edx),%edx
 24e:	8d 49 01             	lea    0x1(%ecx),%ecx
 251:	84 db                	test   %bl,%bl
 253:	75 f1                	jne    246 <strcpy+0xc>
    ;
  return os;
}
 255:	5b                   	pop    %ebx
 256:	5d                   	pop    %ebp
 257:	c3                   	ret    

00000258 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 258:	55                   	push   %ebp
 259:	89 e5                	mov    %esp,%ebp
 25b:	8b 4d 08             	mov    0x8(%ebp),%ecx
 25e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 261:	eb 06                	jmp    269 <strcmp+0x11>
    p++, q++;
 263:	83 c1 01             	add    $0x1,%ecx
 266:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 269:	0f b6 01             	movzbl (%ecx),%eax
 26c:	84 c0                	test   %al,%al
 26e:	74 04                	je     274 <strcmp+0x1c>
 270:	3a 02                	cmp    (%edx),%al
 272:	74 ef                	je     263 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 274:	0f b6 c0             	movzbl %al,%eax
 277:	0f b6 12             	movzbl (%edx),%edx
 27a:	29 d0                	sub    %edx,%eax
}
 27c:	5d                   	pop    %ebp
 27d:	c3                   	ret    

0000027e <strlen>:

uint
strlen(const char *s)
{
 27e:	55                   	push   %ebp
 27f:	89 e5                	mov    %esp,%ebp
 281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 284:	ba 00 00 00 00       	mov    $0x0,%edx
 289:	eb 03                	jmp    28e <strlen+0x10>
 28b:	83 c2 01             	add    $0x1,%edx
 28e:	89 d0                	mov    %edx,%eax
 290:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 294:	75 f5                	jne    28b <strlen+0xd>
    ;
  return n;
}
 296:	5d                   	pop    %ebp
 297:	c3                   	ret    

00000298 <memset>:

void*
memset(void *dst, int c, uint n)
{
 298:	55                   	push   %ebp
 299:	89 e5                	mov    %esp,%ebp
 29b:	57                   	push   %edi
 29c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 29f:	89 d7                	mov    %edx,%edi
 2a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a7:	fc                   	cld    
 2a8:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2aa:	89 d0                	mov    %edx,%eax
 2ac:	5f                   	pop    %edi
 2ad:	5d                   	pop    %ebp
 2ae:	c3                   	ret    

000002af <strchr>:

char*
strchr(const char *s, char c)
{
 2af:	55                   	push   %ebp
 2b0:	89 e5                	mov    %esp,%ebp
 2b2:	8b 45 08             	mov    0x8(%ebp),%eax
 2b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 2b9:	0f b6 10             	movzbl (%eax),%edx
 2bc:	84 d2                	test   %dl,%dl
 2be:	74 09                	je     2c9 <strchr+0x1a>
    if(*s == c)
 2c0:	38 ca                	cmp    %cl,%dl
 2c2:	74 0a                	je     2ce <strchr+0x1f>
  for(; *s; s++)
 2c4:	83 c0 01             	add    $0x1,%eax
 2c7:	eb f0                	jmp    2b9 <strchr+0xa>
      return (char*)s;
  return 0;
 2c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2ce:	5d                   	pop    %ebp
 2cf:	c3                   	ret    

000002d0 <gets>:

char*
gets(char *buf, int max)
{
 2d0:	55                   	push   %ebp
 2d1:	89 e5                	mov    %esp,%ebp
 2d3:	57                   	push   %edi
 2d4:	56                   	push   %esi
 2d5:	53                   	push   %ebx
 2d6:	83 ec 1c             	sub    $0x1c,%esp
 2d9:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2dc:	bb 00 00 00 00       	mov    $0x0,%ebx
 2e1:	8d 73 01             	lea    0x1(%ebx),%esi
 2e4:	3b 75 0c             	cmp    0xc(%ebp),%esi
 2e7:	7d 2e                	jge    317 <gets+0x47>
    cc = read(0, &c, 1);
 2e9:	83 ec 04             	sub    $0x4,%esp
 2ec:	6a 01                	push   $0x1
 2ee:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2f1:	50                   	push   %eax
 2f2:	6a 00                	push   $0x0
 2f4:	e8 e6 00 00 00       	call   3df <read>
    if(cc < 1)
 2f9:	83 c4 10             	add    $0x10,%esp
 2fc:	85 c0                	test   %eax,%eax
 2fe:	7e 17                	jle    317 <gets+0x47>
      break;
    buf[i++] = c;
 300:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 304:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 307:	3c 0a                	cmp    $0xa,%al
 309:	0f 94 c2             	sete   %dl
 30c:	3c 0d                	cmp    $0xd,%al
 30e:	0f 94 c0             	sete   %al
    buf[i++] = c;
 311:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 313:	08 c2                	or     %al,%dl
 315:	74 ca                	je     2e1 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 317:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 31b:	89 f8                	mov    %edi,%eax
 31d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 320:	5b                   	pop    %ebx
 321:	5e                   	pop    %esi
 322:	5f                   	pop    %edi
 323:	5d                   	pop    %ebp
 324:	c3                   	ret    

00000325 <stat>:

int
stat(const char *n, struct stat *st)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	56                   	push   %esi
 329:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 32a:	83 ec 08             	sub    $0x8,%esp
 32d:	6a 00                	push   $0x0
 32f:	ff 75 08             	pushl  0x8(%ebp)
 332:	e8 d0 00 00 00       	call   407 <open>
  if(fd < 0)
 337:	83 c4 10             	add    $0x10,%esp
 33a:	85 c0                	test   %eax,%eax
 33c:	78 24                	js     362 <stat+0x3d>
 33e:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 340:	83 ec 08             	sub    $0x8,%esp
 343:	ff 75 0c             	pushl  0xc(%ebp)
 346:	50                   	push   %eax
 347:	e8 d3 00 00 00       	call   41f <fstat>
 34c:	89 c6                	mov    %eax,%esi
  close(fd);
 34e:	89 1c 24             	mov    %ebx,(%esp)
 351:	e8 99 00 00 00       	call   3ef <close>
  return r;
 356:	83 c4 10             	add    $0x10,%esp
}
 359:	89 f0                	mov    %esi,%eax
 35b:	8d 65 f8             	lea    -0x8(%ebp),%esp
 35e:	5b                   	pop    %ebx
 35f:	5e                   	pop    %esi
 360:	5d                   	pop    %ebp
 361:	c3                   	ret    
    return -1;
 362:	be ff ff ff ff       	mov    $0xffffffff,%esi
 367:	eb f0                	jmp    359 <stat+0x34>

00000369 <atoi>:

int
atoi(const char *s)
{
 369:	55                   	push   %ebp
 36a:	89 e5                	mov    %esp,%ebp
 36c:	53                   	push   %ebx
 36d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 370:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 375:	eb 10                	jmp    387 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 377:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 37a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 37d:	83 c1 01             	add    $0x1,%ecx
 380:	0f be d2             	movsbl %dl,%edx
 383:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 387:	0f b6 11             	movzbl (%ecx),%edx
 38a:	8d 5a d0             	lea    -0x30(%edx),%ebx
 38d:	80 fb 09             	cmp    $0x9,%bl
 390:	76 e5                	jbe    377 <atoi+0xe>
  return n;
}
 392:	5b                   	pop    %ebx
 393:	5d                   	pop    %ebp
 394:	c3                   	ret    

00000395 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 395:	55                   	push   %ebp
 396:	89 e5                	mov    %esp,%ebp
 398:	56                   	push   %esi
 399:	53                   	push   %ebx
 39a:	8b 45 08             	mov    0x8(%ebp),%eax
 39d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 3a0:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 3a3:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 3a5:	eb 0d                	jmp    3b4 <memmove+0x1f>
    *dst++ = *src++;
 3a7:	0f b6 13             	movzbl (%ebx),%edx
 3aa:	88 11                	mov    %dl,(%ecx)
 3ac:	8d 5b 01             	lea    0x1(%ebx),%ebx
 3af:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 3b2:	89 f2                	mov    %esi,%edx
 3b4:	8d 72 ff             	lea    -0x1(%edx),%esi
 3b7:	85 d2                	test   %edx,%edx
 3b9:	7f ec                	jg     3a7 <memmove+0x12>
  return vdst;
}
 3bb:	5b                   	pop    %ebx
 3bc:	5e                   	pop    %esi
 3bd:	5d                   	pop    %ebp
 3be:	c3                   	ret    

000003bf <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3bf:	b8 01 00 00 00       	mov    $0x1,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <exit>:
SYSCALL(exit)
 3c7:	b8 02 00 00 00       	mov    $0x2,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <wait>:
SYSCALL(wait)
 3cf:	b8 03 00 00 00       	mov    $0x3,%eax
 3d4:	cd 40                	int    $0x40
 3d6:	c3                   	ret    

000003d7 <pipe>:
SYSCALL(pipe)
 3d7:	b8 04 00 00 00       	mov    $0x4,%eax
 3dc:	cd 40                	int    $0x40
 3de:	c3                   	ret    

000003df <read>:
SYSCALL(read)
 3df:	b8 05 00 00 00       	mov    $0x5,%eax
 3e4:	cd 40                	int    $0x40
 3e6:	c3                   	ret    

000003e7 <write>:
SYSCALL(write)
 3e7:	b8 10 00 00 00       	mov    $0x10,%eax
 3ec:	cd 40                	int    $0x40
 3ee:	c3                   	ret    

000003ef <close>:
SYSCALL(close)
 3ef:	b8 15 00 00 00       	mov    $0x15,%eax
 3f4:	cd 40                	int    $0x40
 3f6:	c3                   	ret    

000003f7 <kill>:
SYSCALL(kill)
 3f7:	b8 06 00 00 00       	mov    $0x6,%eax
 3fc:	cd 40                	int    $0x40
 3fe:	c3                   	ret    

000003ff <exec>:
SYSCALL(exec)
 3ff:	b8 07 00 00 00       	mov    $0x7,%eax
 404:	cd 40                	int    $0x40
 406:	c3                   	ret    

00000407 <open>:
SYSCALL(open)
 407:	b8 0f 00 00 00       	mov    $0xf,%eax
 40c:	cd 40                	int    $0x40
 40e:	c3                   	ret    

0000040f <mknod>:
SYSCALL(mknod)
 40f:	b8 11 00 00 00       	mov    $0x11,%eax
 414:	cd 40                	int    $0x40
 416:	c3                   	ret    

00000417 <unlink>:
SYSCALL(unlink)
 417:	b8 12 00 00 00       	mov    $0x12,%eax
 41c:	cd 40                	int    $0x40
 41e:	c3                   	ret    

0000041f <fstat>:
SYSCALL(fstat)
 41f:	b8 08 00 00 00       	mov    $0x8,%eax
 424:	cd 40                	int    $0x40
 426:	c3                   	ret    

00000427 <link>:
SYSCALL(link)
 427:	b8 13 00 00 00       	mov    $0x13,%eax
 42c:	cd 40                	int    $0x40
 42e:	c3                   	ret    

0000042f <mkdir>:
SYSCALL(mkdir)
 42f:	b8 14 00 00 00       	mov    $0x14,%eax
 434:	cd 40                	int    $0x40
 436:	c3                   	ret    

00000437 <chdir>:
SYSCALL(chdir)
 437:	b8 09 00 00 00       	mov    $0x9,%eax
 43c:	cd 40                	int    $0x40
 43e:	c3                   	ret    

0000043f <dup>:
SYSCALL(dup)
 43f:	b8 0a 00 00 00       	mov    $0xa,%eax
 444:	cd 40                	int    $0x40
 446:	c3                   	ret    

00000447 <getpid>:
SYSCALL(getpid)
 447:	b8 0b 00 00 00       	mov    $0xb,%eax
 44c:	cd 40                	int    $0x40
 44e:	c3                   	ret    

0000044f <sbrk>:
SYSCALL(sbrk)
 44f:	b8 0c 00 00 00       	mov    $0xc,%eax
 454:	cd 40                	int    $0x40
 456:	c3                   	ret    

00000457 <sleep>:
SYSCALL(sleep)
 457:	b8 0d 00 00 00       	mov    $0xd,%eax
 45c:	cd 40                	int    $0x40
 45e:	c3                   	ret    

0000045f <uptime>:
SYSCALL(uptime)
 45f:	b8 0e 00 00 00       	mov    $0xe,%eax
 464:	cd 40                	int    $0x40
 466:	c3                   	ret    

00000467 <setpri>:
SYSCALL(setpri)
 467:	b8 16 00 00 00       	mov    $0x16,%eax
 46c:	cd 40                	int    $0x40
 46e:	c3                   	ret    

0000046f <getpri>:
SYSCALL(getpri)
 46f:	b8 17 00 00 00       	mov    $0x17,%eax
 474:	cd 40                	int    $0x40
 476:	c3                   	ret    

00000477 <fork2>:
SYSCALL(fork2)
 477:	b8 18 00 00 00       	mov    $0x18,%eax
 47c:	cd 40                	int    $0x40
 47e:	c3                   	ret    

0000047f <getpinfo>:
SYSCALL(getpinfo)
 47f:	b8 19 00 00 00       	mov    $0x19,%eax
 484:	cd 40                	int    $0x40
 486:	c3                   	ret    

00000487 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 487:	55                   	push   %ebp
 488:	89 e5                	mov    %esp,%ebp
 48a:	83 ec 1c             	sub    $0x1c,%esp
 48d:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 490:	6a 01                	push   $0x1
 492:	8d 55 f4             	lea    -0xc(%ebp),%edx
 495:	52                   	push   %edx
 496:	50                   	push   %eax
 497:	e8 4b ff ff ff       	call   3e7 <write>
}
 49c:	83 c4 10             	add    $0x10,%esp
 49f:	c9                   	leave  
 4a0:	c3                   	ret    

000004a1 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a1:	55                   	push   %ebp
 4a2:	89 e5                	mov    %esp,%ebp
 4a4:	57                   	push   %edi
 4a5:	56                   	push   %esi
 4a6:	53                   	push   %ebx
 4a7:	83 ec 2c             	sub    $0x2c,%esp
 4aa:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ac:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 4b0:	0f 95 c3             	setne  %bl
 4b3:	89 d0                	mov    %edx,%eax
 4b5:	c1 e8 1f             	shr    $0x1f,%eax
 4b8:	84 c3                	test   %al,%bl
 4ba:	74 10                	je     4cc <printint+0x2b>
    neg = 1;
    x = -xx;
 4bc:	f7 da                	neg    %edx
    neg = 1;
 4be:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4c5:	be 00 00 00 00       	mov    $0x0,%esi
 4ca:	eb 0b                	jmp    4d7 <printint+0x36>
  neg = 0;
 4cc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 4d3:	eb f0                	jmp    4c5 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 4d5:	89 c6                	mov    %eax,%esi
 4d7:	89 d0                	mov    %edx,%eax
 4d9:	ba 00 00 00 00       	mov    $0x0,%edx
 4de:	f7 f1                	div    %ecx
 4e0:	89 c3                	mov    %eax,%ebx
 4e2:	8d 46 01             	lea    0x1(%esi),%eax
 4e5:	0f b6 92 a8 08 00 00 	movzbl 0x8a8(%edx),%edx
 4ec:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 4f0:	89 da                	mov    %ebx,%edx
 4f2:	85 db                	test   %ebx,%ebx
 4f4:	75 df                	jne    4d5 <printint+0x34>
 4f6:	89 c3                	mov    %eax,%ebx
  if(neg)
 4f8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 4fc:	74 16                	je     514 <printint+0x73>
    buf[i++] = '-';
 4fe:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 503:	8d 5e 02             	lea    0x2(%esi),%ebx
 506:	eb 0c                	jmp    514 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 508:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 50d:	89 f8                	mov    %edi,%eax
 50f:	e8 73 ff ff ff       	call   487 <putc>
  while(--i >= 0)
 514:	83 eb 01             	sub    $0x1,%ebx
 517:	79 ef                	jns    508 <printint+0x67>
}
 519:	83 c4 2c             	add    $0x2c,%esp
 51c:	5b                   	pop    %ebx
 51d:	5e                   	pop    %esi
 51e:	5f                   	pop    %edi
 51f:	5d                   	pop    %ebp
 520:	c3                   	ret    

00000521 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 521:	55                   	push   %ebp
 522:	89 e5                	mov    %esp,%ebp
 524:	57                   	push   %edi
 525:	56                   	push   %esi
 526:	53                   	push   %ebx
 527:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 52a:	8d 45 10             	lea    0x10(%ebp),%eax
 52d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 530:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 535:	bb 00 00 00 00       	mov    $0x0,%ebx
 53a:	eb 14                	jmp    550 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 53c:	89 fa                	mov    %edi,%edx
 53e:	8b 45 08             	mov    0x8(%ebp),%eax
 541:	e8 41 ff ff ff       	call   487 <putc>
 546:	eb 05                	jmp    54d <printf+0x2c>
      }
    } else if(state == '%'){
 548:	83 fe 25             	cmp    $0x25,%esi
 54b:	74 25                	je     572 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 54d:	83 c3 01             	add    $0x1,%ebx
 550:	8b 45 0c             	mov    0xc(%ebp),%eax
 553:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 557:	84 c0                	test   %al,%al
 559:	0f 84 23 01 00 00    	je     682 <printf+0x161>
    c = fmt[i] & 0xff;
 55f:	0f be f8             	movsbl %al,%edi
 562:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 565:	85 f6                	test   %esi,%esi
 567:	75 df                	jne    548 <printf+0x27>
      if(c == '%'){
 569:	83 f8 25             	cmp    $0x25,%eax
 56c:	75 ce                	jne    53c <printf+0x1b>
        state = '%';
 56e:	89 c6                	mov    %eax,%esi
 570:	eb db                	jmp    54d <printf+0x2c>
      if(c == 'd'){
 572:	83 f8 64             	cmp    $0x64,%eax
 575:	74 49                	je     5c0 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 577:	83 f8 78             	cmp    $0x78,%eax
 57a:	0f 94 c1             	sete   %cl
 57d:	83 f8 70             	cmp    $0x70,%eax
 580:	0f 94 c2             	sete   %dl
 583:	08 d1                	or     %dl,%cl
 585:	75 63                	jne    5ea <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 587:	83 f8 73             	cmp    $0x73,%eax
 58a:	0f 84 84 00 00 00    	je     614 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 590:	83 f8 63             	cmp    $0x63,%eax
 593:	0f 84 b7 00 00 00    	je     650 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 599:	83 f8 25             	cmp    $0x25,%eax
 59c:	0f 84 cc 00 00 00    	je     66e <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5a2:	ba 25 00 00 00       	mov    $0x25,%edx
 5a7:	8b 45 08             	mov    0x8(%ebp),%eax
 5aa:	e8 d8 fe ff ff       	call   487 <putc>
        putc(fd, c);
 5af:	89 fa                	mov    %edi,%edx
 5b1:	8b 45 08             	mov    0x8(%ebp),%eax
 5b4:	e8 ce fe ff ff       	call   487 <putc>
      }
      state = 0;
 5b9:	be 00 00 00 00       	mov    $0x0,%esi
 5be:	eb 8d                	jmp    54d <printf+0x2c>
        printint(fd, *ap, 10, 1);
 5c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5c3:	8b 17                	mov    (%edi),%edx
 5c5:	83 ec 0c             	sub    $0xc,%esp
 5c8:	6a 01                	push   $0x1
 5ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
 5cf:	8b 45 08             	mov    0x8(%ebp),%eax
 5d2:	e8 ca fe ff ff       	call   4a1 <printint>
        ap++;
 5d7:	83 c7 04             	add    $0x4,%edi
 5da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5dd:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5e0:	be 00 00 00 00       	mov    $0x0,%esi
 5e5:	e9 63 ff ff ff       	jmp    54d <printf+0x2c>
        printint(fd, *ap, 16, 0);
 5ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5ed:	8b 17                	mov    (%edi),%edx
 5ef:	83 ec 0c             	sub    $0xc,%esp
 5f2:	6a 00                	push   $0x0
 5f4:	b9 10 00 00 00       	mov    $0x10,%ecx
 5f9:	8b 45 08             	mov    0x8(%ebp),%eax
 5fc:	e8 a0 fe ff ff       	call   4a1 <printint>
        ap++;
 601:	83 c7 04             	add    $0x4,%edi
 604:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 607:	83 c4 10             	add    $0x10,%esp
      state = 0;
 60a:	be 00 00 00 00       	mov    $0x0,%esi
 60f:	e9 39 ff ff ff       	jmp    54d <printf+0x2c>
        s = (char*)*ap;
 614:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 617:	8b 30                	mov    (%eax),%esi
        ap++;
 619:	83 c0 04             	add    $0x4,%eax
 61c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 61f:	85 f6                	test   %esi,%esi
 621:	75 28                	jne    64b <printf+0x12a>
          s = "(null)";
 623:	be a0 08 00 00       	mov    $0x8a0,%esi
 628:	8b 7d 08             	mov    0x8(%ebp),%edi
 62b:	eb 0d                	jmp    63a <printf+0x119>
          putc(fd, *s);
 62d:	0f be d2             	movsbl %dl,%edx
 630:	89 f8                	mov    %edi,%eax
 632:	e8 50 fe ff ff       	call   487 <putc>
          s++;
 637:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 63a:	0f b6 16             	movzbl (%esi),%edx
 63d:	84 d2                	test   %dl,%dl
 63f:	75 ec                	jne    62d <printf+0x10c>
      state = 0;
 641:	be 00 00 00 00       	mov    $0x0,%esi
 646:	e9 02 ff ff ff       	jmp    54d <printf+0x2c>
 64b:	8b 7d 08             	mov    0x8(%ebp),%edi
 64e:	eb ea                	jmp    63a <printf+0x119>
        putc(fd, *ap);
 650:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 653:	0f be 17             	movsbl (%edi),%edx
 656:	8b 45 08             	mov    0x8(%ebp),%eax
 659:	e8 29 fe ff ff       	call   487 <putc>
        ap++;
 65e:	83 c7 04             	add    $0x4,%edi
 661:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 664:	be 00 00 00 00       	mov    $0x0,%esi
 669:	e9 df fe ff ff       	jmp    54d <printf+0x2c>
        putc(fd, c);
 66e:	89 fa                	mov    %edi,%edx
 670:	8b 45 08             	mov    0x8(%ebp),%eax
 673:	e8 0f fe ff ff       	call   487 <putc>
      state = 0;
 678:	be 00 00 00 00       	mov    $0x0,%esi
 67d:	e9 cb fe ff ff       	jmp    54d <printf+0x2c>
    }
  }
}
 682:	8d 65 f4             	lea    -0xc(%ebp),%esp
 685:	5b                   	pop    %ebx
 686:	5e                   	pop    %esi
 687:	5f                   	pop    %edi
 688:	5d                   	pop    %ebp
 689:	c3                   	ret    

0000068a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 68a:	55                   	push   %ebp
 68b:	89 e5                	mov    %esp,%ebp
 68d:	57                   	push   %edi
 68e:	56                   	push   %esi
 68f:	53                   	push   %ebx
 690:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 693:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 696:	a1 74 0b 00 00       	mov    0xb74,%eax
 69b:	eb 02                	jmp    69f <free+0x15>
 69d:	89 d0                	mov    %edx,%eax
 69f:	39 c8                	cmp    %ecx,%eax
 6a1:	73 04                	jae    6a7 <free+0x1d>
 6a3:	39 08                	cmp    %ecx,(%eax)
 6a5:	77 12                	ja     6b9 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a7:	8b 10                	mov    (%eax),%edx
 6a9:	39 c2                	cmp    %eax,%edx
 6ab:	77 f0                	ja     69d <free+0x13>
 6ad:	39 c8                	cmp    %ecx,%eax
 6af:	72 08                	jb     6b9 <free+0x2f>
 6b1:	39 ca                	cmp    %ecx,%edx
 6b3:	77 04                	ja     6b9 <free+0x2f>
 6b5:	89 d0                	mov    %edx,%eax
 6b7:	eb e6                	jmp    69f <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 6b9:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6bc:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6bf:	8b 10                	mov    (%eax),%edx
 6c1:	39 d7                	cmp    %edx,%edi
 6c3:	74 19                	je     6de <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6c5:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6c8:	8b 50 04             	mov    0x4(%eax),%edx
 6cb:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6ce:	39 ce                	cmp    %ecx,%esi
 6d0:	74 1b                	je     6ed <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6d2:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6d4:	a3 74 0b 00 00       	mov    %eax,0xb74
}
 6d9:	5b                   	pop    %ebx
 6da:	5e                   	pop    %esi
 6db:	5f                   	pop    %edi
 6dc:	5d                   	pop    %ebp
 6dd:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 6de:	03 72 04             	add    0x4(%edx),%esi
 6e1:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6e4:	8b 10                	mov    (%eax),%edx
 6e6:	8b 12                	mov    (%edx),%edx
 6e8:	89 53 f8             	mov    %edx,-0x8(%ebx)
 6eb:	eb db                	jmp    6c8 <free+0x3e>
    p->s.size += bp->s.size;
 6ed:	03 53 fc             	add    -0x4(%ebx),%edx
 6f0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6f3:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6f6:	89 10                	mov    %edx,(%eax)
 6f8:	eb da                	jmp    6d4 <free+0x4a>

000006fa <morecore>:

static Header*
morecore(uint nu)
{
 6fa:	55                   	push   %ebp
 6fb:	89 e5                	mov    %esp,%ebp
 6fd:	53                   	push   %ebx
 6fe:	83 ec 04             	sub    $0x4,%esp
 701:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 703:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 708:	77 05                	ja     70f <morecore+0x15>
    nu = 4096;
 70a:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 70f:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 716:	83 ec 0c             	sub    $0xc,%esp
 719:	50                   	push   %eax
 71a:	e8 30 fd ff ff       	call   44f <sbrk>
  if(p == (char*)-1)
 71f:	83 c4 10             	add    $0x10,%esp
 722:	83 f8 ff             	cmp    $0xffffffff,%eax
 725:	74 1c                	je     743 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 727:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 72a:	83 c0 08             	add    $0x8,%eax
 72d:	83 ec 0c             	sub    $0xc,%esp
 730:	50                   	push   %eax
 731:	e8 54 ff ff ff       	call   68a <free>
  return freep;
 736:	a1 74 0b 00 00       	mov    0xb74,%eax
 73b:	83 c4 10             	add    $0x10,%esp
}
 73e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 741:	c9                   	leave  
 742:	c3                   	ret    
    return 0;
 743:	b8 00 00 00 00       	mov    $0x0,%eax
 748:	eb f4                	jmp    73e <morecore+0x44>

0000074a <malloc>:

void*
malloc(uint nbytes)
{
 74a:	55                   	push   %ebp
 74b:	89 e5                	mov    %esp,%ebp
 74d:	53                   	push   %ebx
 74e:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 751:	8b 45 08             	mov    0x8(%ebp),%eax
 754:	8d 58 07             	lea    0x7(%eax),%ebx
 757:	c1 eb 03             	shr    $0x3,%ebx
 75a:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 75d:	8b 0d 74 0b 00 00    	mov    0xb74,%ecx
 763:	85 c9                	test   %ecx,%ecx
 765:	74 04                	je     76b <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 767:	8b 01                	mov    (%ecx),%eax
 769:	eb 4d                	jmp    7b8 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 76b:	c7 05 74 0b 00 00 78 	movl   $0xb78,0xb74
 772:	0b 00 00 
 775:	c7 05 78 0b 00 00 78 	movl   $0xb78,0xb78
 77c:	0b 00 00 
    base.s.size = 0;
 77f:	c7 05 7c 0b 00 00 00 	movl   $0x0,0xb7c
 786:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 789:	b9 78 0b 00 00       	mov    $0xb78,%ecx
 78e:	eb d7                	jmp    767 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 790:	39 da                	cmp    %ebx,%edx
 792:	74 1a                	je     7ae <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 794:	29 da                	sub    %ebx,%edx
 796:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 799:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 79c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 79f:	89 0d 74 0b 00 00    	mov    %ecx,0xb74
      return (void*)(p + 1);
 7a5:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7a8:	83 c4 04             	add    $0x4,%esp
 7ab:	5b                   	pop    %ebx
 7ac:	5d                   	pop    %ebp
 7ad:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 7ae:	8b 10                	mov    (%eax),%edx
 7b0:	89 11                	mov    %edx,(%ecx)
 7b2:	eb eb                	jmp    79f <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7b4:	89 c1                	mov    %eax,%ecx
 7b6:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 7b8:	8b 50 04             	mov    0x4(%eax),%edx
 7bb:	39 da                	cmp    %ebx,%edx
 7bd:	73 d1                	jae    790 <malloc+0x46>
    if(p == freep)
 7bf:	39 05 74 0b 00 00    	cmp    %eax,0xb74
 7c5:	75 ed                	jne    7b4 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 7c7:	89 d8                	mov    %ebx,%eax
 7c9:	e8 2c ff ff ff       	call   6fa <morecore>
 7ce:	85 c0                	test   %eax,%eax
 7d0:	75 e2                	jne    7b4 <malloc+0x6a>
        return 0;
 7d2:	b8 00 00 00 00       	mov    $0x0,%eax
 7d7:	eb cf                	jmp    7a8 <malloc+0x5e>
