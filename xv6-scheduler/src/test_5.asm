
_test_5:     file format elf32-i386


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
  1b:	e8 ba 02 00 00       	call   2da <getpinfo>
  20:	83 c4 10             	add    $0x10,%esp
  23:	85 c0                	test   %eax,%eax
  25:	75 0e                	jne    35 <main+0x35>

  int pret;

  int c_pid = fork();
  27:	e8 ee 01 00 00       	call   21a <fork>
  if(c_pid == 0){
  2c:	85 c0                	test   %eax,%eax
  2e:	75 25                	jne    55 <main+0x55>
    exit();
  30:	e8 ed 01 00 00       	call   222 <exit>
  check(getpinfo(&st) == 0, "getpinfo");
  35:	83 ec 0c             	sub    $0xc,%esp
  38:	68 34 06 00 00       	push   $0x634
  3d:	6a 17                	push   $0x17
  3f:	68 3d 06 00 00       	push   $0x63d
  44:	68 60 06 00 00       	push   $0x660
  49:	6a 01                	push   $0x1
  4b:	e8 2c 03 00 00       	call   37c <printf>
  50:	83 c4 20             	add    $0x20,%esp
  53:	eb d2                	jmp    27 <main+0x27>
  }else{
    pret = setpri(c_pid, -1);
  55:	83 ec 08             	sub    $0x8,%esp
  58:	6a ff                	push   $0xffffffff
  5a:	50                   	push   %eax
  5b:	e8 62 02 00 00       	call   2c2 <setpri>
    
    if( pret == -1){
  60:	83 c4 10             	add    $0x10,%esp
  63:	83 f8 ff             	cmp    $0xffffffff,%eax
  66:	74 14                	je     7c <main+0x7c>
      printf(1, "XV6_SCHEDULER\t SUCCESS\n");
    } else{
      printf(1, "XV6_SCHEDULER\t setpri FAILED to return the correct error return code\n");
  68:	83 ec 08             	sub    $0x8,%esp
  6b:	68 90 06 00 00       	push   $0x690
  70:	6a 01                	push   $0x1
  72:	e8 05 03 00 00       	call   37c <printf>
      exit();
  77:	e8 a6 01 00 00       	call   222 <exit>
      printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  7c:	83 ec 08             	sub    $0x8,%esp
  7f:	68 46 06 00 00       	push   $0x646
  84:	6a 01                	push   $0x1
  86:	e8 f1 02 00 00       	call   37c <printf>
    }
  }

  wait();
  8b:	e8 9a 01 00 00       	call   22a <wait>
  
  exit();
  90:	e8 8d 01 00 00       	call   222 <exit>

00000095 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  95:	55                   	push   %ebp
  96:	89 e5                	mov    %esp,%ebp
  98:	53                   	push   %ebx
  99:	8b 45 08             	mov    0x8(%ebp),%eax
  9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  9f:	89 c2                	mov    %eax,%edx
  a1:	0f b6 19             	movzbl (%ecx),%ebx
  a4:	88 1a                	mov    %bl,(%edx)
  a6:	8d 52 01             	lea    0x1(%edx),%edx
  a9:	8d 49 01             	lea    0x1(%ecx),%ecx
  ac:	84 db                	test   %bl,%bl
  ae:	75 f1                	jne    a1 <strcpy+0xc>
    ;
  return os;
}
  b0:	5b                   	pop    %ebx
  b1:	5d                   	pop    %ebp
  b2:	c3                   	ret    

000000b3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b3:	55                   	push   %ebp
  b4:	89 e5                	mov    %esp,%ebp
  b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  bc:	eb 06                	jmp    c4 <strcmp+0x11>
    p++, q++;
  be:	83 c1 01             	add    $0x1,%ecx
  c1:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  c4:	0f b6 01             	movzbl (%ecx),%eax
  c7:	84 c0                	test   %al,%al
  c9:	74 04                	je     cf <strcmp+0x1c>
  cb:	3a 02                	cmp    (%edx),%al
  cd:	74 ef                	je     be <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  cf:	0f b6 c0             	movzbl %al,%eax
  d2:	0f b6 12             	movzbl (%edx),%edx
  d5:	29 d0                	sub    %edx,%eax
}
  d7:	5d                   	pop    %ebp
  d8:	c3                   	ret    

000000d9 <strlen>:

uint
strlen(const char *s)
{
  d9:	55                   	push   %ebp
  da:	89 e5                	mov    %esp,%ebp
  dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  df:	ba 00 00 00 00       	mov    $0x0,%edx
  e4:	eb 03                	jmp    e9 <strlen+0x10>
  e6:	83 c2 01             	add    $0x1,%edx
  e9:	89 d0                	mov    %edx,%eax
  eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  ef:	75 f5                	jne    e6 <strlen+0xd>
    ;
  return n;
}
  f1:	5d                   	pop    %ebp
  f2:	c3                   	ret    

000000f3 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f3:	55                   	push   %ebp
  f4:	89 e5                	mov    %esp,%ebp
  f6:	57                   	push   %edi
  f7:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  fa:	89 d7                	mov    %edx,%edi
  fc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  ff:	8b 45 0c             	mov    0xc(%ebp),%eax
 102:	fc                   	cld    
 103:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 105:	89 d0                	mov    %edx,%eax
 107:	5f                   	pop    %edi
 108:	5d                   	pop    %ebp
 109:	c3                   	ret    

0000010a <strchr>:

char*
strchr(const char *s, char c)
{
 10a:	55                   	push   %ebp
 10b:	89 e5                	mov    %esp,%ebp
 10d:	8b 45 08             	mov    0x8(%ebp),%eax
 110:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 114:	0f b6 10             	movzbl (%eax),%edx
 117:	84 d2                	test   %dl,%dl
 119:	74 09                	je     124 <strchr+0x1a>
    if(*s == c)
 11b:	38 ca                	cmp    %cl,%dl
 11d:	74 0a                	je     129 <strchr+0x1f>
  for(; *s; s++)
 11f:	83 c0 01             	add    $0x1,%eax
 122:	eb f0                	jmp    114 <strchr+0xa>
      return (char*)s;
  return 0;
 124:	b8 00 00 00 00       	mov    $0x0,%eax
}
 129:	5d                   	pop    %ebp
 12a:	c3                   	ret    

0000012b <gets>:

char*
gets(char *buf, int max)
{
 12b:	55                   	push   %ebp
 12c:	89 e5                	mov    %esp,%ebp
 12e:	57                   	push   %edi
 12f:	56                   	push   %esi
 130:	53                   	push   %ebx
 131:	83 ec 1c             	sub    $0x1c,%esp
 134:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 137:	bb 00 00 00 00       	mov    $0x0,%ebx
 13c:	8d 73 01             	lea    0x1(%ebx),%esi
 13f:	3b 75 0c             	cmp    0xc(%ebp),%esi
 142:	7d 2e                	jge    172 <gets+0x47>
    cc = read(0, &c, 1);
 144:	83 ec 04             	sub    $0x4,%esp
 147:	6a 01                	push   $0x1
 149:	8d 45 e7             	lea    -0x19(%ebp),%eax
 14c:	50                   	push   %eax
 14d:	6a 00                	push   $0x0
 14f:	e8 e6 00 00 00       	call   23a <read>
    if(cc < 1)
 154:	83 c4 10             	add    $0x10,%esp
 157:	85 c0                	test   %eax,%eax
 159:	7e 17                	jle    172 <gets+0x47>
      break;
    buf[i++] = c;
 15b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 15f:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 162:	3c 0a                	cmp    $0xa,%al
 164:	0f 94 c2             	sete   %dl
 167:	3c 0d                	cmp    $0xd,%al
 169:	0f 94 c0             	sete   %al
    buf[i++] = c;
 16c:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 16e:	08 c2                	or     %al,%dl
 170:	74 ca                	je     13c <gets+0x11>
      break;
  }
  buf[i] = '\0';
 172:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 176:	89 f8                	mov    %edi,%eax
 178:	8d 65 f4             	lea    -0xc(%ebp),%esp
 17b:	5b                   	pop    %ebx
 17c:	5e                   	pop    %esi
 17d:	5f                   	pop    %edi
 17e:	5d                   	pop    %ebp
 17f:	c3                   	ret    

00000180 <stat>:

int
stat(const char *n, struct stat *st)
{
 180:	55                   	push   %ebp
 181:	89 e5                	mov    %esp,%ebp
 183:	56                   	push   %esi
 184:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 185:	83 ec 08             	sub    $0x8,%esp
 188:	6a 00                	push   $0x0
 18a:	ff 75 08             	pushl  0x8(%ebp)
 18d:	e8 d0 00 00 00       	call   262 <open>
  if(fd < 0)
 192:	83 c4 10             	add    $0x10,%esp
 195:	85 c0                	test   %eax,%eax
 197:	78 24                	js     1bd <stat+0x3d>
 199:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 19b:	83 ec 08             	sub    $0x8,%esp
 19e:	ff 75 0c             	pushl  0xc(%ebp)
 1a1:	50                   	push   %eax
 1a2:	e8 d3 00 00 00       	call   27a <fstat>
 1a7:	89 c6                	mov    %eax,%esi
  close(fd);
 1a9:	89 1c 24             	mov    %ebx,(%esp)
 1ac:	e8 99 00 00 00       	call   24a <close>
  return r;
 1b1:	83 c4 10             	add    $0x10,%esp
}
 1b4:	89 f0                	mov    %esi,%eax
 1b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1b9:	5b                   	pop    %ebx
 1ba:	5e                   	pop    %esi
 1bb:	5d                   	pop    %ebp
 1bc:	c3                   	ret    
    return -1;
 1bd:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1c2:	eb f0                	jmp    1b4 <stat+0x34>

000001c4 <atoi>:

int
atoi(const char *s)
{
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	53                   	push   %ebx
 1c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1cb:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1d0:	eb 10                	jmp    1e2 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1d2:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1d5:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1d8:	83 c1 01             	add    $0x1,%ecx
 1db:	0f be d2             	movsbl %dl,%edx
 1de:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1e2:	0f b6 11             	movzbl (%ecx),%edx
 1e5:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1e8:	80 fb 09             	cmp    $0x9,%bl
 1eb:	76 e5                	jbe    1d2 <atoi+0xe>
  return n;
}
 1ed:	5b                   	pop    %ebx
 1ee:	5d                   	pop    %ebp
 1ef:	c3                   	ret    

000001f0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f0:	55                   	push   %ebp
 1f1:	89 e5                	mov    %esp,%ebp
 1f3:	56                   	push   %esi
 1f4:	53                   	push   %ebx
 1f5:	8b 45 08             	mov    0x8(%ebp),%eax
 1f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1fb:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1fe:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 200:	eb 0d                	jmp    20f <memmove+0x1f>
    *dst++ = *src++;
 202:	0f b6 13             	movzbl (%ebx),%edx
 205:	88 11                	mov    %dl,(%ecx)
 207:	8d 5b 01             	lea    0x1(%ebx),%ebx
 20a:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 20d:	89 f2                	mov    %esi,%edx
 20f:	8d 72 ff             	lea    -0x1(%edx),%esi
 212:	85 d2                	test   %edx,%edx
 214:	7f ec                	jg     202 <memmove+0x12>
  return vdst;
}
 216:	5b                   	pop    %ebx
 217:	5e                   	pop    %esi
 218:	5d                   	pop    %ebp
 219:	c3                   	ret    

0000021a <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 21a:	b8 01 00 00 00       	mov    $0x1,%eax
 21f:	cd 40                	int    $0x40
 221:	c3                   	ret    

00000222 <exit>:
SYSCALL(exit)
 222:	b8 02 00 00 00       	mov    $0x2,%eax
 227:	cd 40                	int    $0x40
 229:	c3                   	ret    

0000022a <wait>:
SYSCALL(wait)
 22a:	b8 03 00 00 00       	mov    $0x3,%eax
 22f:	cd 40                	int    $0x40
 231:	c3                   	ret    

00000232 <pipe>:
SYSCALL(pipe)
 232:	b8 04 00 00 00       	mov    $0x4,%eax
 237:	cd 40                	int    $0x40
 239:	c3                   	ret    

0000023a <read>:
SYSCALL(read)
 23a:	b8 05 00 00 00       	mov    $0x5,%eax
 23f:	cd 40                	int    $0x40
 241:	c3                   	ret    

00000242 <write>:
SYSCALL(write)
 242:	b8 10 00 00 00       	mov    $0x10,%eax
 247:	cd 40                	int    $0x40
 249:	c3                   	ret    

0000024a <close>:
SYSCALL(close)
 24a:	b8 15 00 00 00       	mov    $0x15,%eax
 24f:	cd 40                	int    $0x40
 251:	c3                   	ret    

00000252 <kill>:
SYSCALL(kill)
 252:	b8 06 00 00 00       	mov    $0x6,%eax
 257:	cd 40                	int    $0x40
 259:	c3                   	ret    

0000025a <exec>:
SYSCALL(exec)
 25a:	b8 07 00 00 00       	mov    $0x7,%eax
 25f:	cd 40                	int    $0x40
 261:	c3                   	ret    

00000262 <open>:
SYSCALL(open)
 262:	b8 0f 00 00 00       	mov    $0xf,%eax
 267:	cd 40                	int    $0x40
 269:	c3                   	ret    

0000026a <mknod>:
SYSCALL(mknod)
 26a:	b8 11 00 00 00       	mov    $0x11,%eax
 26f:	cd 40                	int    $0x40
 271:	c3                   	ret    

00000272 <unlink>:
SYSCALL(unlink)
 272:	b8 12 00 00 00       	mov    $0x12,%eax
 277:	cd 40                	int    $0x40
 279:	c3                   	ret    

0000027a <fstat>:
SYSCALL(fstat)
 27a:	b8 08 00 00 00       	mov    $0x8,%eax
 27f:	cd 40                	int    $0x40
 281:	c3                   	ret    

00000282 <link>:
SYSCALL(link)
 282:	b8 13 00 00 00       	mov    $0x13,%eax
 287:	cd 40                	int    $0x40
 289:	c3                   	ret    

0000028a <mkdir>:
SYSCALL(mkdir)
 28a:	b8 14 00 00 00       	mov    $0x14,%eax
 28f:	cd 40                	int    $0x40
 291:	c3                   	ret    

00000292 <chdir>:
SYSCALL(chdir)
 292:	b8 09 00 00 00       	mov    $0x9,%eax
 297:	cd 40                	int    $0x40
 299:	c3                   	ret    

0000029a <dup>:
SYSCALL(dup)
 29a:	b8 0a 00 00 00       	mov    $0xa,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <getpid>:
SYSCALL(getpid)
 2a2:	b8 0b 00 00 00       	mov    $0xb,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <sbrk>:
SYSCALL(sbrk)
 2aa:	b8 0c 00 00 00       	mov    $0xc,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <sleep>:
SYSCALL(sleep)
 2b2:	b8 0d 00 00 00       	mov    $0xd,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <uptime>:
SYSCALL(uptime)
 2ba:	b8 0e 00 00 00       	mov    $0xe,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <setpri>:
SYSCALL(setpri)
 2c2:	b8 16 00 00 00       	mov    $0x16,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <getpri>:
SYSCALL(getpri)
 2ca:	b8 17 00 00 00       	mov    $0x17,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <fork2>:
SYSCALL(fork2)
 2d2:	b8 18 00 00 00       	mov    $0x18,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <getpinfo>:
SYSCALL(getpinfo)
 2da:	b8 19 00 00 00       	mov    $0x19,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2e2:	55                   	push   %ebp
 2e3:	89 e5                	mov    %esp,%ebp
 2e5:	83 ec 1c             	sub    $0x1c,%esp
 2e8:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2eb:	6a 01                	push   $0x1
 2ed:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2f0:	52                   	push   %edx
 2f1:	50                   	push   %eax
 2f2:	e8 4b ff ff ff       	call   242 <write>
}
 2f7:	83 c4 10             	add    $0x10,%esp
 2fa:	c9                   	leave  
 2fb:	c3                   	ret    

000002fc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2fc:	55                   	push   %ebp
 2fd:	89 e5                	mov    %esp,%ebp
 2ff:	57                   	push   %edi
 300:	56                   	push   %esi
 301:	53                   	push   %ebx
 302:	83 ec 2c             	sub    $0x2c,%esp
 305:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 307:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 30b:	0f 95 c3             	setne  %bl
 30e:	89 d0                	mov    %edx,%eax
 310:	c1 e8 1f             	shr    $0x1f,%eax
 313:	84 c3                	test   %al,%bl
 315:	74 10                	je     327 <printint+0x2b>
    neg = 1;
    x = -xx;
 317:	f7 da                	neg    %edx
    neg = 1;
 319:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 320:	be 00 00 00 00       	mov    $0x0,%esi
 325:	eb 0b                	jmp    332 <printint+0x36>
  neg = 0;
 327:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 32e:	eb f0                	jmp    320 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 330:	89 c6                	mov    %eax,%esi
 332:	89 d0                	mov    %edx,%eax
 334:	ba 00 00 00 00       	mov    $0x0,%edx
 339:	f7 f1                	div    %ecx
 33b:	89 c3                	mov    %eax,%ebx
 33d:	8d 46 01             	lea    0x1(%esi),%eax
 340:	0f b6 92 e0 06 00 00 	movzbl 0x6e0(%edx),%edx
 347:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 34b:	89 da                	mov    %ebx,%edx
 34d:	85 db                	test   %ebx,%ebx
 34f:	75 df                	jne    330 <printint+0x34>
 351:	89 c3                	mov    %eax,%ebx
  if(neg)
 353:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 357:	74 16                	je     36f <printint+0x73>
    buf[i++] = '-';
 359:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 35e:	8d 5e 02             	lea    0x2(%esi),%ebx
 361:	eb 0c                	jmp    36f <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 363:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 368:	89 f8                	mov    %edi,%eax
 36a:	e8 73 ff ff ff       	call   2e2 <putc>
  while(--i >= 0)
 36f:	83 eb 01             	sub    $0x1,%ebx
 372:	79 ef                	jns    363 <printint+0x67>
}
 374:	83 c4 2c             	add    $0x2c,%esp
 377:	5b                   	pop    %ebx
 378:	5e                   	pop    %esi
 379:	5f                   	pop    %edi
 37a:	5d                   	pop    %ebp
 37b:	c3                   	ret    

0000037c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 37c:	55                   	push   %ebp
 37d:	89 e5                	mov    %esp,%ebp
 37f:	57                   	push   %edi
 380:	56                   	push   %esi
 381:	53                   	push   %ebx
 382:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 385:	8d 45 10             	lea    0x10(%ebp),%eax
 388:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 38b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 390:	bb 00 00 00 00       	mov    $0x0,%ebx
 395:	eb 14                	jmp    3ab <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 397:	89 fa                	mov    %edi,%edx
 399:	8b 45 08             	mov    0x8(%ebp),%eax
 39c:	e8 41 ff ff ff       	call   2e2 <putc>
 3a1:	eb 05                	jmp    3a8 <printf+0x2c>
      }
    } else if(state == '%'){
 3a3:	83 fe 25             	cmp    $0x25,%esi
 3a6:	74 25                	je     3cd <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3a8:	83 c3 01             	add    $0x1,%ebx
 3ab:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ae:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3b2:	84 c0                	test   %al,%al
 3b4:	0f 84 23 01 00 00    	je     4dd <printf+0x161>
    c = fmt[i] & 0xff;
 3ba:	0f be f8             	movsbl %al,%edi
 3bd:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3c0:	85 f6                	test   %esi,%esi
 3c2:	75 df                	jne    3a3 <printf+0x27>
      if(c == '%'){
 3c4:	83 f8 25             	cmp    $0x25,%eax
 3c7:	75 ce                	jne    397 <printf+0x1b>
        state = '%';
 3c9:	89 c6                	mov    %eax,%esi
 3cb:	eb db                	jmp    3a8 <printf+0x2c>
      if(c == 'd'){
 3cd:	83 f8 64             	cmp    $0x64,%eax
 3d0:	74 49                	je     41b <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3d2:	83 f8 78             	cmp    $0x78,%eax
 3d5:	0f 94 c1             	sete   %cl
 3d8:	83 f8 70             	cmp    $0x70,%eax
 3db:	0f 94 c2             	sete   %dl
 3de:	08 d1                	or     %dl,%cl
 3e0:	75 63                	jne    445 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3e2:	83 f8 73             	cmp    $0x73,%eax
 3e5:	0f 84 84 00 00 00    	je     46f <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3eb:	83 f8 63             	cmp    $0x63,%eax
 3ee:	0f 84 b7 00 00 00    	je     4ab <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3f4:	83 f8 25             	cmp    $0x25,%eax
 3f7:	0f 84 cc 00 00 00    	je     4c9 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3fd:	ba 25 00 00 00       	mov    $0x25,%edx
 402:	8b 45 08             	mov    0x8(%ebp),%eax
 405:	e8 d8 fe ff ff       	call   2e2 <putc>
        putc(fd, c);
 40a:	89 fa                	mov    %edi,%edx
 40c:	8b 45 08             	mov    0x8(%ebp),%eax
 40f:	e8 ce fe ff ff       	call   2e2 <putc>
      }
      state = 0;
 414:	be 00 00 00 00       	mov    $0x0,%esi
 419:	eb 8d                	jmp    3a8 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 41b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 41e:	8b 17                	mov    (%edi),%edx
 420:	83 ec 0c             	sub    $0xc,%esp
 423:	6a 01                	push   $0x1
 425:	b9 0a 00 00 00       	mov    $0xa,%ecx
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	e8 ca fe ff ff       	call   2fc <printint>
        ap++;
 432:	83 c7 04             	add    $0x4,%edi
 435:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 438:	83 c4 10             	add    $0x10,%esp
      state = 0;
 43b:	be 00 00 00 00       	mov    $0x0,%esi
 440:	e9 63 ff ff ff       	jmp    3a8 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 445:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 448:	8b 17                	mov    (%edi),%edx
 44a:	83 ec 0c             	sub    $0xc,%esp
 44d:	6a 00                	push   $0x0
 44f:	b9 10 00 00 00       	mov    $0x10,%ecx
 454:	8b 45 08             	mov    0x8(%ebp),%eax
 457:	e8 a0 fe ff ff       	call   2fc <printint>
        ap++;
 45c:	83 c7 04             	add    $0x4,%edi
 45f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 462:	83 c4 10             	add    $0x10,%esp
      state = 0;
 465:	be 00 00 00 00       	mov    $0x0,%esi
 46a:	e9 39 ff ff ff       	jmp    3a8 <printf+0x2c>
        s = (char*)*ap;
 46f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 472:	8b 30                	mov    (%eax),%esi
        ap++;
 474:	83 c0 04             	add    $0x4,%eax
 477:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 47a:	85 f6                	test   %esi,%esi
 47c:	75 28                	jne    4a6 <printf+0x12a>
          s = "(null)";
 47e:	be d8 06 00 00       	mov    $0x6d8,%esi
 483:	8b 7d 08             	mov    0x8(%ebp),%edi
 486:	eb 0d                	jmp    495 <printf+0x119>
          putc(fd, *s);
 488:	0f be d2             	movsbl %dl,%edx
 48b:	89 f8                	mov    %edi,%eax
 48d:	e8 50 fe ff ff       	call   2e2 <putc>
          s++;
 492:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 495:	0f b6 16             	movzbl (%esi),%edx
 498:	84 d2                	test   %dl,%dl
 49a:	75 ec                	jne    488 <printf+0x10c>
      state = 0;
 49c:	be 00 00 00 00       	mov    $0x0,%esi
 4a1:	e9 02 ff ff ff       	jmp    3a8 <printf+0x2c>
 4a6:	8b 7d 08             	mov    0x8(%ebp),%edi
 4a9:	eb ea                	jmp    495 <printf+0x119>
        putc(fd, *ap);
 4ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4ae:	0f be 17             	movsbl (%edi),%edx
 4b1:	8b 45 08             	mov    0x8(%ebp),%eax
 4b4:	e8 29 fe ff ff       	call   2e2 <putc>
        ap++;
 4b9:	83 c7 04             	add    $0x4,%edi
 4bc:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4bf:	be 00 00 00 00       	mov    $0x0,%esi
 4c4:	e9 df fe ff ff       	jmp    3a8 <printf+0x2c>
        putc(fd, c);
 4c9:	89 fa                	mov    %edi,%edx
 4cb:	8b 45 08             	mov    0x8(%ebp),%eax
 4ce:	e8 0f fe ff ff       	call   2e2 <putc>
      state = 0;
 4d3:	be 00 00 00 00       	mov    $0x0,%esi
 4d8:	e9 cb fe ff ff       	jmp    3a8 <printf+0x2c>
    }
  }
}
 4dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4e0:	5b                   	pop    %ebx
 4e1:	5e                   	pop    %esi
 4e2:	5f                   	pop    %edi
 4e3:	5d                   	pop    %ebp
 4e4:	c3                   	ret    

000004e5 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4e5:	55                   	push   %ebp
 4e6:	89 e5                	mov    %esp,%ebp
 4e8:	57                   	push   %edi
 4e9:	56                   	push   %esi
 4ea:	53                   	push   %ebx
 4eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4ee:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4f1:	a1 78 09 00 00       	mov    0x978,%eax
 4f6:	eb 02                	jmp    4fa <free+0x15>
 4f8:	89 d0                	mov    %edx,%eax
 4fa:	39 c8                	cmp    %ecx,%eax
 4fc:	73 04                	jae    502 <free+0x1d>
 4fe:	39 08                	cmp    %ecx,(%eax)
 500:	77 12                	ja     514 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 502:	8b 10                	mov    (%eax),%edx
 504:	39 c2                	cmp    %eax,%edx
 506:	77 f0                	ja     4f8 <free+0x13>
 508:	39 c8                	cmp    %ecx,%eax
 50a:	72 08                	jb     514 <free+0x2f>
 50c:	39 ca                	cmp    %ecx,%edx
 50e:	77 04                	ja     514 <free+0x2f>
 510:	89 d0                	mov    %edx,%eax
 512:	eb e6                	jmp    4fa <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 514:	8b 73 fc             	mov    -0x4(%ebx),%esi
 517:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 51a:	8b 10                	mov    (%eax),%edx
 51c:	39 d7                	cmp    %edx,%edi
 51e:	74 19                	je     539 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 520:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 523:	8b 50 04             	mov    0x4(%eax),%edx
 526:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 529:	39 ce                	cmp    %ecx,%esi
 52b:	74 1b                	je     548 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 52d:	89 08                	mov    %ecx,(%eax)
  freep = p;
 52f:	a3 78 09 00 00       	mov    %eax,0x978
}
 534:	5b                   	pop    %ebx
 535:	5e                   	pop    %esi
 536:	5f                   	pop    %edi
 537:	5d                   	pop    %ebp
 538:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 539:	03 72 04             	add    0x4(%edx),%esi
 53c:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 53f:	8b 10                	mov    (%eax),%edx
 541:	8b 12                	mov    (%edx),%edx
 543:	89 53 f8             	mov    %edx,-0x8(%ebx)
 546:	eb db                	jmp    523 <free+0x3e>
    p->s.size += bp->s.size;
 548:	03 53 fc             	add    -0x4(%ebx),%edx
 54b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 54e:	8b 53 f8             	mov    -0x8(%ebx),%edx
 551:	89 10                	mov    %edx,(%eax)
 553:	eb da                	jmp    52f <free+0x4a>

00000555 <morecore>:

static Header*
morecore(uint nu)
{
 555:	55                   	push   %ebp
 556:	89 e5                	mov    %esp,%ebp
 558:	53                   	push   %ebx
 559:	83 ec 04             	sub    $0x4,%esp
 55c:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 55e:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 563:	77 05                	ja     56a <morecore+0x15>
    nu = 4096;
 565:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 56a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 571:	83 ec 0c             	sub    $0xc,%esp
 574:	50                   	push   %eax
 575:	e8 30 fd ff ff       	call   2aa <sbrk>
  if(p == (char*)-1)
 57a:	83 c4 10             	add    $0x10,%esp
 57d:	83 f8 ff             	cmp    $0xffffffff,%eax
 580:	74 1c                	je     59e <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 582:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 585:	83 c0 08             	add    $0x8,%eax
 588:	83 ec 0c             	sub    $0xc,%esp
 58b:	50                   	push   %eax
 58c:	e8 54 ff ff ff       	call   4e5 <free>
  return freep;
 591:	a1 78 09 00 00       	mov    0x978,%eax
 596:	83 c4 10             	add    $0x10,%esp
}
 599:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 59c:	c9                   	leave  
 59d:	c3                   	ret    
    return 0;
 59e:	b8 00 00 00 00       	mov    $0x0,%eax
 5a3:	eb f4                	jmp    599 <morecore+0x44>

000005a5 <malloc>:

void*
malloc(uint nbytes)
{
 5a5:	55                   	push   %ebp
 5a6:	89 e5                	mov    %esp,%ebp
 5a8:	53                   	push   %ebx
 5a9:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5ac:	8b 45 08             	mov    0x8(%ebp),%eax
 5af:	8d 58 07             	lea    0x7(%eax),%ebx
 5b2:	c1 eb 03             	shr    $0x3,%ebx
 5b5:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5b8:	8b 0d 78 09 00 00    	mov    0x978,%ecx
 5be:	85 c9                	test   %ecx,%ecx
 5c0:	74 04                	je     5c6 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5c2:	8b 01                	mov    (%ecx),%eax
 5c4:	eb 4d                	jmp    613 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5c6:	c7 05 78 09 00 00 7c 	movl   $0x97c,0x978
 5cd:	09 00 00 
 5d0:	c7 05 7c 09 00 00 7c 	movl   $0x97c,0x97c
 5d7:	09 00 00 
    base.s.size = 0;
 5da:	c7 05 80 09 00 00 00 	movl   $0x0,0x980
 5e1:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5e4:	b9 7c 09 00 00       	mov    $0x97c,%ecx
 5e9:	eb d7                	jmp    5c2 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5eb:	39 da                	cmp    %ebx,%edx
 5ed:	74 1a                	je     609 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5ef:	29 da                	sub    %ebx,%edx
 5f1:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5f4:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5f7:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5fa:	89 0d 78 09 00 00    	mov    %ecx,0x978
      return (void*)(p + 1);
 600:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 603:	83 c4 04             	add    $0x4,%esp
 606:	5b                   	pop    %ebx
 607:	5d                   	pop    %ebp
 608:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 609:	8b 10                	mov    (%eax),%edx
 60b:	89 11                	mov    %edx,(%ecx)
 60d:	eb eb                	jmp    5fa <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 60f:	89 c1                	mov    %eax,%ecx
 611:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 613:	8b 50 04             	mov    0x4(%eax),%edx
 616:	39 da                	cmp    %ebx,%edx
 618:	73 d1                	jae    5eb <malloc+0x46>
    if(p == freep)
 61a:	39 05 78 09 00 00    	cmp    %eax,0x978
 620:	75 ed                	jne    60f <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 622:	89 d8                	mov    %ebx,%eax
 624:	e8 2c ff ff ff       	call   555 <morecore>
 629:	85 c0                	test   %eax,%eax
 62b:	75 e2                	jne    60f <malloc+0x6a>
        return 0;
 62d:	b8 00 00 00 00       	mov    $0x0,%eax
 632:	eb cf                	jmp    603 <malloc+0x5e>
