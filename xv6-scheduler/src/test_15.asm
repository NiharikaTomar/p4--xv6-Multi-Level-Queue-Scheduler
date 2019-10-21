
_test_15:     file format elf32-i386


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
  36:	e8 f7 03 00 00       	call   432 <sleep>
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
  6a:	81 ec 24 0c 00 00    	sub    $0xc24,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  70:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  76:	50                   	push   %eax
  77:	e8 de 03 00 00       	call   45a <getpinfo>
  7c:	83 c4 10             	add    $0x10,%esp
  7f:	85 c0                	test   %eax,%eax
  81:	75 2a                	jne    ad <main+0x54>

  // Push this thread to the bottom
  workload(80000000, 0);
  83:	83 ec 08             	sub    $0x8,%esp
  86:	6a 00                	push   $0x0
  88:	68 00 b4 c4 04       	push   $0x4c4b400
  8d:	e8 6e ff ff ff       	call   0 <workload>

  int i, j, k;

  // Launch the 4 processes, but process 2 will sleep in the middle
  for (i = 0; i < 1; i++) {
  92:	83 c4 10             	add    $0x10,%esp
  95:	bb 00 00 00 00       	mov    $0x0,%ebx
  9a:	85 db                	test   %ebx,%ebx
  9c:	7e 2f                	jle    cd <main+0x74>
    } else {
      //setpri(c_pid, 2);
    }
  }

  for (i = 0; i < 9; i++) { 
  9e:	c7 85 e4 f3 ff ff 00 	movl   $0x0,-0xc1c(%ebp)
  a5:	00 00 00 
  a8:	e9 19 01 00 00       	jmp    1c6 <main+0x16d>
  check(getpinfo(&st) == 0, "getpinfo");
  ad:	83 ec 0c             	sub    $0xc,%esp
  b0:	68 b4 07 00 00       	push   $0x7b4
  b5:	6a 24                	push   $0x24
  b7:	68 bd 07 00 00       	push   $0x7bd
  bc:	68 e4 07 00 00       	push   $0x7e4
  c1:	6a 01                	push   $0x1
  c3:	e8 34 04 00 00       	call   4fc <printf>
  c8:	83 c4 20             	add    $0x20,%esp
  cb:	eb b6                	jmp    83 <main+0x2a>
    int c_pid = fork2(0);
  cd:	83 ec 0c             	sub    $0xc,%esp
  d0:	6a 00                	push   $0x0
  d2:	e8 7b 03 00 00       	call   452 <fork2>
  d7:	89 c1                	mov    %eax,%ecx
    if (c_pid == 0) {
  d9:	83 c4 10             	add    $0x10,%esp
  dc:	85 c0                	test   %eax,%eax
  de:	74 05                	je     e5 <main+0x8c>
  for (i = 0; i < 1; i++) {
  e0:	83 c3 01             	add    $0x1,%ebx
  e3:	eb b5                	jmp    9a <main+0x41>
      if (i % 2 == 1) {
  e5:	be 02 00 00 00       	mov    $0x2,%esi
  ea:	89 d8                	mov    %ebx,%eax
  ec:	99                   	cltd   
  ed:	f7 fe                	idiv   %esi
  ef:	83 fa 01             	cmp    $0x1,%edx
  f2:	74 13                	je     107 <main+0xae>
      workload(600000000, t);
  f4:	83 ec 08             	sub    $0x8,%esp
  f7:	51                   	push   %ecx
  f8:	68 00 46 c3 23       	push   $0x23c34600
  fd:	e8 fe fe ff ff       	call   0 <workload>
      exit();
 102:	e8 9b 02 00 00       	call   3a2 <exit>
          t = 64*5; // for this process, give up CPU for one time-slice
 107:	b9 40 01 00 00       	mov    $0x140,%ecx
 10c:	eb e6                	jmp    f4 <main+0x9b>
    sleep(20);
    check(getpinfo(&st) == 0, "getpinfo");
 10e:	83 ec 0c             	sub    $0xc,%esp
 111:	68 b4 07 00 00       	push   $0x7b4
 116:	6a 3d                	push   $0x3d
 118:	68 bd 07 00 00       	push   $0x7bd
 11d:	68 e4 07 00 00       	push   $0x7e4
 122:	6a 01                	push   $0x1
 124:	e8 d3 03 00 00       	call   4fc <printf>
 129:	83 c4 20             	add    $0x20,%esp
 12c:	e9 c1 00 00 00       	jmp    1f2 <main+0x199>
    
    for (j = 0; j < NPROC; j++) {
 131:	83 c3 01             	add    $0x1,%ebx
 134:	83 fb 3f             	cmp    $0x3f,%ebx
 137:	0f 8f 82 00 00 00    	jg     1bf <main+0x166>
      if (st.inuse[j] && st.pid[j] >= 3 && st.pid[j] != getpid()) {
 13d:	83 bc 9d e8 f3 ff ff 	cmpl   $0x0,-0xc18(%ebp,%ebx,4)
 144:	00 
 145:	74 ea                	je     131 <main+0xd8>
 147:	8b b4 9d e8 f4 ff ff 	mov    -0xb18(%ebp,%ebx,4),%esi
 14e:	83 fe 02             	cmp    $0x2,%esi
 151:	7e de                	jle    131 <main+0xd8>
 153:	e8 ca 02 00 00       	call   422 <getpid>
 158:	39 c6                	cmp    %eax,%esi
 15a:	74 d5                	je     131 <main+0xd8>
	DEBUG_PRINT((1, "%d\n", i));
 15c:	83 ec 04             	sub    $0x4,%esp
 15f:	ff b5 e4 f3 ff ff    	pushl  -0xc1c(%ebp)
 165:	68 c7 07 00 00       	push   $0x7c7
 16a:	6a 01                	push   $0x1
 16c:	e8 8b 03 00 00       	call   4fc <printf>
	DEBUG_PRINT((1, "XV6_SCHEDULER\t CHILD\n"));
 171:	83 c4 08             	add    $0x8,%esp
 174:	68 cb 07 00 00       	push   $0x7cb
 179:	6a 01                	push   $0x1
 17b:	e8 7c 03 00 00       	call   4fc <printf>
        //DEBUG_PRINT((1, "pid: %d\n", st.pid[j]));
        for (k = 3; k >= 0; k--) {
 180:	83 c4 10             	add    $0x10,%esp
 183:	be 03 00 00 00       	mov    $0x3,%esi
 188:	85 f6                	test   %esi,%esi
 18a:	78 a5                	js     131 <main+0xd8>
          DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d ticks used %d\n", k, st.ticks[j][k]));
 18c:	8d 3c 9e             	lea    (%esi,%ebx,4),%edi
 18f:	ff b4 bd e8 f7 ff ff 	pushl  -0x818(%ebp,%edi,4)
 196:	56                   	push   %esi
 197:	68 14 08 00 00       	push   $0x814
 19c:	6a 01                	push   $0x1
 19e:	e8 59 03 00 00       	call   4fc <printf>
	  DEBUG_PRINT((1, "XV6_SCHEDULER\t \t level %d qtail %d\n", k, st.qtail[j][k]));
 1a3:	ff b4 bd e8 fb ff ff 	pushl  -0x418(%ebp,%edi,4)
 1aa:	56                   	push   %esi
 1ab:	68 40 08 00 00       	push   $0x840
 1b0:	6a 01                	push   $0x1
 1b2:	e8 45 03 00 00       	call   4fc <printf>
        for (k = 3; k >= 0; k--) {
 1b7:	83 ee 01             	sub    $0x1,%esi
 1ba:	83 c4 20             	add    $0x20,%esp
 1bd:	eb c9                	jmp    188 <main+0x12f>
  for (i = 0; i < 9; i++) { 
 1bf:	83 85 e4 f3 ff ff 01 	addl   $0x1,-0xc1c(%ebp)
 1c6:	83 bd e4 f3 ff ff 08 	cmpl   $0x8,-0xc1c(%ebp)
 1cd:	7f 2d                	jg     1fc <main+0x1a3>
    sleep(20);
 1cf:	83 ec 0c             	sub    $0xc,%esp
 1d2:	6a 14                	push   $0x14
 1d4:	e8 59 02 00 00       	call   432 <sleep>
    check(getpinfo(&st) == 0, "getpinfo");
 1d9:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 1df:	89 04 24             	mov    %eax,(%esp)
 1e2:	e8 73 02 00 00       	call   45a <getpinfo>
 1e7:	83 c4 10             	add    $0x10,%esp
 1ea:	85 c0                	test   %eax,%eax
 1ec:	0f 85 1c ff ff ff    	jne    10e <main+0xb5>
        for (k = 3; k >= 0; k--) {
 1f2:	bb 00 00 00 00       	mov    $0x0,%ebx
 1f7:	e9 38 ff ff ff       	jmp    134 <main+0xdb>
        }
      } 
    }
  }

  for (i = 0; i < 6; i++) {
 1fc:	bb 00 00 00 00       	mov    $0x0,%ebx
 201:	eb 08                	jmp    20b <main+0x1b2>
    wait();
 203:	e8 a2 01 00 00       	call   3aa <wait>
  for (i = 0; i < 6; i++) {
 208:	83 c3 01             	add    $0x1,%ebx
 20b:	83 fb 05             	cmp    $0x5,%ebx
 20e:	7e f3                	jle    203 <main+0x1aa>
  }

  //printf(1, "TEST PASSED");

  exit();
 210:	e8 8d 01 00 00       	call   3a2 <exit>

00000215 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 215:	55                   	push   %ebp
 216:	89 e5                	mov    %esp,%ebp
 218:	53                   	push   %ebx
 219:	8b 45 08             	mov    0x8(%ebp),%eax
 21c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 21f:	89 c2                	mov    %eax,%edx
 221:	0f b6 19             	movzbl (%ecx),%ebx
 224:	88 1a                	mov    %bl,(%edx)
 226:	8d 52 01             	lea    0x1(%edx),%edx
 229:	8d 49 01             	lea    0x1(%ecx),%ecx
 22c:	84 db                	test   %bl,%bl
 22e:	75 f1                	jne    221 <strcpy+0xc>
    ;
  return os;
}
 230:	5b                   	pop    %ebx
 231:	5d                   	pop    %ebp
 232:	c3                   	ret    

00000233 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 233:	55                   	push   %ebp
 234:	89 e5                	mov    %esp,%ebp
 236:	8b 4d 08             	mov    0x8(%ebp),%ecx
 239:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 23c:	eb 06                	jmp    244 <strcmp+0x11>
    p++, q++;
 23e:	83 c1 01             	add    $0x1,%ecx
 241:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 244:	0f b6 01             	movzbl (%ecx),%eax
 247:	84 c0                	test   %al,%al
 249:	74 04                	je     24f <strcmp+0x1c>
 24b:	3a 02                	cmp    (%edx),%al
 24d:	74 ef                	je     23e <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 24f:	0f b6 c0             	movzbl %al,%eax
 252:	0f b6 12             	movzbl (%edx),%edx
 255:	29 d0                	sub    %edx,%eax
}
 257:	5d                   	pop    %ebp
 258:	c3                   	ret    

00000259 <strlen>:

uint
strlen(const char *s)
{
 259:	55                   	push   %ebp
 25a:	89 e5                	mov    %esp,%ebp
 25c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 25f:	ba 00 00 00 00       	mov    $0x0,%edx
 264:	eb 03                	jmp    269 <strlen+0x10>
 266:	83 c2 01             	add    $0x1,%edx
 269:	89 d0                	mov    %edx,%eax
 26b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 26f:	75 f5                	jne    266 <strlen+0xd>
    ;
  return n;
}
 271:	5d                   	pop    %ebp
 272:	c3                   	ret    

00000273 <memset>:

void*
memset(void *dst, int c, uint n)
{
 273:	55                   	push   %ebp
 274:	89 e5                	mov    %esp,%ebp
 276:	57                   	push   %edi
 277:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 27a:	89 d7                	mov    %edx,%edi
 27c:	8b 4d 10             	mov    0x10(%ebp),%ecx
 27f:	8b 45 0c             	mov    0xc(%ebp),%eax
 282:	fc                   	cld    
 283:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 285:	89 d0                	mov    %edx,%eax
 287:	5f                   	pop    %edi
 288:	5d                   	pop    %ebp
 289:	c3                   	ret    

0000028a <strchr>:

char*
strchr(const char *s, char c)
{
 28a:	55                   	push   %ebp
 28b:	89 e5                	mov    %esp,%ebp
 28d:	8b 45 08             	mov    0x8(%ebp),%eax
 290:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 294:	0f b6 10             	movzbl (%eax),%edx
 297:	84 d2                	test   %dl,%dl
 299:	74 09                	je     2a4 <strchr+0x1a>
    if(*s == c)
 29b:	38 ca                	cmp    %cl,%dl
 29d:	74 0a                	je     2a9 <strchr+0x1f>
  for(; *s; s++)
 29f:	83 c0 01             	add    $0x1,%eax
 2a2:	eb f0                	jmp    294 <strchr+0xa>
      return (char*)s;
  return 0;
 2a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2a9:	5d                   	pop    %ebp
 2aa:	c3                   	ret    

000002ab <gets>:

char*
gets(char *buf, int max)
{
 2ab:	55                   	push   %ebp
 2ac:	89 e5                	mov    %esp,%ebp
 2ae:	57                   	push   %edi
 2af:	56                   	push   %esi
 2b0:	53                   	push   %ebx
 2b1:	83 ec 1c             	sub    $0x1c,%esp
 2b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2b7:	bb 00 00 00 00       	mov    $0x0,%ebx
 2bc:	8d 73 01             	lea    0x1(%ebx),%esi
 2bf:	3b 75 0c             	cmp    0xc(%ebp),%esi
 2c2:	7d 2e                	jge    2f2 <gets+0x47>
    cc = read(0, &c, 1);
 2c4:	83 ec 04             	sub    $0x4,%esp
 2c7:	6a 01                	push   $0x1
 2c9:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2cc:	50                   	push   %eax
 2cd:	6a 00                	push   $0x0
 2cf:	e8 e6 00 00 00       	call   3ba <read>
    if(cc < 1)
 2d4:	83 c4 10             	add    $0x10,%esp
 2d7:	85 c0                	test   %eax,%eax
 2d9:	7e 17                	jle    2f2 <gets+0x47>
      break;
    buf[i++] = c;
 2db:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2df:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 2e2:	3c 0a                	cmp    $0xa,%al
 2e4:	0f 94 c2             	sete   %dl
 2e7:	3c 0d                	cmp    $0xd,%al
 2e9:	0f 94 c0             	sete   %al
    buf[i++] = c;
 2ec:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 2ee:	08 c2                	or     %al,%dl
 2f0:	74 ca                	je     2bc <gets+0x11>
      break;
  }
  buf[i] = '\0';
 2f2:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 2f6:	89 f8                	mov    %edi,%eax
 2f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
 2fb:	5b                   	pop    %ebx
 2fc:	5e                   	pop    %esi
 2fd:	5f                   	pop    %edi
 2fe:	5d                   	pop    %ebp
 2ff:	c3                   	ret    

00000300 <stat>:

int
stat(const char *n, struct stat *st)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	56                   	push   %esi
 304:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 305:	83 ec 08             	sub    $0x8,%esp
 308:	6a 00                	push   $0x0
 30a:	ff 75 08             	pushl  0x8(%ebp)
 30d:	e8 d0 00 00 00       	call   3e2 <open>
  if(fd < 0)
 312:	83 c4 10             	add    $0x10,%esp
 315:	85 c0                	test   %eax,%eax
 317:	78 24                	js     33d <stat+0x3d>
 319:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 31b:	83 ec 08             	sub    $0x8,%esp
 31e:	ff 75 0c             	pushl  0xc(%ebp)
 321:	50                   	push   %eax
 322:	e8 d3 00 00 00       	call   3fa <fstat>
 327:	89 c6                	mov    %eax,%esi
  close(fd);
 329:	89 1c 24             	mov    %ebx,(%esp)
 32c:	e8 99 00 00 00       	call   3ca <close>
  return r;
 331:	83 c4 10             	add    $0x10,%esp
}
 334:	89 f0                	mov    %esi,%eax
 336:	8d 65 f8             	lea    -0x8(%ebp),%esp
 339:	5b                   	pop    %ebx
 33a:	5e                   	pop    %esi
 33b:	5d                   	pop    %ebp
 33c:	c3                   	ret    
    return -1;
 33d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 342:	eb f0                	jmp    334 <stat+0x34>

00000344 <atoi>:

int
atoi(const char *s)
{
 344:	55                   	push   %ebp
 345:	89 e5                	mov    %esp,%ebp
 347:	53                   	push   %ebx
 348:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 34b:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 350:	eb 10                	jmp    362 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 352:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 355:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 358:	83 c1 01             	add    $0x1,%ecx
 35b:	0f be d2             	movsbl %dl,%edx
 35e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 362:	0f b6 11             	movzbl (%ecx),%edx
 365:	8d 5a d0             	lea    -0x30(%edx),%ebx
 368:	80 fb 09             	cmp    $0x9,%bl
 36b:	76 e5                	jbe    352 <atoi+0xe>
  return n;
}
 36d:	5b                   	pop    %ebx
 36e:	5d                   	pop    %ebp
 36f:	c3                   	ret    

00000370 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 370:	55                   	push   %ebp
 371:	89 e5                	mov    %esp,%ebp
 373:	56                   	push   %esi
 374:	53                   	push   %ebx
 375:	8b 45 08             	mov    0x8(%ebp),%eax
 378:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 37b:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 37e:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 380:	eb 0d                	jmp    38f <memmove+0x1f>
    *dst++ = *src++;
 382:	0f b6 13             	movzbl (%ebx),%edx
 385:	88 11                	mov    %dl,(%ecx)
 387:	8d 5b 01             	lea    0x1(%ebx),%ebx
 38a:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 38d:	89 f2                	mov    %esi,%edx
 38f:	8d 72 ff             	lea    -0x1(%edx),%esi
 392:	85 d2                	test   %edx,%edx
 394:	7f ec                	jg     382 <memmove+0x12>
  return vdst;
}
 396:	5b                   	pop    %ebx
 397:	5e                   	pop    %esi
 398:	5d                   	pop    %ebp
 399:	c3                   	ret    

0000039a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 39a:	b8 01 00 00 00       	mov    $0x1,%eax
 39f:	cd 40                	int    $0x40
 3a1:	c3                   	ret    

000003a2 <exit>:
SYSCALL(exit)
 3a2:	b8 02 00 00 00       	mov    $0x2,%eax
 3a7:	cd 40                	int    $0x40
 3a9:	c3                   	ret    

000003aa <wait>:
SYSCALL(wait)
 3aa:	b8 03 00 00 00       	mov    $0x3,%eax
 3af:	cd 40                	int    $0x40
 3b1:	c3                   	ret    

000003b2 <pipe>:
SYSCALL(pipe)
 3b2:	b8 04 00 00 00       	mov    $0x4,%eax
 3b7:	cd 40                	int    $0x40
 3b9:	c3                   	ret    

000003ba <read>:
SYSCALL(read)
 3ba:	b8 05 00 00 00       	mov    $0x5,%eax
 3bf:	cd 40                	int    $0x40
 3c1:	c3                   	ret    

000003c2 <write>:
SYSCALL(write)
 3c2:	b8 10 00 00 00       	mov    $0x10,%eax
 3c7:	cd 40                	int    $0x40
 3c9:	c3                   	ret    

000003ca <close>:
SYSCALL(close)
 3ca:	b8 15 00 00 00       	mov    $0x15,%eax
 3cf:	cd 40                	int    $0x40
 3d1:	c3                   	ret    

000003d2 <kill>:
SYSCALL(kill)
 3d2:	b8 06 00 00 00       	mov    $0x6,%eax
 3d7:	cd 40                	int    $0x40
 3d9:	c3                   	ret    

000003da <exec>:
SYSCALL(exec)
 3da:	b8 07 00 00 00       	mov    $0x7,%eax
 3df:	cd 40                	int    $0x40
 3e1:	c3                   	ret    

000003e2 <open>:
SYSCALL(open)
 3e2:	b8 0f 00 00 00       	mov    $0xf,%eax
 3e7:	cd 40                	int    $0x40
 3e9:	c3                   	ret    

000003ea <mknod>:
SYSCALL(mknod)
 3ea:	b8 11 00 00 00       	mov    $0x11,%eax
 3ef:	cd 40                	int    $0x40
 3f1:	c3                   	ret    

000003f2 <unlink>:
SYSCALL(unlink)
 3f2:	b8 12 00 00 00       	mov    $0x12,%eax
 3f7:	cd 40                	int    $0x40
 3f9:	c3                   	ret    

000003fa <fstat>:
SYSCALL(fstat)
 3fa:	b8 08 00 00 00       	mov    $0x8,%eax
 3ff:	cd 40                	int    $0x40
 401:	c3                   	ret    

00000402 <link>:
SYSCALL(link)
 402:	b8 13 00 00 00       	mov    $0x13,%eax
 407:	cd 40                	int    $0x40
 409:	c3                   	ret    

0000040a <mkdir>:
SYSCALL(mkdir)
 40a:	b8 14 00 00 00       	mov    $0x14,%eax
 40f:	cd 40                	int    $0x40
 411:	c3                   	ret    

00000412 <chdir>:
SYSCALL(chdir)
 412:	b8 09 00 00 00       	mov    $0x9,%eax
 417:	cd 40                	int    $0x40
 419:	c3                   	ret    

0000041a <dup>:
SYSCALL(dup)
 41a:	b8 0a 00 00 00       	mov    $0xa,%eax
 41f:	cd 40                	int    $0x40
 421:	c3                   	ret    

00000422 <getpid>:
SYSCALL(getpid)
 422:	b8 0b 00 00 00       	mov    $0xb,%eax
 427:	cd 40                	int    $0x40
 429:	c3                   	ret    

0000042a <sbrk>:
SYSCALL(sbrk)
 42a:	b8 0c 00 00 00       	mov    $0xc,%eax
 42f:	cd 40                	int    $0x40
 431:	c3                   	ret    

00000432 <sleep>:
SYSCALL(sleep)
 432:	b8 0d 00 00 00       	mov    $0xd,%eax
 437:	cd 40                	int    $0x40
 439:	c3                   	ret    

0000043a <uptime>:
SYSCALL(uptime)
 43a:	b8 0e 00 00 00       	mov    $0xe,%eax
 43f:	cd 40                	int    $0x40
 441:	c3                   	ret    

00000442 <setpri>:
SYSCALL(setpri)
 442:	b8 16 00 00 00       	mov    $0x16,%eax
 447:	cd 40                	int    $0x40
 449:	c3                   	ret    

0000044a <getpri>:
SYSCALL(getpri)
 44a:	b8 17 00 00 00       	mov    $0x17,%eax
 44f:	cd 40                	int    $0x40
 451:	c3                   	ret    

00000452 <fork2>:
SYSCALL(fork2)
 452:	b8 18 00 00 00       	mov    $0x18,%eax
 457:	cd 40                	int    $0x40
 459:	c3                   	ret    

0000045a <getpinfo>:
SYSCALL(getpinfo)
 45a:	b8 19 00 00 00       	mov    $0x19,%eax
 45f:	cd 40                	int    $0x40
 461:	c3                   	ret    

00000462 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 462:	55                   	push   %ebp
 463:	89 e5                	mov    %esp,%ebp
 465:	83 ec 1c             	sub    $0x1c,%esp
 468:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 46b:	6a 01                	push   $0x1
 46d:	8d 55 f4             	lea    -0xc(%ebp),%edx
 470:	52                   	push   %edx
 471:	50                   	push   %eax
 472:	e8 4b ff ff ff       	call   3c2 <write>
}
 477:	83 c4 10             	add    $0x10,%esp
 47a:	c9                   	leave  
 47b:	c3                   	ret    

0000047c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 47c:	55                   	push   %ebp
 47d:	89 e5                	mov    %esp,%ebp
 47f:	57                   	push   %edi
 480:	56                   	push   %esi
 481:	53                   	push   %ebx
 482:	83 ec 2c             	sub    $0x2c,%esp
 485:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 487:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 48b:	0f 95 c3             	setne  %bl
 48e:	89 d0                	mov    %edx,%eax
 490:	c1 e8 1f             	shr    $0x1f,%eax
 493:	84 c3                	test   %al,%bl
 495:	74 10                	je     4a7 <printint+0x2b>
    neg = 1;
    x = -xx;
 497:	f7 da                	neg    %edx
    neg = 1;
 499:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4a0:	be 00 00 00 00       	mov    $0x0,%esi
 4a5:	eb 0b                	jmp    4b2 <printint+0x36>
  neg = 0;
 4a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 4ae:	eb f0                	jmp    4a0 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 4b0:	89 c6                	mov    %eax,%esi
 4b2:	89 d0                	mov    %edx,%eax
 4b4:	ba 00 00 00 00       	mov    $0x0,%edx
 4b9:	f7 f1                	div    %ecx
 4bb:	89 c3                	mov    %eax,%ebx
 4bd:	8d 46 01             	lea    0x1(%esi),%eax
 4c0:	0f b6 92 6c 08 00 00 	movzbl 0x86c(%edx),%edx
 4c7:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 4cb:	89 da                	mov    %ebx,%edx
 4cd:	85 db                	test   %ebx,%ebx
 4cf:	75 df                	jne    4b0 <printint+0x34>
 4d1:	89 c3                	mov    %eax,%ebx
  if(neg)
 4d3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 4d7:	74 16                	je     4ef <printint+0x73>
    buf[i++] = '-';
 4d9:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 4de:	8d 5e 02             	lea    0x2(%esi),%ebx
 4e1:	eb 0c                	jmp    4ef <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 4e3:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 4e8:	89 f8                	mov    %edi,%eax
 4ea:	e8 73 ff ff ff       	call   462 <putc>
  while(--i >= 0)
 4ef:	83 eb 01             	sub    $0x1,%ebx
 4f2:	79 ef                	jns    4e3 <printint+0x67>
}
 4f4:	83 c4 2c             	add    $0x2c,%esp
 4f7:	5b                   	pop    %ebx
 4f8:	5e                   	pop    %esi
 4f9:	5f                   	pop    %edi
 4fa:	5d                   	pop    %ebp
 4fb:	c3                   	ret    

000004fc <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 4fc:	55                   	push   %ebp
 4fd:	89 e5                	mov    %esp,%ebp
 4ff:	57                   	push   %edi
 500:	56                   	push   %esi
 501:	53                   	push   %ebx
 502:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 505:	8d 45 10             	lea    0x10(%ebp),%eax
 508:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 50b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 510:	bb 00 00 00 00       	mov    $0x0,%ebx
 515:	eb 14                	jmp    52b <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 517:	89 fa                	mov    %edi,%edx
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	e8 41 ff ff ff       	call   462 <putc>
 521:	eb 05                	jmp    528 <printf+0x2c>
      }
    } else if(state == '%'){
 523:	83 fe 25             	cmp    $0x25,%esi
 526:	74 25                	je     54d <printf+0x51>
  for(i = 0; fmt[i]; i++){
 528:	83 c3 01             	add    $0x1,%ebx
 52b:	8b 45 0c             	mov    0xc(%ebp),%eax
 52e:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 532:	84 c0                	test   %al,%al
 534:	0f 84 23 01 00 00    	je     65d <printf+0x161>
    c = fmt[i] & 0xff;
 53a:	0f be f8             	movsbl %al,%edi
 53d:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 540:	85 f6                	test   %esi,%esi
 542:	75 df                	jne    523 <printf+0x27>
      if(c == '%'){
 544:	83 f8 25             	cmp    $0x25,%eax
 547:	75 ce                	jne    517 <printf+0x1b>
        state = '%';
 549:	89 c6                	mov    %eax,%esi
 54b:	eb db                	jmp    528 <printf+0x2c>
      if(c == 'd'){
 54d:	83 f8 64             	cmp    $0x64,%eax
 550:	74 49                	je     59b <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 552:	83 f8 78             	cmp    $0x78,%eax
 555:	0f 94 c1             	sete   %cl
 558:	83 f8 70             	cmp    $0x70,%eax
 55b:	0f 94 c2             	sete   %dl
 55e:	08 d1                	or     %dl,%cl
 560:	75 63                	jne    5c5 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 562:	83 f8 73             	cmp    $0x73,%eax
 565:	0f 84 84 00 00 00    	je     5ef <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 56b:	83 f8 63             	cmp    $0x63,%eax
 56e:	0f 84 b7 00 00 00    	je     62b <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 574:	83 f8 25             	cmp    $0x25,%eax
 577:	0f 84 cc 00 00 00    	je     649 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 57d:	ba 25 00 00 00       	mov    $0x25,%edx
 582:	8b 45 08             	mov    0x8(%ebp),%eax
 585:	e8 d8 fe ff ff       	call   462 <putc>
        putc(fd, c);
 58a:	89 fa                	mov    %edi,%edx
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
 58f:	e8 ce fe ff ff       	call   462 <putc>
      }
      state = 0;
 594:	be 00 00 00 00       	mov    $0x0,%esi
 599:	eb 8d                	jmp    528 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 59b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 59e:	8b 17                	mov    (%edi),%edx
 5a0:	83 ec 0c             	sub    $0xc,%esp
 5a3:	6a 01                	push   $0x1
 5a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
 5aa:	8b 45 08             	mov    0x8(%ebp),%eax
 5ad:	e8 ca fe ff ff       	call   47c <printint>
        ap++;
 5b2:	83 c7 04             	add    $0x4,%edi
 5b5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5b8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5bb:	be 00 00 00 00       	mov    $0x0,%esi
 5c0:	e9 63 ff ff ff       	jmp    528 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 5c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5c8:	8b 17                	mov    (%edi),%edx
 5ca:	83 ec 0c             	sub    $0xc,%esp
 5cd:	6a 00                	push   $0x0
 5cf:	b9 10 00 00 00       	mov    $0x10,%ecx
 5d4:	8b 45 08             	mov    0x8(%ebp),%eax
 5d7:	e8 a0 fe ff ff       	call   47c <printint>
        ap++;
 5dc:	83 c7 04             	add    $0x4,%edi
 5df:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5e2:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5e5:	be 00 00 00 00       	mov    $0x0,%esi
 5ea:	e9 39 ff ff ff       	jmp    528 <printf+0x2c>
        s = (char*)*ap;
 5ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5f2:	8b 30                	mov    (%eax),%esi
        ap++;
 5f4:	83 c0 04             	add    $0x4,%eax
 5f7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 5fa:	85 f6                	test   %esi,%esi
 5fc:	75 28                	jne    626 <printf+0x12a>
          s = "(null)";
 5fe:	be 64 08 00 00       	mov    $0x864,%esi
 603:	8b 7d 08             	mov    0x8(%ebp),%edi
 606:	eb 0d                	jmp    615 <printf+0x119>
          putc(fd, *s);
 608:	0f be d2             	movsbl %dl,%edx
 60b:	89 f8                	mov    %edi,%eax
 60d:	e8 50 fe ff ff       	call   462 <putc>
          s++;
 612:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 615:	0f b6 16             	movzbl (%esi),%edx
 618:	84 d2                	test   %dl,%dl
 61a:	75 ec                	jne    608 <printf+0x10c>
      state = 0;
 61c:	be 00 00 00 00       	mov    $0x0,%esi
 621:	e9 02 ff ff ff       	jmp    528 <printf+0x2c>
 626:	8b 7d 08             	mov    0x8(%ebp),%edi
 629:	eb ea                	jmp    615 <printf+0x119>
        putc(fd, *ap);
 62b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 62e:	0f be 17             	movsbl (%edi),%edx
 631:	8b 45 08             	mov    0x8(%ebp),%eax
 634:	e8 29 fe ff ff       	call   462 <putc>
        ap++;
 639:	83 c7 04             	add    $0x4,%edi
 63c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 63f:	be 00 00 00 00       	mov    $0x0,%esi
 644:	e9 df fe ff ff       	jmp    528 <printf+0x2c>
        putc(fd, c);
 649:	89 fa                	mov    %edi,%edx
 64b:	8b 45 08             	mov    0x8(%ebp),%eax
 64e:	e8 0f fe ff ff       	call   462 <putc>
      state = 0;
 653:	be 00 00 00 00       	mov    $0x0,%esi
 658:	e9 cb fe ff ff       	jmp    528 <printf+0x2c>
    }
  }
}
 65d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 660:	5b                   	pop    %ebx
 661:	5e                   	pop    %esi
 662:	5f                   	pop    %edi
 663:	5d                   	pop    %ebp
 664:	c3                   	ret    

00000665 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 665:	55                   	push   %ebp
 666:	89 e5                	mov    %esp,%ebp
 668:	57                   	push   %edi
 669:	56                   	push   %esi
 66a:	53                   	push   %ebx
 66b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 66e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 671:	a1 38 0b 00 00       	mov    0xb38,%eax
 676:	eb 02                	jmp    67a <free+0x15>
 678:	89 d0                	mov    %edx,%eax
 67a:	39 c8                	cmp    %ecx,%eax
 67c:	73 04                	jae    682 <free+0x1d>
 67e:	39 08                	cmp    %ecx,(%eax)
 680:	77 12                	ja     694 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 682:	8b 10                	mov    (%eax),%edx
 684:	39 c2                	cmp    %eax,%edx
 686:	77 f0                	ja     678 <free+0x13>
 688:	39 c8                	cmp    %ecx,%eax
 68a:	72 08                	jb     694 <free+0x2f>
 68c:	39 ca                	cmp    %ecx,%edx
 68e:	77 04                	ja     694 <free+0x2f>
 690:	89 d0                	mov    %edx,%eax
 692:	eb e6                	jmp    67a <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 694:	8b 73 fc             	mov    -0x4(%ebx),%esi
 697:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 69a:	8b 10                	mov    (%eax),%edx
 69c:	39 d7                	cmp    %edx,%edi
 69e:	74 19                	je     6b9 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6a0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6a3:	8b 50 04             	mov    0x4(%eax),%edx
 6a6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6a9:	39 ce                	cmp    %ecx,%esi
 6ab:	74 1b                	je     6c8 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6ad:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6af:	a3 38 0b 00 00       	mov    %eax,0xb38
}
 6b4:	5b                   	pop    %ebx
 6b5:	5e                   	pop    %esi
 6b6:	5f                   	pop    %edi
 6b7:	5d                   	pop    %ebp
 6b8:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 6b9:	03 72 04             	add    0x4(%edx),%esi
 6bc:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6bf:	8b 10                	mov    (%eax),%edx
 6c1:	8b 12                	mov    (%edx),%edx
 6c3:	89 53 f8             	mov    %edx,-0x8(%ebx)
 6c6:	eb db                	jmp    6a3 <free+0x3e>
    p->s.size += bp->s.size;
 6c8:	03 53 fc             	add    -0x4(%ebx),%edx
 6cb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ce:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6d1:	89 10                	mov    %edx,(%eax)
 6d3:	eb da                	jmp    6af <free+0x4a>

000006d5 <morecore>:

static Header*
morecore(uint nu)
{
 6d5:	55                   	push   %ebp
 6d6:	89 e5                	mov    %esp,%ebp
 6d8:	53                   	push   %ebx
 6d9:	83 ec 04             	sub    $0x4,%esp
 6dc:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 6de:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 6e3:	77 05                	ja     6ea <morecore+0x15>
    nu = 4096;
 6e5:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 6ea:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 6f1:	83 ec 0c             	sub    $0xc,%esp
 6f4:	50                   	push   %eax
 6f5:	e8 30 fd ff ff       	call   42a <sbrk>
  if(p == (char*)-1)
 6fa:	83 c4 10             	add    $0x10,%esp
 6fd:	83 f8 ff             	cmp    $0xffffffff,%eax
 700:	74 1c                	je     71e <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 702:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 705:	83 c0 08             	add    $0x8,%eax
 708:	83 ec 0c             	sub    $0xc,%esp
 70b:	50                   	push   %eax
 70c:	e8 54 ff ff ff       	call   665 <free>
  return freep;
 711:	a1 38 0b 00 00       	mov    0xb38,%eax
 716:	83 c4 10             	add    $0x10,%esp
}
 719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 71c:	c9                   	leave  
 71d:	c3                   	ret    
    return 0;
 71e:	b8 00 00 00 00       	mov    $0x0,%eax
 723:	eb f4                	jmp    719 <morecore+0x44>

00000725 <malloc>:

void*
malloc(uint nbytes)
{
 725:	55                   	push   %ebp
 726:	89 e5                	mov    %esp,%ebp
 728:	53                   	push   %ebx
 729:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 72c:	8b 45 08             	mov    0x8(%ebp),%eax
 72f:	8d 58 07             	lea    0x7(%eax),%ebx
 732:	c1 eb 03             	shr    $0x3,%ebx
 735:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 738:	8b 0d 38 0b 00 00    	mov    0xb38,%ecx
 73e:	85 c9                	test   %ecx,%ecx
 740:	74 04                	je     746 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 742:	8b 01                	mov    (%ecx),%eax
 744:	eb 4d                	jmp    793 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 746:	c7 05 38 0b 00 00 3c 	movl   $0xb3c,0xb38
 74d:	0b 00 00 
 750:	c7 05 3c 0b 00 00 3c 	movl   $0xb3c,0xb3c
 757:	0b 00 00 
    base.s.size = 0;
 75a:	c7 05 40 0b 00 00 00 	movl   $0x0,0xb40
 761:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 764:	b9 3c 0b 00 00       	mov    $0xb3c,%ecx
 769:	eb d7                	jmp    742 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 76b:	39 da                	cmp    %ebx,%edx
 76d:	74 1a                	je     789 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 76f:	29 da                	sub    %ebx,%edx
 771:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 774:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 777:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 77a:	89 0d 38 0b 00 00    	mov    %ecx,0xb38
      return (void*)(p + 1);
 780:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 783:	83 c4 04             	add    $0x4,%esp
 786:	5b                   	pop    %ebx
 787:	5d                   	pop    %ebp
 788:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 789:	8b 10                	mov    (%eax),%edx
 78b:	89 11                	mov    %edx,(%ecx)
 78d:	eb eb                	jmp    77a <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78f:	89 c1                	mov    %eax,%ecx
 791:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 793:	8b 50 04             	mov    0x4(%eax),%edx
 796:	39 da                	cmp    %ebx,%edx
 798:	73 d1                	jae    76b <malloc+0x46>
    if(p == freep)
 79a:	39 05 38 0b 00 00    	cmp    %eax,0xb38
 7a0:	75 ed                	jne    78f <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 7a2:	89 d8                	mov    %ebx,%eax
 7a4:	e8 2c ff ff ff       	call   6d5 <morecore>
 7a9:	85 c0                	test   %eax,%eax
 7ab:	75 e2                	jne    78f <malloc+0x6a>
        return 0;
 7ad:	b8 00 00 00 00       	mov    $0x0,%eax
 7b2:	eb cf                	jmp    783 <malloc+0x5e>
