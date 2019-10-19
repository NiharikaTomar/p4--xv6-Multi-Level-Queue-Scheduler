
_userRR:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "fs.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   return 0; 	
}
   3:	b8 00 00 00 00       	mov    $0x0,%eax
   8:	5d                   	pop    %ebp
   9:	c3                   	ret    

0000000a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	8b 45 08             	mov    0x8(%ebp),%eax
  11:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  14:	89 c2                	mov    %eax,%edx
  16:	0f b6 19             	movzbl (%ecx),%ebx
  19:	88 1a                	mov    %bl,(%edx)
  1b:	8d 52 01             	lea    0x1(%edx),%edx
  1e:	8d 49 01             	lea    0x1(%ecx),%ecx
  21:	84 db                	test   %bl,%bl
  23:	75 f1                	jne    16 <strcpy+0xc>
    ;
  return os;
}
  25:	5b                   	pop    %ebx
  26:	5d                   	pop    %ebp
  27:	c3                   	ret    

00000028 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  28:	55                   	push   %ebp
  29:	89 e5                	mov    %esp,%ebp
  2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  31:	eb 06                	jmp    39 <strcmp+0x11>
    p++, q++;
  33:	83 c1 01             	add    $0x1,%ecx
  36:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  39:	0f b6 01             	movzbl (%ecx),%eax
  3c:	84 c0                	test   %al,%al
  3e:	74 04                	je     44 <strcmp+0x1c>
  40:	3a 02                	cmp    (%edx),%al
  42:	74 ef                	je     33 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  44:	0f b6 c0             	movzbl %al,%eax
  47:	0f b6 12             	movzbl (%edx),%edx
  4a:	29 d0                	sub    %edx,%eax
}
  4c:	5d                   	pop    %ebp
  4d:	c3                   	ret    

0000004e <strlen>:

uint
strlen(const char *s)
{
  4e:	55                   	push   %ebp
  4f:	89 e5                	mov    %esp,%ebp
  51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  54:	ba 00 00 00 00       	mov    $0x0,%edx
  59:	eb 03                	jmp    5e <strlen+0x10>
  5b:	83 c2 01             	add    $0x1,%edx
  5e:	89 d0                	mov    %edx,%eax
  60:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  64:	75 f5                	jne    5b <strlen+0xd>
    ;
  return n;
}
  66:	5d                   	pop    %ebp
  67:	c3                   	ret    

00000068 <memset>:

void*
memset(void *dst, int c, uint n)
{
  68:	55                   	push   %ebp
  69:	89 e5                	mov    %esp,%ebp
  6b:	57                   	push   %edi
  6c:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  6f:	89 d7                	mov    %edx,%edi
  71:	8b 4d 10             	mov    0x10(%ebp),%ecx
  74:	8b 45 0c             	mov    0xc(%ebp),%eax
  77:	fc                   	cld    
  78:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  7a:	89 d0                	mov    %edx,%eax
  7c:	5f                   	pop    %edi
  7d:	5d                   	pop    %ebp
  7e:	c3                   	ret    

0000007f <strchr>:

char*
strchr(const char *s, char c)
{
  7f:	55                   	push   %ebp
  80:	89 e5                	mov    %esp,%ebp
  82:	8b 45 08             	mov    0x8(%ebp),%eax
  85:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  89:	0f b6 10             	movzbl (%eax),%edx
  8c:	84 d2                	test   %dl,%dl
  8e:	74 09                	je     99 <strchr+0x1a>
    if(*s == c)
  90:	38 ca                	cmp    %cl,%dl
  92:	74 0a                	je     9e <strchr+0x1f>
  for(; *s; s++)
  94:	83 c0 01             	add    $0x1,%eax
  97:	eb f0                	jmp    89 <strchr+0xa>
      return (char*)s;
  return 0;
  99:	b8 00 00 00 00       	mov    $0x0,%eax
}
  9e:	5d                   	pop    %ebp
  9f:	c3                   	ret    

000000a0 <gets>:

char*
gets(char *buf, int max)
{
  a0:	55                   	push   %ebp
  a1:	89 e5                	mov    %esp,%ebp
  a3:	57                   	push   %edi
  a4:	56                   	push   %esi
  a5:	53                   	push   %ebx
  a6:	83 ec 1c             	sub    $0x1c,%esp
  a9:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  b1:	8d 73 01             	lea    0x1(%ebx),%esi
  b4:	3b 75 0c             	cmp    0xc(%ebp),%esi
  b7:	7d 2e                	jge    e7 <gets+0x47>
    cc = read(0, &c, 1);
  b9:	83 ec 04             	sub    $0x4,%esp
  bc:	6a 01                	push   $0x1
  be:	8d 45 e7             	lea    -0x19(%ebp),%eax
  c1:	50                   	push   %eax
  c2:	6a 00                	push   $0x0
  c4:	e8 e6 00 00 00       	call   1af <read>
    if(cc < 1)
  c9:	83 c4 10             	add    $0x10,%esp
  cc:	85 c0                	test   %eax,%eax
  ce:	7e 17                	jle    e7 <gets+0x47>
      break;
    buf[i++] = c;
  d0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  d4:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
  d7:	3c 0a                	cmp    $0xa,%al
  d9:	0f 94 c2             	sete   %dl
  dc:	3c 0d                	cmp    $0xd,%al
  de:	0f 94 c0             	sete   %al
    buf[i++] = c;
  e1:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
  e3:	08 c2                	or     %al,%dl
  e5:	74 ca                	je     b1 <gets+0x11>
      break;
  }
  buf[i] = '\0';
  e7:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
  eb:	89 f8                	mov    %edi,%eax
  ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  f0:	5b                   	pop    %ebx
  f1:	5e                   	pop    %esi
  f2:	5f                   	pop    %edi
  f3:	5d                   	pop    %ebp
  f4:	c3                   	ret    

000000f5 <stat>:

int
stat(const char *n, struct stat *st)
{
  f5:	55                   	push   %ebp
  f6:	89 e5                	mov    %esp,%ebp
  f8:	56                   	push   %esi
  f9:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
  fa:	83 ec 08             	sub    $0x8,%esp
  fd:	6a 00                	push   $0x0
  ff:	ff 75 08             	pushl  0x8(%ebp)
 102:	e8 d0 00 00 00       	call   1d7 <open>
  if(fd < 0)
 107:	83 c4 10             	add    $0x10,%esp
 10a:	85 c0                	test   %eax,%eax
 10c:	78 24                	js     132 <stat+0x3d>
 10e:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 110:	83 ec 08             	sub    $0x8,%esp
 113:	ff 75 0c             	pushl  0xc(%ebp)
 116:	50                   	push   %eax
 117:	e8 d3 00 00 00       	call   1ef <fstat>
 11c:	89 c6                	mov    %eax,%esi
  close(fd);
 11e:	89 1c 24             	mov    %ebx,(%esp)
 121:	e8 99 00 00 00       	call   1bf <close>
  return r;
 126:	83 c4 10             	add    $0x10,%esp
}
 129:	89 f0                	mov    %esi,%eax
 12b:	8d 65 f8             	lea    -0x8(%ebp),%esp
 12e:	5b                   	pop    %ebx
 12f:	5e                   	pop    %esi
 130:	5d                   	pop    %ebp
 131:	c3                   	ret    
    return -1;
 132:	be ff ff ff ff       	mov    $0xffffffff,%esi
 137:	eb f0                	jmp    129 <stat+0x34>

00000139 <atoi>:

int
atoi(const char *s)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	53                   	push   %ebx
 13d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 140:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 145:	eb 10                	jmp    157 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 147:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 14a:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 14d:	83 c1 01             	add    $0x1,%ecx
 150:	0f be d2             	movsbl %dl,%edx
 153:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 157:	0f b6 11             	movzbl (%ecx),%edx
 15a:	8d 5a d0             	lea    -0x30(%edx),%ebx
 15d:	80 fb 09             	cmp    $0x9,%bl
 160:	76 e5                	jbe    147 <atoi+0xe>
  return n;
}
 162:	5b                   	pop    %ebx
 163:	5d                   	pop    %ebp
 164:	c3                   	ret    

00000165 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 165:	55                   	push   %ebp
 166:	89 e5                	mov    %esp,%ebp
 168:	56                   	push   %esi
 169:	53                   	push   %ebx
 16a:	8b 45 08             	mov    0x8(%ebp),%eax
 16d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 170:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 173:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 175:	eb 0d                	jmp    184 <memmove+0x1f>
    *dst++ = *src++;
 177:	0f b6 13             	movzbl (%ebx),%edx
 17a:	88 11                	mov    %dl,(%ecx)
 17c:	8d 5b 01             	lea    0x1(%ebx),%ebx
 17f:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 182:	89 f2                	mov    %esi,%edx
 184:	8d 72 ff             	lea    -0x1(%edx),%esi
 187:	85 d2                	test   %edx,%edx
 189:	7f ec                	jg     177 <memmove+0x12>
  return vdst;
}
 18b:	5b                   	pop    %ebx
 18c:	5e                   	pop    %esi
 18d:	5d                   	pop    %ebp
 18e:	c3                   	ret    

0000018f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 18f:	b8 01 00 00 00       	mov    $0x1,%eax
 194:	cd 40                	int    $0x40
 196:	c3                   	ret    

00000197 <exit>:
SYSCALL(exit)
 197:	b8 02 00 00 00       	mov    $0x2,%eax
 19c:	cd 40                	int    $0x40
 19e:	c3                   	ret    

0000019f <wait>:
SYSCALL(wait)
 19f:	b8 03 00 00 00       	mov    $0x3,%eax
 1a4:	cd 40                	int    $0x40
 1a6:	c3                   	ret    

000001a7 <pipe>:
SYSCALL(pipe)
 1a7:	b8 04 00 00 00       	mov    $0x4,%eax
 1ac:	cd 40                	int    $0x40
 1ae:	c3                   	ret    

000001af <read>:
SYSCALL(read)
 1af:	b8 05 00 00 00       	mov    $0x5,%eax
 1b4:	cd 40                	int    $0x40
 1b6:	c3                   	ret    

000001b7 <write>:
SYSCALL(write)
 1b7:	b8 10 00 00 00       	mov    $0x10,%eax
 1bc:	cd 40                	int    $0x40
 1be:	c3                   	ret    

000001bf <close>:
SYSCALL(close)
 1bf:	b8 15 00 00 00       	mov    $0x15,%eax
 1c4:	cd 40                	int    $0x40
 1c6:	c3                   	ret    

000001c7 <kill>:
SYSCALL(kill)
 1c7:	b8 06 00 00 00       	mov    $0x6,%eax
 1cc:	cd 40                	int    $0x40
 1ce:	c3                   	ret    

000001cf <exec>:
SYSCALL(exec)
 1cf:	b8 07 00 00 00       	mov    $0x7,%eax
 1d4:	cd 40                	int    $0x40
 1d6:	c3                   	ret    

000001d7 <open>:
SYSCALL(open)
 1d7:	b8 0f 00 00 00       	mov    $0xf,%eax
 1dc:	cd 40                	int    $0x40
 1de:	c3                   	ret    

000001df <mknod>:
SYSCALL(mknod)
 1df:	b8 11 00 00 00       	mov    $0x11,%eax
 1e4:	cd 40                	int    $0x40
 1e6:	c3                   	ret    

000001e7 <unlink>:
SYSCALL(unlink)
 1e7:	b8 12 00 00 00       	mov    $0x12,%eax
 1ec:	cd 40                	int    $0x40
 1ee:	c3                   	ret    

000001ef <fstat>:
SYSCALL(fstat)
 1ef:	b8 08 00 00 00       	mov    $0x8,%eax
 1f4:	cd 40                	int    $0x40
 1f6:	c3                   	ret    

000001f7 <link>:
SYSCALL(link)
 1f7:	b8 13 00 00 00       	mov    $0x13,%eax
 1fc:	cd 40                	int    $0x40
 1fe:	c3                   	ret    

000001ff <mkdir>:
SYSCALL(mkdir)
 1ff:	b8 14 00 00 00       	mov    $0x14,%eax
 204:	cd 40                	int    $0x40
 206:	c3                   	ret    

00000207 <chdir>:
SYSCALL(chdir)
 207:	b8 09 00 00 00       	mov    $0x9,%eax
 20c:	cd 40                	int    $0x40
 20e:	c3                   	ret    

0000020f <dup>:
SYSCALL(dup)
 20f:	b8 0a 00 00 00       	mov    $0xa,%eax
 214:	cd 40                	int    $0x40
 216:	c3                   	ret    

00000217 <getpid>:
SYSCALL(getpid)
 217:	b8 0b 00 00 00       	mov    $0xb,%eax
 21c:	cd 40                	int    $0x40
 21e:	c3                   	ret    

0000021f <sbrk>:
SYSCALL(sbrk)
 21f:	b8 0c 00 00 00       	mov    $0xc,%eax
 224:	cd 40                	int    $0x40
 226:	c3                   	ret    

00000227 <sleep>:
SYSCALL(sleep)
 227:	b8 0d 00 00 00       	mov    $0xd,%eax
 22c:	cd 40                	int    $0x40
 22e:	c3                   	ret    

0000022f <uptime>:
SYSCALL(uptime)
 22f:	b8 0e 00 00 00       	mov    $0xe,%eax
 234:	cd 40                	int    $0x40
 236:	c3                   	ret    

00000237 <setpri>:
SYSCALL(setpri)
 237:	b8 16 00 00 00       	mov    $0x16,%eax
 23c:	cd 40                	int    $0x40
 23e:	c3                   	ret    

0000023f <getpri>:
SYSCALL(getpri)
 23f:	b8 17 00 00 00       	mov    $0x17,%eax
 244:	cd 40                	int    $0x40
 246:	c3                   	ret    

00000247 <fork2>:
SYSCALL(fork2)
 247:	b8 18 00 00 00       	mov    $0x18,%eax
 24c:	cd 40                	int    $0x40
 24e:	c3                   	ret    

0000024f <getpinfo>:
SYSCALL(getpinfo)
 24f:	b8 19 00 00 00       	mov    $0x19,%eax
 254:	cd 40                	int    $0x40
 256:	c3                   	ret    

00000257 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 257:	55                   	push   %ebp
 258:	89 e5                	mov    %esp,%ebp
 25a:	83 ec 1c             	sub    $0x1c,%esp
 25d:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 260:	6a 01                	push   $0x1
 262:	8d 55 f4             	lea    -0xc(%ebp),%edx
 265:	52                   	push   %edx
 266:	50                   	push   %eax
 267:	e8 4b ff ff ff       	call   1b7 <write>
}
 26c:	83 c4 10             	add    $0x10,%esp
 26f:	c9                   	leave  
 270:	c3                   	ret    

00000271 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 271:	55                   	push   %ebp
 272:	89 e5                	mov    %esp,%ebp
 274:	57                   	push   %edi
 275:	56                   	push   %esi
 276:	53                   	push   %ebx
 277:	83 ec 2c             	sub    $0x2c,%esp
 27a:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 27c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 280:	0f 95 c3             	setne  %bl
 283:	89 d0                	mov    %edx,%eax
 285:	c1 e8 1f             	shr    $0x1f,%eax
 288:	84 c3                	test   %al,%bl
 28a:	74 10                	je     29c <printint+0x2b>
    neg = 1;
    x = -xx;
 28c:	f7 da                	neg    %edx
    neg = 1;
 28e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 295:	be 00 00 00 00       	mov    $0x0,%esi
 29a:	eb 0b                	jmp    2a7 <printint+0x36>
  neg = 0;
 29c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2a3:	eb f0                	jmp    295 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2a5:	89 c6                	mov    %eax,%esi
 2a7:	89 d0                	mov    %edx,%eax
 2a9:	ba 00 00 00 00       	mov    $0x0,%edx
 2ae:	f7 f1                	div    %ecx
 2b0:	89 c3                	mov    %eax,%ebx
 2b2:	8d 46 01             	lea    0x1(%esi),%eax
 2b5:	0f b6 92 b4 05 00 00 	movzbl 0x5b4(%edx),%edx
 2bc:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2c0:	89 da                	mov    %ebx,%edx
 2c2:	85 db                	test   %ebx,%ebx
 2c4:	75 df                	jne    2a5 <printint+0x34>
 2c6:	89 c3                	mov    %eax,%ebx
  if(neg)
 2c8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2cc:	74 16                	je     2e4 <printint+0x73>
    buf[i++] = '-';
 2ce:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2d3:	8d 5e 02             	lea    0x2(%esi),%ebx
 2d6:	eb 0c                	jmp    2e4 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 2d8:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 2dd:	89 f8                	mov    %edi,%eax
 2df:	e8 73 ff ff ff       	call   257 <putc>
  while(--i >= 0)
 2e4:	83 eb 01             	sub    $0x1,%ebx
 2e7:	79 ef                	jns    2d8 <printint+0x67>
}
 2e9:	83 c4 2c             	add    $0x2c,%esp
 2ec:	5b                   	pop    %ebx
 2ed:	5e                   	pop    %esi
 2ee:	5f                   	pop    %edi
 2ef:	5d                   	pop    %ebp
 2f0:	c3                   	ret    

000002f1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 2f1:	55                   	push   %ebp
 2f2:	89 e5                	mov    %esp,%ebp
 2f4:	57                   	push   %edi
 2f5:	56                   	push   %esi
 2f6:	53                   	push   %ebx
 2f7:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 2fa:	8d 45 10             	lea    0x10(%ebp),%eax
 2fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 300:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 305:	bb 00 00 00 00       	mov    $0x0,%ebx
 30a:	eb 14                	jmp    320 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 30c:	89 fa                	mov    %edi,%edx
 30e:	8b 45 08             	mov    0x8(%ebp),%eax
 311:	e8 41 ff ff ff       	call   257 <putc>
 316:	eb 05                	jmp    31d <printf+0x2c>
      }
    } else if(state == '%'){
 318:	83 fe 25             	cmp    $0x25,%esi
 31b:	74 25                	je     342 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 31d:	83 c3 01             	add    $0x1,%ebx
 320:	8b 45 0c             	mov    0xc(%ebp),%eax
 323:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 327:	84 c0                	test   %al,%al
 329:	0f 84 23 01 00 00    	je     452 <printf+0x161>
    c = fmt[i] & 0xff;
 32f:	0f be f8             	movsbl %al,%edi
 332:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 335:	85 f6                	test   %esi,%esi
 337:	75 df                	jne    318 <printf+0x27>
      if(c == '%'){
 339:	83 f8 25             	cmp    $0x25,%eax
 33c:	75 ce                	jne    30c <printf+0x1b>
        state = '%';
 33e:	89 c6                	mov    %eax,%esi
 340:	eb db                	jmp    31d <printf+0x2c>
      if(c == 'd'){
 342:	83 f8 64             	cmp    $0x64,%eax
 345:	74 49                	je     390 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 347:	83 f8 78             	cmp    $0x78,%eax
 34a:	0f 94 c1             	sete   %cl
 34d:	83 f8 70             	cmp    $0x70,%eax
 350:	0f 94 c2             	sete   %dl
 353:	08 d1                	or     %dl,%cl
 355:	75 63                	jne    3ba <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 357:	83 f8 73             	cmp    $0x73,%eax
 35a:	0f 84 84 00 00 00    	je     3e4 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 360:	83 f8 63             	cmp    $0x63,%eax
 363:	0f 84 b7 00 00 00    	je     420 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 369:	83 f8 25             	cmp    $0x25,%eax
 36c:	0f 84 cc 00 00 00    	je     43e <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 372:	ba 25 00 00 00       	mov    $0x25,%edx
 377:	8b 45 08             	mov    0x8(%ebp),%eax
 37a:	e8 d8 fe ff ff       	call   257 <putc>
        putc(fd, c);
 37f:	89 fa                	mov    %edi,%edx
 381:	8b 45 08             	mov    0x8(%ebp),%eax
 384:	e8 ce fe ff ff       	call   257 <putc>
      }
      state = 0;
 389:	be 00 00 00 00       	mov    $0x0,%esi
 38e:	eb 8d                	jmp    31d <printf+0x2c>
        printint(fd, *ap, 10, 1);
 390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 393:	8b 17                	mov    (%edi),%edx
 395:	83 ec 0c             	sub    $0xc,%esp
 398:	6a 01                	push   $0x1
 39a:	b9 0a 00 00 00       	mov    $0xa,%ecx
 39f:	8b 45 08             	mov    0x8(%ebp),%eax
 3a2:	e8 ca fe ff ff       	call   271 <printint>
        ap++;
 3a7:	83 c7 04             	add    $0x4,%edi
 3aa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3ad:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3b0:	be 00 00 00 00       	mov    $0x0,%esi
 3b5:	e9 63 ff ff ff       	jmp    31d <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3bd:	8b 17                	mov    (%edi),%edx
 3bf:	83 ec 0c             	sub    $0xc,%esp
 3c2:	6a 00                	push   $0x0
 3c4:	b9 10 00 00 00       	mov    $0x10,%ecx
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	e8 a0 fe ff ff       	call   271 <printint>
        ap++;
 3d1:	83 c7 04             	add    $0x4,%edi
 3d4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d7:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3da:	be 00 00 00 00       	mov    $0x0,%esi
 3df:	e9 39 ff ff ff       	jmp    31d <printf+0x2c>
        s = (char*)*ap;
 3e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 3e7:	8b 30                	mov    (%eax),%esi
        ap++;
 3e9:	83 c0 04             	add    $0x4,%eax
 3ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 3ef:	85 f6                	test   %esi,%esi
 3f1:	75 28                	jne    41b <printf+0x12a>
          s = "(null)";
 3f3:	be ac 05 00 00       	mov    $0x5ac,%esi
 3f8:	8b 7d 08             	mov    0x8(%ebp),%edi
 3fb:	eb 0d                	jmp    40a <printf+0x119>
          putc(fd, *s);
 3fd:	0f be d2             	movsbl %dl,%edx
 400:	89 f8                	mov    %edi,%eax
 402:	e8 50 fe ff ff       	call   257 <putc>
          s++;
 407:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 40a:	0f b6 16             	movzbl (%esi),%edx
 40d:	84 d2                	test   %dl,%dl
 40f:	75 ec                	jne    3fd <printf+0x10c>
      state = 0;
 411:	be 00 00 00 00       	mov    $0x0,%esi
 416:	e9 02 ff ff ff       	jmp    31d <printf+0x2c>
 41b:	8b 7d 08             	mov    0x8(%ebp),%edi
 41e:	eb ea                	jmp    40a <printf+0x119>
        putc(fd, *ap);
 420:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 423:	0f be 17             	movsbl (%edi),%edx
 426:	8b 45 08             	mov    0x8(%ebp),%eax
 429:	e8 29 fe ff ff       	call   257 <putc>
        ap++;
 42e:	83 c7 04             	add    $0x4,%edi
 431:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 434:	be 00 00 00 00       	mov    $0x0,%esi
 439:	e9 df fe ff ff       	jmp    31d <printf+0x2c>
        putc(fd, c);
 43e:	89 fa                	mov    %edi,%edx
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	e8 0f fe ff ff       	call   257 <putc>
      state = 0;
 448:	be 00 00 00 00       	mov    $0x0,%esi
 44d:	e9 cb fe ff ff       	jmp    31d <printf+0x2c>
    }
  }
}
 452:	8d 65 f4             	lea    -0xc(%ebp),%esp
 455:	5b                   	pop    %ebx
 456:	5e                   	pop    %esi
 457:	5f                   	pop    %edi
 458:	5d                   	pop    %ebp
 459:	c3                   	ret    

0000045a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 45a:	55                   	push   %ebp
 45b:	89 e5                	mov    %esp,%ebp
 45d:	57                   	push   %edi
 45e:	56                   	push   %esi
 45f:	53                   	push   %ebx
 460:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 463:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 466:	a1 48 08 00 00       	mov    0x848,%eax
 46b:	eb 02                	jmp    46f <free+0x15>
 46d:	89 d0                	mov    %edx,%eax
 46f:	39 c8                	cmp    %ecx,%eax
 471:	73 04                	jae    477 <free+0x1d>
 473:	39 08                	cmp    %ecx,(%eax)
 475:	77 12                	ja     489 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 477:	8b 10                	mov    (%eax),%edx
 479:	39 c2                	cmp    %eax,%edx
 47b:	77 f0                	ja     46d <free+0x13>
 47d:	39 c8                	cmp    %ecx,%eax
 47f:	72 08                	jb     489 <free+0x2f>
 481:	39 ca                	cmp    %ecx,%edx
 483:	77 04                	ja     489 <free+0x2f>
 485:	89 d0                	mov    %edx,%eax
 487:	eb e6                	jmp    46f <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 489:	8b 73 fc             	mov    -0x4(%ebx),%esi
 48c:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 48f:	8b 10                	mov    (%eax),%edx
 491:	39 d7                	cmp    %edx,%edi
 493:	74 19                	je     4ae <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 495:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 498:	8b 50 04             	mov    0x4(%eax),%edx
 49b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 49e:	39 ce                	cmp    %ecx,%esi
 4a0:	74 1b                	je     4bd <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4a2:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4a4:	a3 48 08 00 00       	mov    %eax,0x848
}
 4a9:	5b                   	pop    %ebx
 4aa:	5e                   	pop    %esi
 4ab:	5f                   	pop    %edi
 4ac:	5d                   	pop    %ebp
 4ad:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4ae:	03 72 04             	add    0x4(%edx),%esi
 4b1:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4b4:	8b 10                	mov    (%eax),%edx
 4b6:	8b 12                	mov    (%edx),%edx
 4b8:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4bb:	eb db                	jmp    498 <free+0x3e>
    p->s.size += bp->s.size;
 4bd:	03 53 fc             	add    -0x4(%ebx),%edx
 4c0:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4c3:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4c6:	89 10                	mov    %edx,(%eax)
 4c8:	eb da                	jmp    4a4 <free+0x4a>

000004ca <morecore>:

static Header*
morecore(uint nu)
{
 4ca:	55                   	push   %ebp
 4cb:	89 e5                	mov    %esp,%ebp
 4cd:	53                   	push   %ebx
 4ce:	83 ec 04             	sub    $0x4,%esp
 4d1:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4d3:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 4d8:	77 05                	ja     4df <morecore+0x15>
    nu = 4096;
 4da:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 4df:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 4e6:	83 ec 0c             	sub    $0xc,%esp
 4e9:	50                   	push   %eax
 4ea:	e8 30 fd ff ff       	call   21f <sbrk>
  if(p == (char*)-1)
 4ef:	83 c4 10             	add    $0x10,%esp
 4f2:	83 f8 ff             	cmp    $0xffffffff,%eax
 4f5:	74 1c                	je     513 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 4f7:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 4fa:	83 c0 08             	add    $0x8,%eax
 4fd:	83 ec 0c             	sub    $0xc,%esp
 500:	50                   	push   %eax
 501:	e8 54 ff ff ff       	call   45a <free>
  return freep;
 506:	a1 48 08 00 00       	mov    0x848,%eax
 50b:	83 c4 10             	add    $0x10,%esp
}
 50e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 511:	c9                   	leave  
 512:	c3                   	ret    
    return 0;
 513:	b8 00 00 00 00       	mov    $0x0,%eax
 518:	eb f4                	jmp    50e <morecore+0x44>

0000051a <malloc>:

void*
malloc(uint nbytes)
{
 51a:	55                   	push   %ebp
 51b:	89 e5                	mov    %esp,%ebp
 51d:	53                   	push   %ebx
 51e:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 521:	8b 45 08             	mov    0x8(%ebp),%eax
 524:	8d 58 07             	lea    0x7(%eax),%ebx
 527:	c1 eb 03             	shr    $0x3,%ebx
 52a:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 52d:	8b 0d 48 08 00 00    	mov    0x848,%ecx
 533:	85 c9                	test   %ecx,%ecx
 535:	74 04                	je     53b <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 537:	8b 01                	mov    (%ecx),%eax
 539:	eb 4d                	jmp    588 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 53b:	c7 05 48 08 00 00 4c 	movl   $0x84c,0x848
 542:	08 00 00 
 545:	c7 05 4c 08 00 00 4c 	movl   $0x84c,0x84c
 54c:	08 00 00 
    base.s.size = 0;
 54f:	c7 05 50 08 00 00 00 	movl   $0x0,0x850
 556:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 559:	b9 4c 08 00 00       	mov    $0x84c,%ecx
 55e:	eb d7                	jmp    537 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 560:	39 da                	cmp    %ebx,%edx
 562:	74 1a                	je     57e <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 564:	29 da                	sub    %ebx,%edx
 566:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 569:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 56c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 56f:	89 0d 48 08 00 00    	mov    %ecx,0x848
      return (void*)(p + 1);
 575:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 578:	83 c4 04             	add    $0x4,%esp
 57b:	5b                   	pop    %ebx
 57c:	5d                   	pop    %ebp
 57d:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 57e:	8b 10                	mov    (%eax),%edx
 580:	89 11                	mov    %edx,(%ecx)
 582:	eb eb                	jmp    56f <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 584:	89 c1                	mov    %eax,%ecx
 586:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 588:	8b 50 04             	mov    0x4(%eax),%edx
 58b:	39 da                	cmp    %ebx,%edx
 58d:	73 d1                	jae    560 <malloc+0x46>
    if(p == freep)
 58f:	39 05 48 08 00 00    	cmp    %eax,0x848
 595:	75 ed                	jne    584 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 597:	89 d8                	mov    %ebx,%eax
 599:	e8 2c ff ff ff       	call   4ca <morecore>
 59e:	85 c0                	test   %eax,%eax
 5a0:	75 e2                	jne    584 <malloc+0x6a>
        return 0;
 5a2:	b8 00 00 00 00       	mov    $0x0,%eax
 5a7:	eb cf                	jmp    578 <malloc+0x5e>
