
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
  1e:	e8 2a 03 00 00       	call   34d <getpinfo>
  23:	83 c4 10             	add    $0x10,%esp
  26:	85 c0                	test   %eax,%eax
  28:	75 07                	jne    31 <main+0x31>
{
  2a:	bf 00 00 00 00       	mov    $0x0,%edi
  2f:	eb 4a                	jmp    7b <main+0x7b>
  check(getpinfo(&st) == 0, "getpinfo");
  31:	83 ec 0c             	sub    $0xc,%esp
  34:	68 a8 06 00 00       	push   $0x6a8
  39:	6a 17                	push   $0x17
  3b:	68 b1 06 00 00       	push   $0x6b1
  40:	68 e0 06 00 00       	push   $0x6e0
  45:	6a 01                	push   $0x1
  47:	e8 a3 03 00 00       	call   3ef <printf>
  4c:	83 c4 20             	add    $0x20,%esp
  4f:	eb d9                	jmp    2a <main+0x2a>
  for (i = 0; i < 1; i++) {
    int c_pid = fork();
   
    // Child
    if (c_pid == 0) {
      exit();
  51:	e8 3f 02 00 00       	call   295 <exit>
    } else {
      int pri = getpri(c_pid);
      int new_pri;

      if(pri == 1){
	       setpri(c_pid, 2);
  56:	83 ec 08             	sub    $0x8,%esp
  59:	6a 02                	push   $0x2
  5b:	53                   	push   %ebx
  5c:	e8 d4 02 00 00       	call   335 <setpri>
  61:	83 c4 10             	add    $0x10,%esp
  64:	eb 45                	jmp    ab <main+0xab>
	     setpri(c_pid, 1);
      }
      new_pri = getpri(c_pid);
      
      if( new_pri != pri && (new_pri >= 0 && new_pri <=3)){
        printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  66:	83 ec 08             	sub    $0x8,%esp
  69:	68 ba 06 00 00       	push   $0x6ba
  6e:	6a 01                	push   $0x1
  70:	e8 7a 03 00 00       	call   3ef <printf>
  75:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 1; i++) {
  78:	83 c7 01             	add    $0x1,%edi
  7b:	85 ff                	test   %edi,%edi
  7d:	7f 5f                	jg     de <main+0xde>
    int c_pid = fork();
  7f:	e8 09 02 00 00       	call   28d <fork>
  84:	89 c3                	mov    %eax,%ebx
    if (c_pid == 0) {
  86:	85 c0                	test   %eax,%eax
  88:	74 c7                	je     51 <main+0x51>
      int pri = getpri(c_pid);
  8a:	83 ec 0c             	sub    $0xc,%esp
  8d:	50                   	push   %eax
  8e:	e8 aa 02 00 00       	call   33d <getpri>
  93:	89 c6                	mov    %eax,%esi
      if(pri == 1){
  95:	83 c4 10             	add    $0x10,%esp
  98:	83 f8 01             	cmp    $0x1,%eax
  9b:	74 b9                	je     56 <main+0x56>
	     setpri(c_pid, 1);
  9d:	83 ec 08             	sub    $0x8,%esp
  a0:	6a 01                	push   $0x1
  a2:	53                   	push   %ebx
  a3:	e8 8d 02 00 00       	call   335 <setpri>
  a8:	83 c4 10             	add    $0x10,%esp
      new_pri = getpri(c_pid);
  ab:	83 ec 0c             	sub    $0xc,%esp
  ae:	53                   	push   %ebx
  af:	e8 89 02 00 00       	call   33d <getpri>
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
  cd:	68 10 07 00 00       	push   $0x710
  d2:	6a 01                	push   $0x1
  d4:	e8 16 03 00 00       	call   3ef <printf>
  d9:	83 c4 10             	add    $0x10,%esp
  dc:	eb 9a                	jmp    78 <main+0x78>

    }
    }
  }

  for (i = 0; i < 1; i++) {
  de:	bb 00 00 00 00       	mov    $0x0,%ebx
  e3:	85 db                	test   %ebx,%ebx
  e5:	7e 05                	jle    ec <main+0xec>
  printf(1, "HEEEEEEEY\n");
    wait();
  }


  exit();
  e7:	e8 a9 01 00 00       	call   295 <exit>
  printf(1, "HEEEEEEEY\n");
  ec:	83 ec 08             	sub    $0x8,%esp
  ef:	68 d2 06 00 00       	push   $0x6d2
  f4:	6a 01                	push   $0x1
  f6:	e8 f4 02 00 00       	call   3ef <printf>
    wait();
  fb:	e8 9d 01 00 00       	call   29d <wait>
  for (i = 0; i < 1; i++) {
 100:	83 c3 01             	add    $0x1,%ebx
 103:	83 c4 10             	add    $0x10,%esp
 106:	eb db                	jmp    e3 <main+0xe3>

00000108 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 108:	55                   	push   %ebp
 109:	89 e5                	mov    %esp,%ebp
 10b:	53                   	push   %ebx
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 112:	89 c2                	mov    %eax,%edx
 114:	0f b6 19             	movzbl (%ecx),%ebx
 117:	88 1a                	mov    %bl,(%edx)
 119:	8d 52 01             	lea    0x1(%edx),%edx
 11c:	8d 49 01             	lea    0x1(%ecx),%ecx
 11f:	84 db                	test   %bl,%bl
 121:	75 f1                	jne    114 <strcpy+0xc>
    ;
  return os;
}
 123:	5b                   	pop    %ebx
 124:	5d                   	pop    %ebp
 125:	c3                   	ret    

00000126 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 126:	55                   	push   %ebp
 127:	89 e5                	mov    %esp,%ebp
 129:	8b 4d 08             	mov    0x8(%ebp),%ecx
 12c:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 12f:	eb 06                	jmp    137 <strcmp+0x11>
    p++, q++;
 131:	83 c1 01             	add    $0x1,%ecx
 134:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 137:	0f b6 01             	movzbl (%ecx),%eax
 13a:	84 c0                	test   %al,%al
 13c:	74 04                	je     142 <strcmp+0x1c>
 13e:	3a 02                	cmp    (%edx),%al
 140:	74 ef                	je     131 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 142:	0f b6 c0             	movzbl %al,%eax
 145:	0f b6 12             	movzbl (%edx),%edx
 148:	29 d0                	sub    %edx,%eax
}
 14a:	5d                   	pop    %ebp
 14b:	c3                   	ret    

0000014c <strlen>:

uint
strlen(const char *s)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
 14f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 152:	ba 00 00 00 00       	mov    $0x0,%edx
 157:	eb 03                	jmp    15c <strlen+0x10>
 159:	83 c2 01             	add    $0x1,%edx
 15c:	89 d0                	mov    %edx,%eax
 15e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 162:	75 f5                	jne    159 <strlen+0xd>
    ;
  return n;
}
 164:	5d                   	pop    %ebp
 165:	c3                   	ret    

00000166 <memset>:

void*
memset(void *dst, int c, uint n)
{
 166:	55                   	push   %ebp
 167:	89 e5                	mov    %esp,%ebp
 169:	57                   	push   %edi
 16a:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 16d:	89 d7                	mov    %edx,%edi
 16f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 172:	8b 45 0c             	mov    0xc(%ebp),%eax
 175:	fc                   	cld    
 176:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 178:	89 d0                	mov    %edx,%eax
 17a:	5f                   	pop    %edi
 17b:	5d                   	pop    %ebp
 17c:	c3                   	ret    

0000017d <strchr>:

char*
strchr(const char *s, char c)
{
 17d:	55                   	push   %ebp
 17e:	89 e5                	mov    %esp,%ebp
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 187:	0f b6 10             	movzbl (%eax),%edx
 18a:	84 d2                	test   %dl,%dl
 18c:	74 09                	je     197 <strchr+0x1a>
    if(*s == c)
 18e:	38 ca                	cmp    %cl,%dl
 190:	74 0a                	je     19c <strchr+0x1f>
  for(; *s; s++)
 192:	83 c0 01             	add    $0x1,%eax
 195:	eb f0                	jmp    187 <strchr+0xa>
      return (char*)s;
  return 0;
 197:	b8 00 00 00 00       	mov    $0x0,%eax
}
 19c:	5d                   	pop    %ebp
 19d:	c3                   	ret    

0000019e <gets>:

char*
gets(char *buf, int max)
{
 19e:	55                   	push   %ebp
 19f:	89 e5                	mov    %esp,%ebp
 1a1:	57                   	push   %edi
 1a2:	56                   	push   %esi
 1a3:	53                   	push   %ebx
 1a4:	83 ec 1c             	sub    $0x1c,%esp
 1a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1aa:	bb 00 00 00 00       	mov    $0x0,%ebx
 1af:	8d 73 01             	lea    0x1(%ebx),%esi
 1b2:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1b5:	7d 2e                	jge    1e5 <gets+0x47>
    cc = read(0, &c, 1);
 1b7:	83 ec 04             	sub    $0x4,%esp
 1ba:	6a 01                	push   $0x1
 1bc:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1bf:	50                   	push   %eax
 1c0:	6a 00                	push   $0x0
 1c2:	e8 e6 00 00 00       	call   2ad <read>
    if(cc < 1)
 1c7:	83 c4 10             	add    $0x10,%esp
 1ca:	85 c0                	test   %eax,%eax
 1cc:	7e 17                	jle    1e5 <gets+0x47>
      break;
    buf[i++] = c;
 1ce:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1d2:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1d5:	3c 0a                	cmp    $0xa,%al
 1d7:	0f 94 c2             	sete   %dl
 1da:	3c 0d                	cmp    $0xd,%al
 1dc:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1df:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1e1:	08 c2                	or     %al,%dl
 1e3:	74 ca                	je     1af <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1e5:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1e9:	89 f8                	mov    %edi,%eax
 1eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1ee:	5b                   	pop    %ebx
 1ef:	5e                   	pop    %esi
 1f0:	5f                   	pop    %edi
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    

000001f3 <stat>:

int
stat(const char *n, struct stat *st)
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	56                   	push   %esi
 1f7:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f8:	83 ec 08             	sub    $0x8,%esp
 1fb:	6a 00                	push   $0x0
 1fd:	ff 75 08             	pushl  0x8(%ebp)
 200:	e8 d0 00 00 00       	call   2d5 <open>
  if(fd < 0)
 205:	83 c4 10             	add    $0x10,%esp
 208:	85 c0                	test   %eax,%eax
 20a:	78 24                	js     230 <stat+0x3d>
 20c:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 20e:	83 ec 08             	sub    $0x8,%esp
 211:	ff 75 0c             	pushl  0xc(%ebp)
 214:	50                   	push   %eax
 215:	e8 d3 00 00 00       	call   2ed <fstat>
 21a:	89 c6                	mov    %eax,%esi
  close(fd);
 21c:	89 1c 24             	mov    %ebx,(%esp)
 21f:	e8 99 00 00 00       	call   2bd <close>
  return r;
 224:	83 c4 10             	add    $0x10,%esp
}
 227:	89 f0                	mov    %esi,%eax
 229:	8d 65 f8             	lea    -0x8(%ebp),%esp
 22c:	5b                   	pop    %ebx
 22d:	5e                   	pop    %esi
 22e:	5d                   	pop    %ebp
 22f:	c3                   	ret    
    return -1;
 230:	be ff ff ff ff       	mov    $0xffffffff,%esi
 235:	eb f0                	jmp    227 <stat+0x34>

00000237 <atoi>:

int
atoi(const char *s)
{
 237:	55                   	push   %ebp
 238:	89 e5                	mov    %esp,%ebp
 23a:	53                   	push   %ebx
 23b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 23e:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 243:	eb 10                	jmp    255 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 245:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 248:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 24b:	83 c1 01             	add    $0x1,%ecx
 24e:	0f be d2             	movsbl %dl,%edx
 251:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 255:	0f b6 11             	movzbl (%ecx),%edx
 258:	8d 5a d0             	lea    -0x30(%edx),%ebx
 25b:	80 fb 09             	cmp    $0x9,%bl
 25e:	76 e5                	jbe    245 <atoi+0xe>
  return n;
}
 260:	5b                   	pop    %ebx
 261:	5d                   	pop    %ebp
 262:	c3                   	ret    

00000263 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 263:	55                   	push   %ebp
 264:	89 e5                	mov    %esp,%ebp
 266:	56                   	push   %esi
 267:	53                   	push   %ebx
 268:	8b 45 08             	mov    0x8(%ebp),%eax
 26b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 26e:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 271:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 273:	eb 0d                	jmp    282 <memmove+0x1f>
    *dst++ = *src++;
 275:	0f b6 13             	movzbl (%ebx),%edx
 278:	88 11                	mov    %dl,(%ecx)
 27a:	8d 5b 01             	lea    0x1(%ebx),%ebx
 27d:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 280:	89 f2                	mov    %esi,%edx
 282:	8d 72 ff             	lea    -0x1(%edx),%esi
 285:	85 d2                	test   %edx,%edx
 287:	7f ec                	jg     275 <memmove+0x12>
  return vdst;
}
 289:	5b                   	pop    %ebx
 28a:	5e                   	pop    %esi
 28b:	5d                   	pop    %ebp
 28c:	c3                   	ret    

0000028d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 28d:	b8 01 00 00 00       	mov    $0x1,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <exit>:
SYSCALL(exit)
 295:	b8 02 00 00 00       	mov    $0x2,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <wait>:
SYSCALL(wait)
 29d:	b8 03 00 00 00       	mov    $0x3,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <pipe>:
SYSCALL(pipe)
 2a5:	b8 04 00 00 00       	mov    $0x4,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <read>:
SYSCALL(read)
 2ad:	b8 05 00 00 00       	mov    $0x5,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <write>:
SYSCALL(write)
 2b5:	b8 10 00 00 00       	mov    $0x10,%eax
 2ba:	cd 40                	int    $0x40
 2bc:	c3                   	ret    

000002bd <close>:
SYSCALL(close)
 2bd:	b8 15 00 00 00       	mov    $0x15,%eax
 2c2:	cd 40                	int    $0x40
 2c4:	c3                   	ret    

000002c5 <kill>:
SYSCALL(kill)
 2c5:	b8 06 00 00 00       	mov    $0x6,%eax
 2ca:	cd 40                	int    $0x40
 2cc:	c3                   	ret    

000002cd <exec>:
SYSCALL(exec)
 2cd:	b8 07 00 00 00       	mov    $0x7,%eax
 2d2:	cd 40                	int    $0x40
 2d4:	c3                   	ret    

000002d5 <open>:
SYSCALL(open)
 2d5:	b8 0f 00 00 00       	mov    $0xf,%eax
 2da:	cd 40                	int    $0x40
 2dc:	c3                   	ret    

000002dd <mknod>:
SYSCALL(mknod)
 2dd:	b8 11 00 00 00       	mov    $0x11,%eax
 2e2:	cd 40                	int    $0x40
 2e4:	c3                   	ret    

000002e5 <unlink>:
SYSCALL(unlink)
 2e5:	b8 12 00 00 00       	mov    $0x12,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <fstat>:
SYSCALL(fstat)
 2ed:	b8 08 00 00 00       	mov    $0x8,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <link>:
SYSCALL(link)
 2f5:	b8 13 00 00 00       	mov    $0x13,%eax
 2fa:	cd 40                	int    $0x40
 2fc:	c3                   	ret    

000002fd <mkdir>:
SYSCALL(mkdir)
 2fd:	b8 14 00 00 00       	mov    $0x14,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <chdir>:
SYSCALL(chdir)
 305:	b8 09 00 00 00       	mov    $0x9,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <dup>:
SYSCALL(dup)
 30d:	b8 0a 00 00 00       	mov    $0xa,%eax
 312:	cd 40                	int    $0x40
 314:	c3                   	ret    

00000315 <getpid>:
SYSCALL(getpid)
 315:	b8 0b 00 00 00       	mov    $0xb,%eax
 31a:	cd 40                	int    $0x40
 31c:	c3                   	ret    

0000031d <sbrk>:
SYSCALL(sbrk)
 31d:	b8 0c 00 00 00       	mov    $0xc,%eax
 322:	cd 40                	int    $0x40
 324:	c3                   	ret    

00000325 <sleep>:
SYSCALL(sleep)
 325:	b8 0d 00 00 00       	mov    $0xd,%eax
 32a:	cd 40                	int    $0x40
 32c:	c3                   	ret    

0000032d <uptime>:
SYSCALL(uptime)
 32d:	b8 0e 00 00 00       	mov    $0xe,%eax
 332:	cd 40                	int    $0x40
 334:	c3                   	ret    

00000335 <setpri>:
SYSCALL(setpri)
 335:	b8 16 00 00 00       	mov    $0x16,%eax
 33a:	cd 40                	int    $0x40
 33c:	c3                   	ret    

0000033d <getpri>:
SYSCALL(getpri)
 33d:	b8 17 00 00 00       	mov    $0x17,%eax
 342:	cd 40                	int    $0x40
 344:	c3                   	ret    

00000345 <fork2>:
SYSCALL(fork2)
 345:	b8 18 00 00 00       	mov    $0x18,%eax
 34a:	cd 40                	int    $0x40
 34c:	c3                   	ret    

0000034d <getpinfo>:
SYSCALL(getpinfo)
 34d:	b8 19 00 00 00       	mov    $0x19,%eax
 352:	cd 40                	int    $0x40
 354:	c3                   	ret    

00000355 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 355:	55                   	push   %ebp
 356:	89 e5                	mov    %esp,%ebp
 358:	83 ec 1c             	sub    $0x1c,%esp
 35b:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 35e:	6a 01                	push   $0x1
 360:	8d 55 f4             	lea    -0xc(%ebp),%edx
 363:	52                   	push   %edx
 364:	50                   	push   %eax
 365:	e8 4b ff ff ff       	call   2b5 <write>
}
 36a:	83 c4 10             	add    $0x10,%esp
 36d:	c9                   	leave  
 36e:	c3                   	ret    

0000036f <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 36f:	55                   	push   %ebp
 370:	89 e5                	mov    %esp,%ebp
 372:	57                   	push   %edi
 373:	56                   	push   %esi
 374:	53                   	push   %ebx
 375:	83 ec 2c             	sub    $0x2c,%esp
 378:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 37a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 37e:	0f 95 c3             	setne  %bl
 381:	89 d0                	mov    %edx,%eax
 383:	c1 e8 1f             	shr    $0x1f,%eax
 386:	84 c3                	test   %al,%bl
 388:	74 10                	je     39a <printint+0x2b>
    neg = 1;
    x = -xx;
 38a:	f7 da                	neg    %edx
    neg = 1;
 38c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 393:	be 00 00 00 00       	mov    $0x0,%esi
 398:	eb 0b                	jmp    3a5 <printint+0x36>
  neg = 0;
 39a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3a1:	eb f0                	jmp    393 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3a3:	89 c6                	mov    %eax,%esi
 3a5:	89 d0                	mov    %edx,%eax
 3a7:	ba 00 00 00 00       	mov    $0x0,%edx
 3ac:	f7 f1                	div    %ecx
 3ae:	89 c3                	mov    %eax,%ebx
 3b0:	8d 46 01             	lea    0x1(%esi),%eax
 3b3:	0f b6 92 38 07 00 00 	movzbl 0x738(%edx),%edx
 3ba:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3be:	89 da                	mov    %ebx,%edx
 3c0:	85 db                	test   %ebx,%ebx
 3c2:	75 df                	jne    3a3 <printint+0x34>
 3c4:	89 c3                	mov    %eax,%ebx
  if(neg)
 3c6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3ca:	74 16                	je     3e2 <printint+0x73>
    buf[i++] = '-';
 3cc:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3d1:	8d 5e 02             	lea    0x2(%esi),%ebx
 3d4:	eb 0c                	jmp    3e2 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3d6:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3db:	89 f8                	mov    %edi,%eax
 3dd:	e8 73 ff ff ff       	call   355 <putc>
  while(--i >= 0)
 3e2:	83 eb 01             	sub    $0x1,%ebx
 3e5:	79 ef                	jns    3d6 <printint+0x67>
}
 3e7:	83 c4 2c             	add    $0x2c,%esp
 3ea:	5b                   	pop    %ebx
 3eb:	5e                   	pop    %esi
 3ec:	5f                   	pop    %edi
 3ed:	5d                   	pop    %ebp
 3ee:	c3                   	ret    

000003ef <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3ef:	55                   	push   %ebp
 3f0:	89 e5                	mov    %esp,%ebp
 3f2:	57                   	push   %edi
 3f3:	56                   	push   %esi
 3f4:	53                   	push   %ebx
 3f5:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3f8:	8d 45 10             	lea    0x10(%ebp),%eax
 3fb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3fe:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 403:	bb 00 00 00 00       	mov    $0x0,%ebx
 408:	eb 14                	jmp    41e <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 40a:	89 fa                	mov    %edi,%edx
 40c:	8b 45 08             	mov    0x8(%ebp),%eax
 40f:	e8 41 ff ff ff       	call   355 <putc>
 414:	eb 05                	jmp    41b <printf+0x2c>
      }
    } else if(state == '%'){
 416:	83 fe 25             	cmp    $0x25,%esi
 419:	74 25                	je     440 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 41b:	83 c3 01             	add    $0x1,%ebx
 41e:	8b 45 0c             	mov    0xc(%ebp),%eax
 421:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 425:	84 c0                	test   %al,%al
 427:	0f 84 23 01 00 00    	je     550 <printf+0x161>
    c = fmt[i] & 0xff;
 42d:	0f be f8             	movsbl %al,%edi
 430:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 433:	85 f6                	test   %esi,%esi
 435:	75 df                	jne    416 <printf+0x27>
      if(c == '%'){
 437:	83 f8 25             	cmp    $0x25,%eax
 43a:	75 ce                	jne    40a <printf+0x1b>
        state = '%';
 43c:	89 c6                	mov    %eax,%esi
 43e:	eb db                	jmp    41b <printf+0x2c>
      if(c == 'd'){
 440:	83 f8 64             	cmp    $0x64,%eax
 443:	74 49                	je     48e <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 445:	83 f8 78             	cmp    $0x78,%eax
 448:	0f 94 c1             	sete   %cl
 44b:	83 f8 70             	cmp    $0x70,%eax
 44e:	0f 94 c2             	sete   %dl
 451:	08 d1                	or     %dl,%cl
 453:	75 63                	jne    4b8 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 455:	83 f8 73             	cmp    $0x73,%eax
 458:	0f 84 84 00 00 00    	je     4e2 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 45e:	83 f8 63             	cmp    $0x63,%eax
 461:	0f 84 b7 00 00 00    	je     51e <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 467:	83 f8 25             	cmp    $0x25,%eax
 46a:	0f 84 cc 00 00 00    	je     53c <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 470:	ba 25 00 00 00       	mov    $0x25,%edx
 475:	8b 45 08             	mov    0x8(%ebp),%eax
 478:	e8 d8 fe ff ff       	call   355 <putc>
        putc(fd, c);
 47d:	89 fa                	mov    %edi,%edx
 47f:	8b 45 08             	mov    0x8(%ebp),%eax
 482:	e8 ce fe ff ff       	call   355 <putc>
      }
      state = 0;
 487:	be 00 00 00 00       	mov    $0x0,%esi
 48c:	eb 8d                	jmp    41b <printf+0x2c>
        printint(fd, *ap, 10, 1);
 48e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 491:	8b 17                	mov    (%edi),%edx
 493:	83 ec 0c             	sub    $0xc,%esp
 496:	6a 01                	push   $0x1
 498:	b9 0a 00 00 00       	mov    $0xa,%ecx
 49d:	8b 45 08             	mov    0x8(%ebp),%eax
 4a0:	e8 ca fe ff ff       	call   36f <printint>
        ap++;
 4a5:	83 c7 04             	add    $0x4,%edi
 4a8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4ab:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4ae:	be 00 00 00 00       	mov    $0x0,%esi
 4b3:	e9 63 ff ff ff       	jmp    41b <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4bb:	8b 17                	mov    (%edi),%edx
 4bd:	83 ec 0c             	sub    $0xc,%esp
 4c0:	6a 00                	push   $0x0
 4c2:	b9 10 00 00 00       	mov    $0x10,%ecx
 4c7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ca:	e8 a0 fe ff ff       	call   36f <printint>
        ap++;
 4cf:	83 c7 04             	add    $0x4,%edi
 4d2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4d5:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4d8:	be 00 00 00 00       	mov    $0x0,%esi
 4dd:	e9 39 ff ff ff       	jmp    41b <printf+0x2c>
        s = (char*)*ap;
 4e2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4e5:	8b 30                	mov    (%eax),%esi
        ap++;
 4e7:	83 c0 04             	add    $0x4,%eax
 4ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4ed:	85 f6                	test   %esi,%esi
 4ef:	75 28                	jne    519 <printf+0x12a>
          s = "(null)";
 4f1:	be 30 07 00 00       	mov    $0x730,%esi
 4f6:	8b 7d 08             	mov    0x8(%ebp),%edi
 4f9:	eb 0d                	jmp    508 <printf+0x119>
          putc(fd, *s);
 4fb:	0f be d2             	movsbl %dl,%edx
 4fe:	89 f8                	mov    %edi,%eax
 500:	e8 50 fe ff ff       	call   355 <putc>
          s++;
 505:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 508:	0f b6 16             	movzbl (%esi),%edx
 50b:	84 d2                	test   %dl,%dl
 50d:	75 ec                	jne    4fb <printf+0x10c>
      state = 0;
 50f:	be 00 00 00 00       	mov    $0x0,%esi
 514:	e9 02 ff ff ff       	jmp    41b <printf+0x2c>
 519:	8b 7d 08             	mov    0x8(%ebp),%edi
 51c:	eb ea                	jmp    508 <printf+0x119>
        putc(fd, *ap);
 51e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 521:	0f be 17             	movsbl (%edi),%edx
 524:	8b 45 08             	mov    0x8(%ebp),%eax
 527:	e8 29 fe ff ff       	call   355 <putc>
        ap++;
 52c:	83 c7 04             	add    $0x4,%edi
 52f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 532:	be 00 00 00 00       	mov    $0x0,%esi
 537:	e9 df fe ff ff       	jmp    41b <printf+0x2c>
        putc(fd, c);
 53c:	89 fa                	mov    %edi,%edx
 53e:	8b 45 08             	mov    0x8(%ebp),%eax
 541:	e8 0f fe ff ff       	call   355 <putc>
      state = 0;
 546:	be 00 00 00 00       	mov    $0x0,%esi
 54b:	e9 cb fe ff ff       	jmp    41b <printf+0x2c>
    }
  }
}
 550:	8d 65 f4             	lea    -0xc(%ebp),%esp
 553:	5b                   	pop    %ebx
 554:	5e                   	pop    %esi
 555:	5f                   	pop    %edi
 556:	5d                   	pop    %ebp
 557:	c3                   	ret    

00000558 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 558:	55                   	push   %ebp
 559:	89 e5                	mov    %esp,%ebp
 55b:	57                   	push   %edi
 55c:	56                   	push   %esi
 55d:	53                   	push   %ebx
 55e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 561:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 564:	a1 dc 09 00 00       	mov    0x9dc,%eax
 569:	eb 02                	jmp    56d <free+0x15>
 56b:	89 d0                	mov    %edx,%eax
 56d:	39 c8                	cmp    %ecx,%eax
 56f:	73 04                	jae    575 <free+0x1d>
 571:	39 08                	cmp    %ecx,(%eax)
 573:	77 12                	ja     587 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 575:	8b 10                	mov    (%eax),%edx
 577:	39 c2                	cmp    %eax,%edx
 579:	77 f0                	ja     56b <free+0x13>
 57b:	39 c8                	cmp    %ecx,%eax
 57d:	72 08                	jb     587 <free+0x2f>
 57f:	39 ca                	cmp    %ecx,%edx
 581:	77 04                	ja     587 <free+0x2f>
 583:	89 d0                	mov    %edx,%eax
 585:	eb e6                	jmp    56d <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 587:	8b 73 fc             	mov    -0x4(%ebx),%esi
 58a:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 58d:	8b 10                	mov    (%eax),%edx
 58f:	39 d7                	cmp    %edx,%edi
 591:	74 19                	je     5ac <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 593:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 596:	8b 50 04             	mov    0x4(%eax),%edx
 599:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 59c:	39 ce                	cmp    %ecx,%esi
 59e:	74 1b                	je     5bb <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5a0:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5a2:	a3 dc 09 00 00       	mov    %eax,0x9dc
}
 5a7:	5b                   	pop    %ebx
 5a8:	5e                   	pop    %esi
 5a9:	5f                   	pop    %edi
 5aa:	5d                   	pop    %ebp
 5ab:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5ac:	03 72 04             	add    0x4(%edx),%esi
 5af:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5b2:	8b 10                	mov    (%eax),%edx
 5b4:	8b 12                	mov    (%edx),%edx
 5b6:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5b9:	eb db                	jmp    596 <free+0x3e>
    p->s.size += bp->s.size;
 5bb:	03 53 fc             	add    -0x4(%ebx),%edx
 5be:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5c1:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5c4:	89 10                	mov    %edx,(%eax)
 5c6:	eb da                	jmp    5a2 <free+0x4a>

000005c8 <morecore>:

static Header*
morecore(uint nu)
{
 5c8:	55                   	push   %ebp
 5c9:	89 e5                	mov    %esp,%ebp
 5cb:	53                   	push   %ebx
 5cc:	83 ec 04             	sub    $0x4,%esp
 5cf:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5d1:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5d6:	77 05                	ja     5dd <morecore+0x15>
    nu = 4096;
 5d8:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5dd:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5e4:	83 ec 0c             	sub    $0xc,%esp
 5e7:	50                   	push   %eax
 5e8:	e8 30 fd ff ff       	call   31d <sbrk>
  if(p == (char*)-1)
 5ed:	83 c4 10             	add    $0x10,%esp
 5f0:	83 f8 ff             	cmp    $0xffffffff,%eax
 5f3:	74 1c                	je     611 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5f5:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5f8:	83 c0 08             	add    $0x8,%eax
 5fb:	83 ec 0c             	sub    $0xc,%esp
 5fe:	50                   	push   %eax
 5ff:	e8 54 ff ff ff       	call   558 <free>
  return freep;
 604:	a1 dc 09 00 00       	mov    0x9dc,%eax
 609:	83 c4 10             	add    $0x10,%esp
}
 60c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 60f:	c9                   	leave  
 610:	c3                   	ret    
    return 0;
 611:	b8 00 00 00 00       	mov    $0x0,%eax
 616:	eb f4                	jmp    60c <morecore+0x44>

00000618 <malloc>:

void*
malloc(uint nbytes)
{
 618:	55                   	push   %ebp
 619:	89 e5                	mov    %esp,%ebp
 61b:	53                   	push   %ebx
 61c:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 61f:	8b 45 08             	mov    0x8(%ebp),%eax
 622:	8d 58 07             	lea    0x7(%eax),%ebx
 625:	c1 eb 03             	shr    $0x3,%ebx
 628:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 62b:	8b 0d dc 09 00 00    	mov    0x9dc,%ecx
 631:	85 c9                	test   %ecx,%ecx
 633:	74 04                	je     639 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 635:	8b 01                	mov    (%ecx),%eax
 637:	eb 4d                	jmp    686 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 639:	c7 05 dc 09 00 00 e0 	movl   $0x9e0,0x9dc
 640:	09 00 00 
 643:	c7 05 e0 09 00 00 e0 	movl   $0x9e0,0x9e0
 64a:	09 00 00 
    base.s.size = 0;
 64d:	c7 05 e4 09 00 00 00 	movl   $0x0,0x9e4
 654:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 657:	b9 e0 09 00 00       	mov    $0x9e0,%ecx
 65c:	eb d7                	jmp    635 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 65e:	39 da                	cmp    %ebx,%edx
 660:	74 1a                	je     67c <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 662:	29 da                	sub    %ebx,%edx
 664:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 667:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 66a:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 66d:	89 0d dc 09 00 00    	mov    %ecx,0x9dc
      return (void*)(p + 1);
 673:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 676:	83 c4 04             	add    $0x4,%esp
 679:	5b                   	pop    %ebx
 67a:	5d                   	pop    %ebp
 67b:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 67c:	8b 10                	mov    (%eax),%edx
 67e:	89 11                	mov    %edx,(%ecx)
 680:	eb eb                	jmp    66d <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 682:	89 c1                	mov    %eax,%ecx
 684:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 686:	8b 50 04             	mov    0x4(%eax),%edx
 689:	39 da                	cmp    %ebx,%edx
 68b:	73 d1                	jae    65e <malloc+0x46>
    if(p == freep)
 68d:	39 05 dc 09 00 00    	cmp    %eax,0x9dc
 693:	75 ed                	jne    682 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 695:	89 d8                	mov    %ebx,%eax
 697:	e8 2c ff ff ff       	call   5c8 <morecore>
 69c:	85 c0                	test   %eax,%eax
 69e:	75 e2                	jne    682 <malloc+0x6a>
        return 0;
 6a0:	b8 00 00 00 00       	mov    $0x0,%eax
 6a5:	eb cf                	jmp    676 <malloc+0x5e>
