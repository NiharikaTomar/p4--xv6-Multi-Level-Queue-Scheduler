
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
  1e:	e8 a4 03 00 00       	call   3c7 <getpinfo>
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
  66:	68 24 07 00 00       	push   $0x724
  6b:	6a 17                	push   $0x17
  6d:	68 2d 07 00 00       	push   $0x72d
  72:	68 88 07 00 00       	push   $0x788
  77:	6a 01                	push   $0x1
  79:	e8 eb 03 00 00       	call   469 <printf>
  7e:	83 c4 20             	add    $0x20,%esp
  81:	eb a7                	jmp    2a <main+0x2a>
    c_pid[i] = fork2(c_pri[i]);
   
    // Child
    if (c_pid[i] == 0) {
      exit();
  83:	e8 87 02 00 00       	call   30f <exit>
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
  c9:	e8 f1 02 00 00       	call   3bf <fork2>
  ce:	89 84 bd e0 f3 ff ff 	mov    %eax,-0xc20(%ebp,%edi,4)
    if (c_pid[i] == 0) {
  d5:	83 c4 10             	add    $0x10,%esp
  d8:	85 c0                	test   %eax,%eax
  da:	74 a7                	je     83 <main+0x83>
      getpinfo(&st);
  dc:	83 ec 0c             	sub    $0xc,%esp
  df:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
  e5:	50                   	push   %eax
  e6:	e8 dc 02 00 00       	call   3c7 <getpinfo>
      for(int j = 0; j < NPROC; j++){
  eb:	83 c4 10             	add    $0x10,%esp
  ee:	b8 00 00 00 00       	mov    $0x0,%eax
  f3:	eb 9d                	jmp    92 <main+0x92>
      	}
      }
    }
  }
  printf(1, "c_newpri 0: %d\n", c_newpri[0]);
  f5:	83 ec 04             	sub    $0x4,%esp
  f8:	53                   	push   %ebx
  f9:	68 36 07 00 00       	push   $0x736
  fe:	6a 01                	push   $0x1
 100:	e8 64 03 00 00       	call   469 <printf>
  printf(1, "c_pri 0: %d\n", c_pri[0]); 
 105:	83 c4 0c             	add    $0xc,%esp
 108:	6a 00                	push   $0x0
 10a:	68 46 07 00 00       	push   $0x746
 10f:	6a 01                	push   $0x1
 111:	e8 53 03 00 00       	call   469 <printf>
  printf(1, "c_newpri 1: %d\n", c_newpri[1]);
 116:	83 c4 0c             	add    $0xc,%esp
 119:	56                   	push   %esi
 11a:	68 53 07 00 00       	push   $0x753
 11f:	6a 01                	push   $0x1
 121:	e8 43 03 00 00       	call   469 <printf>
  printf(1, "c_pri 1: %d\n", c_pri[1]); 
 126:	83 c4 0c             	add    $0xc,%esp
 129:	6a 01                	push   $0x1
 12b:	68 63 07 00 00       	push   $0x763
 130:	6a 01                	push   $0x1
 132:	e8 32 03 00 00       	call   469 <printf>
  if(c_newpri[0] == c_pri[0] && c_newpri[1] == c_pri[1]){
 137:	83 c4 10             	add    $0x10,%esp
 13a:	85 db                	test   %ebx,%ebx
 13c:	75 05                	jne    143 <main+0x143>
 13e:	83 fe 01             	cmp    $0x1,%esi
 141:	74 26                	je     169 <main+0x169>
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
  }else{
    printf(1, "XV6_SCHEDULER\t getpinfo FAILED to properly udpate process info\n");
 143:	83 ec 08             	sub    $0x8,%esp
 146:	68 b8 07 00 00       	push   $0x7b8
 14b:	6a 01                	push   $0x1
 14d:	e8 17 03 00 00       	call   469 <printf>
 152:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 2; i++) {
 155:	bb 00 00 00 00       	mov    $0x0,%ebx
  }
  
  for (i = 0; i < 2; i++) {
 15a:	83 fb 01             	cmp    $0x1,%ebx
 15d:	7f 1e                	jg     17d <main+0x17d>
    wait();
 15f:	e8 b3 01 00 00       	call   317 <wait>
  for (i = 0; i < 2; i++) {
 164:	83 c3 01             	add    $0x1,%ebx
 167:	eb f1                	jmp    15a <main+0x15a>
    printf(1, "XV6_SCHEDULER\t SUCCESS\n");
 169:	83 ec 08             	sub    $0x8,%esp
 16c:	68 70 07 00 00       	push   $0x770
 171:	6a 01                	push   $0x1
 173:	e8 f1 02 00 00       	call   469 <printf>
 178:	83 c4 10             	add    $0x10,%esp
 17b:	eb d8                	jmp    155 <main+0x155>
  }


  exit();
 17d:	e8 8d 01 00 00       	call   30f <exit>

00000182 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 182:	55                   	push   %ebp
 183:	89 e5                	mov    %esp,%ebp
 185:	53                   	push   %ebx
 186:	8b 45 08             	mov    0x8(%ebp),%eax
 189:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 18c:	89 c2                	mov    %eax,%edx
 18e:	0f b6 19             	movzbl (%ecx),%ebx
 191:	88 1a                	mov    %bl,(%edx)
 193:	8d 52 01             	lea    0x1(%edx),%edx
 196:	8d 49 01             	lea    0x1(%ecx),%ecx
 199:	84 db                	test   %bl,%bl
 19b:	75 f1                	jne    18e <strcpy+0xc>
    ;
  return os;
}
 19d:	5b                   	pop    %ebx
 19e:	5d                   	pop    %ebp
 19f:	c3                   	ret    

000001a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1a0:	55                   	push   %ebp
 1a1:	89 e5                	mov    %esp,%ebp
 1a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 1a9:	eb 06                	jmp    1b1 <strcmp+0x11>
    p++, q++;
 1ab:	83 c1 01             	add    $0x1,%ecx
 1ae:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 1b1:	0f b6 01             	movzbl (%ecx),%eax
 1b4:	84 c0                	test   %al,%al
 1b6:	74 04                	je     1bc <strcmp+0x1c>
 1b8:	3a 02                	cmp    (%edx),%al
 1ba:	74 ef                	je     1ab <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 1bc:	0f b6 c0             	movzbl %al,%eax
 1bf:	0f b6 12             	movzbl (%edx),%edx
 1c2:	29 d0                	sub    %edx,%eax
}
 1c4:	5d                   	pop    %ebp
 1c5:	c3                   	ret    

000001c6 <strlen>:

uint
strlen(const char *s)
{
 1c6:	55                   	push   %ebp
 1c7:	89 e5                	mov    %esp,%ebp
 1c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1cc:	ba 00 00 00 00       	mov    $0x0,%edx
 1d1:	eb 03                	jmp    1d6 <strlen+0x10>
 1d3:	83 c2 01             	add    $0x1,%edx
 1d6:	89 d0                	mov    %edx,%eax
 1d8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1dc:	75 f5                	jne    1d3 <strlen+0xd>
    ;
  return n;
}
 1de:	5d                   	pop    %ebp
 1df:	c3                   	ret    

000001e0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1e0:	55                   	push   %ebp
 1e1:	89 e5                	mov    %esp,%ebp
 1e3:	57                   	push   %edi
 1e4:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1e7:	89 d7                	mov    %edx,%edi
 1e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1ec:	8b 45 0c             	mov    0xc(%ebp),%eax
 1ef:	fc                   	cld    
 1f0:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1f2:	89 d0                	mov    %edx,%eax
 1f4:	5f                   	pop    %edi
 1f5:	5d                   	pop    %ebp
 1f6:	c3                   	ret    

000001f7 <strchr>:

char*
strchr(const char *s, char c)
{
 1f7:	55                   	push   %ebp
 1f8:	89 e5                	mov    %esp,%ebp
 1fa:	8b 45 08             	mov    0x8(%ebp),%eax
 1fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 201:	0f b6 10             	movzbl (%eax),%edx
 204:	84 d2                	test   %dl,%dl
 206:	74 09                	je     211 <strchr+0x1a>
    if(*s == c)
 208:	38 ca                	cmp    %cl,%dl
 20a:	74 0a                	je     216 <strchr+0x1f>
  for(; *s; s++)
 20c:	83 c0 01             	add    $0x1,%eax
 20f:	eb f0                	jmp    201 <strchr+0xa>
      return (char*)s;
  return 0;
 211:	b8 00 00 00 00       	mov    $0x0,%eax
}
 216:	5d                   	pop    %ebp
 217:	c3                   	ret    

00000218 <gets>:

char*
gets(char *buf, int max)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	57                   	push   %edi
 21c:	56                   	push   %esi
 21d:	53                   	push   %ebx
 21e:	83 ec 1c             	sub    $0x1c,%esp
 221:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 224:	bb 00 00 00 00       	mov    $0x0,%ebx
 229:	8d 73 01             	lea    0x1(%ebx),%esi
 22c:	3b 75 0c             	cmp    0xc(%ebp),%esi
 22f:	7d 2e                	jge    25f <gets+0x47>
    cc = read(0, &c, 1);
 231:	83 ec 04             	sub    $0x4,%esp
 234:	6a 01                	push   $0x1
 236:	8d 45 e7             	lea    -0x19(%ebp),%eax
 239:	50                   	push   %eax
 23a:	6a 00                	push   $0x0
 23c:	e8 e6 00 00 00       	call   327 <read>
    if(cc < 1)
 241:	83 c4 10             	add    $0x10,%esp
 244:	85 c0                	test   %eax,%eax
 246:	7e 17                	jle    25f <gets+0x47>
      break;
    buf[i++] = c;
 248:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 24c:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 24f:	3c 0a                	cmp    $0xa,%al
 251:	0f 94 c2             	sete   %dl
 254:	3c 0d                	cmp    $0xd,%al
 256:	0f 94 c0             	sete   %al
    buf[i++] = c;
 259:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 25b:	08 c2                	or     %al,%dl
 25d:	74 ca                	je     229 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 25f:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 263:	89 f8                	mov    %edi,%eax
 265:	8d 65 f4             	lea    -0xc(%ebp),%esp
 268:	5b                   	pop    %ebx
 269:	5e                   	pop    %esi
 26a:	5f                   	pop    %edi
 26b:	5d                   	pop    %ebp
 26c:	c3                   	ret    

0000026d <stat>:

int
stat(const char *n, struct stat *st)
{
 26d:	55                   	push   %ebp
 26e:	89 e5                	mov    %esp,%ebp
 270:	56                   	push   %esi
 271:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	83 ec 08             	sub    $0x8,%esp
 275:	6a 00                	push   $0x0
 277:	ff 75 08             	pushl  0x8(%ebp)
 27a:	e8 d0 00 00 00       	call   34f <open>
  if(fd < 0)
 27f:	83 c4 10             	add    $0x10,%esp
 282:	85 c0                	test   %eax,%eax
 284:	78 24                	js     2aa <stat+0x3d>
 286:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 288:	83 ec 08             	sub    $0x8,%esp
 28b:	ff 75 0c             	pushl  0xc(%ebp)
 28e:	50                   	push   %eax
 28f:	e8 d3 00 00 00       	call   367 <fstat>
 294:	89 c6                	mov    %eax,%esi
  close(fd);
 296:	89 1c 24             	mov    %ebx,(%esp)
 299:	e8 99 00 00 00       	call   337 <close>
  return r;
 29e:	83 c4 10             	add    $0x10,%esp
}
 2a1:	89 f0                	mov    %esi,%eax
 2a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
 2a6:	5b                   	pop    %ebx
 2a7:	5e                   	pop    %esi
 2a8:	5d                   	pop    %ebp
 2a9:	c3                   	ret    
    return -1;
 2aa:	be ff ff ff ff       	mov    $0xffffffff,%esi
 2af:	eb f0                	jmp    2a1 <stat+0x34>

000002b1 <atoi>:

int
atoi(const char *s)
{
 2b1:	55                   	push   %ebp
 2b2:	89 e5                	mov    %esp,%ebp
 2b4:	53                   	push   %ebx
 2b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 2b8:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 2bd:	eb 10                	jmp    2cf <atoi+0x1e>
    n = n*10 + *s++ - '0';
 2bf:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 2c2:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 2c5:	83 c1 01             	add    $0x1,%ecx
 2c8:	0f be d2             	movsbl %dl,%edx
 2cb:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 2cf:	0f b6 11             	movzbl (%ecx),%edx
 2d2:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2d5:	80 fb 09             	cmp    $0x9,%bl
 2d8:	76 e5                	jbe    2bf <atoi+0xe>
  return n;
}
 2da:	5b                   	pop    %ebx
 2db:	5d                   	pop    %ebp
 2dc:	c3                   	ret    

000002dd <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2dd:	55                   	push   %ebp
 2de:	89 e5                	mov    %esp,%ebp
 2e0:	56                   	push   %esi
 2e1:	53                   	push   %ebx
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2e8:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2eb:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2ed:	eb 0d                	jmp    2fc <memmove+0x1f>
    *dst++ = *src++;
 2ef:	0f b6 13             	movzbl (%ebx),%edx
 2f2:	88 11                	mov    %dl,(%ecx)
 2f4:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2f7:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2fa:	89 f2                	mov    %esi,%edx
 2fc:	8d 72 ff             	lea    -0x1(%edx),%esi
 2ff:	85 d2                	test   %edx,%edx
 301:	7f ec                	jg     2ef <memmove+0x12>
  return vdst;
}
 303:	5b                   	pop    %ebx
 304:	5e                   	pop    %esi
 305:	5d                   	pop    %ebp
 306:	c3                   	ret    

00000307 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 307:	b8 01 00 00 00       	mov    $0x1,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <exit>:
SYSCALL(exit)
 30f:	b8 02 00 00 00       	mov    $0x2,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <wait>:
SYSCALL(wait)
 317:	b8 03 00 00 00       	mov    $0x3,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <pipe>:
SYSCALL(pipe)
 31f:	b8 04 00 00 00       	mov    $0x4,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <read>:
SYSCALL(read)
 327:	b8 05 00 00 00       	mov    $0x5,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <write>:
SYSCALL(write)
 32f:	b8 10 00 00 00       	mov    $0x10,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <close>:
SYSCALL(close)
 337:	b8 15 00 00 00       	mov    $0x15,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <kill>:
SYSCALL(kill)
 33f:	b8 06 00 00 00       	mov    $0x6,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <exec>:
SYSCALL(exec)
 347:	b8 07 00 00 00       	mov    $0x7,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <open>:
SYSCALL(open)
 34f:	b8 0f 00 00 00       	mov    $0xf,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <mknod>:
SYSCALL(mknod)
 357:	b8 11 00 00 00       	mov    $0x11,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <unlink>:
SYSCALL(unlink)
 35f:	b8 12 00 00 00       	mov    $0x12,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <fstat>:
SYSCALL(fstat)
 367:	b8 08 00 00 00       	mov    $0x8,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <link>:
SYSCALL(link)
 36f:	b8 13 00 00 00       	mov    $0x13,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <mkdir>:
SYSCALL(mkdir)
 377:	b8 14 00 00 00       	mov    $0x14,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <chdir>:
SYSCALL(chdir)
 37f:	b8 09 00 00 00       	mov    $0x9,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <dup>:
SYSCALL(dup)
 387:	b8 0a 00 00 00       	mov    $0xa,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <getpid>:
SYSCALL(getpid)
 38f:	b8 0b 00 00 00       	mov    $0xb,%eax
 394:	cd 40                	int    $0x40
 396:	c3                   	ret    

00000397 <sbrk>:
SYSCALL(sbrk)
 397:	b8 0c 00 00 00       	mov    $0xc,%eax
 39c:	cd 40                	int    $0x40
 39e:	c3                   	ret    

0000039f <sleep>:
SYSCALL(sleep)
 39f:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a4:	cd 40                	int    $0x40
 3a6:	c3                   	ret    

000003a7 <uptime>:
SYSCALL(uptime)
 3a7:	b8 0e 00 00 00       	mov    $0xe,%eax
 3ac:	cd 40                	int    $0x40
 3ae:	c3                   	ret    

000003af <setpri>:
SYSCALL(setpri)
 3af:	b8 16 00 00 00       	mov    $0x16,%eax
 3b4:	cd 40                	int    $0x40
 3b6:	c3                   	ret    

000003b7 <getpri>:
SYSCALL(getpri)
 3b7:	b8 17 00 00 00       	mov    $0x17,%eax
 3bc:	cd 40                	int    $0x40
 3be:	c3                   	ret    

000003bf <fork2>:
SYSCALL(fork2)
 3bf:	b8 18 00 00 00       	mov    $0x18,%eax
 3c4:	cd 40                	int    $0x40
 3c6:	c3                   	ret    

000003c7 <getpinfo>:
SYSCALL(getpinfo)
 3c7:	b8 19 00 00 00       	mov    $0x19,%eax
 3cc:	cd 40                	int    $0x40
 3ce:	c3                   	ret    

000003cf <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3cf:	55                   	push   %ebp
 3d0:	89 e5                	mov    %esp,%ebp
 3d2:	83 ec 1c             	sub    $0x1c,%esp
 3d5:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3d8:	6a 01                	push   $0x1
 3da:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3dd:	52                   	push   %edx
 3de:	50                   	push   %eax
 3df:	e8 4b ff ff ff       	call   32f <write>
}
 3e4:	83 c4 10             	add    $0x10,%esp
 3e7:	c9                   	leave  
 3e8:	c3                   	ret    

000003e9 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3e9:	55                   	push   %ebp
 3ea:	89 e5                	mov    %esp,%ebp
 3ec:	57                   	push   %edi
 3ed:	56                   	push   %esi
 3ee:	53                   	push   %ebx
 3ef:	83 ec 2c             	sub    $0x2c,%esp
 3f2:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3f4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3f8:	0f 95 c3             	setne  %bl
 3fb:	89 d0                	mov    %edx,%eax
 3fd:	c1 e8 1f             	shr    $0x1f,%eax
 400:	84 c3                	test   %al,%bl
 402:	74 10                	je     414 <printint+0x2b>
    neg = 1;
    x = -xx;
 404:	f7 da                	neg    %edx
    neg = 1;
 406:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 40d:	be 00 00 00 00       	mov    $0x0,%esi
 412:	eb 0b                	jmp    41f <printint+0x36>
  neg = 0;
 414:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 41b:	eb f0                	jmp    40d <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 41d:	89 c6                	mov    %eax,%esi
 41f:	89 d0                	mov    %edx,%eax
 421:	ba 00 00 00 00       	mov    $0x0,%edx
 426:	f7 f1                	div    %ecx
 428:	89 c3                	mov    %eax,%ebx
 42a:	8d 46 01             	lea    0x1(%esi),%eax
 42d:	0f b6 92 00 08 00 00 	movzbl 0x800(%edx),%edx
 434:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 438:	89 da                	mov    %ebx,%edx
 43a:	85 db                	test   %ebx,%ebx
 43c:	75 df                	jne    41d <printint+0x34>
 43e:	89 c3                	mov    %eax,%ebx
  if(neg)
 440:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 444:	74 16                	je     45c <printint+0x73>
    buf[i++] = '-';
 446:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 44b:	8d 5e 02             	lea    0x2(%esi),%ebx
 44e:	eb 0c                	jmp    45c <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 450:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 455:	89 f8                	mov    %edi,%eax
 457:	e8 73 ff ff ff       	call   3cf <putc>
  while(--i >= 0)
 45c:	83 eb 01             	sub    $0x1,%ebx
 45f:	79 ef                	jns    450 <printint+0x67>
}
 461:	83 c4 2c             	add    $0x2c,%esp
 464:	5b                   	pop    %ebx
 465:	5e                   	pop    %esi
 466:	5f                   	pop    %edi
 467:	5d                   	pop    %ebp
 468:	c3                   	ret    

00000469 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 469:	55                   	push   %ebp
 46a:	89 e5                	mov    %esp,%ebp
 46c:	57                   	push   %edi
 46d:	56                   	push   %esi
 46e:	53                   	push   %ebx
 46f:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 472:	8d 45 10             	lea    0x10(%ebp),%eax
 475:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 478:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 47d:	bb 00 00 00 00       	mov    $0x0,%ebx
 482:	eb 14                	jmp    498 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 484:	89 fa                	mov    %edi,%edx
 486:	8b 45 08             	mov    0x8(%ebp),%eax
 489:	e8 41 ff ff ff       	call   3cf <putc>
 48e:	eb 05                	jmp    495 <printf+0x2c>
      }
    } else if(state == '%'){
 490:	83 fe 25             	cmp    $0x25,%esi
 493:	74 25                	je     4ba <printf+0x51>
  for(i = 0; fmt[i]; i++){
 495:	83 c3 01             	add    $0x1,%ebx
 498:	8b 45 0c             	mov    0xc(%ebp),%eax
 49b:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 49f:	84 c0                	test   %al,%al
 4a1:	0f 84 23 01 00 00    	je     5ca <printf+0x161>
    c = fmt[i] & 0xff;
 4a7:	0f be f8             	movsbl %al,%edi
 4aa:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 4ad:	85 f6                	test   %esi,%esi
 4af:	75 df                	jne    490 <printf+0x27>
      if(c == '%'){
 4b1:	83 f8 25             	cmp    $0x25,%eax
 4b4:	75 ce                	jne    484 <printf+0x1b>
        state = '%';
 4b6:	89 c6                	mov    %eax,%esi
 4b8:	eb db                	jmp    495 <printf+0x2c>
      if(c == 'd'){
 4ba:	83 f8 64             	cmp    $0x64,%eax
 4bd:	74 49                	je     508 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4bf:	83 f8 78             	cmp    $0x78,%eax
 4c2:	0f 94 c1             	sete   %cl
 4c5:	83 f8 70             	cmp    $0x70,%eax
 4c8:	0f 94 c2             	sete   %dl
 4cb:	08 d1                	or     %dl,%cl
 4cd:	75 63                	jne    532 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4cf:	83 f8 73             	cmp    $0x73,%eax
 4d2:	0f 84 84 00 00 00    	je     55c <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4d8:	83 f8 63             	cmp    $0x63,%eax
 4db:	0f 84 b7 00 00 00    	je     598 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4e1:	83 f8 25             	cmp    $0x25,%eax
 4e4:	0f 84 cc 00 00 00    	je     5b6 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4ea:	ba 25 00 00 00       	mov    $0x25,%edx
 4ef:	8b 45 08             	mov    0x8(%ebp),%eax
 4f2:	e8 d8 fe ff ff       	call   3cf <putc>
        putc(fd, c);
 4f7:	89 fa                	mov    %edi,%edx
 4f9:	8b 45 08             	mov    0x8(%ebp),%eax
 4fc:	e8 ce fe ff ff       	call   3cf <putc>
      }
      state = 0;
 501:	be 00 00 00 00       	mov    $0x0,%esi
 506:	eb 8d                	jmp    495 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 508:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 50b:	8b 17                	mov    (%edi),%edx
 50d:	83 ec 0c             	sub    $0xc,%esp
 510:	6a 01                	push   $0x1
 512:	b9 0a 00 00 00       	mov    $0xa,%ecx
 517:	8b 45 08             	mov    0x8(%ebp),%eax
 51a:	e8 ca fe ff ff       	call   3e9 <printint>
        ap++;
 51f:	83 c7 04             	add    $0x4,%edi
 522:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 525:	83 c4 10             	add    $0x10,%esp
      state = 0;
 528:	be 00 00 00 00       	mov    $0x0,%esi
 52d:	e9 63 ff ff ff       	jmp    495 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 535:	8b 17                	mov    (%edi),%edx
 537:	83 ec 0c             	sub    $0xc,%esp
 53a:	6a 00                	push   $0x0
 53c:	b9 10 00 00 00       	mov    $0x10,%ecx
 541:	8b 45 08             	mov    0x8(%ebp),%eax
 544:	e8 a0 fe ff ff       	call   3e9 <printint>
        ap++;
 549:	83 c7 04             	add    $0x4,%edi
 54c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 54f:	83 c4 10             	add    $0x10,%esp
      state = 0;
 552:	be 00 00 00 00       	mov    $0x0,%esi
 557:	e9 39 ff ff ff       	jmp    495 <printf+0x2c>
        s = (char*)*ap;
 55c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 55f:	8b 30                	mov    (%eax),%esi
        ap++;
 561:	83 c0 04             	add    $0x4,%eax
 564:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 567:	85 f6                	test   %esi,%esi
 569:	75 28                	jne    593 <printf+0x12a>
          s = "(null)";
 56b:	be f8 07 00 00       	mov    $0x7f8,%esi
 570:	8b 7d 08             	mov    0x8(%ebp),%edi
 573:	eb 0d                	jmp    582 <printf+0x119>
          putc(fd, *s);
 575:	0f be d2             	movsbl %dl,%edx
 578:	89 f8                	mov    %edi,%eax
 57a:	e8 50 fe ff ff       	call   3cf <putc>
          s++;
 57f:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 582:	0f b6 16             	movzbl (%esi),%edx
 585:	84 d2                	test   %dl,%dl
 587:	75 ec                	jne    575 <printf+0x10c>
      state = 0;
 589:	be 00 00 00 00       	mov    $0x0,%esi
 58e:	e9 02 ff ff ff       	jmp    495 <printf+0x2c>
 593:	8b 7d 08             	mov    0x8(%ebp),%edi
 596:	eb ea                	jmp    582 <printf+0x119>
        putc(fd, *ap);
 598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 59b:	0f be 17             	movsbl (%edi),%edx
 59e:	8b 45 08             	mov    0x8(%ebp),%eax
 5a1:	e8 29 fe ff ff       	call   3cf <putc>
        ap++;
 5a6:	83 c7 04             	add    $0x4,%edi
 5a9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 5ac:	be 00 00 00 00       	mov    $0x0,%esi
 5b1:	e9 df fe ff ff       	jmp    495 <printf+0x2c>
        putc(fd, c);
 5b6:	89 fa                	mov    %edi,%edx
 5b8:	8b 45 08             	mov    0x8(%ebp),%eax
 5bb:	e8 0f fe ff ff       	call   3cf <putc>
      state = 0;
 5c0:	be 00 00 00 00       	mov    $0x0,%esi
 5c5:	e9 cb fe ff ff       	jmp    495 <printf+0x2c>
    }
  }
}
 5ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5cd:	5b                   	pop    %ebx
 5ce:	5e                   	pop    %esi
 5cf:	5f                   	pop    %edi
 5d0:	5d                   	pop    %ebp
 5d1:	c3                   	ret    

000005d2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5d2:	55                   	push   %ebp
 5d3:	89 e5                	mov    %esp,%ebp
 5d5:	57                   	push   %edi
 5d6:	56                   	push   %esi
 5d7:	53                   	push   %ebx
 5d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5db:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5de:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 5e3:	eb 02                	jmp    5e7 <free+0x15>
 5e5:	89 d0                	mov    %edx,%eax
 5e7:	39 c8                	cmp    %ecx,%eax
 5e9:	73 04                	jae    5ef <free+0x1d>
 5eb:	39 08                	cmp    %ecx,(%eax)
 5ed:	77 12                	ja     601 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5ef:	8b 10                	mov    (%eax),%edx
 5f1:	39 c2                	cmp    %eax,%edx
 5f3:	77 f0                	ja     5e5 <free+0x13>
 5f5:	39 c8                	cmp    %ecx,%eax
 5f7:	72 08                	jb     601 <free+0x2f>
 5f9:	39 ca                	cmp    %ecx,%edx
 5fb:	77 04                	ja     601 <free+0x2f>
 5fd:	89 d0                	mov    %edx,%eax
 5ff:	eb e6                	jmp    5e7 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 601:	8b 73 fc             	mov    -0x4(%ebx),%esi
 604:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 607:	8b 10                	mov    (%eax),%edx
 609:	39 d7                	cmp    %edx,%edi
 60b:	74 19                	je     626 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 60d:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 610:	8b 50 04             	mov    0x4(%eax),%edx
 613:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 616:	39 ce                	cmp    %ecx,%esi
 618:	74 1b                	je     635 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 61a:	89 08                	mov    %ecx,(%eax)
  freep = p;
 61c:	a3 a4 0a 00 00       	mov    %eax,0xaa4
}
 621:	5b                   	pop    %ebx
 622:	5e                   	pop    %esi
 623:	5f                   	pop    %edi
 624:	5d                   	pop    %ebp
 625:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 626:	03 72 04             	add    0x4(%edx),%esi
 629:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 62c:	8b 10                	mov    (%eax),%edx
 62e:	8b 12                	mov    (%edx),%edx
 630:	89 53 f8             	mov    %edx,-0x8(%ebx)
 633:	eb db                	jmp    610 <free+0x3e>
    p->s.size += bp->s.size;
 635:	03 53 fc             	add    -0x4(%ebx),%edx
 638:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 63b:	8b 53 f8             	mov    -0x8(%ebx),%edx
 63e:	89 10                	mov    %edx,(%eax)
 640:	eb da                	jmp    61c <free+0x4a>

00000642 <morecore>:

static Header*
morecore(uint nu)
{
 642:	55                   	push   %ebp
 643:	89 e5                	mov    %esp,%ebp
 645:	53                   	push   %ebx
 646:	83 ec 04             	sub    $0x4,%esp
 649:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 64b:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 650:	77 05                	ja     657 <morecore+0x15>
    nu = 4096;
 652:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 657:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 65e:	83 ec 0c             	sub    $0xc,%esp
 661:	50                   	push   %eax
 662:	e8 30 fd ff ff       	call   397 <sbrk>
  if(p == (char*)-1)
 667:	83 c4 10             	add    $0x10,%esp
 66a:	83 f8 ff             	cmp    $0xffffffff,%eax
 66d:	74 1c                	je     68b <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 66f:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 672:	83 c0 08             	add    $0x8,%eax
 675:	83 ec 0c             	sub    $0xc,%esp
 678:	50                   	push   %eax
 679:	e8 54 ff ff ff       	call   5d2 <free>
  return freep;
 67e:	a1 a4 0a 00 00       	mov    0xaa4,%eax
 683:	83 c4 10             	add    $0x10,%esp
}
 686:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 689:	c9                   	leave  
 68a:	c3                   	ret    
    return 0;
 68b:	b8 00 00 00 00       	mov    $0x0,%eax
 690:	eb f4                	jmp    686 <morecore+0x44>

00000692 <malloc>:

void*
malloc(uint nbytes)
{
 692:	55                   	push   %ebp
 693:	89 e5                	mov    %esp,%ebp
 695:	53                   	push   %ebx
 696:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 699:	8b 45 08             	mov    0x8(%ebp),%eax
 69c:	8d 58 07             	lea    0x7(%eax),%ebx
 69f:	c1 eb 03             	shr    $0x3,%ebx
 6a2:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 6a5:	8b 0d a4 0a 00 00    	mov    0xaa4,%ecx
 6ab:	85 c9                	test   %ecx,%ecx
 6ad:	74 04                	je     6b3 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6af:	8b 01                	mov    (%ecx),%eax
 6b1:	eb 4d                	jmp    700 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 6b3:	c7 05 a4 0a 00 00 a8 	movl   $0xaa8,0xaa4
 6ba:	0a 00 00 
 6bd:	c7 05 a8 0a 00 00 a8 	movl   $0xaa8,0xaa8
 6c4:	0a 00 00 
    base.s.size = 0;
 6c7:	c7 05 ac 0a 00 00 00 	movl   $0x0,0xaac
 6ce:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 6d1:	b9 a8 0a 00 00       	mov    $0xaa8,%ecx
 6d6:	eb d7                	jmp    6af <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 6d8:	39 da                	cmp    %ebx,%edx
 6da:	74 1a                	je     6f6 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6dc:	29 da                	sub    %ebx,%edx
 6de:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6e1:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6e4:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6e7:	89 0d a4 0a 00 00    	mov    %ecx,0xaa4
      return (void*)(p + 1);
 6ed:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6f0:	83 c4 04             	add    $0x4,%esp
 6f3:	5b                   	pop    %ebx
 6f4:	5d                   	pop    %ebp
 6f5:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6f6:	8b 10                	mov    (%eax),%edx
 6f8:	89 11                	mov    %edx,(%ecx)
 6fa:	eb eb                	jmp    6e7 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6fc:	89 c1                	mov    %eax,%ecx
 6fe:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 700:	8b 50 04             	mov    0x4(%eax),%edx
 703:	39 da                	cmp    %ebx,%edx
 705:	73 d1                	jae    6d8 <malloc+0x46>
    if(p == freep)
 707:	39 05 a4 0a 00 00    	cmp    %eax,0xaa4
 70d:	75 ed                	jne    6fc <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 70f:	89 d8                	mov    %ebx,%eax
 711:	e8 2c ff ff ff       	call   642 <morecore>
 716:	85 c0                	test   %eax,%eax
 718:	75 e2                	jne    6fc <malloc+0x6a>
        return 0;
 71a:	b8 00 00 00 00       	mov    $0x0,%eax
 71f:	eb cf                	jmp    6f0 <malloc+0x5e>
