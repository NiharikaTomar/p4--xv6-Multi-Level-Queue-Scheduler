
_test_9:     file format elf32-i386


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
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	81 ec 0c 0c 00 00    	sub    $0xc0c,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  15:	8d 85 f8 f3 ff ff    	lea    -0xc08(%ebp),%eax
  1b:	50                   	push   %eax
  1c:	e8 cc 02 00 00       	call   2ed <getpinfo>
  21:	83 c4 10             	add    $0x10,%esp
  24:	85 c0                	test   %eax,%eax
  26:	75 47                	jne    6f <main+0x6f>

  int fret;

  fret = fork2(2);
  28:	83 ec 0c             	sub    $0xc,%esp
  2b:	6a 02                	push   $0x2
  2d:	e8 b3 02 00 00       	call   2e5 <fork2>
  32:	89 c3                	mov    %eax,%ebx

  int pri = getpri(fret);
  34:	89 04 24             	mov    %eax,(%esp)
  37:	e8 a1 02 00 00       	call   2dd <getpri>
  if(fret != 0){
  3c:	83 c4 10             	add    $0x10,%esp
  3f:	85 db                	test   %ebx,%ebx
  41:	74 60                	je     a3 <main+0xa3>
    if( fret != -1 && pri == 2){
  43:	83 fb ff             	cmp    $0xffffffff,%ebx
  46:	0f 95 c2             	setne  %dl
  49:	83 f8 02             	cmp    $0x2,%eax
  4c:	0f 94 c0             	sete   %al
  4f:	84 c2                	test   %al,%dl
  51:	74 3c                	je     8f <main+0x8f>
      printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  53:	83 ec 08             	sub    $0x8,%esp
  56:	68 5a 06 00 00       	push   $0x65a
  5b:	6a 01                	push   $0x1
  5d:	e8 2d 03 00 00       	call   38f <printf>
  62:	83 c4 10             	add    $0x10,%esp
    }
  }else{
    exit();
  }

  wait();
  65:	e8 d3 01 00 00       	call   23d <wait>
  
  exit();
  6a:	e8 c6 01 00 00       	call   235 <exit>
  check(getpinfo(&st) == 0, "getpinfo");
  6f:	83 ec 0c             	sub    $0xc,%esp
  72:	68 48 06 00 00       	push   $0x648
  77:	6a 17                	push   $0x17
  79:	68 51 06 00 00       	push   $0x651
  7e:	68 90 06 00 00       	push   $0x690
  83:	6a 01                	push   $0x1
  85:	e8 05 03 00 00       	call   38f <printf>
  8a:	83 c4 20             	add    $0x20,%esp
  8d:	eb 99                	jmp    28 <main+0x28>
      printf(1, "XV6_SCHEDULER\t fork2 FAILED\n");
  8f:	83 ec 08             	sub    $0x8,%esp
  92:	68 72 06 00 00       	push   $0x672
  97:	6a 01                	push   $0x1
  99:	e8 f1 02 00 00       	call   38f <printf>
  9e:	83 c4 10             	add    $0x10,%esp
  a1:	eb c2                	jmp    65 <main+0x65>
    exit();
  a3:	e8 8d 01 00 00       	call   235 <exit>

000000a8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  a8:	55                   	push   %ebp
  a9:	89 e5                	mov    %esp,%ebp
  ab:	53                   	push   %ebx
  ac:	8b 45 08             	mov    0x8(%ebp),%eax
  af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  b2:	89 c2                	mov    %eax,%edx
  b4:	0f b6 19             	movzbl (%ecx),%ebx
  b7:	88 1a                	mov    %bl,(%edx)
  b9:	8d 52 01             	lea    0x1(%edx),%edx
  bc:	8d 49 01             	lea    0x1(%ecx),%ecx
  bf:	84 db                	test   %bl,%bl
  c1:	75 f1                	jne    b4 <strcpy+0xc>
    ;
  return os;
}
  c3:	5b                   	pop    %ebx
  c4:	5d                   	pop    %ebp
  c5:	c3                   	ret    

000000c6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  c6:	55                   	push   %ebp
  c7:	89 e5                	mov    %esp,%ebp
  c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  cf:	eb 06                	jmp    d7 <strcmp+0x11>
    p++, q++;
  d1:	83 c1 01             	add    $0x1,%ecx
  d4:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  d7:	0f b6 01             	movzbl (%ecx),%eax
  da:	84 c0                	test   %al,%al
  dc:	74 04                	je     e2 <strcmp+0x1c>
  de:	3a 02                	cmp    (%edx),%al
  e0:	74 ef                	je     d1 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  e2:	0f b6 c0             	movzbl %al,%eax
  e5:	0f b6 12             	movzbl (%edx),%edx
  e8:	29 d0                	sub    %edx,%eax
}
  ea:	5d                   	pop    %ebp
  eb:	c3                   	ret    

000000ec <strlen>:

uint
strlen(const char *s)
{
  ec:	55                   	push   %ebp
  ed:	89 e5                	mov    %esp,%ebp
  ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  f2:	ba 00 00 00 00       	mov    $0x0,%edx
  f7:	eb 03                	jmp    fc <strlen+0x10>
  f9:	83 c2 01             	add    $0x1,%edx
  fc:	89 d0                	mov    %edx,%eax
  fe:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 102:	75 f5                	jne    f9 <strlen+0xd>
    ;
  return n;
}
 104:	5d                   	pop    %ebp
 105:	c3                   	ret    

00000106 <memset>:

void*
memset(void *dst, int c, uint n)
{
 106:	55                   	push   %ebp
 107:	89 e5                	mov    %esp,%ebp
 109:	57                   	push   %edi
 10a:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 10d:	89 d7                	mov    %edx,%edi
 10f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 112:	8b 45 0c             	mov    0xc(%ebp),%eax
 115:	fc                   	cld    
 116:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 118:	89 d0                	mov    %edx,%eax
 11a:	5f                   	pop    %edi
 11b:	5d                   	pop    %ebp
 11c:	c3                   	ret    

0000011d <strchr>:

char*
strchr(const char *s, char c)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
 120:	8b 45 08             	mov    0x8(%ebp),%eax
 123:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 127:	0f b6 10             	movzbl (%eax),%edx
 12a:	84 d2                	test   %dl,%dl
 12c:	74 09                	je     137 <strchr+0x1a>
    if(*s == c)
 12e:	38 ca                	cmp    %cl,%dl
 130:	74 0a                	je     13c <strchr+0x1f>
  for(; *s; s++)
 132:	83 c0 01             	add    $0x1,%eax
 135:	eb f0                	jmp    127 <strchr+0xa>
      return (char*)s;
  return 0;
 137:	b8 00 00 00 00       	mov    $0x0,%eax
}
 13c:	5d                   	pop    %ebp
 13d:	c3                   	ret    

0000013e <gets>:

char*
gets(char *buf, int max)
{
 13e:	55                   	push   %ebp
 13f:	89 e5                	mov    %esp,%ebp
 141:	57                   	push   %edi
 142:	56                   	push   %esi
 143:	53                   	push   %ebx
 144:	83 ec 1c             	sub    $0x1c,%esp
 147:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 14a:	bb 00 00 00 00       	mov    $0x0,%ebx
 14f:	8d 73 01             	lea    0x1(%ebx),%esi
 152:	3b 75 0c             	cmp    0xc(%ebp),%esi
 155:	7d 2e                	jge    185 <gets+0x47>
    cc = read(0, &c, 1);
 157:	83 ec 04             	sub    $0x4,%esp
 15a:	6a 01                	push   $0x1
 15c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 15f:	50                   	push   %eax
 160:	6a 00                	push   $0x0
 162:	e8 e6 00 00 00       	call   24d <read>
    if(cc < 1)
 167:	83 c4 10             	add    $0x10,%esp
 16a:	85 c0                	test   %eax,%eax
 16c:	7e 17                	jle    185 <gets+0x47>
      break;
    buf[i++] = c;
 16e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 172:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 175:	3c 0a                	cmp    $0xa,%al
 177:	0f 94 c2             	sete   %dl
 17a:	3c 0d                	cmp    $0xd,%al
 17c:	0f 94 c0             	sete   %al
    buf[i++] = c;
 17f:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 181:	08 c2                	or     %al,%dl
 183:	74 ca                	je     14f <gets+0x11>
      break;
  }
  buf[i] = '\0';
 185:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 189:	89 f8                	mov    %edi,%eax
 18b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 18e:	5b                   	pop    %ebx
 18f:	5e                   	pop    %esi
 190:	5f                   	pop    %edi
 191:	5d                   	pop    %ebp
 192:	c3                   	ret    

00000193 <stat>:

int
stat(const char *n, struct stat *st)
{
 193:	55                   	push   %ebp
 194:	89 e5                	mov    %esp,%ebp
 196:	56                   	push   %esi
 197:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 198:	83 ec 08             	sub    $0x8,%esp
 19b:	6a 00                	push   $0x0
 19d:	ff 75 08             	pushl  0x8(%ebp)
 1a0:	e8 d0 00 00 00       	call   275 <open>
  if(fd < 0)
 1a5:	83 c4 10             	add    $0x10,%esp
 1a8:	85 c0                	test   %eax,%eax
 1aa:	78 24                	js     1d0 <stat+0x3d>
 1ac:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1ae:	83 ec 08             	sub    $0x8,%esp
 1b1:	ff 75 0c             	pushl  0xc(%ebp)
 1b4:	50                   	push   %eax
 1b5:	e8 d3 00 00 00       	call   28d <fstat>
 1ba:	89 c6                	mov    %eax,%esi
  close(fd);
 1bc:	89 1c 24             	mov    %ebx,(%esp)
 1bf:	e8 99 00 00 00       	call   25d <close>
  return r;
 1c4:	83 c4 10             	add    $0x10,%esp
}
 1c7:	89 f0                	mov    %esi,%eax
 1c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1cc:	5b                   	pop    %ebx
 1cd:	5e                   	pop    %esi
 1ce:	5d                   	pop    %ebp
 1cf:	c3                   	ret    
    return -1;
 1d0:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1d5:	eb f0                	jmp    1c7 <stat+0x34>

000001d7 <atoi>:

int
atoi(const char *s)
{
 1d7:	55                   	push   %ebp
 1d8:	89 e5                	mov    %esp,%ebp
 1da:	53                   	push   %ebx
 1db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1de:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1e3:	eb 10                	jmp    1f5 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1e5:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1e8:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1eb:	83 c1 01             	add    $0x1,%ecx
 1ee:	0f be d2             	movsbl %dl,%edx
 1f1:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1f5:	0f b6 11             	movzbl (%ecx),%edx
 1f8:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1fb:	80 fb 09             	cmp    $0x9,%bl
 1fe:	76 e5                	jbe    1e5 <atoi+0xe>
  return n;
}
 200:	5b                   	pop    %ebx
 201:	5d                   	pop    %ebp
 202:	c3                   	ret    

00000203 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 203:	55                   	push   %ebp
 204:	89 e5                	mov    %esp,%ebp
 206:	56                   	push   %esi
 207:	53                   	push   %ebx
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 20e:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 211:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 213:	eb 0d                	jmp    222 <memmove+0x1f>
    *dst++ = *src++;
 215:	0f b6 13             	movzbl (%ebx),%edx
 218:	88 11                	mov    %dl,(%ecx)
 21a:	8d 5b 01             	lea    0x1(%ebx),%ebx
 21d:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 220:	89 f2                	mov    %esi,%edx
 222:	8d 72 ff             	lea    -0x1(%edx),%esi
 225:	85 d2                	test   %edx,%edx
 227:	7f ec                	jg     215 <memmove+0x12>
  return vdst;
}
 229:	5b                   	pop    %ebx
 22a:	5e                   	pop    %esi
 22b:	5d                   	pop    %ebp
 22c:	c3                   	ret    

0000022d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 22d:	b8 01 00 00 00       	mov    $0x1,%eax
 232:	cd 40                	int    $0x40
 234:	c3                   	ret    

00000235 <exit>:
SYSCALL(exit)
 235:	b8 02 00 00 00       	mov    $0x2,%eax
 23a:	cd 40                	int    $0x40
 23c:	c3                   	ret    

0000023d <wait>:
SYSCALL(wait)
 23d:	b8 03 00 00 00       	mov    $0x3,%eax
 242:	cd 40                	int    $0x40
 244:	c3                   	ret    

00000245 <pipe>:
SYSCALL(pipe)
 245:	b8 04 00 00 00       	mov    $0x4,%eax
 24a:	cd 40                	int    $0x40
 24c:	c3                   	ret    

0000024d <read>:
SYSCALL(read)
 24d:	b8 05 00 00 00       	mov    $0x5,%eax
 252:	cd 40                	int    $0x40
 254:	c3                   	ret    

00000255 <write>:
SYSCALL(write)
 255:	b8 10 00 00 00       	mov    $0x10,%eax
 25a:	cd 40                	int    $0x40
 25c:	c3                   	ret    

0000025d <close>:
SYSCALL(close)
 25d:	b8 15 00 00 00       	mov    $0x15,%eax
 262:	cd 40                	int    $0x40
 264:	c3                   	ret    

00000265 <kill>:
SYSCALL(kill)
 265:	b8 06 00 00 00       	mov    $0x6,%eax
 26a:	cd 40                	int    $0x40
 26c:	c3                   	ret    

0000026d <exec>:
SYSCALL(exec)
 26d:	b8 07 00 00 00       	mov    $0x7,%eax
 272:	cd 40                	int    $0x40
 274:	c3                   	ret    

00000275 <open>:
SYSCALL(open)
 275:	b8 0f 00 00 00       	mov    $0xf,%eax
 27a:	cd 40                	int    $0x40
 27c:	c3                   	ret    

0000027d <mknod>:
SYSCALL(mknod)
 27d:	b8 11 00 00 00       	mov    $0x11,%eax
 282:	cd 40                	int    $0x40
 284:	c3                   	ret    

00000285 <unlink>:
SYSCALL(unlink)
 285:	b8 12 00 00 00       	mov    $0x12,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <fstat>:
SYSCALL(fstat)
 28d:	b8 08 00 00 00       	mov    $0x8,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <link>:
SYSCALL(link)
 295:	b8 13 00 00 00       	mov    $0x13,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <mkdir>:
SYSCALL(mkdir)
 29d:	b8 14 00 00 00       	mov    $0x14,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <chdir>:
SYSCALL(chdir)
 2a5:	b8 09 00 00 00       	mov    $0x9,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <dup>:
SYSCALL(dup)
 2ad:	b8 0a 00 00 00       	mov    $0xa,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <getpid>:
SYSCALL(getpid)
 2b5:	b8 0b 00 00 00       	mov    $0xb,%eax
 2ba:	cd 40                	int    $0x40
 2bc:	c3                   	ret    

000002bd <sbrk>:
SYSCALL(sbrk)
 2bd:	b8 0c 00 00 00       	mov    $0xc,%eax
 2c2:	cd 40                	int    $0x40
 2c4:	c3                   	ret    

000002c5 <sleep>:
SYSCALL(sleep)
 2c5:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ca:	cd 40                	int    $0x40
 2cc:	c3                   	ret    

000002cd <uptime>:
SYSCALL(uptime)
 2cd:	b8 0e 00 00 00       	mov    $0xe,%eax
 2d2:	cd 40                	int    $0x40
 2d4:	c3                   	ret    

000002d5 <setpri>:
SYSCALL(setpri)
 2d5:	b8 16 00 00 00       	mov    $0x16,%eax
 2da:	cd 40                	int    $0x40
 2dc:	c3                   	ret    

000002dd <getpri>:
SYSCALL(getpri)
 2dd:	b8 17 00 00 00       	mov    $0x17,%eax
 2e2:	cd 40                	int    $0x40
 2e4:	c3                   	ret    

000002e5 <fork2>:
SYSCALL(fork2)
 2e5:	b8 18 00 00 00       	mov    $0x18,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <getpinfo>:
SYSCALL(getpinfo)
 2ed:	b8 19 00 00 00       	mov    $0x19,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2f5:	55                   	push   %ebp
 2f6:	89 e5                	mov    %esp,%ebp
 2f8:	83 ec 1c             	sub    $0x1c,%esp
 2fb:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2fe:	6a 01                	push   $0x1
 300:	8d 55 f4             	lea    -0xc(%ebp),%edx
 303:	52                   	push   %edx
 304:	50                   	push   %eax
 305:	e8 4b ff ff ff       	call   255 <write>
}
 30a:	83 c4 10             	add    $0x10,%esp
 30d:	c9                   	leave  
 30e:	c3                   	ret    

0000030f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 30f:	55                   	push   %ebp
 310:	89 e5                	mov    %esp,%ebp
 312:	57                   	push   %edi
 313:	56                   	push   %esi
 314:	53                   	push   %ebx
 315:	83 ec 2c             	sub    $0x2c,%esp
 318:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 31a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 31e:	0f 95 c3             	setne  %bl
 321:	89 d0                	mov    %edx,%eax
 323:	c1 e8 1f             	shr    $0x1f,%eax
 326:	84 c3                	test   %al,%bl
 328:	74 10                	je     33a <printint+0x2b>
    neg = 1;
    x = -xx;
 32a:	f7 da                	neg    %edx
    neg = 1;
 32c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 333:	be 00 00 00 00       	mov    $0x0,%esi
 338:	eb 0b                	jmp    345 <printint+0x36>
  neg = 0;
 33a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 341:	eb f0                	jmp    333 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 343:	89 c6                	mov    %eax,%esi
 345:	89 d0                	mov    %edx,%eax
 347:	ba 00 00 00 00       	mov    $0x0,%edx
 34c:	f7 f1                	div    %ecx
 34e:	89 c3                	mov    %eax,%ebx
 350:	8d 46 01             	lea    0x1(%esi),%eax
 353:	0f b6 92 c8 06 00 00 	movzbl 0x6c8(%edx),%edx
 35a:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 35e:	89 da                	mov    %ebx,%edx
 360:	85 db                	test   %ebx,%ebx
 362:	75 df                	jne    343 <printint+0x34>
 364:	89 c3                	mov    %eax,%ebx
  if(neg)
 366:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 36a:	74 16                	je     382 <printint+0x73>
    buf[i++] = '-';
 36c:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 371:	8d 5e 02             	lea    0x2(%esi),%ebx
 374:	eb 0c                	jmp    382 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 376:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 37b:	89 f8                	mov    %edi,%eax
 37d:	e8 73 ff ff ff       	call   2f5 <putc>
  while(--i >= 0)
 382:	83 eb 01             	sub    $0x1,%ebx
 385:	79 ef                	jns    376 <printint+0x67>
}
 387:	83 c4 2c             	add    $0x2c,%esp
 38a:	5b                   	pop    %ebx
 38b:	5e                   	pop    %esi
 38c:	5f                   	pop    %edi
 38d:	5d                   	pop    %ebp
 38e:	c3                   	ret    

0000038f <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 38f:	55                   	push   %ebp
 390:	89 e5                	mov    %esp,%ebp
 392:	57                   	push   %edi
 393:	56                   	push   %esi
 394:	53                   	push   %ebx
 395:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 398:	8d 45 10             	lea    0x10(%ebp),%eax
 39b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 39e:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3a3:	bb 00 00 00 00       	mov    $0x0,%ebx
 3a8:	eb 14                	jmp    3be <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3aa:	89 fa                	mov    %edi,%edx
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
 3af:	e8 41 ff ff ff       	call   2f5 <putc>
 3b4:	eb 05                	jmp    3bb <printf+0x2c>
      }
    } else if(state == '%'){
 3b6:	83 fe 25             	cmp    $0x25,%esi
 3b9:	74 25                	je     3e0 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3bb:	83 c3 01             	add    $0x1,%ebx
 3be:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c1:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3c5:	84 c0                	test   %al,%al
 3c7:	0f 84 23 01 00 00    	je     4f0 <printf+0x161>
    c = fmt[i] & 0xff;
 3cd:	0f be f8             	movsbl %al,%edi
 3d0:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3d3:	85 f6                	test   %esi,%esi
 3d5:	75 df                	jne    3b6 <printf+0x27>
      if(c == '%'){
 3d7:	83 f8 25             	cmp    $0x25,%eax
 3da:	75 ce                	jne    3aa <printf+0x1b>
        state = '%';
 3dc:	89 c6                	mov    %eax,%esi
 3de:	eb db                	jmp    3bb <printf+0x2c>
      if(c == 'd'){
 3e0:	83 f8 64             	cmp    $0x64,%eax
 3e3:	74 49                	je     42e <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3e5:	83 f8 78             	cmp    $0x78,%eax
 3e8:	0f 94 c1             	sete   %cl
 3eb:	83 f8 70             	cmp    $0x70,%eax
 3ee:	0f 94 c2             	sete   %dl
 3f1:	08 d1                	or     %dl,%cl
 3f3:	75 63                	jne    458 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3f5:	83 f8 73             	cmp    $0x73,%eax
 3f8:	0f 84 84 00 00 00    	je     482 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3fe:	83 f8 63             	cmp    $0x63,%eax
 401:	0f 84 b7 00 00 00    	je     4be <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 407:	83 f8 25             	cmp    $0x25,%eax
 40a:	0f 84 cc 00 00 00    	je     4dc <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 410:	ba 25 00 00 00       	mov    $0x25,%edx
 415:	8b 45 08             	mov    0x8(%ebp),%eax
 418:	e8 d8 fe ff ff       	call   2f5 <putc>
        putc(fd, c);
 41d:	89 fa                	mov    %edi,%edx
 41f:	8b 45 08             	mov    0x8(%ebp),%eax
 422:	e8 ce fe ff ff       	call   2f5 <putc>
      }
      state = 0;
 427:	be 00 00 00 00       	mov    $0x0,%esi
 42c:	eb 8d                	jmp    3bb <printf+0x2c>
        printint(fd, *ap, 10, 1);
 42e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 431:	8b 17                	mov    (%edi),%edx
 433:	83 ec 0c             	sub    $0xc,%esp
 436:	6a 01                	push   $0x1
 438:	b9 0a 00 00 00       	mov    $0xa,%ecx
 43d:	8b 45 08             	mov    0x8(%ebp),%eax
 440:	e8 ca fe ff ff       	call   30f <printint>
        ap++;
 445:	83 c7 04             	add    $0x4,%edi
 448:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 44b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 44e:	be 00 00 00 00       	mov    $0x0,%esi
 453:	e9 63 ff ff ff       	jmp    3bb <printf+0x2c>
        printint(fd, *ap, 16, 0);
 458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 45b:	8b 17                	mov    (%edi),%edx
 45d:	83 ec 0c             	sub    $0xc,%esp
 460:	6a 00                	push   $0x0
 462:	b9 10 00 00 00       	mov    $0x10,%ecx
 467:	8b 45 08             	mov    0x8(%ebp),%eax
 46a:	e8 a0 fe ff ff       	call   30f <printint>
        ap++;
 46f:	83 c7 04             	add    $0x4,%edi
 472:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 475:	83 c4 10             	add    $0x10,%esp
      state = 0;
 478:	be 00 00 00 00       	mov    $0x0,%esi
 47d:	e9 39 ff ff ff       	jmp    3bb <printf+0x2c>
        s = (char*)*ap;
 482:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 485:	8b 30                	mov    (%eax),%esi
        ap++;
 487:	83 c0 04             	add    $0x4,%eax
 48a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 48d:	85 f6                	test   %esi,%esi
 48f:	75 28                	jne    4b9 <printf+0x12a>
          s = "(null)";
 491:	be c0 06 00 00       	mov    $0x6c0,%esi
 496:	8b 7d 08             	mov    0x8(%ebp),%edi
 499:	eb 0d                	jmp    4a8 <printf+0x119>
          putc(fd, *s);
 49b:	0f be d2             	movsbl %dl,%edx
 49e:	89 f8                	mov    %edi,%eax
 4a0:	e8 50 fe ff ff       	call   2f5 <putc>
          s++;
 4a5:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4a8:	0f b6 16             	movzbl (%esi),%edx
 4ab:	84 d2                	test   %dl,%dl
 4ad:	75 ec                	jne    49b <printf+0x10c>
      state = 0;
 4af:	be 00 00 00 00       	mov    $0x0,%esi
 4b4:	e9 02 ff ff ff       	jmp    3bb <printf+0x2c>
 4b9:	8b 7d 08             	mov    0x8(%ebp),%edi
 4bc:	eb ea                	jmp    4a8 <printf+0x119>
        putc(fd, *ap);
 4be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4c1:	0f be 17             	movsbl (%edi),%edx
 4c4:	8b 45 08             	mov    0x8(%ebp),%eax
 4c7:	e8 29 fe ff ff       	call   2f5 <putc>
        ap++;
 4cc:	83 c7 04             	add    $0x4,%edi
 4cf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4d2:	be 00 00 00 00       	mov    $0x0,%esi
 4d7:	e9 df fe ff ff       	jmp    3bb <printf+0x2c>
        putc(fd, c);
 4dc:	89 fa                	mov    %edi,%edx
 4de:	8b 45 08             	mov    0x8(%ebp),%eax
 4e1:	e8 0f fe ff ff       	call   2f5 <putc>
      state = 0;
 4e6:	be 00 00 00 00       	mov    $0x0,%esi
 4eb:	e9 cb fe ff ff       	jmp    3bb <printf+0x2c>
    }
  }
}
 4f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4f3:	5b                   	pop    %ebx
 4f4:	5e                   	pop    %esi
 4f5:	5f                   	pop    %edi
 4f6:	5d                   	pop    %ebp
 4f7:	c3                   	ret    

000004f8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4f8:	55                   	push   %ebp
 4f9:	89 e5                	mov    %esp,%ebp
 4fb:	57                   	push   %edi
 4fc:	56                   	push   %esi
 4fd:	53                   	push   %ebx
 4fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 501:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 504:	a1 64 09 00 00       	mov    0x964,%eax
 509:	eb 02                	jmp    50d <free+0x15>
 50b:	89 d0                	mov    %edx,%eax
 50d:	39 c8                	cmp    %ecx,%eax
 50f:	73 04                	jae    515 <free+0x1d>
 511:	39 08                	cmp    %ecx,(%eax)
 513:	77 12                	ja     527 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 515:	8b 10                	mov    (%eax),%edx
 517:	39 c2                	cmp    %eax,%edx
 519:	77 f0                	ja     50b <free+0x13>
 51b:	39 c8                	cmp    %ecx,%eax
 51d:	72 08                	jb     527 <free+0x2f>
 51f:	39 ca                	cmp    %ecx,%edx
 521:	77 04                	ja     527 <free+0x2f>
 523:	89 d0                	mov    %edx,%eax
 525:	eb e6                	jmp    50d <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 527:	8b 73 fc             	mov    -0x4(%ebx),%esi
 52a:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 52d:	8b 10                	mov    (%eax),%edx
 52f:	39 d7                	cmp    %edx,%edi
 531:	74 19                	je     54c <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 533:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 536:	8b 50 04             	mov    0x4(%eax),%edx
 539:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 53c:	39 ce                	cmp    %ecx,%esi
 53e:	74 1b                	je     55b <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 540:	89 08                	mov    %ecx,(%eax)
  freep = p;
 542:	a3 64 09 00 00       	mov    %eax,0x964
}
 547:	5b                   	pop    %ebx
 548:	5e                   	pop    %esi
 549:	5f                   	pop    %edi
 54a:	5d                   	pop    %ebp
 54b:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 54c:	03 72 04             	add    0x4(%edx),%esi
 54f:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 552:	8b 10                	mov    (%eax),%edx
 554:	8b 12                	mov    (%edx),%edx
 556:	89 53 f8             	mov    %edx,-0x8(%ebx)
 559:	eb db                	jmp    536 <free+0x3e>
    p->s.size += bp->s.size;
 55b:	03 53 fc             	add    -0x4(%ebx),%edx
 55e:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 561:	8b 53 f8             	mov    -0x8(%ebx),%edx
 564:	89 10                	mov    %edx,(%eax)
 566:	eb da                	jmp    542 <free+0x4a>

00000568 <morecore>:

static Header*
morecore(uint nu)
{
 568:	55                   	push   %ebp
 569:	89 e5                	mov    %esp,%ebp
 56b:	53                   	push   %ebx
 56c:	83 ec 04             	sub    $0x4,%esp
 56f:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 571:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 576:	77 05                	ja     57d <morecore+0x15>
    nu = 4096;
 578:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 57d:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 584:	83 ec 0c             	sub    $0xc,%esp
 587:	50                   	push   %eax
 588:	e8 30 fd ff ff       	call   2bd <sbrk>
  if(p == (char*)-1)
 58d:	83 c4 10             	add    $0x10,%esp
 590:	83 f8 ff             	cmp    $0xffffffff,%eax
 593:	74 1c                	je     5b1 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 595:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 598:	83 c0 08             	add    $0x8,%eax
 59b:	83 ec 0c             	sub    $0xc,%esp
 59e:	50                   	push   %eax
 59f:	e8 54 ff ff ff       	call   4f8 <free>
  return freep;
 5a4:	a1 64 09 00 00       	mov    0x964,%eax
 5a9:	83 c4 10             	add    $0x10,%esp
}
 5ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5af:	c9                   	leave  
 5b0:	c3                   	ret    
    return 0;
 5b1:	b8 00 00 00 00       	mov    $0x0,%eax
 5b6:	eb f4                	jmp    5ac <morecore+0x44>

000005b8 <malloc>:

void*
malloc(uint nbytes)
{
 5b8:	55                   	push   %ebp
 5b9:	89 e5                	mov    %esp,%ebp
 5bb:	53                   	push   %ebx
 5bc:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5bf:	8b 45 08             	mov    0x8(%ebp),%eax
 5c2:	8d 58 07             	lea    0x7(%eax),%ebx
 5c5:	c1 eb 03             	shr    $0x3,%ebx
 5c8:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5cb:	8b 0d 64 09 00 00    	mov    0x964,%ecx
 5d1:	85 c9                	test   %ecx,%ecx
 5d3:	74 04                	je     5d9 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5d5:	8b 01                	mov    (%ecx),%eax
 5d7:	eb 4d                	jmp    626 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5d9:	c7 05 64 09 00 00 68 	movl   $0x968,0x964
 5e0:	09 00 00 
 5e3:	c7 05 68 09 00 00 68 	movl   $0x968,0x968
 5ea:	09 00 00 
    base.s.size = 0;
 5ed:	c7 05 6c 09 00 00 00 	movl   $0x0,0x96c
 5f4:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5f7:	b9 68 09 00 00       	mov    $0x968,%ecx
 5fc:	eb d7                	jmp    5d5 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5fe:	39 da                	cmp    %ebx,%edx
 600:	74 1a                	je     61c <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 602:	29 da                	sub    %ebx,%edx
 604:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 607:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 60a:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 60d:	89 0d 64 09 00 00    	mov    %ecx,0x964
      return (void*)(p + 1);
 613:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 616:	83 c4 04             	add    $0x4,%esp
 619:	5b                   	pop    %ebx
 61a:	5d                   	pop    %ebp
 61b:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 61c:	8b 10                	mov    (%eax),%edx
 61e:	89 11                	mov    %edx,(%ecx)
 620:	eb eb                	jmp    60d <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 622:	89 c1                	mov    %eax,%ecx
 624:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 626:	8b 50 04             	mov    0x4(%eax),%edx
 629:	39 da                	cmp    %ebx,%edx
 62b:	73 d1                	jae    5fe <malloc+0x46>
    if(p == freep)
 62d:	39 05 64 09 00 00    	cmp    %eax,0x964
 633:	75 ed                	jne    622 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 635:	89 d8                	mov    %ebx,%eax
 637:	e8 2c ff ff ff       	call   568 <morecore>
 63c:	85 c0                	test   %eax,%eax
 63e:	75 e2                	jne    622 <malloc+0x6a>
        return 0;
 640:	b8 00 00 00 00       	mov    $0x0,%eax
 645:	eb cf                	jmp    616 <malloc+0x5e>
