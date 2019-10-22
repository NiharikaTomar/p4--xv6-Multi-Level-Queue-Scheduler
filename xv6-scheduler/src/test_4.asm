
_test_4:     file format elf32-i386


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
   e:	81 ec 10 0c 00 00    	sub    $0xc10,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  14:	8d 85 f8 f3 ff ff    	lea    -0xc08(%ebp),%eax
  1a:	50                   	push   %eax
  1b:	e8 ab 02 00 00       	call   2cb <getpinfo>
  20:	83 c4 10             	add    $0x10,%esp
  23:	85 c0                	test   %eax,%eax
  25:	75 2b                	jne    52 <main+0x52>

  int pret;

  pret = setpri(-1, 2);
  27:	83 ec 08             	sub    $0x8,%esp
  2a:	6a 02                	push   $0x2
  2c:	6a ff                	push   $0xffffffff
  2e:	e8 80 02 00 00       	call   2b3 <setpri>

  if( pret == -1){
  33:	83 c4 10             	add    $0x10,%esp
  36:	83 f8 ff             	cmp    $0xffffffff,%eax
  39:	74 37                	je     72 <main+0x72>
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  } else{
    printf(1, "XV6_SCHEDULER\t setpri FAILED to return the correct error return code\n");
  3b:	83 ec 08             	sub    $0x8,%esp
  3e:	68 84 06 00 00       	push   $0x684
  43:	6a 01                	push   $0x1
  45:	e8 23 03 00 00       	call   36d <printf>
  4a:	83 c4 10             	add    $0x10,%esp
  }
  
  exit();
  4d:	e8 c1 01 00 00       	call   213 <exit>
  check(getpinfo(&st) == 0, "getpinfo");
  52:	83 ec 0c             	sub    $0xc,%esp
  55:	68 28 06 00 00       	push   $0x628
  5a:	6a 17                	push   $0x17
  5c:	68 31 06 00 00       	push   $0x631
  61:	68 54 06 00 00       	push   $0x654
  66:	6a 01                	push   $0x1
  68:	e8 00 03 00 00       	call   36d <printf>
  6d:	83 c4 20             	add    $0x20,%esp
  70:	eb b5                	jmp    27 <main+0x27>
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  72:	83 ec 08             	sub    $0x8,%esp
  75:	68 3a 06 00 00       	push   $0x63a
  7a:	6a 01                	push   $0x1
  7c:	e8 ec 02 00 00       	call   36d <printf>
  81:	83 c4 10             	add    $0x10,%esp
  84:	eb c7                	jmp    4d <main+0x4d>

00000086 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  89:	53                   	push   %ebx
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  90:	89 c2                	mov    %eax,%edx
  92:	0f b6 19             	movzbl (%ecx),%ebx
  95:	88 1a                	mov    %bl,(%edx)
  97:	8d 52 01             	lea    0x1(%edx),%edx
  9a:	8d 49 01             	lea    0x1(%ecx),%ecx
  9d:	84 db                	test   %bl,%bl
  9f:	75 f1                	jne    92 <strcpy+0xc>
    ;
  return os;
}
  a1:	5b                   	pop    %ebx
  a2:	5d                   	pop    %ebp
  a3:	c3                   	ret    

000000a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a4:	55                   	push   %ebp
  a5:	89 e5                	mov    %esp,%ebp
  a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  ad:	eb 06                	jmp    b5 <strcmp+0x11>
    p++, q++;
  af:	83 c1 01             	add    $0x1,%ecx
  b2:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  b5:	0f b6 01             	movzbl (%ecx),%eax
  b8:	84 c0                	test   %al,%al
  ba:	74 04                	je     c0 <strcmp+0x1c>
  bc:	3a 02                	cmp    (%edx),%al
  be:	74 ef                	je     af <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  c0:	0f b6 c0             	movzbl %al,%eax
  c3:	0f b6 12             	movzbl (%edx),%edx
  c6:	29 d0                	sub    %edx,%eax
}
  c8:	5d                   	pop    %ebp
  c9:	c3                   	ret    

000000ca <strlen>:

uint
strlen(const char *s)
{
  ca:	55                   	push   %ebp
  cb:	89 e5                	mov    %esp,%ebp
  cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  d0:	ba 00 00 00 00       	mov    $0x0,%edx
  d5:	eb 03                	jmp    da <strlen+0x10>
  d7:	83 c2 01             	add    $0x1,%edx
  da:	89 d0                	mov    %edx,%eax
  dc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  e0:	75 f5                	jne    d7 <strlen+0xd>
    ;
  return n;
}
  e2:	5d                   	pop    %ebp
  e3:	c3                   	ret    

000000e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	57                   	push   %edi
  e8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  eb:	89 d7                	mov    %edx,%edi
  ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	fc                   	cld    
  f4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  f6:	89 d0                	mov    %edx,%eax
  f8:	5f                   	pop    %edi
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    

000000fb <strchr>:

char*
strchr(const char *s, char c)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  fe:	8b 45 08             	mov    0x8(%ebp),%eax
 101:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 105:	0f b6 10             	movzbl (%eax),%edx
 108:	84 d2                	test   %dl,%dl
 10a:	74 09                	je     115 <strchr+0x1a>
    if(*s == c)
 10c:	38 ca                	cmp    %cl,%dl
 10e:	74 0a                	je     11a <strchr+0x1f>
  for(; *s; s++)
 110:	83 c0 01             	add    $0x1,%eax
 113:	eb f0                	jmp    105 <strchr+0xa>
      return (char*)s;
  return 0;
 115:	b8 00 00 00 00       	mov    $0x0,%eax
}
 11a:	5d                   	pop    %ebp
 11b:	c3                   	ret    

0000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	57                   	push   %edi
 120:	56                   	push   %esi
 121:	53                   	push   %ebx
 122:	83 ec 1c             	sub    $0x1c,%esp
 125:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	bb 00 00 00 00       	mov    $0x0,%ebx
 12d:	8d 73 01             	lea    0x1(%ebx),%esi
 130:	3b 75 0c             	cmp    0xc(%ebp),%esi
 133:	7d 2e                	jge    163 <gets+0x47>
    cc = read(0, &c, 1);
 135:	83 ec 04             	sub    $0x4,%esp
 138:	6a 01                	push   $0x1
 13a:	8d 45 e7             	lea    -0x19(%ebp),%eax
 13d:	50                   	push   %eax
 13e:	6a 00                	push   $0x0
 140:	e8 e6 00 00 00       	call   22b <read>
    if(cc < 1)
 145:	83 c4 10             	add    $0x10,%esp
 148:	85 c0                	test   %eax,%eax
 14a:	7e 17                	jle    163 <gets+0x47>
      break;
    buf[i++] = c;
 14c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 150:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 153:	3c 0a                	cmp    $0xa,%al
 155:	0f 94 c2             	sete   %dl
 158:	3c 0d                	cmp    $0xd,%al
 15a:	0f 94 c0             	sete   %al
    buf[i++] = c;
 15d:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 15f:	08 c2                	or     %al,%dl
 161:	74 ca                	je     12d <gets+0x11>
      break;
  }
  buf[i] = '\0';
 163:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 167:	89 f8                	mov    %edi,%eax
 169:	8d 65 f4             	lea    -0xc(%ebp),%esp
 16c:	5b                   	pop    %ebx
 16d:	5e                   	pop    %esi
 16e:	5f                   	pop    %edi
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    

00000171 <stat>:

int
stat(const char *n, struct stat *st)
{
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
 174:	56                   	push   %esi
 175:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 176:	83 ec 08             	sub    $0x8,%esp
 179:	6a 00                	push   $0x0
 17b:	ff 75 08             	pushl  0x8(%ebp)
 17e:	e8 d0 00 00 00       	call   253 <open>
  if(fd < 0)
 183:	83 c4 10             	add    $0x10,%esp
 186:	85 c0                	test   %eax,%eax
 188:	78 24                	js     1ae <stat+0x3d>
 18a:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 18c:	83 ec 08             	sub    $0x8,%esp
 18f:	ff 75 0c             	pushl  0xc(%ebp)
 192:	50                   	push   %eax
 193:	e8 d3 00 00 00       	call   26b <fstat>
 198:	89 c6                	mov    %eax,%esi
  close(fd);
 19a:	89 1c 24             	mov    %ebx,(%esp)
 19d:	e8 99 00 00 00       	call   23b <close>
  return r;
 1a2:	83 c4 10             	add    $0x10,%esp
}
 1a5:	89 f0                	mov    %esi,%eax
 1a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1aa:	5b                   	pop    %ebx
 1ab:	5e                   	pop    %esi
 1ac:	5d                   	pop    %ebp
 1ad:	c3                   	ret    
    return -1;
 1ae:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1b3:	eb f0                	jmp    1a5 <stat+0x34>

000001b5 <atoi>:

int
atoi(const char *s)
{
 1b5:	55                   	push   %ebp
 1b6:	89 e5                	mov    %esp,%ebp
 1b8:	53                   	push   %ebx
 1b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1bc:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1c1:	eb 10                	jmp    1d3 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1c3:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1c6:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1c9:	83 c1 01             	add    $0x1,%ecx
 1cc:	0f be d2             	movsbl %dl,%edx
 1cf:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1d3:	0f b6 11             	movzbl (%ecx),%edx
 1d6:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1d9:	80 fb 09             	cmp    $0x9,%bl
 1dc:	76 e5                	jbe    1c3 <atoi+0xe>
  return n;
}
 1de:	5b                   	pop    %ebx
 1df:	5d                   	pop    %ebp
 1e0:	c3                   	ret    

000001e1 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	56                   	push   %esi
 1e5:	53                   	push   %ebx
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1ec:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1ef:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1f1:	eb 0d                	jmp    200 <memmove+0x1f>
    *dst++ = *src++;
 1f3:	0f b6 13             	movzbl (%ebx),%edx
 1f6:	88 11                	mov    %dl,(%ecx)
 1f8:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1fb:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1fe:	89 f2                	mov    %esi,%edx
 200:	8d 72 ff             	lea    -0x1(%edx),%esi
 203:	85 d2                	test   %edx,%edx
 205:	7f ec                	jg     1f3 <memmove+0x12>
  return vdst;
}
 207:	5b                   	pop    %ebx
 208:	5e                   	pop    %esi
 209:	5d                   	pop    %ebp
 20a:	c3                   	ret    

0000020b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 20b:	b8 01 00 00 00       	mov    $0x1,%eax
 210:	cd 40                	int    $0x40
 212:	c3                   	ret    

00000213 <exit>:
SYSCALL(exit)
 213:	b8 02 00 00 00       	mov    $0x2,%eax
 218:	cd 40                	int    $0x40
 21a:	c3                   	ret    

0000021b <wait>:
SYSCALL(wait)
 21b:	b8 03 00 00 00       	mov    $0x3,%eax
 220:	cd 40                	int    $0x40
 222:	c3                   	ret    

00000223 <pipe>:
SYSCALL(pipe)
 223:	b8 04 00 00 00       	mov    $0x4,%eax
 228:	cd 40                	int    $0x40
 22a:	c3                   	ret    

0000022b <read>:
SYSCALL(read)
 22b:	b8 05 00 00 00       	mov    $0x5,%eax
 230:	cd 40                	int    $0x40
 232:	c3                   	ret    

00000233 <write>:
SYSCALL(write)
 233:	b8 10 00 00 00       	mov    $0x10,%eax
 238:	cd 40                	int    $0x40
 23a:	c3                   	ret    

0000023b <close>:
SYSCALL(close)
 23b:	b8 15 00 00 00       	mov    $0x15,%eax
 240:	cd 40                	int    $0x40
 242:	c3                   	ret    

00000243 <kill>:
SYSCALL(kill)
 243:	b8 06 00 00 00       	mov    $0x6,%eax
 248:	cd 40                	int    $0x40
 24a:	c3                   	ret    

0000024b <exec>:
SYSCALL(exec)
 24b:	b8 07 00 00 00       	mov    $0x7,%eax
 250:	cd 40                	int    $0x40
 252:	c3                   	ret    

00000253 <open>:
SYSCALL(open)
 253:	b8 0f 00 00 00       	mov    $0xf,%eax
 258:	cd 40                	int    $0x40
 25a:	c3                   	ret    

0000025b <mknod>:
SYSCALL(mknod)
 25b:	b8 11 00 00 00       	mov    $0x11,%eax
 260:	cd 40                	int    $0x40
 262:	c3                   	ret    

00000263 <unlink>:
SYSCALL(unlink)
 263:	b8 12 00 00 00       	mov    $0x12,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <fstat>:
SYSCALL(fstat)
 26b:	b8 08 00 00 00       	mov    $0x8,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <link>:
SYSCALL(link)
 273:	b8 13 00 00 00       	mov    $0x13,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <mkdir>:
SYSCALL(mkdir)
 27b:	b8 14 00 00 00       	mov    $0x14,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <chdir>:
SYSCALL(chdir)
 283:	b8 09 00 00 00       	mov    $0x9,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <dup>:
SYSCALL(dup)
 28b:	b8 0a 00 00 00       	mov    $0xa,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <getpid>:
SYSCALL(getpid)
 293:	b8 0b 00 00 00       	mov    $0xb,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <sbrk>:
SYSCALL(sbrk)
 29b:	b8 0c 00 00 00       	mov    $0xc,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <sleep>:
SYSCALL(sleep)
 2a3:	b8 0d 00 00 00       	mov    $0xd,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <uptime>:
SYSCALL(uptime)
 2ab:	b8 0e 00 00 00       	mov    $0xe,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <setpri>:
SYSCALL(setpri)
 2b3:	b8 16 00 00 00       	mov    $0x16,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <getpri>:
SYSCALL(getpri)
 2bb:	b8 17 00 00 00       	mov    $0x17,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <fork2>:
SYSCALL(fork2)
 2c3:	b8 18 00 00 00       	mov    $0x18,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <getpinfo>:
SYSCALL(getpinfo)
 2cb:	b8 19 00 00 00       	mov    $0x19,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2d3:	55                   	push   %ebp
 2d4:	89 e5                	mov    %esp,%ebp
 2d6:	83 ec 1c             	sub    $0x1c,%esp
 2d9:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2dc:	6a 01                	push   $0x1
 2de:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2e1:	52                   	push   %edx
 2e2:	50                   	push   %eax
 2e3:	e8 4b ff ff ff       	call   233 <write>
}
 2e8:	83 c4 10             	add    $0x10,%esp
 2eb:	c9                   	leave  
 2ec:	c3                   	ret    

000002ed <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2ed:	55                   	push   %ebp
 2ee:	89 e5                	mov    %esp,%ebp
 2f0:	57                   	push   %edi
 2f1:	56                   	push   %esi
 2f2:	53                   	push   %ebx
 2f3:	83 ec 2c             	sub    $0x2c,%esp
 2f6:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2fc:	0f 95 c3             	setne  %bl
 2ff:	89 d0                	mov    %edx,%eax
 301:	c1 e8 1f             	shr    $0x1f,%eax
 304:	84 c3                	test   %al,%bl
 306:	74 10                	je     318 <printint+0x2b>
    neg = 1;
    x = -xx;
 308:	f7 da                	neg    %edx
    neg = 1;
 30a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 311:	be 00 00 00 00       	mov    $0x0,%esi
 316:	eb 0b                	jmp    323 <printint+0x36>
  neg = 0;
 318:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 31f:	eb f0                	jmp    311 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 321:	89 c6                	mov    %eax,%esi
 323:	89 d0                	mov    %edx,%eax
 325:	ba 00 00 00 00       	mov    $0x0,%edx
 32a:	f7 f1                	div    %ecx
 32c:	89 c3                	mov    %eax,%ebx
 32e:	8d 46 01             	lea    0x1(%esi),%eax
 331:	0f b6 92 d4 06 00 00 	movzbl 0x6d4(%edx),%edx
 338:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 33c:	89 da                	mov    %ebx,%edx
 33e:	85 db                	test   %ebx,%ebx
 340:	75 df                	jne    321 <printint+0x34>
 342:	89 c3                	mov    %eax,%ebx
  if(neg)
 344:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 348:	74 16                	je     360 <printint+0x73>
    buf[i++] = '-';
 34a:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 34f:	8d 5e 02             	lea    0x2(%esi),%ebx
 352:	eb 0c                	jmp    360 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 354:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 359:	89 f8                	mov    %edi,%eax
 35b:	e8 73 ff ff ff       	call   2d3 <putc>
  while(--i >= 0)
 360:	83 eb 01             	sub    $0x1,%ebx
 363:	79 ef                	jns    354 <printint+0x67>
}
 365:	83 c4 2c             	add    $0x2c,%esp
 368:	5b                   	pop    %ebx
 369:	5e                   	pop    %esi
 36a:	5f                   	pop    %edi
 36b:	5d                   	pop    %ebp
 36c:	c3                   	ret    

0000036d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 36d:	55                   	push   %ebp
 36e:	89 e5                	mov    %esp,%ebp
 370:	57                   	push   %edi
 371:	56                   	push   %esi
 372:	53                   	push   %ebx
 373:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 376:	8d 45 10             	lea    0x10(%ebp),%eax
 379:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 37c:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 381:	bb 00 00 00 00       	mov    $0x0,%ebx
 386:	eb 14                	jmp    39c <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 388:	89 fa                	mov    %edi,%edx
 38a:	8b 45 08             	mov    0x8(%ebp),%eax
 38d:	e8 41 ff ff ff       	call   2d3 <putc>
 392:	eb 05                	jmp    399 <printf+0x2c>
      }
    } else if(state == '%'){
 394:	83 fe 25             	cmp    $0x25,%esi
 397:	74 25                	je     3be <printf+0x51>
  for(i = 0; fmt[i]; i++){
 399:	83 c3 01             	add    $0x1,%ebx
 39c:	8b 45 0c             	mov    0xc(%ebp),%eax
 39f:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3a3:	84 c0                	test   %al,%al
 3a5:	0f 84 23 01 00 00    	je     4ce <printf+0x161>
    c = fmt[i] & 0xff;
 3ab:	0f be f8             	movsbl %al,%edi
 3ae:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3b1:	85 f6                	test   %esi,%esi
 3b3:	75 df                	jne    394 <printf+0x27>
      if(c == '%'){
 3b5:	83 f8 25             	cmp    $0x25,%eax
 3b8:	75 ce                	jne    388 <printf+0x1b>
        state = '%';
 3ba:	89 c6                	mov    %eax,%esi
 3bc:	eb db                	jmp    399 <printf+0x2c>
      if(c == 'd'){
 3be:	83 f8 64             	cmp    $0x64,%eax
 3c1:	74 49                	je     40c <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3c3:	83 f8 78             	cmp    $0x78,%eax
 3c6:	0f 94 c1             	sete   %cl
 3c9:	83 f8 70             	cmp    $0x70,%eax
 3cc:	0f 94 c2             	sete   %dl
 3cf:	08 d1                	or     %dl,%cl
 3d1:	75 63                	jne    436 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3d3:	83 f8 73             	cmp    $0x73,%eax
 3d6:	0f 84 84 00 00 00    	je     460 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3dc:	83 f8 63             	cmp    $0x63,%eax
 3df:	0f 84 b7 00 00 00    	je     49c <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3e5:	83 f8 25             	cmp    $0x25,%eax
 3e8:	0f 84 cc 00 00 00    	je     4ba <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3ee:	ba 25 00 00 00       	mov    $0x25,%edx
 3f3:	8b 45 08             	mov    0x8(%ebp),%eax
 3f6:	e8 d8 fe ff ff       	call   2d3 <putc>
        putc(fd, c);
 3fb:	89 fa                	mov    %edi,%edx
 3fd:	8b 45 08             	mov    0x8(%ebp),%eax
 400:	e8 ce fe ff ff       	call   2d3 <putc>
      }
      state = 0;
 405:	be 00 00 00 00       	mov    $0x0,%esi
 40a:	eb 8d                	jmp    399 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 40c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 40f:	8b 17                	mov    (%edi),%edx
 411:	83 ec 0c             	sub    $0xc,%esp
 414:	6a 01                	push   $0x1
 416:	b9 0a 00 00 00       	mov    $0xa,%ecx
 41b:	8b 45 08             	mov    0x8(%ebp),%eax
 41e:	e8 ca fe ff ff       	call   2ed <printint>
        ap++;
 423:	83 c7 04             	add    $0x4,%edi
 426:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 429:	83 c4 10             	add    $0x10,%esp
      state = 0;
 42c:	be 00 00 00 00       	mov    $0x0,%esi
 431:	e9 63 ff ff ff       	jmp    399 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 436:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 439:	8b 17                	mov    (%edi),%edx
 43b:	83 ec 0c             	sub    $0xc,%esp
 43e:	6a 00                	push   $0x0
 440:	b9 10 00 00 00       	mov    $0x10,%ecx
 445:	8b 45 08             	mov    0x8(%ebp),%eax
 448:	e8 a0 fe ff ff       	call   2ed <printint>
        ap++;
 44d:	83 c7 04             	add    $0x4,%edi
 450:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 453:	83 c4 10             	add    $0x10,%esp
      state = 0;
 456:	be 00 00 00 00       	mov    $0x0,%esi
 45b:	e9 39 ff ff ff       	jmp    399 <printf+0x2c>
        s = (char*)*ap;
 460:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 463:	8b 30                	mov    (%eax),%esi
        ap++;
 465:	83 c0 04             	add    $0x4,%eax
 468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 46b:	85 f6                	test   %esi,%esi
 46d:	75 28                	jne    497 <printf+0x12a>
          s = "(null)";
 46f:	be cc 06 00 00       	mov    $0x6cc,%esi
 474:	8b 7d 08             	mov    0x8(%ebp),%edi
 477:	eb 0d                	jmp    486 <printf+0x119>
          putc(fd, *s);
 479:	0f be d2             	movsbl %dl,%edx
 47c:	89 f8                	mov    %edi,%eax
 47e:	e8 50 fe ff ff       	call   2d3 <putc>
          s++;
 483:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 486:	0f b6 16             	movzbl (%esi),%edx
 489:	84 d2                	test   %dl,%dl
 48b:	75 ec                	jne    479 <printf+0x10c>
      state = 0;
 48d:	be 00 00 00 00       	mov    $0x0,%esi
 492:	e9 02 ff ff ff       	jmp    399 <printf+0x2c>
 497:	8b 7d 08             	mov    0x8(%ebp),%edi
 49a:	eb ea                	jmp    486 <printf+0x119>
        putc(fd, *ap);
 49c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 49f:	0f be 17             	movsbl (%edi),%edx
 4a2:	8b 45 08             	mov    0x8(%ebp),%eax
 4a5:	e8 29 fe ff ff       	call   2d3 <putc>
        ap++;
 4aa:	83 c7 04             	add    $0x4,%edi
 4ad:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4b0:	be 00 00 00 00       	mov    $0x0,%esi
 4b5:	e9 df fe ff ff       	jmp    399 <printf+0x2c>
        putc(fd, c);
 4ba:	89 fa                	mov    %edi,%edx
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	e8 0f fe ff ff       	call   2d3 <putc>
      state = 0;
 4c4:	be 00 00 00 00       	mov    $0x0,%esi
 4c9:	e9 cb fe ff ff       	jmp    399 <printf+0x2c>
    }
  }
}
 4ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4d1:	5b                   	pop    %ebx
 4d2:	5e                   	pop    %esi
 4d3:	5f                   	pop    %edi
 4d4:	5d                   	pop    %ebp
 4d5:	c3                   	ret    

000004d6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4d6:	55                   	push   %ebp
 4d7:	89 e5                	mov    %esp,%ebp
 4d9:	57                   	push   %edi
 4da:	56                   	push   %esi
 4db:	53                   	push   %ebx
 4dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4df:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4e2:	a1 6c 09 00 00       	mov    0x96c,%eax
 4e7:	eb 02                	jmp    4eb <free+0x15>
 4e9:	89 d0                	mov    %edx,%eax
 4eb:	39 c8                	cmp    %ecx,%eax
 4ed:	73 04                	jae    4f3 <free+0x1d>
 4ef:	39 08                	cmp    %ecx,(%eax)
 4f1:	77 12                	ja     505 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4f3:	8b 10                	mov    (%eax),%edx
 4f5:	39 c2                	cmp    %eax,%edx
 4f7:	77 f0                	ja     4e9 <free+0x13>
 4f9:	39 c8                	cmp    %ecx,%eax
 4fb:	72 08                	jb     505 <free+0x2f>
 4fd:	39 ca                	cmp    %ecx,%edx
 4ff:	77 04                	ja     505 <free+0x2f>
 501:	89 d0                	mov    %edx,%eax
 503:	eb e6                	jmp    4eb <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 505:	8b 73 fc             	mov    -0x4(%ebx),%esi
 508:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 50b:	8b 10                	mov    (%eax),%edx
 50d:	39 d7                	cmp    %edx,%edi
 50f:	74 19                	je     52a <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 511:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 514:	8b 50 04             	mov    0x4(%eax),%edx
 517:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 51a:	39 ce                	cmp    %ecx,%esi
 51c:	74 1b                	je     539 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 51e:	89 08                	mov    %ecx,(%eax)
  freep = p;
 520:	a3 6c 09 00 00       	mov    %eax,0x96c
}
 525:	5b                   	pop    %ebx
 526:	5e                   	pop    %esi
 527:	5f                   	pop    %edi
 528:	5d                   	pop    %ebp
 529:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 52a:	03 72 04             	add    0x4(%edx),%esi
 52d:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 530:	8b 10                	mov    (%eax),%edx
 532:	8b 12                	mov    (%edx),%edx
 534:	89 53 f8             	mov    %edx,-0x8(%ebx)
 537:	eb db                	jmp    514 <free+0x3e>
    p->s.size += bp->s.size;
 539:	03 53 fc             	add    -0x4(%ebx),%edx
 53c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 53f:	8b 53 f8             	mov    -0x8(%ebx),%edx
 542:	89 10                	mov    %edx,(%eax)
 544:	eb da                	jmp    520 <free+0x4a>

00000546 <morecore>:

static Header*
morecore(uint nu)
{
 546:	55                   	push   %ebp
 547:	89 e5                	mov    %esp,%ebp
 549:	53                   	push   %ebx
 54a:	83 ec 04             	sub    $0x4,%esp
 54d:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 54f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 554:	77 05                	ja     55b <morecore+0x15>
    nu = 4096;
 556:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 55b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 562:	83 ec 0c             	sub    $0xc,%esp
 565:	50                   	push   %eax
 566:	e8 30 fd ff ff       	call   29b <sbrk>
  if(p == (char*)-1)
 56b:	83 c4 10             	add    $0x10,%esp
 56e:	83 f8 ff             	cmp    $0xffffffff,%eax
 571:	74 1c                	je     58f <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 573:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 576:	83 c0 08             	add    $0x8,%eax
 579:	83 ec 0c             	sub    $0xc,%esp
 57c:	50                   	push   %eax
 57d:	e8 54 ff ff ff       	call   4d6 <free>
  return freep;
 582:	a1 6c 09 00 00       	mov    0x96c,%eax
 587:	83 c4 10             	add    $0x10,%esp
}
 58a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 58d:	c9                   	leave  
 58e:	c3                   	ret    
    return 0;
 58f:	b8 00 00 00 00       	mov    $0x0,%eax
 594:	eb f4                	jmp    58a <morecore+0x44>

00000596 <malloc>:

void*
malloc(uint nbytes)
{
 596:	55                   	push   %ebp
 597:	89 e5                	mov    %esp,%ebp
 599:	53                   	push   %ebx
 59a:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	8d 58 07             	lea    0x7(%eax),%ebx
 5a3:	c1 eb 03             	shr    $0x3,%ebx
 5a6:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5a9:	8b 0d 6c 09 00 00    	mov    0x96c,%ecx
 5af:	85 c9                	test   %ecx,%ecx
 5b1:	74 04                	je     5b7 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5b3:	8b 01                	mov    (%ecx),%eax
 5b5:	eb 4d                	jmp    604 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5b7:	c7 05 6c 09 00 00 70 	movl   $0x970,0x96c
 5be:	09 00 00 
 5c1:	c7 05 70 09 00 00 70 	movl   $0x970,0x970
 5c8:	09 00 00 
    base.s.size = 0;
 5cb:	c7 05 74 09 00 00 00 	movl   $0x0,0x974
 5d2:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5d5:	b9 70 09 00 00       	mov    $0x970,%ecx
 5da:	eb d7                	jmp    5b3 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5dc:	39 da                	cmp    %ebx,%edx
 5de:	74 1a                	je     5fa <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5e0:	29 da                	sub    %ebx,%edx
 5e2:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5e5:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5e8:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5eb:	89 0d 6c 09 00 00    	mov    %ecx,0x96c
      return (void*)(p + 1);
 5f1:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5f4:	83 c4 04             	add    $0x4,%esp
 5f7:	5b                   	pop    %ebx
 5f8:	5d                   	pop    %ebp
 5f9:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5fa:	8b 10                	mov    (%eax),%edx
 5fc:	89 11                	mov    %edx,(%ecx)
 5fe:	eb eb                	jmp    5eb <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 600:	89 c1                	mov    %eax,%ecx
 602:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 604:	8b 50 04             	mov    0x4(%eax),%edx
 607:	39 da                	cmp    %ebx,%edx
 609:	73 d1                	jae    5dc <malloc+0x46>
    if(p == freep)
 60b:	39 05 6c 09 00 00    	cmp    %eax,0x96c
 611:	75 ed                	jne    600 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 613:	89 d8                	mov    %ebx,%eax
 615:	e8 2c ff ff ff       	call   546 <morecore>
 61a:	85 c0                	test   %eax,%eax
 61c:	75 e2                	jne    600 <malloc+0x6a>
        return 0;
 61e:	b8 00 00 00 00       	mov    $0x0,%eax
 623:	eb cf                	jmp    5f4 <malloc+0x5e>
