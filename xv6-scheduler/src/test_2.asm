
_test_2:     file format elf32-i386


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
   e:	83 ec 24             	sub    $0x24,%esp
  int error = 0;
  char *args[5];
  args[0] = "userRR";
  11:	c7 45 e4 18 06 00 00 	movl   $0x618,-0x1c(%ebp)
  args[1] = "5";
  18:	c7 45 e8 1f 06 00 00 	movl   $0x61f,-0x18(%ebp)
  args[2] = "3";
  1f:	c7 45 ec 21 06 00 00 	movl   $0x621,-0x14(%ebp)
  args[3] = "loop";
  26:	c7 45 f0 23 06 00 00 	movl   $0x623,-0x10(%ebp)
  args[4] = "2";
  2d:	c7 45 f4 28 06 00 00 	movl   $0x628,-0xc(%ebp)

  int c_pid = fork();
  34:	e8 c5 01 00 00       	call   1fe <fork>
  if(c_pid == 0){
  39:	85 c0                	test   %eax,%eax
  3b:	75 32                	jne    6f <main+0x6f>
    error = exec("userRR", args);
  3d:	83 ec 08             	sub    $0x8,%esp
  40:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  43:	50                   	push   %eax
  44:	68 18 06 00 00       	push   $0x618
  49:	e8 f0 01 00 00       	call   23e <exec>
    if( error == -1 ){
  4e:	83 c4 10             	add    $0x10,%esp
  51:	83 f8 ff             	cmp    $0xffffffff,%eax
  54:	74 05                	je     5b <main+0x5b>
      printf(1, "XV6_SCHEDULER\t userRR either did not exist or was not callable as specifcied in assignment\n");
    }
    exit();
  56:	e8 ab 01 00 00       	call   206 <exit>
      printf(1, "XV6_SCHEDULER\t userRR either did not exist or was not callable as specifcied in assignment\n");
  5b:	83 ec 08             	sub    $0x8,%esp
  5e:	68 2c 06 00 00       	push   $0x62c
  63:	6a 01                	push   $0x1
  65:	e8 f6 02 00 00       	call   360 <printf>
  6a:	83 c4 10             	add    $0x10,%esp
  6d:	eb e7                	jmp    56 <main+0x56>
  }else{
    wait();
  6f:	e8 9a 01 00 00       	call   20e <wait>
  }
    exit();
  74:	e8 8d 01 00 00       	call   206 <exit>

00000079 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	53                   	push   %ebx
  7d:	8b 45 08             	mov    0x8(%ebp),%eax
  80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  83:	89 c2                	mov    %eax,%edx
  85:	0f b6 19             	movzbl (%ecx),%ebx
  88:	88 1a                	mov    %bl,(%edx)
  8a:	8d 52 01             	lea    0x1(%edx),%edx
  8d:	8d 49 01             	lea    0x1(%ecx),%ecx
  90:	84 db                	test   %bl,%bl
  92:	75 f1                	jne    85 <strcpy+0xc>
    ;
  return os;
}
  94:	5b                   	pop    %ebx
  95:	5d                   	pop    %ebp
  96:	c3                   	ret    

00000097 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  97:	55                   	push   %ebp
  98:	89 e5                	mov    %esp,%ebp
  9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  a0:	eb 06                	jmp    a8 <strcmp+0x11>
    p++, q++;
  a2:	83 c1 01             	add    $0x1,%ecx
  a5:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  a8:	0f b6 01             	movzbl (%ecx),%eax
  ab:	84 c0                	test   %al,%al
  ad:	74 04                	je     b3 <strcmp+0x1c>
  af:	3a 02                	cmp    (%edx),%al
  b1:	74 ef                	je     a2 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  b3:	0f b6 c0             	movzbl %al,%eax
  b6:	0f b6 12             	movzbl (%edx),%edx
  b9:	29 d0                	sub    %edx,%eax
}
  bb:	5d                   	pop    %ebp
  bc:	c3                   	ret    

000000bd <strlen>:

uint
strlen(const char *s)
{
  bd:	55                   	push   %ebp
  be:	89 e5                	mov    %esp,%ebp
  c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  c3:	ba 00 00 00 00       	mov    $0x0,%edx
  c8:	eb 03                	jmp    cd <strlen+0x10>
  ca:	83 c2 01             	add    $0x1,%edx
  cd:	89 d0                	mov    %edx,%eax
  cf:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  d3:	75 f5                	jne    ca <strlen+0xd>
    ;
  return n;
}
  d5:	5d                   	pop    %ebp
  d6:	c3                   	ret    

000000d7 <memset>:

void*
memset(void *dst, int c, uint n)
{
  d7:	55                   	push   %ebp
  d8:	89 e5                	mov    %esp,%ebp
  da:	57                   	push   %edi
  db:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  de:	89 d7                	mov    %edx,%edi
  e0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  e6:	fc                   	cld    
  e7:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  e9:	89 d0                	mov    %edx,%eax
  eb:	5f                   	pop    %edi
  ec:	5d                   	pop    %ebp
  ed:	c3                   	ret    

000000ee <strchr>:

char*
strchr(const char *s, char c)
{
  ee:	55                   	push   %ebp
  ef:	89 e5                	mov    %esp,%ebp
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  f8:	0f b6 10             	movzbl (%eax),%edx
  fb:	84 d2                	test   %dl,%dl
  fd:	74 09                	je     108 <strchr+0x1a>
    if(*s == c)
  ff:	38 ca                	cmp    %cl,%dl
 101:	74 0a                	je     10d <strchr+0x1f>
  for(; *s; s++)
 103:	83 c0 01             	add    $0x1,%eax
 106:	eb f0                	jmp    f8 <strchr+0xa>
      return (char*)s;
  return 0;
 108:	b8 00 00 00 00       	mov    $0x0,%eax
}
 10d:	5d                   	pop    %ebp
 10e:	c3                   	ret    

0000010f <gets>:

char*
gets(char *buf, int max)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	57                   	push   %edi
 113:	56                   	push   %esi
 114:	53                   	push   %ebx
 115:	83 ec 1c             	sub    $0x1c,%esp
 118:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11b:	bb 00 00 00 00       	mov    $0x0,%ebx
 120:	8d 73 01             	lea    0x1(%ebx),%esi
 123:	3b 75 0c             	cmp    0xc(%ebp),%esi
 126:	7d 2e                	jge    156 <gets+0x47>
    cc = read(0, &c, 1);
 128:	83 ec 04             	sub    $0x4,%esp
 12b:	6a 01                	push   $0x1
 12d:	8d 45 e7             	lea    -0x19(%ebp),%eax
 130:	50                   	push   %eax
 131:	6a 00                	push   $0x0
 133:	e8 e6 00 00 00       	call   21e <read>
    if(cc < 1)
 138:	83 c4 10             	add    $0x10,%esp
 13b:	85 c0                	test   %eax,%eax
 13d:	7e 17                	jle    156 <gets+0x47>
      break;
    buf[i++] = c;
 13f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 143:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 146:	3c 0a                	cmp    $0xa,%al
 148:	0f 94 c2             	sete   %dl
 14b:	3c 0d                	cmp    $0xd,%al
 14d:	0f 94 c0             	sete   %al
    buf[i++] = c;
 150:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 152:	08 c2                	or     %al,%dl
 154:	74 ca                	je     120 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 156:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 15a:	89 f8                	mov    %edi,%eax
 15c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 15f:	5b                   	pop    %ebx
 160:	5e                   	pop    %esi
 161:	5f                   	pop    %edi
 162:	5d                   	pop    %ebp
 163:	c3                   	ret    

00000164 <stat>:

int
stat(const char *n, struct stat *st)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	56                   	push   %esi
 168:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 169:	83 ec 08             	sub    $0x8,%esp
 16c:	6a 00                	push   $0x0
 16e:	ff 75 08             	pushl  0x8(%ebp)
 171:	e8 d0 00 00 00       	call   246 <open>
  if(fd < 0)
 176:	83 c4 10             	add    $0x10,%esp
 179:	85 c0                	test   %eax,%eax
 17b:	78 24                	js     1a1 <stat+0x3d>
 17d:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 17f:	83 ec 08             	sub    $0x8,%esp
 182:	ff 75 0c             	pushl  0xc(%ebp)
 185:	50                   	push   %eax
 186:	e8 d3 00 00 00       	call   25e <fstat>
 18b:	89 c6                	mov    %eax,%esi
  close(fd);
 18d:	89 1c 24             	mov    %ebx,(%esp)
 190:	e8 99 00 00 00       	call   22e <close>
  return r;
 195:	83 c4 10             	add    $0x10,%esp
}
 198:	89 f0                	mov    %esi,%eax
 19a:	8d 65 f8             	lea    -0x8(%ebp),%esp
 19d:	5b                   	pop    %ebx
 19e:	5e                   	pop    %esi
 19f:	5d                   	pop    %ebp
 1a0:	c3                   	ret    
    return -1;
 1a1:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1a6:	eb f0                	jmp    198 <stat+0x34>

000001a8 <atoi>:

int
atoi(const char *s)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
 1ab:	53                   	push   %ebx
 1ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1af:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1b4:	eb 10                	jmp    1c6 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1b6:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1b9:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1bc:	83 c1 01             	add    $0x1,%ecx
 1bf:	0f be d2             	movsbl %dl,%edx
 1c2:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1c6:	0f b6 11             	movzbl (%ecx),%edx
 1c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1cc:	80 fb 09             	cmp    $0x9,%bl
 1cf:	76 e5                	jbe    1b6 <atoi+0xe>
  return n;
}
 1d1:	5b                   	pop    %ebx
 1d2:	5d                   	pop    %ebp
 1d3:	c3                   	ret    

000001d4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1d4:	55                   	push   %ebp
 1d5:	89 e5                	mov    %esp,%ebp
 1d7:	56                   	push   %esi
 1d8:	53                   	push   %ebx
 1d9:	8b 45 08             	mov    0x8(%ebp),%eax
 1dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1df:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1e2:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1e4:	eb 0d                	jmp    1f3 <memmove+0x1f>
    *dst++ = *src++;
 1e6:	0f b6 13             	movzbl (%ebx),%edx
 1e9:	88 11                	mov    %dl,(%ecx)
 1eb:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1ee:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1f1:	89 f2                	mov    %esi,%edx
 1f3:	8d 72 ff             	lea    -0x1(%edx),%esi
 1f6:	85 d2                	test   %edx,%edx
 1f8:	7f ec                	jg     1e6 <memmove+0x12>
  return vdst;
}
 1fa:	5b                   	pop    %ebx
 1fb:	5e                   	pop    %esi
 1fc:	5d                   	pop    %ebp
 1fd:	c3                   	ret    

000001fe <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1fe:	b8 01 00 00 00       	mov    $0x1,%eax
 203:	cd 40                	int    $0x40
 205:	c3                   	ret    

00000206 <exit>:
SYSCALL(exit)
 206:	b8 02 00 00 00       	mov    $0x2,%eax
 20b:	cd 40                	int    $0x40
 20d:	c3                   	ret    

0000020e <wait>:
SYSCALL(wait)
 20e:	b8 03 00 00 00       	mov    $0x3,%eax
 213:	cd 40                	int    $0x40
 215:	c3                   	ret    

00000216 <pipe>:
SYSCALL(pipe)
 216:	b8 04 00 00 00       	mov    $0x4,%eax
 21b:	cd 40                	int    $0x40
 21d:	c3                   	ret    

0000021e <read>:
SYSCALL(read)
 21e:	b8 05 00 00 00       	mov    $0x5,%eax
 223:	cd 40                	int    $0x40
 225:	c3                   	ret    

00000226 <write>:
SYSCALL(write)
 226:	b8 10 00 00 00       	mov    $0x10,%eax
 22b:	cd 40                	int    $0x40
 22d:	c3                   	ret    

0000022e <close>:
SYSCALL(close)
 22e:	b8 15 00 00 00       	mov    $0x15,%eax
 233:	cd 40                	int    $0x40
 235:	c3                   	ret    

00000236 <kill>:
SYSCALL(kill)
 236:	b8 06 00 00 00       	mov    $0x6,%eax
 23b:	cd 40                	int    $0x40
 23d:	c3                   	ret    

0000023e <exec>:
SYSCALL(exec)
 23e:	b8 07 00 00 00       	mov    $0x7,%eax
 243:	cd 40                	int    $0x40
 245:	c3                   	ret    

00000246 <open>:
SYSCALL(open)
 246:	b8 0f 00 00 00       	mov    $0xf,%eax
 24b:	cd 40                	int    $0x40
 24d:	c3                   	ret    

0000024e <mknod>:
SYSCALL(mknod)
 24e:	b8 11 00 00 00       	mov    $0x11,%eax
 253:	cd 40                	int    $0x40
 255:	c3                   	ret    

00000256 <unlink>:
SYSCALL(unlink)
 256:	b8 12 00 00 00       	mov    $0x12,%eax
 25b:	cd 40                	int    $0x40
 25d:	c3                   	ret    

0000025e <fstat>:
SYSCALL(fstat)
 25e:	b8 08 00 00 00       	mov    $0x8,%eax
 263:	cd 40                	int    $0x40
 265:	c3                   	ret    

00000266 <link>:
SYSCALL(link)
 266:	b8 13 00 00 00       	mov    $0x13,%eax
 26b:	cd 40                	int    $0x40
 26d:	c3                   	ret    

0000026e <mkdir>:
SYSCALL(mkdir)
 26e:	b8 14 00 00 00       	mov    $0x14,%eax
 273:	cd 40                	int    $0x40
 275:	c3                   	ret    

00000276 <chdir>:
SYSCALL(chdir)
 276:	b8 09 00 00 00       	mov    $0x9,%eax
 27b:	cd 40                	int    $0x40
 27d:	c3                   	ret    

0000027e <dup>:
SYSCALL(dup)
 27e:	b8 0a 00 00 00       	mov    $0xa,%eax
 283:	cd 40                	int    $0x40
 285:	c3                   	ret    

00000286 <getpid>:
SYSCALL(getpid)
 286:	b8 0b 00 00 00       	mov    $0xb,%eax
 28b:	cd 40                	int    $0x40
 28d:	c3                   	ret    

0000028e <sbrk>:
SYSCALL(sbrk)
 28e:	b8 0c 00 00 00       	mov    $0xc,%eax
 293:	cd 40                	int    $0x40
 295:	c3                   	ret    

00000296 <sleep>:
SYSCALL(sleep)
 296:	b8 0d 00 00 00       	mov    $0xd,%eax
 29b:	cd 40                	int    $0x40
 29d:	c3                   	ret    

0000029e <uptime>:
SYSCALL(uptime)
 29e:	b8 0e 00 00 00       	mov    $0xe,%eax
 2a3:	cd 40                	int    $0x40
 2a5:	c3                   	ret    

000002a6 <setpri>:
SYSCALL(setpri)
 2a6:	b8 16 00 00 00       	mov    $0x16,%eax
 2ab:	cd 40                	int    $0x40
 2ad:	c3                   	ret    

000002ae <getpri>:
SYSCALL(getpri)
 2ae:	b8 17 00 00 00       	mov    $0x17,%eax
 2b3:	cd 40                	int    $0x40
 2b5:	c3                   	ret    

000002b6 <fork2>:
SYSCALL(fork2)
 2b6:	b8 18 00 00 00       	mov    $0x18,%eax
 2bb:	cd 40                	int    $0x40
 2bd:	c3                   	ret    

000002be <getpinfo>:
SYSCALL(getpinfo)
 2be:	b8 19 00 00 00       	mov    $0x19,%eax
 2c3:	cd 40                	int    $0x40
 2c5:	c3                   	ret    

000002c6 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2c6:	55                   	push   %ebp
 2c7:	89 e5                	mov    %esp,%ebp
 2c9:	83 ec 1c             	sub    $0x1c,%esp
 2cc:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2cf:	6a 01                	push   $0x1
 2d1:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2d4:	52                   	push   %edx
 2d5:	50                   	push   %eax
 2d6:	e8 4b ff ff ff       	call   226 <write>
}
 2db:	83 c4 10             	add    $0x10,%esp
 2de:	c9                   	leave  
 2df:	c3                   	ret    

000002e0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2e0:	55                   	push   %ebp
 2e1:	89 e5                	mov    %esp,%ebp
 2e3:	57                   	push   %edi
 2e4:	56                   	push   %esi
 2e5:	53                   	push   %ebx
 2e6:	83 ec 2c             	sub    $0x2c,%esp
 2e9:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2eb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2ef:	0f 95 c3             	setne  %bl
 2f2:	89 d0                	mov    %edx,%eax
 2f4:	c1 e8 1f             	shr    $0x1f,%eax
 2f7:	84 c3                	test   %al,%bl
 2f9:	74 10                	je     30b <printint+0x2b>
    neg = 1;
    x = -xx;
 2fb:	f7 da                	neg    %edx
    neg = 1;
 2fd:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 304:	be 00 00 00 00       	mov    $0x0,%esi
 309:	eb 0b                	jmp    316 <printint+0x36>
  neg = 0;
 30b:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 312:	eb f0                	jmp    304 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 314:	89 c6                	mov    %eax,%esi
 316:	89 d0                	mov    %edx,%eax
 318:	ba 00 00 00 00       	mov    $0x0,%edx
 31d:	f7 f1                	div    %ecx
 31f:	89 c3                	mov    %eax,%ebx
 321:	8d 46 01             	lea    0x1(%esi),%eax
 324:	0f b6 92 90 06 00 00 	movzbl 0x690(%edx),%edx
 32b:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 32f:	89 da                	mov    %ebx,%edx
 331:	85 db                	test   %ebx,%ebx
 333:	75 df                	jne    314 <printint+0x34>
 335:	89 c3                	mov    %eax,%ebx
  if(neg)
 337:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 33b:	74 16                	je     353 <printint+0x73>
    buf[i++] = '-';
 33d:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 342:	8d 5e 02             	lea    0x2(%esi),%ebx
 345:	eb 0c                	jmp    353 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 347:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 34c:	89 f8                	mov    %edi,%eax
 34e:	e8 73 ff ff ff       	call   2c6 <putc>
  while(--i >= 0)
 353:	83 eb 01             	sub    $0x1,%ebx
 356:	79 ef                	jns    347 <printint+0x67>
}
 358:	83 c4 2c             	add    $0x2c,%esp
 35b:	5b                   	pop    %ebx
 35c:	5e                   	pop    %esi
 35d:	5f                   	pop    %edi
 35e:	5d                   	pop    %ebp
 35f:	c3                   	ret    

00000360 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 360:	55                   	push   %ebp
 361:	89 e5                	mov    %esp,%ebp
 363:	57                   	push   %edi
 364:	56                   	push   %esi
 365:	53                   	push   %ebx
 366:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 369:	8d 45 10             	lea    0x10(%ebp),%eax
 36c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 36f:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 374:	bb 00 00 00 00       	mov    $0x0,%ebx
 379:	eb 14                	jmp    38f <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 37b:	89 fa                	mov    %edi,%edx
 37d:	8b 45 08             	mov    0x8(%ebp),%eax
 380:	e8 41 ff ff ff       	call   2c6 <putc>
 385:	eb 05                	jmp    38c <printf+0x2c>
      }
    } else if(state == '%'){
 387:	83 fe 25             	cmp    $0x25,%esi
 38a:	74 25                	je     3b1 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 38c:	83 c3 01             	add    $0x1,%ebx
 38f:	8b 45 0c             	mov    0xc(%ebp),%eax
 392:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 396:	84 c0                	test   %al,%al
 398:	0f 84 23 01 00 00    	je     4c1 <printf+0x161>
    c = fmt[i] & 0xff;
 39e:	0f be f8             	movsbl %al,%edi
 3a1:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3a4:	85 f6                	test   %esi,%esi
 3a6:	75 df                	jne    387 <printf+0x27>
      if(c == '%'){
 3a8:	83 f8 25             	cmp    $0x25,%eax
 3ab:	75 ce                	jne    37b <printf+0x1b>
        state = '%';
 3ad:	89 c6                	mov    %eax,%esi
 3af:	eb db                	jmp    38c <printf+0x2c>
      if(c == 'd'){
 3b1:	83 f8 64             	cmp    $0x64,%eax
 3b4:	74 49                	je     3ff <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3b6:	83 f8 78             	cmp    $0x78,%eax
 3b9:	0f 94 c1             	sete   %cl
 3bc:	83 f8 70             	cmp    $0x70,%eax
 3bf:	0f 94 c2             	sete   %dl
 3c2:	08 d1                	or     %dl,%cl
 3c4:	75 63                	jne    429 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3c6:	83 f8 73             	cmp    $0x73,%eax
 3c9:	0f 84 84 00 00 00    	je     453 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3cf:	83 f8 63             	cmp    $0x63,%eax
 3d2:	0f 84 b7 00 00 00    	je     48f <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3d8:	83 f8 25             	cmp    $0x25,%eax
 3db:	0f 84 cc 00 00 00    	je     4ad <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3e1:	ba 25 00 00 00       	mov    $0x25,%edx
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	e8 d8 fe ff ff       	call   2c6 <putc>
        putc(fd, c);
 3ee:	89 fa                	mov    %edi,%edx
 3f0:	8b 45 08             	mov    0x8(%ebp),%eax
 3f3:	e8 ce fe ff ff       	call   2c6 <putc>
      }
      state = 0;
 3f8:	be 00 00 00 00       	mov    $0x0,%esi
 3fd:	eb 8d                	jmp    38c <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 402:	8b 17                	mov    (%edi),%edx
 404:	83 ec 0c             	sub    $0xc,%esp
 407:	6a 01                	push   $0x1
 409:	b9 0a 00 00 00       	mov    $0xa,%ecx
 40e:	8b 45 08             	mov    0x8(%ebp),%eax
 411:	e8 ca fe ff ff       	call   2e0 <printint>
        ap++;
 416:	83 c7 04             	add    $0x4,%edi
 419:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 41c:	83 c4 10             	add    $0x10,%esp
      state = 0;
 41f:	be 00 00 00 00       	mov    $0x0,%esi
 424:	e9 63 ff ff ff       	jmp    38c <printf+0x2c>
        printint(fd, *ap, 16, 0);
 429:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 42c:	8b 17                	mov    (%edi),%edx
 42e:	83 ec 0c             	sub    $0xc,%esp
 431:	6a 00                	push   $0x0
 433:	b9 10 00 00 00       	mov    $0x10,%ecx
 438:	8b 45 08             	mov    0x8(%ebp),%eax
 43b:	e8 a0 fe ff ff       	call   2e0 <printint>
        ap++;
 440:	83 c7 04             	add    $0x4,%edi
 443:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 446:	83 c4 10             	add    $0x10,%esp
      state = 0;
 449:	be 00 00 00 00       	mov    $0x0,%esi
 44e:	e9 39 ff ff ff       	jmp    38c <printf+0x2c>
        s = (char*)*ap;
 453:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 456:	8b 30                	mov    (%eax),%esi
        ap++;
 458:	83 c0 04             	add    $0x4,%eax
 45b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 45e:	85 f6                	test   %esi,%esi
 460:	75 28                	jne    48a <printf+0x12a>
          s = "(null)";
 462:	be 88 06 00 00       	mov    $0x688,%esi
 467:	8b 7d 08             	mov    0x8(%ebp),%edi
 46a:	eb 0d                	jmp    479 <printf+0x119>
          putc(fd, *s);
 46c:	0f be d2             	movsbl %dl,%edx
 46f:	89 f8                	mov    %edi,%eax
 471:	e8 50 fe ff ff       	call   2c6 <putc>
          s++;
 476:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 479:	0f b6 16             	movzbl (%esi),%edx
 47c:	84 d2                	test   %dl,%dl
 47e:	75 ec                	jne    46c <printf+0x10c>
      state = 0;
 480:	be 00 00 00 00       	mov    $0x0,%esi
 485:	e9 02 ff ff ff       	jmp    38c <printf+0x2c>
 48a:	8b 7d 08             	mov    0x8(%ebp),%edi
 48d:	eb ea                	jmp    479 <printf+0x119>
        putc(fd, *ap);
 48f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 492:	0f be 17             	movsbl (%edi),%edx
 495:	8b 45 08             	mov    0x8(%ebp),%eax
 498:	e8 29 fe ff ff       	call   2c6 <putc>
        ap++;
 49d:	83 c7 04             	add    $0x4,%edi
 4a0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4a3:	be 00 00 00 00       	mov    $0x0,%esi
 4a8:	e9 df fe ff ff       	jmp    38c <printf+0x2c>
        putc(fd, c);
 4ad:	89 fa                	mov    %edi,%edx
 4af:	8b 45 08             	mov    0x8(%ebp),%eax
 4b2:	e8 0f fe ff ff       	call   2c6 <putc>
      state = 0;
 4b7:	be 00 00 00 00       	mov    $0x0,%esi
 4bc:	e9 cb fe ff ff       	jmp    38c <printf+0x2c>
    }
  }
}
 4c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4c4:	5b                   	pop    %ebx
 4c5:	5e                   	pop    %esi
 4c6:	5f                   	pop    %edi
 4c7:	5d                   	pop    %ebp
 4c8:	c3                   	ret    

000004c9 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4c9:	55                   	push   %ebp
 4ca:	89 e5                	mov    %esp,%ebp
 4cc:	57                   	push   %edi
 4cd:	56                   	push   %esi
 4ce:	53                   	push   %ebx
 4cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4d2:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4d5:	a1 28 09 00 00       	mov    0x928,%eax
 4da:	eb 02                	jmp    4de <free+0x15>
 4dc:	89 d0                	mov    %edx,%eax
 4de:	39 c8                	cmp    %ecx,%eax
 4e0:	73 04                	jae    4e6 <free+0x1d>
 4e2:	39 08                	cmp    %ecx,(%eax)
 4e4:	77 12                	ja     4f8 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4e6:	8b 10                	mov    (%eax),%edx
 4e8:	39 c2                	cmp    %eax,%edx
 4ea:	77 f0                	ja     4dc <free+0x13>
 4ec:	39 c8                	cmp    %ecx,%eax
 4ee:	72 08                	jb     4f8 <free+0x2f>
 4f0:	39 ca                	cmp    %ecx,%edx
 4f2:	77 04                	ja     4f8 <free+0x2f>
 4f4:	89 d0                	mov    %edx,%eax
 4f6:	eb e6                	jmp    4de <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4f8:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4fb:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4fe:	8b 10                	mov    (%eax),%edx
 500:	39 d7                	cmp    %edx,%edi
 502:	74 19                	je     51d <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 504:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 507:	8b 50 04             	mov    0x4(%eax),%edx
 50a:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 50d:	39 ce                	cmp    %ecx,%esi
 50f:	74 1b                	je     52c <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 511:	89 08                	mov    %ecx,(%eax)
  freep = p;
 513:	a3 28 09 00 00       	mov    %eax,0x928
}
 518:	5b                   	pop    %ebx
 519:	5e                   	pop    %esi
 51a:	5f                   	pop    %edi
 51b:	5d                   	pop    %ebp
 51c:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 51d:	03 72 04             	add    0x4(%edx),%esi
 520:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 523:	8b 10                	mov    (%eax),%edx
 525:	8b 12                	mov    (%edx),%edx
 527:	89 53 f8             	mov    %edx,-0x8(%ebx)
 52a:	eb db                	jmp    507 <free+0x3e>
    p->s.size += bp->s.size;
 52c:	03 53 fc             	add    -0x4(%ebx),%edx
 52f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 532:	8b 53 f8             	mov    -0x8(%ebx),%edx
 535:	89 10                	mov    %edx,(%eax)
 537:	eb da                	jmp    513 <free+0x4a>

00000539 <morecore>:

static Header*
morecore(uint nu)
{
 539:	55                   	push   %ebp
 53a:	89 e5                	mov    %esp,%ebp
 53c:	53                   	push   %ebx
 53d:	83 ec 04             	sub    $0x4,%esp
 540:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 542:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 547:	77 05                	ja     54e <morecore+0x15>
    nu = 4096;
 549:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 54e:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 555:	83 ec 0c             	sub    $0xc,%esp
 558:	50                   	push   %eax
 559:	e8 30 fd ff ff       	call   28e <sbrk>
  if(p == (char*)-1)
 55e:	83 c4 10             	add    $0x10,%esp
 561:	83 f8 ff             	cmp    $0xffffffff,%eax
 564:	74 1c                	je     582 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 566:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 569:	83 c0 08             	add    $0x8,%eax
 56c:	83 ec 0c             	sub    $0xc,%esp
 56f:	50                   	push   %eax
 570:	e8 54 ff ff ff       	call   4c9 <free>
  return freep;
 575:	a1 28 09 00 00       	mov    0x928,%eax
 57a:	83 c4 10             	add    $0x10,%esp
}
 57d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 580:	c9                   	leave  
 581:	c3                   	ret    
    return 0;
 582:	b8 00 00 00 00       	mov    $0x0,%eax
 587:	eb f4                	jmp    57d <morecore+0x44>

00000589 <malloc>:

void*
malloc(uint nbytes)
{
 589:	55                   	push   %ebp
 58a:	89 e5                	mov    %esp,%ebp
 58c:	53                   	push   %ebx
 58d:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 590:	8b 45 08             	mov    0x8(%ebp),%eax
 593:	8d 58 07             	lea    0x7(%eax),%ebx
 596:	c1 eb 03             	shr    $0x3,%ebx
 599:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 59c:	8b 0d 28 09 00 00    	mov    0x928,%ecx
 5a2:	85 c9                	test   %ecx,%ecx
 5a4:	74 04                	je     5aa <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5a6:	8b 01                	mov    (%ecx),%eax
 5a8:	eb 4d                	jmp    5f7 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5aa:	c7 05 28 09 00 00 2c 	movl   $0x92c,0x928
 5b1:	09 00 00 
 5b4:	c7 05 2c 09 00 00 2c 	movl   $0x92c,0x92c
 5bb:	09 00 00 
    base.s.size = 0;
 5be:	c7 05 30 09 00 00 00 	movl   $0x0,0x930
 5c5:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5c8:	b9 2c 09 00 00       	mov    $0x92c,%ecx
 5cd:	eb d7                	jmp    5a6 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5cf:	39 da                	cmp    %ebx,%edx
 5d1:	74 1a                	je     5ed <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5d3:	29 da                	sub    %ebx,%edx
 5d5:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5d8:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5db:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5de:	89 0d 28 09 00 00    	mov    %ecx,0x928
      return (void*)(p + 1);
 5e4:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5e7:	83 c4 04             	add    $0x4,%esp
 5ea:	5b                   	pop    %ebx
 5eb:	5d                   	pop    %ebp
 5ec:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5ed:	8b 10                	mov    (%eax),%edx
 5ef:	89 11                	mov    %edx,(%ecx)
 5f1:	eb eb                	jmp    5de <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5f3:	89 c1                	mov    %eax,%ecx
 5f5:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5f7:	8b 50 04             	mov    0x4(%eax),%edx
 5fa:	39 da                	cmp    %ebx,%edx
 5fc:	73 d1                	jae    5cf <malloc+0x46>
    if(p == freep)
 5fe:	39 05 28 09 00 00    	cmp    %eax,0x928
 604:	75 ed                	jne    5f3 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 606:	89 d8                	mov    %ebx,%eax
 608:	e8 2c ff ff ff       	call   539 <morecore>
 60d:	85 c0                	test   %eax,%eax
 60f:	75 e2                	jne    5f3 <malloc+0x6a>
        return 0;
 611:	b8 00 00 00 00       	mov    $0x0,%eax
 616:	eb cf                	jmp    5e7 <malloc+0x5e>
