
_userRR:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "pstat.h"
#include "syscall.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
// checking valid input
  if(argc != 5){
  11:	83 39 05             	cmpl   $0x5,(%ecx)
  14:	74 14                	je     2a <main+0x2a>
    printf(1, "Illegal number of arguments\n");
  16:	83 ec 08             	sub    $0x8,%esp
  19:	68 d0 05 00 00       	push   $0x5d0
  1e:	6a 01                	push   $0x1
  20:	e8 f1 02 00 00       	call   316 <printf>
    exit();
  25:	e8 92 01 00 00       	call   1bc <exit>

  // for(int i = 0; i < iterations; i++) {
  //    kill(cur_pid[i]);
  // }

  exit(); 	
  2a:	e8 8d 01 00 00       	call   1bc <exit>

0000002f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  2f:	55                   	push   %ebp
  30:	89 e5                	mov    %esp,%ebp
  32:	53                   	push   %ebx
  33:	8b 45 08             	mov    0x8(%ebp),%eax
  36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  39:	89 c2                	mov    %eax,%edx
  3b:	0f b6 19             	movzbl (%ecx),%ebx
  3e:	88 1a                	mov    %bl,(%edx)
  40:	8d 52 01             	lea    0x1(%edx),%edx
  43:	8d 49 01             	lea    0x1(%ecx),%ecx
  46:	84 db                	test   %bl,%bl
  48:	75 f1                	jne    3b <strcpy+0xc>
    ;
  return os;
}
  4a:	5b                   	pop    %ebx
  4b:	5d                   	pop    %ebp
  4c:	c3                   	ret    

0000004d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4d:	55                   	push   %ebp
  4e:	89 e5                	mov    %esp,%ebp
  50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  53:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  56:	eb 06                	jmp    5e <strcmp+0x11>
    p++, q++;
  58:	83 c1 01             	add    $0x1,%ecx
  5b:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  5e:	0f b6 01             	movzbl (%ecx),%eax
  61:	84 c0                	test   %al,%al
  63:	74 04                	je     69 <strcmp+0x1c>
  65:	3a 02                	cmp    (%edx),%al
  67:	74 ef                	je     58 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  69:	0f b6 c0             	movzbl %al,%eax
  6c:	0f b6 12             	movzbl (%edx),%edx
  6f:	29 d0                	sub    %edx,%eax
}
  71:	5d                   	pop    %ebp
  72:	c3                   	ret    

00000073 <strlen>:

uint
strlen(const char *s)
{
  73:	55                   	push   %ebp
  74:	89 e5                	mov    %esp,%ebp
  76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  79:	ba 00 00 00 00       	mov    $0x0,%edx
  7e:	eb 03                	jmp    83 <strlen+0x10>
  80:	83 c2 01             	add    $0x1,%edx
  83:	89 d0                	mov    %edx,%eax
  85:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  89:	75 f5                	jne    80 <strlen+0xd>
    ;
  return n;
}
  8b:	5d                   	pop    %ebp
  8c:	c3                   	ret    

0000008d <memset>:

void*
memset(void *dst, int c, uint n)
{
  8d:	55                   	push   %ebp
  8e:	89 e5                	mov    %esp,%ebp
  90:	57                   	push   %edi
  91:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  94:	89 d7                	mov    %edx,%edi
  96:	8b 4d 10             	mov    0x10(%ebp),%ecx
  99:	8b 45 0c             	mov    0xc(%ebp),%eax
  9c:	fc                   	cld    
  9d:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  9f:	89 d0                	mov    %edx,%eax
  a1:	5f                   	pop    %edi
  a2:	5d                   	pop    %ebp
  a3:	c3                   	ret    

000000a4 <strchr>:

char*
strchr(const char *s, char c)
{
  a4:	55                   	push   %ebp
  a5:	89 e5                	mov    %esp,%ebp
  a7:	8b 45 08             	mov    0x8(%ebp),%eax
  aa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  ae:	0f b6 10             	movzbl (%eax),%edx
  b1:	84 d2                	test   %dl,%dl
  b3:	74 09                	je     be <strchr+0x1a>
    if(*s == c)
  b5:	38 ca                	cmp    %cl,%dl
  b7:	74 0a                	je     c3 <strchr+0x1f>
  for(; *s; s++)
  b9:	83 c0 01             	add    $0x1,%eax
  bc:	eb f0                	jmp    ae <strchr+0xa>
      return (char*)s;
  return 0;
  be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c3:	5d                   	pop    %ebp
  c4:	c3                   	ret    

000000c5 <gets>:

char*
gets(char *buf, int max)
{
  c5:	55                   	push   %ebp
  c6:	89 e5                	mov    %esp,%ebp
  c8:	57                   	push   %edi
  c9:	56                   	push   %esi
  ca:	53                   	push   %ebx
  cb:	83 ec 1c             	sub    $0x1c,%esp
  ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  d6:	8d 73 01             	lea    0x1(%ebx),%esi
  d9:	3b 75 0c             	cmp    0xc(%ebp),%esi
  dc:	7d 2e                	jge    10c <gets+0x47>
    cc = read(0, &c, 1);
  de:	83 ec 04             	sub    $0x4,%esp
  e1:	6a 01                	push   $0x1
  e3:	8d 45 e7             	lea    -0x19(%ebp),%eax
  e6:	50                   	push   %eax
  e7:	6a 00                	push   $0x0
  e9:	e8 e6 00 00 00       	call   1d4 <read>
    if(cc < 1)
  ee:	83 c4 10             	add    $0x10,%esp
  f1:	85 c0                	test   %eax,%eax
  f3:	7e 17                	jle    10c <gets+0x47>
      break;
    buf[i++] = c;
  f5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  f9:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
  fc:	3c 0a                	cmp    $0xa,%al
  fe:	0f 94 c2             	sete   %dl
 101:	3c 0d                	cmp    $0xd,%al
 103:	0f 94 c0             	sete   %al
    buf[i++] = c;
 106:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 108:	08 c2                	or     %al,%dl
 10a:	74 ca                	je     d6 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 10c:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 110:	89 f8                	mov    %edi,%eax
 112:	8d 65 f4             	lea    -0xc(%ebp),%esp
 115:	5b                   	pop    %ebx
 116:	5e                   	pop    %esi
 117:	5f                   	pop    %edi
 118:	5d                   	pop    %ebp
 119:	c3                   	ret    

0000011a <stat>:

int
stat(const char *n, struct stat *st)
{
 11a:	55                   	push   %ebp
 11b:	89 e5                	mov    %esp,%ebp
 11d:	56                   	push   %esi
 11e:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 11f:	83 ec 08             	sub    $0x8,%esp
 122:	6a 00                	push   $0x0
 124:	ff 75 08             	pushl  0x8(%ebp)
 127:	e8 d0 00 00 00       	call   1fc <open>
  if(fd < 0)
 12c:	83 c4 10             	add    $0x10,%esp
 12f:	85 c0                	test   %eax,%eax
 131:	78 24                	js     157 <stat+0x3d>
 133:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 135:	83 ec 08             	sub    $0x8,%esp
 138:	ff 75 0c             	pushl  0xc(%ebp)
 13b:	50                   	push   %eax
 13c:	e8 d3 00 00 00       	call   214 <fstat>
 141:	89 c6                	mov    %eax,%esi
  close(fd);
 143:	89 1c 24             	mov    %ebx,(%esp)
 146:	e8 99 00 00 00       	call   1e4 <close>
  return r;
 14b:	83 c4 10             	add    $0x10,%esp
}
 14e:	89 f0                	mov    %esi,%eax
 150:	8d 65 f8             	lea    -0x8(%ebp),%esp
 153:	5b                   	pop    %ebx
 154:	5e                   	pop    %esi
 155:	5d                   	pop    %ebp
 156:	c3                   	ret    
    return -1;
 157:	be ff ff ff ff       	mov    $0xffffffff,%esi
 15c:	eb f0                	jmp    14e <stat+0x34>

0000015e <atoi>:

int
atoi(const char *s)
{
 15e:	55                   	push   %ebp
 15f:	89 e5                	mov    %esp,%ebp
 161:	53                   	push   %ebx
 162:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 165:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 16a:	eb 10                	jmp    17c <atoi+0x1e>
    n = n*10 + *s++ - '0';
 16c:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 16f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 172:	83 c1 01             	add    $0x1,%ecx
 175:	0f be d2             	movsbl %dl,%edx
 178:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 17c:	0f b6 11             	movzbl (%ecx),%edx
 17f:	8d 5a d0             	lea    -0x30(%edx),%ebx
 182:	80 fb 09             	cmp    $0x9,%bl
 185:	76 e5                	jbe    16c <atoi+0xe>
  return n;
}
 187:	5b                   	pop    %ebx
 188:	5d                   	pop    %ebp
 189:	c3                   	ret    

0000018a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 18a:	55                   	push   %ebp
 18b:	89 e5                	mov    %esp,%ebp
 18d:	56                   	push   %esi
 18e:	53                   	push   %ebx
 18f:	8b 45 08             	mov    0x8(%ebp),%eax
 192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 195:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 198:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 19a:	eb 0d                	jmp    1a9 <memmove+0x1f>
    *dst++ = *src++;
 19c:	0f b6 13             	movzbl (%ebx),%edx
 19f:	88 11                	mov    %dl,(%ecx)
 1a1:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1a4:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1a7:	89 f2                	mov    %esi,%edx
 1a9:	8d 72 ff             	lea    -0x1(%edx),%esi
 1ac:	85 d2                	test   %edx,%edx
 1ae:	7f ec                	jg     19c <memmove+0x12>
  return vdst;
}
 1b0:	5b                   	pop    %ebx
 1b1:	5e                   	pop    %esi
 1b2:	5d                   	pop    %ebp
 1b3:	c3                   	ret    

000001b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1b4:	b8 01 00 00 00       	mov    $0x1,%eax
 1b9:	cd 40                	int    $0x40
 1bb:	c3                   	ret    

000001bc <exit>:
SYSCALL(exit)
 1bc:	b8 02 00 00 00       	mov    $0x2,%eax
 1c1:	cd 40                	int    $0x40
 1c3:	c3                   	ret    

000001c4 <wait>:
SYSCALL(wait)
 1c4:	b8 03 00 00 00       	mov    $0x3,%eax
 1c9:	cd 40                	int    $0x40
 1cb:	c3                   	ret    

000001cc <pipe>:
SYSCALL(pipe)
 1cc:	b8 04 00 00 00       	mov    $0x4,%eax
 1d1:	cd 40                	int    $0x40
 1d3:	c3                   	ret    

000001d4 <read>:
SYSCALL(read)
 1d4:	b8 05 00 00 00       	mov    $0x5,%eax
 1d9:	cd 40                	int    $0x40
 1db:	c3                   	ret    

000001dc <write>:
SYSCALL(write)
 1dc:	b8 10 00 00 00       	mov    $0x10,%eax
 1e1:	cd 40                	int    $0x40
 1e3:	c3                   	ret    

000001e4 <close>:
SYSCALL(close)
 1e4:	b8 15 00 00 00       	mov    $0x15,%eax
 1e9:	cd 40                	int    $0x40
 1eb:	c3                   	ret    

000001ec <kill>:
SYSCALL(kill)
 1ec:	b8 06 00 00 00       	mov    $0x6,%eax
 1f1:	cd 40                	int    $0x40
 1f3:	c3                   	ret    

000001f4 <exec>:
SYSCALL(exec)
 1f4:	b8 07 00 00 00       	mov    $0x7,%eax
 1f9:	cd 40                	int    $0x40
 1fb:	c3                   	ret    

000001fc <open>:
SYSCALL(open)
 1fc:	b8 0f 00 00 00       	mov    $0xf,%eax
 201:	cd 40                	int    $0x40
 203:	c3                   	ret    

00000204 <mknod>:
SYSCALL(mknod)
 204:	b8 11 00 00 00       	mov    $0x11,%eax
 209:	cd 40                	int    $0x40
 20b:	c3                   	ret    

0000020c <unlink>:
SYSCALL(unlink)
 20c:	b8 12 00 00 00       	mov    $0x12,%eax
 211:	cd 40                	int    $0x40
 213:	c3                   	ret    

00000214 <fstat>:
SYSCALL(fstat)
 214:	b8 08 00 00 00       	mov    $0x8,%eax
 219:	cd 40                	int    $0x40
 21b:	c3                   	ret    

0000021c <link>:
SYSCALL(link)
 21c:	b8 13 00 00 00       	mov    $0x13,%eax
 221:	cd 40                	int    $0x40
 223:	c3                   	ret    

00000224 <mkdir>:
SYSCALL(mkdir)
 224:	b8 14 00 00 00       	mov    $0x14,%eax
 229:	cd 40                	int    $0x40
 22b:	c3                   	ret    

0000022c <chdir>:
SYSCALL(chdir)
 22c:	b8 09 00 00 00       	mov    $0x9,%eax
 231:	cd 40                	int    $0x40
 233:	c3                   	ret    

00000234 <dup>:
SYSCALL(dup)
 234:	b8 0a 00 00 00       	mov    $0xa,%eax
 239:	cd 40                	int    $0x40
 23b:	c3                   	ret    

0000023c <getpid>:
SYSCALL(getpid)
 23c:	b8 0b 00 00 00       	mov    $0xb,%eax
 241:	cd 40                	int    $0x40
 243:	c3                   	ret    

00000244 <sbrk>:
SYSCALL(sbrk)
 244:	b8 0c 00 00 00       	mov    $0xc,%eax
 249:	cd 40                	int    $0x40
 24b:	c3                   	ret    

0000024c <sleep>:
SYSCALL(sleep)
 24c:	b8 0d 00 00 00       	mov    $0xd,%eax
 251:	cd 40                	int    $0x40
 253:	c3                   	ret    

00000254 <uptime>:
SYSCALL(uptime)
 254:	b8 0e 00 00 00       	mov    $0xe,%eax
 259:	cd 40                	int    $0x40
 25b:	c3                   	ret    

0000025c <setpri>:
SYSCALL(setpri)
 25c:	b8 16 00 00 00       	mov    $0x16,%eax
 261:	cd 40                	int    $0x40
 263:	c3                   	ret    

00000264 <getpri>:
SYSCALL(getpri)
 264:	b8 17 00 00 00       	mov    $0x17,%eax
 269:	cd 40                	int    $0x40
 26b:	c3                   	ret    

0000026c <fork2>:
SYSCALL(fork2)
 26c:	b8 18 00 00 00       	mov    $0x18,%eax
 271:	cd 40                	int    $0x40
 273:	c3                   	ret    

00000274 <getpinfo>:
SYSCALL(getpinfo)
 274:	b8 19 00 00 00       	mov    $0x19,%eax
 279:	cd 40                	int    $0x40
 27b:	c3                   	ret    

0000027c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 27c:	55                   	push   %ebp
 27d:	89 e5                	mov    %esp,%ebp
 27f:	83 ec 1c             	sub    $0x1c,%esp
 282:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 285:	6a 01                	push   $0x1
 287:	8d 55 f4             	lea    -0xc(%ebp),%edx
 28a:	52                   	push   %edx
 28b:	50                   	push   %eax
 28c:	e8 4b ff ff ff       	call   1dc <write>
}
 291:	83 c4 10             	add    $0x10,%esp
 294:	c9                   	leave  
 295:	c3                   	ret    

00000296 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 296:	55                   	push   %ebp
 297:	89 e5                	mov    %esp,%ebp
 299:	57                   	push   %edi
 29a:	56                   	push   %esi
 29b:	53                   	push   %ebx
 29c:	83 ec 2c             	sub    $0x2c,%esp
 29f:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2a5:	0f 95 c3             	setne  %bl
 2a8:	89 d0                	mov    %edx,%eax
 2aa:	c1 e8 1f             	shr    $0x1f,%eax
 2ad:	84 c3                	test   %al,%bl
 2af:	74 10                	je     2c1 <printint+0x2b>
    neg = 1;
    x = -xx;
 2b1:	f7 da                	neg    %edx
    neg = 1;
 2b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2ba:	be 00 00 00 00       	mov    $0x0,%esi
 2bf:	eb 0b                	jmp    2cc <printint+0x36>
  neg = 0;
 2c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2c8:	eb f0                	jmp    2ba <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2ca:	89 c6                	mov    %eax,%esi
 2cc:	89 d0                	mov    %edx,%eax
 2ce:	ba 00 00 00 00       	mov    $0x0,%edx
 2d3:	f7 f1                	div    %ecx
 2d5:	89 c3                	mov    %eax,%ebx
 2d7:	8d 46 01             	lea    0x1(%esi),%eax
 2da:	0f b6 92 f4 05 00 00 	movzbl 0x5f4(%edx),%edx
 2e1:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2e5:	89 da                	mov    %ebx,%edx
 2e7:	85 db                	test   %ebx,%ebx
 2e9:	75 df                	jne    2ca <printint+0x34>
 2eb:	89 c3                	mov    %eax,%ebx
  if(neg)
 2ed:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2f1:	74 16                	je     309 <printint+0x73>
    buf[i++] = '-';
 2f3:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2f8:	8d 5e 02             	lea    0x2(%esi),%ebx
 2fb:	eb 0c                	jmp    309 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2fd:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 302:	89 f8                	mov    %edi,%eax
 304:	e8 73 ff ff ff       	call   27c <putc>
  while(--i >= 0)
 309:	83 eb 01             	sub    $0x1,%ebx
 30c:	79 ef                	jns    2fd <printint+0x67>
}
 30e:	83 c4 2c             	add    $0x2c,%esp
 311:	5b                   	pop    %ebx
 312:	5e                   	pop    %esi
 313:	5f                   	pop    %edi
 314:	5d                   	pop    %ebp
 315:	c3                   	ret    

00000316 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 316:	55                   	push   %ebp
 317:	89 e5                	mov    %esp,%ebp
 319:	57                   	push   %edi
 31a:	56                   	push   %esi
 31b:	53                   	push   %ebx
 31c:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 31f:	8d 45 10             	lea    0x10(%ebp),%eax
 322:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 325:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 32a:	bb 00 00 00 00       	mov    $0x0,%ebx
 32f:	eb 14                	jmp    345 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 331:	89 fa                	mov    %edi,%edx
 333:	8b 45 08             	mov    0x8(%ebp),%eax
 336:	e8 41 ff ff ff       	call   27c <putc>
 33b:	eb 05                	jmp    342 <printf+0x2c>
      }
    } else if(state == '%'){
 33d:	83 fe 25             	cmp    $0x25,%esi
 340:	74 25                	je     367 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 342:	83 c3 01             	add    $0x1,%ebx
 345:	8b 45 0c             	mov    0xc(%ebp),%eax
 348:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 34c:	84 c0                	test   %al,%al
 34e:	0f 84 23 01 00 00    	je     477 <printf+0x161>
    c = fmt[i] & 0xff;
 354:	0f be f8             	movsbl %al,%edi
 357:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 35a:	85 f6                	test   %esi,%esi
 35c:	75 df                	jne    33d <printf+0x27>
      if(c == '%'){
 35e:	83 f8 25             	cmp    $0x25,%eax
 361:	75 ce                	jne    331 <printf+0x1b>
        state = '%';
 363:	89 c6                	mov    %eax,%esi
 365:	eb db                	jmp    342 <printf+0x2c>
      if(c == 'd'){
 367:	83 f8 64             	cmp    $0x64,%eax
 36a:	74 49                	je     3b5 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 36c:	83 f8 78             	cmp    $0x78,%eax
 36f:	0f 94 c1             	sete   %cl
 372:	83 f8 70             	cmp    $0x70,%eax
 375:	0f 94 c2             	sete   %dl
 378:	08 d1                	or     %dl,%cl
 37a:	75 63                	jne    3df <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 37c:	83 f8 73             	cmp    $0x73,%eax
 37f:	0f 84 84 00 00 00    	je     409 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 385:	83 f8 63             	cmp    $0x63,%eax
 388:	0f 84 b7 00 00 00    	je     445 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 38e:	83 f8 25             	cmp    $0x25,%eax
 391:	0f 84 cc 00 00 00    	je     463 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 397:	ba 25 00 00 00       	mov    $0x25,%edx
 39c:	8b 45 08             	mov    0x8(%ebp),%eax
 39f:	e8 d8 fe ff ff       	call   27c <putc>
        putc(fd, c);
 3a4:	89 fa                	mov    %edi,%edx
 3a6:	8b 45 08             	mov    0x8(%ebp),%eax
 3a9:	e8 ce fe ff ff       	call   27c <putc>
      }
      state = 0;
 3ae:	be 00 00 00 00       	mov    $0x0,%esi
 3b3:	eb 8d                	jmp    342 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3b8:	8b 17                	mov    (%edi),%edx
 3ba:	83 ec 0c             	sub    $0xc,%esp
 3bd:	6a 01                	push   $0x1
 3bf:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	e8 ca fe ff ff       	call   296 <printint>
        ap++;
 3cc:	83 c7 04             	add    $0x4,%edi
 3cf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d2:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3d5:	be 00 00 00 00       	mov    $0x0,%esi
 3da:	e9 63 ff ff ff       	jmp    342 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e2:	8b 17                	mov    (%edi),%edx
 3e4:	83 ec 0c             	sub    $0xc,%esp
 3e7:	6a 00                	push   $0x0
 3e9:	b9 10 00 00 00       	mov    $0x10,%ecx
 3ee:	8b 45 08             	mov    0x8(%ebp),%eax
 3f1:	e8 a0 fe ff ff       	call   296 <printint>
        ap++;
 3f6:	83 c7 04             	add    $0x4,%edi
 3f9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3fc:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3ff:	be 00 00 00 00       	mov    $0x0,%esi
 404:	e9 39 ff ff ff       	jmp    342 <printf+0x2c>
        s = (char*)*ap;
 409:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 40c:	8b 30                	mov    (%eax),%esi
        ap++;
 40e:	83 c0 04             	add    $0x4,%eax
 411:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 414:	85 f6                	test   %esi,%esi
 416:	75 28                	jne    440 <printf+0x12a>
          s = "(null)";
 418:	be ed 05 00 00       	mov    $0x5ed,%esi
 41d:	8b 7d 08             	mov    0x8(%ebp),%edi
 420:	eb 0d                	jmp    42f <printf+0x119>
          putc(fd, *s);
 422:	0f be d2             	movsbl %dl,%edx
 425:	89 f8                	mov    %edi,%eax
 427:	e8 50 fe ff ff       	call   27c <putc>
          s++;
 42c:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 42f:	0f b6 16             	movzbl (%esi),%edx
 432:	84 d2                	test   %dl,%dl
 434:	75 ec                	jne    422 <printf+0x10c>
      state = 0;
 436:	be 00 00 00 00       	mov    $0x0,%esi
 43b:	e9 02 ff ff ff       	jmp    342 <printf+0x2c>
 440:	8b 7d 08             	mov    0x8(%ebp),%edi
 443:	eb ea                	jmp    42f <printf+0x119>
        putc(fd, *ap);
 445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 448:	0f be 17             	movsbl (%edi),%edx
 44b:	8b 45 08             	mov    0x8(%ebp),%eax
 44e:	e8 29 fe ff ff       	call   27c <putc>
        ap++;
 453:	83 c7 04             	add    $0x4,%edi
 456:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 459:	be 00 00 00 00       	mov    $0x0,%esi
 45e:	e9 df fe ff ff       	jmp    342 <printf+0x2c>
        putc(fd, c);
 463:	89 fa                	mov    %edi,%edx
 465:	8b 45 08             	mov    0x8(%ebp),%eax
 468:	e8 0f fe ff ff       	call   27c <putc>
      state = 0;
 46d:	be 00 00 00 00       	mov    $0x0,%esi
 472:	e9 cb fe ff ff       	jmp    342 <printf+0x2c>
    }
  }
}
 477:	8d 65 f4             	lea    -0xc(%ebp),%esp
 47a:	5b                   	pop    %ebx
 47b:	5e                   	pop    %esi
 47c:	5f                   	pop    %edi
 47d:	5d                   	pop    %ebp
 47e:	c3                   	ret    

0000047f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 47f:	55                   	push   %ebp
 480:	89 e5                	mov    %esp,%ebp
 482:	57                   	push   %edi
 483:	56                   	push   %esi
 484:	53                   	push   %ebx
 485:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 488:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 48b:	a1 8c 08 00 00       	mov    0x88c,%eax
 490:	eb 02                	jmp    494 <free+0x15>
 492:	89 d0                	mov    %edx,%eax
 494:	39 c8                	cmp    %ecx,%eax
 496:	73 04                	jae    49c <free+0x1d>
 498:	39 08                	cmp    %ecx,(%eax)
 49a:	77 12                	ja     4ae <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 49c:	8b 10                	mov    (%eax),%edx
 49e:	39 c2                	cmp    %eax,%edx
 4a0:	77 f0                	ja     492 <free+0x13>
 4a2:	39 c8                	cmp    %ecx,%eax
 4a4:	72 08                	jb     4ae <free+0x2f>
 4a6:	39 ca                	cmp    %ecx,%edx
 4a8:	77 04                	ja     4ae <free+0x2f>
 4aa:	89 d0                	mov    %edx,%eax
 4ac:	eb e6                	jmp    494 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ae:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4b1:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4b4:	8b 10                	mov    (%eax),%edx
 4b6:	39 d7                	cmp    %edx,%edi
 4b8:	74 19                	je     4d3 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4ba:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4bd:	8b 50 04             	mov    0x4(%eax),%edx
 4c0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4c3:	39 ce                	cmp    %ecx,%esi
 4c5:	74 1b                	je     4e2 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4c7:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4c9:	a3 8c 08 00 00       	mov    %eax,0x88c
}
 4ce:	5b                   	pop    %ebx
 4cf:	5e                   	pop    %esi
 4d0:	5f                   	pop    %edi
 4d1:	5d                   	pop    %ebp
 4d2:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4d3:	03 72 04             	add    0x4(%edx),%esi
 4d6:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4d9:	8b 10                	mov    (%eax),%edx
 4db:	8b 12                	mov    (%edx),%edx
 4dd:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4e0:	eb db                	jmp    4bd <free+0x3e>
    p->s.size += bp->s.size;
 4e2:	03 53 fc             	add    -0x4(%ebx),%edx
 4e5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4e8:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4eb:	89 10                	mov    %edx,(%eax)
 4ed:	eb da                	jmp    4c9 <free+0x4a>

000004ef <morecore>:

static Header*
morecore(uint nu)
{
 4ef:	55                   	push   %ebp
 4f0:	89 e5                	mov    %esp,%ebp
 4f2:	53                   	push   %ebx
 4f3:	83 ec 04             	sub    $0x4,%esp
 4f6:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4f8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4fd:	77 05                	ja     504 <morecore+0x15>
    nu = 4096;
 4ff:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 504:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 50b:	83 ec 0c             	sub    $0xc,%esp
 50e:	50                   	push   %eax
 50f:	e8 30 fd ff ff       	call   244 <sbrk>
  if(p == (char*)-1)
 514:	83 c4 10             	add    $0x10,%esp
 517:	83 f8 ff             	cmp    $0xffffffff,%eax
 51a:	74 1c                	je     538 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 51c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 51f:	83 c0 08             	add    $0x8,%eax
 522:	83 ec 0c             	sub    $0xc,%esp
 525:	50                   	push   %eax
 526:	e8 54 ff ff ff       	call   47f <free>
  return freep;
 52b:	a1 8c 08 00 00       	mov    0x88c,%eax
 530:	83 c4 10             	add    $0x10,%esp
}
 533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 536:	c9                   	leave  
 537:	c3                   	ret    
    return 0;
 538:	b8 00 00 00 00       	mov    $0x0,%eax
 53d:	eb f4                	jmp    533 <morecore+0x44>

0000053f <malloc>:

void*
malloc(uint nbytes)
{
 53f:	55                   	push   %ebp
 540:	89 e5                	mov    %esp,%ebp
 542:	53                   	push   %ebx
 543:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 546:	8b 45 08             	mov    0x8(%ebp),%eax
 549:	8d 58 07             	lea    0x7(%eax),%ebx
 54c:	c1 eb 03             	shr    $0x3,%ebx
 54f:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 552:	8b 0d 8c 08 00 00    	mov    0x88c,%ecx
 558:	85 c9                	test   %ecx,%ecx
 55a:	74 04                	je     560 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 55c:	8b 01                	mov    (%ecx),%eax
 55e:	eb 4d                	jmp    5ad <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 560:	c7 05 8c 08 00 00 90 	movl   $0x890,0x88c
 567:	08 00 00 
 56a:	c7 05 90 08 00 00 90 	movl   $0x890,0x890
 571:	08 00 00 
    base.s.size = 0;
 574:	c7 05 94 08 00 00 00 	movl   $0x0,0x894
 57b:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 57e:	b9 90 08 00 00       	mov    $0x890,%ecx
 583:	eb d7                	jmp    55c <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 585:	39 da                	cmp    %ebx,%edx
 587:	74 1a                	je     5a3 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 589:	29 da                	sub    %ebx,%edx
 58b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 58e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 591:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 594:	89 0d 8c 08 00 00    	mov    %ecx,0x88c
      return (void*)(p + 1);
 59a:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 59d:	83 c4 04             	add    $0x4,%esp
 5a0:	5b                   	pop    %ebx
 5a1:	5d                   	pop    %ebp
 5a2:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5a3:	8b 10                	mov    (%eax),%edx
 5a5:	89 11                	mov    %edx,(%ecx)
 5a7:	eb eb                	jmp    594 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5a9:	89 c1                	mov    %eax,%ecx
 5ab:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ad:	8b 50 04             	mov    0x4(%eax),%edx
 5b0:	39 da                	cmp    %ebx,%edx
 5b2:	73 d1                	jae    585 <malloc+0x46>
    if(p == freep)
 5b4:	39 05 8c 08 00 00    	cmp    %eax,0x88c
 5ba:	75 ed                	jne    5a9 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5bc:	89 d8                	mov    %ebx,%eax
 5be:	e8 2c ff ff ff       	call   4ef <morecore>
 5c3:	85 c0                	test   %eax,%eax
 5c5:	75 e2                	jne    5a9 <malloc+0x6a>
        return 0;
 5c7:	b8 00 00 00 00       	mov    $0x0,%eax
 5cc:	eb cf                	jmp    59d <malloc+0x5e>
