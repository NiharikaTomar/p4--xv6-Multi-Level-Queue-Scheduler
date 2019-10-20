
_test_1:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#endif


int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 14             	sub    $0x14,%esp
  int error = 0;
  char *args[1];
  args[0] = "loop";
  11:	c7 45 f4 08 06 00 00 	movl   $0x608,-0xc(%ebp)

  int c_pid = fork();
  18:	e8 ce 01 00 00       	call   1eb <fork>
  if(c_pid == 0){
  1d:	85 c0                	test   %eax,%eax
  1f:	75 32                	jne    53 <main+0x53>
    error = exec("loop", args);
  21:	83 ec 08             	sub    $0x8,%esp
  24:	8d 45 f4             	lea    -0xc(%ebp),%eax
  27:	50                   	push   %eax
  28:	68 08 06 00 00       	push   $0x608
  2d:	e8 f9 01 00 00       	call   22b <exec>
    
    if( error == -1 ){
  32:	83 c4 10             	add    $0x10,%esp
  35:	83 f8 ff             	cmp    $0xffffffff,%eax
  38:	74 05                	je     3f <main+0x3f>
      printf(1, "XV6_SCHEDULER\t loop either did not exist or was not callable as specifcied in assignment\n");
    }
    exit();
  3a:	e8 b4 01 00 00       	call   1f3 <exit>
      printf(1, "XV6_SCHEDULER\t loop either did not exist or was not callable as specifcied in assignment\n");
  3f:	83 ec 08             	sub    $0x8,%esp
  42:	68 10 06 00 00       	push   $0x610
  47:	6a 01                	push   $0x1
  49:	e8 ff 02 00 00       	call   34d <printf>
  4e:	83 c4 10             	add    $0x10,%esp
  51:	eb e7                	jmp    3a <main+0x3a>
    //sleep(8);
  }

  
  //printf(1, "kill\n");
  kill(c_pid);
  53:	83 ec 0c             	sub    $0xc,%esp
  56:	50                   	push   %eax
  57:	e8 c7 01 00 00       	call   223 <kill>
  wait();
  5c:	e8 9a 01 00 00       	call   1fb <wait>
  exit();
  61:	e8 8d 01 00 00       	call   1f3 <exit>

00000066 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  66:	55                   	push   %ebp
  67:	89 e5                	mov    %esp,%ebp
  69:	53                   	push   %ebx
  6a:	8b 45 08             	mov    0x8(%ebp),%eax
  6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  70:	89 c2                	mov    %eax,%edx
  72:	0f b6 19             	movzbl (%ecx),%ebx
  75:	88 1a                	mov    %bl,(%edx)
  77:	8d 52 01             	lea    0x1(%edx),%edx
  7a:	8d 49 01             	lea    0x1(%ecx),%ecx
  7d:	84 db                	test   %bl,%bl
  7f:	75 f1                	jne    72 <strcpy+0xc>
    ;
  return os;
}
  81:	5b                   	pop    %ebx
  82:	5d                   	pop    %ebp
  83:	c3                   	ret    

00000084 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  84:	55                   	push   %ebp
  85:	89 e5                	mov    %esp,%ebp
  87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  8d:	eb 06                	jmp    95 <strcmp+0x11>
    p++, q++;
  8f:	83 c1 01             	add    $0x1,%ecx
  92:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  95:	0f b6 01             	movzbl (%ecx),%eax
  98:	84 c0                	test   %al,%al
  9a:	74 04                	je     a0 <strcmp+0x1c>
  9c:	3a 02                	cmp    (%edx),%al
  9e:	74 ef                	je     8f <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  a0:	0f b6 c0             	movzbl %al,%eax
  a3:	0f b6 12             	movzbl (%edx),%edx
  a6:	29 d0                	sub    %edx,%eax
}
  a8:	5d                   	pop    %ebp
  a9:	c3                   	ret    

000000aa <strlen>:

uint
strlen(const char *s)
{
  aa:	55                   	push   %ebp
  ab:	89 e5                	mov    %esp,%ebp
  ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  b0:	ba 00 00 00 00       	mov    $0x0,%edx
  b5:	eb 03                	jmp    ba <strlen+0x10>
  b7:	83 c2 01             	add    $0x1,%edx
  ba:	89 d0                	mov    %edx,%eax
  bc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  c0:	75 f5                	jne    b7 <strlen+0xd>
    ;
  return n;
}
  c2:	5d                   	pop    %ebp
  c3:	c3                   	ret    

000000c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c4:	55                   	push   %ebp
  c5:	89 e5                	mov    %esp,%ebp
  c7:	57                   	push   %edi
  c8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  cb:	89 d7                	mov    %edx,%edi
  cd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  d3:	fc                   	cld    
  d4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  d6:	89 d0                	mov    %edx,%eax
  d8:	5f                   	pop    %edi
  d9:	5d                   	pop    %ebp
  da:	c3                   	ret    

000000db <strchr>:

char*
strchr(const char *s, char c)
{
  db:	55                   	push   %ebp
  dc:	89 e5                	mov    %esp,%ebp
  de:	8b 45 08             	mov    0x8(%ebp),%eax
  e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  e5:	0f b6 10             	movzbl (%eax),%edx
  e8:	84 d2                	test   %dl,%dl
  ea:	74 09                	je     f5 <strchr+0x1a>
    if(*s == c)
  ec:	38 ca                	cmp    %cl,%dl
  ee:	74 0a                	je     fa <strchr+0x1f>
  for(; *s; s++)
  f0:	83 c0 01             	add    $0x1,%eax
  f3:	eb f0                	jmp    e5 <strchr+0xa>
      return (char*)s;
  return 0;
  f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  fa:	5d                   	pop    %ebp
  fb:	c3                   	ret    

000000fc <gets>:

char*
gets(char *buf, int max)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	57                   	push   %edi
 100:	56                   	push   %esi
 101:	53                   	push   %ebx
 102:	83 ec 1c             	sub    $0x1c,%esp
 105:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 108:	bb 00 00 00 00       	mov    $0x0,%ebx
 10d:	8d 73 01             	lea    0x1(%ebx),%esi
 110:	3b 75 0c             	cmp    0xc(%ebp),%esi
 113:	7d 2e                	jge    143 <gets+0x47>
    cc = read(0, &c, 1);
 115:	83 ec 04             	sub    $0x4,%esp
 118:	6a 01                	push   $0x1
 11a:	8d 45 e7             	lea    -0x19(%ebp),%eax
 11d:	50                   	push   %eax
 11e:	6a 00                	push   $0x0
 120:	e8 e6 00 00 00       	call   20b <read>
    if(cc < 1)
 125:	83 c4 10             	add    $0x10,%esp
 128:	85 c0                	test   %eax,%eax
 12a:	7e 17                	jle    143 <gets+0x47>
      break;
    buf[i++] = c;
 12c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 130:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 133:	3c 0a                	cmp    $0xa,%al
 135:	0f 94 c2             	sete   %dl
 138:	3c 0d                	cmp    $0xd,%al
 13a:	0f 94 c0             	sete   %al
    buf[i++] = c;
 13d:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 13f:	08 c2                	or     %al,%dl
 141:	74 ca                	je     10d <gets+0x11>
      break;
  }
  buf[i] = '\0';
 143:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 147:	89 f8                	mov    %edi,%eax
 149:	8d 65 f4             	lea    -0xc(%ebp),%esp
 14c:	5b                   	pop    %ebx
 14d:	5e                   	pop    %esi
 14e:	5f                   	pop    %edi
 14f:	5d                   	pop    %ebp
 150:	c3                   	ret    

00000151 <stat>:

int
stat(const char *n, struct stat *st)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	56                   	push   %esi
 155:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 156:	83 ec 08             	sub    $0x8,%esp
 159:	6a 00                	push   $0x0
 15b:	ff 75 08             	pushl  0x8(%ebp)
 15e:	e8 d0 00 00 00       	call   233 <open>
  if(fd < 0)
 163:	83 c4 10             	add    $0x10,%esp
 166:	85 c0                	test   %eax,%eax
 168:	78 24                	js     18e <stat+0x3d>
 16a:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 16c:	83 ec 08             	sub    $0x8,%esp
 16f:	ff 75 0c             	pushl  0xc(%ebp)
 172:	50                   	push   %eax
 173:	e8 d3 00 00 00       	call   24b <fstat>
 178:	89 c6                	mov    %eax,%esi
  close(fd);
 17a:	89 1c 24             	mov    %ebx,(%esp)
 17d:	e8 99 00 00 00       	call   21b <close>
  return r;
 182:	83 c4 10             	add    $0x10,%esp
}
 185:	89 f0                	mov    %esi,%eax
 187:	8d 65 f8             	lea    -0x8(%ebp),%esp
 18a:	5b                   	pop    %ebx
 18b:	5e                   	pop    %esi
 18c:	5d                   	pop    %ebp
 18d:	c3                   	ret    
    return -1;
 18e:	be ff ff ff ff       	mov    $0xffffffff,%esi
 193:	eb f0                	jmp    185 <stat+0x34>

00000195 <atoi>:

int
atoi(const char *s)
{
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
 198:	53                   	push   %ebx
 199:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 19c:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1a1:	eb 10                	jmp    1b3 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1a3:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1a6:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1a9:	83 c1 01             	add    $0x1,%ecx
 1ac:	0f be d2             	movsbl %dl,%edx
 1af:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1b3:	0f b6 11             	movzbl (%ecx),%edx
 1b6:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1b9:	80 fb 09             	cmp    $0x9,%bl
 1bc:	76 e5                	jbe    1a3 <atoi+0xe>
  return n;
}
 1be:	5b                   	pop    %ebx
 1bf:	5d                   	pop    %ebp
 1c0:	c3                   	ret    

000001c1 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	56                   	push   %esi
 1c5:	53                   	push   %ebx
 1c6:	8b 45 08             	mov    0x8(%ebp),%eax
 1c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1cc:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1cf:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1d1:	eb 0d                	jmp    1e0 <memmove+0x1f>
    *dst++ = *src++;
 1d3:	0f b6 13             	movzbl (%ebx),%edx
 1d6:	88 11                	mov    %dl,(%ecx)
 1d8:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1db:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1de:	89 f2                	mov    %esi,%edx
 1e0:	8d 72 ff             	lea    -0x1(%edx),%esi
 1e3:	85 d2                	test   %edx,%edx
 1e5:	7f ec                	jg     1d3 <memmove+0x12>
  return vdst;
}
 1e7:	5b                   	pop    %ebx
 1e8:	5e                   	pop    %esi
 1e9:	5d                   	pop    %ebp
 1ea:	c3                   	ret    

000001eb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1eb:	b8 01 00 00 00       	mov    $0x1,%eax
 1f0:	cd 40                	int    $0x40
 1f2:	c3                   	ret    

000001f3 <exit>:
SYSCALL(exit)
 1f3:	b8 02 00 00 00       	mov    $0x2,%eax
 1f8:	cd 40                	int    $0x40
 1fa:	c3                   	ret    

000001fb <wait>:
SYSCALL(wait)
 1fb:	b8 03 00 00 00       	mov    $0x3,%eax
 200:	cd 40                	int    $0x40
 202:	c3                   	ret    

00000203 <pipe>:
SYSCALL(pipe)
 203:	b8 04 00 00 00       	mov    $0x4,%eax
 208:	cd 40                	int    $0x40
 20a:	c3                   	ret    

0000020b <read>:
SYSCALL(read)
 20b:	b8 05 00 00 00       	mov    $0x5,%eax
 210:	cd 40                	int    $0x40
 212:	c3                   	ret    

00000213 <write>:
SYSCALL(write)
 213:	b8 10 00 00 00       	mov    $0x10,%eax
 218:	cd 40                	int    $0x40
 21a:	c3                   	ret    

0000021b <close>:
SYSCALL(close)
 21b:	b8 15 00 00 00       	mov    $0x15,%eax
 220:	cd 40                	int    $0x40
 222:	c3                   	ret    

00000223 <kill>:
SYSCALL(kill)
 223:	b8 06 00 00 00       	mov    $0x6,%eax
 228:	cd 40                	int    $0x40
 22a:	c3                   	ret    

0000022b <exec>:
SYSCALL(exec)
 22b:	b8 07 00 00 00       	mov    $0x7,%eax
 230:	cd 40                	int    $0x40
 232:	c3                   	ret    

00000233 <open>:
SYSCALL(open)
 233:	b8 0f 00 00 00       	mov    $0xf,%eax
 238:	cd 40                	int    $0x40
 23a:	c3                   	ret    

0000023b <mknod>:
SYSCALL(mknod)
 23b:	b8 11 00 00 00       	mov    $0x11,%eax
 240:	cd 40                	int    $0x40
 242:	c3                   	ret    

00000243 <unlink>:
SYSCALL(unlink)
 243:	b8 12 00 00 00       	mov    $0x12,%eax
 248:	cd 40                	int    $0x40
 24a:	c3                   	ret    

0000024b <fstat>:
SYSCALL(fstat)
 24b:	b8 08 00 00 00       	mov    $0x8,%eax
 250:	cd 40                	int    $0x40
 252:	c3                   	ret    

00000253 <link>:
SYSCALL(link)
 253:	b8 13 00 00 00       	mov    $0x13,%eax
 258:	cd 40                	int    $0x40
 25a:	c3                   	ret    

0000025b <mkdir>:
SYSCALL(mkdir)
 25b:	b8 14 00 00 00       	mov    $0x14,%eax
 260:	cd 40                	int    $0x40
 262:	c3                   	ret    

00000263 <chdir>:
SYSCALL(chdir)
 263:	b8 09 00 00 00       	mov    $0x9,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <dup>:
SYSCALL(dup)
 26b:	b8 0a 00 00 00       	mov    $0xa,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <getpid>:
SYSCALL(getpid)
 273:	b8 0b 00 00 00       	mov    $0xb,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <sbrk>:
SYSCALL(sbrk)
 27b:	b8 0c 00 00 00       	mov    $0xc,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <sleep>:
SYSCALL(sleep)
 283:	b8 0d 00 00 00       	mov    $0xd,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <uptime>:
SYSCALL(uptime)
 28b:	b8 0e 00 00 00       	mov    $0xe,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <setpri>:
SYSCALL(setpri)
 293:	b8 16 00 00 00       	mov    $0x16,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <getpri>:
SYSCALL(getpri)
 29b:	b8 17 00 00 00       	mov    $0x17,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <fork2>:
SYSCALL(fork2)
 2a3:	b8 18 00 00 00       	mov    $0x18,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <getpinfo>:
SYSCALL(getpinfo)
 2ab:	b8 19 00 00 00       	mov    $0x19,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2b3:	55                   	push   %ebp
 2b4:	89 e5                	mov    %esp,%ebp
 2b6:	83 ec 1c             	sub    $0x1c,%esp
 2b9:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2bc:	6a 01                	push   $0x1
 2be:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2c1:	52                   	push   %edx
 2c2:	50                   	push   %eax
 2c3:	e8 4b ff ff ff       	call   213 <write>
}
 2c8:	83 c4 10             	add    $0x10,%esp
 2cb:	c9                   	leave  
 2cc:	c3                   	ret    

000002cd <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2cd:	55                   	push   %ebp
 2ce:	89 e5                	mov    %esp,%ebp
 2d0:	57                   	push   %edi
 2d1:	56                   	push   %esi
 2d2:	53                   	push   %ebx
 2d3:	83 ec 2c             	sub    $0x2c,%esp
 2d6:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2d8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2dc:	0f 95 c3             	setne  %bl
 2df:	89 d0                	mov    %edx,%eax
 2e1:	c1 e8 1f             	shr    $0x1f,%eax
 2e4:	84 c3                	test   %al,%bl
 2e6:	74 10                	je     2f8 <printint+0x2b>
    neg = 1;
    x = -xx;
 2e8:	f7 da                	neg    %edx
    neg = 1;
 2ea:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2f1:	be 00 00 00 00       	mov    $0x0,%esi
 2f6:	eb 0b                	jmp    303 <printint+0x36>
  neg = 0;
 2f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2ff:	eb f0                	jmp    2f1 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 301:	89 c6                	mov    %eax,%esi
 303:	89 d0                	mov    %edx,%eax
 305:	ba 00 00 00 00       	mov    $0x0,%edx
 30a:	f7 f1                	div    %ecx
 30c:	89 c3                	mov    %eax,%ebx
 30e:	8d 46 01             	lea    0x1(%esi),%eax
 311:	0f b6 92 74 06 00 00 	movzbl 0x674(%edx),%edx
 318:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 31c:	89 da                	mov    %ebx,%edx
 31e:	85 db                	test   %ebx,%ebx
 320:	75 df                	jne    301 <printint+0x34>
 322:	89 c3                	mov    %eax,%ebx
  if(neg)
 324:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 328:	74 16                	je     340 <printint+0x73>
    buf[i++] = '-';
 32a:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 32f:	8d 5e 02             	lea    0x2(%esi),%ebx
 332:	eb 0c                	jmp    340 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 334:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 339:	89 f8                	mov    %edi,%eax
 33b:	e8 73 ff ff ff       	call   2b3 <putc>
  while(--i >= 0)
 340:	83 eb 01             	sub    $0x1,%ebx
 343:	79 ef                	jns    334 <printint+0x67>
}
 345:	83 c4 2c             	add    $0x2c,%esp
 348:	5b                   	pop    %ebx
 349:	5e                   	pop    %esi
 34a:	5f                   	pop    %edi
 34b:	5d                   	pop    %ebp
 34c:	c3                   	ret    

0000034d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 34d:	55                   	push   %ebp
 34e:	89 e5                	mov    %esp,%ebp
 350:	57                   	push   %edi
 351:	56                   	push   %esi
 352:	53                   	push   %ebx
 353:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 356:	8d 45 10             	lea    0x10(%ebp),%eax
 359:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 35c:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 361:	bb 00 00 00 00       	mov    $0x0,%ebx
 366:	eb 14                	jmp    37c <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 368:	89 fa                	mov    %edi,%edx
 36a:	8b 45 08             	mov    0x8(%ebp),%eax
 36d:	e8 41 ff ff ff       	call   2b3 <putc>
 372:	eb 05                	jmp    379 <printf+0x2c>
      }
    } else if(state == '%'){
 374:	83 fe 25             	cmp    $0x25,%esi
 377:	74 25                	je     39e <printf+0x51>
  for(i = 0; fmt[i]; i++){
 379:	83 c3 01             	add    $0x1,%ebx
 37c:	8b 45 0c             	mov    0xc(%ebp),%eax
 37f:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 383:	84 c0                	test   %al,%al
 385:	0f 84 23 01 00 00    	je     4ae <printf+0x161>
    c = fmt[i] & 0xff;
 38b:	0f be f8             	movsbl %al,%edi
 38e:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 391:	85 f6                	test   %esi,%esi
 393:	75 df                	jne    374 <printf+0x27>
      if(c == '%'){
 395:	83 f8 25             	cmp    $0x25,%eax
 398:	75 ce                	jne    368 <printf+0x1b>
        state = '%';
 39a:	89 c6                	mov    %eax,%esi
 39c:	eb db                	jmp    379 <printf+0x2c>
      if(c == 'd'){
 39e:	83 f8 64             	cmp    $0x64,%eax
 3a1:	74 49                	je     3ec <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3a3:	83 f8 78             	cmp    $0x78,%eax
 3a6:	0f 94 c1             	sete   %cl
 3a9:	83 f8 70             	cmp    $0x70,%eax
 3ac:	0f 94 c2             	sete   %dl
 3af:	08 d1                	or     %dl,%cl
 3b1:	75 63                	jne    416 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3b3:	83 f8 73             	cmp    $0x73,%eax
 3b6:	0f 84 84 00 00 00    	je     440 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3bc:	83 f8 63             	cmp    $0x63,%eax
 3bf:	0f 84 b7 00 00 00    	je     47c <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3c5:	83 f8 25             	cmp    $0x25,%eax
 3c8:	0f 84 cc 00 00 00    	je     49a <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3ce:	ba 25 00 00 00       	mov    $0x25,%edx
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	e8 d8 fe ff ff       	call   2b3 <putc>
        putc(fd, c);
 3db:	89 fa                	mov    %edi,%edx
 3dd:	8b 45 08             	mov    0x8(%ebp),%eax
 3e0:	e8 ce fe ff ff       	call   2b3 <putc>
      }
      state = 0;
 3e5:	be 00 00 00 00       	mov    $0x0,%esi
 3ea:	eb 8d                	jmp    379 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3ef:	8b 17                	mov    (%edi),%edx
 3f1:	83 ec 0c             	sub    $0xc,%esp
 3f4:	6a 01                	push   $0x1
 3f6:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3fb:	8b 45 08             	mov    0x8(%ebp),%eax
 3fe:	e8 ca fe ff ff       	call   2cd <printint>
        ap++;
 403:	83 c7 04             	add    $0x4,%edi
 406:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 409:	83 c4 10             	add    $0x10,%esp
      state = 0;
 40c:	be 00 00 00 00       	mov    $0x0,%esi
 411:	e9 63 ff ff ff       	jmp    379 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 416:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 419:	8b 17                	mov    (%edi),%edx
 41b:	83 ec 0c             	sub    $0xc,%esp
 41e:	6a 00                	push   $0x0
 420:	b9 10 00 00 00       	mov    $0x10,%ecx
 425:	8b 45 08             	mov    0x8(%ebp),%eax
 428:	e8 a0 fe ff ff       	call   2cd <printint>
        ap++;
 42d:	83 c7 04             	add    $0x4,%edi
 430:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 433:	83 c4 10             	add    $0x10,%esp
      state = 0;
 436:	be 00 00 00 00       	mov    $0x0,%esi
 43b:	e9 39 ff ff ff       	jmp    379 <printf+0x2c>
        s = (char*)*ap;
 440:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 443:	8b 30                	mov    (%eax),%esi
        ap++;
 445:	83 c0 04             	add    $0x4,%eax
 448:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 44b:	85 f6                	test   %esi,%esi
 44d:	75 28                	jne    477 <printf+0x12a>
          s = "(null)";
 44f:	be 6c 06 00 00       	mov    $0x66c,%esi
 454:	8b 7d 08             	mov    0x8(%ebp),%edi
 457:	eb 0d                	jmp    466 <printf+0x119>
          putc(fd, *s);
 459:	0f be d2             	movsbl %dl,%edx
 45c:	89 f8                	mov    %edi,%eax
 45e:	e8 50 fe ff ff       	call   2b3 <putc>
          s++;
 463:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 466:	0f b6 16             	movzbl (%esi),%edx
 469:	84 d2                	test   %dl,%dl
 46b:	75 ec                	jne    459 <printf+0x10c>
      state = 0;
 46d:	be 00 00 00 00       	mov    $0x0,%esi
 472:	e9 02 ff ff ff       	jmp    379 <printf+0x2c>
 477:	8b 7d 08             	mov    0x8(%ebp),%edi
 47a:	eb ea                	jmp    466 <printf+0x119>
        putc(fd, *ap);
 47c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 47f:	0f be 17             	movsbl (%edi),%edx
 482:	8b 45 08             	mov    0x8(%ebp),%eax
 485:	e8 29 fe ff ff       	call   2b3 <putc>
        ap++;
 48a:	83 c7 04             	add    $0x4,%edi
 48d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 490:	be 00 00 00 00       	mov    $0x0,%esi
 495:	e9 df fe ff ff       	jmp    379 <printf+0x2c>
        putc(fd, c);
 49a:	89 fa                	mov    %edi,%edx
 49c:	8b 45 08             	mov    0x8(%ebp),%eax
 49f:	e8 0f fe ff ff       	call   2b3 <putc>
      state = 0;
 4a4:	be 00 00 00 00       	mov    $0x0,%esi
 4a9:	e9 cb fe ff ff       	jmp    379 <printf+0x2c>
    }
  }
}
 4ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4b1:	5b                   	pop    %ebx
 4b2:	5e                   	pop    %esi
 4b3:	5f                   	pop    %edi
 4b4:	5d                   	pop    %ebp
 4b5:	c3                   	ret    

000004b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4b6:	55                   	push   %ebp
 4b7:	89 e5                	mov    %esp,%ebp
 4b9:	57                   	push   %edi
 4ba:	56                   	push   %esi
 4bb:	53                   	push   %ebx
 4bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4bf:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4c2:	a1 0c 09 00 00       	mov    0x90c,%eax
 4c7:	eb 02                	jmp    4cb <free+0x15>
 4c9:	89 d0                	mov    %edx,%eax
 4cb:	39 c8                	cmp    %ecx,%eax
 4cd:	73 04                	jae    4d3 <free+0x1d>
 4cf:	39 08                	cmp    %ecx,(%eax)
 4d1:	77 12                	ja     4e5 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4d3:	8b 10                	mov    (%eax),%edx
 4d5:	39 c2                	cmp    %eax,%edx
 4d7:	77 f0                	ja     4c9 <free+0x13>
 4d9:	39 c8                	cmp    %ecx,%eax
 4db:	72 08                	jb     4e5 <free+0x2f>
 4dd:	39 ca                	cmp    %ecx,%edx
 4df:	77 04                	ja     4e5 <free+0x2f>
 4e1:	89 d0                	mov    %edx,%eax
 4e3:	eb e6                	jmp    4cb <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4e5:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4e8:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4eb:	8b 10                	mov    (%eax),%edx
 4ed:	39 d7                	cmp    %edx,%edi
 4ef:	74 19                	je     50a <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4f1:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4f4:	8b 50 04             	mov    0x4(%eax),%edx
 4f7:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4fa:	39 ce                	cmp    %ecx,%esi
 4fc:	74 1b                	je     519 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4fe:	89 08                	mov    %ecx,(%eax)
  freep = p;
 500:	a3 0c 09 00 00       	mov    %eax,0x90c
}
 505:	5b                   	pop    %ebx
 506:	5e                   	pop    %esi
 507:	5f                   	pop    %edi
 508:	5d                   	pop    %ebp
 509:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 50a:	03 72 04             	add    0x4(%edx),%esi
 50d:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 510:	8b 10                	mov    (%eax),%edx
 512:	8b 12                	mov    (%edx),%edx
 514:	89 53 f8             	mov    %edx,-0x8(%ebx)
 517:	eb db                	jmp    4f4 <free+0x3e>
    p->s.size += bp->s.size;
 519:	03 53 fc             	add    -0x4(%ebx),%edx
 51c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 51f:	8b 53 f8             	mov    -0x8(%ebx),%edx
 522:	89 10                	mov    %edx,(%eax)
 524:	eb da                	jmp    500 <free+0x4a>

00000526 <morecore>:

static Header*
morecore(uint nu)
{
 526:	55                   	push   %ebp
 527:	89 e5                	mov    %esp,%ebp
 529:	53                   	push   %ebx
 52a:	83 ec 04             	sub    $0x4,%esp
 52d:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 52f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 534:	77 05                	ja     53b <morecore+0x15>
    nu = 4096;
 536:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 53b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 542:	83 ec 0c             	sub    $0xc,%esp
 545:	50                   	push   %eax
 546:	e8 30 fd ff ff       	call   27b <sbrk>
  if(p == (char*)-1)
 54b:	83 c4 10             	add    $0x10,%esp
 54e:	83 f8 ff             	cmp    $0xffffffff,%eax
 551:	74 1c                	je     56f <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 553:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 556:	83 c0 08             	add    $0x8,%eax
 559:	83 ec 0c             	sub    $0xc,%esp
 55c:	50                   	push   %eax
 55d:	e8 54 ff ff ff       	call   4b6 <free>
  return freep;
 562:	a1 0c 09 00 00       	mov    0x90c,%eax
 567:	83 c4 10             	add    $0x10,%esp
}
 56a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 56d:	c9                   	leave  
 56e:	c3                   	ret    
    return 0;
 56f:	b8 00 00 00 00       	mov    $0x0,%eax
 574:	eb f4                	jmp    56a <morecore+0x44>

00000576 <malloc>:

void*
malloc(uint nbytes)
{
 576:	55                   	push   %ebp
 577:	89 e5                	mov    %esp,%ebp
 579:	53                   	push   %ebx
 57a:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 57d:	8b 45 08             	mov    0x8(%ebp),%eax
 580:	8d 58 07             	lea    0x7(%eax),%ebx
 583:	c1 eb 03             	shr    $0x3,%ebx
 586:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 589:	8b 0d 0c 09 00 00    	mov    0x90c,%ecx
 58f:	85 c9                	test   %ecx,%ecx
 591:	74 04                	je     597 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 593:	8b 01                	mov    (%ecx),%eax
 595:	eb 4d                	jmp    5e4 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 597:	c7 05 0c 09 00 00 10 	movl   $0x910,0x90c
 59e:	09 00 00 
 5a1:	c7 05 10 09 00 00 10 	movl   $0x910,0x910
 5a8:	09 00 00 
    base.s.size = 0;
 5ab:	c7 05 14 09 00 00 00 	movl   $0x0,0x914
 5b2:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5b5:	b9 10 09 00 00       	mov    $0x910,%ecx
 5ba:	eb d7                	jmp    593 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5bc:	39 da                	cmp    %ebx,%edx
 5be:	74 1a                	je     5da <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5c0:	29 da                	sub    %ebx,%edx
 5c2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5c5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5c8:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5cb:	89 0d 0c 09 00 00    	mov    %ecx,0x90c
      return (void*)(p + 1);
 5d1:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5d4:	83 c4 04             	add    $0x4,%esp
 5d7:	5b                   	pop    %ebx
 5d8:	5d                   	pop    %ebp
 5d9:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5da:	8b 10                	mov    (%eax),%edx
 5dc:	89 11                	mov    %edx,(%ecx)
 5de:	eb eb                	jmp    5cb <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5e0:	89 c1                	mov    %eax,%ecx
 5e2:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5e4:	8b 50 04             	mov    0x4(%eax),%edx
 5e7:	39 da                	cmp    %ebx,%edx
 5e9:	73 d1                	jae    5bc <malloc+0x46>
    if(p == freep)
 5eb:	39 05 0c 09 00 00    	cmp    %eax,0x90c
 5f1:	75 ed                	jne    5e0 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5f3:	89 d8                	mov    %ebx,%eax
 5f5:	e8 2c ff ff ff       	call   526 <morecore>
 5fa:	85 c0                	test   %eax,%eax
 5fc:	75 e2                	jne    5e0 <malloc+0x6a>
        return 0;
 5fe:	b8 00 00 00 00       	mov    $0x0,%eax
 603:	eb cf                	jmp    5d4 <malloc+0x5e>
