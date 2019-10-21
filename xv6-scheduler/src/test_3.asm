
_test_3:     file format elf32-i386


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
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	81 ec 14 0c 00 00    	sub    $0xc14,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  17:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  1d:	50                   	push   %eax
  1e:	e8 18 03 00 00       	call   33b <getpinfo>
  23:	83 c4 10             	add    $0x10,%esp
  26:	85 c0                	test   %eax,%eax
  28:	75 07                	jne    31 <main+0x31>
{
  2a:	bf 00 00 00 00       	mov    $0x0,%edi
  2f:	eb 4a                	jmp    7b <main+0x7b>
  check(getpinfo(&st) == 0, "getpinfo");
  31:	83 ec 0c             	sub    $0xc,%esp
  34:	68 98 06 00 00       	push   $0x698
  39:	6a 17                	push   $0x17
  3b:	68 a1 06 00 00       	push   $0x6a1
  40:	68 c4 06 00 00       	push   $0x6c4
  45:	6a 01                	push   $0x1
  47:	e8 91 03 00 00       	call   3dd <printf>
  4c:	83 c4 20             	add    $0x20,%esp
  4f:	eb d9                	jmp    2a <main+0x2a>
  for (i = 0; i < 1; i++) {
    int c_pid = fork();
   
    // Child
    if (c_pid == 0) {
      exit();
  51:	e8 2d 02 00 00       	call   283 <exit>
    } else {
      int pri = getpri(c_pid);
      int new_pri;
      if(pri == 1){
	setpri(c_pid, 2);
  56:	83 ec 08             	sub    $0x8,%esp
  59:	6a 02                	push   $0x2
  5b:	53                   	push   %ebx
  5c:	e8 c2 02 00 00       	call   323 <setpri>
  61:	83 c4 10             	add    $0x10,%esp
  64:	eb 45                	jmp    ab <main+0xab>
	setpri(c_pid, 1);
      }
      new_pri = getpri(c_pid);
      
      if( new_pri != pri && (new_pri >= 0 && new_pri <=3)){
	printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  66:	83 ec 08             	sub    $0x8,%esp
  69:	68 aa 06 00 00       	push   $0x6aa
  6e:	6a 01                	push   $0x1
  70:	e8 68 03 00 00       	call   3dd <printf>
  75:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 1; i++) {
  78:	83 c7 01             	add    $0x1,%edi
  7b:	85 ff                	test   %edi,%edi
  7d:	7f 5f                	jg     de <main+0xde>
    int c_pid = fork();
  7f:	e8 f7 01 00 00       	call   27b <fork>
  84:	89 c3                	mov    %eax,%ebx
    if (c_pid == 0) {
  86:	85 c0                	test   %eax,%eax
  88:	74 c7                	je     51 <main+0x51>
      int pri = getpri(c_pid);
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	50                   	push   %eax
  8e:	e8 98 02 00 00       	call   32b <getpri>
  93:	89 c6                	mov    %eax,%esi
      if(pri == 1){
  95:	83 c4 10             	add    $0x10,%esp
  98:	83 f8 01             	cmp    $0x1,%eax
  9b:	74 b9                	je     56 <main+0x56>
	setpri(c_pid, 1);
  9d:	83 ec 08             	sub    $0x8,%esp
  a0:	6a 01                	push   $0x1
  a2:	53                   	push   %ebx
  a3:	e8 7b 02 00 00       	call   323 <setpri>
  a8:	83 c4 10             	add    $0x10,%esp
      new_pri = getpri(c_pid);
  ab:	83 ec 0c             	sub    $0xc,%esp
  ae:	53                   	push   %ebx
  af:	e8 77 02 00 00       	call   32b <getpri>
      if( new_pri != pri && (new_pri >= 0 && new_pri <=3)){
  b4:	83 c4 10             	add    $0x10,%esp
  b7:	39 c6                	cmp    %eax,%esi
  b9:	0f 95 c1             	setne  %cl
  bc:	83 f8 03             	cmp    $0x3,%eax
  bf:	0f 96 c2             	setbe  %dl
  c2:	84 d1                	test   %dl,%cl
  c4:	75 a0                	jne    66 <main+0x66>
      }else if (new_pri == pri){
  c6:	39 c6                	cmp    %eax,%esi
  c8:	75 ae                	jne    78 <main+0x78>
	printf(1, "XV6_SCHEDULER\t setpri() FAILED\n");
  ca:	83 ec 08             	sub    $0x8,%esp
  cd:	68 f4 06 00 00       	push   $0x6f4
  d2:	6a 01                	push   $0x1
  d4:	e8 04 03 00 00       	call   3dd <printf>
  d9:	83 c4 10             	add    $0x10,%esp
  dc:	eb 9a                	jmp    78 <main+0x78>
    }

    }
  }

  for (i = 0; i < 1; i++) {
  de:	bb 00 00 00 00       	mov    $0x0,%ebx
  e3:	85 db                	test   %ebx,%ebx
  e5:	7e 05                	jle    ec <main+0xec>

    wait();
  }


  exit();
  e7:	e8 97 01 00 00       	call   283 <exit>
    wait();
  ec:	e8 9a 01 00 00       	call   28b <wait>
  for (i = 0; i < 1; i++) {
  f1:	83 c3 01             	add    $0x1,%ebx
  f4:	eb ed                	jmp    e3 <main+0xe3>

000000f6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  f9:	53                   	push   %ebx
  fa:	8b 45 08             	mov    0x8(%ebp),%eax
  fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 100:	89 c2                	mov    %eax,%edx
 102:	0f b6 19             	movzbl (%ecx),%ebx
 105:	88 1a                	mov    %bl,(%edx)
 107:	8d 52 01             	lea    0x1(%edx),%edx
 10a:	8d 49 01             	lea    0x1(%ecx),%ecx
 10d:	84 db                	test   %bl,%bl
 10f:	75 f1                	jne    102 <strcpy+0xc>
    ;
  return os;
}
 111:	5b                   	pop    %ebx
 112:	5d                   	pop    %ebp
 113:	c3                   	ret    

00000114 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11a:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 11d:	eb 06                	jmp    125 <strcmp+0x11>
    p++, q++;
 11f:	83 c1 01             	add    $0x1,%ecx
 122:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 125:	0f b6 01             	movzbl (%ecx),%eax
 128:	84 c0                	test   %al,%al
 12a:	74 04                	je     130 <strcmp+0x1c>
 12c:	3a 02                	cmp    (%edx),%al
 12e:	74 ef                	je     11f <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 130:	0f b6 c0             	movzbl %al,%eax
 133:	0f b6 12             	movzbl (%edx),%edx
 136:	29 d0                	sub    %edx,%eax
}
 138:	5d                   	pop    %ebp
 139:	c3                   	ret    

0000013a <strlen>:

uint
strlen(const char *s)
{
 13a:	55                   	push   %ebp
 13b:	89 e5                	mov    %esp,%ebp
 13d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 140:	ba 00 00 00 00       	mov    $0x0,%edx
 145:	eb 03                	jmp    14a <strlen+0x10>
 147:	83 c2 01             	add    $0x1,%edx
 14a:	89 d0                	mov    %edx,%eax
 14c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 150:	75 f5                	jne    147 <strlen+0xd>
    ;
  return n;
}
 152:	5d                   	pop    %ebp
 153:	c3                   	ret    

00000154 <memset>:

void*
memset(void *dst, int c, uint n)
{
 154:	55                   	push   %ebp
 155:	89 e5                	mov    %esp,%ebp
 157:	57                   	push   %edi
 158:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 15b:	89 d7                	mov    %edx,%edi
 15d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 160:	8b 45 0c             	mov    0xc(%ebp),%eax
 163:	fc                   	cld    
 164:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 166:	89 d0                	mov    %edx,%eax
 168:	5f                   	pop    %edi
 169:	5d                   	pop    %ebp
 16a:	c3                   	ret    

0000016b <strchr>:

char*
strchr(const char *s, char c)
{
 16b:	55                   	push   %ebp
 16c:	89 e5                	mov    %esp,%ebp
 16e:	8b 45 08             	mov    0x8(%ebp),%eax
 171:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 175:	0f b6 10             	movzbl (%eax),%edx
 178:	84 d2                	test   %dl,%dl
 17a:	74 09                	je     185 <strchr+0x1a>
    if(*s == c)
 17c:	38 ca                	cmp    %cl,%dl
 17e:	74 0a                	je     18a <strchr+0x1f>
  for(; *s; s++)
 180:	83 c0 01             	add    $0x1,%eax
 183:	eb f0                	jmp    175 <strchr+0xa>
      return (char*)s;
  return 0;
 185:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18a:	5d                   	pop    %ebp
 18b:	c3                   	ret    

0000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	55                   	push   %ebp
 18d:	89 e5                	mov    %esp,%ebp
 18f:	57                   	push   %edi
 190:	56                   	push   %esi
 191:	53                   	push   %ebx
 192:	83 ec 1c             	sub    $0x1c,%esp
 195:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 198:	bb 00 00 00 00       	mov    $0x0,%ebx
 19d:	8d 73 01             	lea    0x1(%ebx),%esi
 1a0:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1a3:	7d 2e                	jge    1d3 <gets+0x47>
    cc = read(0, &c, 1);
 1a5:	83 ec 04             	sub    $0x4,%esp
 1a8:	6a 01                	push   $0x1
 1aa:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1ad:	50                   	push   %eax
 1ae:	6a 00                	push   $0x0
 1b0:	e8 e6 00 00 00       	call   29b <read>
    if(cc < 1)
 1b5:	83 c4 10             	add    $0x10,%esp
 1b8:	85 c0                	test   %eax,%eax
 1ba:	7e 17                	jle    1d3 <gets+0x47>
      break;
    buf[i++] = c;
 1bc:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1c0:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1c3:	3c 0a                	cmp    $0xa,%al
 1c5:	0f 94 c2             	sete   %dl
 1c8:	3c 0d                	cmp    $0xd,%al
 1ca:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1cd:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1cf:	08 c2                	or     %al,%dl
 1d1:	74 ca                	je     19d <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1d3:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1d7:	89 f8                	mov    %edi,%eax
 1d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1dc:	5b                   	pop    %ebx
 1dd:	5e                   	pop    %esi
 1de:	5f                   	pop    %edi
 1df:	5d                   	pop    %ebp
 1e0:	c3                   	ret    

000001e1 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	56                   	push   %esi
 1e5:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1e6:	83 ec 08             	sub    $0x8,%esp
 1e9:	6a 00                	push   $0x0
 1eb:	ff 75 08             	pushl  0x8(%ebp)
 1ee:	e8 d0 00 00 00       	call   2c3 <open>
  if(fd < 0)
 1f3:	83 c4 10             	add    $0x10,%esp
 1f6:	85 c0                	test   %eax,%eax
 1f8:	78 24                	js     21e <stat+0x3d>
 1fa:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1fc:	83 ec 08             	sub    $0x8,%esp
 1ff:	ff 75 0c             	pushl  0xc(%ebp)
 202:	50                   	push   %eax
 203:	e8 d3 00 00 00       	call   2db <fstat>
 208:	89 c6                	mov    %eax,%esi
  close(fd);
 20a:	89 1c 24             	mov    %ebx,(%esp)
 20d:	e8 99 00 00 00       	call   2ab <close>
  return r;
 212:	83 c4 10             	add    $0x10,%esp
}
 215:	89 f0                	mov    %esi,%eax
 217:	8d 65 f8             	lea    -0x8(%ebp),%esp
 21a:	5b                   	pop    %ebx
 21b:	5e                   	pop    %esi
 21c:	5d                   	pop    %ebp
 21d:	c3                   	ret    
    return -1;
 21e:	be ff ff ff ff       	mov    $0xffffffff,%esi
 223:	eb f0                	jmp    215 <stat+0x34>

00000225 <atoi>:

int
atoi(const char *s)
{
 225:	55                   	push   %ebp
 226:	89 e5                	mov    %esp,%ebp
 228:	53                   	push   %ebx
 229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 22c:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 231:	eb 10                	jmp    243 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 233:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 236:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 239:	83 c1 01             	add    $0x1,%ecx
 23c:	0f be d2             	movsbl %dl,%edx
 23f:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 243:	0f b6 11             	movzbl (%ecx),%edx
 246:	8d 5a d0             	lea    -0x30(%edx),%ebx
 249:	80 fb 09             	cmp    $0x9,%bl
 24c:	76 e5                	jbe    233 <atoi+0xe>
  return n;
}
 24e:	5b                   	pop    %ebx
 24f:	5d                   	pop    %ebp
 250:	c3                   	ret    

00000251 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 251:	55                   	push   %ebp
 252:	89 e5                	mov    %esp,%ebp
 254:	56                   	push   %esi
 255:	53                   	push   %ebx
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 25c:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 25f:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 261:	eb 0d                	jmp    270 <memmove+0x1f>
    *dst++ = *src++;
 263:	0f b6 13             	movzbl (%ebx),%edx
 266:	88 11                	mov    %dl,(%ecx)
 268:	8d 5b 01             	lea    0x1(%ebx),%ebx
 26b:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 26e:	89 f2                	mov    %esi,%edx
 270:	8d 72 ff             	lea    -0x1(%edx),%esi
 273:	85 d2                	test   %edx,%edx
 275:	7f ec                	jg     263 <memmove+0x12>
  return vdst;
}
 277:	5b                   	pop    %ebx
 278:	5e                   	pop    %esi
 279:	5d                   	pop    %ebp
 27a:	c3                   	ret    

0000027b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 27b:	b8 01 00 00 00       	mov    $0x1,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <exit>:
SYSCALL(exit)
 283:	b8 02 00 00 00       	mov    $0x2,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <wait>:
SYSCALL(wait)
 28b:	b8 03 00 00 00       	mov    $0x3,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <pipe>:
SYSCALL(pipe)
 293:	b8 04 00 00 00       	mov    $0x4,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <read>:
SYSCALL(read)
 29b:	b8 05 00 00 00       	mov    $0x5,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <write>:
SYSCALL(write)
 2a3:	b8 10 00 00 00       	mov    $0x10,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <close>:
SYSCALL(close)
 2ab:	b8 15 00 00 00       	mov    $0x15,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <kill>:
SYSCALL(kill)
 2b3:	b8 06 00 00 00       	mov    $0x6,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <exec>:
SYSCALL(exec)
 2bb:	b8 07 00 00 00       	mov    $0x7,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <open>:
SYSCALL(open)
 2c3:	b8 0f 00 00 00       	mov    $0xf,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <mknod>:
SYSCALL(mknod)
 2cb:	b8 11 00 00 00       	mov    $0x11,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <unlink>:
SYSCALL(unlink)
 2d3:	b8 12 00 00 00       	mov    $0x12,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <fstat>:
SYSCALL(fstat)
 2db:	b8 08 00 00 00       	mov    $0x8,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <link>:
SYSCALL(link)
 2e3:	b8 13 00 00 00       	mov    $0x13,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <mkdir>:
SYSCALL(mkdir)
 2eb:	b8 14 00 00 00       	mov    $0x14,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <chdir>:
SYSCALL(chdir)
 2f3:	b8 09 00 00 00       	mov    $0x9,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <dup>:
SYSCALL(dup)
 2fb:	b8 0a 00 00 00       	mov    $0xa,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <getpid>:
SYSCALL(getpid)
 303:	b8 0b 00 00 00       	mov    $0xb,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <sbrk>:
SYSCALL(sbrk)
 30b:	b8 0c 00 00 00       	mov    $0xc,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <sleep>:
SYSCALL(sleep)
 313:	b8 0d 00 00 00       	mov    $0xd,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <uptime>:
SYSCALL(uptime)
 31b:	b8 0e 00 00 00       	mov    $0xe,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <setpri>:
SYSCALL(setpri)
 323:	b8 16 00 00 00       	mov    $0x16,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <getpri>:
SYSCALL(getpri)
 32b:	b8 17 00 00 00       	mov    $0x17,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <fork2>:
SYSCALL(fork2)
 333:	b8 18 00 00 00       	mov    $0x18,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <getpinfo>:
SYSCALL(getpinfo)
 33b:	b8 19 00 00 00       	mov    $0x19,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 343:	55                   	push   %ebp
 344:	89 e5                	mov    %esp,%ebp
 346:	83 ec 1c             	sub    $0x1c,%esp
 349:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 34c:	6a 01                	push   $0x1
 34e:	8d 55 f4             	lea    -0xc(%ebp),%edx
 351:	52                   	push   %edx
 352:	50                   	push   %eax
 353:	e8 4b ff ff ff       	call   2a3 <write>
}
 358:	83 c4 10             	add    $0x10,%esp
 35b:	c9                   	leave  
 35c:	c3                   	ret    

0000035d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 35d:	55                   	push   %ebp
 35e:	89 e5                	mov    %esp,%ebp
 360:	57                   	push   %edi
 361:	56                   	push   %esi
 362:	53                   	push   %ebx
 363:	83 ec 2c             	sub    $0x2c,%esp
 366:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 368:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 36c:	0f 95 c3             	setne  %bl
 36f:	89 d0                	mov    %edx,%eax
 371:	c1 e8 1f             	shr    $0x1f,%eax
 374:	84 c3                	test   %al,%bl
 376:	74 10                	je     388 <printint+0x2b>
    neg = 1;
    x = -xx;
 378:	f7 da                	neg    %edx
    neg = 1;
 37a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 381:	be 00 00 00 00       	mov    $0x0,%esi
 386:	eb 0b                	jmp    393 <printint+0x36>
  neg = 0;
 388:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 38f:	eb f0                	jmp    381 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 391:	89 c6                	mov    %eax,%esi
 393:	89 d0                	mov    %edx,%eax
 395:	ba 00 00 00 00       	mov    $0x0,%edx
 39a:	f7 f1                	div    %ecx
 39c:	89 c3                	mov    %eax,%ebx
 39e:	8d 46 01             	lea    0x1(%esi),%eax
 3a1:	0f b6 92 1c 07 00 00 	movzbl 0x71c(%edx),%edx
 3a8:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3ac:	89 da                	mov    %ebx,%edx
 3ae:	85 db                	test   %ebx,%ebx
 3b0:	75 df                	jne    391 <printint+0x34>
 3b2:	89 c3                	mov    %eax,%ebx
  if(neg)
 3b4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3b8:	74 16                	je     3d0 <printint+0x73>
    buf[i++] = '-';
 3ba:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3bf:	8d 5e 02             	lea    0x2(%esi),%ebx
 3c2:	eb 0c                	jmp    3d0 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3c4:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3c9:	89 f8                	mov    %edi,%eax
 3cb:	e8 73 ff ff ff       	call   343 <putc>
  while(--i >= 0)
 3d0:	83 eb 01             	sub    $0x1,%ebx
 3d3:	79 ef                	jns    3c4 <printint+0x67>
}
 3d5:	83 c4 2c             	add    $0x2c,%esp
 3d8:	5b                   	pop    %ebx
 3d9:	5e                   	pop    %esi
 3da:	5f                   	pop    %edi
 3db:	5d                   	pop    %ebp
 3dc:	c3                   	ret    

000003dd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3dd:	55                   	push   %ebp
 3de:	89 e5                	mov    %esp,%ebp
 3e0:	57                   	push   %edi
 3e1:	56                   	push   %esi
 3e2:	53                   	push   %ebx
 3e3:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3e6:	8d 45 10             	lea    0x10(%ebp),%eax
 3e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3ec:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3f1:	bb 00 00 00 00       	mov    $0x0,%ebx
 3f6:	eb 14                	jmp    40c <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3f8:	89 fa                	mov    %edi,%edx
 3fa:	8b 45 08             	mov    0x8(%ebp),%eax
 3fd:	e8 41 ff ff ff       	call   343 <putc>
 402:	eb 05                	jmp    409 <printf+0x2c>
      }
    } else if(state == '%'){
 404:	83 fe 25             	cmp    $0x25,%esi
 407:	74 25                	je     42e <printf+0x51>
  for(i = 0; fmt[i]; i++){
 409:	83 c3 01             	add    $0x1,%ebx
 40c:	8b 45 0c             	mov    0xc(%ebp),%eax
 40f:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 413:	84 c0                	test   %al,%al
 415:	0f 84 23 01 00 00    	je     53e <printf+0x161>
    c = fmt[i] & 0xff;
 41b:	0f be f8             	movsbl %al,%edi
 41e:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 421:	85 f6                	test   %esi,%esi
 423:	75 df                	jne    404 <printf+0x27>
      if(c == '%'){
 425:	83 f8 25             	cmp    $0x25,%eax
 428:	75 ce                	jne    3f8 <printf+0x1b>
        state = '%';
 42a:	89 c6                	mov    %eax,%esi
 42c:	eb db                	jmp    409 <printf+0x2c>
      if(c == 'd'){
 42e:	83 f8 64             	cmp    $0x64,%eax
 431:	74 49                	je     47c <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 433:	83 f8 78             	cmp    $0x78,%eax
 436:	0f 94 c1             	sete   %cl
 439:	83 f8 70             	cmp    $0x70,%eax
 43c:	0f 94 c2             	sete   %dl
 43f:	08 d1                	or     %dl,%cl
 441:	75 63                	jne    4a6 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 443:	83 f8 73             	cmp    $0x73,%eax
 446:	0f 84 84 00 00 00    	je     4d0 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 44c:	83 f8 63             	cmp    $0x63,%eax
 44f:	0f 84 b7 00 00 00    	je     50c <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 455:	83 f8 25             	cmp    $0x25,%eax
 458:	0f 84 cc 00 00 00    	je     52a <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 45e:	ba 25 00 00 00       	mov    $0x25,%edx
 463:	8b 45 08             	mov    0x8(%ebp),%eax
 466:	e8 d8 fe ff ff       	call   343 <putc>
        putc(fd, c);
 46b:	89 fa                	mov    %edi,%edx
 46d:	8b 45 08             	mov    0x8(%ebp),%eax
 470:	e8 ce fe ff ff       	call   343 <putc>
      }
      state = 0;
 475:	be 00 00 00 00       	mov    $0x0,%esi
 47a:	eb 8d                	jmp    409 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 47c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 47f:	8b 17                	mov    (%edi),%edx
 481:	83 ec 0c             	sub    $0xc,%esp
 484:	6a 01                	push   $0x1
 486:	b9 0a 00 00 00       	mov    $0xa,%ecx
 48b:	8b 45 08             	mov    0x8(%ebp),%eax
 48e:	e8 ca fe ff ff       	call   35d <printint>
        ap++;
 493:	83 c7 04             	add    $0x4,%edi
 496:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 499:	83 c4 10             	add    $0x10,%esp
      state = 0;
 49c:	be 00 00 00 00       	mov    $0x0,%esi
 4a1:	e9 63 ff ff ff       	jmp    409 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4a9:	8b 17                	mov    (%edi),%edx
 4ab:	83 ec 0c             	sub    $0xc,%esp
 4ae:	6a 00                	push   $0x0
 4b0:	b9 10 00 00 00       	mov    $0x10,%ecx
 4b5:	8b 45 08             	mov    0x8(%ebp),%eax
 4b8:	e8 a0 fe ff ff       	call   35d <printint>
        ap++;
 4bd:	83 c7 04             	add    $0x4,%edi
 4c0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4c3:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4c6:	be 00 00 00 00       	mov    $0x0,%esi
 4cb:	e9 39 ff ff ff       	jmp    409 <printf+0x2c>
        s = (char*)*ap;
 4d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4d3:	8b 30                	mov    (%eax),%esi
        ap++;
 4d5:	83 c0 04             	add    $0x4,%eax
 4d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4db:	85 f6                	test   %esi,%esi
 4dd:	75 28                	jne    507 <printf+0x12a>
          s = "(null)";
 4df:	be 14 07 00 00       	mov    $0x714,%esi
 4e4:	8b 7d 08             	mov    0x8(%ebp),%edi
 4e7:	eb 0d                	jmp    4f6 <printf+0x119>
          putc(fd, *s);
 4e9:	0f be d2             	movsbl %dl,%edx
 4ec:	89 f8                	mov    %edi,%eax
 4ee:	e8 50 fe ff ff       	call   343 <putc>
          s++;
 4f3:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4f6:	0f b6 16             	movzbl (%esi),%edx
 4f9:	84 d2                	test   %dl,%dl
 4fb:	75 ec                	jne    4e9 <printf+0x10c>
      state = 0;
 4fd:	be 00 00 00 00       	mov    $0x0,%esi
 502:	e9 02 ff ff ff       	jmp    409 <printf+0x2c>
 507:	8b 7d 08             	mov    0x8(%ebp),%edi
 50a:	eb ea                	jmp    4f6 <printf+0x119>
        putc(fd, *ap);
 50c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 50f:	0f be 17             	movsbl (%edi),%edx
 512:	8b 45 08             	mov    0x8(%ebp),%eax
 515:	e8 29 fe ff ff       	call   343 <putc>
        ap++;
 51a:	83 c7 04             	add    $0x4,%edi
 51d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 520:	be 00 00 00 00       	mov    $0x0,%esi
 525:	e9 df fe ff ff       	jmp    409 <printf+0x2c>
        putc(fd, c);
 52a:	89 fa                	mov    %edi,%edx
 52c:	8b 45 08             	mov    0x8(%ebp),%eax
 52f:	e8 0f fe ff ff       	call   343 <putc>
      state = 0;
 534:	be 00 00 00 00       	mov    $0x0,%esi
 539:	e9 cb fe ff ff       	jmp    409 <printf+0x2c>
    }
  }
}
 53e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 541:	5b                   	pop    %ebx
 542:	5e                   	pop    %esi
 543:	5f                   	pop    %edi
 544:	5d                   	pop    %ebp
 545:	c3                   	ret    

00000546 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 546:	55                   	push   %ebp
 547:	89 e5                	mov    %esp,%ebp
 549:	57                   	push   %edi
 54a:	56                   	push   %esi
 54b:	53                   	push   %ebx
 54c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 54f:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 552:	a1 c0 09 00 00       	mov    0x9c0,%eax
 557:	eb 02                	jmp    55b <free+0x15>
 559:	89 d0                	mov    %edx,%eax
 55b:	39 c8                	cmp    %ecx,%eax
 55d:	73 04                	jae    563 <free+0x1d>
 55f:	39 08                	cmp    %ecx,(%eax)
 561:	77 12                	ja     575 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 563:	8b 10                	mov    (%eax),%edx
 565:	39 c2                	cmp    %eax,%edx
 567:	77 f0                	ja     559 <free+0x13>
 569:	39 c8                	cmp    %ecx,%eax
 56b:	72 08                	jb     575 <free+0x2f>
 56d:	39 ca                	cmp    %ecx,%edx
 56f:	77 04                	ja     575 <free+0x2f>
 571:	89 d0                	mov    %edx,%eax
 573:	eb e6                	jmp    55b <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 575:	8b 73 fc             	mov    -0x4(%ebx),%esi
 578:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 57b:	8b 10                	mov    (%eax),%edx
 57d:	39 d7                	cmp    %edx,%edi
 57f:	74 19                	je     59a <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 581:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 584:	8b 50 04             	mov    0x4(%eax),%edx
 587:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 58a:	39 ce                	cmp    %ecx,%esi
 58c:	74 1b                	je     5a9 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 58e:	89 08                	mov    %ecx,(%eax)
  freep = p;
 590:	a3 c0 09 00 00       	mov    %eax,0x9c0
}
 595:	5b                   	pop    %ebx
 596:	5e                   	pop    %esi
 597:	5f                   	pop    %edi
 598:	5d                   	pop    %ebp
 599:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 59a:	03 72 04             	add    0x4(%edx),%esi
 59d:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5a0:	8b 10                	mov    (%eax),%edx
 5a2:	8b 12                	mov    (%edx),%edx
 5a4:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5a7:	eb db                	jmp    584 <free+0x3e>
    p->s.size += bp->s.size;
 5a9:	03 53 fc             	add    -0x4(%ebx),%edx
 5ac:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5af:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5b2:	89 10                	mov    %edx,(%eax)
 5b4:	eb da                	jmp    590 <free+0x4a>

000005b6 <morecore>:

static Header*
morecore(uint nu)
{
 5b6:	55                   	push   %ebp
 5b7:	89 e5                	mov    %esp,%ebp
 5b9:	53                   	push   %ebx
 5ba:	83 ec 04             	sub    $0x4,%esp
 5bd:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5bf:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5c4:	77 05                	ja     5cb <morecore+0x15>
    nu = 4096;
 5c6:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5cb:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5d2:	83 ec 0c             	sub    $0xc,%esp
 5d5:	50                   	push   %eax
 5d6:	e8 30 fd ff ff       	call   30b <sbrk>
  if(p == (char*)-1)
 5db:	83 c4 10             	add    $0x10,%esp
 5de:	83 f8 ff             	cmp    $0xffffffff,%eax
 5e1:	74 1c                	je     5ff <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5e3:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5e6:	83 c0 08             	add    $0x8,%eax
 5e9:	83 ec 0c             	sub    $0xc,%esp
 5ec:	50                   	push   %eax
 5ed:	e8 54 ff ff ff       	call   546 <free>
  return freep;
 5f2:	a1 c0 09 00 00       	mov    0x9c0,%eax
 5f7:	83 c4 10             	add    $0x10,%esp
}
 5fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5fd:	c9                   	leave  
 5fe:	c3                   	ret    
    return 0;
 5ff:	b8 00 00 00 00       	mov    $0x0,%eax
 604:	eb f4                	jmp    5fa <morecore+0x44>

00000606 <malloc>:

void*
malloc(uint nbytes)
{
 606:	55                   	push   %ebp
 607:	89 e5                	mov    %esp,%ebp
 609:	53                   	push   %ebx
 60a:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 60d:	8b 45 08             	mov    0x8(%ebp),%eax
 610:	8d 58 07             	lea    0x7(%eax),%ebx
 613:	c1 eb 03             	shr    $0x3,%ebx
 616:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 619:	8b 0d c0 09 00 00    	mov    0x9c0,%ecx
 61f:	85 c9                	test   %ecx,%ecx
 621:	74 04                	je     627 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 623:	8b 01                	mov    (%ecx),%eax
 625:	eb 4d                	jmp    674 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 627:	c7 05 c0 09 00 00 c4 	movl   $0x9c4,0x9c0
 62e:	09 00 00 
 631:	c7 05 c4 09 00 00 c4 	movl   $0x9c4,0x9c4
 638:	09 00 00 
    base.s.size = 0;
 63b:	c7 05 c8 09 00 00 00 	movl   $0x0,0x9c8
 642:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 645:	b9 c4 09 00 00       	mov    $0x9c4,%ecx
 64a:	eb d7                	jmp    623 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 64c:	39 da                	cmp    %ebx,%edx
 64e:	74 1a                	je     66a <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 650:	29 da                	sub    %ebx,%edx
 652:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 655:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 658:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 65b:	89 0d c0 09 00 00    	mov    %ecx,0x9c0
      return (void*)(p + 1);
 661:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 664:	83 c4 04             	add    $0x4,%esp
 667:	5b                   	pop    %ebx
 668:	5d                   	pop    %ebp
 669:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 66a:	8b 10                	mov    (%eax),%edx
 66c:	89 11                	mov    %edx,(%ecx)
 66e:	eb eb                	jmp    65b <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 670:	89 c1                	mov    %eax,%ecx
 672:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 674:	8b 50 04             	mov    0x4(%eax),%edx
 677:	39 da                	cmp    %ebx,%edx
 679:	73 d1                	jae    64c <malloc+0x46>
    if(p == freep)
 67b:	39 05 c0 09 00 00    	cmp    %eax,0x9c0
 681:	75 ed                	jne    670 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 683:	89 d8                	mov    %ebx,%eax
 685:	e8 2c ff ff ff       	call   5b6 <morecore>
 68a:	85 c0                	test   %eax,%eax
 68c:	75 e2                	jne    670 <malloc+0x6a>
        return 0;
 68e:	b8 00 00 00 00       	mov    $0x0,%eax
 693:	eb cf                	jmp    664 <malloc+0x5e>
