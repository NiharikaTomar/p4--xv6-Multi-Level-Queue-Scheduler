
_test_7:     file format elf32-i386


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
  11:	81 ec 24 0c 00 00    	sub    $0xc24,%esp
  struct pstat st;
  check(getpinfo(&st) == 0, "getpinfo");
  17:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  1d:	50                   	push   %eax
  1e:	e8 5f 03 00 00       	call   382 <getpinfo>
  23:	83 c4 10             	add    $0x10,%esp
  26:	85 c0                	test   %eax,%eax
  28:	75 39                	jne    63 <main+0x63>

  int i;
  int c_pid[2];
  c_pid[0] = -1;
  2a:	c7 85 e0 f3 ff ff ff 	movl   $0xffffffff,-0xc20(%ebp)
  31:	ff ff ff 
  c_pid[1] = -1;
  34:	c7 85 e4 f3 ff ff ff 	movl   $0xffffffff,-0xc1c(%ebp)
  3b:	ff ff ff 
  int c_pri[2];
  int c_newpri[2];
  c_newpri[0] = -1;
  3e:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
  c_newpri[1] = -1;
  43:	be ff ff ff ff       	mov    $0xffffffff,%esi
  c_pri[0] = 0;
  48:	c7 85 d8 f3 ff ff 00 	movl   $0x0,-0xc28(%ebp)
  4f:	00 00 00 
  c_pri[1] = 1;
  52:	c7 85 dc f3 ff ff 01 	movl   $0x1,-0xc24(%ebp)
  59:	00 00 00 
  for (i = 0; i < 2; i++) {
  5c:	bf 00 00 00 00       	mov    $0x0,%edi
  61:	eb 57                	jmp    ba <main+0xba>
  check(getpinfo(&st) == 0, "getpinfo");
  63:	83 ec 0c             	sub    $0xc,%esp
  66:	68 dc 06 00 00       	push   $0x6dc
  6b:	6a 17                	push   $0x17
  6d:	68 e5 06 00 00       	push   $0x6e5
  72:	68 08 07 00 00       	push   $0x708
  77:	6a 01                	push   $0x1
  79:	e8 a6 03 00 00       	call   424 <printf>
  7e:	83 c4 20             	add    $0x20,%esp
  81:	eb a7                	jmp    2a <main+0x2a>
    c_pid[i] = fork2(c_pri[i]);
   
    // Child
    if (c_pid[i] == 0) {
      exit();
  83:	e8 42 02 00 00       	call   2ca <exit>
    } else {
      getpinfo(&st);
      for(int j = 0; j < NPROC; j++){
	if(st.pid[j] == c_pid[0]){
	  c_newpri[0] = st.priority[j]; 
  88:	8b 9c 85 e8 f5 ff ff 	mov    -0xa18(%ebp,%eax,4),%ebx
      for(int j = 0; j < NPROC; j++){
  8f:	83 c0 01             	add    $0x1,%eax
  92:	83 f8 3f             	cmp    $0x3f,%eax
  95:	7f 20                	jg     b7 <main+0xb7>
	if(st.pid[j] == c_pid[0]){
  97:	8b 94 85 e8 f4 ff ff 	mov    -0xb18(%ebp,%eax,4),%edx
  9e:	3b 95 e0 f3 ff ff    	cmp    -0xc20(%ebp),%edx
  a4:	74 e2                	je     88 <main+0x88>
	} else if(st.pid[j] == c_pid[1]){
  a6:	3b 95 e4 f3 ff ff    	cmp    -0xc1c(%ebp),%edx
  ac:	75 e1                	jne    8f <main+0x8f>
	  c_newpri[1] = st.priority[j];
  ae:	8b b4 85 e8 f5 ff ff 	mov    -0xa18(%ebp,%eax,4),%esi
  b5:	eb d8                	jmp    8f <main+0x8f>
  for (i = 0; i < 2; i++) {
  b7:	83 c7 01             	add    $0x1,%edi
  ba:	83 ff 01             	cmp    $0x1,%edi
  bd:	7f 36                	jg     f5 <main+0xf5>
    c_pid[i] = fork2(c_pri[i]);
  bf:	83 ec 0c             	sub    $0xc,%esp
  c2:	ff b4 bd d8 f3 ff ff 	pushl  -0xc28(%ebp,%edi,4)
  c9:	e8 ac 02 00 00       	call   37a <fork2>
  ce:	89 84 bd e0 f3 ff ff 	mov    %eax,-0xc20(%ebp,%edi,4)
    if (c_pid[i] == 0) {
  d5:	83 c4 10             	add    $0x10,%esp
  d8:	85 c0                	test   %eax,%eax
  da:	74 a7                	je     83 <main+0x83>
      getpinfo(&st);
  dc:	83 ec 0c             	sub    $0xc,%esp
  df:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  e5:	50                   	push   %eax
  e6:	e8 97 02 00 00       	call   382 <getpinfo>
      for(int j = 0; j < NPROC; j++){
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	b8 00 00 00 00       	mov    $0x0,%eax
  f3:	eb 9d                	jmp    92 <main+0x92>
	}
      }
    }
  }

  if(c_newpri[0] == c_pri[0] && c_newpri[1] == c_pri[1]){
  f5:	85 db                	test   %ebx,%ebx
  f7:	75 05                	jne    fe <main+0xfe>
  f9:	83 fe 01             	cmp    $0x1,%esi
  fc:	74 26                	je     124 <main+0x124>
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  }else{
    printf(1, "XV6_SCHEDULER\t getpinfo FAILED to properly udpate process info\n");
  fe:	83 ec 08             	sub    $0x8,%esp
 101:	68 38 07 00 00       	push   $0x738
 106:	6a 01                	push   $0x1
 108:	e8 17 03 00 00       	call   424 <printf>
 10d:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 2; i++) {
 110:	bb 00 00 00 00       	mov    $0x0,%ebx
  }
  
  for (i = 0; i < 2; i++) {
 115:	83 fb 01             	cmp    $0x1,%ebx
 118:	7f 1e                	jg     138 <main+0x138>
    wait();
 11a:	e8 b3 01 00 00       	call   2d2 <wait>
  for (i = 0; i < 2; i++) {
 11f:	83 c3 01             	add    $0x1,%ebx
 122:	eb f1                	jmp    115 <main+0x115>
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
 124:	83 ec 08             	sub    $0x8,%esp
 127:	68 ee 06 00 00       	push   $0x6ee
 12c:	6a 01                	push   $0x1
 12e:	e8 f1 02 00 00       	call   424 <printf>
 133:	83 c4 10             	add    $0x10,%esp
 136:	eb d8                	jmp    110 <main+0x110>
  }


  exit();
 138:	e8 8d 01 00 00       	call   2ca <exit>

0000013d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 13d:	55                   	push   %ebp
 13e:	89 e5                	mov    %esp,%ebp
 140:	53                   	push   %ebx
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 147:	89 c2                	mov    %eax,%edx
 149:	0f b6 19             	movzbl (%ecx),%ebx
 14c:	88 1a                	mov    %bl,(%edx)
 14e:	8d 52 01             	lea    0x1(%edx),%edx
 151:	8d 49 01             	lea    0x1(%ecx),%ecx
 154:	84 db                	test   %bl,%bl
 156:	75 f1                	jne    149 <strcpy+0xc>
    ;
  return os;
}
 158:	5b                   	pop    %ebx
 159:	5d                   	pop    %ebp
 15a:	c3                   	ret    

0000015b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 15b:	55                   	push   %ebp
 15c:	89 e5                	mov    %esp,%ebp
 15e:	8b 4d 08             	mov    0x8(%ebp),%ecx
 161:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 164:	eb 06                	jmp    16c <strcmp+0x11>
    p++, q++;
 166:	83 c1 01             	add    $0x1,%ecx
 169:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 16c:	0f b6 01             	movzbl (%ecx),%eax
 16f:	84 c0                	test   %al,%al
 171:	74 04                	je     177 <strcmp+0x1c>
 173:	3a 02                	cmp    (%edx),%al
 175:	74 ef                	je     166 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 177:	0f b6 c0             	movzbl %al,%eax
 17a:	0f b6 12             	movzbl (%edx),%edx
 17d:	29 d0                	sub    %edx,%eax
}
 17f:	5d                   	pop    %ebp
 180:	c3                   	ret    

00000181 <strlen>:

uint
strlen(const char *s)
{
 181:	55                   	push   %ebp
 182:	89 e5                	mov    %esp,%ebp
 184:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 187:	ba 00 00 00 00       	mov    $0x0,%edx
 18c:	eb 03                	jmp    191 <strlen+0x10>
 18e:	83 c2 01             	add    $0x1,%edx
 191:	89 d0                	mov    %edx,%eax
 193:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 197:	75 f5                	jne    18e <strlen+0xd>
    ;
  return n;
}
 199:	5d                   	pop    %ebp
 19a:	c3                   	ret    

0000019b <memset>:

void*
memset(void *dst, int c, uint n)
{
 19b:	55                   	push   %ebp
 19c:	89 e5                	mov    %esp,%ebp
 19e:	57                   	push   %edi
 19f:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1a2:	89 d7                	mov    %edx,%edi
 1a4:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 1aa:	fc                   	cld    
 1ab:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1ad:	89 d0                	mov    %edx,%eax
 1af:	5f                   	pop    %edi
 1b0:	5d                   	pop    %ebp
 1b1:	c3                   	ret    

000001b2 <strchr>:

char*
strchr(const char *s, char c)
{
 1b2:	55                   	push   %ebp
 1b3:	89 e5                	mov    %esp,%ebp
 1b5:	8b 45 08             	mov    0x8(%ebp),%eax
 1b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1bc:	0f b6 10             	movzbl (%eax),%edx
 1bf:	84 d2                	test   %dl,%dl
 1c1:	74 09                	je     1cc <strchr+0x1a>
    if(*s == c)
 1c3:	38 ca                	cmp    %cl,%dl
 1c5:	74 0a                	je     1d1 <strchr+0x1f>
  for(; *s; s++)
 1c7:	83 c0 01             	add    $0x1,%eax
 1ca:	eb f0                	jmp    1bc <strchr+0xa>
      return (char*)s;
  return 0;
 1cc:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1d1:	5d                   	pop    %ebp
 1d2:	c3                   	ret    

000001d3 <gets>:

char*
gets(char *buf, int max)
{
 1d3:	55                   	push   %ebp
 1d4:	89 e5                	mov    %esp,%ebp
 1d6:	57                   	push   %edi
 1d7:	56                   	push   %esi
 1d8:	53                   	push   %ebx
 1d9:	83 ec 1c             	sub    $0x1c,%esp
 1dc:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1df:	bb 00 00 00 00       	mov    $0x0,%ebx
 1e4:	8d 73 01             	lea    0x1(%ebx),%esi
 1e7:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1ea:	7d 2e                	jge    21a <gets+0x47>
    cc = read(0, &c, 1);
 1ec:	83 ec 04             	sub    $0x4,%esp
 1ef:	6a 01                	push   $0x1
 1f1:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1f4:	50                   	push   %eax
 1f5:	6a 00                	push   $0x0
 1f7:	e8 e6 00 00 00       	call   2e2 <read>
    if(cc < 1)
 1fc:	83 c4 10             	add    $0x10,%esp
 1ff:	85 c0                	test   %eax,%eax
 201:	7e 17                	jle    21a <gets+0x47>
      break;
    buf[i++] = c;
 203:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 207:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 20a:	3c 0a                	cmp    $0xa,%al
 20c:	0f 94 c2             	sete   %dl
 20f:	3c 0d                	cmp    $0xd,%al
 211:	0f 94 c0             	sete   %al
    buf[i++] = c;
 214:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 216:	08 c2                	or     %al,%dl
 218:	74 ca                	je     1e4 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 21a:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 21e:	89 f8                	mov    %edi,%eax
 220:	8d 65 f4             	lea    -0xc(%ebp),%esp
 223:	5b                   	pop    %ebx
 224:	5e                   	pop    %esi
 225:	5f                   	pop    %edi
 226:	5d                   	pop    %ebp
 227:	c3                   	ret    

00000228 <stat>:

int
stat(const char *n, struct stat *st)
{
 228:	55                   	push   %ebp
 229:	89 e5                	mov    %esp,%ebp
 22b:	56                   	push   %esi
 22c:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22d:	83 ec 08             	sub    $0x8,%esp
 230:	6a 00                	push   $0x0
 232:	ff 75 08             	pushl  0x8(%ebp)
 235:	e8 d0 00 00 00       	call   30a <open>
  if(fd < 0)
 23a:	83 c4 10             	add    $0x10,%esp
 23d:	85 c0                	test   %eax,%eax
 23f:	78 24                	js     265 <stat+0x3d>
 241:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 243:	83 ec 08             	sub    $0x8,%esp
 246:	ff 75 0c             	pushl  0xc(%ebp)
 249:	50                   	push   %eax
 24a:	e8 d3 00 00 00       	call   322 <fstat>
 24f:	89 c6                	mov    %eax,%esi
  close(fd);
 251:	89 1c 24             	mov    %ebx,(%esp)
 254:	e8 99 00 00 00       	call   2f2 <close>
  return r;
 259:	83 c4 10             	add    $0x10,%esp
}
 25c:	89 f0                	mov    %esi,%eax
 25e:	8d 65 f8             	lea    -0x8(%ebp),%esp
 261:	5b                   	pop    %ebx
 262:	5e                   	pop    %esi
 263:	5d                   	pop    %ebp
 264:	c3                   	ret    
    return -1;
 265:	be ff ff ff ff       	mov    $0xffffffff,%esi
 26a:	eb f0                	jmp    25c <stat+0x34>

0000026c <atoi>:

int
atoi(const char *s)
{
 26c:	55                   	push   %ebp
 26d:	89 e5                	mov    %esp,%ebp
 26f:	53                   	push   %ebx
 270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 273:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 278:	eb 10                	jmp    28a <atoi+0x1e>
    n = n*10 + *s++ - '0';
 27a:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 27d:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 280:	83 c1 01             	add    $0x1,%ecx
 283:	0f be d2             	movsbl %dl,%edx
 286:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 28a:	0f b6 11             	movzbl (%ecx),%edx
 28d:	8d 5a d0             	lea    -0x30(%edx),%ebx
 290:	80 fb 09             	cmp    $0x9,%bl
 293:	76 e5                	jbe    27a <atoi+0xe>
  return n;
}
 295:	5b                   	pop    %ebx
 296:	5d                   	pop    %ebp
 297:	c3                   	ret    

00000298 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 298:	55                   	push   %ebp
 299:	89 e5                	mov    %esp,%ebp
 29b:	56                   	push   %esi
 29c:	53                   	push   %ebx
 29d:	8b 45 08             	mov    0x8(%ebp),%eax
 2a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2a3:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2a6:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2a8:	eb 0d                	jmp    2b7 <memmove+0x1f>
    *dst++ = *src++;
 2aa:	0f b6 13             	movzbl (%ebx),%edx
 2ad:	88 11                	mov    %dl,(%ecx)
 2af:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2b2:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2b5:	89 f2                	mov    %esi,%edx
 2b7:	8d 72 ff             	lea    -0x1(%edx),%esi
 2ba:	85 d2                	test   %edx,%edx
 2bc:	7f ec                	jg     2aa <memmove+0x12>
  return vdst;
}
 2be:	5b                   	pop    %ebx
 2bf:	5e                   	pop    %esi
 2c0:	5d                   	pop    %ebp
 2c1:	c3                   	ret    

000002c2 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c2:	b8 01 00 00 00       	mov    $0x1,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <exit>:
SYSCALL(exit)
 2ca:	b8 02 00 00 00       	mov    $0x2,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <wait>:
SYSCALL(wait)
 2d2:	b8 03 00 00 00       	mov    $0x3,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <pipe>:
SYSCALL(pipe)
 2da:	b8 04 00 00 00       	mov    $0x4,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <read>:
SYSCALL(read)
 2e2:	b8 05 00 00 00       	mov    $0x5,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <write>:
SYSCALL(write)
 2ea:	b8 10 00 00 00       	mov    $0x10,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <close>:
SYSCALL(close)
 2f2:	b8 15 00 00 00       	mov    $0x15,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <kill>:
SYSCALL(kill)
 2fa:	b8 06 00 00 00       	mov    $0x6,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <exec>:
SYSCALL(exec)
 302:	b8 07 00 00 00       	mov    $0x7,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <open>:
SYSCALL(open)
 30a:	b8 0f 00 00 00       	mov    $0xf,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <mknod>:
SYSCALL(mknod)
 312:	b8 11 00 00 00       	mov    $0x11,%eax
 317:	cd 40                	int    $0x40
 319:	c3                   	ret    

0000031a <unlink>:
SYSCALL(unlink)
 31a:	b8 12 00 00 00       	mov    $0x12,%eax
 31f:	cd 40                	int    $0x40
 321:	c3                   	ret    

00000322 <fstat>:
SYSCALL(fstat)
 322:	b8 08 00 00 00       	mov    $0x8,%eax
 327:	cd 40                	int    $0x40
 329:	c3                   	ret    

0000032a <link>:
SYSCALL(link)
 32a:	b8 13 00 00 00       	mov    $0x13,%eax
 32f:	cd 40                	int    $0x40
 331:	c3                   	ret    

00000332 <mkdir>:
SYSCALL(mkdir)
 332:	b8 14 00 00 00       	mov    $0x14,%eax
 337:	cd 40                	int    $0x40
 339:	c3                   	ret    

0000033a <chdir>:
SYSCALL(chdir)
 33a:	b8 09 00 00 00       	mov    $0x9,%eax
 33f:	cd 40                	int    $0x40
 341:	c3                   	ret    

00000342 <dup>:
SYSCALL(dup)
 342:	b8 0a 00 00 00       	mov    $0xa,%eax
 347:	cd 40                	int    $0x40
 349:	c3                   	ret    

0000034a <getpid>:
SYSCALL(getpid)
 34a:	b8 0b 00 00 00       	mov    $0xb,%eax
 34f:	cd 40                	int    $0x40
 351:	c3                   	ret    

00000352 <sbrk>:
SYSCALL(sbrk)
 352:	b8 0c 00 00 00       	mov    $0xc,%eax
 357:	cd 40                	int    $0x40
 359:	c3                   	ret    

0000035a <sleep>:
SYSCALL(sleep)
 35a:	b8 0d 00 00 00       	mov    $0xd,%eax
 35f:	cd 40                	int    $0x40
 361:	c3                   	ret    

00000362 <uptime>:
SYSCALL(uptime)
 362:	b8 0e 00 00 00       	mov    $0xe,%eax
 367:	cd 40                	int    $0x40
 369:	c3                   	ret    

0000036a <setpri>:
SYSCALL(setpri)
 36a:	b8 16 00 00 00       	mov    $0x16,%eax
 36f:	cd 40                	int    $0x40
 371:	c3                   	ret    

00000372 <getpri>:
SYSCALL(getpri)
 372:	b8 17 00 00 00       	mov    $0x17,%eax
 377:	cd 40                	int    $0x40
 379:	c3                   	ret    

0000037a <fork2>:
SYSCALL(fork2)
 37a:	b8 18 00 00 00       	mov    $0x18,%eax
 37f:	cd 40                	int    $0x40
 381:	c3                   	ret    

00000382 <getpinfo>:
SYSCALL(getpinfo)
 382:	b8 19 00 00 00       	mov    $0x19,%eax
 387:	cd 40                	int    $0x40
 389:	c3                   	ret    

0000038a <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 38a:	55                   	push   %ebp
 38b:	89 e5                	mov    %esp,%ebp
 38d:	83 ec 1c             	sub    $0x1c,%esp
 390:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 393:	6a 01                	push   $0x1
 395:	8d 55 f4             	lea    -0xc(%ebp),%edx
 398:	52                   	push   %edx
 399:	50                   	push   %eax
 39a:	e8 4b ff ff ff       	call   2ea <write>
}
 39f:	83 c4 10             	add    $0x10,%esp
 3a2:	c9                   	leave  
 3a3:	c3                   	ret    

000003a4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3a4:	55                   	push   %ebp
 3a5:	89 e5                	mov    %esp,%ebp
 3a7:	57                   	push   %edi
 3a8:	56                   	push   %esi
 3a9:	53                   	push   %ebx
 3aa:	83 ec 2c             	sub    $0x2c,%esp
 3ad:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3af:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3b3:	0f 95 c3             	setne  %bl
 3b6:	89 d0                	mov    %edx,%eax
 3b8:	c1 e8 1f             	shr    $0x1f,%eax
 3bb:	84 c3                	test   %al,%bl
 3bd:	74 10                	je     3cf <printint+0x2b>
    neg = 1;
    x = -xx;
 3bf:	f7 da                	neg    %edx
    neg = 1;
 3c1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3c8:	be 00 00 00 00       	mov    $0x0,%esi
 3cd:	eb 0b                	jmp    3da <printint+0x36>
  neg = 0;
 3cf:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 3d6:	eb f0                	jmp    3c8 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 3d8:	89 c6                	mov    %eax,%esi
 3da:	89 d0                	mov    %edx,%eax
 3dc:	ba 00 00 00 00       	mov    $0x0,%edx
 3e1:	f7 f1                	div    %ecx
 3e3:	89 c3                	mov    %eax,%ebx
 3e5:	8d 46 01             	lea    0x1(%esi),%eax
 3e8:	0f b6 92 80 07 00 00 	movzbl 0x780(%edx),%edx
 3ef:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 3f3:	89 da                	mov    %ebx,%edx
 3f5:	85 db                	test   %ebx,%ebx
 3f7:	75 df                	jne    3d8 <printint+0x34>
 3f9:	89 c3                	mov    %eax,%ebx
  if(neg)
 3fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3ff:	74 16                	je     417 <printint+0x73>
    buf[i++] = '-';
 401:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 406:	8d 5e 02             	lea    0x2(%esi),%ebx
 409:	eb 0c                	jmp    417 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 40b:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 410:	89 f8                	mov    %edi,%eax
 412:	e8 73 ff ff ff       	call   38a <putc>
  while(--i >= 0)
 417:	83 eb 01             	sub    $0x1,%ebx
 41a:	79 ef                	jns    40b <printint+0x67>
}
 41c:	83 c4 2c             	add    $0x2c,%esp
 41f:	5b                   	pop    %ebx
 420:	5e                   	pop    %esi
 421:	5f                   	pop    %edi
 422:	5d                   	pop    %ebp
 423:	c3                   	ret    

00000424 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	57                   	push   %edi
 428:	56                   	push   %esi
 429:	53                   	push   %ebx
 42a:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 42d:	8d 45 10             	lea    0x10(%ebp),%eax
 430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 433:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 438:	bb 00 00 00 00       	mov    $0x0,%ebx
 43d:	eb 14                	jmp    453 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 43f:	89 fa                	mov    %edi,%edx
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	e8 41 ff ff ff       	call   38a <putc>
 449:	eb 05                	jmp    450 <printf+0x2c>
      }
    } else if(state == '%'){
 44b:	83 fe 25             	cmp    $0x25,%esi
 44e:	74 25                	je     475 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 450:	83 c3 01             	add    $0x1,%ebx
 453:	8b 45 0c             	mov    0xc(%ebp),%eax
 456:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 45a:	84 c0                	test   %al,%al
 45c:	0f 84 23 01 00 00    	je     585 <printf+0x161>
    c = fmt[i] & 0xff;
 462:	0f be f8             	movsbl %al,%edi
 465:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 468:	85 f6                	test   %esi,%esi
 46a:	75 df                	jne    44b <printf+0x27>
      if(c == '%'){
 46c:	83 f8 25             	cmp    $0x25,%eax
 46f:	75 ce                	jne    43f <printf+0x1b>
        state = '%';
 471:	89 c6                	mov    %eax,%esi
 473:	eb db                	jmp    450 <printf+0x2c>
      if(c == 'd'){
 475:	83 f8 64             	cmp    $0x64,%eax
 478:	74 49                	je     4c3 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 47a:	83 f8 78             	cmp    $0x78,%eax
 47d:	0f 94 c1             	sete   %cl
 480:	83 f8 70             	cmp    $0x70,%eax
 483:	0f 94 c2             	sete   %dl
 486:	08 d1                	or     %dl,%cl
 488:	75 63                	jne    4ed <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 48a:	83 f8 73             	cmp    $0x73,%eax
 48d:	0f 84 84 00 00 00    	je     517 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 493:	83 f8 63             	cmp    $0x63,%eax
 496:	0f 84 b7 00 00 00    	je     553 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 49c:	83 f8 25             	cmp    $0x25,%eax
 49f:	0f 84 cc 00 00 00    	je     571 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4a5:	ba 25 00 00 00       	mov    $0x25,%edx
 4aa:	8b 45 08             	mov    0x8(%ebp),%eax
 4ad:	e8 d8 fe ff ff       	call   38a <putc>
        putc(fd, c);
 4b2:	89 fa                	mov    %edi,%edx
 4b4:	8b 45 08             	mov    0x8(%ebp),%eax
 4b7:	e8 ce fe ff ff       	call   38a <putc>
      }
      state = 0;
 4bc:	be 00 00 00 00       	mov    $0x0,%esi
 4c1:	eb 8d                	jmp    450 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4c6:	8b 17                	mov    (%edi),%edx
 4c8:	83 ec 0c             	sub    $0xc,%esp
 4cb:	6a 01                	push   $0x1
 4cd:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4d2:	8b 45 08             	mov    0x8(%ebp),%eax
 4d5:	e8 ca fe ff ff       	call   3a4 <printint>
        ap++;
 4da:	83 c7 04             	add    $0x4,%edi
 4dd:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4e0:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4e3:	be 00 00 00 00       	mov    $0x0,%esi
 4e8:	e9 63 ff ff ff       	jmp    450 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 4ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4f0:	8b 17                	mov    (%edi),%edx
 4f2:	83 ec 0c             	sub    $0xc,%esp
 4f5:	6a 00                	push   $0x0
 4f7:	b9 10 00 00 00       	mov    $0x10,%ecx
 4fc:	8b 45 08             	mov    0x8(%ebp),%eax
 4ff:	e8 a0 fe ff ff       	call   3a4 <printint>
        ap++;
 504:	83 c7 04             	add    $0x4,%edi
 507:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 50a:	83 c4 10             	add    $0x10,%esp
      state = 0;
 50d:	be 00 00 00 00       	mov    $0x0,%esi
 512:	e9 39 ff ff ff       	jmp    450 <printf+0x2c>
        s = (char*)*ap;
 517:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 51a:	8b 30                	mov    (%eax),%esi
        ap++;
 51c:	83 c0 04             	add    $0x4,%eax
 51f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 522:	85 f6                	test   %esi,%esi
 524:	75 28                	jne    54e <printf+0x12a>
          s = "(null)";
 526:	be 78 07 00 00       	mov    $0x778,%esi
 52b:	8b 7d 08             	mov    0x8(%ebp),%edi
 52e:	eb 0d                	jmp    53d <printf+0x119>
          putc(fd, *s);
 530:	0f be d2             	movsbl %dl,%edx
 533:	89 f8                	mov    %edi,%eax
 535:	e8 50 fe ff ff       	call   38a <putc>
          s++;
 53a:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 53d:	0f b6 16             	movzbl (%esi),%edx
 540:	84 d2                	test   %dl,%dl
 542:	75 ec                	jne    530 <printf+0x10c>
      state = 0;
 544:	be 00 00 00 00       	mov    $0x0,%esi
 549:	e9 02 ff ff ff       	jmp    450 <printf+0x2c>
 54e:	8b 7d 08             	mov    0x8(%ebp),%edi
 551:	eb ea                	jmp    53d <printf+0x119>
        putc(fd, *ap);
 553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 556:	0f be 17             	movsbl (%edi),%edx
 559:	8b 45 08             	mov    0x8(%ebp),%eax
 55c:	e8 29 fe ff ff       	call   38a <putc>
        ap++;
 561:	83 c7 04             	add    $0x4,%edi
 564:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 567:	be 00 00 00 00       	mov    $0x0,%esi
 56c:	e9 df fe ff ff       	jmp    450 <printf+0x2c>
        putc(fd, c);
 571:	89 fa                	mov    %edi,%edx
 573:	8b 45 08             	mov    0x8(%ebp),%eax
 576:	e8 0f fe ff ff       	call   38a <putc>
      state = 0;
 57b:	be 00 00 00 00       	mov    $0x0,%esi
 580:	e9 cb fe ff ff       	jmp    450 <printf+0x2c>
    }
  }
}
 585:	8d 65 f4             	lea    -0xc(%ebp),%esp
 588:	5b                   	pop    %ebx
 589:	5e                   	pop    %esi
 58a:	5f                   	pop    %edi
 58b:	5d                   	pop    %ebp
 58c:	c3                   	ret    

0000058d <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 58d:	55                   	push   %ebp
 58e:	89 e5                	mov    %esp,%ebp
 590:	57                   	push   %edi
 591:	56                   	push   %esi
 592:	53                   	push   %ebx
 593:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 596:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 599:	a1 24 0a 00 00       	mov    0xa24,%eax
 59e:	eb 02                	jmp    5a2 <free+0x15>
 5a0:	89 d0                	mov    %edx,%eax
 5a2:	39 c8                	cmp    %ecx,%eax
 5a4:	73 04                	jae    5aa <free+0x1d>
 5a6:	39 08                	cmp    %ecx,(%eax)
 5a8:	77 12                	ja     5bc <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5aa:	8b 10                	mov    (%eax),%edx
 5ac:	39 c2                	cmp    %eax,%edx
 5ae:	77 f0                	ja     5a0 <free+0x13>
 5b0:	39 c8                	cmp    %ecx,%eax
 5b2:	72 08                	jb     5bc <free+0x2f>
 5b4:	39 ca                	cmp    %ecx,%edx
 5b6:	77 04                	ja     5bc <free+0x2f>
 5b8:	89 d0                	mov    %edx,%eax
 5ba:	eb e6                	jmp    5a2 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5bc:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5bf:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5c2:	8b 10                	mov    (%eax),%edx
 5c4:	39 d7                	cmp    %edx,%edi
 5c6:	74 19                	je     5e1 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5c8:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5cb:	8b 50 04             	mov    0x4(%eax),%edx
 5ce:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5d1:	39 ce                	cmp    %ecx,%esi
 5d3:	74 1b                	je     5f0 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5d5:	89 08                	mov    %ecx,(%eax)
  freep = p;
 5d7:	a3 24 0a 00 00       	mov    %eax,0xa24
}
 5dc:	5b                   	pop    %ebx
 5dd:	5e                   	pop    %esi
 5de:	5f                   	pop    %edi
 5df:	5d                   	pop    %ebp
 5e0:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 5e1:	03 72 04             	add    0x4(%edx),%esi
 5e4:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 5e7:	8b 10                	mov    (%eax),%edx
 5e9:	8b 12                	mov    (%edx),%edx
 5eb:	89 53 f8             	mov    %edx,-0x8(%ebx)
 5ee:	eb db                	jmp    5cb <free+0x3e>
    p->s.size += bp->s.size;
 5f0:	03 53 fc             	add    -0x4(%ebx),%edx
 5f3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 5f6:	8b 53 f8             	mov    -0x8(%ebx),%edx
 5f9:	89 10                	mov    %edx,(%eax)
 5fb:	eb da                	jmp    5d7 <free+0x4a>

000005fd <morecore>:

static Header*
morecore(uint nu)
{
 5fd:	55                   	push   %ebp
 5fe:	89 e5                	mov    %esp,%ebp
 600:	53                   	push   %ebx
 601:	83 ec 04             	sub    $0x4,%esp
 604:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 606:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 60b:	77 05                	ja     612 <morecore+0x15>
    nu = 4096;
 60d:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 612:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 619:	83 ec 0c             	sub    $0xc,%esp
 61c:	50                   	push   %eax
 61d:	e8 30 fd ff ff       	call   352 <sbrk>
  if(p == (char*)-1)
 622:	83 c4 10             	add    $0x10,%esp
 625:	83 f8 ff             	cmp    $0xffffffff,%eax
 628:	74 1c                	je     646 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 62a:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 62d:	83 c0 08             	add    $0x8,%eax
 630:	83 ec 0c             	sub    $0xc,%esp
 633:	50                   	push   %eax
 634:	e8 54 ff ff ff       	call   58d <free>
  return freep;
 639:	a1 24 0a 00 00       	mov    0xa24,%eax
 63e:	83 c4 10             	add    $0x10,%esp
}
 641:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 644:	c9                   	leave  
 645:	c3                   	ret    
    return 0;
 646:	b8 00 00 00 00       	mov    $0x0,%eax
 64b:	eb f4                	jmp    641 <morecore+0x44>

0000064d <malloc>:

void*
malloc(uint nbytes)
{
 64d:	55                   	push   %ebp
 64e:	89 e5                	mov    %esp,%ebp
 650:	53                   	push   %ebx
 651:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 654:	8b 45 08             	mov    0x8(%ebp),%eax
 657:	8d 58 07             	lea    0x7(%eax),%ebx
 65a:	c1 eb 03             	shr    $0x3,%ebx
 65d:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 660:	8b 0d 24 0a 00 00    	mov    0xa24,%ecx
 666:	85 c9                	test   %ecx,%ecx
 668:	74 04                	je     66e <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 66a:	8b 01                	mov    (%ecx),%eax
 66c:	eb 4d                	jmp    6bb <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 66e:	c7 05 24 0a 00 00 28 	movl   $0xa28,0xa24
 675:	0a 00 00 
 678:	c7 05 28 0a 00 00 28 	movl   $0xa28,0xa28
 67f:	0a 00 00 
    base.s.size = 0;
 682:	c7 05 2c 0a 00 00 00 	movl   $0x0,0xa2c
 689:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 68c:	b9 28 0a 00 00       	mov    $0xa28,%ecx
 691:	eb d7                	jmp    66a <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 693:	39 da                	cmp    %ebx,%edx
 695:	74 1a                	je     6b1 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 697:	29 da                	sub    %ebx,%edx
 699:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 69c:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 69f:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6a2:	89 0d 24 0a 00 00    	mov    %ecx,0xa24
      return (void*)(p + 1);
 6a8:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6ab:	83 c4 04             	add    $0x4,%esp
 6ae:	5b                   	pop    %ebx
 6af:	5d                   	pop    %ebp
 6b0:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6b1:	8b 10                	mov    (%eax),%edx
 6b3:	89 11                	mov    %edx,(%ecx)
 6b5:	eb eb                	jmp    6a2 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6b7:	89 c1                	mov    %eax,%ecx
 6b9:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6bb:	8b 50 04             	mov    0x4(%eax),%edx
 6be:	39 da                	cmp    %ebx,%edx
 6c0:	73 d1                	jae    693 <malloc+0x46>
    if(p == freep)
 6c2:	39 05 24 0a 00 00    	cmp    %eax,0xa24
 6c8:	75 ed                	jne    6b7 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6ca:	89 d8                	mov    %ebx,%eax
 6cc:	e8 2c ff ff ff       	call   5fd <morecore>
 6d1:	85 c0                	test   %eax,%eax
 6d3:	75 e2                	jne    6b7 <malloc+0x6a>
        return 0;
 6d5:	b8 00 00 00 00       	mov    $0x0,%eax
 6da:	eb cf                	jmp    6ab <malloc+0x5e>
