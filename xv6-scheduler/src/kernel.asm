
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 b9 10 80       	mov    $0x8010b9d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 64 2a 10 80       	mov    $0x80102a64,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 e0 b9 10 80       	push   $0x8010b9e0
80100046:	e8 fc 44 00 00       	call   80104547 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 30 01 11 80    	mov    0x80110130,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb dc 00 11 80    	cmp    $0x801100dc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 e0 b9 10 80       	push   $0x8010b9e0
8010007c:	e8 2b 45 00 00       	call   801045ac <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 a7 42 00 00       	call   80104333 <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 2c 01 11 80    	mov    0x8011012c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb dc 00 11 80    	cmp    $0x801100dc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 e0 b9 10 80       	push   $0x8010b9e0
801000ca:	e8 dd 44 00 00       	call   801045ac <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 59 42 00 00       	call   80104333 <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 c0 6e 10 80       	push   $0x80106ec0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 d1 6e 10 80       	push   $0x80106ed1
80100100:	68 e0 b9 10 80       	push   $0x8010b9e0
80100105:	e8 01 43 00 00       	call   8010440b <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 2c 01 11 80 dc 	movl   $0x801100dc,0x8011012c
80100111:	00 11 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 30 01 11 80 dc 	movl   $0x801100dc,0x80110130
8010011b:	00 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 14 ba 10 80       	mov    $0x8010ba14,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 30 01 11 80       	mov    0x80110130,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 dc 00 11 80 	movl   $0x801100dc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 d8 6e 10 80       	push   $0x80106ed8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 b8 41 00 00       	call   80104300 <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 30 01 11 80       	mov    0x80110130,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 30 01 11 80    	mov    %ebx,0x80110130
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb dc 00 11 80    	cmp    $0x801100dc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 77 1c 00 00       	call   80101e0c <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 10 42 00 00       	call   801043bd <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 4c 1c 00 00       	call   80101e0c <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 df 6e 10 80       	push   $0x80106edf
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 d4 41 00 00       	call   801043bd <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 89 41 00 00       	call   80104382 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 b9 10 80 	movl   $0x8010b9e0,(%esp)
80100200:	e8 42 43 00 00       	call   80104547 <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 30 01 11 80       	mov    0x80110130,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 dc 00 11 80 	movl   $0x801100dc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 30 01 11 80       	mov    0x80110130,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 30 01 11 80    	mov    %ebx,0x80110130
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 e0 b9 10 80       	push   $0x8010b9e0
8010024c:	e8 5b 43 00 00       	call   801045ac <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 e6 6e 10 80       	push   $0x80106ee6
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 c3 13 00 00       	call   80101643 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028a:	e8 b8 42 00 00       	call   80104547 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 03 11 80       	mov    0x801103c0,%eax
8010029f:	3b 05 c4 03 11 80    	cmp    0x801103c4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 22 2f 00 00       	call   801031ce <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 a5 10 80       	push   $0x8010a520
801002ba:	68 c0 03 11 80       	push   $0x801103c0
801002bf:	e8 9a 38 00 00       	call   80103b5e <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 d6 42 00 00       	call   801045ac <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 a3 12 00 00       	call   80101581 <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 c0 03 11 80    	mov    %edx,0x801103c0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 40 03 11 80 	movzbl -0x7feefcc0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 c0 03 11 80       	mov    %eax,0x801103c0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 a5 10 80       	push   $0x8010a520
80100331:	e8 76 42 00 00       	call   801045ac <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 43 12 00 00       	call   80101581 <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 1f 20 00 00       	call   8010237e <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 ed 6e 10 80       	push   $0x80106eed
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 47 78 10 80 	movl   $0x80107847,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 92 40 00 00       	call   80104426 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 01 6f 10 80       	push   $0x80106f01
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 05 6f 10 80       	push   $0x80106f05
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 af 41 00 00       	call   8010466e <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 15 41 00 00       	call   801045f3 <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 91 55 00 00       	call   80105a9c <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 78 55 00 00       	call   80105a9c <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 6c 55 00 00       	call   80105a9c <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 60 55 00 00       	call   80105a9c <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 30 6f 10 80 	movzbl -0x7fef90d0(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 80 10 00 00       	call   80101643 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005ca:	e8 78 3f 00 00       	call   80104547 <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 a5 10 80       	push   $0x8010a520
801005f1:	e8 b6 3f 00 00       	call   801045ac <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 80 0f 00 00       	call   80101581 <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 a5 10 80       	mov    0x8010a554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 a5 10 80       	push   $0x8010a520
80100638:	e8 0a 3f 00 00       	call   80104547 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 1f 6f 10 80       	push   $0x80106f1f
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be 18 6f 10 80       	mov    $0x80106f18,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 a5 10 80       	push   $0x8010a520
80100734:	e8 73 3e 00 00       	call   801045ac <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010074a:	68 20 a5 10 80       	push   $0x8010a520
8010074f:	e8 f3 3d 00 00       	call   80104547 <acquire>
  while((c = getc()) >= 0){
80100754:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100757:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
    switch(c){
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 c8 03 11 80       	mov    0x801103c8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 c0 03 11 80    	sub    0x801103c0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 c8 03 11 80    	mov    %edx,0x801103c8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 40 03 11 80    	mov    %cl,-0x7feefcc0(%eax)
        consputc(c);
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 c0 03 11 80       	mov    0x801103c0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 c8 03 11 80    	cmp    %eax,0x801103c8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 c8 03 11 80       	mov    0x801103c8,%eax
801007d1:	a3 c4 03 11 80       	mov    %eax,0x801103c4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 c0 03 11 80       	push   $0x801103c0
801007de:	e8 e3 34 00 00       	call   80103cc6 <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 c8 03 11 80       	mov    %eax,0x801103c8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 c8 03 11 80       	mov    0x801103c8,%eax
801007fc:	3b 05 c4 03 11 80    	cmp    0x801103c4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 40 03 11 80 0a 	cmpb   $0xa,-0x7feefcc0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
      doprocdump = 1;
80100821:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
    switch(c){
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
      if(input.e != input.w){
8010084a:	a1 c8 03 11 80       	mov    0x801103c8,%eax
8010084f:	3b 05 c4 03 11 80    	cmp    0x801103c4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 c8 03 11 80       	mov    %eax,0x801103c8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 a5 10 80       	push   $0x8010a520
80100873:	e8 34 3d 00 00       	call   801045ac <release>
  if(doprocdump) {
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
}
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100887:	e8 d9 34 00 00       	call   80103d65 <procdump>
}
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:

void
consoleinit(void)
{
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100894:	68 28 6f 10 80       	push   $0x80106f28
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 68 3b 00 00       	call   8010440b <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 8c 0d 11 80 ac 	movl   $0x801005ac,0x80110d8c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 88 0d 11 80 68 	movl   $0x80100268,0x80110d88
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 b1 16 00 00       	call   80101f7e <ioapicenable>
}
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008de:	e8 eb 28 00 00       	call   801031ce <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 c0 1e 00 00       	call   801027ae <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 e8 12 00 00       	call   80101be1 <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 76 0c 00 00       	call   80101581 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 57 0e 00 00       	call   80101773 <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 dd 02 00 00    	je     80100c09 <exec+0x337>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 f3 0d 00 00       	call   80101728 <iunlockput>
    end_op();
80100935:	e8 ee 1e 00 00       	call   80102828 <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
    end_op();
8010094a:	e8 d9 1e 00 00       	call   80102828 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 41 6f 10 80       	push   $0x80106f41
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
80100972:	e8 e5 62 00 00       	call   80106c5c <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 06 01 00 00    	je     80100a8b <exec+0x1b9>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 98 00 00 00    	jle    80100a4a <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 ab 0d 00 00       	call   80101773 <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 b7 00 00 00    	jne    80100a8b <exec+0x1b9>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 9c 00 00 00    	jb     80100a8b <exec+0x1b9>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 90 00 00 00    	jb     80100a8b <exec+0x1b9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009fb:	83 ec 04             	sub    $0x4,%esp
801009fe:	50                   	push   %eax
801009ff:	57                   	push   %edi
80100a00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a06:	e8 f7 60 00 00       	call   80106b02 <allocuvm>
80100a0b:	89 c7                	mov    %eax,%edi
80100a0d:	83 c4 10             	add    $0x10,%esp
80100a10:	85 c0                	test   %eax,%eax
80100a12:	74 77                	je     80100a8b <exec+0x1b9>
    if(ph.vaddr % PGSIZE != 0)
80100a14:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a1a:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1f:	75 6a                	jne    80100a8b <exec+0x1b9>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a21:	83 ec 0c             	sub    $0xc,%esp
80100a24:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a2a:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a30:	53                   	push   %ebx
80100a31:	50                   	push   %eax
80100a32:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a38:	e8 93 5f 00 00       	call   801069d0 <loaduvm>
80100a3d:	83 c4 20             	add    $0x20,%esp
80100a40:	85 c0                	test   %eax,%eax
80100a42:	0f 89 4f ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a48:	eb 41                	jmp    80100a8b <exec+0x1b9>
  iunlockput(ip);
80100a4a:	83 ec 0c             	sub    $0xc,%esp
80100a4d:	53                   	push   %ebx
80100a4e:	e8 d5 0c 00 00       	call   80101728 <iunlockput>
  end_op();
80100a53:	e8 d0 1d 00 00       	call   80102828 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 89 60 00 00       	call   80106b02 <allocuvm>
80100a79:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a7f:	83 c4 10             	add    $0x10,%esp
80100a82:	85 c0                	test   %eax,%eax
80100a84:	75 24                	jne    80100aaa <exec+0x1d8>
  ip = 0;
80100a86:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8b:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a91:	85 c0                	test   %eax,%eax
80100a93:	0f 84 8b fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100a99:	83 ec 0c             	sub    $0xc,%esp
80100a9c:	50                   	push   %eax
80100a9d:	e8 4a 61 00 00       	call   80106bec <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 20 62 00 00       	call   80106ce1 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	83 c4 10             	add    $0x10,%esp
80100ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100acc:	8d 34 98             	lea    (%eax,%ebx,4),%esi
80100acf:	8b 06                	mov    (%esi),%eax
80100ad1:	85 c0                	test   %eax,%eax
80100ad3:	74 4d                	je     80100b22 <exec+0x250>
    if(argc >= MAXARG)
80100ad5:	83 fb 1f             	cmp    $0x1f,%ebx
80100ad8:	0f 87 0d 01 00 00    	ja     80100beb <exec+0x319>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 ae 3c 00 00       	call   80104795 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 9c 3c 00 00       	call   80104795 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 24 63 00 00       	call   80106e2f <copyout>
80100b0b:	83 c4 20             	add    $0x20,%esp
80100b0e:	85 c0                	test   %eax,%eax
80100b10:	0f 88 df 00 00 00    	js     80100bf5 <exec+0x323>
    ustack[3+argc] = sp;
80100b16:	89 bc 9d 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100b1d:	83 c3 01             	add    $0x1,%ebx
80100b20:	eb a7                	jmp    80100ac9 <exec+0x1f7>
  ustack[3+argc] = 0;
80100b22:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100b29:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2d:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b34:	ff ff ff 
  ustack[1] = argc;
80100b37:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100b44:	89 f9                	mov    %edi,%ecx
80100b46:	29 c1                	sub    %eax,%ecx
80100b48:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b4e:	8d 04 9d 10 00 00 00 	lea    0x10(,%ebx,4),%eax
80100b55:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b57:	50                   	push   %eax
80100b58:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b5e:	50                   	push   %eax
80100b5f:	57                   	push   %edi
80100b60:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b66:	e8 c4 62 00 00       	call   80106e2f <copyout>
80100b6b:	83 c4 10             	add    $0x10,%esp
80100b6e:	85 c0                	test   %eax,%eax
80100b70:	0f 88 89 00 00 00    	js     80100bff <exec+0x32d>
  for(last=s=path; *s; s++)
80100b76:	8b 55 08             	mov    0x8(%ebp),%edx
80100b79:	89 d0                	mov    %edx,%eax
80100b7b:	eb 03                	jmp    80100b80 <exec+0x2ae>
80100b7d:	83 c0 01             	add    $0x1,%eax
80100b80:	0f b6 08             	movzbl (%eax),%ecx
80100b83:	84 c9                	test   %cl,%cl
80100b85:	74 0a                	je     80100b91 <exec+0x2bf>
    if(*s == '/')
80100b87:	80 f9 2f             	cmp    $0x2f,%cl
80100b8a:	75 f1                	jne    80100b7d <exec+0x2ab>
      last = s+1;
80100b8c:	8d 50 01             	lea    0x1(%eax),%edx
80100b8f:	eb ec                	jmp    80100b7d <exec+0x2ab>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b91:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100b97:	89 f0                	mov    %esi,%eax
80100b99:	83 c0 6c             	add    $0x6c,%eax
80100b9c:	83 ec 04             	sub    $0x4,%esp
80100b9f:	6a 10                	push   $0x10
80100ba1:	52                   	push   %edx
80100ba2:	50                   	push   %eax
80100ba3:	e8 b2 3b 00 00       	call   8010475a <safestrcpy>
  oldpgdir = curproc->pgdir;
80100ba8:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bab:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bb1:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bb4:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bba:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bbc:	8b 46 18             	mov    0x18(%esi),%eax
80100bbf:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bce:	89 34 24             	mov    %esi,(%esp)
80100bd1:	e8 79 5c 00 00       	call   8010684f <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 0e 60 00 00       	call   80106bec <freevm>
  return 0;
80100bde:	83 c4 10             	add    $0x10,%esp
80100be1:	b8 00 00 00 00       	mov    $0x0,%eax
80100be6:	e9 57 fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100beb:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf0:	e9 96 fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfa:	e9 8c fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bff:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c04:	e9 82 fe ff ff       	jmp    80100a8b <exec+0x1b9>
  return -1;
80100c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0e:	e9 2f fd ff ff       	jmp    80100942 <exec+0x70>

80100c13 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c13:	55                   	push   %ebp
80100c14:	89 e5                	mov    %esp,%ebp
80100c16:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c19:	68 4d 6f 10 80       	push   $0x80106f4d
80100c1e:	68 e0 03 11 80       	push   $0x801103e0
80100c23:	e8 e3 37 00 00       	call   8010440b <initlock>
}
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	c9                   	leave  
80100c2c:	c3                   	ret    

80100c2d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c2d:	55                   	push   %ebp
80100c2e:	89 e5                	mov    %esp,%ebp
80100c30:	53                   	push   %ebx
80100c31:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c34:	68 e0 03 11 80       	push   $0x801103e0
80100c39:	e8 09 39 00 00       	call   80104547 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb 14 04 11 80       	mov    $0x80110414,%ebx
80100c46:	81 fb 74 0d 11 80    	cmp    $0x80110d74,%ebx
80100c4c:	73 29                	jae    80100c77 <filealloc+0x4a>
    if(f->ref == 0){
80100c4e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c52:	74 05                	je     80100c59 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c54:	83 c3 18             	add    $0x18,%ebx
80100c57:	eb ed                	jmp    80100c46 <filealloc+0x19>
      f->ref = 1;
80100c59:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c60:	83 ec 0c             	sub    $0xc,%esp
80100c63:	68 e0 03 11 80       	push   $0x801103e0
80100c68:	e8 3f 39 00 00       	call   801045ac <release>
      return f;
80100c6d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c70:	89 d8                	mov    %ebx,%eax
80100c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c75:	c9                   	leave  
80100c76:	c3                   	ret    
  release(&ftable.lock);
80100c77:	83 ec 0c             	sub    $0xc,%esp
80100c7a:	68 e0 03 11 80       	push   $0x801103e0
80100c7f:	e8 28 39 00 00       	call   801045ac <release>
  return 0;
80100c84:	83 c4 10             	add    $0x10,%esp
80100c87:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c8c:	eb e2                	jmp    80100c70 <filealloc+0x43>

80100c8e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	53                   	push   %ebx
80100c92:	83 ec 10             	sub    $0x10,%esp
80100c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c98:	68 e0 03 11 80       	push   $0x801103e0
80100c9d:	e8 a5 38 00 00       	call   80104547 <acquire>
  if(f->ref < 1)
80100ca2:	8b 43 04             	mov    0x4(%ebx),%eax
80100ca5:	83 c4 10             	add    $0x10,%esp
80100ca8:	85 c0                	test   %eax,%eax
80100caa:	7e 1a                	jle    80100cc6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cac:	83 c0 01             	add    $0x1,%eax
80100caf:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cb2:	83 ec 0c             	sub    $0xc,%esp
80100cb5:	68 e0 03 11 80       	push   $0x801103e0
80100cba:	e8 ed 38 00 00       	call   801045ac <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 54 6f 10 80       	push   $0x80106f54
80100cce:	e8 75 f6 ff ff       	call   80100348 <panic>

80100cd3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cd3:	55                   	push   %ebp
80100cd4:	89 e5                	mov    %esp,%ebp
80100cd6:	53                   	push   %ebx
80100cd7:	83 ec 30             	sub    $0x30,%esp
80100cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cdd:	68 e0 03 11 80       	push   $0x801103e0
80100ce2:	e8 60 38 00 00       	call   80104547 <acquire>
  if(f->ref < 1)
80100ce7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cea:	83 c4 10             	add    $0x10,%esp
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 1f                	jle    80100d10 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cf1:	83 e8 01             	sub    $0x1,%eax
80100cf4:	89 43 04             	mov    %eax,0x4(%ebx)
80100cf7:	85 c0                	test   %eax,%eax
80100cf9:	7e 22                	jle    80100d1d <fileclose+0x4a>
    release(&ftable.lock);
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	68 e0 03 11 80       	push   $0x801103e0
80100d03:	e8 a4 38 00 00       	call   801045ac <release>
    return;
80100d08:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d0e:	c9                   	leave  
80100d0f:	c3                   	ret    
    panic("fileclose");
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	68 5c 6f 10 80       	push   $0x80106f5c
80100d18:	e8 2b f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d1d:	8b 03                	mov    (%ebx),%eax
80100d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d22:	8b 43 08             	mov    0x8(%ebx),%eax
80100d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d28:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d2e:	8b 43 10             	mov    0x10(%ebx),%eax
80100d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d34:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	68 e0 03 11 80       	push   $0x801103e0
80100d49:	e8 5e 38 00 00       	call   801045ac <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 4b 1a 00 00       	call   801027ae <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 b5 1a 00 00       	call   80102828 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 9a 20 00 00       	call   80102e22 <pipeclose>
80100d88:	83 c4 10             	add    $0x10,%esp
80100d8b:	e9 7b ff ff ff       	jmp    80100d0b <fileclose+0x38>

80100d90 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d90:	55                   	push   %ebp
80100d91:	89 e5                	mov    %esp,%ebp
80100d93:	53                   	push   %ebx
80100d94:	83 ec 04             	sub    $0x4,%esp
80100d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d9a:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d9d:	75 31                	jne    80100dd0 <filestat+0x40>
    ilock(f->ip);
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	ff 73 10             	pushl  0x10(%ebx)
80100da5:	e8 d7 07 00 00       	call   80101581 <ilock>
    stati(f->ip, st);
80100daa:	83 c4 08             	add    $0x8,%esp
80100dad:	ff 75 0c             	pushl  0xc(%ebp)
80100db0:	ff 73 10             	pushl  0x10(%ebx)
80100db3:	e8 90 09 00 00       	call   80101748 <stati>
    iunlock(f->ip);
80100db8:	83 c4 04             	add    $0x4,%esp
80100dbb:	ff 73 10             	pushl  0x10(%ebx)
80100dbe:	e8 80 08 00 00       	call   80101643 <iunlock>
    return 0;
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dce:	c9                   	leave  
80100dcf:	c3                   	ret    
  return -1;
80100dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dd5:	eb f4                	jmp    80100dcb <filestat+0x3b>

80100dd7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd7:	55                   	push   %ebp
80100dd8:	89 e5                	mov    %esp,%ebp
80100dda:	56                   	push   %esi
80100ddb:	53                   	push   %ebx
80100ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100ddf:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100de3:	74 70                	je     80100e55 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100de5:	8b 03                	mov    (%ebx),%eax
80100de7:	83 f8 01             	cmp    $0x1,%eax
80100dea:	74 44                	je     80100e30 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100dec:	83 f8 02             	cmp    $0x2,%eax
80100def:	75 57                	jne    80100e48 <fileread+0x71>
    ilock(f->ip);
80100df1:	83 ec 0c             	sub    $0xc,%esp
80100df4:	ff 73 10             	pushl  0x10(%ebx)
80100df7:	e8 85 07 00 00       	call   80101581 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dfc:	ff 75 10             	pushl  0x10(%ebp)
80100dff:	ff 73 14             	pushl  0x14(%ebx)
80100e02:	ff 75 0c             	pushl  0xc(%ebp)
80100e05:	ff 73 10             	pushl  0x10(%ebx)
80100e08:	e8 66 09 00 00       	call   80101773 <readi>
80100e0d:	89 c6                	mov    %eax,%esi
80100e0f:	83 c4 20             	add    $0x20,%esp
80100e12:	85 c0                	test   %eax,%eax
80100e14:	7e 03                	jle    80100e19 <fileread+0x42>
      f->off += r;
80100e16:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e19:	83 ec 0c             	sub    $0xc,%esp
80100e1c:	ff 73 10             	pushl  0x10(%ebx)
80100e1f:	e8 1f 08 00 00       	call   80101643 <iunlock>
    return r;
80100e24:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e27:	89 f0                	mov    %esi,%eax
80100e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e2c:	5b                   	pop    %ebx
80100e2d:	5e                   	pop    %esi
80100e2e:	5d                   	pop    %ebp
80100e2f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e30:	83 ec 04             	sub    $0x4,%esp
80100e33:	ff 75 10             	pushl  0x10(%ebp)
80100e36:	ff 75 0c             	pushl  0xc(%ebp)
80100e39:	ff 73 0c             	pushl  0xc(%ebx)
80100e3c:	e8 39 21 00 00       	call   80102f7a <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 66 6f 10 80       	push   $0x80106f66
80100e50:	e8 f3 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e55:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e5a:	eb cb                	jmp    80100e27 <fileread+0x50>

80100e5c <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e5c:	55                   	push   %ebp
80100e5d:	89 e5                	mov    %esp,%ebp
80100e5f:	57                   	push   %edi
80100e60:	56                   	push   %esi
80100e61:	53                   	push   %ebx
80100e62:	83 ec 1c             	sub    $0x1c,%esp
80100e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e68:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e6c:	0f 84 c5 00 00 00    	je     80100f37 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e72:	8b 03                	mov    (%ebx),%eax
80100e74:	83 f8 01             	cmp    $0x1,%eax
80100e77:	74 10                	je     80100e89 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e79:	83 f8 02             	cmp    $0x2,%eax
80100e7c:	0f 85 a8 00 00 00    	jne    80100f2a <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e82:	bf 00 00 00 00       	mov    $0x0,%edi
80100e87:	eb 67                	jmp    80100ef0 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e89:	83 ec 04             	sub    $0x4,%esp
80100e8c:	ff 75 10             	pushl  0x10(%ebp)
80100e8f:	ff 75 0c             	pushl  0xc(%ebp)
80100e92:	ff 73 0c             	pushl  0xc(%ebx)
80100e95:	e8 14 20 00 00       	call   80102eae <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 07 19 00 00       	call   801027ae <begin_op>
      ilock(f->ip);
80100ea7:	83 ec 0c             	sub    $0xc,%esp
80100eaa:	ff 73 10             	pushl  0x10(%ebx)
80100ead:	e8 cf 06 00 00       	call   80101581 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100eb2:	89 f8                	mov    %edi,%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
80100eba:	ff 73 14             	pushl  0x14(%ebx)
80100ebd:	50                   	push   %eax
80100ebe:	ff 73 10             	pushl  0x10(%ebx)
80100ec1:	e8 aa 09 00 00       	call   80101870 <writei>
80100ec6:	89 c6                	mov    %eax,%esi
80100ec8:	83 c4 20             	add    $0x20,%esp
80100ecb:	85 c0                	test   %eax,%eax
80100ecd:	7e 03                	jle    80100ed2 <filewrite+0x76>
        f->off += r;
80100ecf:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ed2:	83 ec 0c             	sub    $0xc,%esp
80100ed5:	ff 73 10             	pushl  0x10(%ebx)
80100ed8:	e8 66 07 00 00       	call   80101643 <iunlock>
      end_op();
80100edd:	e8 46 19 00 00       	call   80102828 <end_op>

      if(r < 0)
80100ee2:	83 c4 10             	add    $0x10,%esp
80100ee5:	85 f6                	test   %esi,%esi
80100ee7:	78 31                	js     80100f1a <filewrite+0xbe>
        break;
      if(r != n1)
80100ee9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100eec:	75 1f                	jne    80100f0d <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eee:	01 f7                	add    %esi,%edi
    while(i < n){
80100ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ef3:	7d 25                	jge    80100f1a <filewrite+0xbe>
      int n1 = n - i;
80100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef8:	29 f8                	sub    %edi,%eax
80100efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100efd:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f02:	7e 9e                	jle    80100ea2 <filewrite+0x46>
        n1 = max;
80100f04:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f0b:	eb 95                	jmp    80100ea2 <filewrite+0x46>
        panic("short filewrite");
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	68 6f 6f 10 80       	push   $0x80106f6f
80100f15:	e8 2e f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f1d:	75 1f                	jne    80100f3e <filewrite+0xe2>
80100f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f25:	5b                   	pop    %ebx
80100f26:	5e                   	pop    %esi
80100f27:	5f                   	pop    %edi
80100f28:	5d                   	pop    %ebp
80100f29:	c3                   	ret    
  panic("filewrite");
80100f2a:	83 ec 0c             	sub    $0xc,%esp
80100f2d:	68 75 6f 10 80       	push   $0x80106f75
80100f32:	e8 11 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f3c:	eb e4                	jmp    80100f22 <filewrite+0xc6>
    return i == n ? n : -1;
80100f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f43:	eb dd                	jmp    80100f22 <filewrite+0xc6>

80100f45 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f45:	55                   	push   %ebp
80100f46:	89 e5                	mov    %esp,%ebp
80100f48:	57                   	push   %edi
80100f49:	56                   	push   %esi
80100f4a:	53                   	push   %ebx
80100f4b:	83 ec 0c             	sub    $0xc,%esp
80100f4e:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f50:	eb 03                	jmp    80100f55 <skipelem+0x10>
    path++;
80100f52:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f55:	0f b6 10             	movzbl (%eax),%edx
80100f58:	80 fa 2f             	cmp    $0x2f,%dl
80100f5b:	74 f5                	je     80100f52 <skipelem+0xd>
  if(*path == 0)
80100f5d:	84 d2                	test   %dl,%dl
80100f5f:	74 59                	je     80100fba <skipelem+0x75>
80100f61:	89 c3                	mov    %eax,%ebx
80100f63:	eb 03                	jmp    80100f68 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f65:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f68:	0f b6 13             	movzbl (%ebx),%edx
80100f6b:	80 fa 2f             	cmp    $0x2f,%dl
80100f6e:	0f 95 c1             	setne  %cl
80100f71:	84 d2                	test   %dl,%dl
80100f73:	0f 95 c2             	setne  %dl
80100f76:	84 d1                	test   %dl,%cl
80100f78:	75 eb                	jne    80100f65 <skipelem+0x20>
  len = path - s;
80100f7a:	89 de                	mov    %ebx,%esi
80100f7c:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f7e:	83 fe 0d             	cmp    $0xd,%esi
80100f81:	7e 11                	jle    80100f94 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f83:	83 ec 04             	sub    $0x4,%esp
80100f86:	6a 0e                	push   $0xe
80100f88:	50                   	push   %eax
80100f89:	57                   	push   %edi
80100f8a:	e8 df 36 00 00       	call   8010466e <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 cf 36 00 00       	call   8010466e <memmove>
    name[len] = 0;
80100f9f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fa3:	83 c4 10             	add    $0x10,%esp
80100fa6:	eb 03                	jmp    80100fab <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fa8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fab:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fae:	74 f8                	je     80100fa8 <skipelem+0x63>
  return path;
}
80100fb0:	89 d8                	mov    %ebx,%eax
80100fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fb5:	5b                   	pop    %ebx
80100fb6:	5e                   	pop    %esi
80100fb7:	5f                   	pop    %edi
80100fb8:	5d                   	pop    %ebp
80100fb9:	c3                   	ret    
    return 0;
80100fba:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fbf:	eb ef                	jmp    80100fb0 <skipelem+0x6b>

80100fc1 <bzero>:
{
80100fc1:	55                   	push   %ebp
80100fc2:	89 e5                	mov    %esp,%ebp
80100fc4:	53                   	push   %ebx
80100fc5:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fc8:	52                   	push   %edx
80100fc9:	50                   	push   %eax
80100fca:	e8 9d f1 ff ff       	call   8010016c <bread>
80100fcf:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fd1:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fd4:	83 c4 0c             	add    $0xc,%esp
80100fd7:	68 00 02 00 00       	push   $0x200
80100fdc:	6a 00                	push   $0x0
80100fde:	50                   	push   %eax
80100fdf:	e8 0f 36 00 00       	call   801045f3 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 eb 18 00 00       	call   801028d7 <log_write>
  brelse(bp);
80100fec:	89 1c 24             	mov    %ebx,(%esp)
80100fef:	e8 e1 f1 ff ff       	call   801001d5 <brelse>
}
80100ff4:	83 c4 10             	add    $0x10,%esp
80100ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ffa:	c9                   	leave  
80100ffb:	c3                   	ret    

80100ffc <balloc>:
{
80100ffc:	55                   	push   %ebp
80100ffd:	89 e5                	mov    %esp,%ebp
80100fff:	57                   	push   %edi
80101000:	56                   	push   %esi
80101001:	53                   	push   %ebx
80101002:	83 ec 1c             	sub    $0x1c,%esp
80101005:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101008:	be 00 00 00 00       	mov    $0x0,%esi
8010100d:	eb 14                	jmp    80101023 <balloc+0x27>
    brelse(bp);
8010100f:	83 ec 0c             	sub    $0xc,%esp
80101012:	ff 75 e4             	pushl  -0x1c(%ebp)
80101015:	e8 bb f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010101a:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101020:	83 c4 10             	add    $0x10,%esp
80101023:	39 35 e0 0d 11 80    	cmp    %esi,0x80110de0
80101029:	76 75                	jbe    801010a0 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010102b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101031:	85 f6                	test   %esi,%esi
80101033:	0f 49 c6             	cmovns %esi,%eax
80101036:	c1 f8 0c             	sar    $0xc,%eax
80101039:	03 05 f8 0d 11 80    	add    0x80110df8,%eax
8010103f:	83 ec 08             	sub    $0x8,%esp
80101042:	50                   	push   %eax
80101043:	ff 75 d8             	pushl  -0x28(%ebp)
80101046:	e8 21 f1 ff ff       	call   8010016c <bread>
8010104b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010104e:	83 c4 10             	add    $0x10,%esp
80101051:	b8 00 00 00 00       	mov    $0x0,%eax
80101056:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010105b:	7f b2                	jg     8010100f <balloc+0x13>
8010105d:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80101060:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101063:	3b 1d e0 0d 11 80    	cmp    0x80110de0,%ebx
80101069:	73 a4                	jae    8010100f <balloc+0x13>
      m = 1 << (bi % 8);
8010106b:	99                   	cltd   
8010106c:	c1 ea 1d             	shr    $0x1d,%edx
8010106f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80101072:	83 e1 07             	and    $0x7,%ecx
80101075:	29 d1                	sub    %edx,%ecx
80101077:	ba 01 00 00 00       	mov    $0x1,%edx
8010107c:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010107e:	8d 48 07             	lea    0x7(%eax),%ecx
80101081:	85 c0                	test   %eax,%eax
80101083:	0f 49 c8             	cmovns %eax,%ecx
80101086:	c1 f9 03             	sar    $0x3,%ecx
80101089:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010108c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010108f:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
80101094:	0f b6 f9             	movzbl %cl,%edi
80101097:	85 d7                	test   %edx,%edi
80101099:	74 12                	je     801010ad <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010109b:	83 c0 01             	add    $0x1,%eax
8010109e:	eb b6                	jmp    80101056 <balloc+0x5a>
  panic("balloc: out of blocks");
801010a0:	83 ec 0c             	sub    $0xc,%esp
801010a3:	68 7f 6f 10 80       	push   $0x80106f7f
801010a8:	e8 9b f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010ad:	09 ca                	or     %ecx,%edx
801010af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b2:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010b5:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010b9:	83 ec 0c             	sub    $0xc,%esp
801010bc:	89 c6                	mov    %eax,%esi
801010be:	50                   	push   %eax
801010bf:	e8 13 18 00 00       	call   801028d7 <log_write>
        brelse(bp);
801010c4:	89 34 24             	mov    %esi,(%esp)
801010c7:	e8 09 f1 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
801010cc:	89 da                	mov    %ebx,%edx
801010ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010d1:	e8 eb fe ff ff       	call   80100fc1 <bzero>
}
801010d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010dc:	5b                   	pop    %ebx
801010dd:	5e                   	pop    %esi
801010de:	5f                   	pop    %edi
801010df:	5d                   	pop    %ebp
801010e0:	c3                   	ret    

801010e1 <bmap>:
{
801010e1:	55                   	push   %ebp
801010e2:	89 e5                	mov    %esp,%ebp
801010e4:	57                   	push   %edi
801010e5:	56                   	push   %esi
801010e6:	53                   	push   %ebx
801010e7:	83 ec 1c             	sub    $0x1c,%esp
801010ea:	89 c6                	mov    %eax,%esi
801010ec:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801010ee:	83 fa 0b             	cmp    $0xb,%edx
801010f1:	77 17                	ja     8010110a <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
801010f3:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
801010f7:	85 db                	test   %ebx,%ebx
801010f9:	75 4a                	jne    80101145 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010fb:	8b 00                	mov    (%eax),%eax
801010fd:	e8 fa fe ff ff       	call   80100ffc <balloc>
80101102:	89 c3                	mov    %eax,%ebx
80101104:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101108:	eb 3b                	jmp    80101145 <bmap+0x64>
  bn -= NDIRECT;
8010110a:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
8010110d:	83 fb 7f             	cmp    $0x7f,%ebx
80101110:	77 68                	ja     8010117a <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101112:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101118:	85 c0                	test   %eax,%eax
8010111a:	74 33                	je     8010114f <bmap+0x6e>
    bp = bread(ip->dev, addr);
8010111c:	83 ec 08             	sub    $0x8,%esp
8010111f:	50                   	push   %eax
80101120:	ff 36                	pushl  (%esi)
80101122:	e8 45 f0 ff ff       	call   8010016c <bread>
80101127:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101129:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
8010112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101130:	8b 18                	mov    (%eax),%ebx
80101132:	83 c4 10             	add    $0x10,%esp
80101135:	85 db                	test   %ebx,%ebx
80101137:	74 25                	je     8010115e <bmap+0x7d>
    brelse(bp);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	57                   	push   %edi
8010113d:	e8 93 f0 ff ff       	call   801001d5 <brelse>
    return addr;
80101142:	83 c4 10             	add    $0x10,%esp
}
80101145:	89 d8                	mov    %ebx,%eax
80101147:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114a:	5b                   	pop    %ebx
8010114b:	5e                   	pop    %esi
8010114c:	5f                   	pop    %edi
8010114d:	5d                   	pop    %ebp
8010114e:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010114f:	8b 06                	mov    (%esi),%eax
80101151:	e8 a6 fe ff ff       	call   80100ffc <balloc>
80101156:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
8010115c:	eb be                	jmp    8010111c <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
8010115e:	8b 06                	mov    (%esi),%eax
80101160:	e8 97 fe ff ff       	call   80100ffc <balloc>
80101165:	89 c3                	mov    %eax,%ebx
80101167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010116a:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
8010116c:	83 ec 0c             	sub    $0xc,%esp
8010116f:	57                   	push   %edi
80101170:	e8 62 17 00 00       	call   801028d7 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 95 6f 10 80       	push   $0x80106f95
80101182:	e8 c1 f1 ff ff       	call   80100348 <panic>

80101187 <iget>:
{
80101187:	55                   	push   %ebp
80101188:	89 e5                	mov    %esp,%ebp
8010118a:	57                   	push   %edi
8010118b:	56                   	push   %esi
8010118c:	53                   	push   %ebx
8010118d:	83 ec 28             	sub    $0x28,%esp
80101190:	89 c7                	mov    %eax,%edi
80101192:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101195:	68 00 0e 11 80       	push   $0x80110e00
8010119a:	e8 a8 33 00 00       	call   80104547 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010119f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011a2:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011a7:	bb 34 0e 11 80       	mov    $0x80110e34,%ebx
801011ac:	eb 0a                	jmp    801011b8 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ae:	85 f6                	test   %esi,%esi
801011b0:	74 3b                	je     801011ed <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b2:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011b8:	81 fb 54 2a 11 80    	cmp    $0x80112a54,%ebx
801011be:	73 35                	jae    801011f5 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011c0:	8b 43 08             	mov    0x8(%ebx),%eax
801011c3:	85 c0                	test   %eax,%eax
801011c5:	7e e7                	jle    801011ae <iget+0x27>
801011c7:	39 3b                	cmp    %edi,(%ebx)
801011c9:	75 e3                	jne    801011ae <iget+0x27>
801011cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011ce:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011d1:	75 db                	jne    801011ae <iget+0x27>
      ip->ref++;
801011d3:	83 c0 01             	add    $0x1,%eax
801011d6:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801011d9:	83 ec 0c             	sub    $0xc,%esp
801011dc:	68 00 0e 11 80       	push   $0x80110e00
801011e1:	e8 c6 33 00 00       	call   801045ac <release>
      return ip;
801011e6:	83 c4 10             	add    $0x10,%esp
801011e9:	89 de                	mov    %ebx,%esi
801011eb:	eb 32                	jmp    8010121f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ed:	85 c0                	test   %eax,%eax
801011ef:	75 c1                	jne    801011b2 <iget+0x2b>
      empty = ip;
801011f1:	89 de                	mov    %ebx,%esi
801011f3:	eb bd                	jmp    801011b2 <iget+0x2b>
  if(empty == 0)
801011f5:	85 f6                	test   %esi,%esi
801011f7:	74 30                	je     80101229 <iget+0xa2>
  ip->dev = dev;
801011f9:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011fe:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101201:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101208:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010120f:	83 ec 0c             	sub    $0xc,%esp
80101212:	68 00 0e 11 80       	push   $0x80110e00
80101217:	e8 90 33 00 00       	call   801045ac <release>
  return ip;
8010121c:	83 c4 10             	add    $0x10,%esp
}
8010121f:	89 f0                	mov    %esi,%eax
80101221:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101224:	5b                   	pop    %ebx
80101225:	5e                   	pop    %esi
80101226:	5f                   	pop    %edi
80101227:	5d                   	pop    %ebp
80101228:	c3                   	ret    
    panic("iget: no inodes");
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	68 a8 6f 10 80       	push   $0x80106fa8
80101231:	e8 12 f1 ff ff       	call   80100348 <panic>

80101236 <readsb>:
{
80101236:	55                   	push   %ebp
80101237:	89 e5                	mov    %esp,%ebp
80101239:	53                   	push   %ebx
8010123a:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
8010123d:	6a 01                	push   $0x1
8010123f:	ff 75 08             	pushl  0x8(%ebp)
80101242:	e8 25 ef ff ff       	call   8010016c <bread>
80101247:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101249:	8d 40 5c             	lea    0x5c(%eax),%eax
8010124c:	83 c4 0c             	add    $0xc,%esp
8010124f:	6a 1c                	push   $0x1c
80101251:	50                   	push   %eax
80101252:	ff 75 0c             	pushl  0xc(%ebp)
80101255:	e8 14 34 00 00       	call   8010466e <memmove>
  brelse(bp);
8010125a:	89 1c 24             	mov    %ebx,(%esp)
8010125d:	e8 73 ef ff ff       	call   801001d5 <brelse>
}
80101262:	83 c4 10             	add    $0x10,%esp
80101265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101268:	c9                   	leave  
80101269:	c3                   	ret    

8010126a <bfree>:
{
8010126a:	55                   	push   %ebp
8010126b:	89 e5                	mov    %esp,%ebp
8010126d:	56                   	push   %esi
8010126e:	53                   	push   %ebx
8010126f:	89 c6                	mov    %eax,%esi
80101271:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
80101273:	83 ec 08             	sub    $0x8,%esp
80101276:	68 e0 0d 11 80       	push   $0x80110de0
8010127b:	50                   	push   %eax
8010127c:	e8 b5 ff ff ff       	call   80101236 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101281:	89 d8                	mov    %ebx,%eax
80101283:	c1 e8 0c             	shr    $0xc,%eax
80101286:	03 05 f8 0d 11 80    	add    0x80110df8,%eax
8010128c:	83 c4 08             	add    $0x8,%esp
8010128f:	50                   	push   %eax
80101290:	56                   	push   %esi
80101291:	e8 d6 ee ff ff       	call   8010016c <bread>
80101296:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101298:	89 d9                	mov    %ebx,%ecx
8010129a:	83 e1 07             	and    $0x7,%ecx
8010129d:	b8 01 00 00 00       	mov    $0x1,%eax
801012a2:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012a4:	83 c4 10             	add    $0x10,%esp
801012a7:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012ad:	c1 fb 03             	sar    $0x3,%ebx
801012b0:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012b5:	0f b6 ca             	movzbl %dl,%ecx
801012b8:	85 c1                	test   %eax,%ecx
801012ba:	74 23                	je     801012df <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012bc:	f7 d0                	not    %eax
801012be:	21 d0                	and    %edx,%eax
801012c0:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012c4:	83 ec 0c             	sub    $0xc,%esp
801012c7:	56                   	push   %esi
801012c8:	e8 0a 16 00 00       	call   801028d7 <log_write>
  brelse(bp);
801012cd:	89 34 24             	mov    %esi,(%esp)
801012d0:	e8 00 ef ff ff       	call   801001d5 <brelse>
}
801012d5:	83 c4 10             	add    $0x10,%esp
801012d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012db:	5b                   	pop    %ebx
801012dc:	5e                   	pop    %esi
801012dd:	5d                   	pop    %ebp
801012de:	c3                   	ret    
    panic("freeing free block");
801012df:	83 ec 0c             	sub    $0xc,%esp
801012e2:	68 b8 6f 10 80       	push   $0x80106fb8
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 cb 6f 10 80       	push   $0x80106fcb
801012f8:	68 00 0e 11 80       	push   $0x80110e00
801012fd:	e8 09 31 00 00       	call   8010440b <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 d2 6f 10 80       	push   $0x80106fd2
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 40 0e 11 80       	add    $0x80110e40,%eax
80101321:	50                   	push   %eax
80101322:	e8 d9 2f 00 00       	call   80104300 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101327:	83 c3 01             	add    $0x1,%ebx
8010132a:	83 c4 10             	add    $0x10,%esp
8010132d:	83 fb 31             	cmp    $0x31,%ebx
80101330:	7e da                	jle    8010130c <iinit+0x20>
  readsb(dev, &sb);
80101332:	83 ec 08             	sub    $0x8,%esp
80101335:	68 e0 0d 11 80       	push   $0x80110de0
8010133a:	ff 75 08             	pushl  0x8(%ebp)
8010133d:	e8 f4 fe ff ff       	call   80101236 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101342:	ff 35 f8 0d 11 80    	pushl  0x80110df8
80101348:	ff 35 f4 0d 11 80    	pushl  0x80110df4
8010134e:	ff 35 f0 0d 11 80    	pushl  0x80110df0
80101354:	ff 35 ec 0d 11 80    	pushl  0x80110dec
8010135a:	ff 35 e8 0d 11 80    	pushl  0x80110de8
80101360:	ff 35 e4 0d 11 80    	pushl  0x80110de4
80101366:	ff 35 e0 0d 11 80    	pushl  0x80110de0
8010136c:	68 38 70 10 80       	push   $0x80107038
80101371:	e8 95 f2 ff ff       	call   8010060b <cprintf>
}
80101376:	83 c4 30             	add    $0x30,%esp
80101379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <ialloc>:
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	57                   	push   %edi
80101382:	56                   	push   %esi
80101383:	53                   	push   %ebx
80101384:	83 ec 1c             	sub    $0x1c,%esp
80101387:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010138d:	bb 01 00 00 00       	mov    $0x1,%ebx
80101392:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101395:	39 1d e8 0d 11 80    	cmp    %ebx,0x80110de8
8010139b:	76 3f                	jbe    801013dc <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010139d:	89 d8                	mov    %ebx,%eax
8010139f:	c1 e8 03             	shr    $0x3,%eax
801013a2:	03 05 f4 0d 11 80    	add    0x80110df4,%eax
801013a8:	83 ec 08             	sub    $0x8,%esp
801013ab:	50                   	push   %eax
801013ac:	ff 75 08             	pushl  0x8(%ebp)
801013af:	e8 b8 ed ff ff       	call   8010016c <bread>
801013b4:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013b6:	89 d8                	mov    %ebx,%eax
801013b8:	83 e0 07             	and    $0x7,%eax
801013bb:	c1 e0 06             	shl    $0x6,%eax
801013be:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013c2:	83 c4 10             	add    $0x10,%esp
801013c5:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013c9:	74 1e                	je     801013e9 <ialloc+0x6b>
    brelse(bp);
801013cb:	83 ec 0c             	sub    $0xc,%esp
801013ce:	56                   	push   %esi
801013cf:	e8 01 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013d4:	83 c3 01             	add    $0x1,%ebx
801013d7:	83 c4 10             	add    $0x10,%esp
801013da:	eb b6                	jmp    80101392 <ialloc+0x14>
  panic("ialloc: no inodes");
801013dc:	83 ec 0c             	sub    $0xc,%esp
801013df:	68 d8 6f 10 80       	push   $0x80106fd8
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 fd 31 00 00       	call   801045f3 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 d2 14 00 00       	call   801028d7 <log_write>
      brelse(bp);
80101405:	89 34 24             	mov    %esi,(%esp)
80101408:	e8 c8 ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
8010140d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	e8 6f fd ff ff       	call   80101187 <iget>
}
80101418:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010141b:	5b                   	pop    %ebx
8010141c:	5e                   	pop    %esi
8010141d:	5f                   	pop    %edi
8010141e:	5d                   	pop    %ebp
8010141f:	c3                   	ret    

80101420 <iupdate>:
{
80101420:	55                   	push   %ebp
80101421:	89 e5                	mov    %esp,%ebp
80101423:	56                   	push   %esi
80101424:	53                   	push   %ebx
80101425:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101428:	8b 43 04             	mov    0x4(%ebx),%eax
8010142b:	c1 e8 03             	shr    $0x3,%eax
8010142e:	03 05 f4 0d 11 80    	add    0x80110df4,%eax
80101434:	83 ec 08             	sub    $0x8,%esp
80101437:	50                   	push   %eax
80101438:	ff 33                	pushl  (%ebx)
8010143a:	e8 2d ed ff ff       	call   8010016c <bread>
8010143f:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101441:	8b 43 04             	mov    0x4(%ebx),%eax
80101444:	83 e0 07             	and    $0x7,%eax
80101447:	c1 e0 06             	shl    $0x6,%eax
8010144a:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010144e:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101452:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101455:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101459:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010145d:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
80101461:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101465:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101469:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010146d:	8b 53 58             	mov    0x58(%ebx),%edx
80101470:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101473:	83 c3 5c             	add    $0x5c,%ebx
80101476:	83 c0 0c             	add    $0xc,%eax
80101479:	83 c4 0c             	add    $0xc,%esp
8010147c:	6a 34                	push   $0x34
8010147e:	53                   	push   %ebx
8010147f:	50                   	push   %eax
80101480:	e8 e9 31 00 00       	call   8010466e <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 4a 14 00 00       	call   801028d7 <log_write>
  brelse(bp);
8010148d:	89 34 24             	mov    %esi,(%esp)
80101490:	e8 40 ed ff ff       	call   801001d5 <brelse>
}
80101495:	83 c4 10             	add    $0x10,%esp
80101498:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010149b:	5b                   	pop    %ebx
8010149c:	5e                   	pop    %esi
8010149d:	5d                   	pop    %ebp
8010149e:	c3                   	ret    

8010149f <itrunc>:
{
8010149f:	55                   	push   %ebp
801014a0:	89 e5                	mov    %esp,%ebp
801014a2:	57                   	push   %edi
801014a3:	56                   	push   %esi
801014a4:	53                   	push   %ebx
801014a5:	83 ec 1c             	sub    $0x1c,%esp
801014a8:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
801014af:	eb 03                	jmp    801014b4 <itrunc+0x15>
801014b1:	83 c3 01             	add    $0x1,%ebx
801014b4:	83 fb 0b             	cmp    $0xb,%ebx
801014b7:	7f 19                	jg     801014d2 <itrunc+0x33>
    if(ip->addrs[i]){
801014b9:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014bd:	85 d2                	test   %edx,%edx
801014bf:	74 f0                	je     801014b1 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014c1:	8b 06                	mov    (%esi),%eax
801014c3:	e8 a2 fd ff ff       	call   8010126a <bfree>
      ip->addrs[i] = 0;
801014c8:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014cf:	00 
801014d0:	eb df                	jmp    801014b1 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014d2:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014d8:	85 c0                	test   %eax,%eax
801014da:	75 1b                	jne    801014f7 <itrunc+0x58>
  ip->size = 0;
801014dc:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014e3:	83 ec 0c             	sub    $0xc,%esp
801014e6:	56                   	push   %esi
801014e7:	e8 34 ff ff ff       	call   80101420 <iupdate>
}
801014ec:	83 c4 10             	add    $0x10,%esp
801014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014f2:	5b                   	pop    %ebx
801014f3:	5e                   	pop    %esi
801014f4:	5f                   	pop    %edi
801014f5:	5d                   	pop    %ebp
801014f6:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014f7:	83 ec 08             	sub    $0x8,%esp
801014fa:	50                   	push   %eax
801014fb:	ff 36                	pushl  (%esi)
801014fd:	e8 6a ec ff ff       	call   8010016c <bread>
80101502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101505:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101508:	83 c4 10             	add    $0x10,%esp
8010150b:	bb 00 00 00 00       	mov    $0x0,%ebx
80101510:	eb 03                	jmp    80101515 <itrunc+0x76>
80101512:	83 c3 01             	add    $0x1,%ebx
80101515:	83 fb 7f             	cmp    $0x7f,%ebx
80101518:	77 10                	ja     8010152a <itrunc+0x8b>
      if(a[j])
8010151a:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010151d:	85 d2                	test   %edx,%edx
8010151f:	74 f1                	je     80101512 <itrunc+0x73>
        bfree(ip->dev, a[j]);
80101521:	8b 06                	mov    (%esi),%eax
80101523:	e8 42 fd ff ff       	call   8010126a <bfree>
80101528:	eb e8                	jmp    80101512 <itrunc+0x73>
    brelse(bp);
8010152a:	83 ec 0c             	sub    $0xc,%esp
8010152d:	ff 75 e4             	pushl  -0x1c(%ebp)
80101530:	e8 a0 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101535:	8b 06                	mov    (%esi),%eax
80101537:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010153d:	e8 28 fd ff ff       	call   8010126a <bfree>
    ip->addrs[NDIRECT] = 0;
80101542:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101549:	00 00 00 
8010154c:	83 c4 10             	add    $0x10,%esp
8010154f:	eb 8b                	jmp    801014dc <itrunc+0x3d>

80101551 <idup>:
{
80101551:	55                   	push   %ebp
80101552:	89 e5                	mov    %esp,%ebp
80101554:	53                   	push   %ebx
80101555:	83 ec 10             	sub    $0x10,%esp
80101558:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010155b:	68 00 0e 11 80       	push   $0x80110e00
80101560:	e8 e2 2f 00 00       	call   80104547 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
80101575:	e8 32 30 00 00       	call   801045ac <release>
}
8010157a:	89 d8                	mov    %ebx,%eax
8010157c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010157f:	c9                   	leave  
80101580:	c3                   	ret    

80101581 <ilock>:
{
80101581:	55                   	push   %ebp
80101582:	89 e5                	mov    %esp,%ebp
80101584:	56                   	push   %esi
80101585:	53                   	push   %ebx
80101586:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101589:	85 db                	test   %ebx,%ebx
8010158b:	74 22                	je     801015af <ilock+0x2e>
8010158d:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101591:	7e 1c                	jle    801015af <ilock+0x2e>
  acquiresleep(&ip->lock);
80101593:	83 ec 0c             	sub    $0xc,%esp
80101596:	8d 43 0c             	lea    0xc(%ebx),%eax
80101599:	50                   	push   %eax
8010159a:	e8 94 2d 00 00       	call   80104333 <acquiresleep>
  if(ip->valid == 0){
8010159f:	83 c4 10             	add    $0x10,%esp
801015a2:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015a6:	74 14                	je     801015bc <ilock+0x3b>
}
801015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015ab:	5b                   	pop    %ebx
801015ac:	5e                   	pop    %esi
801015ad:	5d                   	pop    %ebp
801015ae:	c3                   	ret    
    panic("ilock");
801015af:	83 ec 0c             	sub    $0xc,%esp
801015b2:	68 ea 6f 10 80       	push   $0x80106fea
801015b7:	e8 8c ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015bc:	8b 43 04             	mov    0x4(%ebx),%eax
801015bf:	c1 e8 03             	shr    $0x3,%eax
801015c2:	03 05 f4 0d 11 80    	add    0x80110df4,%eax
801015c8:	83 ec 08             	sub    $0x8,%esp
801015cb:	50                   	push   %eax
801015cc:	ff 33                	pushl  (%ebx)
801015ce:	e8 99 eb ff ff       	call   8010016c <bread>
801015d3:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015d5:	8b 43 04             	mov    0x4(%ebx),%eax
801015d8:	83 e0 07             	and    $0x7,%eax
801015db:	c1 e0 06             	shl    $0x6,%eax
801015de:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015e2:	0f b7 10             	movzwl (%eax),%edx
801015e5:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015e9:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015ed:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015f1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015f5:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015f9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015fd:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101601:	8b 50 08             	mov    0x8(%eax),%edx
80101604:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101607:	83 c0 0c             	add    $0xc,%eax
8010160a:	8d 53 5c             	lea    0x5c(%ebx),%edx
8010160d:	83 c4 0c             	add    $0xc,%esp
80101610:	6a 34                	push   $0x34
80101612:	50                   	push   %eax
80101613:	52                   	push   %edx
80101614:	e8 55 30 00 00       	call   8010466e <memmove>
    brelse(bp);
80101619:	89 34 24             	mov    %esi,(%esp)
8010161c:	e8 b4 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
80101621:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101628:	83 c4 10             	add    $0x10,%esp
8010162b:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101630:	0f 85 72 ff ff ff    	jne    801015a8 <ilock+0x27>
      panic("ilock: no type");
80101636:	83 ec 0c             	sub    $0xc,%esp
80101639:	68 f0 6f 10 80       	push   $0x80106ff0
8010163e:	e8 05 ed ff ff       	call   80100348 <panic>

80101643 <iunlock>:
{
80101643:	55                   	push   %ebp
80101644:	89 e5                	mov    %esp,%ebp
80101646:	56                   	push   %esi
80101647:	53                   	push   %ebx
80101648:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010164b:	85 db                	test   %ebx,%ebx
8010164d:	74 2c                	je     8010167b <iunlock+0x38>
8010164f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101652:	83 ec 0c             	sub    $0xc,%esp
80101655:	56                   	push   %esi
80101656:	e8 62 2d 00 00       	call   801043bd <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 11 2d 00 00       	call   80104382 <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 ff 6f 10 80       	push   $0x80106fff
80101683:	e8 c0 ec ff ff       	call   80100348 <panic>

80101688 <iput>:
{
80101688:	55                   	push   %ebp
80101689:	89 e5                	mov    %esp,%ebp
8010168b:	57                   	push   %edi
8010168c:	56                   	push   %esi
8010168d:	53                   	push   %ebx
8010168e:	83 ec 18             	sub    $0x18,%esp
80101691:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101694:	8d 73 0c             	lea    0xc(%ebx),%esi
80101697:	56                   	push   %esi
80101698:	e8 96 2c 00 00       	call   80104333 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 cc 2c 00 00       	call   80104382 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
801016bd:	e8 85 2e 00 00       	call   80104547 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
801016d2:	e8 d5 2e 00 00       	call   801045ac <release>
}
801016d7:	83 c4 10             	add    $0x10,%esp
801016da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016dd:	5b                   	pop    %ebx
801016de:	5e                   	pop    %esi
801016df:	5f                   	pop    %edi
801016e0:	5d                   	pop    %ebp
801016e1:	c3                   	ret    
    acquire(&icache.lock);
801016e2:	83 ec 0c             	sub    $0xc,%esp
801016e5:	68 00 0e 11 80       	push   $0x80110e00
801016ea:	e8 58 2e 00 00       	call   80104547 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
801016f9:	e8 ae 2e 00 00       	call   801045ac <release>
    if(r == 1){
801016fe:	83 c4 10             	add    $0x10,%esp
80101701:	83 ff 01             	cmp    $0x1,%edi
80101704:	75 a7                	jne    801016ad <iput+0x25>
      itrunc(ip);
80101706:	89 d8                	mov    %ebx,%eax
80101708:	e8 92 fd ff ff       	call   8010149f <itrunc>
      ip->type = 0;
8010170d:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101713:	83 ec 0c             	sub    $0xc,%esp
80101716:	53                   	push   %ebx
80101717:	e8 04 fd ff ff       	call   80101420 <iupdate>
      ip->valid = 0;
8010171c:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101723:	83 c4 10             	add    $0x10,%esp
80101726:	eb 85                	jmp    801016ad <iput+0x25>

80101728 <iunlockput>:
{
80101728:	55                   	push   %ebp
80101729:	89 e5                	mov    %esp,%ebp
8010172b:	53                   	push   %ebx
8010172c:	83 ec 10             	sub    $0x10,%esp
8010172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101732:	53                   	push   %ebx
80101733:	e8 0b ff ff ff       	call   80101643 <iunlock>
  iput(ip);
80101738:	89 1c 24             	mov    %ebx,(%esp)
8010173b:	e8 48 ff ff ff       	call   80101688 <iput>
}
80101740:	83 c4 10             	add    $0x10,%esp
80101743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101746:	c9                   	leave  
80101747:	c3                   	ret    

80101748 <stati>:
{
80101748:	55                   	push   %ebp
80101749:	89 e5                	mov    %esp,%ebp
8010174b:	8b 55 08             	mov    0x8(%ebp),%edx
8010174e:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101751:	8b 0a                	mov    (%edx),%ecx
80101753:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101756:	8b 4a 04             	mov    0x4(%edx),%ecx
80101759:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010175c:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101760:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101763:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101767:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010176b:	8b 52 58             	mov    0x58(%edx),%edx
8010176e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101771:	5d                   	pop    %ebp
80101772:	c3                   	ret    

80101773 <readi>:
{
80101773:	55                   	push   %ebp
80101774:	89 e5                	mov    %esp,%ebp
80101776:	57                   	push   %edi
80101777:	56                   	push   %esi
80101778:	53                   	push   %ebx
80101779:	83 ec 1c             	sub    $0x1c,%esp
8010177c:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010177f:	8b 45 08             	mov    0x8(%ebp),%eax
80101782:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101787:	74 2c                	je     801017b5 <readi+0x42>
  if(off > ip->size || off + n < off)
80101789:	8b 45 08             	mov    0x8(%ebp),%eax
8010178c:	8b 40 58             	mov    0x58(%eax),%eax
8010178f:	39 f8                	cmp    %edi,%eax
80101791:	0f 82 cb 00 00 00    	jb     80101862 <readi+0xef>
80101797:	89 fa                	mov    %edi,%edx
80101799:	03 55 14             	add    0x14(%ebp),%edx
8010179c:	0f 82 c7 00 00 00    	jb     80101869 <readi+0xf6>
  if(off + n > ip->size)
801017a2:	39 d0                	cmp    %edx,%eax
801017a4:	73 05                	jae    801017ab <readi+0x38>
    n = ip->size - off;
801017a6:	29 f8                	sub    %edi,%eax
801017a8:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017ab:	be 00 00 00 00       	mov    $0x0,%esi
801017b0:	e9 8f 00 00 00       	jmp    80101844 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017b5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017b9:	66 83 f8 09          	cmp    $0x9,%ax
801017bd:	0f 87 91 00 00 00    	ja     80101854 <readi+0xe1>
801017c3:	98                   	cwtl   
801017c4:	8b 04 c5 80 0d 11 80 	mov    -0x7feef280(,%eax,8),%eax
801017cb:	85 c0                	test   %eax,%eax
801017cd:	0f 84 88 00 00 00    	je     8010185b <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017d3:	83 ec 04             	sub    $0x4,%esp
801017d6:	ff 75 14             	pushl  0x14(%ebp)
801017d9:	ff 75 0c             	pushl  0xc(%ebp)
801017dc:	ff 75 08             	pushl  0x8(%ebp)
801017df:	ff d0                	call   *%eax
801017e1:	83 c4 10             	add    $0x10,%esp
801017e4:	eb 66                	jmp    8010184c <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017e6:	89 fa                	mov    %edi,%edx
801017e8:	c1 ea 09             	shr    $0x9,%edx
801017eb:	8b 45 08             	mov    0x8(%ebp),%eax
801017ee:	e8 ee f8 ff ff       	call   801010e1 <bmap>
801017f3:	83 ec 08             	sub    $0x8,%esp
801017f6:	50                   	push   %eax
801017f7:	8b 45 08             	mov    0x8(%ebp),%eax
801017fa:	ff 30                	pushl  (%eax)
801017fc:	e8 6b e9 ff ff       	call   8010016c <bread>
80101801:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101803:	89 f8                	mov    %edi,%eax
80101805:	25 ff 01 00 00       	and    $0x1ff,%eax
8010180a:	bb 00 02 00 00       	mov    $0x200,%ebx
8010180f:	29 c3                	sub    %eax,%ebx
80101811:	8b 55 14             	mov    0x14(%ebp),%edx
80101814:	29 f2                	sub    %esi,%edx
80101816:	83 c4 0c             	add    $0xc,%esp
80101819:	39 d3                	cmp    %edx,%ebx
8010181b:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010181e:	53                   	push   %ebx
8010181f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101822:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101826:	50                   	push   %eax
80101827:	ff 75 0c             	pushl  0xc(%ebp)
8010182a:	e8 3f 2e 00 00       	call   8010466e <memmove>
    brelse(bp);
8010182f:	83 c4 04             	add    $0x4,%esp
80101832:	ff 75 e4             	pushl  -0x1c(%ebp)
80101835:	e8 9b e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010183a:	01 de                	add    %ebx,%esi
8010183c:	01 df                	add    %ebx,%edi
8010183e:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101841:	83 c4 10             	add    $0x10,%esp
80101844:	39 75 14             	cmp    %esi,0x14(%ebp)
80101847:	77 9d                	ja     801017e6 <readi+0x73>
  return n;
80101849:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010184c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010184f:	5b                   	pop    %ebx
80101850:	5e                   	pop    %esi
80101851:	5f                   	pop    %edi
80101852:	5d                   	pop    %ebp
80101853:	c3                   	ret    
      return -1;
80101854:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101859:	eb f1                	jmp    8010184c <readi+0xd9>
8010185b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101860:	eb ea                	jmp    8010184c <readi+0xd9>
    return -1;
80101862:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101867:	eb e3                	jmp    8010184c <readi+0xd9>
80101869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186e:	eb dc                	jmp    8010184c <readi+0xd9>

80101870 <writei>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	57                   	push   %edi
80101874:	56                   	push   %esi
80101875:	53                   	push   %ebx
80101876:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101879:	8b 45 08             	mov    0x8(%ebp),%eax
8010187c:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101881:	74 2f                	je     801018b2 <writei+0x42>
  if(off > ip->size || off + n < off)
80101883:	8b 45 08             	mov    0x8(%ebp),%eax
80101886:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101889:	39 48 58             	cmp    %ecx,0x58(%eax)
8010188c:	0f 82 f4 00 00 00    	jb     80101986 <writei+0x116>
80101892:	89 c8                	mov    %ecx,%eax
80101894:	03 45 14             	add    0x14(%ebp),%eax
80101897:	0f 82 f0 00 00 00    	jb     8010198d <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
8010189d:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018a2:	0f 87 ec 00 00 00    	ja     80101994 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018a8:	be 00 00 00 00       	mov    $0x0,%esi
801018ad:	e9 94 00 00 00       	jmp    80101946 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018b2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018b6:	66 83 f8 09          	cmp    $0x9,%ax
801018ba:	0f 87 b8 00 00 00    	ja     80101978 <writei+0x108>
801018c0:	98                   	cwtl   
801018c1:	8b 04 c5 84 0d 11 80 	mov    -0x7feef27c(,%eax,8),%eax
801018c8:	85 c0                	test   %eax,%eax
801018ca:	0f 84 af 00 00 00    	je     8010197f <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018d0:	83 ec 04             	sub    $0x4,%esp
801018d3:	ff 75 14             	pushl  0x14(%ebp)
801018d6:	ff 75 0c             	pushl  0xc(%ebp)
801018d9:	ff 75 08             	pushl  0x8(%ebp)
801018dc:	ff d0                	call   *%eax
801018de:	83 c4 10             	add    $0x10,%esp
801018e1:	eb 7c                	jmp    8010195f <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018e3:	8b 55 10             	mov    0x10(%ebp),%edx
801018e6:	c1 ea 09             	shr    $0x9,%edx
801018e9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ec:	e8 f0 f7 ff ff       	call   801010e1 <bmap>
801018f1:	83 ec 08             	sub    $0x8,%esp
801018f4:	50                   	push   %eax
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	ff 30                	pushl  (%eax)
801018fa:	e8 6d e8 ff ff       	call   8010016c <bread>
801018ff:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101901:	8b 45 10             	mov    0x10(%ebp),%eax
80101904:	25 ff 01 00 00       	and    $0x1ff,%eax
80101909:	bb 00 02 00 00       	mov    $0x200,%ebx
8010190e:	29 c3                	sub    %eax,%ebx
80101910:	8b 55 14             	mov    0x14(%ebp),%edx
80101913:	29 f2                	sub    %esi,%edx
80101915:	83 c4 0c             	add    $0xc,%esp
80101918:	39 d3                	cmp    %edx,%ebx
8010191a:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010191d:	53                   	push   %ebx
8010191e:	ff 75 0c             	pushl  0xc(%ebp)
80101921:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101925:	50                   	push   %eax
80101926:	e8 43 2d 00 00       	call   8010466e <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 a4 0f 00 00       	call   801028d7 <log_write>
    brelse(bp);
80101933:	89 3c 24             	mov    %edi,(%esp)
80101936:	e8 9a e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010193b:	01 de                	add    %ebx,%esi
8010193d:	01 5d 10             	add    %ebx,0x10(%ebp)
80101940:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101943:	83 c4 10             	add    $0x10,%esp
80101946:	3b 75 14             	cmp    0x14(%ebp),%esi
80101949:	72 98                	jb     801018e3 <writei+0x73>
  if(n > 0 && off > ip->size){
8010194b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010194f:	74 0b                	je     8010195c <writei+0xec>
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101957:	39 48 58             	cmp    %ecx,0x58(%eax)
8010195a:	72 0b                	jb     80101967 <writei+0xf7>
  return n;
8010195c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010195f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101962:	5b                   	pop    %ebx
80101963:	5e                   	pop    %esi
80101964:	5f                   	pop    %edi
80101965:	5d                   	pop    %ebp
80101966:	c3                   	ret    
    ip->size = off;
80101967:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
8010196a:	83 ec 0c             	sub    $0xc,%esp
8010196d:	50                   	push   %eax
8010196e:	e8 ad fa ff ff       	call   80101420 <iupdate>
80101973:	83 c4 10             	add    $0x10,%esp
80101976:	eb e4                	jmp    8010195c <writei+0xec>
      return -1;
80101978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010197d:	eb e0                	jmp    8010195f <writei+0xef>
8010197f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101984:	eb d9                	jmp    8010195f <writei+0xef>
    return -1;
80101986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010198b:	eb d2                	jmp    8010195f <writei+0xef>
8010198d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101992:	eb cb                	jmp    8010195f <writei+0xef>
    return -1;
80101994:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101999:	eb c4                	jmp    8010195f <writei+0xef>

8010199b <namecmp>:
{
8010199b:	55                   	push   %ebp
8010199c:	89 e5                	mov    %esp,%ebp
8010199e:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019a1:	6a 0e                	push   $0xe
801019a3:	ff 75 0c             	pushl  0xc(%ebp)
801019a6:	ff 75 08             	pushl  0x8(%ebp)
801019a9:	e8 27 2d 00 00       	call   801046d5 <strncmp>
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <dirlookup>:
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	57                   	push   %edi
801019b4:	56                   	push   %esi
801019b5:	53                   	push   %ebx
801019b6:	83 ec 1c             	sub    $0x1c,%esp
801019b9:	8b 75 08             	mov    0x8(%ebp),%esi
801019bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019bf:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019c4:	75 07                	jne    801019cd <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019c6:	bb 00 00 00 00       	mov    $0x0,%ebx
801019cb:	eb 1d                	jmp    801019ea <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019cd:	83 ec 0c             	sub    $0xc,%esp
801019d0:	68 07 70 10 80       	push   $0x80107007
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 19 70 10 80       	push   $0x80107019
801019e2:	e8 61 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019e7:	83 c3 10             	add    $0x10,%ebx
801019ea:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019ed:	76 48                	jbe    80101a37 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019ef:	6a 10                	push   $0x10
801019f1:	53                   	push   %ebx
801019f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019f5:	50                   	push   %eax
801019f6:	56                   	push   %esi
801019f7:	e8 77 fd ff ff       	call   80101773 <readi>
801019fc:	83 c4 10             	add    $0x10,%esp
801019ff:	83 f8 10             	cmp    $0x10,%eax
80101a02:	75 d6                	jne    801019da <dirlookup+0x2a>
    if(de.inum == 0)
80101a04:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a09:	74 dc                	je     801019e7 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a0b:	83 ec 08             	sub    $0x8,%esp
80101a0e:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a11:	50                   	push   %eax
80101a12:	57                   	push   %edi
80101a13:	e8 83 ff ff ff       	call   8010199b <namecmp>
80101a18:	83 c4 10             	add    $0x10,%esp
80101a1b:	85 c0                	test   %eax,%eax
80101a1d:	75 c8                	jne    801019e7 <dirlookup+0x37>
      if(poff)
80101a1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a23:	74 05                	je     80101a2a <dirlookup+0x7a>
        *poff = off;
80101a25:	8b 45 10             	mov    0x10(%ebp),%eax
80101a28:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a2a:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a2e:	8b 06                	mov    (%esi),%eax
80101a30:	e8 52 f7 ff ff       	call   80101187 <iget>
80101a35:	eb 05                	jmp    80101a3c <dirlookup+0x8c>
  return 0;
80101a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a3f:	5b                   	pop    %ebx
80101a40:	5e                   	pop    %esi
80101a41:	5f                   	pop    %edi
80101a42:	5d                   	pop    %ebp
80101a43:	c3                   	ret    

80101a44 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a44:	55                   	push   %ebp
80101a45:	89 e5                	mov    %esp,%ebp
80101a47:	57                   	push   %edi
80101a48:	56                   	push   %esi
80101a49:	53                   	push   %ebx
80101a4a:	83 ec 1c             	sub    $0x1c,%esp
80101a4d:	89 c6                	mov    %eax,%esi
80101a4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a52:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a55:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a58:	74 17                	je     80101a71 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a5a:	e8 6f 17 00 00       	call   801031ce <myproc>
80101a5f:	83 ec 0c             	sub    $0xc,%esp
80101a62:	ff 70 68             	pushl  0x68(%eax)
80101a65:	e8 e7 fa ff ff       	call   80101551 <idup>
80101a6a:	89 c3                	mov    %eax,%ebx
80101a6c:	83 c4 10             	add    $0x10,%esp
80101a6f:	eb 53                	jmp    80101ac4 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a71:	ba 01 00 00 00       	mov    $0x1,%edx
80101a76:	b8 01 00 00 00       	mov    $0x1,%eax
80101a7b:	e8 07 f7 ff ff       	call   80101187 <iget>
80101a80:	89 c3                	mov    %eax,%ebx
80101a82:	eb 40                	jmp    80101ac4 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a84:	83 ec 0c             	sub    $0xc,%esp
80101a87:	53                   	push   %ebx
80101a88:	e8 9b fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101a8d:	83 c4 10             	add    $0x10,%esp
80101a90:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a95:	89 d8                	mov    %ebx,%eax
80101a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a9a:	5b                   	pop    %ebx
80101a9b:	5e                   	pop    %esi
80101a9c:	5f                   	pop    %edi
80101a9d:	5d                   	pop    %ebp
80101a9e:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a9f:	83 ec 04             	sub    $0x4,%esp
80101aa2:	6a 00                	push   $0x0
80101aa4:	ff 75 e4             	pushl  -0x1c(%ebp)
80101aa7:	53                   	push   %ebx
80101aa8:	e8 03 ff ff ff       	call   801019b0 <dirlookup>
80101aad:	89 c7                	mov    %eax,%edi
80101aaf:	83 c4 10             	add    $0x10,%esp
80101ab2:	85 c0                	test   %eax,%eax
80101ab4:	74 4a                	je     80101b00 <namex+0xbc>
    iunlockput(ip);
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	53                   	push   %ebx
80101aba:	e8 69 fc ff ff       	call   80101728 <iunlockput>
    ip = next;
80101abf:	83 c4 10             	add    $0x10,%esp
80101ac2:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ac4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ac7:	89 f0                	mov    %esi,%eax
80101ac9:	e8 77 f4 ff ff       	call   80100f45 <skipelem>
80101ace:	89 c6                	mov    %eax,%esi
80101ad0:	85 c0                	test   %eax,%eax
80101ad2:	74 3c                	je     80101b10 <namex+0xcc>
    ilock(ip);
80101ad4:	83 ec 0c             	sub    $0xc,%esp
80101ad7:	53                   	push   %ebx
80101ad8:	e8 a4 fa ff ff       	call   80101581 <ilock>
    if(ip->type != T_DIR){
80101add:	83 c4 10             	add    $0x10,%esp
80101ae0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101ae5:	75 9d                	jne    80101a84 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ae7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101aeb:	74 b2                	je     80101a9f <namex+0x5b>
80101aed:	80 3e 00             	cmpb   $0x0,(%esi)
80101af0:	75 ad                	jne    80101a9f <namex+0x5b>
      iunlock(ip);
80101af2:	83 ec 0c             	sub    $0xc,%esp
80101af5:	53                   	push   %ebx
80101af6:	e8 48 fb ff ff       	call   80101643 <iunlock>
      return ip;
80101afb:	83 c4 10             	add    $0x10,%esp
80101afe:	eb 95                	jmp    80101a95 <namex+0x51>
      iunlockput(ip);
80101b00:	83 ec 0c             	sub    $0xc,%esp
80101b03:	53                   	push   %ebx
80101b04:	e8 1f fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101b09:	83 c4 10             	add    $0x10,%esp
80101b0c:	89 fb                	mov    %edi,%ebx
80101b0e:	eb 85                	jmp    80101a95 <namex+0x51>
  if(nameiparent){
80101b10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b14:	0f 84 7b ff ff ff    	je     80101a95 <namex+0x51>
    iput(ip);
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	53                   	push   %ebx
80101b1e:	e8 65 fb ff ff       	call   80101688 <iput>
    return 0;
80101b23:	83 c4 10             	add    $0x10,%esp
80101b26:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b2b:	e9 65 ff ff ff       	jmp    80101a95 <namex+0x51>

80101b30 <dirlink>:
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	57                   	push   %edi
80101b34:	56                   	push   %esi
80101b35:	53                   	push   %ebx
80101b36:	83 ec 20             	sub    $0x20,%esp
80101b39:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b3f:	6a 00                	push   $0x0
80101b41:	57                   	push   %edi
80101b42:	53                   	push   %ebx
80101b43:	e8 68 fe ff ff       	call   801019b0 <dirlookup>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	75 2d                	jne    80101b7c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b4f:	b8 00 00 00 00       	mov    $0x0,%eax
80101b54:	89 c6                	mov    %eax,%esi
80101b56:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b59:	76 41                	jbe    80101b9c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b5b:	6a 10                	push   $0x10
80101b5d:	50                   	push   %eax
80101b5e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b61:	50                   	push   %eax
80101b62:	53                   	push   %ebx
80101b63:	e8 0b fc ff ff       	call   80101773 <readi>
80101b68:	83 c4 10             	add    $0x10,%esp
80101b6b:	83 f8 10             	cmp    $0x10,%eax
80101b6e:	75 1f                	jne    80101b8f <dirlink+0x5f>
    if(de.inum == 0)
80101b70:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b75:	74 25                	je     80101b9c <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b77:	8d 46 10             	lea    0x10(%esi),%eax
80101b7a:	eb d8                	jmp    80101b54 <dirlink+0x24>
    iput(ip);
80101b7c:	83 ec 0c             	sub    $0xc,%esp
80101b7f:	50                   	push   %eax
80101b80:	e8 03 fb ff ff       	call   80101688 <iput>
    return -1;
80101b85:	83 c4 10             	add    $0x10,%esp
80101b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b8d:	eb 3d                	jmp    80101bcc <dirlink+0x9c>
      panic("dirlink read");
80101b8f:	83 ec 0c             	sub    $0xc,%esp
80101b92:	68 28 70 10 80       	push   $0x80107028
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 64 2b 00 00       	call   80104712 <strncpy>
  de.inum = inum;
80101bae:	8b 45 10             	mov    0x10(%ebp),%eax
80101bb1:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bb5:	6a 10                	push   $0x10
80101bb7:	56                   	push   %esi
80101bb8:	57                   	push   %edi
80101bb9:	53                   	push   %ebx
80101bba:	e8 b1 fc ff ff       	call   80101870 <writei>
80101bbf:	83 c4 20             	add    $0x20,%esp
80101bc2:	83 f8 10             	cmp    $0x10,%eax
80101bc5:	75 0d                	jne    80101bd4 <dirlink+0xa4>
  return 0;
80101bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bcf:	5b                   	pop    %ebx
80101bd0:	5e                   	pop    %esi
80101bd1:	5f                   	pop    %edi
80101bd2:	5d                   	pop    %ebp
80101bd3:	c3                   	ret    
    panic("dirlink");
80101bd4:	83 ec 0c             	sub    $0xc,%esp
80101bd7:	68 40 76 10 80       	push   $0x80107640
80101bdc:	e8 67 e7 ff ff       	call   80100348 <panic>

80101be1 <namei>:

struct inode*
namei(char *path)
{
80101be1:	55                   	push   %ebp
80101be2:	89 e5                	mov    %esp,%ebp
80101be4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101be7:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bea:	ba 00 00 00 00       	mov    $0x0,%edx
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	e8 4d fe ff ff       	call   80101a44 <namex>
}
80101bf7:	c9                   	leave  
80101bf8:	c3                   	ret    

80101bf9 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101bf9:	55                   	push   %ebp
80101bfa:	89 e5                	mov    %esp,%ebp
80101bfc:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c02:	ba 01 00 00 00       	mov    $0x1,%edx
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	e8 35 fe ff ff       	call   80101a44 <namex>
}
80101c0f:	c9                   	leave  
80101c10:	c3                   	ret    

80101c11 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c11:	55                   	push   %ebp
80101c12:	89 e5                	mov    %esp,%ebp
80101c14:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c16:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c1b:	ec                   	in     (%dx),%al
80101c1c:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c1e:	83 e0 c0             	and    $0xffffffc0,%eax
80101c21:	3c 40                	cmp    $0x40,%al
80101c23:	75 f1                	jne    80101c16 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c25:	85 c9                	test   %ecx,%ecx
80101c27:	74 0c                	je     80101c35 <idewait+0x24>
80101c29:	f6 c2 21             	test   $0x21,%dl
80101c2c:	75 0e                	jne    80101c3c <idewait+0x2b>
    return -1;
  return 0;
80101c2e:	b8 00 00 00 00       	mov    $0x0,%eax
80101c33:	eb 05                	jmp    80101c3a <idewait+0x29>
80101c35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c3a:	5d                   	pop    %ebp
80101c3b:	c3                   	ret    
    return -1;
80101c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c41:	eb f7                	jmp    80101c3a <idewait+0x29>

80101c43 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c43:	55                   	push   %ebp
80101c44:	89 e5                	mov    %esp,%ebp
80101c46:	56                   	push   %esi
80101c47:	53                   	push   %ebx
  if(b == 0)
80101c48:	85 c0                	test   %eax,%eax
80101c4a:	74 7d                	je     80101cc9 <idestart+0x86>
80101c4c:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c4e:	8b 58 08             	mov    0x8(%eax),%ebx
80101c51:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c57:	77 7d                	ja     80101cd6 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c59:	b8 00 00 00 00       	mov    $0x0,%eax
80101c5e:	e8 ae ff ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c63:	b8 00 00 00 00       	mov    $0x0,%eax
80101c68:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c6d:	ee                   	out    %al,(%dx)
80101c6e:	b8 01 00 00 00       	mov    $0x1,%eax
80101c73:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c78:	ee                   	out    %al,(%dx)
80101c79:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c7e:	89 d8                	mov    %ebx,%eax
80101c80:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c81:	89 d8                	mov    %ebx,%eax
80101c83:	c1 f8 08             	sar    $0x8,%eax
80101c86:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c8b:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c8c:	89 d8                	mov    %ebx,%eax
80101c8e:	c1 f8 10             	sar    $0x10,%eax
80101c91:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c96:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c97:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c9b:	c1 e0 04             	shl    $0x4,%eax
80101c9e:	83 e0 10             	and    $0x10,%eax
80101ca1:	c1 fb 18             	sar    $0x18,%ebx
80101ca4:	83 e3 0f             	and    $0xf,%ebx
80101ca7:	09 d8                	or     %ebx,%eax
80101ca9:	83 c8 e0             	or     $0xffffffe0,%eax
80101cac:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cb1:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101cb2:	f6 06 04             	testb  $0x4,(%esi)
80101cb5:	75 2c                	jne    80101ce3 <idestart+0xa0>
80101cb7:	b8 20 00 00 00       	mov    $0x20,%eax
80101cbc:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cc1:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cc5:	5b                   	pop    %ebx
80101cc6:	5e                   	pop    %esi
80101cc7:	5d                   	pop    %ebp
80101cc8:	c3                   	ret    
    panic("idestart");
80101cc9:	83 ec 0c             	sub    $0xc,%esp
80101ccc:	68 8b 70 10 80       	push   $0x8010708b
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 94 70 10 80       	push   $0x80107094
80101cde:	e8 65 e6 ff ff       	call   80100348 <panic>
80101ce3:	b8 30 00 00 00       	mov    $0x30,%eax
80101ce8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ced:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cee:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cf1:	b9 80 00 00 00       	mov    $0x80,%ecx
80101cf6:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101cfb:	fc                   	cld    
80101cfc:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101cfe:	eb c2                	jmp    80101cc2 <idestart+0x7f>

80101d00 <ideinit>:
{
80101d00:	55                   	push   %ebp
80101d01:	89 e5                	mov    %esp,%ebp
80101d03:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d06:	68 a6 70 10 80       	push   $0x801070a6
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 f6 26 00 00       	call   8010440b <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d15:	83 c4 08             	add    $0x8,%esp
80101d18:	a1 20 31 11 80       	mov    0x80113120,%eax
80101d1d:	83 e8 01             	sub    $0x1,%eax
80101d20:	50                   	push   %eax
80101d21:	6a 0e                	push   $0xe
80101d23:	e8 56 02 00 00       	call   80101f7e <ioapicenable>
  idewait(0);
80101d28:	b8 00 00 00 00       	mov    $0x0,%eax
80101d2d:	e8 df fe ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d32:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d37:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d3c:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d3d:	83 c4 10             	add    $0x10,%esp
80101d40:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d45:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d4b:	7f 19                	jg     80101d66 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d4d:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d52:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d53:	84 c0                	test   %al,%al
80101d55:	75 05                	jne    80101d5c <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d57:	83 c1 01             	add    $0x1,%ecx
80101d5a:	eb e9                	jmp    80101d45 <ideinit+0x45>
      havedisk1 = 1;
80101d5c:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101d63:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d66:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d6b:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d70:	ee                   	out    %al,(%dx)
}
80101d71:	c9                   	leave  
80101d72:	c3                   	ret    

80101d73 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d73:	55                   	push   %ebp
80101d74:	89 e5                	mov    %esp,%ebp
80101d76:	57                   	push   %edi
80101d77:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d78:	83 ec 0c             	sub    $0xc,%esp
80101d7b:	68 80 a5 10 80       	push   $0x8010a580
80101d80:	e8 c2 27 00 00       	call   80104547 <acquire>

  if((b = idequeue) == 0){
80101d85:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101d8b:	83 c4 10             	add    $0x10,%esp
80101d8e:	85 db                	test   %ebx,%ebx
80101d90:	74 48                	je     80101dda <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d92:	8b 43 58             	mov    0x58(%ebx),%eax
80101d95:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d9a:	f6 03 04             	testb  $0x4,(%ebx)
80101d9d:	74 4d                	je     80101dec <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d9f:	8b 03                	mov    (%ebx),%eax
80101da1:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101da4:	83 e0 fb             	and    $0xfffffffb,%eax
80101da7:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101da9:	83 ec 0c             	sub    $0xc,%esp
80101dac:	53                   	push   %ebx
80101dad:	e8 14 1f 00 00       	call   80103cc6 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101db2:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101db7:	83 c4 10             	add    $0x10,%esp
80101dba:	85 c0                	test   %eax,%eax
80101dbc:	74 05                	je     80101dc3 <ideintr+0x50>
    idestart(idequeue);
80101dbe:	e8 80 fe ff ff       	call   80101c43 <idestart>

  release(&idelock);
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	68 80 a5 10 80       	push   $0x8010a580
80101dcb:	e8 dc 27 00 00       	call   801045ac <release>
80101dd0:	83 c4 10             	add    $0x10,%esp
}
80101dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dd6:	5b                   	pop    %ebx
80101dd7:	5f                   	pop    %edi
80101dd8:	5d                   	pop    %ebp
80101dd9:	c3                   	ret    
    release(&idelock);
80101dda:	83 ec 0c             	sub    $0xc,%esp
80101ddd:	68 80 a5 10 80       	push   $0x8010a580
80101de2:	e8 c5 27 00 00       	call   801045ac <release>
    return;
80101de7:	83 c4 10             	add    $0x10,%esp
80101dea:	eb e7                	jmp    80101dd3 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dec:	b8 01 00 00 00       	mov    $0x1,%eax
80101df1:	e8 1b fe ff ff       	call   80101c11 <idewait>
80101df6:	85 c0                	test   %eax,%eax
80101df8:	78 a5                	js     80101d9f <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101dfa:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101dfd:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e02:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e07:	fc                   	cld    
80101e08:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e0a:	eb 93                	jmp    80101d9f <ideintr+0x2c>

80101e0c <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e0c:	55                   	push   %ebp
80101e0d:	89 e5                	mov    %esp,%ebp
80101e0f:	53                   	push   %ebx
80101e10:	83 ec 10             	sub    $0x10,%esp
80101e13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e16:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e19:	50                   	push   %eax
80101e1a:	e8 9e 25 00 00       	call   801043bd <holdingsleep>
80101e1f:	83 c4 10             	add    $0x10,%esp
80101e22:	85 c0                	test   %eax,%eax
80101e24:	74 37                	je     80101e5d <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e26:	8b 03                	mov    (%ebx),%eax
80101e28:	83 e0 06             	and    $0x6,%eax
80101e2b:	83 f8 02             	cmp    $0x2,%eax
80101e2e:	74 3a                	je     80101e6a <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e30:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e34:	74 09                	je     80101e3f <iderw+0x33>
80101e36:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101e3d:	74 38                	je     80101e77 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	68 80 a5 10 80       	push   $0x8010a580
80101e47:	e8 fb 26 00 00       	call   80104547 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 aa 70 10 80       	push   $0x801070aa
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 c0 70 10 80       	push   $0x801070c0
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 d5 70 10 80       	push   $0x801070d5
80101e7f:	e8 c4 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e84:	8d 50 58             	lea    0x58(%eax),%edx
80101e87:	8b 02                	mov    (%edx),%eax
80101e89:	85 c0                	test   %eax,%eax
80101e8b:	75 f7                	jne    80101e84 <iderw+0x78>
    ;
  *pp = b;
80101e8d:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e8f:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101e95:	75 1a                	jne    80101eb1 <iderw+0xa5>
    idestart(b);
80101e97:	89 d8                	mov    %ebx,%eax
80101e99:	e8 a5 fd ff ff       	call   80101c43 <idestart>
80101e9e:	eb 11                	jmp    80101eb1 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101ea0:	83 ec 08             	sub    $0x8,%esp
80101ea3:	68 80 a5 10 80       	push   $0x8010a580
80101ea8:	53                   	push   %ebx
80101ea9:	e8 b0 1c 00 00       	call   80103b5e <sleep>
80101eae:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101eb1:	8b 03                	mov    (%ebx),%eax
80101eb3:	83 e0 06             	and    $0x6,%eax
80101eb6:	83 f8 02             	cmp    $0x2,%eax
80101eb9:	75 e5                	jne    80101ea0 <iderw+0x94>
  }


  release(&idelock);
80101ebb:	83 ec 0c             	sub    $0xc,%esp
80101ebe:	68 80 a5 10 80       	push   $0x8010a580
80101ec3:	e8 e4 26 00 00       	call   801045ac <release>
}
80101ec8:	83 c4 10             	add    $0x10,%esp
80101ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ece:	c9                   	leave  
80101ecf:	c3                   	ret    

80101ed0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ed0:	55                   	push   %ebp
80101ed1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ed3:	8b 15 54 2a 11 80    	mov    0x80112a54,%edx
80101ed9:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101edb:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101ee0:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ee3:	5d                   	pop    %ebp
80101ee4:	c3                   	ret    

80101ee5 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ee5:	55                   	push   %ebp
80101ee6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ee8:	8b 0d 54 2a 11 80    	mov    0x80112a54,%ecx
80101eee:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ef0:	a1 54 2a 11 80       	mov    0x80112a54,%eax
80101ef5:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ef8:	5d                   	pop    %ebp
80101ef9:	c3                   	ret    

80101efa <ioapicinit>:

void
ioapicinit(void)
{
80101efa:	55                   	push   %ebp
80101efb:	89 e5                	mov    %esp,%ebp
80101efd:	57                   	push   %edi
80101efe:	56                   	push   %esi
80101eff:	53                   	push   %ebx
80101f00:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f03:	c7 05 54 2a 11 80 00 	movl   $0xfec00000,0x80112a54
80101f0a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f0d:	b8 01 00 00 00       	mov    $0x1,%eax
80101f12:	e8 b9 ff ff ff       	call   80101ed0 <ioapicread>
80101f17:	c1 e8 10             	shr    $0x10,%eax
80101f1a:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80101f22:	e8 a9 ff ff ff       	call   80101ed0 <ioapicread>
80101f27:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f2a:	0f b6 15 80 2b 11 80 	movzbl 0x80112b80,%edx
80101f31:	39 c2                	cmp    %eax,%edx
80101f33:	75 07                	jne    80101f3c <ioapicinit+0x42>
{
80101f35:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f3a:	eb 36                	jmp    80101f72 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f3c:	83 ec 0c             	sub    $0xc,%esp
80101f3f:	68 f4 70 10 80       	push   $0x801070f4
80101f44:	e8 c2 e6 ff ff       	call   8010060b <cprintf>
80101f49:	83 c4 10             	add    $0x10,%esp
80101f4c:	eb e7                	jmp    80101f35 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f4e:	8d 53 20             	lea    0x20(%ebx),%edx
80101f51:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f57:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f5b:	89 f0                	mov    %esi,%eax
80101f5d:	e8 83 ff ff ff       	call   80101ee5 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f62:	8d 46 01             	lea    0x1(%esi),%eax
80101f65:	ba 00 00 00 00       	mov    $0x0,%edx
80101f6a:	e8 76 ff ff ff       	call   80101ee5 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f6f:	83 c3 01             	add    $0x1,%ebx
80101f72:	39 fb                	cmp    %edi,%ebx
80101f74:	7e d8                	jle    80101f4e <ioapicinit+0x54>
  }
}
80101f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f79:	5b                   	pop    %ebx
80101f7a:	5e                   	pop    %esi
80101f7b:	5f                   	pop    %edi
80101f7c:	5d                   	pop    %ebp
80101f7d:	c3                   	ret    

80101f7e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f7e:	55                   	push   %ebp
80101f7f:	89 e5                	mov    %esp,%ebp
80101f81:	53                   	push   %ebx
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f85:	8d 50 20             	lea    0x20(%eax),%edx
80101f88:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f8c:	89 d8                	mov    %ebx,%eax
80101f8e:	e8 52 ff ff ff       	call   80101ee5 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f96:	c1 e2 18             	shl    $0x18,%edx
80101f99:	8d 43 01             	lea    0x1(%ebx),%eax
80101f9c:	e8 44 ff ff ff       	call   80101ee5 <ioapicwrite>
}
80101fa1:	5b                   	pop    %ebx
80101fa2:	5d                   	pop    %ebp
80101fa3:	c3                   	ret    

80101fa4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fa4:	55                   	push   %ebp
80101fa5:	89 e5                	mov    %esp,%ebp
80101fa7:	53                   	push   %ebx
80101fa8:	83 ec 04             	sub    $0x4,%esp
80101fab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fae:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fb4:	75 4c                	jne    80102002 <kfree+0x5e>
80101fb6:	81 fb c8 65 11 80    	cmp    $0x801165c8,%ebx
80101fbc:	72 44                	jb     80102002 <kfree+0x5e>
80101fbe:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fc4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fc9:	77 37                	ja     80102002 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fcb:	83 ec 04             	sub    $0x4,%esp
80101fce:	68 00 10 00 00       	push   $0x1000
80101fd3:	6a 01                	push   $0x1
80101fd5:	53                   	push   %ebx
80101fd6:	e8 18 26 00 00       	call   801045f3 <memset>

  if(kmem.use_lock)
80101fdb:	83 c4 10             	add    $0x10,%esp
80101fde:	83 3d 94 2a 11 80 00 	cmpl   $0x0,0x80112a94
80101fe5:	75 28                	jne    8010200f <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fe7:	a1 98 2a 11 80       	mov    0x80112a98,%eax
80101fec:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fee:	89 1d 98 2a 11 80    	mov    %ebx,0x80112a98
  if(kmem.use_lock)
80101ff4:	83 3d 94 2a 11 80 00 	cmpl   $0x0,0x80112a94
80101ffb:	75 24                	jne    80102021 <kfree+0x7d>
    release(&kmem.lock);
}
80101ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102000:	c9                   	leave  
80102001:	c3                   	ret    
    panic("kfree");
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	68 26 71 10 80       	push   $0x80107126
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 60 2a 11 80       	push   $0x80112a60
80102017:	e8 2b 25 00 00       	call   80104547 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 60 2a 11 80       	push   $0x80112a60
80102029:	e8 7e 25 00 00       	call   801045ac <release>
8010202e:	83 c4 10             	add    $0x10,%esp
}
80102031:	eb ca                	jmp    80101ffd <kfree+0x59>

80102033 <freerange>:
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	56                   	push   %esi
80102037:	53                   	push   %ebx
80102038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102043:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102048:	eb 0e                	jmp    80102058 <freerange+0x25>
    kfree(p);
8010204a:	83 ec 0c             	sub    $0xc,%esp
8010204d:	50                   	push   %eax
8010204e:	e8 51 ff ff ff       	call   80101fa4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102053:	83 c4 10             	add    $0x10,%esp
80102056:	89 f0                	mov    %esi,%eax
80102058:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010205e:	39 de                	cmp    %ebx,%esi
80102060:	76 e8                	jbe    8010204a <freerange+0x17>
}
80102062:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102065:	5b                   	pop    %ebx
80102066:	5e                   	pop    %esi
80102067:	5d                   	pop    %ebp
80102068:	c3                   	ret    

80102069 <kinit1>:
{
80102069:	55                   	push   %ebp
8010206a:	89 e5                	mov    %esp,%ebp
8010206c:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010206f:	68 2c 71 10 80       	push   $0x8010712c
80102074:	68 60 2a 11 80       	push   $0x80112a60
80102079:	e8 8d 23 00 00       	call   8010440b <initlock>
  kmem.use_lock = 0;
8010207e:	c7 05 94 2a 11 80 00 	movl   $0x0,0x80112a94
80102085:	00 00 00 
  freerange(vstart, vend);
80102088:	83 c4 08             	add    $0x8,%esp
8010208b:	ff 75 0c             	pushl  0xc(%ebp)
8010208e:	ff 75 08             	pushl  0x8(%ebp)
80102091:	e8 9d ff ff ff       	call   80102033 <freerange>
}
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	c9                   	leave  
8010209a:	c3                   	ret    

8010209b <kinit2>:
{
8010209b:	55                   	push   %ebp
8010209c:	89 e5                	mov    %esp,%ebp
8010209e:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	ff 75 08             	pushl  0x8(%ebp)
801020a7:	e8 87 ff ff ff       	call   80102033 <freerange>
  kmem.use_lock = 1;
801020ac:	c7 05 94 2a 11 80 01 	movl   $0x1,0x80112a94
801020b3:	00 00 00 
}
801020b6:	83 c4 10             	add    $0x10,%esp
801020b9:	c9                   	leave  
801020ba:	c3                   	ret    

801020bb <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020bb:	55                   	push   %ebp
801020bc:	89 e5                	mov    %esp,%ebp
801020be:	53                   	push   %ebx
801020bf:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020c2:	83 3d 94 2a 11 80 00 	cmpl   $0x0,0x80112a94
801020c9:	75 21                	jne    801020ec <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020cb:	8b 1d 98 2a 11 80    	mov    0x80112a98,%ebx
  if(r)
801020d1:	85 db                	test   %ebx,%ebx
801020d3:	74 07                	je     801020dc <kalloc+0x21>
    kmem.freelist = r->next;
801020d5:	8b 03                	mov    (%ebx),%eax
801020d7:	a3 98 2a 11 80       	mov    %eax,0x80112a98
  if(kmem.use_lock)
801020dc:	83 3d 94 2a 11 80 00 	cmpl   $0x0,0x80112a94
801020e3:	75 19                	jne    801020fe <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
801020e5:	89 d8                	mov    %ebx,%eax
801020e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020ea:	c9                   	leave  
801020eb:	c3                   	ret    
    acquire(&kmem.lock);
801020ec:	83 ec 0c             	sub    $0xc,%esp
801020ef:	68 60 2a 11 80       	push   $0x80112a60
801020f4:	e8 4e 24 00 00       	call   80104547 <acquire>
801020f9:	83 c4 10             	add    $0x10,%esp
801020fc:	eb cd                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
801020fe:	83 ec 0c             	sub    $0xc,%esp
80102101:	68 60 2a 11 80       	push   $0x80112a60
80102106:	e8 a1 24 00 00       	call   801045ac <release>
8010210b:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010210e:	eb d5                	jmp    801020e5 <kalloc+0x2a>

80102110 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102110:	55                   	push   %ebp
80102111:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102113:	ba 64 00 00 00       	mov    $0x64,%edx
80102118:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102119:	a8 01                	test   $0x1,%al
8010211b:	0f 84 b5 00 00 00    	je     801021d6 <kbdgetc+0xc6>
80102121:	ba 60 00 00 00       	mov    $0x60,%edx
80102126:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102127:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010212a:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102130:	74 5c                	je     8010218e <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102132:	84 c0                	test   %al,%al
80102134:	78 66                	js     8010219c <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102136:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
8010213c:	f6 c1 40             	test   $0x40,%cl
8010213f:	74 0f                	je     80102150 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102141:	83 c8 80             	or     $0xffffff80,%eax
80102144:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102147:	83 e1 bf             	and    $0xffffffbf,%ecx
8010214a:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
80102150:	0f b6 8a 60 72 10 80 	movzbl -0x7fef8da0(%edx),%ecx
80102157:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
8010215d:	0f b6 82 60 71 10 80 	movzbl -0x7fef8ea0(%edx),%eax
80102164:	31 c1                	xor    %eax,%ecx
80102166:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010216c:	89 c8                	mov    %ecx,%eax
8010216e:	83 e0 03             	and    $0x3,%eax
80102171:	8b 04 85 40 71 10 80 	mov    -0x7fef8ec0(,%eax,4),%eax
80102178:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010217c:	f6 c1 08             	test   $0x8,%cl
8010217f:	74 19                	je     8010219a <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102181:	8d 50 9f             	lea    -0x61(%eax),%edx
80102184:	83 fa 19             	cmp    $0x19,%edx
80102187:	77 40                	ja     801021c9 <kbdgetc+0xb9>
      c += 'A' - 'a';
80102189:	83 e8 20             	sub    $0x20,%eax
8010218c:	eb 0c                	jmp    8010219a <kbdgetc+0x8a>
    shift |= E0ESC;
8010218e:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
80102195:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010219a:	5d                   	pop    %ebp
8010219b:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010219c:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801021a2:	f6 c1 40             	test   $0x40,%cl
801021a5:	75 05                	jne    801021ac <kbdgetc+0x9c>
801021a7:	89 c2                	mov    %eax,%edx
801021a9:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801021ac:	0f b6 82 60 72 10 80 	movzbl -0x7fef8da0(%edx),%eax
801021b3:	83 c8 40             	or     $0x40,%eax
801021b6:	0f b6 c0             	movzbl %al,%eax
801021b9:	f7 d0                	not    %eax
801021bb:	21 c8                	and    %ecx,%eax
801021bd:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
801021c2:	b8 00 00 00 00       	mov    $0x0,%eax
801021c7:	eb d1                	jmp    8010219a <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
801021c9:	8d 50 bf             	lea    -0x41(%eax),%edx
801021cc:	83 fa 19             	cmp    $0x19,%edx
801021cf:	77 c9                	ja     8010219a <kbdgetc+0x8a>
      c += 'a' - 'A';
801021d1:	83 c0 20             	add    $0x20,%eax
  return c;
801021d4:	eb c4                	jmp    8010219a <kbdgetc+0x8a>
    return -1;
801021d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801021db:	eb bd                	jmp    8010219a <kbdgetc+0x8a>

801021dd <kbdintr>:

void
kbdintr(void)
{
801021dd:	55                   	push   %ebp
801021de:	89 e5                	mov    %esp,%ebp
801021e0:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801021e3:	68 10 21 10 80       	push   $0x80102110
801021e8:	e8 51 e5 ff ff       	call   8010073e <consoleintr>
}
801021ed:	83 c4 10             	add    $0x10,%esp
801021f0:	c9                   	leave  
801021f1:	c3                   	ret    

801021f2 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801021f2:	55                   	push   %ebp
801021f3:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801021f5:	8b 0d 9c 2a 11 80    	mov    0x80112a9c,%ecx
801021fb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801021fe:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102200:	a1 9c 2a 11 80       	mov    0x80112a9c,%eax
80102205:	8b 40 20             	mov    0x20(%eax),%eax
}
80102208:	5d                   	pop    %ebp
80102209:	c3                   	ret    

8010220a <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010220a:	55                   	push   %ebp
8010220b:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010220d:	ba 70 00 00 00       	mov    $0x70,%edx
80102212:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102213:	ba 71 00 00 00       	mov    $0x71,%edx
80102218:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102219:	0f b6 c0             	movzbl %al,%eax
}
8010221c:	5d                   	pop    %ebp
8010221d:	c3                   	ret    

8010221e <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010221e:	55                   	push   %ebp
8010221f:	89 e5                	mov    %esp,%ebp
80102221:	53                   	push   %ebx
80102222:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102224:	b8 00 00 00 00       	mov    $0x0,%eax
80102229:	e8 dc ff ff ff       	call   8010220a <cmos_read>
8010222e:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102230:	b8 02 00 00 00       	mov    $0x2,%eax
80102235:	e8 d0 ff ff ff       	call   8010220a <cmos_read>
8010223a:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010223d:	b8 04 00 00 00       	mov    $0x4,%eax
80102242:	e8 c3 ff ff ff       	call   8010220a <cmos_read>
80102247:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010224a:	b8 07 00 00 00       	mov    $0x7,%eax
8010224f:	e8 b6 ff ff ff       	call   8010220a <cmos_read>
80102254:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102257:	b8 08 00 00 00       	mov    $0x8,%eax
8010225c:	e8 a9 ff ff ff       	call   8010220a <cmos_read>
80102261:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
80102264:	b8 09 00 00 00       	mov    $0x9,%eax
80102269:	e8 9c ff ff ff       	call   8010220a <cmos_read>
8010226e:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102271:	5b                   	pop    %ebx
80102272:	5d                   	pop    %ebp
80102273:	c3                   	ret    

80102274 <lapicinit>:
  if(!lapic)
80102274:	83 3d 9c 2a 11 80 00 	cmpl   $0x0,0x80112a9c
8010227b:	0f 84 fb 00 00 00    	je     8010237c <lapicinit+0x108>
{
80102281:	55                   	push   %ebp
80102282:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102284:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102289:	b8 3c 00 00 00       	mov    $0x3c,%eax
8010228e:	e8 5f ff ff ff       	call   801021f2 <lapicw>
  lapicw(TDCR, X1);
80102293:	ba 0b 00 00 00       	mov    $0xb,%edx
80102298:	b8 f8 00 00 00       	mov    $0xf8,%eax
8010229d:	e8 50 ff ff ff       	call   801021f2 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022a2:	ba 20 00 02 00       	mov    $0x20020,%edx
801022a7:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022ac:	e8 41 ff ff ff       	call   801021f2 <lapicw>
  lapicw(TICR, 10000000);
801022b1:	ba 80 96 98 00       	mov    $0x989680,%edx
801022b6:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022bb:	e8 32 ff ff ff       	call   801021f2 <lapicw>
  lapicw(LINT0, MASKED);
801022c0:	ba 00 00 01 00       	mov    $0x10000,%edx
801022c5:	b8 d4 00 00 00       	mov    $0xd4,%eax
801022ca:	e8 23 ff ff ff       	call   801021f2 <lapicw>
  lapicw(LINT1, MASKED);
801022cf:	ba 00 00 01 00       	mov    $0x10000,%edx
801022d4:	b8 d8 00 00 00       	mov    $0xd8,%eax
801022d9:	e8 14 ff ff ff       	call   801021f2 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801022de:	a1 9c 2a 11 80       	mov    0x80112a9c,%eax
801022e3:	8b 40 30             	mov    0x30(%eax),%eax
801022e6:	c1 e8 10             	shr    $0x10,%eax
801022e9:	3c 03                	cmp    $0x3,%al
801022eb:	77 7b                	ja     80102368 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801022ed:	ba 33 00 00 00       	mov    $0x33,%edx
801022f2:	b8 dc 00 00 00       	mov    $0xdc,%eax
801022f7:	e8 f6 fe ff ff       	call   801021f2 <lapicw>
  lapicw(ESR, 0);
801022fc:	ba 00 00 00 00       	mov    $0x0,%edx
80102301:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102306:	e8 e7 fe ff ff       	call   801021f2 <lapicw>
  lapicw(ESR, 0);
8010230b:	ba 00 00 00 00       	mov    $0x0,%edx
80102310:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102315:	e8 d8 fe ff ff       	call   801021f2 <lapicw>
  lapicw(EOI, 0);
8010231a:	ba 00 00 00 00       	mov    $0x0,%edx
8010231f:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102324:	e8 c9 fe ff ff       	call   801021f2 <lapicw>
  lapicw(ICRHI, 0);
80102329:	ba 00 00 00 00       	mov    $0x0,%edx
8010232e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102333:	e8 ba fe ff ff       	call   801021f2 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102338:	ba 00 85 08 00       	mov    $0x88500,%edx
8010233d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102342:	e8 ab fe ff ff       	call   801021f2 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102347:	a1 9c 2a 11 80       	mov    0x80112a9c,%eax
8010234c:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102352:	f6 c4 10             	test   $0x10,%ah
80102355:	75 f0                	jne    80102347 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102357:	ba 00 00 00 00       	mov    $0x0,%edx
8010235c:	b8 20 00 00 00       	mov    $0x20,%eax
80102361:	e8 8c fe ff ff       	call   801021f2 <lapicw>
}
80102366:	5d                   	pop    %ebp
80102367:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102368:	ba 00 00 01 00       	mov    $0x10000,%edx
8010236d:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102372:	e8 7b fe ff ff       	call   801021f2 <lapicw>
80102377:	e9 71 ff ff ff       	jmp    801022ed <lapicinit+0x79>
8010237c:	f3 c3                	repz ret 

8010237e <lapicid>:
{
8010237e:	55                   	push   %ebp
8010237f:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102381:	a1 9c 2a 11 80       	mov    0x80112a9c,%eax
80102386:	85 c0                	test   %eax,%eax
80102388:	74 08                	je     80102392 <lapicid+0x14>
  return lapic[ID] >> 24;
8010238a:	8b 40 20             	mov    0x20(%eax),%eax
8010238d:	c1 e8 18             	shr    $0x18,%eax
}
80102390:	5d                   	pop    %ebp
80102391:	c3                   	ret    
    return 0;
80102392:	b8 00 00 00 00       	mov    $0x0,%eax
80102397:	eb f7                	jmp    80102390 <lapicid+0x12>

80102399 <lapiceoi>:
  if(lapic)
80102399:	83 3d 9c 2a 11 80 00 	cmpl   $0x0,0x80112a9c
801023a0:	74 14                	je     801023b6 <lapiceoi+0x1d>
{
801023a2:	55                   	push   %ebp
801023a3:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801023a5:	ba 00 00 00 00       	mov    $0x0,%edx
801023aa:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023af:	e8 3e fe ff ff       	call   801021f2 <lapicw>
}
801023b4:	5d                   	pop    %ebp
801023b5:	c3                   	ret    
801023b6:	f3 c3                	repz ret 

801023b8 <microdelay>:
{
801023b8:	55                   	push   %ebp
801023b9:	89 e5                	mov    %esp,%ebp
}
801023bb:	5d                   	pop    %ebp
801023bc:	c3                   	ret    

801023bd <lapicstartap>:
{
801023bd:	55                   	push   %ebp
801023be:	89 e5                	mov    %esp,%ebp
801023c0:	57                   	push   %edi
801023c1:	56                   	push   %esi
801023c2:	53                   	push   %ebx
801023c3:	8b 75 08             	mov    0x8(%ebp),%esi
801023c6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023c9:	b8 0f 00 00 00       	mov    $0xf,%eax
801023ce:	ba 70 00 00 00       	mov    $0x70,%edx
801023d3:	ee                   	out    %al,(%dx)
801023d4:	b8 0a 00 00 00       	mov    $0xa,%eax
801023d9:	ba 71 00 00 00       	mov    $0x71,%edx
801023de:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801023df:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801023e6:	00 00 
  wrv[1] = addr >> 4;
801023e8:	89 f8                	mov    %edi,%eax
801023ea:	c1 e8 04             	shr    $0x4,%eax
801023ed:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801023f3:	c1 e6 18             	shl    $0x18,%esi
801023f6:	89 f2                	mov    %esi,%edx
801023f8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801023fd:	e8 f0 fd ff ff       	call   801021f2 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102402:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102407:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010240c:	e8 e1 fd ff ff       	call   801021f2 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102411:	ba 00 85 00 00       	mov    $0x8500,%edx
80102416:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010241b:	e8 d2 fd ff ff       	call   801021f2 <lapicw>
  for(i = 0; i < 2; i++){
80102420:	bb 00 00 00 00       	mov    $0x0,%ebx
80102425:	eb 21                	jmp    80102448 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102427:	89 f2                	mov    %esi,%edx
80102429:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010242e:	e8 bf fd ff ff       	call   801021f2 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102433:	89 fa                	mov    %edi,%edx
80102435:	c1 ea 0c             	shr    $0xc,%edx
80102438:	80 ce 06             	or     $0x6,%dh
8010243b:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102440:	e8 ad fd ff ff       	call   801021f2 <lapicw>
  for(i = 0; i < 2; i++){
80102445:	83 c3 01             	add    $0x1,%ebx
80102448:	83 fb 01             	cmp    $0x1,%ebx
8010244b:	7e da                	jle    80102427 <lapicstartap+0x6a>
}
8010244d:	5b                   	pop    %ebx
8010244e:	5e                   	pop    %esi
8010244f:	5f                   	pop    %edi
80102450:	5d                   	pop    %ebp
80102451:	c3                   	ret    

80102452 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102452:	55                   	push   %ebp
80102453:	89 e5                	mov    %esp,%ebp
80102455:	57                   	push   %edi
80102456:	56                   	push   %esi
80102457:	53                   	push   %ebx
80102458:	83 ec 3c             	sub    $0x3c,%esp
8010245b:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010245e:	b8 0b 00 00 00       	mov    $0xb,%eax
80102463:	e8 a2 fd ff ff       	call   8010220a <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102468:	83 e0 04             	and    $0x4,%eax
8010246b:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010246d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102470:	e8 a9 fd ff ff       	call   8010221e <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102475:	b8 0a 00 00 00       	mov    $0xa,%eax
8010247a:	e8 8b fd ff ff       	call   8010220a <cmos_read>
8010247f:	a8 80                	test   $0x80,%al
80102481:	75 ea                	jne    8010246d <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102483:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102486:	89 d8                	mov    %ebx,%eax
80102488:	e8 91 fd ff ff       	call   8010221e <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010248d:	83 ec 04             	sub    $0x4,%esp
80102490:	6a 18                	push   $0x18
80102492:	53                   	push   %ebx
80102493:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102496:	50                   	push   %eax
80102497:	e8 9d 21 00 00       	call   80104639 <memcmp>
8010249c:	83 c4 10             	add    $0x10,%esp
8010249f:	85 c0                	test   %eax,%eax
801024a1:	75 ca                	jne    8010246d <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024a3:	85 ff                	test   %edi,%edi
801024a5:	0f 85 84 00 00 00    	jne    8010252f <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024ab:	8b 55 d0             	mov    -0x30(%ebp),%edx
801024ae:	89 d0                	mov    %edx,%eax
801024b0:	c1 e8 04             	shr    $0x4,%eax
801024b3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024b6:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024b9:	83 e2 0f             	and    $0xf,%edx
801024bc:	01 d0                	add    %edx,%eax
801024be:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
801024c1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801024c4:	89 d0                	mov    %edx,%eax
801024c6:	c1 e8 04             	shr    $0x4,%eax
801024c9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024cc:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024cf:	83 e2 0f             	and    $0xf,%edx
801024d2:	01 d0                	add    %edx,%eax
801024d4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801024d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
801024da:	89 d0                	mov    %edx,%eax
801024dc:	c1 e8 04             	shr    $0x4,%eax
801024df:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024e2:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024e5:	83 e2 0f             	and    $0xf,%edx
801024e8:	01 d0                	add    %edx,%eax
801024ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801024ed:	8b 55 dc             	mov    -0x24(%ebp),%edx
801024f0:	89 d0                	mov    %edx,%eax
801024f2:	c1 e8 04             	shr    $0x4,%eax
801024f5:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024f8:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024fb:	83 e2 0f             	and    $0xf,%edx
801024fe:	01 d0                	add    %edx,%eax
80102500:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102503:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102506:	89 d0                	mov    %edx,%eax
80102508:	c1 e8 04             	shr    $0x4,%eax
8010250b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010250e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102511:	83 e2 0f             	and    $0xf,%edx
80102514:	01 d0                	add    %edx,%eax
80102516:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102519:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010251c:	89 d0                	mov    %edx,%eax
8010251e:	c1 e8 04             	shr    $0x4,%eax
80102521:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102524:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102527:	83 e2 0f             	and    $0xf,%edx
8010252a:	01 d0                	add    %edx,%eax
8010252c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
8010252f:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102532:	89 06                	mov    %eax,(%esi)
80102534:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102537:	89 46 04             	mov    %eax,0x4(%esi)
8010253a:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010253d:	89 46 08             	mov    %eax,0x8(%esi)
80102540:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102543:	89 46 0c             	mov    %eax,0xc(%esi)
80102546:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102549:	89 46 10             	mov    %eax,0x10(%esi)
8010254c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010254f:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102552:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102559:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010255c:	5b                   	pop    %ebx
8010255d:	5e                   	pop    %esi
8010255e:	5f                   	pop    %edi
8010255f:	5d                   	pop    %ebp
80102560:	c3                   	ret    

80102561 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102561:	55                   	push   %ebp
80102562:	89 e5                	mov    %esp,%ebp
80102564:	53                   	push   %ebx
80102565:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102568:	ff 35 d4 2a 11 80    	pushl  0x80112ad4
8010256e:	ff 35 e4 2a 11 80    	pushl  0x80112ae4
80102574:	e8 f3 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102579:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010257c:	89 1d e8 2a 11 80    	mov    %ebx,0x80112ae8
  for (i = 0; i < log.lh.n; i++) {
80102582:	83 c4 10             	add    $0x10,%esp
80102585:	ba 00 00 00 00       	mov    $0x0,%edx
8010258a:	eb 0e                	jmp    8010259a <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010258c:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102590:	89 0c 95 ec 2a 11 80 	mov    %ecx,-0x7feed514(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102597:	83 c2 01             	add    $0x1,%edx
8010259a:	39 d3                	cmp    %edx,%ebx
8010259c:	7f ee                	jg     8010258c <read_head+0x2b>
  }
  brelse(buf);
8010259e:	83 ec 0c             	sub    $0xc,%esp
801025a1:	50                   	push   %eax
801025a2:	e8 2e dc ff ff       	call   801001d5 <brelse>
}
801025a7:	83 c4 10             	add    $0x10,%esp
801025aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025ad:	c9                   	leave  
801025ae:	c3                   	ret    

801025af <install_trans>:
{
801025af:	55                   	push   %ebp
801025b0:	89 e5                	mov    %esp,%ebp
801025b2:	57                   	push   %edi
801025b3:	56                   	push   %esi
801025b4:	53                   	push   %ebx
801025b5:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025b8:	bb 00 00 00 00       	mov    $0x0,%ebx
801025bd:	eb 66                	jmp    80102625 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801025bf:	89 d8                	mov    %ebx,%eax
801025c1:	03 05 d4 2a 11 80    	add    0x80112ad4,%eax
801025c7:	83 c0 01             	add    $0x1,%eax
801025ca:	83 ec 08             	sub    $0x8,%esp
801025cd:	50                   	push   %eax
801025ce:	ff 35 e4 2a 11 80    	pushl  0x80112ae4
801025d4:	e8 93 db ff ff       	call   8010016c <bread>
801025d9:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801025db:	83 c4 08             	add    $0x8,%esp
801025de:	ff 34 9d ec 2a 11 80 	pushl  -0x7feed514(,%ebx,4)
801025e5:	ff 35 e4 2a 11 80    	pushl  0x80112ae4
801025eb:	e8 7c db ff ff       	call   8010016c <bread>
801025f0:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801025f2:	8d 57 5c             	lea    0x5c(%edi),%edx
801025f5:	8d 40 5c             	lea    0x5c(%eax),%eax
801025f8:	83 c4 0c             	add    $0xc,%esp
801025fb:	68 00 02 00 00       	push   $0x200
80102600:	52                   	push   %edx
80102601:	50                   	push   %eax
80102602:	e8 67 20 00 00       	call   8010466e <memmove>
    bwrite(dbuf);  // write dst to disk
80102607:	89 34 24             	mov    %esi,(%esp)
8010260a:	e8 8b db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
8010260f:	89 3c 24             	mov    %edi,(%esp)
80102612:	e8 be db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102617:	89 34 24             	mov    %esi,(%esp)
8010261a:	e8 b6 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010261f:	83 c3 01             	add    $0x1,%ebx
80102622:	83 c4 10             	add    $0x10,%esp
80102625:	39 1d e8 2a 11 80    	cmp    %ebx,0x80112ae8
8010262b:	7f 92                	jg     801025bf <install_trans+0x10>
}
8010262d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102630:	5b                   	pop    %ebx
80102631:	5e                   	pop    %esi
80102632:	5f                   	pop    %edi
80102633:	5d                   	pop    %ebp
80102634:	c3                   	ret    

80102635 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102635:	55                   	push   %ebp
80102636:	89 e5                	mov    %esp,%ebp
80102638:	53                   	push   %ebx
80102639:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010263c:	ff 35 d4 2a 11 80    	pushl  0x80112ad4
80102642:	ff 35 e4 2a 11 80    	pushl  0x80112ae4
80102648:	e8 1f db ff ff       	call   8010016c <bread>
8010264d:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010264f:	8b 0d e8 2a 11 80    	mov    0x80112ae8,%ecx
80102655:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102658:	83 c4 10             	add    $0x10,%esp
8010265b:	b8 00 00 00 00       	mov    $0x0,%eax
80102660:	eb 0e                	jmp    80102670 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
80102662:	8b 14 85 ec 2a 11 80 	mov    -0x7feed514(,%eax,4),%edx
80102669:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
8010266d:	83 c0 01             	add    $0x1,%eax
80102670:	39 c1                	cmp    %eax,%ecx
80102672:	7f ee                	jg     80102662 <write_head+0x2d>
  }
  bwrite(buf);
80102674:	83 ec 0c             	sub    $0xc,%esp
80102677:	53                   	push   %ebx
80102678:	e8 1d db ff ff       	call   8010019a <bwrite>
  brelse(buf);
8010267d:	89 1c 24             	mov    %ebx,(%esp)
80102680:	e8 50 db ff ff       	call   801001d5 <brelse>
}
80102685:	83 c4 10             	add    $0x10,%esp
80102688:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010268b:	c9                   	leave  
8010268c:	c3                   	ret    

8010268d <recover_from_log>:

static void
recover_from_log(void)
{
8010268d:	55                   	push   %ebp
8010268e:	89 e5                	mov    %esp,%ebp
80102690:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102693:	e8 c9 fe ff ff       	call   80102561 <read_head>
  install_trans(); // if committed, copy from log to disk
80102698:	e8 12 ff ff ff       	call   801025af <install_trans>
  log.lh.n = 0;
8010269d:	c7 05 e8 2a 11 80 00 	movl   $0x0,0x80112ae8
801026a4:	00 00 00 
  write_head(); // clear the log
801026a7:	e8 89 ff ff ff       	call   80102635 <write_head>
}
801026ac:	c9                   	leave  
801026ad:	c3                   	ret    

801026ae <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026ae:	55                   	push   %ebp
801026af:	89 e5                	mov    %esp,%ebp
801026b1:	57                   	push   %edi
801026b2:	56                   	push   %esi
801026b3:	53                   	push   %ebx
801026b4:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026b7:	bb 00 00 00 00       	mov    $0x0,%ebx
801026bc:	eb 66                	jmp    80102724 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801026be:	89 d8                	mov    %ebx,%eax
801026c0:	03 05 d4 2a 11 80    	add    0x80112ad4,%eax
801026c6:	83 c0 01             	add    $0x1,%eax
801026c9:	83 ec 08             	sub    $0x8,%esp
801026cc:	50                   	push   %eax
801026cd:	ff 35 e4 2a 11 80    	pushl  0x80112ae4
801026d3:	e8 94 da ff ff       	call   8010016c <bread>
801026d8:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801026da:	83 c4 08             	add    $0x8,%esp
801026dd:	ff 34 9d ec 2a 11 80 	pushl  -0x7feed514(,%ebx,4)
801026e4:	ff 35 e4 2a 11 80    	pushl  0x80112ae4
801026ea:	e8 7d da ff ff       	call   8010016c <bread>
801026ef:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801026f1:	8d 50 5c             	lea    0x5c(%eax),%edx
801026f4:	8d 46 5c             	lea    0x5c(%esi),%eax
801026f7:	83 c4 0c             	add    $0xc,%esp
801026fa:	68 00 02 00 00       	push   $0x200
801026ff:	52                   	push   %edx
80102700:	50                   	push   %eax
80102701:	e8 68 1f 00 00       	call   8010466e <memmove>
    bwrite(to);  // write the log
80102706:	89 34 24             	mov    %esi,(%esp)
80102709:	e8 8c da ff ff       	call   8010019a <bwrite>
    brelse(from);
8010270e:	89 3c 24             	mov    %edi,(%esp)
80102711:	e8 bf da ff ff       	call   801001d5 <brelse>
    brelse(to);
80102716:	89 34 24             	mov    %esi,(%esp)
80102719:	e8 b7 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010271e:	83 c3 01             	add    $0x1,%ebx
80102721:	83 c4 10             	add    $0x10,%esp
80102724:	39 1d e8 2a 11 80    	cmp    %ebx,0x80112ae8
8010272a:	7f 92                	jg     801026be <write_log+0x10>
  }
}
8010272c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010272f:	5b                   	pop    %ebx
80102730:	5e                   	pop    %esi
80102731:	5f                   	pop    %edi
80102732:	5d                   	pop    %ebp
80102733:	c3                   	ret    

80102734 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102734:	83 3d e8 2a 11 80 00 	cmpl   $0x0,0x80112ae8
8010273b:	7e 26                	jle    80102763 <commit+0x2f>
{
8010273d:	55                   	push   %ebp
8010273e:	89 e5                	mov    %esp,%ebp
80102740:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102743:	e8 66 ff ff ff       	call   801026ae <write_log>
    write_head();    // Write header to disk -- the real commit
80102748:	e8 e8 fe ff ff       	call   80102635 <write_head>
    install_trans(); // Now install writes to home locations
8010274d:	e8 5d fe ff ff       	call   801025af <install_trans>
    log.lh.n = 0;
80102752:	c7 05 e8 2a 11 80 00 	movl   $0x0,0x80112ae8
80102759:	00 00 00 
    write_head();    // Erase the transaction from the log
8010275c:	e8 d4 fe ff ff       	call   80102635 <write_head>
  }
}
80102761:	c9                   	leave  
80102762:	c3                   	ret    
80102763:	f3 c3                	repz ret 

80102765 <initlog>:
{
80102765:	55                   	push   %ebp
80102766:	89 e5                	mov    %esp,%ebp
80102768:	53                   	push   %ebx
80102769:	83 ec 2c             	sub    $0x2c,%esp
8010276c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
8010276f:	68 60 73 10 80       	push   $0x80107360
80102774:	68 a0 2a 11 80       	push   $0x80112aa0
80102779:	e8 8d 1c 00 00       	call   8010440b <initlock>
  readsb(dev, &sb);
8010277e:	83 c4 08             	add    $0x8,%esp
80102781:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102784:	50                   	push   %eax
80102785:	53                   	push   %ebx
80102786:	e8 ab ea ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
8010278b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010278e:	a3 d4 2a 11 80       	mov    %eax,0x80112ad4
  log.size = sb.nlog;
80102793:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102796:	a3 d8 2a 11 80       	mov    %eax,0x80112ad8
  log.dev = dev;
8010279b:	89 1d e4 2a 11 80    	mov    %ebx,0x80112ae4
  recover_from_log();
801027a1:	e8 e7 fe ff ff       	call   8010268d <recover_from_log>
}
801027a6:	83 c4 10             	add    $0x10,%esp
801027a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ac:	c9                   	leave  
801027ad:	c3                   	ret    

801027ae <begin_op>:
{
801027ae:	55                   	push   %ebp
801027af:	89 e5                	mov    %esp,%ebp
801027b1:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027b4:	68 a0 2a 11 80       	push   $0x80112aa0
801027b9:	e8 89 1d 00 00       	call   80104547 <acquire>
801027be:	83 c4 10             	add    $0x10,%esp
801027c1:	eb 15                	jmp    801027d8 <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c3:	83 ec 08             	sub    $0x8,%esp
801027c6:	68 a0 2a 11 80       	push   $0x80112aa0
801027cb:	68 a0 2a 11 80       	push   $0x80112aa0
801027d0:	e8 89 13 00 00       	call   80103b5e <sleep>
801027d5:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801027d8:	83 3d e0 2a 11 80 00 	cmpl   $0x0,0x80112ae0
801027df:	75 e2                	jne    801027c3 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801027e1:	a1 dc 2a 11 80       	mov    0x80112adc,%eax
801027e6:	83 c0 01             	add    $0x1,%eax
801027e9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801027ec:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801027ef:	03 15 e8 2a 11 80    	add    0x80112ae8,%edx
801027f5:	83 fa 1e             	cmp    $0x1e,%edx
801027f8:	7e 17                	jle    80102811 <begin_op+0x63>
      sleep(&log, &log.lock);
801027fa:	83 ec 08             	sub    $0x8,%esp
801027fd:	68 a0 2a 11 80       	push   $0x80112aa0
80102802:	68 a0 2a 11 80       	push   $0x80112aa0
80102807:	e8 52 13 00 00       	call   80103b5e <sleep>
8010280c:	83 c4 10             	add    $0x10,%esp
8010280f:	eb c7                	jmp    801027d8 <begin_op+0x2a>
      log.outstanding += 1;
80102811:	a3 dc 2a 11 80       	mov    %eax,0x80112adc
      release(&log.lock);
80102816:	83 ec 0c             	sub    $0xc,%esp
80102819:	68 a0 2a 11 80       	push   $0x80112aa0
8010281e:	e8 89 1d 00 00       	call   801045ac <release>
}
80102823:	83 c4 10             	add    $0x10,%esp
80102826:	c9                   	leave  
80102827:	c3                   	ret    

80102828 <end_op>:
{
80102828:	55                   	push   %ebp
80102829:	89 e5                	mov    %esp,%ebp
8010282b:	53                   	push   %ebx
8010282c:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
8010282f:	68 a0 2a 11 80       	push   $0x80112aa0
80102834:	e8 0e 1d 00 00       	call   80104547 <acquire>
  log.outstanding -= 1;
80102839:	a1 dc 2a 11 80       	mov    0x80112adc,%eax
8010283e:	83 e8 01             	sub    $0x1,%eax
80102841:	a3 dc 2a 11 80       	mov    %eax,0x80112adc
  if(log.committing)
80102846:	8b 1d e0 2a 11 80    	mov    0x80112ae0,%ebx
8010284c:	83 c4 10             	add    $0x10,%esp
8010284f:	85 db                	test   %ebx,%ebx
80102851:	75 2c                	jne    8010287f <end_op+0x57>
  if(log.outstanding == 0){
80102853:	85 c0                	test   %eax,%eax
80102855:	75 35                	jne    8010288c <end_op+0x64>
    log.committing = 1;
80102857:	c7 05 e0 2a 11 80 01 	movl   $0x1,0x80112ae0
8010285e:	00 00 00 
    do_commit = 1;
80102861:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102866:	83 ec 0c             	sub    $0xc,%esp
80102869:	68 a0 2a 11 80       	push   $0x80112aa0
8010286e:	e8 39 1d 00 00       	call   801045ac <release>
  if(do_commit){
80102873:	83 c4 10             	add    $0x10,%esp
80102876:	85 db                	test   %ebx,%ebx
80102878:	75 24                	jne    8010289e <end_op+0x76>
}
8010287a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010287d:	c9                   	leave  
8010287e:	c3                   	ret    
    panic("log.committing");
8010287f:	83 ec 0c             	sub    $0xc,%esp
80102882:	68 64 73 10 80       	push   $0x80107364
80102887:	e8 bc da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	68 a0 2a 11 80       	push   $0x80112aa0
80102894:	e8 2d 14 00 00       	call   80103cc6 <wakeup>
80102899:	83 c4 10             	add    $0x10,%esp
8010289c:	eb c8                	jmp    80102866 <end_op+0x3e>
    commit();
8010289e:	e8 91 fe ff ff       	call   80102734 <commit>
    acquire(&log.lock);
801028a3:	83 ec 0c             	sub    $0xc,%esp
801028a6:	68 a0 2a 11 80       	push   $0x80112aa0
801028ab:	e8 97 1c 00 00       	call   80104547 <acquire>
    log.committing = 0;
801028b0:	c7 05 e0 2a 11 80 00 	movl   $0x0,0x80112ae0
801028b7:	00 00 00 
    wakeup(&log);
801028ba:	c7 04 24 a0 2a 11 80 	movl   $0x80112aa0,(%esp)
801028c1:	e8 00 14 00 00       	call   80103cc6 <wakeup>
    release(&log.lock);
801028c6:	c7 04 24 a0 2a 11 80 	movl   $0x80112aa0,(%esp)
801028cd:	e8 da 1c 00 00       	call   801045ac <release>
801028d2:	83 c4 10             	add    $0x10,%esp
}
801028d5:	eb a3                	jmp    8010287a <end_op+0x52>

801028d7 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801028d7:	55                   	push   %ebp
801028d8:	89 e5                	mov    %esp,%ebp
801028da:	53                   	push   %ebx
801028db:	83 ec 04             	sub    $0x4,%esp
801028de:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801028e1:	8b 15 e8 2a 11 80    	mov    0x80112ae8,%edx
801028e7:	83 fa 1d             	cmp    $0x1d,%edx
801028ea:	7f 45                	jg     80102931 <log_write+0x5a>
801028ec:	a1 d8 2a 11 80       	mov    0x80112ad8,%eax
801028f1:	83 e8 01             	sub    $0x1,%eax
801028f4:	39 c2                	cmp    %eax,%edx
801028f6:	7d 39                	jge    80102931 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
801028f8:	83 3d dc 2a 11 80 00 	cmpl   $0x0,0x80112adc
801028ff:	7e 3d                	jle    8010293e <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102901:	83 ec 0c             	sub    $0xc,%esp
80102904:	68 a0 2a 11 80       	push   $0x80112aa0
80102909:	e8 39 1c 00 00       	call   80104547 <acquire>
  for (i = 0; i < log.lh.n; i++) {
8010290e:	83 c4 10             	add    $0x10,%esp
80102911:	b8 00 00 00 00       	mov    $0x0,%eax
80102916:	8b 15 e8 2a 11 80    	mov    0x80112ae8,%edx
8010291c:	39 c2                	cmp    %eax,%edx
8010291e:	7e 2b                	jle    8010294b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102920:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102923:	39 0c 85 ec 2a 11 80 	cmp    %ecx,-0x7feed514(,%eax,4)
8010292a:	74 1f                	je     8010294b <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
8010292c:	83 c0 01             	add    $0x1,%eax
8010292f:	eb e5                	jmp    80102916 <log_write+0x3f>
    panic("too big a transaction");
80102931:	83 ec 0c             	sub    $0xc,%esp
80102934:	68 73 73 10 80       	push   $0x80107373
80102939:	e8 0a da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 89 73 10 80       	push   $0x80107389
80102946:	e8 fd d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
8010294b:	8b 4b 08             	mov    0x8(%ebx),%ecx
8010294e:	89 0c 85 ec 2a 11 80 	mov    %ecx,-0x7feed514(,%eax,4)
  if (i == log.lh.n)
80102955:	39 c2                	cmp    %eax,%edx
80102957:	74 18                	je     80102971 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102959:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010295c:	83 ec 0c             	sub    $0xc,%esp
8010295f:	68 a0 2a 11 80       	push   $0x80112aa0
80102964:	e8 43 1c 00 00       	call   801045ac <release>
}
80102969:	83 c4 10             	add    $0x10,%esp
8010296c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010296f:	c9                   	leave  
80102970:	c3                   	ret    
    log.lh.n++;
80102971:	83 c2 01             	add    $0x1,%edx
80102974:	89 15 e8 2a 11 80    	mov    %edx,0x80112ae8
8010297a:	eb dd                	jmp    80102959 <log_write+0x82>

8010297c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010297c:	55                   	push   %ebp
8010297d:	89 e5                	mov    %esp,%ebp
8010297f:	53                   	push   %ebx
80102980:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102983:	68 8a 00 00 00       	push   $0x8a
80102988:	68 8c a4 10 80       	push   $0x8010a48c
8010298d:	68 00 70 00 80       	push   $0x80007000
80102992:	e8 d7 1c 00 00       	call   8010466e <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102997:	83 c4 10             	add    $0x10,%esp
8010299a:	bb a0 2b 11 80       	mov    $0x80112ba0,%ebx
8010299f:	eb 06                	jmp    801029a7 <startothers+0x2b>
801029a1:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029a7:	69 05 20 31 11 80 b0 	imul   $0xb0,0x80113120,%eax
801029ae:	00 00 00 
801029b1:	05 a0 2b 11 80       	add    $0x80112ba0,%eax
801029b6:	39 d8                	cmp    %ebx,%eax
801029b8:	76 4c                	jbe    80102a06 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
801029ba:	e8 98 07 00 00       	call   80103157 <mycpu>
801029bf:	39 d8                	cmp    %ebx,%eax
801029c1:	74 de                	je     801029a1 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801029c3:	e8 f3 f6 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
801029c8:	05 00 10 00 00       	add    $0x1000,%eax
801029cd:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
801029d2:	c7 05 f8 6f 00 80 4a 	movl   $0x80102a4a,0x80006ff8
801029d9:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801029dc:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
801029e3:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
801029e6:	83 ec 08             	sub    $0x8,%esp
801029e9:	68 00 70 00 00       	push   $0x7000
801029ee:	0f b6 03             	movzbl (%ebx),%eax
801029f1:	50                   	push   %eax
801029f2:	e8 c6 f9 ff ff       	call   801023bd <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801029f7:	83 c4 10             	add    $0x10,%esp
801029fa:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a00:	85 c0                	test   %eax,%eax
80102a02:	74 f6                	je     801029fa <startothers+0x7e>
80102a04:	eb 9b                	jmp    801029a1 <startothers+0x25>
      ;
  }
}
80102a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a09:	c9                   	leave  
80102a0a:	c3                   	ret    

80102a0b <mpmain>:
{
80102a0b:	55                   	push   %ebp
80102a0c:	89 e5                	mov    %esp,%ebp
80102a0e:	53                   	push   %ebx
80102a0f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a12:	e8 9c 07 00 00       	call   801031b3 <cpuid>
80102a17:	89 c3                	mov    %eax,%ebx
80102a19:	e8 95 07 00 00       	call   801031b3 <cpuid>
80102a1e:	83 ec 04             	sub    $0x4,%esp
80102a21:	53                   	push   %ebx
80102a22:	50                   	push   %eax
80102a23:	68 a4 73 10 80       	push   $0x801073a4
80102a28:	e8 de db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a2d:	e8 02 2e 00 00       	call   80105834 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a32:	e8 20 07 00 00       	call   80103157 <mycpu>
80102a37:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a39:	b8 01 00 00 00       	mov    $0x1,%eax
80102a3e:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a45:	e8 eb 0a 00 00       	call   80103535 <scheduler>

80102a4a <mpenter>:
{
80102a4a:	55                   	push   %ebp
80102a4b:	89 e5                	mov    %esp,%ebp
80102a4d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a50:	e8 e8 3d 00 00       	call   8010683d <switchkvm>
  seginit();
80102a55:	e8 97 3c 00 00       	call   801066f1 <seginit>
  lapicinit();
80102a5a:	e8 15 f8 ff ff       	call   80102274 <lapicinit>
  mpmain();
80102a5f:	e8 a7 ff ff ff       	call   80102a0b <mpmain>

80102a64 <main>:
{
80102a64:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102a68:	83 e4 f0             	and    $0xfffffff0,%esp
80102a6b:	ff 71 fc             	pushl  -0x4(%ecx)
80102a6e:	55                   	push   %ebp
80102a6f:	89 e5                	mov    %esp,%ebp
80102a71:	51                   	push   %ecx
80102a72:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102a75:	68 00 00 40 80       	push   $0x80400000
80102a7a:	68 c8 65 11 80       	push   $0x801165c8
80102a7f:	e8 e5 f5 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102a84:	e8 41 42 00 00       	call   80106cca <kvmalloc>
  mpinit();        // detect other processors
80102a89:	e8 c9 01 00 00       	call   80102c57 <mpinit>
  lapicinit();     // interrupt controller
80102a8e:	e8 e1 f7 ff ff       	call   80102274 <lapicinit>
  seginit();       // segment descriptors
80102a93:	e8 59 3c 00 00       	call   801066f1 <seginit>
  picinit();       // disable pic
80102a98:	e8 82 02 00 00       	call   80102d1f <picinit>
  ioapicinit();    // another interrupt controller
80102a9d:	e8 58 f4 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102aa2:	e8 e7 dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102aa7:	e8 36 30 00 00       	call   80105ae2 <uartinit>
  pinit();         // process table
80102aac:	e8 8c 06 00 00       	call   8010313d <pinit>
  tvinit();        // trap vectors
80102ab1:	e8 cd 2c 00 00       	call   80105783 <tvinit>
  binit();         // buffer cache
80102ab6:	e8 39 d6 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102abb:	e8 53 e1 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102ac0:	e8 3b f2 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102ac5:	e8 b2 fe ff ff       	call   8010297c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102aca:	83 c4 08             	add    $0x8,%esp
80102acd:	68 00 00 00 8e       	push   $0x8e000000
80102ad2:	68 00 00 40 80       	push   $0x80400000
80102ad7:	e8 bf f5 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102adc:	e8 11 07 00 00       	call   801031f2 <userinit>
  mpmain();        // finish this processor's setup
80102ae1:	e8 25 ff ff ff       	call   80102a0b <mpmain>

80102ae6 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102ae6:	55                   	push   %ebp
80102ae7:	89 e5                	mov    %esp,%ebp
80102ae9:	56                   	push   %esi
80102aea:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102aeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102af0:	b9 00 00 00 00       	mov    $0x0,%ecx
80102af5:	eb 09                	jmp    80102b00 <sum+0x1a>
    sum += addr[i];
80102af7:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102afb:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102afd:	83 c1 01             	add    $0x1,%ecx
80102b00:	39 d1                	cmp    %edx,%ecx
80102b02:	7c f3                	jl     80102af7 <sum+0x11>
  return sum;
}
80102b04:	89 d8                	mov    %ebx,%eax
80102b06:	5b                   	pop    %ebx
80102b07:	5e                   	pop    %esi
80102b08:	5d                   	pop    %ebp
80102b09:	c3                   	ret    

80102b0a <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b0a:	55                   	push   %ebp
80102b0b:	89 e5                	mov    %esp,%ebp
80102b0d:	56                   	push   %esi
80102b0e:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102b0f:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102b15:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102b17:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b19:	eb 03                	jmp    80102b1e <mpsearch1+0x14>
80102b1b:	83 c3 10             	add    $0x10,%ebx
80102b1e:	39 f3                	cmp    %esi,%ebx
80102b20:	73 29                	jae    80102b4b <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b22:	83 ec 04             	sub    $0x4,%esp
80102b25:	6a 04                	push   $0x4
80102b27:	68 b8 73 10 80       	push   $0x801073b8
80102b2c:	53                   	push   %ebx
80102b2d:	e8 07 1b 00 00       	call   80104639 <memcmp>
80102b32:	83 c4 10             	add    $0x10,%esp
80102b35:	85 c0                	test   %eax,%eax
80102b37:	75 e2                	jne    80102b1b <mpsearch1+0x11>
80102b39:	ba 10 00 00 00       	mov    $0x10,%edx
80102b3e:	89 d8                	mov    %ebx,%eax
80102b40:	e8 a1 ff ff ff       	call   80102ae6 <sum>
80102b45:	84 c0                	test   %al,%al
80102b47:	75 d2                	jne    80102b1b <mpsearch1+0x11>
80102b49:	eb 05                	jmp    80102b50 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102b4b:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b50:	89 d8                	mov    %ebx,%eax
80102b52:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b55:	5b                   	pop    %ebx
80102b56:	5e                   	pop    %esi
80102b57:	5d                   	pop    %ebp
80102b58:	c3                   	ret    

80102b59 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b59:	55                   	push   %ebp
80102b5a:	89 e5                	mov    %esp,%ebp
80102b5c:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102b5f:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102b66:	c1 e0 08             	shl    $0x8,%eax
80102b69:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102b70:	09 d0                	or     %edx,%eax
80102b72:	c1 e0 04             	shl    $0x4,%eax
80102b75:	85 c0                	test   %eax,%eax
80102b77:	74 1f                	je     80102b98 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102b79:	ba 00 04 00 00       	mov    $0x400,%edx
80102b7e:	e8 87 ff ff ff       	call   80102b0a <mpsearch1>
80102b83:	85 c0                	test   %eax,%eax
80102b85:	75 0f                	jne    80102b96 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102b87:	ba 00 00 01 00       	mov    $0x10000,%edx
80102b8c:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102b91:	e8 74 ff ff ff       	call   80102b0a <mpsearch1>
}
80102b96:	c9                   	leave  
80102b97:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102b98:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102b9f:	c1 e0 08             	shl    $0x8,%eax
80102ba2:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102ba9:	09 d0                	or     %edx,%eax
80102bab:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102bae:	2d 00 04 00 00       	sub    $0x400,%eax
80102bb3:	ba 00 04 00 00       	mov    $0x400,%edx
80102bb8:	e8 4d ff ff ff       	call   80102b0a <mpsearch1>
80102bbd:	85 c0                	test   %eax,%eax
80102bbf:	75 d5                	jne    80102b96 <mpsearch+0x3d>
80102bc1:	eb c4                	jmp    80102b87 <mpsearch+0x2e>

80102bc3 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102bc3:	55                   	push   %ebp
80102bc4:	89 e5                	mov    %esp,%ebp
80102bc6:	57                   	push   %edi
80102bc7:	56                   	push   %esi
80102bc8:	53                   	push   %ebx
80102bc9:	83 ec 1c             	sub    $0x1c,%esp
80102bcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102bcf:	e8 85 ff ff ff       	call   80102b59 <mpsearch>
80102bd4:	85 c0                	test   %eax,%eax
80102bd6:	74 5c                	je     80102c34 <mpconfig+0x71>
80102bd8:	89 c7                	mov    %eax,%edi
80102bda:	8b 58 04             	mov    0x4(%eax),%ebx
80102bdd:	85 db                	test   %ebx,%ebx
80102bdf:	74 5a                	je     80102c3b <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102be1:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102be7:	83 ec 04             	sub    $0x4,%esp
80102bea:	6a 04                	push   $0x4
80102bec:	68 bd 73 10 80       	push   $0x801073bd
80102bf1:	56                   	push   %esi
80102bf2:	e8 42 1a 00 00       	call   80104639 <memcmp>
80102bf7:	83 c4 10             	add    $0x10,%esp
80102bfa:	85 c0                	test   %eax,%eax
80102bfc:	75 44                	jne    80102c42 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102bfe:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102c05:	3c 01                	cmp    $0x1,%al
80102c07:	0f 95 c2             	setne  %dl
80102c0a:	3c 04                	cmp    $0x4,%al
80102c0c:	0f 95 c0             	setne  %al
80102c0f:	84 c2                	test   %al,%dl
80102c11:	75 36                	jne    80102c49 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c13:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102c1a:	89 f0                	mov    %esi,%eax
80102c1c:	e8 c5 fe ff ff       	call   80102ae6 <sum>
80102c21:	84 c0                	test   %al,%al
80102c23:	75 2b                	jne    80102c50 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102c25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c28:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102c2a:	89 f0                	mov    %esi,%eax
80102c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c2f:	5b                   	pop    %ebx
80102c30:	5e                   	pop    %esi
80102c31:	5f                   	pop    %edi
80102c32:	5d                   	pop    %ebp
80102c33:	c3                   	ret    
    return 0;
80102c34:	be 00 00 00 00       	mov    $0x0,%esi
80102c39:	eb ef                	jmp    80102c2a <mpconfig+0x67>
80102c3b:	be 00 00 00 00       	mov    $0x0,%esi
80102c40:	eb e8                	jmp    80102c2a <mpconfig+0x67>
    return 0;
80102c42:	be 00 00 00 00       	mov    $0x0,%esi
80102c47:	eb e1                	jmp    80102c2a <mpconfig+0x67>
    return 0;
80102c49:	be 00 00 00 00       	mov    $0x0,%esi
80102c4e:	eb da                	jmp    80102c2a <mpconfig+0x67>
    return 0;
80102c50:	be 00 00 00 00       	mov    $0x0,%esi
80102c55:	eb d3                	jmp    80102c2a <mpconfig+0x67>

80102c57 <mpinit>:

void
mpinit(void)
{
80102c57:	55                   	push   %ebp
80102c58:	89 e5                	mov    %esp,%ebp
80102c5a:	57                   	push   %edi
80102c5b:	56                   	push   %esi
80102c5c:	53                   	push   %ebx
80102c5d:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102c60:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102c63:	e8 5b ff ff ff       	call   80102bc3 <mpconfig>
80102c68:	85 c0                	test   %eax,%eax
80102c6a:	74 19                	je     80102c85 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102c6c:	8b 50 24             	mov    0x24(%eax),%edx
80102c6f:	89 15 9c 2a 11 80    	mov    %edx,0x80112a9c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c75:	8d 50 2c             	lea    0x2c(%eax),%edx
80102c78:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102c7c:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102c7e:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102c83:	eb 34                	jmp    80102cb9 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102c85:	83 ec 0c             	sub    $0xc,%esp
80102c88:	68 c2 73 10 80       	push   $0x801073c2
80102c8d:	e8 b6 d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102c92:	8b 35 20 31 11 80    	mov    0x80113120,%esi
80102c98:	83 fe 07             	cmp    $0x7,%esi
80102c9b:	7f 19                	jg     80102cb6 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102c9d:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102ca1:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102ca7:	88 87 a0 2b 11 80    	mov    %al,-0x7feed460(%edi)
        ncpu++;
80102cad:	83 c6 01             	add    $0x1,%esi
80102cb0:	89 35 20 31 11 80    	mov    %esi,0x80113120
      }
      p += sizeof(struct mpproc);
80102cb6:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cb9:	39 ca                	cmp    %ecx,%edx
80102cbb:	73 2b                	jae    80102ce8 <mpinit+0x91>
    switch(*p){
80102cbd:	0f b6 02             	movzbl (%edx),%eax
80102cc0:	3c 04                	cmp    $0x4,%al
80102cc2:	77 1d                	ja     80102ce1 <mpinit+0x8a>
80102cc4:	0f b6 c0             	movzbl %al,%eax
80102cc7:	ff 24 85 fc 73 10 80 	jmp    *-0x7fef8c04(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102cce:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102cd2:	a2 80 2b 11 80       	mov    %al,0x80112b80
      p += sizeof(struct mpioapic);
80102cd7:	83 c2 08             	add    $0x8,%edx
      continue;
80102cda:	eb dd                	jmp    80102cb9 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102cdc:	83 c2 08             	add    $0x8,%edx
      continue;
80102cdf:	eb d8                	jmp    80102cb9 <mpinit+0x62>
    default:
      ismp = 0;
80102ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
80102ce6:	eb d1                	jmp    80102cb9 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102ce8:	85 db                	test   %ebx,%ebx
80102cea:	74 26                	je     80102d12 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102cec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102cef:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102cf3:	74 15                	je     80102d0a <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cf5:	b8 70 00 00 00       	mov    $0x70,%eax
80102cfa:	ba 22 00 00 00       	mov    $0x22,%edx
80102cff:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d00:	ba 23 00 00 00       	mov    $0x23,%edx
80102d05:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d06:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d09:	ee                   	out    %al,(%dx)
  }
}
80102d0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d0d:	5b                   	pop    %ebx
80102d0e:	5e                   	pop    %esi
80102d0f:	5f                   	pop    %edi
80102d10:	5d                   	pop    %ebp
80102d11:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d12:	83 ec 0c             	sub    $0xc,%esp
80102d15:	68 dc 73 10 80       	push   $0x801073dc
80102d1a:	e8 29 d6 ff ff       	call   80100348 <panic>

80102d1f <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d27:	ba 21 00 00 00       	mov    $0x21,%edx
80102d2c:	ee                   	out    %al,(%dx)
80102d2d:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d32:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d33:	5d                   	pop    %ebp
80102d34:	c3                   	ret    

80102d35 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d35:	55                   	push   %ebp
80102d36:	89 e5                	mov    %esp,%ebp
80102d38:	57                   	push   %edi
80102d39:	56                   	push   %esi
80102d3a:	53                   	push   %ebx
80102d3b:	83 ec 0c             	sub    $0xc,%esp
80102d3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d41:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d44:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d4a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d50:	e8 d8 de ff ff       	call   80100c2d <filealloc>
80102d55:	89 03                	mov    %eax,(%ebx)
80102d57:	85 c0                	test   %eax,%eax
80102d59:	74 16                	je     80102d71 <pipealloc+0x3c>
80102d5b:	e8 cd de ff ff       	call   80100c2d <filealloc>
80102d60:	89 06                	mov    %eax,(%esi)
80102d62:	85 c0                	test   %eax,%eax
80102d64:	74 0b                	je     80102d71 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102d66:	e8 50 f3 ff ff       	call   801020bb <kalloc>
80102d6b:	89 c7                	mov    %eax,%edi
80102d6d:	85 c0                	test   %eax,%eax
80102d6f:	75 35                	jne    80102da6 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102d71:	8b 03                	mov    (%ebx),%eax
80102d73:	85 c0                	test   %eax,%eax
80102d75:	74 0c                	je     80102d83 <pipealloc+0x4e>
    fileclose(*f0);
80102d77:	83 ec 0c             	sub    $0xc,%esp
80102d7a:	50                   	push   %eax
80102d7b:	e8 53 df ff ff       	call   80100cd3 <fileclose>
80102d80:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102d83:	8b 06                	mov    (%esi),%eax
80102d85:	85 c0                	test   %eax,%eax
80102d87:	0f 84 8b 00 00 00    	je     80102e18 <pipealloc+0xe3>
    fileclose(*f1);
80102d8d:	83 ec 0c             	sub    $0xc,%esp
80102d90:	50                   	push   %eax
80102d91:	e8 3d df ff ff       	call   80100cd3 <fileclose>
80102d96:	83 c4 10             	add    $0x10,%esp
  return -1;
80102d99:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102d9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102da1:	5b                   	pop    %ebx
80102da2:	5e                   	pop    %esi
80102da3:	5f                   	pop    %edi
80102da4:	5d                   	pop    %ebp
80102da5:	c3                   	ret    
  p->readopen = 1;
80102da6:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102dad:	00 00 00 
  p->writeopen = 1;
80102db0:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102db7:	00 00 00 
  p->nwrite = 0;
80102dba:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102dc1:	00 00 00 
  p->nread = 0;
80102dc4:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102dcb:	00 00 00 
  initlock(&p->lock, "pipe");
80102dce:	83 ec 08             	sub    $0x8,%esp
80102dd1:	68 10 74 10 80       	push   $0x80107410
80102dd6:	50                   	push   %eax
80102dd7:	e8 2f 16 00 00       	call   8010440b <initlock>
  (*f0)->type = FD_PIPE;
80102ddc:	8b 03                	mov    (%ebx),%eax
80102dde:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102de4:	8b 03                	mov    (%ebx),%eax
80102de6:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102dea:	8b 03                	mov    (%ebx),%eax
80102dec:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102df0:	8b 03                	mov    (%ebx),%eax
80102df2:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102df5:	8b 06                	mov    (%esi),%eax
80102df7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102dfd:	8b 06                	mov    (%esi),%eax
80102dff:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e03:	8b 06                	mov    (%esi),%eax
80102e05:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e09:	8b 06                	mov    (%esi),%eax
80102e0b:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e0e:	83 c4 10             	add    $0x10,%esp
80102e11:	b8 00 00 00 00       	mov    $0x0,%eax
80102e16:	eb 86                	jmp    80102d9e <pipealloc+0x69>
  return -1;
80102e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e1d:	e9 7c ff ff ff       	jmp    80102d9e <pipealloc+0x69>

80102e22 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e22:	55                   	push   %ebp
80102e23:	89 e5                	mov    %esp,%ebp
80102e25:	53                   	push   %ebx
80102e26:	83 ec 10             	sub    $0x10,%esp
80102e29:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e2c:	53                   	push   %ebx
80102e2d:	e8 15 17 00 00       	call   80104547 <acquire>
  if(writable){
80102e32:	83 c4 10             	add    $0x10,%esp
80102e35:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e39:	74 3f                	je     80102e7a <pipeclose+0x58>
    p->writeopen = 0;
80102e3b:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e42:	00 00 00 
    wakeup(&p->nread);
80102e45:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e4b:	83 ec 0c             	sub    $0xc,%esp
80102e4e:	50                   	push   %eax
80102e4f:	e8 72 0e 00 00       	call   80103cc6 <wakeup>
80102e54:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e57:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102e5e:	75 09                	jne    80102e69 <pipeclose+0x47>
80102e60:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102e67:	74 2f                	je     80102e98 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102e69:	83 ec 0c             	sub    $0xc,%esp
80102e6c:	53                   	push   %ebx
80102e6d:	e8 3a 17 00 00       	call   801045ac <release>
80102e72:	83 c4 10             	add    $0x10,%esp
}
80102e75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e78:	c9                   	leave  
80102e79:	c3                   	ret    
    p->readopen = 0;
80102e7a:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102e81:	00 00 00 
    wakeup(&p->nwrite);
80102e84:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102e8a:	83 ec 0c             	sub    $0xc,%esp
80102e8d:	50                   	push   %eax
80102e8e:	e8 33 0e 00 00       	call   80103cc6 <wakeup>
80102e93:	83 c4 10             	add    $0x10,%esp
80102e96:	eb bf                	jmp    80102e57 <pipeclose+0x35>
    release(&p->lock);
80102e98:	83 ec 0c             	sub    $0xc,%esp
80102e9b:	53                   	push   %ebx
80102e9c:	e8 0b 17 00 00       	call   801045ac <release>
    kfree((char*)p);
80102ea1:	89 1c 24             	mov    %ebx,(%esp)
80102ea4:	e8 fb f0 ff ff       	call   80101fa4 <kfree>
80102ea9:	83 c4 10             	add    $0x10,%esp
80102eac:	eb c7                	jmp    80102e75 <pipeclose+0x53>

80102eae <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102eae:	55                   	push   %ebp
80102eaf:	89 e5                	mov    %esp,%ebp
80102eb1:	57                   	push   %edi
80102eb2:	56                   	push   %esi
80102eb3:	53                   	push   %ebx
80102eb4:	83 ec 18             	sub    $0x18,%esp
80102eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102eba:	89 de                	mov    %ebx,%esi
80102ebc:	53                   	push   %ebx
80102ebd:	e8 85 16 00 00       	call   80104547 <acquire>
  for(i = 0; i < n; i++){
80102ec2:	83 c4 10             	add    $0x10,%esp
80102ec5:	bf 00 00 00 00       	mov    $0x0,%edi
80102eca:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102ecd:	0f 8d 88 00 00 00    	jge    80102f5b <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102ed3:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102ed9:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102edf:	05 00 02 00 00       	add    $0x200,%eax
80102ee4:	39 c2                	cmp    %eax,%edx
80102ee6:	75 51                	jne    80102f39 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102ee8:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102eef:	74 2f                	je     80102f20 <pipewrite+0x72>
80102ef1:	e8 d8 02 00 00       	call   801031ce <myproc>
80102ef6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102efa:	75 24                	jne    80102f20 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102efc:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f02:	83 ec 0c             	sub    $0xc,%esp
80102f05:	50                   	push   %eax
80102f06:	e8 bb 0d 00 00       	call   80103cc6 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f0b:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f11:	83 c4 08             	add    $0x8,%esp
80102f14:	56                   	push   %esi
80102f15:	50                   	push   %eax
80102f16:	e8 43 0c 00 00       	call   80103b5e <sleep>
80102f1b:	83 c4 10             	add    $0x10,%esp
80102f1e:	eb b3                	jmp    80102ed3 <pipewrite+0x25>
        release(&p->lock);
80102f20:	83 ec 0c             	sub    $0xc,%esp
80102f23:	53                   	push   %ebx
80102f24:	e8 83 16 00 00       	call   801045ac <release>
        return -1;
80102f29:	83 c4 10             	add    $0x10,%esp
80102f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f34:	5b                   	pop    %ebx
80102f35:	5e                   	pop    %esi
80102f36:	5f                   	pop    %edi
80102f37:	5d                   	pop    %ebp
80102f38:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f39:	8d 42 01             	lea    0x1(%edx),%eax
80102f3c:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f42:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f48:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f4b:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f4f:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f53:	83 c7 01             	add    $0x1,%edi
80102f56:	e9 6f ff ff ff       	jmp    80102eca <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f5b:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f61:	83 ec 0c             	sub    $0xc,%esp
80102f64:	50                   	push   %eax
80102f65:	e8 5c 0d 00 00       	call   80103cc6 <wakeup>
  release(&p->lock);
80102f6a:	89 1c 24             	mov    %ebx,(%esp)
80102f6d:	e8 3a 16 00 00       	call   801045ac <release>
  return n;
80102f72:	83 c4 10             	add    $0x10,%esp
80102f75:	8b 45 10             	mov    0x10(%ebp),%eax
80102f78:	eb b7                	jmp    80102f31 <pipewrite+0x83>

80102f7a <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102f7a:	55                   	push   %ebp
80102f7b:	89 e5                	mov    %esp,%ebp
80102f7d:	57                   	push   %edi
80102f7e:	56                   	push   %esi
80102f7f:	53                   	push   %ebx
80102f80:	83 ec 18             	sub    $0x18,%esp
80102f83:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f86:	89 df                	mov    %ebx,%edi
80102f88:	53                   	push   %ebx
80102f89:	e8 b9 15 00 00       	call   80104547 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102f8e:	83 c4 10             	add    $0x10,%esp
80102f91:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102f97:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102f9d:	75 3d                	jne    80102fdc <piperead+0x62>
80102f9f:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fa5:	85 f6                	test   %esi,%esi
80102fa7:	74 38                	je     80102fe1 <piperead+0x67>
    if(myproc()->killed){
80102fa9:	e8 20 02 00 00       	call   801031ce <myproc>
80102fae:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102fb2:	75 15                	jne    80102fc9 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102fb4:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fba:	83 ec 08             	sub    $0x8,%esp
80102fbd:	57                   	push   %edi
80102fbe:	50                   	push   %eax
80102fbf:	e8 9a 0b 00 00       	call   80103b5e <sleep>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	eb c8                	jmp    80102f91 <piperead+0x17>
      release(&p->lock);
80102fc9:	83 ec 0c             	sub    $0xc,%esp
80102fcc:	53                   	push   %ebx
80102fcd:	e8 da 15 00 00       	call   801045ac <release>
      return -1;
80102fd2:	83 c4 10             	add    $0x10,%esp
80102fd5:	be ff ff ff ff       	mov    $0xffffffff,%esi
80102fda:	eb 50                	jmp    8010302c <piperead+0xb2>
80102fdc:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80102fe1:	3b 75 10             	cmp    0x10(%ebp),%esi
80102fe4:	7d 2c                	jge    80103012 <piperead+0x98>
    if(p->nread == p->nwrite)
80102fe6:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102fec:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80102ff2:	74 1e                	je     80103012 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80102ff4:	8d 50 01             	lea    0x1(%eax),%edx
80102ff7:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80102ffd:	25 ff 01 00 00       	and    $0x1ff,%eax
80103002:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103007:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010300a:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010300d:	83 c6 01             	add    $0x1,%esi
80103010:	eb cf                	jmp    80102fe1 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103012:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103018:	83 ec 0c             	sub    $0xc,%esp
8010301b:	50                   	push   %eax
8010301c:	e8 a5 0c 00 00       	call   80103cc6 <wakeup>
  release(&p->lock);
80103021:	89 1c 24             	mov    %ebx,(%esp)
80103024:	e8 83 15 00 00       	call   801045ac <release>
  return i;
80103029:	83 c4 10             	add    $0x10,%esp
}
8010302c:	89 f0                	mov    %esi,%eax
8010302e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103031:	5b                   	pop    %ebx
80103032:	5e                   	pop    %esi
80103033:	5f                   	pop    %edi
80103034:	5d                   	pop    %ebp
80103035:	c3                   	ret    

80103036 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103036:	55                   	push   %ebp
80103037:	89 e5                	mov    %esp,%ebp
80103039:	53                   	push   %ebx
8010303a:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010303d:	68 40 31 11 80       	push   $0x80113140
80103042:	e8 00 15 00 00       	call   80104547 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103047:	83 c4 10             	add    $0x10,%esp
8010304a:	bb 74 31 11 80       	mov    $0x80113174,%ebx
8010304f:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103055:	73 0e                	jae    80103065 <allocproc+0x2f>
    if(p->state == UNUSED)
80103057:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
8010305b:	74 1f                	je     8010307c <allocproc+0x46>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010305d:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103063:	eb ea                	jmp    8010304f <allocproc+0x19>
      goto found;

  release(&ptable.lock);
80103065:	83 ec 0c             	sub    $0xc,%esp
80103068:	68 40 31 11 80       	push   $0x80113140
8010306d:	e8 3a 15 00 00       	call   801045ac <release>
  return 0;
80103072:	83 c4 10             	add    $0x10,%esp
80103075:	bb 00 00 00 00       	mov    $0x0,%ebx
8010307a:	eb 69                	jmp    801030e5 <allocproc+0xaf>

found:
  p->state = EMBRYO;
8010307c:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103083:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103088:	8d 50 01             	lea    0x1(%eax),%edx
8010308b:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103091:	89 43 10             	mov    %eax,0x10(%ebx)

  release(&ptable.lock);
80103094:	83 ec 0c             	sub    $0xc,%esp
80103097:	68 40 31 11 80       	push   $0x80113140
8010309c:	e8 0b 15 00 00       	call   801045ac <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801030a1:	e8 15 f0 ff ff       	call   801020bb <kalloc>
801030a6:	89 43 08             	mov    %eax,0x8(%ebx)
801030a9:	83 c4 10             	add    $0x10,%esp
801030ac:	85 c0                	test   %eax,%eax
801030ae:	74 3c                	je     801030ec <allocproc+0xb6>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801030b0:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801030b6:	89 53 18             	mov    %edx,0x18(%ebx)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
801030b9:	c7 80 b0 0f 00 00 78 	movl   $0x80105778,0xfb0(%eax)
801030c0:	57 10 80 

  sp -= sizeof *p->context;
801030c3:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801030c8:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801030cb:	83 ec 04             	sub    $0x4,%esp
801030ce:	6a 14                	push   $0x14
801030d0:	6a 00                	push   $0x0
801030d2:	50                   	push   %eax
801030d3:	e8 1b 15 00 00       	call   801045f3 <memset>
  p->context->eip = (uint)forkret;
801030d8:	8b 43 1c             	mov    0x1c(%ebx),%eax
801030db:	c7 40 10 fa 30 10 80 	movl   $0x801030fa,0x10(%eax)

  return p;
801030e2:	83 c4 10             	add    $0x10,%esp
}
801030e5:	89 d8                	mov    %ebx,%eax
801030e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801030ea:	c9                   	leave  
801030eb:	c3                   	ret    
    p->state = UNUSED;
801030ec:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801030f3:	bb 00 00 00 00       	mov    $0x0,%ebx
801030f8:	eb eb                	jmp    801030e5 <allocproc+0xaf>

801030fa <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801030fa:	55                   	push   %ebp
801030fb:	89 e5                	mov    %esp,%ebp
801030fd:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103100:	68 40 31 11 80       	push   $0x80113140
80103105:	e8 a2 14 00 00       	call   801045ac <release>

  if (first) {
8010310a:	83 c4 10             	add    $0x10,%esp
8010310d:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103114:	75 02                	jne    80103118 <forkret+0x1e>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103116:	c9                   	leave  
80103117:	c3                   	ret    
    first = 0;
80103118:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
8010311f:	00 00 00 
    iinit(ROOTDEV);
80103122:	83 ec 0c             	sub    $0xc,%esp
80103125:	6a 01                	push   $0x1
80103127:	e8 c0 e1 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
8010312c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103133:	e8 2d f6 ff ff       	call   80102765 <initlog>
80103138:	83 c4 10             	add    $0x10,%esp
}
8010313b:	eb d9                	jmp    80103116 <forkret+0x1c>

8010313d <pinit>:
{
8010313d:	55                   	push   %ebp
8010313e:	89 e5                	mov    %esp,%ebp
80103140:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103143:	68 15 74 10 80       	push   $0x80107415
80103148:	68 40 31 11 80       	push   $0x80113140
8010314d:	e8 b9 12 00 00       	call   8010440b <initlock>
}
80103152:	83 c4 10             	add    $0x10,%esp
80103155:	c9                   	leave  
80103156:	c3                   	ret    

80103157 <mycpu>:
{
80103157:	55                   	push   %ebp
80103158:	89 e5                	mov    %esp,%ebp
8010315a:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010315d:	9c                   	pushf  
8010315e:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010315f:	f6 c4 02             	test   $0x2,%ah
80103162:	75 28                	jne    8010318c <mycpu+0x35>
  apicid = lapicid();
80103164:	e8 15 f2 ff ff       	call   8010237e <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103169:	ba 00 00 00 00       	mov    $0x0,%edx
8010316e:	39 15 20 31 11 80    	cmp    %edx,0x80113120
80103174:	7e 23                	jle    80103199 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103176:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010317c:	0f b6 89 a0 2b 11 80 	movzbl -0x7feed460(%ecx),%ecx
80103183:	39 c1                	cmp    %eax,%ecx
80103185:	74 1f                	je     801031a6 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103187:	83 c2 01             	add    $0x1,%edx
8010318a:	eb e2                	jmp    8010316e <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
8010318c:	83 ec 0c             	sub    $0xc,%esp
8010318f:	68 f8 74 10 80       	push   $0x801074f8
80103194:	e8 af d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103199:	83 ec 0c             	sub    $0xc,%esp
8010319c:	68 1c 74 10 80       	push   $0x8010741c
801031a1:	e8 a2 d1 ff ff       	call   80100348 <panic>
      return &cpus[i];
801031a6:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
801031ac:	05 a0 2b 11 80       	add    $0x80112ba0,%eax
}
801031b1:	c9                   	leave  
801031b2:	c3                   	ret    

801031b3 <cpuid>:
cpuid() {
801031b3:	55                   	push   %ebp
801031b4:	89 e5                	mov    %esp,%ebp
801031b6:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801031b9:	e8 99 ff ff ff       	call   80103157 <mycpu>
801031be:	2d a0 2b 11 80       	sub    $0x80112ba0,%eax
801031c3:	c1 f8 04             	sar    $0x4,%eax
801031c6:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801031cc:	c9                   	leave  
801031cd:	c3                   	ret    

801031ce <myproc>:
myproc(void) {
801031ce:	55                   	push   %ebp
801031cf:	89 e5                	mov    %esp,%ebp
801031d1:	53                   	push   %ebx
801031d2:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801031d5:	e8 90 12 00 00       	call   8010446a <pushcli>
  c = mycpu();
801031da:	e8 78 ff ff ff       	call   80103157 <mycpu>
  p = c->proc;
801031df:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801031e5:	e8 bd 12 00 00       	call   801044a7 <popcli>
}
801031ea:	89 d8                	mov    %ebx,%eax
801031ec:	83 c4 04             	add    $0x4,%esp
801031ef:	5b                   	pop    %ebx
801031f0:	5d                   	pop    %ebp
801031f1:	c3                   	ret    

801031f2 <userinit>:
{
801031f2:	55                   	push   %ebp
801031f3:	89 e5                	mov    %esp,%ebp
801031f5:	53                   	push   %ebx
801031f6:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801031f9:	e8 38 fe ff ff       	call   80103036 <allocproc>
801031fe:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103200:	a3 c0 a9 10 80       	mov    %eax,0x8010a9c0
  if((p->pgdir = setupkvm()) == 0)
80103205:	e8 52 3a 00 00       	call   80106c5c <setupkvm>
8010320a:	89 43 04             	mov    %eax,0x4(%ebx)
8010320d:	85 c0                	test   %eax,%eax
8010320f:	0f 84 db 00 00 00    	je     801032f0 <userinit+0xfe>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103215:	83 ec 04             	sub    $0x4,%esp
80103218:	68 2c 00 00 00       	push   $0x2c
8010321d:	68 60 a4 10 80       	push   $0x8010a460
80103222:	50                   	push   %eax
80103223:	e8 3f 37 00 00       	call   80106967 <inituvm>
  p->sz = PGSIZE;
80103228:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
8010322e:	83 c4 0c             	add    $0xc,%esp
80103231:	6a 4c                	push   $0x4c
80103233:	6a 00                	push   $0x0
80103235:	ff 73 18             	pushl  0x18(%ebx)
80103238:	e8 b6 13 00 00       	call   801045f3 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010323d:	8b 43 18             	mov    0x18(%ebx),%eax
80103240:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103246:	8b 43 18             	mov    0x18(%ebx),%eax
80103249:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010324f:	8b 43 18             	mov    0x18(%ebx),%eax
80103252:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103256:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010325a:	8b 43 18             	mov    0x18(%ebx),%eax
8010325d:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103261:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103265:	8b 43 18             	mov    0x18(%ebx),%eax
80103268:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010326f:	8b 43 18             	mov    0x18(%ebx),%eax
80103272:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103279:	8b 43 18             	mov    0x18(%ebx),%eax
8010327c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103283:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103286:	83 c4 0c             	add    $0xc,%esp
80103289:	6a 10                	push   $0x10
8010328b:	68 45 74 10 80       	push   $0x80107445
80103290:	50                   	push   %eax
80103291:	e8 c4 14 00 00       	call   8010475a <safestrcpy>
  p->cwd = namei("/");
80103296:	c7 04 24 4e 74 10 80 	movl   $0x8010744e,(%esp)
8010329d:	e8 3f e9 ff ff       	call   80101be1 <namei>
801032a2:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
801032a5:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
801032ac:	e8 96 12 00 00       	call   80104547 <acquire>
  p->state = RUNNABLE;
801032b1:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  p->priority = 3;
801032b8:	c7 83 9c 00 00 00 03 	movl   $0x3,0x9c(%ebx)
801032bf:	00 00 00 
  p->ticksUsed[3] = 0;
801032c2:	c7 83 ac 00 00 00 00 	movl   $0x0,0xac(%ebx)
801032c9:	00 00 00 
  q3[0] = p;
801032cc:	89 1d c0 a5 10 80    	mov    %ebx,0x8010a5c0
  p->qtail[3] = 1;
801032d2:	c7 83 88 00 00 00 01 	movl   $0x1,0x88(%ebx)
801032d9:	00 00 00 
  release(&ptable.lock);
801032dc:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
801032e3:	e8 c4 12 00 00       	call   801045ac <release>
}
801032e8:	83 c4 10             	add    $0x10,%esp
801032eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032ee:	c9                   	leave  
801032ef:	c3                   	ret    
    panic("userinit: out of memory?");
801032f0:	83 ec 0c             	sub    $0xc,%esp
801032f3:	68 2c 74 10 80       	push   $0x8010742c
801032f8:	e8 4b d0 ff ff       	call   80100348 <panic>

801032fd <growproc>:
{
801032fd:	55                   	push   %ebp
801032fe:	89 e5                	mov    %esp,%ebp
80103300:	56                   	push   %esi
80103301:	53                   	push   %ebx
80103302:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103305:	e8 c4 fe ff ff       	call   801031ce <myproc>
8010330a:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
8010330c:	8b 00                	mov    (%eax),%eax
  if(n > 0){
8010330e:	85 f6                	test   %esi,%esi
80103310:	7f 21                	jg     80103333 <growproc+0x36>
  } else if(n < 0){
80103312:	85 f6                	test   %esi,%esi
80103314:	79 33                	jns    80103349 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103316:	83 ec 04             	sub    $0x4,%esp
80103319:	01 c6                	add    %eax,%esi
8010331b:	56                   	push   %esi
8010331c:	50                   	push   %eax
8010331d:	ff 73 04             	pushl  0x4(%ebx)
80103320:	e8 4b 37 00 00       	call   80106a70 <deallocuvm>
80103325:	83 c4 10             	add    $0x10,%esp
80103328:	85 c0                	test   %eax,%eax
8010332a:	75 1d                	jne    80103349 <growproc+0x4c>
      return -1;
8010332c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103331:	eb 29                	jmp    8010335c <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103333:	83 ec 04             	sub    $0x4,%esp
80103336:	01 c6                	add    %eax,%esi
80103338:	56                   	push   %esi
80103339:	50                   	push   %eax
8010333a:	ff 73 04             	pushl  0x4(%ebx)
8010333d:	e8 c0 37 00 00       	call   80106b02 <allocuvm>
80103342:	83 c4 10             	add    $0x10,%esp
80103345:	85 c0                	test   %eax,%eax
80103347:	74 1a                	je     80103363 <growproc+0x66>
  curproc->sz = sz;
80103349:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
8010334b:	83 ec 0c             	sub    $0xc,%esp
8010334e:	53                   	push   %ebx
8010334f:	e8 fb 34 00 00       	call   8010684f <switchuvm>
  return 0;
80103354:	83 c4 10             	add    $0x10,%esp
80103357:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010335c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010335f:	5b                   	pop    %ebx
80103360:	5e                   	pop    %esi
80103361:	5d                   	pop    %ebp
80103362:	c3                   	ret    
      return -1;
80103363:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103368:	eb f2                	jmp    8010335c <growproc+0x5f>

8010336a <delete>:
delete(struct proc **queue, int pid){
8010336a:	55                   	push   %ebp
8010336b:	89 e5                	mov    %esp,%ebp
8010336d:	53                   	push   %ebx
8010336e:	8b 45 08             	mov    0x8(%ebp),%eax
80103371:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  for (int i = 0; i < NPROC; i++) {
80103374:	ba 00 00 00 00       	mov    $0x0,%edx
80103379:	83 fa 3f             	cmp    $0x3f,%edx
8010337c:	7f 0d                	jg     8010338b <delete+0x21>
    if (queue[i]->pid == pid) {
8010337e:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
80103381:	39 59 10             	cmp    %ebx,0x10(%ecx)
80103384:	74 0a                	je     80103390 <delete+0x26>
  for (int i = 0; i < NPROC; i++) {
80103386:	83 c2 01             	add    $0x1,%edx
80103389:	eb ee                	jmp    80103379 <delete+0xf>
  int position_in_queue = -1;
8010338b:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  if (position_in_queue != -1) {
80103390:	83 fa ff             	cmp    $0xffffffff,%edx
80103393:	75 0d                	jne    801033a2 <delete+0x38>
80103395:	eb 1a                	jmp    801033b1 <delete+0x47>
      queue[i] = queue[i+1];
80103397:	8d 4a 01             	lea    0x1(%edx),%ecx
8010339a:	8b 1c 88             	mov    (%eax,%ecx,4),%ebx
8010339d:	89 1c 90             	mov    %ebx,(%eax,%edx,4)
    for(int i = position_in_queue; i < NPROC; i++){
801033a0:	89 ca                	mov    %ecx,%edx
801033a2:	83 fa 3f             	cmp    $0x3f,%edx
801033a5:	7e f0                	jle    80103397 <delete+0x2d>
    queue[NPROC-1] = 0;
801033a7:	c7 80 fc 00 00 00 00 	movl   $0x0,0xfc(%eax)
801033ae:	00 00 00 
}
801033b1:	5b                   	pop    %ebx
801033b2:	5d                   	pop    %ebp
801033b3:	c3                   	ret    

801033b4 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801033b4:	55                   	push   %ebp
801033b5:	89 e5                	mov    %esp,%ebp
801033b7:	57                   	push   %edi
801033b8:	56                   	push   %esi
801033b9:	53                   	push   %ebx
801033ba:	89 c7                	mov    %eax,%edi
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801033bc:	bb 74 31 11 80       	mov    $0x80113174,%ebx
801033c1:	e9 04 01 00 00       	jmp    801034ca <wakeup1+0x116>
    if(p->state == SLEEPING && p->chan == chan){
      p->state = RUNNABLE;

      if (p->priority == 3) {
        delete(q3, p->pid);
801033c6:	ff 73 10             	pushl  0x10(%ebx)
801033c9:	68 c0 a5 10 80       	push   $0x8010a5c0
801033ce:	e8 97 ff ff ff       	call   8010336a <delete>
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
801033d3:	83 c4 08             	add    $0x8,%esp
801033d6:	b8 00 00 00 00       	mov    $0x0,%eax
801033db:	83 f8 3f             	cmp    $0x3f,%eax
801033de:	7f 16                	jg     801033f6 <wakeup1+0x42>
          if(q3[i] == 0){
801033e0:	83 3c 85 c0 a5 10 80 	cmpl   $0x0,-0x7fef5a40(,%eax,4)
801033e7:	00 
801033e8:	74 05                	je     801033ef <wakeup1+0x3b>
        for(int i = 0; i < NPROC; i++){
801033ea:	83 c0 01             	add    $0x1,%eax
801033ed:	eb ec                	jmp    801033db <wakeup1+0x27>
            q3[i] = p;
801033ef:	89 1c 85 c0 a5 10 80 	mov    %ebx,-0x7fef5a40(,%eax,4)
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[3] = 0;
801033f6:	c7 83 ac 00 00 00 00 	movl   $0x0,0xac(%ebx)
801033fd:	00 00 00 
        p->qtail[3]++;
80103400:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80103406:	83 c0 01             	add    $0x1,%eax
80103409:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
8010340f:	e9 b0 00 00 00       	jmp    801034c4 <wakeup1+0x110>
      } else if (p->priority == 2) {
        delete(q2, p->pid);
80103414:	ff 73 10             	pushl  0x10(%ebx)
80103417:	68 c0 a6 10 80       	push   $0x8010a6c0
8010341c:	e8 49 ff ff ff       	call   8010336a <delete>
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
80103421:	83 c4 08             	add    $0x8,%esp
80103424:	b8 00 00 00 00       	mov    $0x0,%eax
80103429:	83 f8 3f             	cmp    $0x3f,%eax
8010342c:	7f 16                	jg     80103444 <wakeup1+0x90>
          if(q2[i] == 0){
8010342e:	83 3c 85 c0 a6 10 80 	cmpl   $0x0,-0x7fef5940(,%eax,4)
80103435:	00 
80103436:	74 05                	je     8010343d <wakeup1+0x89>
        for(int i = 0; i < NPROC; i++){
80103438:	83 c0 01             	add    $0x1,%eax
8010343b:	eb ec                	jmp    80103429 <wakeup1+0x75>
            q2[i] = p;
8010343d:	89 1c 85 c0 a6 10 80 	mov    %ebx,-0x7fef5940(,%eax,4)
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[2] = 0;
80103444:	c7 83 a8 00 00 00 00 	movl   $0x0,0xa8(%ebx)
8010344b:	00 00 00 
        p->qtail[2]++;
8010344e:	8b 83 84 00 00 00    	mov    0x84(%ebx),%eax
80103454:	83 c0 01             	add    $0x1,%eax
80103457:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
8010345d:	eb 65                	jmp    801034c4 <wakeup1+0x110>
        // cprintf("PID %d In wakeup1: %d\n",p->pid, p->qtail[2]);
      } else if (p->priority == 1) {
        delete(q1, p->pid);
8010345f:	ff 73 10             	pushl  0x10(%ebx)
80103462:	68 c0 a7 10 80       	push   $0x8010a7c0
80103467:	e8 fe fe ff ff       	call   8010336a <delete>
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
8010346c:	83 c4 08             	add    $0x8,%esp
8010346f:	b8 00 00 00 00       	mov    $0x0,%eax
80103474:	83 f8 3f             	cmp    $0x3f,%eax
80103477:	7f 16                	jg     8010348f <wakeup1+0xdb>
          if(q1[i] == 0){
80103479:	83 3c 85 c0 a7 10 80 	cmpl   $0x0,-0x7fef5840(,%eax,4)
80103480:	00 
80103481:	74 05                	je     80103488 <wakeup1+0xd4>
        for(int i = 0; i < NPROC; i++){
80103483:	83 c0 01             	add    $0x1,%eax
80103486:	eb ec                	jmp    80103474 <wakeup1+0xc0>
            q1[i] = p;
80103488:	89 1c 85 c0 a7 10 80 	mov    %ebx,-0x7fef5840(,%eax,4)
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[1] = 0;
8010348f:	c7 83 a4 00 00 00 00 	movl   $0x0,0xa4(%ebx)
80103496:	00 00 00 
        p->qtail[1]++;
80103499:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
8010349f:	83 c0 01             	add    $0x1,%eax
801034a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
801034a8:	eb 1a                	jmp    801034c4 <wakeup1+0x110>
      } else if (p->priority == 0) {
        delete(q0, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q0[i] == 0){
            q0[i] = p;
801034aa:	89 1c b5 c0 a8 10 80 	mov    %ebx,-0x7fef5740(,%esi,4)
            break;
          }
        }
        // Resetting timer tick
        p->ticksUsed[0] = 0;
801034b1:	c7 83 a0 00 00 00 00 	movl   $0x0,0xa0(%ebx)
801034b8:	00 00 00 
        p->qtail[0]++;
801034bb:	8b 43 7c             	mov    0x7c(%ebx),%eax
801034be:	83 c0 01             	add    $0x1,%eax
801034c1:	89 43 7c             	mov    %eax,0x7c(%ebx)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
801034c4:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801034ca:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
801034d0:	73 5b                	jae    8010352d <wakeup1+0x179>
    if(p->state == SLEEPING && p->chan == chan){
801034d2:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
801034d6:	75 ec                	jne    801034c4 <wakeup1+0x110>
801034d8:	39 7b 20             	cmp    %edi,0x20(%ebx)
801034db:	75 e7                	jne    801034c4 <wakeup1+0x110>
      p->state = RUNNABLE;
801034dd:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
      if (p->priority == 3) {
801034e4:	8b b3 9c 00 00 00    	mov    0x9c(%ebx),%esi
801034ea:	83 fe 03             	cmp    $0x3,%esi
801034ed:	0f 84 d3 fe ff ff    	je     801033c6 <wakeup1+0x12>
      } else if (p->priority == 2) {
801034f3:	83 fe 02             	cmp    $0x2,%esi
801034f6:	0f 84 18 ff ff ff    	je     80103414 <wakeup1+0x60>
      } else if (p->priority == 1) {
801034fc:	83 fe 01             	cmp    $0x1,%esi
801034ff:	0f 84 5a ff ff ff    	je     8010345f <wakeup1+0xab>
      } else if (p->priority == 0) {
80103505:	85 f6                	test   %esi,%esi
80103507:	75 bb                	jne    801034c4 <wakeup1+0x110>
        delete(q0, p->pid);
80103509:	ff 73 10             	pushl  0x10(%ebx)
8010350c:	68 c0 a8 10 80       	push   $0x8010a8c0
80103511:	e8 54 fe ff ff       	call   8010336a <delete>
        for(int i = 0; i < NPROC; i++){
80103516:	83 c4 08             	add    $0x8,%esp
80103519:	83 fe 3f             	cmp    $0x3f,%esi
8010351c:	7f 93                	jg     801034b1 <wakeup1+0xfd>
          if(q0[i] == 0){
8010351e:	83 3c b5 c0 a8 10 80 	cmpl   $0x0,-0x7fef5740(,%esi,4)
80103525:	00 
80103526:	74 82                	je     801034aa <wakeup1+0xf6>
        for(int i = 0; i < NPROC; i++){
80103528:	83 c6 01             	add    $0x1,%esi
8010352b:	eb ec                	jmp    80103519 <wakeup1+0x165>
      }
    }
  }
}
8010352d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103530:	5b                   	pop    %ebx
80103531:	5e                   	pop    %esi
80103532:	5f                   	pop    %edi
80103533:	5d                   	pop    %ebp
80103534:	c3                   	ret    

80103535 <scheduler>:
{
80103535:	55                   	push   %ebp
80103536:	89 e5                	mov    %esp,%ebp
80103538:	56                   	push   %esi
80103539:	53                   	push   %ebx
  struct cpu *c = mycpu();
8010353a:	e8 18 fc ff ff       	call   80103157 <mycpu>
8010353f:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103541:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103548:	00 00 00 
8010354b:	e9 0c 03 00 00       	jmp    8010385c <scheduler+0x327>
            if(p->ticksUsed[3] < 8) {
80103550:	83 bb ac 00 00 00 07 	cmpl   $0x7,0xac(%ebx)
80103557:	7e 3a                	jle    80103593 <scheduler+0x5e>
      for(int k = 0; k < NPROC; k++) {
80103559:	83 c0 01             	add    $0x1,%eax
8010355c:	83 f8 3f             	cmp    $0x3f,%eax
8010355f:	7f 1b                	jg     8010357c <scheduler+0x47>
        if (q3[k] != 0) {
80103561:	8b 1c 85 c0 a5 10 80 	mov    -0x7fef5a40(,%eax,4),%ebx
80103568:	85 db                	test   %ebx,%ebx
8010356a:	74 ed                	je     80103559 <scheduler+0x24>
          if(p->state == RUNNABLE) {
8010356c:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103570:	74 de                	je     80103550 <scheduler+0x1b>
          } else if (q3[k+1] != 0){
80103572:	83 3c 85 c4 a5 10 80 	cmpl   $0x0,-0x7fef5a3c(,%eax,4)
80103579:	00 
8010357a:	75 dd                	jne    80103559 <scheduler+0x24>
    if (q2[0] != 0) {
8010357c:	83 3d c0 a6 10 80 00 	cmpl   $0x0,0x8010a6c0
80103583:	0f 84 e3 00 00 00    	je     8010366c <scheduler+0x137>
      for(int k = 0; k < NPROC; k++) {
80103589:	b8 00 00 00 00       	mov    $0x0,%eax
8010358e:	e9 b9 00 00 00       	jmp    8010364c <scheduler+0x117>
              c->proc = p;
80103593:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
              switchuvm(p);
80103599:	83 ec 0c             	sub    $0xc,%esp
8010359c:	53                   	push   %ebx
8010359d:	e8 ad 32 00 00       	call   8010684f <switchuvm>
              p->state = RUNNING;
801035a2:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
              swtch(&(c->scheduler), p->context);
801035a9:	83 c4 08             	add    $0x8,%esp
801035ac:	ff 73 1c             	pushl  0x1c(%ebx)
801035af:	8d 46 04             	lea    0x4(%esi),%eax
801035b2:	50                   	push   %eax
801035b3:	e8 f5 11 00 00       	call   801047ad <swtch>
              switchkvm();
801035b8:	e8 80 32 00 00       	call   8010683d <switchkvm>
              p->ticksUsed[3]++;
801035bd:	8b 83 ac 00 00 00    	mov    0xac(%ebx),%eax
801035c3:	83 c0 01             	add    $0x1,%eax
801035c6:	89 83 ac 00 00 00    	mov    %eax,0xac(%ebx)
              p->ticks[3]++;
801035cc:	8b 8b 98 00 00 00    	mov    0x98(%ebx),%ecx
801035d2:	8d 51 01             	lea    0x1(%ecx),%edx
801035d5:	89 93 98 00 00 00    	mov    %edx,0x98(%ebx)
              if(p->ticksUsed[3] == 8) {
801035db:	83 c4 10             	add    $0x10,%esp
801035de:	83 f8 08             	cmp    $0x8,%eax
801035e1:	74 0f                	je     801035f2 <scheduler+0xbd>
                c->proc = 0;
801035e3:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035ea:	00 00 00 
                goto start;
801035ed:	e9 7b 02 00 00       	jmp    8010386d <scheduler+0x338>
                delete(q3, p->pid);
801035f2:	83 ec 08             	sub    $0x8,%esp
801035f5:	ff 73 10             	pushl  0x10(%ebx)
801035f8:	68 c0 a5 10 80       	push   $0x8010a5c0
801035fd:	e8 68 fd ff ff       	call   8010336a <delete>
                p->ticksUsed[3] = 0;
80103602:	c7 83 ac 00 00 00 00 	movl   $0x0,0xac(%ebx)
80103609:	00 00 00 
                for(int i = 0; i < NPROC; i++){
8010360c:	83 c4 10             	add    $0x10,%esp
8010360f:	b8 00 00 00 00       	mov    $0x0,%eax
80103614:	83 f8 3f             	cmp    $0x3f,%eax
80103617:	7f 16                	jg     8010362f <scheduler+0xfa>
                  if(q3[i] == 0){
80103619:	83 3c 85 c0 a5 10 80 	cmpl   $0x0,-0x7fef5a40(,%eax,4)
80103620:	00 
80103621:	74 05                	je     80103628 <scheduler+0xf3>
                for(int i = 0; i < NPROC; i++){
80103623:	83 c0 01             	add    $0x1,%eax
80103626:	eb ec                	jmp    80103614 <scheduler+0xdf>
                    q3[i] = p;
80103628:	89 1c 85 c0 a5 10 80 	mov    %ebx,-0x7fef5a40(,%eax,4)
                p->qtail[3]++;
8010362f:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80103635:	83 c0 01             	add    $0x1,%eax
80103638:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
8010363e:	eb a3                	jmp    801035e3 <scheduler+0xae>
            if(p->ticksUsed[2] < 12) {
80103640:	83 bb a8 00 00 00 0b 	cmpl   $0xb,0xa8(%ebx)
80103647:	7e 3a                	jle    80103683 <scheduler+0x14e>
      for(int k = 0; k < NPROC; k++) {
80103649:	83 c0 01             	add    $0x1,%eax
8010364c:	83 f8 3f             	cmp    $0x3f,%eax
8010364f:	7f 1b                	jg     8010366c <scheduler+0x137>
        if (q2[k] != 0) {
80103651:	8b 1c 85 c0 a6 10 80 	mov    -0x7fef5940(,%eax,4),%ebx
80103658:	85 db                	test   %ebx,%ebx
8010365a:	74 ed                	je     80103649 <scheduler+0x114>
          if(p->state == RUNNABLE) {
8010365c:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103660:	74 de                	je     80103640 <scheduler+0x10b>
          } else if (q2[k+1] != 0){
80103662:	83 3c 85 c4 a6 10 80 	cmpl   $0x0,-0x7fef593c(,%eax,4)
80103669:	00 
8010366a:	75 dd                	jne    80103649 <scheduler+0x114>
    if (q1[0] != 0) {
8010366c:	83 3d c0 a7 10 80 00 	cmpl   $0x0,0x8010a7c0
80103673:	0f 84 e3 00 00 00    	je     8010375c <scheduler+0x227>
      for(int k = 0; k < NPROC; k++) {
80103679:	b8 00 00 00 00       	mov    $0x0,%eax
8010367e:	e9 b9 00 00 00       	jmp    8010373c <scheduler+0x207>
              c->proc = p;
80103683:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
              switchuvm(p);
80103689:	83 ec 0c             	sub    $0xc,%esp
8010368c:	53                   	push   %ebx
8010368d:	e8 bd 31 00 00       	call   8010684f <switchuvm>
              p->state = RUNNING;
80103692:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
              swtch(&(c->scheduler), p->context);
80103699:	83 c4 08             	add    $0x8,%esp
8010369c:	ff 73 1c             	pushl  0x1c(%ebx)
8010369f:	8d 46 04             	lea    0x4(%esi),%eax
801036a2:	50                   	push   %eax
801036a3:	e8 05 11 00 00       	call   801047ad <swtch>
              switchkvm();
801036a8:	e8 90 31 00 00       	call   8010683d <switchkvm>
              p->ticksUsed[2]++;
801036ad:	8b 83 a8 00 00 00    	mov    0xa8(%ebx),%eax
801036b3:	83 c0 01             	add    $0x1,%eax
801036b6:	89 83 a8 00 00 00    	mov    %eax,0xa8(%ebx)
              p->ticks[2]++;
801036bc:	8b 8b 94 00 00 00    	mov    0x94(%ebx),%ecx
801036c2:	8d 51 01             	lea    0x1(%ecx),%edx
801036c5:	89 93 94 00 00 00    	mov    %edx,0x94(%ebx)
              if(p->ticksUsed[2] == 12) {
801036cb:	83 c4 10             	add    $0x10,%esp
801036ce:	83 f8 0c             	cmp    $0xc,%eax
801036d1:	74 0f                	je     801036e2 <scheduler+0x1ad>
              c->proc = 0;
801036d3:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801036da:	00 00 00 
              goto start;
801036dd:	e9 8b 01 00 00       	jmp    8010386d <scheduler+0x338>
                delete(q2, p->pid);
801036e2:	83 ec 08             	sub    $0x8,%esp
801036e5:	ff 73 10             	pushl  0x10(%ebx)
801036e8:	68 c0 a6 10 80       	push   $0x8010a6c0
801036ed:	e8 78 fc ff ff       	call   8010336a <delete>
                p->ticksUsed[2] = 0;
801036f2:	c7 83 a8 00 00 00 00 	movl   $0x0,0xa8(%ebx)
801036f9:	00 00 00 
                for(int i = 0; i < NPROC; i++){
801036fc:	83 c4 10             	add    $0x10,%esp
801036ff:	b8 00 00 00 00       	mov    $0x0,%eax
80103704:	83 f8 3f             	cmp    $0x3f,%eax
80103707:	7f 16                	jg     8010371f <scheduler+0x1ea>
                  if(q2[i] == 0){
80103709:	83 3c 85 c0 a6 10 80 	cmpl   $0x0,-0x7fef5940(,%eax,4)
80103710:	00 
80103711:	74 05                	je     80103718 <scheduler+0x1e3>
                for(int i = 0; i < NPROC; i++){
80103713:	83 c0 01             	add    $0x1,%eax
80103716:	eb ec                	jmp    80103704 <scheduler+0x1cf>
                    q2[i] = p;
80103718:	89 1c 85 c0 a6 10 80 	mov    %ebx,-0x7fef5940(,%eax,4)
                p->qtail[2]++;
8010371f:	8b 83 84 00 00 00    	mov    0x84(%ebx),%eax
80103725:	83 c0 01             	add    $0x1,%eax
80103728:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
8010372e:	eb a3                	jmp    801036d3 <scheduler+0x19e>
            if(p->ticksUsed[1] < 16) {
80103730:	83 bb a4 00 00 00 0f 	cmpl   $0xf,0xa4(%ebx)
80103737:	7e 3a                	jle    80103773 <scheduler+0x23e>
      for(int k = 0; k < NPROC; k++) {
80103739:	83 c0 01             	add    $0x1,%eax
8010373c:	83 f8 3f             	cmp    $0x3f,%eax
8010373f:	7f 1b                	jg     8010375c <scheduler+0x227>
        if (q1[k] != 0) {
80103741:	8b 1c 85 c0 a7 10 80 	mov    -0x7fef5840(,%eax,4),%ebx
80103748:	85 db                	test   %ebx,%ebx
8010374a:	74 ed                	je     80103739 <scheduler+0x204>
          if(p->state == RUNNABLE) {
8010374c:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103750:	74 de                	je     80103730 <scheduler+0x1fb>
          } else if (q1[k+1] != 0){
80103752:	83 3c 85 c4 a7 10 80 	cmpl   $0x0,-0x7fef583c(,%eax,4)
80103759:	00 
8010375a:	75 dd                	jne    80103739 <scheduler+0x204>
    if (q0[0] != 0) {
8010375c:	83 3d c0 a8 10 80 00 	cmpl   $0x0,0x8010a8c0
80103763:	0f 84 e3 00 00 00    	je     8010384c <scheduler+0x317>
      for(int k = 0; k < NPROC; k++) {
80103769:	b8 00 00 00 00       	mov    $0x0,%eax
8010376e:	e9 b9 00 00 00       	jmp    8010382c <scheduler+0x2f7>
              c->proc = p;
80103773:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
              switchuvm(p);
80103779:	83 ec 0c             	sub    $0xc,%esp
8010377c:	53                   	push   %ebx
8010377d:	e8 cd 30 00 00       	call   8010684f <switchuvm>
              p->state = RUNNING;
80103782:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
              swtch(&(c->scheduler), p->context);
80103789:	83 c4 08             	add    $0x8,%esp
8010378c:	ff 73 1c             	pushl  0x1c(%ebx)
8010378f:	8d 46 04             	lea    0x4(%esi),%eax
80103792:	50                   	push   %eax
80103793:	e8 15 10 00 00       	call   801047ad <swtch>
              switchkvm();
80103798:	e8 a0 30 00 00       	call   8010683d <switchkvm>
              p->ticksUsed[1]++;
8010379d:	8b 83 a4 00 00 00    	mov    0xa4(%ebx),%eax
801037a3:	83 c0 01             	add    $0x1,%eax
801037a6:	89 83 a4 00 00 00    	mov    %eax,0xa4(%ebx)
              p->ticks[1]++;
801037ac:	8b 8b 90 00 00 00    	mov    0x90(%ebx),%ecx
801037b2:	8d 51 01             	lea    0x1(%ecx),%edx
801037b5:	89 93 90 00 00 00    	mov    %edx,0x90(%ebx)
              if(p->ticksUsed[1] == 16) {
801037bb:	83 c4 10             	add    $0x10,%esp
801037be:	83 f8 10             	cmp    $0x10,%eax
801037c1:	74 0f                	je     801037d2 <scheduler+0x29d>
              c->proc = 0;
801037c3:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801037ca:	00 00 00 
              goto start;
801037cd:	e9 9b 00 00 00       	jmp    8010386d <scheduler+0x338>
                delete(q1, p->pid);
801037d2:	83 ec 08             	sub    $0x8,%esp
801037d5:	ff 73 10             	pushl  0x10(%ebx)
801037d8:	68 c0 a7 10 80       	push   $0x8010a7c0
801037dd:	e8 88 fb ff ff       	call   8010336a <delete>
                p->ticksUsed[1] = 0;
801037e2:	c7 83 a4 00 00 00 00 	movl   $0x0,0xa4(%ebx)
801037e9:	00 00 00 
                for(int i = 0; i < NPROC; i++){
801037ec:	83 c4 10             	add    $0x10,%esp
801037ef:	b8 00 00 00 00       	mov    $0x0,%eax
801037f4:	eb 03                	jmp    801037f9 <scheduler+0x2c4>
801037f6:	83 c0 01             	add    $0x1,%eax
801037f9:	83 f8 3f             	cmp    $0x3f,%eax
801037fc:	7f 11                	jg     8010380f <scheduler+0x2da>
                  if(q1[i] == 0){
801037fe:	83 3c 85 c0 a7 10 80 	cmpl   $0x0,-0x7fef5840(,%eax,4)
80103805:	00 
80103806:	75 ee                	jne    801037f6 <scheduler+0x2c1>
                    q1[i] = p;
80103808:	89 1c 85 c0 a7 10 80 	mov    %ebx,-0x7fef5840(,%eax,4)
                p->qtail[1]++;
8010380f:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
80103815:	83 c0 01             	add    $0x1,%eax
80103818:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
8010381e:	eb a3                	jmp    801037c3 <scheduler+0x28e>
            if(p->ticksUsed[0] < 20) {
80103820:	83 bb a0 00 00 00 13 	cmpl   $0x13,0xa0(%ebx)
80103827:	7e 5b                	jle    80103884 <scheduler+0x34f>
      for(int k = 0; k < NPROC; k++) {
80103829:	83 c0 01             	add    $0x1,%eax
8010382c:	83 f8 3f             	cmp    $0x3f,%eax
8010382f:	7f 1b                	jg     8010384c <scheduler+0x317>
        if (q0[k] != 0) {
80103831:	8b 1c 85 c0 a8 10 80 	mov    -0x7fef5740(,%eax,4),%ebx
80103838:	85 db                	test   %ebx,%ebx
8010383a:	74 ed                	je     80103829 <scheduler+0x2f4>
          if(p->state == RUNNABLE) {
8010383c:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103840:	74 de                	je     80103820 <scheduler+0x2eb>
          } else if (q0[k+1] != 0){
80103842:	83 3c 85 c4 a8 10 80 	cmpl   $0x0,-0x7fef573c(,%eax,4)
80103849:	00 
8010384a:	75 dd                	jne    80103829 <scheduler+0x2f4>
    release(&ptable.lock);
8010384c:	83 ec 0c             	sub    $0xc,%esp
8010384f:	68 40 31 11 80       	push   $0x80113140
80103854:	e8 53 0d 00 00       	call   801045ac <release>
    sti();
80103859:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
8010385c:	fb                   	sti    
    acquire(&ptable.lock);
8010385d:	83 ec 0c             	sub    $0xc,%esp
80103860:	68 40 31 11 80       	push   $0x80113140
80103865:	e8 dd 0c 00 00       	call   80104547 <acquire>
8010386a:	83 c4 10             	add    $0x10,%esp
    if (q3[0] != 0) {
8010386d:	83 3d c0 a5 10 80 00 	cmpl   $0x0,0x8010a5c0
80103874:	0f 84 02 fd ff ff    	je     8010357c <scheduler+0x47>
      for(int k = 0; k < NPROC; k++) {
8010387a:	b8 00 00 00 00       	mov    $0x0,%eax
8010387f:	e9 d8 fc ff ff       	jmp    8010355c <scheduler+0x27>
              c->proc = p;
80103884:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
              switchuvm(p);
8010388a:	83 ec 0c             	sub    $0xc,%esp
8010388d:	53                   	push   %ebx
8010388e:	e8 bc 2f 00 00       	call   8010684f <switchuvm>
              p->state = RUNNING;
80103893:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
              swtch(&(c->scheduler), p->context);
8010389a:	83 c4 08             	add    $0x8,%esp
8010389d:	ff 73 1c             	pushl  0x1c(%ebx)
801038a0:	8d 46 04             	lea    0x4(%esi),%eax
801038a3:	50                   	push   %eax
801038a4:	e8 04 0f 00 00       	call   801047ad <swtch>
              switchkvm();
801038a9:	e8 8f 2f 00 00       	call   8010683d <switchkvm>
              p->ticksUsed[0]++;
801038ae:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
801038b4:	83 c0 01             	add    $0x1,%eax
801038b7:	89 83 a0 00 00 00    	mov    %eax,0xa0(%ebx)
              p->ticks[0]++;
801038bd:	8b 8b 8c 00 00 00    	mov    0x8c(%ebx),%ecx
801038c3:	8d 51 01             	lea    0x1(%ecx),%edx
801038c6:	89 93 8c 00 00 00    	mov    %edx,0x8c(%ebx)
              if(p->ticksUsed[0] == 20) {
801038cc:	83 c4 10             	add    $0x10,%esp
801038cf:	83 f8 14             	cmp    $0x14,%eax
801038d2:	74 0c                	je     801038e0 <scheduler+0x3ab>
                c->proc = 0;
801038d4:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801038db:	00 00 00 
                goto start;
801038de:	eb 8d                	jmp    8010386d <scheduler+0x338>
                delete(q0, p->pid);
801038e0:	83 ec 08             	sub    $0x8,%esp
801038e3:	ff 73 10             	pushl  0x10(%ebx)
801038e6:	68 c0 a8 10 80       	push   $0x8010a8c0
801038eb:	e8 7a fa ff ff       	call   8010336a <delete>
                p->ticksUsed[0] = 0;
801038f0:	c7 83 a0 00 00 00 00 	movl   $0x0,0xa0(%ebx)
801038f7:	00 00 00 
                for(int i = 0; i < NPROC; i++){
801038fa:	83 c4 10             	add    $0x10,%esp
801038fd:	b8 00 00 00 00       	mov    $0x0,%eax
80103902:	83 f8 3f             	cmp    $0x3f,%eax
80103905:	7f 16                	jg     8010391d <scheduler+0x3e8>
                  if(q0[i] == 0){
80103907:	83 3c 85 c0 a8 10 80 	cmpl   $0x0,-0x7fef5740(,%eax,4)
8010390e:	00 
8010390f:	74 05                	je     80103916 <scheduler+0x3e1>
                for(int i = 0; i < NPROC; i++){
80103911:	83 c0 01             	add    $0x1,%eax
80103914:	eb ec                	jmp    80103902 <scheduler+0x3cd>
                    q0[i] = p;
80103916:	89 1c 85 c0 a8 10 80 	mov    %ebx,-0x7fef5740(,%eax,4)
                p->qtail[0]++;
8010391d:	8b 43 7c             	mov    0x7c(%ebx),%eax
80103920:	83 c0 01             	add    $0x1,%eax
80103923:	89 43 7c             	mov    %eax,0x7c(%ebx)
80103926:	eb ac                	jmp    801038d4 <scheduler+0x39f>

80103928 <sched>:
{
80103928:	55                   	push   %ebp
80103929:	89 e5                	mov    %esp,%ebp
8010392b:	56                   	push   %esi
8010392c:	53                   	push   %ebx
  struct proc *p = myproc();
8010392d:	e8 9c f8 ff ff       	call   801031ce <myproc>
80103932:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103934:	83 ec 0c             	sub    $0xc,%esp
80103937:	68 40 31 11 80       	push   $0x80113140
8010393c:	e8 c6 0b 00 00       	call   80104507 <holding>
80103941:	83 c4 10             	add    $0x10,%esp
80103944:	85 c0                	test   %eax,%eax
80103946:	74 4f                	je     80103997 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103948:	e8 0a f8 ff ff       	call   80103157 <mycpu>
8010394d:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103954:	75 4e                	jne    801039a4 <sched+0x7c>
  if(p->state == RUNNING)
80103956:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010395a:	74 55                	je     801039b1 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010395c:	9c                   	pushf  
8010395d:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010395e:	f6 c4 02             	test   $0x2,%ah
80103961:	75 5b                	jne    801039be <sched+0x96>
  intena = mycpu()->intena;
80103963:	e8 ef f7 ff ff       	call   80103157 <mycpu>
80103968:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010396e:	e8 e4 f7 ff ff       	call   80103157 <mycpu>
80103973:	83 ec 08             	sub    $0x8,%esp
80103976:	ff 70 04             	pushl  0x4(%eax)
80103979:	83 c3 1c             	add    $0x1c,%ebx
8010397c:	53                   	push   %ebx
8010397d:	e8 2b 0e 00 00       	call   801047ad <swtch>
  mycpu()->intena = intena;
80103982:	e8 d0 f7 ff ff       	call   80103157 <mycpu>
80103987:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010398d:	83 c4 10             	add    $0x10,%esp
80103990:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103993:	5b                   	pop    %ebx
80103994:	5e                   	pop    %esi
80103995:	5d                   	pop    %ebp
80103996:	c3                   	ret    
    panic("sched ptable.lock");
80103997:	83 ec 0c             	sub    $0xc,%esp
8010399a:	68 50 74 10 80       	push   $0x80107450
8010399f:	e8 a4 c9 ff ff       	call   80100348 <panic>
    panic("sched locks");
801039a4:	83 ec 0c             	sub    $0xc,%esp
801039a7:	68 62 74 10 80       	push   $0x80107462
801039ac:	e8 97 c9 ff ff       	call   80100348 <panic>
    panic("sched running");
801039b1:	83 ec 0c             	sub    $0xc,%esp
801039b4:	68 6e 74 10 80       	push   $0x8010746e
801039b9:	e8 8a c9 ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801039be:	83 ec 0c             	sub    $0xc,%esp
801039c1:	68 7c 74 10 80       	push   $0x8010747c
801039c6:	e8 7d c9 ff ff       	call   80100348 <panic>

801039cb <exit>:
{
801039cb:	55                   	push   %ebp
801039cc:	89 e5                	mov    %esp,%ebp
801039ce:	56                   	push   %esi
801039cf:	53                   	push   %ebx
  struct proc *curproc = myproc();
801039d0:	e8 f9 f7 ff ff       	call   801031ce <myproc>
  if(curproc == initproc)
801039d5:	39 05 c0 a9 10 80    	cmp    %eax,0x8010a9c0
801039db:	74 09                	je     801039e6 <exit+0x1b>
801039dd:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801039df:	bb 00 00 00 00       	mov    $0x0,%ebx
801039e4:	eb 10                	jmp    801039f6 <exit+0x2b>
    panic("init exiting");
801039e6:	83 ec 0c             	sub    $0xc,%esp
801039e9:	68 90 74 10 80       	push   $0x80107490
801039ee:	e8 55 c9 ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
801039f3:	83 c3 01             	add    $0x1,%ebx
801039f6:	83 fb 0f             	cmp    $0xf,%ebx
801039f9:	7f 1e                	jg     80103a19 <exit+0x4e>
    if(curproc->ofile[fd]){
801039fb:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801039ff:	85 c0                	test   %eax,%eax
80103a01:	74 f0                	je     801039f3 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103a03:	83 ec 0c             	sub    $0xc,%esp
80103a06:	50                   	push   %eax
80103a07:	e8 c7 d2 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103a0c:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103a13:	00 
80103a14:	83 c4 10             	add    $0x10,%esp
80103a17:	eb da                	jmp    801039f3 <exit+0x28>
  begin_op();
80103a19:	e8 90 ed ff ff       	call   801027ae <begin_op>
  iput(curproc->cwd);
80103a1e:	83 ec 0c             	sub    $0xc,%esp
80103a21:	ff 76 68             	pushl  0x68(%esi)
80103a24:	e8 5f dc ff ff       	call   80101688 <iput>
  end_op();
80103a29:	e8 fa ed ff ff       	call   80102828 <end_op>
  curproc->cwd = 0;
80103a2e:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103a35:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103a3c:	e8 06 0b 00 00       	call   80104547 <acquire>
  wakeup1(curproc->parent);
80103a41:	8b 46 14             	mov    0x14(%esi),%eax
80103a44:	e8 6b f9 ff ff       	call   801033b4 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a49:	83 c4 10             	add    $0x10,%esp
80103a4c:	bb 74 31 11 80       	mov    $0x80113174,%ebx
80103a51:	eb 06                	jmp    80103a59 <exit+0x8e>
80103a53:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103a59:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103a5f:	73 1a                	jae    80103a7b <exit+0xb0>
    if(p->parent == curproc){
80103a61:	39 73 14             	cmp    %esi,0x14(%ebx)
80103a64:	75 ed                	jne    80103a53 <exit+0x88>
      p->parent = initproc;
80103a66:	a1 c0 a9 10 80       	mov    0x8010a9c0,%eax
80103a6b:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103a6e:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103a72:	75 df                	jne    80103a53 <exit+0x88>
        wakeup1(initproc);
80103a74:	e8 3b f9 ff ff       	call   801033b4 <wakeup1>
80103a79:	eb d8                	jmp    80103a53 <exit+0x88>
  curproc->state = ZOMBIE;
80103a7b:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  if (curproc->priority == 3) {
80103a82:	8b 86 9c 00 00 00    	mov    0x9c(%esi),%eax
80103a88:	83 f8 03             	cmp    $0x3,%eax
80103a8b:	74 20                	je     80103aad <exit+0xe2>
  } else if (curproc->priority == 2) {
80103a8d:	83 f8 02             	cmp    $0x2,%eax
80103a90:	74 3a                	je     80103acc <exit+0x101>
  } else if (curproc->priority == 1) {
80103a92:	83 f8 01             	cmp    $0x1,%eax
80103a95:	74 54                	je     80103aeb <exit+0x120>
  } else if (curproc->priority == 0) {
80103a97:	85 c0                	test   %eax,%eax
80103a99:	74 6f                	je     80103b0a <exit+0x13f>
  sched();
80103a9b:	e8 88 fe ff ff       	call   80103928 <sched>
  panic("zombie exit");
80103aa0:	83 ec 0c             	sub    $0xc,%esp
80103aa3:	68 9d 74 10 80       	push   $0x8010749d
80103aa8:	e8 9b c8 ff ff       	call   80100348 <panic>
    delete(q3, curproc->pid);
80103aad:	83 ec 08             	sub    $0x8,%esp
80103ab0:	ff 76 10             	pushl  0x10(%esi)
80103ab3:	68 c0 a5 10 80       	push   $0x8010a5c0
80103ab8:	e8 ad f8 ff ff       	call   8010336a <delete>
    curproc->ticksUsed[3] = 0;
80103abd:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103ac4:	00 00 00 
80103ac7:	83 c4 10             	add    $0x10,%esp
80103aca:	eb cf                	jmp    80103a9b <exit+0xd0>
    delete(q2, curproc->pid);
80103acc:	83 ec 08             	sub    $0x8,%esp
80103acf:	ff 76 10             	pushl  0x10(%esi)
80103ad2:	68 c0 a6 10 80       	push   $0x8010a6c0
80103ad7:	e8 8e f8 ff ff       	call   8010336a <delete>
    curproc->ticksUsed[2] = 0;
80103adc:	c7 86 a8 00 00 00 00 	movl   $0x0,0xa8(%esi)
80103ae3:	00 00 00 
80103ae6:	83 c4 10             	add    $0x10,%esp
80103ae9:	eb b0                	jmp    80103a9b <exit+0xd0>
    delete(q1, curproc->pid);
80103aeb:	83 ec 08             	sub    $0x8,%esp
80103aee:	ff 76 10             	pushl  0x10(%esi)
80103af1:	68 c0 a7 10 80       	push   $0x8010a7c0
80103af6:	e8 6f f8 ff ff       	call   8010336a <delete>
    curproc->ticksUsed[1] = 0;
80103afb:	c7 86 a4 00 00 00 00 	movl   $0x0,0xa4(%esi)
80103b02:	00 00 00 
80103b05:	83 c4 10             	add    $0x10,%esp
80103b08:	eb 91                	jmp    80103a9b <exit+0xd0>
    delete(q0, curproc->pid);
80103b0a:	83 ec 08             	sub    $0x8,%esp
80103b0d:	ff 76 10             	pushl  0x10(%esi)
80103b10:	68 c0 a8 10 80       	push   $0x8010a8c0
80103b15:	e8 50 f8 ff ff       	call   8010336a <delete>
    curproc->ticksUsed[0] = 0;
80103b1a:	c7 86 a0 00 00 00 00 	movl   $0x0,0xa0(%esi)
80103b21:	00 00 00 
80103b24:	83 c4 10             	add    $0x10,%esp
80103b27:	e9 6f ff ff ff       	jmp    80103a9b <exit+0xd0>

80103b2c <yield>:
{
80103b2c:	55                   	push   %ebp
80103b2d:	89 e5                	mov    %esp,%ebp
80103b2f:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103b32:	68 40 31 11 80       	push   $0x80113140
80103b37:	e8 0b 0a 00 00       	call   80104547 <acquire>
  myproc()->state = RUNNABLE;
80103b3c:	e8 8d f6 ff ff       	call   801031ce <myproc>
80103b41:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103b48:	e8 db fd ff ff       	call   80103928 <sched>
  release(&ptable.lock);
80103b4d:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103b54:	e8 53 0a 00 00       	call   801045ac <release>
}
80103b59:	83 c4 10             	add    $0x10,%esp
80103b5c:	c9                   	leave  
80103b5d:	c3                   	ret    

80103b5e <sleep>:
{
80103b5e:	55                   	push   %ebp
80103b5f:	89 e5                	mov    %esp,%ebp
80103b61:	56                   	push   %esi
80103b62:	53                   	push   %ebx
80103b63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103b66:	e8 63 f6 ff ff       	call   801031ce <myproc>
  if(p == 0)
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	74 66                	je     80103bd5 <sleep+0x77>
80103b6f:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103b71:	85 db                	test   %ebx,%ebx
80103b73:	74 6d                	je     80103be2 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103b75:	81 fb 40 31 11 80    	cmp    $0x80113140,%ebx
80103b7b:	74 18                	je     80103b95 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103b7d:	83 ec 0c             	sub    $0xc,%esp
80103b80:	68 40 31 11 80       	push   $0x80113140
80103b85:	e8 bd 09 00 00       	call   80104547 <acquire>
    release(lk);
80103b8a:	89 1c 24             	mov    %ebx,(%esp)
80103b8d:	e8 1a 0a 00 00       	call   801045ac <release>
80103b92:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103b95:	8b 45 08             	mov    0x8(%ebp),%eax
80103b98:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103b9b:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103ba2:	e8 81 fd ff ff       	call   80103928 <sched>
  p->chan = 0;
80103ba7:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103bae:	81 fb 40 31 11 80    	cmp    $0x80113140,%ebx
80103bb4:	74 18                	je     80103bce <sleep+0x70>
    release(&ptable.lock);
80103bb6:	83 ec 0c             	sub    $0xc,%esp
80103bb9:	68 40 31 11 80       	push   $0x80113140
80103bbe:	e8 e9 09 00 00       	call   801045ac <release>
    acquire(lk);
80103bc3:	89 1c 24             	mov    %ebx,(%esp)
80103bc6:	e8 7c 09 00 00       	call   80104547 <acquire>
80103bcb:	83 c4 10             	add    $0x10,%esp
}
80103bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bd1:	5b                   	pop    %ebx
80103bd2:	5e                   	pop    %esi
80103bd3:	5d                   	pop    %ebp
80103bd4:	c3                   	ret    
    panic("sleep");
80103bd5:	83 ec 0c             	sub    $0xc,%esp
80103bd8:	68 a9 74 10 80       	push   $0x801074a9
80103bdd:	e8 66 c7 ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103be2:	83 ec 0c             	sub    $0xc,%esp
80103be5:	68 af 74 10 80       	push   $0x801074af
80103bea:	e8 59 c7 ff ff       	call   80100348 <panic>

80103bef <wait>:
{
80103bef:	55                   	push   %ebp
80103bf0:	89 e5                	mov    %esp,%ebp
80103bf2:	56                   	push   %esi
80103bf3:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103bf4:	e8 d5 f5 ff ff       	call   801031ce <myproc>
80103bf9:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103bfb:	83 ec 0c             	sub    $0xc,%esp
80103bfe:	68 40 31 11 80       	push   $0x80113140
80103c03:	e8 3f 09 00 00       	call   80104547 <acquire>
80103c08:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103c0b:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c10:	bb 74 31 11 80       	mov    $0x80113174,%ebx
80103c15:	eb 5e                	jmp    80103c75 <wait+0x86>
        pid = p->pid;
80103c17:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103c1a:	83 ec 0c             	sub    $0xc,%esp
80103c1d:	ff 73 08             	pushl  0x8(%ebx)
80103c20:	e8 7f e3 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
80103c25:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103c2c:	83 c4 04             	add    $0x4,%esp
80103c2f:	ff 73 04             	pushl  0x4(%ebx)
80103c32:	e8 b5 2f 00 00       	call   80106bec <freevm>
        p->pid = 0;
80103c37:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103c3e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103c45:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103c49:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103c50:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103c57:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103c5e:	e8 49 09 00 00       	call   801045ac <release>
        return pid;
80103c63:	83 c4 10             	add    $0x10,%esp
}
80103c66:	89 f0                	mov    %esi,%eax
80103c68:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c6b:	5b                   	pop    %ebx
80103c6c:	5e                   	pop    %esi
80103c6d:	5d                   	pop    %ebp
80103c6e:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c6f:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103c75:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103c7b:	73 12                	jae    80103c8f <wait+0xa0>
      if(p->parent != curproc)
80103c7d:	39 73 14             	cmp    %esi,0x14(%ebx)
80103c80:	75 ed                	jne    80103c6f <wait+0x80>
      if(p->state == ZOMBIE){
80103c82:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103c86:	74 8f                	je     80103c17 <wait+0x28>
      havekids = 1;
80103c88:	b8 01 00 00 00       	mov    $0x1,%eax
80103c8d:	eb e0                	jmp    80103c6f <wait+0x80>
    if(!havekids || curproc->killed){
80103c8f:	85 c0                	test   %eax,%eax
80103c91:	74 06                	je     80103c99 <wait+0xaa>
80103c93:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103c97:	74 17                	je     80103cb0 <wait+0xc1>
      release(&ptable.lock);
80103c99:	83 ec 0c             	sub    $0xc,%esp
80103c9c:	68 40 31 11 80       	push   $0x80113140
80103ca1:	e8 06 09 00 00       	call   801045ac <release>
      return -1;
80103ca6:	83 c4 10             	add    $0x10,%esp
80103ca9:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103cae:	eb b6                	jmp    80103c66 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103cb0:	83 ec 08             	sub    $0x8,%esp
80103cb3:	68 40 31 11 80       	push   $0x80113140
80103cb8:	56                   	push   %esi
80103cb9:	e8 a0 fe ff ff       	call   80103b5e <sleep>
    havekids = 0;
80103cbe:	83 c4 10             	add    $0x10,%esp
80103cc1:	e9 45 ff ff ff       	jmp    80103c0b <wait+0x1c>

80103cc6 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103cc6:	55                   	push   %ebp
80103cc7:	89 e5                	mov    %esp,%ebp
80103cc9:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103ccc:	68 40 31 11 80       	push   $0x80113140
80103cd1:	e8 71 08 00 00       	call   80104547 <acquire>
  wakeup1(chan);
80103cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80103cd9:	e8 d6 f6 ff ff       	call   801033b4 <wakeup1>
  release(&ptable.lock);
80103cde:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103ce5:	e8 c2 08 00 00       	call   801045ac <release>
}
80103cea:	83 c4 10             	add    $0x10,%esp
80103ced:	c9                   	leave  
80103cee:	c3                   	ret    

80103cef <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103cef:	55                   	push   %ebp
80103cf0:	89 e5                	mov    %esp,%ebp
80103cf2:	53                   	push   %ebx
80103cf3:	83 ec 10             	sub    $0x10,%esp
80103cf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103cf9:	68 40 31 11 80       	push   $0x80113140
80103cfe:	e8 44 08 00 00       	call   80104547 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d03:	83 c4 10             	add    $0x10,%esp
80103d06:	b8 74 31 11 80       	mov    $0x80113174,%eax
80103d0b:	3d 74 5d 11 80       	cmp    $0x80115d74,%eax
80103d10:	73 3c                	jae    80103d4e <kill+0x5f>
    if(p->pid == pid){
80103d12:	39 58 10             	cmp    %ebx,0x10(%eax)
80103d15:	74 07                	je     80103d1e <kill+0x2f>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d17:	05 b0 00 00 00       	add    $0xb0,%eax
80103d1c:	eb ed                	jmp    80103d0b <kill+0x1c>
      p->killed = 1;
80103d1e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103d25:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103d29:	74 1a                	je     80103d45 <kill+0x56>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103d2b:	83 ec 0c             	sub    $0xc,%esp
80103d2e:	68 40 31 11 80       	push   $0x80113140
80103d33:	e8 74 08 00 00       	call   801045ac <release>
      return 0;
80103d38:	83 c4 10             	add    $0x10,%esp
80103d3b:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103d40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d43:	c9                   	leave  
80103d44:	c3                   	ret    
        p->state = RUNNABLE;
80103d45:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103d4c:	eb dd                	jmp    80103d2b <kill+0x3c>
  release(&ptable.lock);
80103d4e:	83 ec 0c             	sub    $0xc,%esp
80103d51:	68 40 31 11 80       	push   $0x80113140
80103d56:	e8 51 08 00 00       	call   801045ac <release>
  return -1;
80103d5b:	83 c4 10             	add    $0x10,%esp
80103d5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d63:	eb db                	jmp    80103d40 <kill+0x51>

80103d65 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103d65:	55                   	push   %ebp
80103d66:	89 e5                	mov    %esp,%ebp
80103d68:	56                   	push   %esi
80103d69:	53                   	push   %ebx
80103d6a:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d6d:	bb 74 31 11 80       	mov    $0x80113174,%ebx
80103d72:	eb 36                	jmp    80103daa <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103d74:	b8 c0 74 10 80       	mov    $0x801074c0,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103d79:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103d7c:	52                   	push   %edx
80103d7d:	50                   	push   %eax
80103d7e:	ff 73 10             	pushl  0x10(%ebx)
80103d81:	68 c4 74 10 80       	push   $0x801074c4
80103d86:	e8 80 c8 ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103d8b:	83 c4 10             	add    $0x10,%esp
80103d8e:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103d92:	74 3c                	je     80103dd0 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103d94:	83 ec 0c             	sub    $0xc,%esp
80103d97:	68 47 78 10 80       	push   $0x80107847
80103d9c:	e8 6a c8 ff ff       	call   8010060b <cprintf>
80103da1:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103da4:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103daa:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103db0:	73 61                	jae    80103e13 <procdump+0xae>
    if(p->state == UNUSED)
80103db2:	8b 43 0c             	mov    0xc(%ebx),%eax
80103db5:	85 c0                	test   %eax,%eax
80103db7:	74 eb                	je     80103da4 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103db9:	83 f8 05             	cmp    $0x5,%eax
80103dbc:	77 b6                	ja     80103d74 <procdump+0xf>
80103dbe:	8b 04 85 20 75 10 80 	mov    -0x7fef8ae0(,%eax,4),%eax
80103dc5:	85 c0                	test   %eax,%eax
80103dc7:	75 b0                	jne    80103d79 <procdump+0x14>
      state = "???";
80103dc9:	b8 c0 74 10 80       	mov    $0x801074c0,%eax
80103dce:	eb a9                	jmp    80103d79 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103dd0:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103dd3:	8b 40 0c             	mov    0xc(%eax),%eax
80103dd6:	83 c0 08             	add    $0x8,%eax
80103dd9:	83 ec 08             	sub    $0x8,%esp
80103ddc:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103ddf:	52                   	push   %edx
80103de0:	50                   	push   %eax
80103de1:	e8 40 06 00 00       	call   80104426 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103de6:	83 c4 10             	add    $0x10,%esp
80103de9:	be 00 00 00 00       	mov    $0x0,%esi
80103dee:	eb 14                	jmp    80103e04 <procdump+0x9f>
        cprintf(" %p", pc[i]);
80103df0:	83 ec 08             	sub    $0x8,%esp
80103df3:	50                   	push   %eax
80103df4:	68 01 6f 10 80       	push   $0x80106f01
80103df9:	e8 0d c8 ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103dfe:	83 c6 01             	add    $0x1,%esi
80103e01:	83 c4 10             	add    $0x10,%esp
80103e04:	83 fe 09             	cmp    $0x9,%esi
80103e07:	7f 8b                	jg     80103d94 <procdump+0x2f>
80103e09:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103e0d:	85 c0                	test   %eax,%eax
80103e0f:	75 df                	jne    80103df0 <procdump+0x8b>
80103e11:	eb 81                	jmp    80103d94 <procdump+0x2f>
  }
}
80103e13:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103e16:	5b                   	pop    %ebx
80103e17:	5e                   	pop    %esi
80103e18:	5d                   	pop    %ebp
80103e19:	c3                   	ret    

80103e1a <setpri>:

// Set priority system call
int setpri(int PID, int pri){
80103e1a:	55                   	push   %ebp
80103e1b:	89 e5                	mov    %esp,%ebp
80103e1d:	57                   	push   %edi
80103e1e:	56                   	push   %esi
80103e1f:	53                   	push   %ebx
80103e20:	83 ec 1c             	sub    $0x1c,%esp
80103e23:	8b 7d 08             	mov    0x8(%ebp),%edi
80103e26:	8b 75 0c             	mov    0xc(%ebp),%esi
  int out = -1;
  struct proc *p;

  if (pri < 0 || pri > 3) {
80103e29:	83 fe 03             	cmp    $0x3,%esi
80103e2c:	0f 87 65 01 00 00    	ja     80103f97 <setpri+0x17d>
    return out;
  }

  acquire(&ptable.lock);
80103e32:	83 ec 0c             	sub    $0xc,%esp
80103e35:	68 40 31 11 80       	push   $0x80113140
80103e3a:	e8 08 07 00 00       	call   80104547 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e3f:	83 c4 10             	add    $0x10,%esp
80103e42:	bb 74 31 11 80       	mov    $0x80113174,%ebx
  int out = -1;
80103e47:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103e4e:	e9 d0 00 00 00       	jmp    80103f23 <setpri+0x109>
    if(p->pid == PID){
      if (pri == 3) {
        delete(q3, p->pid);
80103e53:	83 ec 08             	sub    $0x8,%esp
80103e56:	50                   	push   %eax
80103e57:	68 c0 a5 10 80       	push   $0x8010a5c0
80103e5c:	e8 09 f5 ff ff       	call   8010336a <delete>
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
80103e61:	83 c4 10             	add    $0x10,%esp
80103e64:	b8 00 00 00 00       	mov    $0x0,%eax
80103e69:	83 f8 3f             	cmp    $0x3f,%eax
80103e6c:	0f 8f 85 00 00 00    	jg     80103ef7 <setpri+0xdd>
          if(q3[i] == 0){
80103e72:	83 3c 85 c0 a5 10 80 	cmpl   $0x0,-0x7fef5a40(,%eax,4)
80103e79:	00 
80103e7a:	74 05                	je     80103e81 <setpri+0x67>
        for(int i = 0; i < NPROC; i++){
80103e7c:	83 c0 01             	add    $0x1,%eax
80103e7f:	eb e8                	jmp    80103e69 <setpri+0x4f>
            q3[i] = p;
80103e81:	89 1c 85 c0 a5 10 80 	mov    %ebx,-0x7fef5a40(,%eax,4)
            break;
80103e88:	eb 6d                	jmp    80103ef7 <setpri+0xdd>
          }
        }
      } else if (pri == 2) {
        delete(q2, p->pid);
80103e8a:	83 ec 08             	sub    $0x8,%esp
80103e8d:	50                   	push   %eax
80103e8e:	68 c0 a6 10 80       	push   $0x8010a6c0
80103e93:	e8 d2 f4 ff ff       	call   8010336a <delete>
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
80103e98:	83 c4 10             	add    $0x10,%esp
80103e9b:	b8 00 00 00 00       	mov    $0x0,%eax
80103ea0:	83 f8 3f             	cmp    $0x3f,%eax
80103ea3:	7f 52                	jg     80103ef7 <setpri+0xdd>
          if(q2[i] == 0){
80103ea5:	83 3c 85 c0 a6 10 80 	cmpl   $0x0,-0x7fef5940(,%eax,4)
80103eac:	00 
80103ead:	74 05                	je     80103eb4 <setpri+0x9a>
        for(int i = 0; i < NPROC; i++){
80103eaf:	83 c0 01             	add    $0x1,%eax
80103eb2:	eb ec                	jmp    80103ea0 <setpri+0x86>
            q2[i] = p;
80103eb4:	89 1c 85 c0 a6 10 80 	mov    %ebx,-0x7fef5940(,%eax,4)
            break;
80103ebb:	eb 3a                	jmp    80103ef7 <setpri+0xdd>
          }
        }
      } else if (pri == 1) {
        delete(q1, p->pid);
80103ebd:	83 ec 08             	sub    $0x8,%esp
80103ec0:	50                   	push   %eax
80103ec1:	68 c0 a7 10 80       	push   $0x8010a7c0
80103ec6:	e8 9f f4 ff ff       	call   8010336a <delete>
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
80103ecb:	83 c4 10             	add    $0x10,%esp
80103ece:	b8 00 00 00 00       	mov    $0x0,%eax
80103ed3:	83 f8 3f             	cmp    $0x3f,%eax
80103ed6:	7f 1f                	jg     80103ef7 <setpri+0xdd>
          if(q1[i] == 0){
80103ed8:	83 3c 85 c0 a7 10 80 	cmpl   $0x0,-0x7fef5840(,%eax,4)
80103edf:	00 
80103ee0:	74 05                	je     80103ee7 <setpri+0xcd>
        for(int i = 0; i < NPROC; i++){
80103ee2:	83 c0 01             	add    $0x1,%eax
80103ee5:	eb ec                	jmp    80103ed3 <setpri+0xb9>
            q1[i] = p;
80103ee7:	89 1c 85 c0 a7 10 80 	mov    %ebx,-0x7fef5840(,%eax,4)
            break;
80103eee:	eb 07                	jmp    80103ef7 <setpri+0xdd>
      } else if (pri == 0) {
        delete(q0, p->pid);
        // Add to the end of the queue
        for(int i = 0; i < NPROC; i++){
          if(q0[i] == 0){
            q0[i] = p;
80103ef0:	89 1c 85 c0 a8 10 80 	mov    %ebx,-0x7fef5740(,%eax,4)
            break;
          }
        }
      }
      p->priority = pri;
80103ef7:	89 b3 9c 00 00 00    	mov    %esi,0x9c(%ebx)
      p->ticksUsed[pri] = 0;
80103efd:	c7 84 b3 a0 00 00 00 	movl   $0x0,0xa0(%ebx,%esi,4)
80103f04:	00 00 00 00 
      p->qtail[pri]++;
80103f08:	8d 56 1c             	lea    0x1c(%esi),%edx
80103f0b:	8b 44 93 0c          	mov    0xc(%ebx,%edx,4),%eax
80103f0f:	83 c0 01             	add    $0x1,%eax
80103f12:	89 44 93 0c          	mov    %eax,0xc(%ebx,%edx,4)
      // cprintf("In setpri: %d\n", p->qtail[pri]);
      out = 0;
80103f16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f1d:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103f23:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103f29:	73 51                	jae    80103f7c <setpri+0x162>
    if(p->pid == PID){
80103f2b:	8b 43 10             	mov    0x10(%ebx),%eax
80103f2e:	39 f8                	cmp    %edi,%eax
80103f30:	75 eb                	jne    80103f1d <setpri+0x103>
      if (pri == 3) {
80103f32:	83 fe 03             	cmp    $0x3,%esi
80103f35:	0f 84 18 ff ff ff    	je     80103e53 <setpri+0x39>
      } else if (pri == 2) {
80103f3b:	83 fe 02             	cmp    $0x2,%esi
80103f3e:	0f 84 46 ff ff ff    	je     80103e8a <setpri+0x70>
      } else if (pri == 1) {
80103f44:	83 fe 01             	cmp    $0x1,%esi
80103f47:	0f 84 70 ff ff ff    	je     80103ebd <setpri+0xa3>
      } else if (pri == 0) {
80103f4d:	85 f6                	test   %esi,%esi
80103f4f:	75 a6                	jne    80103ef7 <setpri+0xdd>
        delete(q0, p->pid);
80103f51:	83 ec 08             	sub    $0x8,%esp
80103f54:	50                   	push   %eax
80103f55:	68 c0 a8 10 80       	push   $0x8010a8c0
80103f5a:	e8 0b f4 ff ff       	call   8010336a <delete>
        for(int i = 0; i < NPROC; i++){
80103f5f:	83 c4 10             	add    $0x10,%esp
80103f62:	89 f0                	mov    %esi,%eax
80103f64:	83 f8 3f             	cmp    $0x3f,%eax
80103f67:	7f 8e                	jg     80103ef7 <setpri+0xdd>
          if(q0[i] == 0){
80103f69:	83 3c 85 c0 a8 10 80 	cmpl   $0x0,-0x7fef5740(,%eax,4)
80103f70:	00 
80103f71:	0f 84 79 ff ff ff    	je     80103ef0 <setpri+0xd6>
        for(int i = 0; i < NPROC; i++){
80103f77:	83 c0 01             	add    $0x1,%eax
80103f7a:	eb e8                	jmp    80103f64 <setpri+0x14a>
    }
  }
  release(&ptable.lock);
80103f7c:	83 ec 0c             	sub    $0xc,%esp
80103f7f:	68 40 31 11 80       	push   $0x80113140
80103f84:	e8 23 06 00 00       	call   801045ac <release>
  return out;
80103f89:	83 c4 10             	add    $0x10,%esp
}
80103f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f92:	5b                   	pop    %ebx
80103f93:	5e                   	pop    %esi
80103f94:	5f                   	pop    %edi
80103f95:	5d                   	pop    %ebp
80103f96:	c3                   	ret    
    return out;
80103f97:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
80103f9e:	eb ec                	jmp    80103f8c <setpri+0x172>

80103fa0 <getpri>:

// Get priority system call
int getpri(int PID){
80103fa0:	55                   	push   %ebp
80103fa1:	89 e5                	mov    %esp,%ebp
80103fa3:	8b 55 08             	mov    0x8(%ebp),%edx

  int pri = -1;
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa6:	b8 74 31 11 80       	mov    $0x80113174,%eax
80103fab:	3d 74 5d 11 80       	cmp    $0x80115d74,%eax
80103fb0:	73 14                	jae    80103fc6 <getpri+0x26>
    if(p->pid == PID){
80103fb2:	39 50 10             	cmp    %edx,0x10(%eax)
80103fb5:	74 07                	je     80103fbe <getpri+0x1e>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fb7:	05 b0 00 00 00       	add    $0xb0,%eax
80103fbc:	eb ed                	jmp    80103fab <getpri+0xb>
        pri = p->priority;
80103fbe:	8b 80 9c 00 00 00    	mov    0x9c(%eax),%eax
        break;
    }
  }
  return pri;
}
80103fc4:	5d                   	pop    %ebp
80103fc5:	c3                   	ret    
  int pri = -1;
80103fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return pri;
80103fcb:	eb f7                	jmp    80103fc4 <getpri+0x24>

80103fcd <fork2>:

// fork 2 has original fork implementation in addition
// to setting the desired priority of a process
int
fork2(int pri)
{
80103fcd:	55                   	push   %ebp
80103fce:	89 e5                	mov    %esp,%ebp
80103fd0:	57                   	push   %edi
80103fd1:	56                   	push   %esi
80103fd2:	53                   	push   %ebx
80103fd3:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103fd6:	e8 f3 f1 ff ff       	call   801031ce <myproc>
80103fdb:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  if (pri < 0 || pri > 3) {
80103fde:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
80103fe2:	0f 87 0e 02 00 00    	ja     801041f6 <fork2+0x229>
80103fe8:	89 c7                	mov    %eax,%edi
    return -1;
  }

  // Allocate process.
  if((np = allocproc()) == 0){
80103fea:	e8 47 f0 ff ff       	call   80103036 <allocproc>
80103fef:	89 c3                	mov    %eax,%ebx
80103ff1:	85 c0                	test   %eax,%eax
80103ff3:	0f 84 07 02 00 00    	je     80104200 <fork2+0x233>
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103ff9:	83 ec 08             	sub    $0x8,%esp
80103ffc:	ff 37                	pushl  (%edi)
80103ffe:	ff 77 04             	pushl  0x4(%edi)
80104001:	e8 07 2d 00 00       	call   80106d0d <copyuvm>
80104006:	89 43 04             	mov    %eax,0x4(%ebx)
80104009:	83 c4 10             	add    $0x10,%esp
8010400c:	85 c0                	test   %eax,%eax
8010400e:	74 2a                	je     8010403a <fork2+0x6d>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
80104010:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104013:	8b 02                	mov    (%edx),%eax
80104015:	89 03                	mov    %eax,(%ebx)
  np->parent = curproc;
80104017:	89 53 14             	mov    %edx,0x14(%ebx)

  *np->tf = *curproc->tf;
8010401a:	8b 72 18             	mov    0x18(%edx),%esi
8010401d:	b9 13 00 00 00       	mov    $0x13,%ecx
80104022:	8b 7b 18             	mov    0x18(%ebx),%edi
80104025:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104027:	8b 43 18             	mov    0x18(%ebx),%eax
8010402a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104031:	be 00 00 00 00       	mov    $0x0,%esi
80104036:	89 d7                	mov    %edx,%edi
80104038:	eb 29                	jmp    80104063 <fork2+0x96>
    kfree(np->kstack);
8010403a:	83 ec 0c             	sub    $0xc,%esp
8010403d:	ff 73 08             	pushl  0x8(%ebx)
80104040:	e8 5f df ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
80104045:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
8010404c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80104053:	83 c4 10             	add    $0x10,%esp
80104056:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010405b:	e9 f9 00 00 00       	jmp    80104159 <fork2+0x18c>
  for(i = 0; i < NOFILE; i++)
80104060:	83 c6 01             	add    $0x1,%esi
80104063:	83 fe 0f             	cmp    $0xf,%esi
80104066:	7f 1a                	jg     80104082 <fork2+0xb5>
    if(curproc->ofile[i])
80104068:	8b 44 b7 28          	mov    0x28(%edi,%esi,4),%eax
8010406c:	85 c0                	test   %eax,%eax
8010406e:	74 f0                	je     80104060 <fork2+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104070:	83 ec 0c             	sub    $0xc,%esp
80104073:	50                   	push   %eax
80104074:	e8 15 cc ff ff       	call   80100c8e <filedup>
80104079:	89 44 b3 28          	mov    %eax,0x28(%ebx,%esi,4)
8010407d:	83 c4 10             	add    $0x10,%esp
80104080:	eb de                	jmp    80104060 <fork2+0x93>
  np->cwd = idup(curproc->cwd);
80104082:	83 ec 0c             	sub    $0xc,%esp
80104085:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80104088:	ff 77 68             	pushl  0x68(%edi)
8010408b:	e8 c1 d4 ff ff       	call   80101551 <idup>
80104090:	89 43 68             	mov    %eax,0x68(%ebx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104093:	8d 47 6c             	lea    0x6c(%edi),%eax
80104096:	8d 53 6c             	lea    0x6c(%ebx),%edx
80104099:	83 c4 0c             	add    $0xc,%esp
8010409c:	6a 10                	push   $0x10
8010409e:	50                   	push   %eax
8010409f:	52                   	push   %edx
801040a0:	e8 b5 06 00 00       	call   8010475a <safestrcpy>

  pid = np->pid;
801040a5:	8b 73 10             	mov    0x10(%ebx),%esi

  acquire(&ptable.lock);
801040a8:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
801040af:	e8 93 04 00 00       	call   80104547 <acquire>

  np->state = RUNNABLE;
801040b4:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  // Set desired priority
  np->priority = pri;
801040bb:	8b 45 08             	mov    0x8(%ebp),%eax
801040be:	89 83 9c 00 00 00    	mov    %eax,0x9c(%ebx)
  // Set qtails, ticks, and ticksUsed to zero at each priority
  for (int i = 0; i < 4; i++){
801040c4:	83 c4 10             	add    $0x10,%esp
801040c7:	b8 00 00 00 00       	mov    $0x0,%eax
801040cc:	eb 21                	jmp    801040ef <fork2+0x122>
    np->qtail[i] = 0;
801040ce:	c7 44 83 7c 00 00 00 	movl   $0x0,0x7c(%ebx,%eax,4)
801040d5:	00 
    np->ticks[i] = 0;
801040d6:	c7 84 83 8c 00 00 00 	movl   $0x0,0x8c(%ebx,%eax,4)
801040dd:	00 00 00 00 
    np->ticksUsed[i] = 0;
801040e1:	c7 84 83 a0 00 00 00 	movl   $0x0,0xa0(%ebx,%eax,4)
801040e8:	00 00 00 00 
  for (int i = 0; i < 4; i++){
801040ec:	83 c0 01             	add    $0x1,%eax
801040ef:	83 f8 03             	cmp    $0x3,%eax
801040f2:	7e da                	jle    801040ce <fork2+0x101>
  }
  // Insert the process in the queue and increment qtail
  if (pri == 3) {
801040f4:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
801040f8:	74 69                	je     80104163 <fork2+0x196>
          q3[i] = np;
          break;
        }
      }
      np->qtail[3]++;
  } else if (pri == 2){
801040fa:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
801040fe:	0f 84 90 00 00 00    	je     80104194 <fork2+0x1c7>
          break;
        }
      }
      np->qtail[2]++;
      // cprintf("PID %d In fork2 qtail: %d\n", np->pid, np->qtail[2]);
  } else if (pri == 1){
80104104:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
80104108:	0f 84 b7 00 00 00    	je     801041c5 <fork2+0x1f8>
          q1[i] = np;
          break;
        }
      }
      np->qtail[1]++;
  } else if (pri == 0){
8010410e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104112:	75 35                	jne    80104149 <fork2+0x17c>
80104114:	8b 45 08             	mov    0x8(%ebp),%eax
      for(int i = 0; i < NPROC; i++){
80104117:	83 f8 3f             	cmp    $0x3f,%eax
8010411a:	0f 8f c8 00 00 00    	jg     801041e8 <fork2+0x21b>
        if(q0[i] == 0){
80104120:	83 3c 85 c0 a8 10 80 	cmpl   $0x0,-0x7fef5740(,%eax,4)
80104127:	00 
80104128:	0f 84 b0 00 00 00    	je     801041de <fork2+0x211>
      for(int i = 0; i < NPROC; i++){
8010412e:	83 c0 01             	add    $0x1,%eax
80104131:	eb e4                	jmp    80104117 <fork2+0x14a>
          q3[i] = np;
80104133:	89 1c 85 c0 a5 10 80 	mov    %ebx,-0x7fef5a40(,%eax,4)
      np->qtail[3]++;
8010413a:	8b 83 88 00 00 00    	mov    0x88(%ebx),%eax
80104140:	83 c0 01             	add    $0x1,%eax
80104143:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
        }
      }
      np->qtail[0]++;
  }

  release(&ptable.lock);
80104149:	83 ec 0c             	sub    $0xc,%esp
8010414c:	68 40 31 11 80       	push   $0x80113140
80104151:	e8 56 04 00 00       	call   801045ac <release>
  return pid;
80104156:	83 c4 10             	add    $0x10,%esp
}
80104159:	89 f0                	mov    %esi,%eax
8010415b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010415e:	5b                   	pop    %ebx
8010415f:	5e                   	pop    %esi
80104160:	5f                   	pop    %edi
80104161:	5d                   	pop    %ebp
80104162:	c3                   	ret    
      for(int i = 0; i < NPROC; i++){
80104163:	b8 00 00 00 00       	mov    $0x0,%eax
80104168:	83 f8 3f             	cmp    $0x3f,%eax
8010416b:	7f cd                	jg     8010413a <fork2+0x16d>
        if(q3[i] == 0){
8010416d:	83 3c 85 c0 a5 10 80 	cmpl   $0x0,-0x7fef5a40(,%eax,4)
80104174:	00 
80104175:	74 bc                	je     80104133 <fork2+0x166>
      for(int i = 0; i < NPROC; i++){
80104177:	83 c0 01             	add    $0x1,%eax
8010417a:	eb ec                	jmp    80104168 <fork2+0x19b>
          q2[i] = np;
8010417c:	89 1c 85 c0 a6 10 80 	mov    %ebx,-0x7fef5940(,%eax,4)
      np->qtail[2]++;
80104183:	8b 83 84 00 00 00    	mov    0x84(%ebx),%eax
80104189:	83 c0 01             	add    $0x1,%eax
8010418c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
80104192:	eb b5                	jmp    80104149 <fork2+0x17c>
      for(int i = 0; i < NPROC; i++){
80104194:	b8 00 00 00 00       	mov    $0x0,%eax
80104199:	83 f8 3f             	cmp    $0x3f,%eax
8010419c:	7f e5                	jg     80104183 <fork2+0x1b6>
        if(q2[i] == 0){
8010419e:	83 3c 85 c0 a6 10 80 	cmpl   $0x0,-0x7fef5940(,%eax,4)
801041a5:	00 
801041a6:	74 d4                	je     8010417c <fork2+0x1af>
      for(int i = 0; i < NPROC; i++){
801041a8:	83 c0 01             	add    $0x1,%eax
801041ab:	eb ec                	jmp    80104199 <fork2+0x1cc>
          q1[i] = np;
801041ad:	89 1c 85 c0 a7 10 80 	mov    %ebx,-0x7fef5840(,%eax,4)
      np->qtail[1]++;
801041b4:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
801041ba:	83 c0 01             	add    $0x1,%eax
801041bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
801041c3:	eb 84                	jmp    80104149 <fork2+0x17c>
      for(int i = 0; i < NPROC; i++){
801041c5:	b8 00 00 00 00       	mov    $0x0,%eax
801041ca:	83 f8 3f             	cmp    $0x3f,%eax
801041cd:	7f e5                	jg     801041b4 <fork2+0x1e7>
        if(q1[i] == 0){
801041cf:	83 3c 85 c0 a7 10 80 	cmpl   $0x0,-0x7fef5840(,%eax,4)
801041d6:	00 
801041d7:	74 d4                	je     801041ad <fork2+0x1e0>
      for(int i = 0; i < NPROC; i++){
801041d9:	83 c0 01             	add    $0x1,%eax
801041dc:	eb ec                	jmp    801041ca <fork2+0x1fd>
801041de:	89 45 08             	mov    %eax,0x8(%ebp)
          q0[i] = np;
801041e1:	89 1c 85 c0 a8 10 80 	mov    %ebx,-0x7fef5740(,%eax,4)
      np->qtail[0]++;
801041e8:	8b 43 7c             	mov    0x7c(%ebx),%eax
801041eb:	83 c0 01             	add    $0x1,%eax
801041ee:	89 43 7c             	mov    %eax,0x7c(%ebx)
801041f1:	e9 53 ff ff ff       	jmp    80104149 <fork2+0x17c>
    return -1;
801041f6:	be ff ff ff ff       	mov    $0xffffffff,%esi
801041fb:	e9 59 ff ff ff       	jmp    80104159 <fork2+0x18c>
    return -1;
80104200:	be ff ff ff ff       	mov    $0xffffffff,%esi
80104205:	e9 4f ff ff ff       	jmp    80104159 <fork2+0x18c>

8010420a <fork>:
{
8010420a:	55                   	push   %ebp
8010420b:	89 e5                	mov    %esp,%ebp
8010420d:	83 ec 08             	sub    $0x8,%esp
  struct proc *p = myproc();
80104210:	e8 b9 ef ff ff       	call   801031ce <myproc>
  return fork2(getpri(p->pid));
80104215:	83 ec 0c             	sub    $0xc,%esp
80104218:	ff 70 10             	pushl  0x10(%eax)
8010421b:	e8 80 fd ff ff       	call   80103fa0 <getpri>
80104220:	89 04 24             	mov    %eax,(%esp)
80104223:	e8 a5 fd ff ff       	call   80103fcd <fork2>
}
80104228:	c9                   	leave  
80104229:	c3                   	ret    

8010422a <getpinfo>:

int getpinfo(struct pstat *mystruct){
8010422a:	55                   	push   %ebp
8010422b:	89 e5                	mov    %esp,%ebp
8010422d:	57                   	push   %edi
8010422e:	56                   	push   %esi
8010422f:	53                   	push   %ebx
80104230:	83 ec 0c             	sub    $0xc,%esp
80104233:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (mystruct == 0) {
80104236:	85 db                	test   %ebx,%ebx
80104238:	0f 84 bb 00 00 00    	je     801042f9 <getpinfo+0xcf>
    return -1;
  }

  struct proc *p = ptable.proc;
  acquire(&ptable.lock);
8010423e:	83 ec 0c             	sub    $0xc,%esp
80104241:	68 40 31 11 80       	push   $0x80113140
80104246:	e8 fc 02 00 00       	call   80104547 <acquire>

  for(int i = 0; i < NPROC; i++){
8010424b:	83 c4 10             	add    $0x10,%esp
8010424e:	bf 00 00 00 00       	mov    $0x0,%edi
80104253:	eb 30                	jmp    80104285 <getpinfo+0x5b>

    if (p[i].state == UNUSED || p[i].state == EMBRYO || p[i].state == ZOMBIE){
      mystruct->inuse[i] = 0;
    } else {
      mystruct->inuse[i] = 1;
80104255:	c7 04 bb 01 00 00 00 	movl   $0x1,(%ebx,%edi,4)
8010425c:	eb 56                	jmp    801042b4 <getpinfo+0x8a>
    }
    mystruct->pid[i] = p[i].pid;
    mystruct->state[i] = p[i].state;
    mystruct->priority[i] = p[i].priority;
    for (int j = 0; j < 4; j++) {
      mystruct->ticks[i][j] = p[i].ticks[j];
8010425e:	8d 34 b8             	lea    (%eax,%edi,4),%esi
80104261:	8b 8c 82 8c 00 00 00 	mov    0x8c(%edx,%eax,4),%ecx
80104268:	89 8c b3 00 04 00 00 	mov    %ecx,0x400(%ebx,%esi,4)
      mystruct->qtail[i][j] = p[i].qtail[j];
8010426f:	8b 4c 82 7c          	mov    0x7c(%edx,%eax,4),%ecx
80104273:	89 8c b3 00 08 00 00 	mov    %ecx,0x800(%ebx,%esi,4)
    for (int j = 0; j < 4; j++) {
8010427a:	83 c0 01             	add    $0x1,%eax
8010427d:	83 f8 03             	cmp    $0x3,%eax
80104280:	7e dc                	jle    8010425e <getpinfo+0x34>
  for(int i = 0; i < NPROC; i++){
80104282:	83 c7 01             	add    $0x1,%edi
80104285:	83 ff 3f             	cmp    $0x3f,%edi
80104288:	7f 52                	jg     801042dc <getpinfo+0xb2>
    if (p[i].state == UNUSED || p[i].state == EMBRYO || p[i].state == ZOMBIE){
8010428a:	69 d7 b0 00 00 00    	imul   $0xb0,%edi,%edx
80104290:	81 c2 74 31 11 80    	add    $0x80113174,%edx
80104296:	8b 4a 0c             	mov    0xc(%edx),%ecx
80104299:	83 f9 01             	cmp    $0x1,%ecx
8010429c:	0f 96 c0             	setbe  %al
8010429f:	89 c6                	mov    %eax,%esi
801042a1:	83 f9 05             	cmp    $0x5,%ecx
801042a4:	0f 94 c0             	sete   %al
801042a7:	89 f1                	mov    %esi,%ecx
801042a9:	08 c1                	or     %al,%cl
801042ab:	74 a8                	je     80104255 <getpinfo+0x2b>
      mystruct->inuse[i] = 0;
801042ad:	c7 04 bb 00 00 00 00 	movl   $0x0,(%ebx,%edi,4)
    mystruct->pid[i] = p[i].pid;
801042b4:	8b 42 10             	mov    0x10(%edx),%eax
801042b7:	89 84 bb 00 01 00 00 	mov    %eax,0x100(%ebx,%edi,4)
    mystruct->state[i] = p[i].state;
801042be:	8b 42 0c             	mov    0xc(%edx),%eax
801042c1:	89 84 bb 00 03 00 00 	mov    %eax,0x300(%ebx,%edi,4)
    mystruct->priority[i] = p[i].priority;
801042c8:	8b 82 9c 00 00 00    	mov    0x9c(%edx),%eax
801042ce:	89 84 bb 00 02 00 00 	mov    %eax,0x200(%ebx,%edi,4)
    for (int j = 0; j < 4; j++) {
801042d5:	b8 00 00 00 00       	mov    $0x0,%eax
801042da:	eb a1                	jmp    8010427d <getpinfo+0x53>
    }
  }
  release(&ptable.lock);
801042dc:	83 ec 0c             	sub    $0xc,%esp
801042df:	68 40 31 11 80       	push   $0x80113140
801042e4:	e8 c3 02 00 00       	call   801045ac <release>
  return 0;
801042e9:	83 c4 10             	add    $0x10,%esp
801042ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
801042f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042f4:	5b                   	pop    %ebx
801042f5:	5e                   	pop    %esi
801042f6:	5f                   	pop    %edi
801042f7:	5d                   	pop    %ebp
801042f8:	c3                   	ret    
    return -1;
801042f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042fe:	eb f1                	jmp    801042f1 <getpinfo+0xc7>

80104300 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104300:	55                   	push   %ebp
80104301:	89 e5                	mov    %esp,%ebp
80104303:	53                   	push   %ebx
80104304:	83 ec 0c             	sub    $0xc,%esp
80104307:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010430a:	68 38 75 10 80       	push   $0x80107538
8010430f:	8d 43 04             	lea    0x4(%ebx),%eax
80104312:	50                   	push   %eax
80104313:	e8 f3 00 00 00       	call   8010440b <initlock>
  lk->name = name;
80104318:	8b 45 0c             	mov    0xc(%ebp),%eax
8010431b:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
8010431e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80104324:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
8010432b:	83 c4 10             	add    $0x10,%esp
8010432e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104331:	c9                   	leave  
80104332:	c3                   	ret    

80104333 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104333:	55                   	push   %ebp
80104334:	89 e5                	mov    %esp,%ebp
80104336:	56                   	push   %esi
80104337:	53                   	push   %ebx
80104338:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
8010433b:	8d 73 04             	lea    0x4(%ebx),%esi
8010433e:	83 ec 0c             	sub    $0xc,%esp
80104341:	56                   	push   %esi
80104342:	e8 00 02 00 00       	call   80104547 <acquire>
  while (lk->locked) {
80104347:	83 c4 10             	add    $0x10,%esp
8010434a:	eb 0d                	jmp    80104359 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
8010434c:	83 ec 08             	sub    $0x8,%esp
8010434f:	56                   	push   %esi
80104350:	53                   	push   %ebx
80104351:	e8 08 f8 ff ff       	call   80103b5e <sleep>
80104356:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104359:	83 3b 00             	cmpl   $0x0,(%ebx)
8010435c:	75 ee                	jne    8010434c <acquiresleep+0x19>
  }
  lk->locked = 1;
8010435e:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104364:	e8 65 ee ff ff       	call   801031ce <myproc>
80104369:	8b 40 10             	mov    0x10(%eax),%eax
8010436c:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
8010436f:	83 ec 0c             	sub    $0xc,%esp
80104372:	56                   	push   %esi
80104373:	e8 34 02 00 00       	call   801045ac <release>
}
80104378:	83 c4 10             	add    $0x10,%esp
8010437b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010437e:	5b                   	pop    %ebx
8010437f:	5e                   	pop    %esi
80104380:	5d                   	pop    %ebp
80104381:	c3                   	ret    

80104382 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104382:	55                   	push   %ebp
80104383:	89 e5                	mov    %esp,%ebp
80104385:	56                   	push   %esi
80104386:	53                   	push   %ebx
80104387:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
8010438a:	8d 73 04             	lea    0x4(%ebx),%esi
8010438d:	83 ec 0c             	sub    $0xc,%esp
80104390:	56                   	push   %esi
80104391:	e8 b1 01 00 00       	call   80104547 <acquire>
  lk->locked = 0;
80104396:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010439c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
801043a3:	89 1c 24             	mov    %ebx,(%esp)
801043a6:	e8 1b f9 ff ff       	call   80103cc6 <wakeup>
  release(&lk->lk);
801043ab:	89 34 24             	mov    %esi,(%esp)
801043ae:	e8 f9 01 00 00       	call   801045ac <release>
}
801043b3:	83 c4 10             	add    $0x10,%esp
801043b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043b9:	5b                   	pop    %ebx
801043ba:	5e                   	pop    %esi
801043bb:	5d                   	pop    %ebp
801043bc:	c3                   	ret    

801043bd <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801043bd:	55                   	push   %ebp
801043be:	89 e5                	mov    %esp,%ebp
801043c0:	56                   	push   %esi
801043c1:	53                   	push   %ebx
801043c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
801043c5:	8d 73 04             	lea    0x4(%ebx),%esi
801043c8:	83 ec 0c             	sub    $0xc,%esp
801043cb:	56                   	push   %esi
801043cc:	e8 76 01 00 00       	call   80104547 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
801043d1:	83 c4 10             	add    $0x10,%esp
801043d4:	83 3b 00             	cmpl   $0x0,(%ebx)
801043d7:	75 17                	jne    801043f0 <holdingsleep+0x33>
801043d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
801043de:	83 ec 0c             	sub    $0xc,%esp
801043e1:	56                   	push   %esi
801043e2:	e8 c5 01 00 00       	call   801045ac <release>
  return r;
}
801043e7:	89 d8                	mov    %ebx,%eax
801043e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801043ec:	5b                   	pop    %ebx
801043ed:	5e                   	pop    %esi
801043ee:	5d                   	pop    %ebp
801043ef:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
801043f0:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801043f3:	e8 d6 ed ff ff       	call   801031ce <myproc>
801043f8:	3b 58 10             	cmp    0x10(%eax),%ebx
801043fb:	74 07                	je     80104404 <holdingsleep+0x47>
801043fd:	bb 00 00 00 00       	mov    $0x0,%ebx
80104402:	eb da                	jmp    801043de <holdingsleep+0x21>
80104404:	bb 01 00 00 00       	mov    $0x1,%ebx
80104409:	eb d3                	jmp    801043de <holdingsleep+0x21>

8010440b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010440b:	55                   	push   %ebp
8010440c:	89 e5                	mov    %esp,%ebp
8010440e:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80104411:	8b 55 0c             	mov    0xc(%ebp),%edx
80104414:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104417:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010441d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104424:	5d                   	pop    %ebp
80104425:	c3                   	ret    

80104426 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104426:	55                   	push   %ebp
80104427:	89 e5                	mov    %esp,%ebp
80104429:	53                   	push   %ebx
8010442a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010442d:	8b 45 08             	mov    0x8(%ebp),%eax
80104430:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80104433:	b8 00 00 00 00       	mov    $0x0,%eax
80104438:	83 f8 09             	cmp    $0x9,%eax
8010443b:	7f 25                	jg     80104462 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010443d:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104443:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104449:	77 17                	ja     80104462 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010444b:	8b 5a 04             	mov    0x4(%edx),%ebx
8010444e:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80104451:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80104453:	83 c0 01             	add    $0x1,%eax
80104456:	eb e0                	jmp    80104438 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80104458:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
8010445f:	83 c0 01             	add    $0x1,%eax
80104462:	83 f8 09             	cmp    $0x9,%eax
80104465:	7e f1                	jle    80104458 <getcallerpcs+0x32>
}
80104467:	5b                   	pop    %ebx
80104468:	5d                   	pop    %ebp
80104469:	c3                   	ret    

8010446a <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010446a:	55                   	push   %ebp
8010446b:	89 e5                	mov    %esp,%ebp
8010446d:	53                   	push   %ebx
8010446e:	83 ec 04             	sub    $0x4,%esp
80104471:	9c                   	pushf  
80104472:	5b                   	pop    %ebx
  asm volatile("cli");
80104473:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80104474:	e8 de ec ff ff       	call   80103157 <mycpu>
80104479:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80104480:	74 12                	je     80104494 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104482:	e8 d0 ec ff ff       	call   80103157 <mycpu>
80104487:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
8010448e:	83 c4 04             	add    $0x4,%esp
80104491:	5b                   	pop    %ebx
80104492:	5d                   	pop    %ebp
80104493:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80104494:	e8 be ec ff ff       	call   80103157 <mycpu>
80104499:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010449f:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
801044a5:	eb db                	jmp    80104482 <pushcli+0x18>

801044a7 <popcli>:

void
popcli(void)
{
801044a7:	55                   	push   %ebp
801044a8:	89 e5                	mov    %esp,%ebp
801044aa:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801044ad:	9c                   	pushf  
801044ae:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801044af:	f6 c4 02             	test   $0x2,%ah
801044b2:	75 28                	jne    801044dc <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
801044b4:	e8 9e ec ff ff       	call   80103157 <mycpu>
801044b9:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
801044bf:	8d 51 ff             	lea    -0x1(%ecx),%edx
801044c2:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801044c8:	85 d2                	test   %edx,%edx
801044ca:	78 1d                	js     801044e9 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801044cc:	e8 86 ec ff ff       	call   80103157 <mycpu>
801044d1:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
801044d8:	74 1c                	je     801044f6 <popcli+0x4f>
    sti();
}
801044da:	c9                   	leave  
801044db:	c3                   	ret    
    panic("popcli - interruptible");
801044dc:	83 ec 0c             	sub    $0xc,%esp
801044df:	68 43 75 10 80       	push   $0x80107543
801044e4:	e8 5f be ff ff       	call   80100348 <panic>
    panic("popcli");
801044e9:	83 ec 0c             	sub    $0xc,%esp
801044ec:	68 5a 75 10 80       	push   $0x8010755a
801044f1:	e8 52 be ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801044f6:	e8 5c ec ff ff       	call   80103157 <mycpu>
801044fb:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80104502:	74 d6                	je     801044da <popcli+0x33>
  asm volatile("sti");
80104504:	fb                   	sti    
}
80104505:	eb d3                	jmp    801044da <popcli+0x33>

80104507 <holding>:
{
80104507:	55                   	push   %ebp
80104508:	89 e5                	mov    %esp,%ebp
8010450a:	53                   	push   %ebx
8010450b:	83 ec 04             	sub    $0x4,%esp
8010450e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104511:	e8 54 ff ff ff       	call   8010446a <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104516:	83 3b 00             	cmpl   $0x0,(%ebx)
80104519:	75 12                	jne    8010452d <holding+0x26>
8010451b:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80104520:	e8 82 ff ff ff       	call   801044a7 <popcli>
}
80104525:	89 d8                	mov    %ebx,%eax
80104527:	83 c4 04             	add    $0x4,%esp
8010452a:	5b                   	pop    %ebx
8010452b:	5d                   	pop    %ebp
8010452c:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
8010452d:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104530:	e8 22 ec ff ff       	call   80103157 <mycpu>
80104535:	39 c3                	cmp    %eax,%ebx
80104537:	74 07                	je     80104540 <holding+0x39>
80104539:	bb 00 00 00 00       	mov    $0x0,%ebx
8010453e:	eb e0                	jmp    80104520 <holding+0x19>
80104540:	bb 01 00 00 00       	mov    $0x1,%ebx
80104545:	eb d9                	jmp    80104520 <holding+0x19>

80104547 <acquire>:
{
80104547:	55                   	push   %ebp
80104548:	89 e5                	mov    %esp,%ebp
8010454a:	53                   	push   %ebx
8010454b:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010454e:	e8 17 ff ff ff       	call   8010446a <pushcli>
  if(holding(lk))
80104553:	83 ec 0c             	sub    $0xc,%esp
80104556:	ff 75 08             	pushl  0x8(%ebp)
80104559:	e8 a9 ff ff ff       	call   80104507 <holding>
8010455e:	83 c4 10             	add    $0x10,%esp
80104561:	85 c0                	test   %eax,%eax
80104563:	75 3a                	jne    8010459f <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80104565:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80104568:	b8 01 00 00 00       	mov    $0x1,%eax
8010456d:	f0 87 02             	lock xchg %eax,(%edx)
80104570:	85 c0                	test   %eax,%eax
80104572:	75 f1                	jne    80104565 <acquire+0x1e>
  __sync_synchronize();
80104574:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104579:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010457c:	e8 d6 eb ff ff       	call   80103157 <mycpu>
80104581:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104584:	8b 45 08             	mov    0x8(%ebp),%eax
80104587:	83 c0 0c             	add    $0xc,%eax
8010458a:	83 ec 08             	sub    $0x8,%esp
8010458d:	50                   	push   %eax
8010458e:	8d 45 08             	lea    0x8(%ebp),%eax
80104591:	50                   	push   %eax
80104592:	e8 8f fe ff ff       	call   80104426 <getcallerpcs>
}
80104597:	83 c4 10             	add    $0x10,%esp
8010459a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010459d:	c9                   	leave  
8010459e:	c3                   	ret    
    panic("acquire");
8010459f:	83 ec 0c             	sub    $0xc,%esp
801045a2:	68 61 75 10 80       	push   $0x80107561
801045a7:	e8 9c bd ff ff       	call   80100348 <panic>

801045ac <release>:
{
801045ac:	55                   	push   %ebp
801045ad:	89 e5                	mov    %esp,%ebp
801045af:	53                   	push   %ebx
801045b0:	83 ec 10             	sub    $0x10,%esp
801045b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
801045b6:	53                   	push   %ebx
801045b7:	e8 4b ff ff ff       	call   80104507 <holding>
801045bc:	83 c4 10             	add    $0x10,%esp
801045bf:	85 c0                	test   %eax,%eax
801045c1:	74 23                	je     801045e6 <release+0x3a>
  lk->pcs[0] = 0;
801045c3:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801045ca:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801045d1:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801045d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
801045dc:	e8 c6 fe ff ff       	call   801044a7 <popcli>
}
801045e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801045e4:	c9                   	leave  
801045e5:	c3                   	ret    
    panic("release");
801045e6:	83 ec 0c             	sub    $0xc,%esp
801045e9:	68 69 75 10 80       	push   $0x80107569
801045ee:	e8 55 bd ff ff       	call   80100348 <panic>

801045f3 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801045f3:	55                   	push   %ebp
801045f4:	89 e5                	mov    %esp,%ebp
801045f6:	57                   	push   %edi
801045f7:	53                   	push   %ebx
801045f8:	8b 55 08             	mov    0x8(%ebp),%edx
801045fb:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
801045fe:	f6 c2 03             	test   $0x3,%dl
80104601:	75 05                	jne    80104608 <memset+0x15>
80104603:	f6 c1 03             	test   $0x3,%cl
80104606:	74 0e                	je     80104616 <memset+0x23>
  asm volatile("cld; rep stosb" :
80104608:	89 d7                	mov    %edx,%edi
8010460a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010460d:	fc                   	cld    
8010460e:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80104610:	89 d0                	mov    %edx,%eax
80104612:	5b                   	pop    %ebx
80104613:	5f                   	pop    %edi
80104614:	5d                   	pop    %ebp
80104615:	c3                   	ret    
    c &= 0xFF;
80104616:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
8010461a:	c1 e9 02             	shr    $0x2,%ecx
8010461d:	89 f8                	mov    %edi,%eax
8010461f:	c1 e0 18             	shl    $0x18,%eax
80104622:	89 fb                	mov    %edi,%ebx
80104624:	c1 e3 10             	shl    $0x10,%ebx
80104627:	09 d8                	or     %ebx,%eax
80104629:	89 fb                	mov    %edi,%ebx
8010462b:	c1 e3 08             	shl    $0x8,%ebx
8010462e:	09 d8                	or     %ebx,%eax
80104630:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104632:	89 d7                	mov    %edx,%edi
80104634:	fc                   	cld    
80104635:	f3 ab                	rep stos %eax,%es:(%edi)
80104637:	eb d7                	jmp    80104610 <memset+0x1d>

80104639 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104639:	55                   	push   %ebp
8010463a:	89 e5                	mov    %esp,%ebp
8010463c:	56                   	push   %esi
8010463d:	53                   	push   %ebx
8010463e:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104641:	8b 55 0c             	mov    0xc(%ebp),%edx
80104644:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104647:	8d 70 ff             	lea    -0x1(%eax),%esi
8010464a:	85 c0                	test   %eax,%eax
8010464c:	74 1c                	je     8010466a <memcmp+0x31>
    if(*s1 != *s2)
8010464e:	0f b6 01             	movzbl (%ecx),%eax
80104651:	0f b6 1a             	movzbl (%edx),%ebx
80104654:	38 d8                	cmp    %bl,%al
80104656:	75 0a                	jne    80104662 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80104658:	83 c1 01             	add    $0x1,%ecx
8010465b:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
8010465e:	89 f0                	mov    %esi,%eax
80104660:	eb e5                	jmp    80104647 <memcmp+0xe>
      return *s1 - *s2;
80104662:	0f b6 c0             	movzbl %al,%eax
80104665:	0f b6 db             	movzbl %bl,%ebx
80104668:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
8010466a:	5b                   	pop    %ebx
8010466b:	5e                   	pop    %esi
8010466c:	5d                   	pop    %ebp
8010466d:	c3                   	ret    

8010466e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010466e:	55                   	push   %ebp
8010466f:	89 e5                	mov    %esp,%ebp
80104671:	56                   	push   %esi
80104672:	53                   	push   %ebx
80104673:	8b 45 08             	mov    0x8(%ebp),%eax
80104676:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104679:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010467c:	39 c1                	cmp    %eax,%ecx
8010467e:	73 3a                	jae    801046ba <memmove+0x4c>
80104680:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80104683:	39 c3                	cmp    %eax,%ebx
80104685:	76 37                	jbe    801046be <memmove+0x50>
    s += n;
    d += n;
80104687:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
8010468a:	eb 0d                	jmp    80104699 <memmove+0x2b>
      *--d = *--s;
8010468c:	83 eb 01             	sub    $0x1,%ebx
8010468f:	83 e9 01             	sub    $0x1,%ecx
80104692:	0f b6 13             	movzbl (%ebx),%edx
80104695:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80104697:	89 f2                	mov    %esi,%edx
80104699:	8d 72 ff             	lea    -0x1(%edx),%esi
8010469c:	85 d2                	test   %edx,%edx
8010469e:	75 ec                	jne    8010468c <memmove+0x1e>
801046a0:	eb 14                	jmp    801046b6 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
801046a2:	0f b6 11             	movzbl (%ecx),%edx
801046a5:	88 13                	mov    %dl,(%ebx)
801046a7:	8d 5b 01             	lea    0x1(%ebx),%ebx
801046aa:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
801046ad:	89 f2                	mov    %esi,%edx
801046af:	8d 72 ff             	lea    -0x1(%edx),%esi
801046b2:	85 d2                	test   %edx,%edx
801046b4:	75 ec                	jne    801046a2 <memmove+0x34>

  return dst;
}
801046b6:	5b                   	pop    %ebx
801046b7:	5e                   	pop    %esi
801046b8:	5d                   	pop    %ebp
801046b9:	c3                   	ret    
801046ba:	89 c3                	mov    %eax,%ebx
801046bc:	eb f1                	jmp    801046af <memmove+0x41>
801046be:	89 c3                	mov    %eax,%ebx
801046c0:	eb ed                	jmp    801046af <memmove+0x41>

801046c2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801046c2:	55                   	push   %ebp
801046c3:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801046c5:	ff 75 10             	pushl  0x10(%ebp)
801046c8:	ff 75 0c             	pushl  0xc(%ebp)
801046cb:	ff 75 08             	pushl  0x8(%ebp)
801046ce:	e8 9b ff ff ff       	call   8010466e <memmove>
}
801046d3:	c9                   	leave  
801046d4:	c3                   	ret    

801046d5 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801046d5:	55                   	push   %ebp
801046d6:	89 e5                	mov    %esp,%ebp
801046d8:	53                   	push   %ebx
801046d9:	8b 55 08             	mov    0x8(%ebp),%edx
801046dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801046df:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
801046e2:	eb 09                	jmp    801046ed <strncmp+0x18>
    n--, p++, q++;
801046e4:	83 e8 01             	sub    $0x1,%eax
801046e7:	83 c2 01             	add    $0x1,%edx
801046ea:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801046ed:	85 c0                	test   %eax,%eax
801046ef:	74 0b                	je     801046fc <strncmp+0x27>
801046f1:	0f b6 1a             	movzbl (%edx),%ebx
801046f4:	84 db                	test   %bl,%bl
801046f6:	74 04                	je     801046fc <strncmp+0x27>
801046f8:	3a 19                	cmp    (%ecx),%bl
801046fa:	74 e8                	je     801046e4 <strncmp+0xf>
  if(n == 0)
801046fc:	85 c0                	test   %eax,%eax
801046fe:	74 0b                	je     8010470b <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80104700:	0f b6 02             	movzbl (%edx),%eax
80104703:	0f b6 11             	movzbl (%ecx),%edx
80104706:	29 d0                	sub    %edx,%eax
}
80104708:	5b                   	pop    %ebx
80104709:	5d                   	pop    %ebp
8010470a:	c3                   	ret    
    return 0;
8010470b:	b8 00 00 00 00       	mov    $0x0,%eax
80104710:	eb f6                	jmp    80104708 <strncmp+0x33>

80104712 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104712:	55                   	push   %ebp
80104713:	89 e5                	mov    %esp,%ebp
80104715:	57                   	push   %edi
80104716:	56                   	push   %esi
80104717:	53                   	push   %ebx
80104718:	8b 5d 0c             	mov    0xc(%ebp),%ebx
8010471b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
8010471e:	8b 45 08             	mov    0x8(%ebp),%eax
80104721:	eb 04                	jmp    80104727 <strncpy+0x15>
80104723:	89 fb                	mov    %edi,%ebx
80104725:	89 f0                	mov    %esi,%eax
80104727:	8d 51 ff             	lea    -0x1(%ecx),%edx
8010472a:	85 c9                	test   %ecx,%ecx
8010472c:	7e 1d                	jle    8010474b <strncpy+0x39>
8010472e:	8d 7b 01             	lea    0x1(%ebx),%edi
80104731:	8d 70 01             	lea    0x1(%eax),%esi
80104734:	0f b6 1b             	movzbl (%ebx),%ebx
80104737:	88 18                	mov    %bl,(%eax)
80104739:	89 d1                	mov    %edx,%ecx
8010473b:	84 db                	test   %bl,%bl
8010473d:	75 e4                	jne    80104723 <strncpy+0x11>
8010473f:	89 f0                	mov    %esi,%eax
80104741:	eb 08                	jmp    8010474b <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80104743:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104746:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104748:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
8010474b:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010474e:	85 d2                	test   %edx,%edx
80104750:	7f f1                	jg     80104743 <strncpy+0x31>
  return os;
}
80104752:	8b 45 08             	mov    0x8(%ebp),%eax
80104755:	5b                   	pop    %ebx
80104756:	5e                   	pop    %esi
80104757:	5f                   	pop    %edi
80104758:	5d                   	pop    %ebp
80104759:	c3                   	ret    

8010475a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010475a:	55                   	push   %ebp
8010475b:	89 e5                	mov    %esp,%ebp
8010475d:	57                   	push   %edi
8010475e:	56                   	push   %esi
8010475f:	53                   	push   %ebx
80104760:	8b 45 08             	mov    0x8(%ebp),%eax
80104763:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104766:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104769:	85 d2                	test   %edx,%edx
8010476b:	7e 23                	jle    80104790 <safestrcpy+0x36>
8010476d:	89 c1                	mov    %eax,%ecx
8010476f:	eb 04                	jmp    80104775 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104771:	89 fb                	mov    %edi,%ebx
80104773:	89 f1                	mov    %esi,%ecx
80104775:	83 ea 01             	sub    $0x1,%edx
80104778:	85 d2                	test   %edx,%edx
8010477a:	7e 11                	jle    8010478d <safestrcpy+0x33>
8010477c:	8d 7b 01             	lea    0x1(%ebx),%edi
8010477f:	8d 71 01             	lea    0x1(%ecx),%esi
80104782:	0f b6 1b             	movzbl (%ebx),%ebx
80104785:	88 19                	mov    %bl,(%ecx)
80104787:	84 db                	test   %bl,%bl
80104789:	75 e6                	jne    80104771 <safestrcpy+0x17>
8010478b:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
8010478d:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80104790:	5b                   	pop    %ebx
80104791:	5e                   	pop    %esi
80104792:	5f                   	pop    %edi
80104793:	5d                   	pop    %ebp
80104794:	c3                   	ret    

80104795 <strlen>:

int
strlen(const char *s)
{
80104795:	55                   	push   %ebp
80104796:	89 e5                	mov    %esp,%ebp
80104798:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
8010479b:	b8 00 00 00 00       	mov    $0x0,%eax
801047a0:	eb 03                	jmp    801047a5 <strlen+0x10>
801047a2:	83 c0 01             	add    $0x1,%eax
801047a5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
801047a9:	75 f7                	jne    801047a2 <strlen+0xd>
    ;
  return n;
}
801047ab:	5d                   	pop    %ebp
801047ac:	c3                   	ret    

801047ad <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
801047ad:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
801047b1:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
801047b5:	55                   	push   %ebp
  pushl %ebx
801047b6:	53                   	push   %ebx
  pushl %esi
801047b7:	56                   	push   %esi
  pushl %edi
801047b8:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
801047b9:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
801047bb:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
801047bd:	5f                   	pop    %edi
  popl %esi
801047be:	5e                   	pop    %esi
  popl %ebx
801047bf:	5b                   	pop    %ebx
  popl %ebp
801047c0:	5d                   	pop    %ebp
  ret
801047c1:	c3                   	ret    

801047c2 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801047c2:	55                   	push   %ebp
801047c3:	89 e5                	mov    %esp,%ebp
801047c5:	53                   	push   %ebx
801047c6:	83 ec 04             	sub    $0x4,%esp
801047c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801047cc:	e8 fd e9 ff ff       	call   801031ce <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801047d1:	8b 00                	mov    (%eax),%eax
801047d3:	39 d8                	cmp    %ebx,%eax
801047d5:	76 19                	jbe    801047f0 <fetchint+0x2e>
801047d7:	8d 53 04             	lea    0x4(%ebx),%edx
801047da:	39 d0                	cmp    %edx,%eax
801047dc:	72 19                	jb     801047f7 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
801047de:	8b 13                	mov    (%ebx),%edx
801047e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801047e3:	89 10                	mov    %edx,(%eax)
  return 0;
801047e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047ea:	83 c4 04             	add    $0x4,%esp
801047ed:	5b                   	pop    %ebx
801047ee:	5d                   	pop    %ebp
801047ef:	c3                   	ret    
    return -1;
801047f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047f5:	eb f3                	jmp    801047ea <fetchint+0x28>
801047f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047fc:	eb ec                	jmp    801047ea <fetchint+0x28>

801047fe <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801047fe:	55                   	push   %ebp
801047ff:	89 e5                	mov    %esp,%ebp
80104801:	53                   	push   %ebx
80104802:	83 ec 04             	sub    $0x4,%esp
80104805:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104808:	e8 c1 e9 ff ff       	call   801031ce <myproc>

  if(addr >= curproc->sz)
8010480d:	39 18                	cmp    %ebx,(%eax)
8010480f:	76 26                	jbe    80104837 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80104811:	8b 55 0c             	mov    0xc(%ebp),%edx
80104814:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104816:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104818:	89 d8                	mov    %ebx,%eax
8010481a:	39 d0                	cmp    %edx,%eax
8010481c:	73 0e                	jae    8010482c <fetchstr+0x2e>
    if(*s == 0)
8010481e:	80 38 00             	cmpb   $0x0,(%eax)
80104821:	74 05                	je     80104828 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80104823:	83 c0 01             	add    $0x1,%eax
80104826:	eb f2                	jmp    8010481a <fetchstr+0x1c>
      return s - *pp;
80104828:	29 d8                	sub    %ebx,%eax
8010482a:	eb 05                	jmp    80104831 <fetchstr+0x33>
  }
  return -1;
8010482c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104831:	83 c4 04             	add    $0x4,%esp
80104834:	5b                   	pop    %ebx
80104835:	5d                   	pop    %ebp
80104836:	c3                   	ret    
    return -1;
80104837:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010483c:	eb f3                	jmp    80104831 <fetchstr+0x33>

8010483e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010483e:	55                   	push   %ebp
8010483f:	89 e5                	mov    %esp,%ebp
80104841:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104844:	e8 85 e9 ff ff       	call   801031ce <myproc>
80104849:	8b 50 18             	mov    0x18(%eax),%edx
8010484c:	8b 45 08             	mov    0x8(%ebp),%eax
8010484f:	c1 e0 02             	shl    $0x2,%eax
80104852:	03 42 44             	add    0x44(%edx),%eax
80104855:	83 ec 08             	sub    $0x8,%esp
80104858:	ff 75 0c             	pushl  0xc(%ebp)
8010485b:	83 c0 04             	add    $0x4,%eax
8010485e:	50                   	push   %eax
8010485f:	e8 5e ff ff ff       	call   801047c2 <fetchint>
}
80104864:	c9                   	leave  
80104865:	c3                   	ret    

80104866 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104866:	55                   	push   %ebp
80104867:	89 e5                	mov    %esp,%ebp
80104869:	56                   	push   %esi
8010486a:	53                   	push   %ebx
8010486b:	83 ec 10             	sub    $0x10,%esp
8010486e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104871:	e8 58 e9 ff ff       	call   801031ce <myproc>
80104876:	89 c6                	mov    %eax,%esi

  if(argint(n, &i) < 0)
80104878:	83 ec 08             	sub    $0x8,%esp
8010487b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010487e:	50                   	push   %eax
8010487f:	ff 75 08             	pushl  0x8(%ebp)
80104882:	e8 b7 ff ff ff       	call   8010483e <argint>
80104887:	83 c4 10             	add    $0x10,%esp
8010488a:	85 c0                	test   %eax,%eax
8010488c:	78 24                	js     801048b2 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010488e:	85 db                	test   %ebx,%ebx
80104890:	78 27                	js     801048b9 <argptr+0x53>
80104892:	8b 16                	mov    (%esi),%edx
80104894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104897:	39 c2                	cmp    %eax,%edx
80104899:	76 25                	jbe    801048c0 <argptr+0x5a>
8010489b:	01 c3                	add    %eax,%ebx
8010489d:	39 da                	cmp    %ebx,%edx
8010489f:	72 26                	jb     801048c7 <argptr+0x61>
    return -1;
  *pp = (char*)i;
801048a1:	8b 55 0c             	mov    0xc(%ebp),%edx
801048a4:	89 02                	mov    %eax,(%edx)
  return 0;
801048a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
801048ae:	5b                   	pop    %ebx
801048af:	5e                   	pop    %esi
801048b0:	5d                   	pop    %ebp
801048b1:	c3                   	ret    
    return -1;
801048b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b7:	eb f2                	jmp    801048ab <argptr+0x45>
    return -1;
801048b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048be:	eb eb                	jmp    801048ab <argptr+0x45>
801048c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048c5:	eb e4                	jmp    801048ab <argptr+0x45>
801048c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048cc:	eb dd                	jmp    801048ab <argptr+0x45>

801048ce <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801048ce:	55                   	push   %ebp
801048cf:	89 e5                	mov    %esp,%ebp
801048d1:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801048d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048d7:	50                   	push   %eax
801048d8:	ff 75 08             	pushl  0x8(%ebp)
801048db:	e8 5e ff ff ff       	call   8010483e <argint>
801048e0:	83 c4 10             	add    $0x10,%esp
801048e3:	85 c0                	test   %eax,%eax
801048e5:	78 13                	js     801048fa <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801048e7:	83 ec 08             	sub    $0x8,%esp
801048ea:	ff 75 0c             	pushl  0xc(%ebp)
801048ed:	ff 75 f4             	pushl  -0xc(%ebp)
801048f0:	e8 09 ff ff ff       	call   801047fe <fetchstr>
801048f5:	83 c4 10             	add    $0x10,%esp
}
801048f8:	c9                   	leave  
801048f9:	c3                   	ret    
    return -1;
801048fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048ff:	eb f7                	jmp    801048f8 <argstr+0x2a>

80104901 <syscall>:
[SYS_getpinfo]  sys_getpinfo,
};

void
syscall(void)
{
80104901:	55                   	push   %ebp
80104902:	89 e5                	mov    %esp,%ebp
80104904:	53                   	push   %ebx
80104905:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104908:	e8 c1 e8 ff ff       	call   801031ce <myproc>
8010490d:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010490f:	8b 40 18             	mov    0x18(%eax),%eax
80104912:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104915:	8d 50 ff             	lea    -0x1(%eax),%edx
80104918:	83 fa 18             	cmp    $0x18,%edx
8010491b:	77 18                	ja     80104935 <syscall+0x34>
8010491d:	8b 14 85 a0 75 10 80 	mov    -0x7fef8a60(,%eax,4),%edx
80104924:	85 d2                	test   %edx,%edx
80104926:	74 0d                	je     80104935 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104928:	ff d2                	call   *%edx
8010492a:	8b 53 18             	mov    0x18(%ebx),%edx
8010492d:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104930:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104933:	c9                   	leave  
80104934:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104935:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104938:	50                   	push   %eax
80104939:	52                   	push   %edx
8010493a:	ff 73 10             	pushl  0x10(%ebx)
8010493d:	68 71 75 10 80       	push   $0x80107571
80104942:	e8 c4 bc ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104947:	8b 43 18             	mov    0x18(%ebx),%eax
8010494a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104951:	83 c4 10             	add    $0x10,%esp
}
80104954:	eb da                	jmp    80104930 <syscall+0x2f>

80104956 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104956:	55                   	push   %ebp
80104957:	89 e5                	mov    %esp,%ebp
80104959:	56                   	push   %esi
8010495a:	53                   	push   %ebx
8010495b:	83 ec 18             	sub    $0x18,%esp
8010495e:	89 d6                	mov    %edx,%esi
80104960:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104962:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104965:	52                   	push   %edx
80104966:	50                   	push   %eax
80104967:	e8 d2 fe ff ff       	call   8010483e <argint>
8010496c:	83 c4 10             	add    $0x10,%esp
8010496f:	85 c0                	test   %eax,%eax
80104971:	78 2e                	js     801049a1 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104973:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104977:	77 2f                	ja     801049a8 <argfd+0x52>
80104979:	e8 50 e8 ff ff       	call   801031ce <myproc>
8010497e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104981:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104985:	85 c0                	test   %eax,%eax
80104987:	74 26                	je     801049af <argfd+0x59>
    return -1;
  if(pfd)
80104989:	85 f6                	test   %esi,%esi
8010498b:	74 02                	je     8010498f <argfd+0x39>
    *pfd = fd;
8010498d:	89 16                	mov    %edx,(%esi)
  if(pf)
8010498f:	85 db                	test   %ebx,%ebx
80104991:	74 23                	je     801049b6 <argfd+0x60>
    *pf = f;
80104993:	89 03                	mov    %eax,(%ebx)
  return 0;
80104995:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010499a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010499d:	5b                   	pop    %ebx
8010499e:	5e                   	pop    %esi
8010499f:	5d                   	pop    %ebp
801049a0:	c3                   	ret    
    return -1;
801049a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049a6:	eb f2                	jmp    8010499a <argfd+0x44>
    return -1;
801049a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049ad:	eb eb                	jmp    8010499a <argfd+0x44>
801049af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b4:	eb e4                	jmp    8010499a <argfd+0x44>
  return 0;
801049b6:	b8 00 00 00 00       	mov    $0x0,%eax
801049bb:	eb dd                	jmp    8010499a <argfd+0x44>

801049bd <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801049bd:	55                   	push   %ebp
801049be:	89 e5                	mov    %esp,%ebp
801049c0:	53                   	push   %ebx
801049c1:	83 ec 04             	sub    $0x4,%esp
801049c4:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801049c6:	e8 03 e8 ff ff       	call   801031ce <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801049cb:	ba 00 00 00 00       	mov    $0x0,%edx
801049d0:	83 fa 0f             	cmp    $0xf,%edx
801049d3:	7f 18                	jg     801049ed <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801049d5:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801049da:	74 05                	je     801049e1 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801049dc:	83 c2 01             	add    $0x1,%edx
801049df:	eb ef                	jmp    801049d0 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801049e1:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801049e5:	89 d0                	mov    %edx,%eax
801049e7:	83 c4 04             	add    $0x4,%esp
801049ea:	5b                   	pop    %ebx
801049eb:	5d                   	pop    %ebp
801049ec:	c3                   	ret    
  return -1;
801049ed:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801049f2:	eb f1                	jmp    801049e5 <fdalloc+0x28>

801049f4 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801049f4:	55                   	push   %ebp
801049f5:	89 e5                	mov    %esp,%ebp
801049f7:	56                   	push   %esi
801049f8:	53                   	push   %ebx
801049f9:	83 ec 10             	sub    $0x10,%esp
801049fc:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801049fe:	b8 20 00 00 00       	mov    $0x20,%eax
80104a03:	89 c6                	mov    %eax,%esi
80104a05:	39 43 58             	cmp    %eax,0x58(%ebx)
80104a08:	76 2e                	jbe    80104a38 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104a0a:	6a 10                	push   $0x10
80104a0c:	50                   	push   %eax
80104a0d:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104a10:	50                   	push   %eax
80104a11:	53                   	push   %ebx
80104a12:	e8 5c cd ff ff       	call   80101773 <readi>
80104a17:	83 c4 10             	add    $0x10,%esp
80104a1a:	83 f8 10             	cmp    $0x10,%eax
80104a1d:	75 0c                	jne    80104a2b <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104a1f:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104a24:	75 1e                	jne    80104a44 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104a26:	8d 46 10             	lea    0x10(%esi),%eax
80104a29:	eb d8                	jmp    80104a03 <isdirempty+0xf>
      panic("isdirempty: readi");
80104a2b:	83 ec 0c             	sub    $0xc,%esp
80104a2e:	68 08 76 10 80       	push   $0x80107608
80104a33:	e8 10 b9 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104a38:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104a3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104a40:	5b                   	pop    %ebx
80104a41:	5e                   	pop    %esi
80104a42:	5d                   	pop    %ebp
80104a43:	c3                   	ret    
      return 0;
80104a44:	b8 00 00 00 00       	mov    $0x0,%eax
80104a49:	eb f2                	jmp    80104a3d <isdirempty+0x49>

80104a4b <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104a4b:	55                   	push   %ebp
80104a4c:	89 e5                	mov    %esp,%ebp
80104a4e:	57                   	push   %edi
80104a4f:	56                   	push   %esi
80104a50:	53                   	push   %ebx
80104a51:	83 ec 44             	sub    $0x44,%esp
80104a54:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104a57:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104a5a:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104a5d:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104a60:	52                   	push   %edx
80104a61:	50                   	push   %eax
80104a62:	e8 92 d1 ff ff       	call   80101bf9 <nameiparent>
80104a67:	89 c6                	mov    %eax,%esi
80104a69:	83 c4 10             	add    $0x10,%esp
80104a6c:	85 c0                	test   %eax,%eax
80104a6e:	0f 84 3a 01 00 00    	je     80104bae <create+0x163>
    return 0;
  ilock(dp);
80104a74:	83 ec 0c             	sub    $0xc,%esp
80104a77:	50                   	push   %eax
80104a78:	e8 04 cb ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104a7d:	83 c4 0c             	add    $0xc,%esp
80104a80:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104a83:	50                   	push   %eax
80104a84:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104a87:	50                   	push   %eax
80104a88:	56                   	push   %esi
80104a89:	e8 22 cf ff ff       	call   801019b0 <dirlookup>
80104a8e:	89 c3                	mov    %eax,%ebx
80104a90:	83 c4 10             	add    $0x10,%esp
80104a93:	85 c0                	test   %eax,%eax
80104a95:	74 3f                	je     80104ad6 <create+0x8b>
    iunlockput(dp);
80104a97:	83 ec 0c             	sub    $0xc,%esp
80104a9a:	56                   	push   %esi
80104a9b:	e8 88 cc ff ff       	call   80101728 <iunlockput>
    ilock(ip);
80104aa0:	89 1c 24             	mov    %ebx,(%esp)
80104aa3:	e8 d9 ca ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104aa8:	83 c4 10             	add    $0x10,%esp
80104aab:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104ab0:	75 11                	jne    80104ac3 <create+0x78>
80104ab2:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104ab7:	75 0a                	jne    80104ac3 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104ab9:	89 d8                	mov    %ebx,%eax
80104abb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104abe:	5b                   	pop    %ebx
80104abf:	5e                   	pop    %esi
80104ac0:	5f                   	pop    %edi
80104ac1:	5d                   	pop    %ebp
80104ac2:	c3                   	ret    
    iunlockput(ip);
80104ac3:	83 ec 0c             	sub    $0xc,%esp
80104ac6:	53                   	push   %ebx
80104ac7:	e8 5c cc ff ff       	call   80101728 <iunlockput>
    return 0;
80104acc:	83 c4 10             	add    $0x10,%esp
80104acf:	bb 00 00 00 00       	mov    $0x0,%ebx
80104ad4:	eb e3                	jmp    80104ab9 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
80104ad6:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104ada:	83 ec 08             	sub    $0x8,%esp
80104add:	50                   	push   %eax
80104ade:	ff 36                	pushl  (%esi)
80104ae0:	e8 99 c8 ff ff       	call   8010137e <ialloc>
80104ae5:	89 c3                	mov    %eax,%ebx
80104ae7:	83 c4 10             	add    $0x10,%esp
80104aea:	85 c0                	test   %eax,%eax
80104aec:	74 55                	je     80104b43 <create+0xf8>
  ilock(ip);
80104aee:	83 ec 0c             	sub    $0xc,%esp
80104af1:	50                   	push   %eax
80104af2:	e8 8a ca ff ff       	call   80101581 <ilock>
  ip->major = major;
80104af7:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104afb:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104aff:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104b03:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104b09:	89 1c 24             	mov    %ebx,(%esp)
80104b0c:	e8 0f c9 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104b11:	83 c4 10             	add    $0x10,%esp
80104b14:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104b19:	74 35                	je     80104b50 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104b1b:	83 ec 04             	sub    $0x4,%esp
80104b1e:	ff 73 04             	pushl  0x4(%ebx)
80104b21:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104b24:	50                   	push   %eax
80104b25:	56                   	push   %esi
80104b26:	e8 05 d0 ff ff       	call   80101b30 <dirlink>
80104b2b:	83 c4 10             	add    $0x10,%esp
80104b2e:	85 c0                	test   %eax,%eax
80104b30:	78 6f                	js     80104ba1 <create+0x156>
  iunlockput(dp);
80104b32:	83 ec 0c             	sub    $0xc,%esp
80104b35:	56                   	push   %esi
80104b36:	e8 ed cb ff ff       	call   80101728 <iunlockput>
  return ip;
80104b3b:	83 c4 10             	add    $0x10,%esp
80104b3e:	e9 76 ff ff ff       	jmp    80104ab9 <create+0x6e>
    panic("create: ialloc");
80104b43:	83 ec 0c             	sub    $0xc,%esp
80104b46:	68 1a 76 10 80       	push   $0x8010761a
80104b4b:	e8 f8 b7 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104b50:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104b54:	83 c0 01             	add    $0x1,%eax
80104b57:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104b5b:	83 ec 0c             	sub    $0xc,%esp
80104b5e:	56                   	push   %esi
80104b5f:	e8 bc c8 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104b64:	83 c4 0c             	add    $0xc,%esp
80104b67:	ff 73 04             	pushl  0x4(%ebx)
80104b6a:	68 2a 76 10 80       	push   $0x8010762a
80104b6f:	53                   	push   %ebx
80104b70:	e8 bb cf ff ff       	call   80101b30 <dirlink>
80104b75:	83 c4 10             	add    $0x10,%esp
80104b78:	85 c0                	test   %eax,%eax
80104b7a:	78 18                	js     80104b94 <create+0x149>
80104b7c:	83 ec 04             	sub    $0x4,%esp
80104b7f:	ff 76 04             	pushl  0x4(%esi)
80104b82:	68 29 76 10 80       	push   $0x80107629
80104b87:	53                   	push   %ebx
80104b88:	e8 a3 cf ff ff       	call   80101b30 <dirlink>
80104b8d:	83 c4 10             	add    $0x10,%esp
80104b90:	85 c0                	test   %eax,%eax
80104b92:	79 87                	jns    80104b1b <create+0xd0>
      panic("create dots");
80104b94:	83 ec 0c             	sub    $0xc,%esp
80104b97:	68 2c 76 10 80       	push   $0x8010762c
80104b9c:	e8 a7 b7 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104ba1:	83 ec 0c             	sub    $0xc,%esp
80104ba4:	68 38 76 10 80       	push   $0x80107638
80104ba9:	e8 9a b7 ff ff       	call   80100348 <panic>
    return 0;
80104bae:	89 c3                	mov    %eax,%ebx
80104bb0:	e9 04 ff ff ff       	jmp    80104ab9 <create+0x6e>

80104bb5 <sys_dup>:
{
80104bb5:	55                   	push   %ebp
80104bb6:	89 e5                	mov    %esp,%ebp
80104bb8:	53                   	push   %ebx
80104bb9:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
80104bbc:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104bbf:	ba 00 00 00 00       	mov    $0x0,%edx
80104bc4:	b8 00 00 00 00       	mov    $0x0,%eax
80104bc9:	e8 88 fd ff ff       	call   80104956 <argfd>
80104bce:	85 c0                	test   %eax,%eax
80104bd0:	78 23                	js     80104bf5 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104bd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bd5:	e8 e3 fd ff ff       	call   801049bd <fdalloc>
80104bda:	89 c3                	mov    %eax,%ebx
80104bdc:	85 c0                	test   %eax,%eax
80104bde:	78 1c                	js     80104bfc <sys_dup+0x47>
  filedup(f);
80104be0:	83 ec 0c             	sub    $0xc,%esp
80104be3:	ff 75 f4             	pushl  -0xc(%ebp)
80104be6:	e8 a3 c0 ff ff       	call   80100c8e <filedup>
  return fd;
80104beb:	83 c4 10             	add    $0x10,%esp
}
80104bee:	89 d8                	mov    %ebx,%eax
80104bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104bf3:	c9                   	leave  
80104bf4:	c3                   	ret    
    return -1;
80104bf5:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104bfa:	eb f2                	jmp    80104bee <sys_dup+0x39>
    return -1;
80104bfc:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104c01:	eb eb                	jmp    80104bee <sys_dup+0x39>

80104c03 <sys_read>:
{
80104c03:	55                   	push   %ebp
80104c04:	89 e5                	mov    %esp,%ebp
80104c06:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104c09:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104c0c:	ba 00 00 00 00       	mov    $0x0,%edx
80104c11:	b8 00 00 00 00       	mov    $0x0,%eax
80104c16:	e8 3b fd ff ff       	call   80104956 <argfd>
80104c1b:	85 c0                	test   %eax,%eax
80104c1d:	78 43                	js     80104c62 <sys_read+0x5f>
80104c1f:	83 ec 08             	sub    $0x8,%esp
80104c22:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c25:	50                   	push   %eax
80104c26:	6a 02                	push   $0x2
80104c28:	e8 11 fc ff ff       	call   8010483e <argint>
80104c2d:	83 c4 10             	add    $0x10,%esp
80104c30:	85 c0                	test   %eax,%eax
80104c32:	78 35                	js     80104c69 <sys_read+0x66>
80104c34:	83 ec 04             	sub    $0x4,%esp
80104c37:	ff 75 f0             	pushl  -0x10(%ebp)
80104c3a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c3d:	50                   	push   %eax
80104c3e:	6a 01                	push   $0x1
80104c40:	e8 21 fc ff ff       	call   80104866 <argptr>
80104c45:	83 c4 10             	add    $0x10,%esp
80104c48:	85 c0                	test   %eax,%eax
80104c4a:	78 24                	js     80104c70 <sys_read+0x6d>
  return fileread(f, p, n);
80104c4c:	83 ec 04             	sub    $0x4,%esp
80104c4f:	ff 75 f0             	pushl  -0x10(%ebp)
80104c52:	ff 75 ec             	pushl  -0x14(%ebp)
80104c55:	ff 75 f4             	pushl  -0xc(%ebp)
80104c58:	e8 7a c1 ff ff       	call   80100dd7 <fileread>
80104c5d:	83 c4 10             	add    $0x10,%esp
}
80104c60:	c9                   	leave  
80104c61:	c3                   	ret    
    return -1;
80104c62:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c67:	eb f7                	jmp    80104c60 <sys_read+0x5d>
80104c69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6e:	eb f0                	jmp    80104c60 <sys_read+0x5d>
80104c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c75:	eb e9                	jmp    80104c60 <sys_read+0x5d>

80104c77 <sys_write>:
{
80104c77:	55                   	push   %ebp
80104c78:	89 e5                	mov    %esp,%ebp
80104c7a:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104c7d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104c80:	ba 00 00 00 00       	mov    $0x0,%edx
80104c85:	b8 00 00 00 00       	mov    $0x0,%eax
80104c8a:	e8 c7 fc ff ff       	call   80104956 <argfd>
80104c8f:	85 c0                	test   %eax,%eax
80104c91:	78 43                	js     80104cd6 <sys_write+0x5f>
80104c93:	83 ec 08             	sub    $0x8,%esp
80104c96:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c99:	50                   	push   %eax
80104c9a:	6a 02                	push   $0x2
80104c9c:	e8 9d fb ff ff       	call   8010483e <argint>
80104ca1:	83 c4 10             	add    $0x10,%esp
80104ca4:	85 c0                	test   %eax,%eax
80104ca6:	78 35                	js     80104cdd <sys_write+0x66>
80104ca8:	83 ec 04             	sub    $0x4,%esp
80104cab:	ff 75 f0             	pushl  -0x10(%ebp)
80104cae:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104cb1:	50                   	push   %eax
80104cb2:	6a 01                	push   $0x1
80104cb4:	e8 ad fb ff ff       	call   80104866 <argptr>
80104cb9:	83 c4 10             	add    $0x10,%esp
80104cbc:	85 c0                	test   %eax,%eax
80104cbe:	78 24                	js     80104ce4 <sys_write+0x6d>
  return filewrite(f, p, n);
80104cc0:	83 ec 04             	sub    $0x4,%esp
80104cc3:	ff 75 f0             	pushl  -0x10(%ebp)
80104cc6:	ff 75 ec             	pushl  -0x14(%ebp)
80104cc9:	ff 75 f4             	pushl  -0xc(%ebp)
80104ccc:	e8 8b c1 ff ff       	call   80100e5c <filewrite>
80104cd1:	83 c4 10             	add    $0x10,%esp
}
80104cd4:	c9                   	leave  
80104cd5:	c3                   	ret    
    return -1;
80104cd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cdb:	eb f7                	jmp    80104cd4 <sys_write+0x5d>
80104cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce2:	eb f0                	jmp    80104cd4 <sys_write+0x5d>
80104ce4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce9:	eb e9                	jmp    80104cd4 <sys_write+0x5d>

80104ceb <sys_close>:
{
80104ceb:	55                   	push   %ebp
80104cec:	89 e5                	mov    %esp,%ebp
80104cee:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104cf1:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104cf4:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104cf7:	b8 00 00 00 00       	mov    $0x0,%eax
80104cfc:	e8 55 fc ff ff       	call   80104956 <argfd>
80104d01:	85 c0                	test   %eax,%eax
80104d03:	78 25                	js     80104d2a <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104d05:	e8 c4 e4 ff ff       	call   801031ce <myproc>
80104d0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d0d:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104d14:	00 
  fileclose(f);
80104d15:	83 ec 0c             	sub    $0xc,%esp
80104d18:	ff 75 f0             	pushl  -0x10(%ebp)
80104d1b:	e8 b3 bf ff ff       	call   80100cd3 <fileclose>
  return 0;
80104d20:	83 c4 10             	add    $0x10,%esp
80104d23:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d28:	c9                   	leave  
80104d29:	c3                   	ret    
    return -1;
80104d2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2f:	eb f7                	jmp    80104d28 <sys_close+0x3d>

80104d31 <sys_fstat>:
{
80104d31:	55                   	push   %ebp
80104d32:	89 e5                	mov    %esp,%ebp
80104d34:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104d37:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104d3a:	ba 00 00 00 00       	mov    $0x0,%edx
80104d3f:	b8 00 00 00 00       	mov    $0x0,%eax
80104d44:	e8 0d fc ff ff       	call   80104956 <argfd>
80104d49:	85 c0                	test   %eax,%eax
80104d4b:	78 2a                	js     80104d77 <sys_fstat+0x46>
80104d4d:	83 ec 04             	sub    $0x4,%esp
80104d50:	6a 14                	push   $0x14
80104d52:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d55:	50                   	push   %eax
80104d56:	6a 01                	push   $0x1
80104d58:	e8 09 fb ff ff       	call   80104866 <argptr>
80104d5d:	83 c4 10             	add    $0x10,%esp
80104d60:	85 c0                	test   %eax,%eax
80104d62:	78 1a                	js     80104d7e <sys_fstat+0x4d>
  return filestat(f, st);
80104d64:	83 ec 08             	sub    $0x8,%esp
80104d67:	ff 75 f0             	pushl  -0x10(%ebp)
80104d6a:	ff 75 f4             	pushl  -0xc(%ebp)
80104d6d:	e8 1e c0 ff ff       	call   80100d90 <filestat>
80104d72:	83 c4 10             	add    $0x10,%esp
}
80104d75:	c9                   	leave  
80104d76:	c3                   	ret    
    return -1;
80104d77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d7c:	eb f7                	jmp    80104d75 <sys_fstat+0x44>
80104d7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d83:	eb f0                	jmp    80104d75 <sys_fstat+0x44>

80104d85 <sys_link>:
{
80104d85:	55                   	push   %ebp
80104d86:	89 e5                	mov    %esp,%ebp
80104d88:	56                   	push   %esi
80104d89:	53                   	push   %ebx
80104d8a:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104d8d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104d90:	50                   	push   %eax
80104d91:	6a 00                	push   $0x0
80104d93:	e8 36 fb ff ff       	call   801048ce <argstr>
80104d98:	83 c4 10             	add    $0x10,%esp
80104d9b:	85 c0                	test   %eax,%eax
80104d9d:	0f 88 32 01 00 00    	js     80104ed5 <sys_link+0x150>
80104da3:	83 ec 08             	sub    $0x8,%esp
80104da6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104da9:	50                   	push   %eax
80104daa:	6a 01                	push   $0x1
80104dac:	e8 1d fb ff ff       	call   801048ce <argstr>
80104db1:	83 c4 10             	add    $0x10,%esp
80104db4:	85 c0                	test   %eax,%eax
80104db6:	0f 88 20 01 00 00    	js     80104edc <sys_link+0x157>
  begin_op();
80104dbc:	e8 ed d9 ff ff       	call   801027ae <begin_op>
  if((ip = namei(old)) == 0){
80104dc1:	83 ec 0c             	sub    $0xc,%esp
80104dc4:	ff 75 e0             	pushl  -0x20(%ebp)
80104dc7:	e8 15 ce ff ff       	call   80101be1 <namei>
80104dcc:	89 c3                	mov    %eax,%ebx
80104dce:	83 c4 10             	add    $0x10,%esp
80104dd1:	85 c0                	test   %eax,%eax
80104dd3:	0f 84 99 00 00 00    	je     80104e72 <sys_link+0xed>
  ilock(ip);
80104dd9:	83 ec 0c             	sub    $0xc,%esp
80104ddc:	50                   	push   %eax
80104ddd:	e8 9f c7 ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
80104de2:	83 c4 10             	add    $0x10,%esp
80104de5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104dea:	0f 84 8e 00 00 00    	je     80104e7e <sys_link+0xf9>
  ip->nlink++;
80104df0:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104df4:	83 c0 01             	add    $0x1,%eax
80104df7:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104dfb:	83 ec 0c             	sub    $0xc,%esp
80104dfe:	53                   	push   %ebx
80104dff:	e8 1c c6 ff ff       	call   80101420 <iupdate>
  iunlock(ip);
80104e04:	89 1c 24             	mov    %ebx,(%esp)
80104e07:	e8 37 c8 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104e0c:	83 c4 08             	add    $0x8,%esp
80104e0f:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104e12:	50                   	push   %eax
80104e13:	ff 75 e4             	pushl  -0x1c(%ebp)
80104e16:	e8 de cd ff ff       	call   80101bf9 <nameiparent>
80104e1b:	89 c6                	mov    %eax,%esi
80104e1d:	83 c4 10             	add    $0x10,%esp
80104e20:	85 c0                	test   %eax,%eax
80104e22:	74 7e                	je     80104ea2 <sys_link+0x11d>
  ilock(dp);
80104e24:	83 ec 0c             	sub    $0xc,%esp
80104e27:	50                   	push   %eax
80104e28:	e8 54 c7 ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104e2d:	83 c4 10             	add    $0x10,%esp
80104e30:	8b 03                	mov    (%ebx),%eax
80104e32:	39 06                	cmp    %eax,(%esi)
80104e34:	75 60                	jne    80104e96 <sys_link+0x111>
80104e36:	83 ec 04             	sub    $0x4,%esp
80104e39:	ff 73 04             	pushl  0x4(%ebx)
80104e3c:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104e3f:	50                   	push   %eax
80104e40:	56                   	push   %esi
80104e41:	e8 ea cc ff ff       	call   80101b30 <dirlink>
80104e46:	83 c4 10             	add    $0x10,%esp
80104e49:	85 c0                	test   %eax,%eax
80104e4b:	78 49                	js     80104e96 <sys_link+0x111>
  iunlockput(dp);
80104e4d:	83 ec 0c             	sub    $0xc,%esp
80104e50:	56                   	push   %esi
80104e51:	e8 d2 c8 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104e56:	89 1c 24             	mov    %ebx,(%esp)
80104e59:	e8 2a c8 ff ff       	call   80101688 <iput>
  end_op();
80104e5e:	e8 c5 d9 ff ff       	call   80102828 <end_op>
  return 0;
80104e63:	83 c4 10             	add    $0x10,%esp
80104e66:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104e6e:	5b                   	pop    %ebx
80104e6f:	5e                   	pop    %esi
80104e70:	5d                   	pop    %ebp
80104e71:	c3                   	ret    
    end_op();
80104e72:	e8 b1 d9 ff ff       	call   80102828 <end_op>
    return -1;
80104e77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e7c:	eb ed                	jmp    80104e6b <sys_link+0xe6>
    iunlockput(ip);
80104e7e:	83 ec 0c             	sub    $0xc,%esp
80104e81:	53                   	push   %ebx
80104e82:	e8 a1 c8 ff ff       	call   80101728 <iunlockput>
    end_op();
80104e87:	e8 9c d9 ff ff       	call   80102828 <end_op>
    return -1;
80104e8c:	83 c4 10             	add    $0x10,%esp
80104e8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e94:	eb d5                	jmp    80104e6b <sys_link+0xe6>
    iunlockput(dp);
80104e96:	83 ec 0c             	sub    $0xc,%esp
80104e99:	56                   	push   %esi
80104e9a:	e8 89 c8 ff ff       	call   80101728 <iunlockput>
    goto bad;
80104e9f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104ea2:	83 ec 0c             	sub    $0xc,%esp
80104ea5:	53                   	push   %ebx
80104ea6:	e8 d6 c6 ff ff       	call   80101581 <ilock>
  ip->nlink--;
80104eab:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104eaf:	83 e8 01             	sub    $0x1,%eax
80104eb2:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104eb6:	89 1c 24             	mov    %ebx,(%esp)
80104eb9:	e8 62 c5 ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104ebe:	89 1c 24             	mov    %ebx,(%esp)
80104ec1:	e8 62 c8 ff ff       	call   80101728 <iunlockput>
  end_op();
80104ec6:	e8 5d d9 ff ff       	call   80102828 <end_op>
  return -1;
80104ecb:	83 c4 10             	add    $0x10,%esp
80104ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed3:	eb 96                	jmp    80104e6b <sys_link+0xe6>
    return -1;
80104ed5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104eda:	eb 8f                	jmp    80104e6b <sys_link+0xe6>
80104edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee1:	eb 88                	jmp    80104e6b <sys_link+0xe6>

80104ee3 <sys_unlink>:
{
80104ee3:	55                   	push   %ebp
80104ee4:	89 e5                	mov    %esp,%ebp
80104ee6:	57                   	push   %edi
80104ee7:	56                   	push   %esi
80104ee8:	53                   	push   %ebx
80104ee9:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104eec:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104eef:	50                   	push   %eax
80104ef0:	6a 00                	push   $0x0
80104ef2:	e8 d7 f9 ff ff       	call   801048ce <argstr>
80104ef7:	83 c4 10             	add    $0x10,%esp
80104efa:	85 c0                	test   %eax,%eax
80104efc:	0f 88 83 01 00 00    	js     80105085 <sys_unlink+0x1a2>
  begin_op();
80104f02:	e8 a7 d8 ff ff       	call   801027ae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104f07:	83 ec 08             	sub    $0x8,%esp
80104f0a:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104f0d:	50                   	push   %eax
80104f0e:	ff 75 c4             	pushl  -0x3c(%ebp)
80104f11:	e8 e3 cc ff ff       	call   80101bf9 <nameiparent>
80104f16:	89 c6                	mov    %eax,%esi
80104f18:	83 c4 10             	add    $0x10,%esp
80104f1b:	85 c0                	test   %eax,%eax
80104f1d:	0f 84 ed 00 00 00    	je     80105010 <sys_unlink+0x12d>
  ilock(dp);
80104f23:	83 ec 0c             	sub    $0xc,%esp
80104f26:	50                   	push   %eax
80104f27:	e8 55 c6 ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104f2c:	83 c4 08             	add    $0x8,%esp
80104f2f:	68 2a 76 10 80       	push   $0x8010762a
80104f34:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104f37:	50                   	push   %eax
80104f38:	e8 5e ca ff ff       	call   8010199b <namecmp>
80104f3d:	83 c4 10             	add    $0x10,%esp
80104f40:	85 c0                	test   %eax,%eax
80104f42:	0f 84 fc 00 00 00    	je     80105044 <sys_unlink+0x161>
80104f48:	83 ec 08             	sub    $0x8,%esp
80104f4b:	68 29 76 10 80       	push   $0x80107629
80104f50:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104f53:	50                   	push   %eax
80104f54:	e8 42 ca ff ff       	call   8010199b <namecmp>
80104f59:	83 c4 10             	add    $0x10,%esp
80104f5c:	85 c0                	test   %eax,%eax
80104f5e:	0f 84 e0 00 00 00    	je     80105044 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104f64:	83 ec 04             	sub    $0x4,%esp
80104f67:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104f6a:	50                   	push   %eax
80104f6b:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104f6e:	50                   	push   %eax
80104f6f:	56                   	push   %esi
80104f70:	e8 3b ca ff ff       	call   801019b0 <dirlookup>
80104f75:	89 c3                	mov    %eax,%ebx
80104f77:	83 c4 10             	add    $0x10,%esp
80104f7a:	85 c0                	test   %eax,%eax
80104f7c:	0f 84 c2 00 00 00    	je     80105044 <sys_unlink+0x161>
  ilock(ip);
80104f82:	83 ec 0c             	sub    $0xc,%esp
80104f85:	50                   	push   %eax
80104f86:	e8 f6 c5 ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
80104f8b:	83 c4 10             	add    $0x10,%esp
80104f8e:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104f93:	0f 8e 83 00 00 00    	jle    8010501c <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104f99:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104f9e:	0f 84 85 00 00 00    	je     80105029 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104fa4:	83 ec 04             	sub    $0x4,%esp
80104fa7:	6a 10                	push   $0x10
80104fa9:	6a 00                	push   $0x0
80104fab:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104fae:	57                   	push   %edi
80104faf:	e8 3f f6 ff ff       	call   801045f3 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104fb4:	6a 10                	push   $0x10
80104fb6:	ff 75 c0             	pushl  -0x40(%ebp)
80104fb9:	57                   	push   %edi
80104fba:	56                   	push   %esi
80104fbb:	e8 b0 c8 ff ff       	call   80101870 <writei>
80104fc0:	83 c4 20             	add    $0x20,%esp
80104fc3:	83 f8 10             	cmp    $0x10,%eax
80104fc6:	0f 85 90 00 00 00    	jne    8010505c <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104fcc:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104fd1:	0f 84 92 00 00 00    	je     80105069 <sys_unlink+0x186>
  iunlockput(dp);
80104fd7:	83 ec 0c             	sub    $0xc,%esp
80104fda:	56                   	push   %esi
80104fdb:	e8 48 c7 ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
80104fe0:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104fe4:	83 e8 01             	sub    $0x1,%eax
80104fe7:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104feb:	89 1c 24             	mov    %ebx,(%esp)
80104fee:	e8 2d c4 ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104ff3:	89 1c 24             	mov    %ebx,(%esp)
80104ff6:	e8 2d c7 ff ff       	call   80101728 <iunlockput>
  end_op();
80104ffb:	e8 28 d8 ff ff       	call   80102828 <end_op>
  return 0;
80105000:	83 c4 10             	add    $0x10,%esp
80105003:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105008:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010500b:	5b                   	pop    %ebx
8010500c:	5e                   	pop    %esi
8010500d:	5f                   	pop    %edi
8010500e:	5d                   	pop    %ebp
8010500f:	c3                   	ret    
    end_op();
80105010:	e8 13 d8 ff ff       	call   80102828 <end_op>
    return -1;
80105015:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010501a:	eb ec                	jmp    80105008 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
8010501c:	83 ec 0c             	sub    $0xc,%esp
8010501f:	68 48 76 10 80       	push   $0x80107648
80105024:	e8 1f b3 ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105029:	89 d8                	mov    %ebx,%eax
8010502b:	e8 c4 f9 ff ff       	call   801049f4 <isdirempty>
80105030:	85 c0                	test   %eax,%eax
80105032:	0f 85 6c ff ff ff    	jne    80104fa4 <sys_unlink+0xc1>
    iunlockput(ip);
80105038:	83 ec 0c             	sub    $0xc,%esp
8010503b:	53                   	push   %ebx
8010503c:	e8 e7 c6 ff ff       	call   80101728 <iunlockput>
    goto bad;
80105041:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80105044:	83 ec 0c             	sub    $0xc,%esp
80105047:	56                   	push   %esi
80105048:	e8 db c6 ff ff       	call   80101728 <iunlockput>
  end_op();
8010504d:	e8 d6 d7 ff ff       	call   80102828 <end_op>
  return -1;
80105052:	83 c4 10             	add    $0x10,%esp
80105055:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010505a:	eb ac                	jmp    80105008 <sys_unlink+0x125>
    panic("unlink: writei");
8010505c:	83 ec 0c             	sub    $0xc,%esp
8010505f:	68 5a 76 10 80       	push   $0x8010765a
80105064:	e8 df b2 ff ff       	call   80100348 <panic>
    dp->nlink--;
80105069:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010506d:	83 e8 01             	sub    $0x1,%eax
80105070:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80105074:	83 ec 0c             	sub    $0xc,%esp
80105077:	56                   	push   %esi
80105078:	e8 a3 c3 ff ff       	call   80101420 <iupdate>
8010507d:	83 c4 10             	add    $0x10,%esp
80105080:	e9 52 ff ff ff       	jmp    80104fd7 <sys_unlink+0xf4>
    return -1;
80105085:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010508a:	e9 79 ff ff ff       	jmp    80105008 <sys_unlink+0x125>

8010508f <sys_open>:

int
sys_open(void)
{
8010508f:	55                   	push   %ebp
80105090:	89 e5                	mov    %esp,%ebp
80105092:	57                   	push   %edi
80105093:	56                   	push   %esi
80105094:	53                   	push   %ebx
80105095:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105098:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010509b:	50                   	push   %eax
8010509c:	6a 00                	push   $0x0
8010509e:	e8 2b f8 ff ff       	call   801048ce <argstr>
801050a3:	83 c4 10             	add    $0x10,%esp
801050a6:	85 c0                	test   %eax,%eax
801050a8:	0f 88 30 01 00 00    	js     801051de <sys_open+0x14f>
801050ae:	83 ec 08             	sub    $0x8,%esp
801050b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801050b4:	50                   	push   %eax
801050b5:	6a 01                	push   $0x1
801050b7:	e8 82 f7 ff ff       	call   8010483e <argint>
801050bc:	83 c4 10             	add    $0x10,%esp
801050bf:	85 c0                	test   %eax,%eax
801050c1:	0f 88 21 01 00 00    	js     801051e8 <sys_open+0x159>
    return -1;

  begin_op();
801050c7:	e8 e2 d6 ff ff       	call   801027ae <begin_op>

  if(omode & O_CREATE){
801050cc:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801050d0:	0f 84 84 00 00 00    	je     8010515a <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801050d6:	83 ec 0c             	sub    $0xc,%esp
801050d9:	6a 00                	push   $0x0
801050db:	b9 00 00 00 00       	mov    $0x0,%ecx
801050e0:	ba 02 00 00 00       	mov    $0x2,%edx
801050e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801050e8:	e8 5e f9 ff ff       	call   80104a4b <create>
801050ed:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801050ef:	83 c4 10             	add    $0x10,%esp
801050f2:	85 c0                	test   %eax,%eax
801050f4:	74 58                	je     8010514e <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801050f6:	e8 32 bb ff ff       	call   80100c2d <filealloc>
801050fb:	89 c3                	mov    %eax,%ebx
801050fd:	85 c0                	test   %eax,%eax
801050ff:	0f 84 ae 00 00 00    	je     801051b3 <sys_open+0x124>
80105105:	e8 b3 f8 ff ff       	call   801049bd <fdalloc>
8010510a:	89 c7                	mov    %eax,%edi
8010510c:	85 c0                	test   %eax,%eax
8010510e:	0f 88 9f 00 00 00    	js     801051b3 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105114:	83 ec 0c             	sub    $0xc,%esp
80105117:	56                   	push   %esi
80105118:	e8 26 c5 ff ff       	call   80101643 <iunlock>
  end_op();
8010511d:	e8 06 d7 ff ff       	call   80102828 <end_op>

  f->type = FD_INODE;
80105122:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80105128:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
8010512b:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80105132:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105135:	83 c4 10             	add    $0x10,%esp
80105138:	a8 01                	test   $0x1,%al
8010513a:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
8010513e:	a8 03                	test   $0x3,%al
80105140:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80105144:	89 f8                	mov    %edi,%eax
80105146:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105149:	5b                   	pop    %ebx
8010514a:	5e                   	pop    %esi
8010514b:	5f                   	pop    %edi
8010514c:	5d                   	pop    %ebp
8010514d:	c3                   	ret    
      end_op();
8010514e:	e8 d5 d6 ff ff       	call   80102828 <end_op>
      return -1;
80105153:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80105158:	eb ea                	jmp    80105144 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
8010515a:	83 ec 0c             	sub    $0xc,%esp
8010515d:	ff 75 e4             	pushl  -0x1c(%ebp)
80105160:	e8 7c ca ff ff       	call   80101be1 <namei>
80105165:	89 c6                	mov    %eax,%esi
80105167:	83 c4 10             	add    $0x10,%esp
8010516a:	85 c0                	test   %eax,%eax
8010516c:	74 39                	je     801051a7 <sys_open+0x118>
    ilock(ip);
8010516e:	83 ec 0c             	sub    $0xc,%esp
80105171:	50                   	push   %eax
80105172:	e8 0a c4 ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105177:	83 c4 10             	add    $0x10,%esp
8010517a:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010517f:	0f 85 71 ff ff ff    	jne    801050f6 <sys_open+0x67>
80105185:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80105189:	0f 84 67 ff ff ff    	je     801050f6 <sys_open+0x67>
      iunlockput(ip);
8010518f:	83 ec 0c             	sub    $0xc,%esp
80105192:	56                   	push   %esi
80105193:	e8 90 c5 ff ff       	call   80101728 <iunlockput>
      end_op();
80105198:	e8 8b d6 ff ff       	call   80102828 <end_op>
      return -1;
8010519d:	83 c4 10             	add    $0x10,%esp
801051a0:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801051a5:	eb 9d                	jmp    80105144 <sys_open+0xb5>
      end_op();
801051a7:	e8 7c d6 ff ff       	call   80102828 <end_op>
      return -1;
801051ac:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801051b1:	eb 91                	jmp    80105144 <sys_open+0xb5>
    if(f)
801051b3:	85 db                	test   %ebx,%ebx
801051b5:	74 0c                	je     801051c3 <sys_open+0x134>
      fileclose(f);
801051b7:	83 ec 0c             	sub    $0xc,%esp
801051ba:	53                   	push   %ebx
801051bb:	e8 13 bb ff ff       	call   80100cd3 <fileclose>
801051c0:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801051c3:	83 ec 0c             	sub    $0xc,%esp
801051c6:	56                   	push   %esi
801051c7:	e8 5c c5 ff ff       	call   80101728 <iunlockput>
    end_op();
801051cc:	e8 57 d6 ff ff       	call   80102828 <end_op>
    return -1;
801051d1:	83 c4 10             	add    $0x10,%esp
801051d4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801051d9:	e9 66 ff ff ff       	jmp    80105144 <sys_open+0xb5>
    return -1;
801051de:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801051e3:	e9 5c ff ff ff       	jmp    80105144 <sys_open+0xb5>
801051e8:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801051ed:	e9 52 ff ff ff       	jmp    80105144 <sys_open+0xb5>

801051f2 <sys_mkdir>:

int
sys_mkdir(void)
{
801051f2:	55                   	push   %ebp
801051f3:	89 e5                	mov    %esp,%ebp
801051f5:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801051f8:	e8 b1 d5 ff ff       	call   801027ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801051fd:	83 ec 08             	sub    $0x8,%esp
80105200:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105203:	50                   	push   %eax
80105204:	6a 00                	push   $0x0
80105206:	e8 c3 f6 ff ff       	call   801048ce <argstr>
8010520b:	83 c4 10             	add    $0x10,%esp
8010520e:	85 c0                	test   %eax,%eax
80105210:	78 36                	js     80105248 <sys_mkdir+0x56>
80105212:	83 ec 0c             	sub    $0xc,%esp
80105215:	6a 00                	push   $0x0
80105217:	b9 00 00 00 00       	mov    $0x0,%ecx
8010521c:	ba 01 00 00 00       	mov    $0x1,%edx
80105221:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105224:	e8 22 f8 ff ff       	call   80104a4b <create>
80105229:	83 c4 10             	add    $0x10,%esp
8010522c:	85 c0                	test   %eax,%eax
8010522e:	74 18                	je     80105248 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80105230:	83 ec 0c             	sub    $0xc,%esp
80105233:	50                   	push   %eax
80105234:	e8 ef c4 ff ff       	call   80101728 <iunlockput>
  end_op();
80105239:	e8 ea d5 ff ff       	call   80102828 <end_op>
  return 0;
8010523e:	83 c4 10             	add    $0x10,%esp
80105241:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105246:	c9                   	leave  
80105247:	c3                   	ret    
    end_op();
80105248:	e8 db d5 ff ff       	call   80102828 <end_op>
    return -1;
8010524d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105252:	eb f2                	jmp    80105246 <sys_mkdir+0x54>

80105254 <sys_mknod>:

int
sys_mknod(void)
{
80105254:	55                   	push   %ebp
80105255:	89 e5                	mov    %esp,%ebp
80105257:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010525a:	e8 4f d5 ff ff       	call   801027ae <begin_op>
  if((argstr(0, &path)) < 0 ||
8010525f:	83 ec 08             	sub    $0x8,%esp
80105262:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105265:	50                   	push   %eax
80105266:	6a 00                	push   $0x0
80105268:	e8 61 f6 ff ff       	call   801048ce <argstr>
8010526d:	83 c4 10             	add    $0x10,%esp
80105270:	85 c0                	test   %eax,%eax
80105272:	78 62                	js     801052d6 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80105274:	83 ec 08             	sub    $0x8,%esp
80105277:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010527a:	50                   	push   %eax
8010527b:	6a 01                	push   $0x1
8010527d:	e8 bc f5 ff ff       	call   8010483e <argint>
  if((argstr(0, &path)) < 0 ||
80105282:	83 c4 10             	add    $0x10,%esp
80105285:	85 c0                	test   %eax,%eax
80105287:	78 4d                	js     801052d6 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80105289:	83 ec 08             	sub    $0x8,%esp
8010528c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010528f:	50                   	push   %eax
80105290:	6a 02                	push   $0x2
80105292:	e8 a7 f5 ff ff       	call   8010483e <argint>
     argint(1, &major) < 0 ||
80105297:	83 c4 10             	add    $0x10,%esp
8010529a:	85 c0                	test   %eax,%eax
8010529c:	78 38                	js     801052d6 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010529e:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
801052a2:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
801052a6:	83 ec 0c             	sub    $0xc,%esp
801052a9:	50                   	push   %eax
801052aa:	ba 03 00 00 00       	mov    $0x3,%edx
801052af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052b2:	e8 94 f7 ff ff       	call   80104a4b <create>
801052b7:	83 c4 10             	add    $0x10,%esp
801052ba:	85 c0                	test   %eax,%eax
801052bc:	74 18                	je     801052d6 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
801052be:	83 ec 0c             	sub    $0xc,%esp
801052c1:	50                   	push   %eax
801052c2:	e8 61 c4 ff ff       	call   80101728 <iunlockput>
  end_op();
801052c7:	e8 5c d5 ff ff       	call   80102828 <end_op>
  return 0;
801052cc:	83 c4 10             	add    $0x10,%esp
801052cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052d4:	c9                   	leave  
801052d5:	c3                   	ret    
    end_op();
801052d6:	e8 4d d5 ff ff       	call   80102828 <end_op>
    return -1;
801052db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e0:	eb f2                	jmp    801052d4 <sys_mknod+0x80>

801052e2 <sys_chdir>:

int
sys_chdir(void)
{
801052e2:	55                   	push   %ebp
801052e3:	89 e5                	mov    %esp,%ebp
801052e5:	56                   	push   %esi
801052e6:	53                   	push   %ebx
801052e7:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801052ea:	e8 df de ff ff       	call   801031ce <myproc>
801052ef:	89 c6                	mov    %eax,%esi
  
  begin_op();
801052f1:	e8 b8 d4 ff ff       	call   801027ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801052f6:	83 ec 08             	sub    $0x8,%esp
801052f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052fc:	50                   	push   %eax
801052fd:	6a 00                	push   $0x0
801052ff:	e8 ca f5 ff ff       	call   801048ce <argstr>
80105304:	83 c4 10             	add    $0x10,%esp
80105307:	85 c0                	test   %eax,%eax
80105309:	78 52                	js     8010535d <sys_chdir+0x7b>
8010530b:	83 ec 0c             	sub    $0xc,%esp
8010530e:	ff 75 f4             	pushl  -0xc(%ebp)
80105311:	e8 cb c8 ff ff       	call   80101be1 <namei>
80105316:	89 c3                	mov    %eax,%ebx
80105318:	83 c4 10             	add    $0x10,%esp
8010531b:	85 c0                	test   %eax,%eax
8010531d:	74 3e                	je     8010535d <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
8010531f:	83 ec 0c             	sub    $0xc,%esp
80105322:	50                   	push   %eax
80105323:	e8 59 c2 ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80105328:	83 c4 10             	add    $0x10,%esp
8010532b:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105330:	75 37                	jne    80105369 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105332:	83 ec 0c             	sub    $0xc,%esp
80105335:	53                   	push   %ebx
80105336:	e8 08 c3 ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
8010533b:	83 c4 04             	add    $0x4,%esp
8010533e:	ff 76 68             	pushl  0x68(%esi)
80105341:	e8 42 c3 ff ff       	call   80101688 <iput>
  end_op();
80105346:	e8 dd d4 ff ff       	call   80102828 <end_op>
  curproc->cwd = ip;
8010534b:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010534e:	83 c4 10             	add    $0x10,%esp
80105351:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105356:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105359:	5b                   	pop    %ebx
8010535a:	5e                   	pop    %esi
8010535b:	5d                   	pop    %ebp
8010535c:	c3                   	ret    
    end_op();
8010535d:	e8 c6 d4 ff ff       	call   80102828 <end_op>
    return -1;
80105362:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105367:	eb ed                	jmp    80105356 <sys_chdir+0x74>
    iunlockput(ip);
80105369:	83 ec 0c             	sub    $0xc,%esp
8010536c:	53                   	push   %ebx
8010536d:	e8 b6 c3 ff ff       	call   80101728 <iunlockput>
    end_op();
80105372:	e8 b1 d4 ff ff       	call   80102828 <end_op>
    return -1;
80105377:	83 c4 10             	add    $0x10,%esp
8010537a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537f:	eb d5                	jmp    80105356 <sys_chdir+0x74>

80105381 <sys_exec>:

int
sys_exec(void)
{
80105381:	55                   	push   %ebp
80105382:	89 e5                	mov    %esp,%ebp
80105384:	53                   	push   %ebx
80105385:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010538b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010538e:	50                   	push   %eax
8010538f:	6a 00                	push   $0x0
80105391:	e8 38 f5 ff ff       	call   801048ce <argstr>
80105396:	83 c4 10             	add    $0x10,%esp
80105399:	85 c0                	test   %eax,%eax
8010539b:	0f 88 a8 00 00 00    	js     80105449 <sys_exec+0xc8>
801053a1:	83 ec 08             	sub    $0x8,%esp
801053a4:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801053aa:	50                   	push   %eax
801053ab:	6a 01                	push   $0x1
801053ad:	e8 8c f4 ff ff       	call   8010483e <argint>
801053b2:	83 c4 10             	add    $0x10,%esp
801053b5:	85 c0                	test   %eax,%eax
801053b7:	0f 88 93 00 00 00    	js     80105450 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
801053bd:	83 ec 04             	sub    $0x4,%esp
801053c0:	68 80 00 00 00       	push   $0x80
801053c5:	6a 00                	push   $0x0
801053c7:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801053cd:	50                   	push   %eax
801053ce:	e8 20 f2 ff ff       	call   801045f3 <memset>
801053d3:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801053d6:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
801053db:	83 fb 1f             	cmp    $0x1f,%ebx
801053de:	77 77                	ja     80105457 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801053e0:	83 ec 08             	sub    $0x8,%esp
801053e3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801053e9:	50                   	push   %eax
801053ea:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
801053f0:	8d 04 98             	lea    (%eax,%ebx,4),%eax
801053f3:	50                   	push   %eax
801053f4:	e8 c9 f3 ff ff       	call   801047c2 <fetchint>
801053f9:	83 c4 10             	add    $0x10,%esp
801053fc:	85 c0                	test   %eax,%eax
801053fe:	78 5e                	js     8010545e <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80105400:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105406:	85 c0                	test   %eax,%eax
80105408:	74 1d                	je     80105427 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010540a:	83 ec 08             	sub    $0x8,%esp
8010540d:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80105414:	52                   	push   %edx
80105415:	50                   	push   %eax
80105416:	e8 e3 f3 ff ff       	call   801047fe <fetchstr>
8010541b:	83 c4 10             	add    $0x10,%esp
8010541e:	85 c0                	test   %eax,%eax
80105420:	78 46                	js     80105468 <sys_exec+0xe7>
  for(i=0;; i++){
80105422:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105425:	eb b4                	jmp    801053db <sys_exec+0x5a>
      argv[i] = 0;
80105427:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
8010542e:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80105432:	83 ec 08             	sub    $0x8,%esp
80105435:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
8010543b:	50                   	push   %eax
8010543c:	ff 75 f4             	pushl  -0xc(%ebp)
8010543f:	e8 8e b4 ff ff       	call   801008d2 <exec>
80105444:	83 c4 10             	add    $0x10,%esp
80105447:	eb 1a                	jmp    80105463 <sys_exec+0xe2>
    return -1;
80105449:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010544e:	eb 13                	jmp    80105463 <sys_exec+0xe2>
80105450:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105455:	eb 0c                	jmp    80105463 <sys_exec+0xe2>
      return -1;
80105457:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010545c:	eb 05                	jmp    80105463 <sys_exec+0xe2>
      return -1;
8010545e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105466:	c9                   	leave  
80105467:	c3                   	ret    
      return -1;
80105468:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010546d:	eb f4                	jmp    80105463 <sys_exec+0xe2>

8010546f <sys_pipe>:

int
sys_pipe(void)
{
8010546f:	55                   	push   %ebp
80105470:	89 e5                	mov    %esp,%ebp
80105472:	53                   	push   %ebx
80105473:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105476:	6a 08                	push   $0x8
80105478:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010547b:	50                   	push   %eax
8010547c:	6a 00                	push   $0x0
8010547e:	e8 e3 f3 ff ff       	call   80104866 <argptr>
80105483:	83 c4 10             	add    $0x10,%esp
80105486:	85 c0                	test   %eax,%eax
80105488:	78 77                	js     80105501 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
8010548a:	83 ec 08             	sub    $0x8,%esp
8010548d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105490:	50                   	push   %eax
80105491:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105494:	50                   	push   %eax
80105495:	e8 9b d8 ff ff       	call   80102d35 <pipealloc>
8010549a:	83 c4 10             	add    $0x10,%esp
8010549d:	85 c0                	test   %eax,%eax
8010549f:	78 67                	js     80105508 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
801054a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054a4:	e8 14 f5 ff ff       	call   801049bd <fdalloc>
801054a9:	89 c3                	mov    %eax,%ebx
801054ab:	85 c0                	test   %eax,%eax
801054ad:	78 21                	js     801054d0 <sys_pipe+0x61>
801054af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801054b2:	e8 06 f5 ff ff       	call   801049bd <fdalloc>
801054b7:	85 c0                	test   %eax,%eax
801054b9:	78 15                	js     801054d0 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
801054bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054be:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
801054c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801054c3:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
801054c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801054ce:	c9                   	leave  
801054cf:	c3                   	ret    
    if(fd0 >= 0)
801054d0:	85 db                	test   %ebx,%ebx
801054d2:	78 0d                	js     801054e1 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
801054d4:	e8 f5 dc ff ff       	call   801031ce <myproc>
801054d9:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
801054e0:	00 
    fileclose(rf);
801054e1:	83 ec 0c             	sub    $0xc,%esp
801054e4:	ff 75 f0             	pushl  -0x10(%ebp)
801054e7:	e8 e7 b7 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
801054ec:	83 c4 04             	add    $0x4,%esp
801054ef:	ff 75 ec             	pushl  -0x14(%ebp)
801054f2:	e8 dc b7 ff ff       	call   80100cd3 <fileclose>
    return -1;
801054f7:	83 c4 10             	add    $0x10,%esp
801054fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801054ff:	eb ca                	jmp    801054cb <sys_pipe+0x5c>
    return -1;
80105501:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105506:	eb c3                	jmp    801054cb <sys_pipe+0x5c>
    return -1;
80105508:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010550d:	eb bc                	jmp    801054cb <sys_pipe+0x5c>

8010550f <sys_fork>:
// #include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
8010550f:	55                   	push   %ebp
80105510:	89 e5                	mov    %esp,%ebp
80105512:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105515:	e8 f0 ec ff ff       	call   8010420a <fork>
}
8010551a:	c9                   	leave  
8010551b:	c3                   	ret    

8010551c <sys_exit>:

int
sys_exit(void)
{
8010551c:	55                   	push   %ebp
8010551d:	89 e5                	mov    %esp,%ebp
8010551f:	83 ec 08             	sub    $0x8,%esp
  exit();
80105522:	e8 a4 e4 ff ff       	call   801039cb <exit>
  return 0;  // not reached
}
80105527:	b8 00 00 00 00       	mov    $0x0,%eax
8010552c:	c9                   	leave  
8010552d:	c3                   	ret    

8010552e <sys_wait>:

int
sys_wait(void)
{
8010552e:	55                   	push   %ebp
8010552f:	89 e5                	mov    %esp,%ebp
80105531:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105534:	e8 b6 e6 ff ff       	call   80103bef <wait>
}
80105539:	c9                   	leave  
8010553a:	c3                   	ret    

8010553b <sys_kill>:

int
sys_kill(void)
{
8010553b:	55                   	push   %ebp
8010553c:	89 e5                	mov    %esp,%ebp
8010553e:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105541:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105544:	50                   	push   %eax
80105545:	6a 00                	push   $0x0
80105547:	e8 f2 f2 ff ff       	call   8010483e <argint>
8010554c:	83 c4 10             	add    $0x10,%esp
8010554f:	85 c0                	test   %eax,%eax
80105551:	78 10                	js     80105563 <sys_kill+0x28>
    return -1;
  return kill(pid);
80105553:	83 ec 0c             	sub    $0xc,%esp
80105556:	ff 75 f4             	pushl  -0xc(%ebp)
80105559:	e8 91 e7 ff ff       	call   80103cef <kill>
8010555e:	83 c4 10             	add    $0x10,%esp
}
80105561:	c9                   	leave  
80105562:	c3                   	ret    
    return -1;
80105563:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105568:	eb f7                	jmp    80105561 <sys_kill+0x26>

8010556a <sys_getpid>:

int
sys_getpid(void)
{
8010556a:	55                   	push   %ebp
8010556b:	89 e5                	mov    %esp,%ebp
8010556d:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105570:	e8 59 dc ff ff       	call   801031ce <myproc>
80105575:	8b 40 10             	mov    0x10(%eax),%eax
}
80105578:	c9                   	leave  
80105579:	c3                   	ret    

8010557a <sys_sbrk>:

int
sys_sbrk(void)
{
8010557a:	55                   	push   %ebp
8010557b:	89 e5                	mov    %esp,%ebp
8010557d:	53                   	push   %ebx
8010557e:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105581:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105584:	50                   	push   %eax
80105585:	6a 00                	push   $0x0
80105587:	e8 b2 f2 ff ff       	call   8010483e <argint>
8010558c:	83 c4 10             	add    $0x10,%esp
8010558f:	85 c0                	test   %eax,%eax
80105591:	78 27                	js     801055ba <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105593:	e8 36 dc ff ff       	call   801031ce <myproc>
80105598:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
8010559a:	83 ec 0c             	sub    $0xc,%esp
8010559d:	ff 75 f4             	pushl  -0xc(%ebp)
801055a0:	e8 58 dd ff ff       	call   801032fd <growproc>
801055a5:	83 c4 10             	add    $0x10,%esp
801055a8:	85 c0                	test   %eax,%eax
801055aa:	78 07                	js     801055b3 <sys_sbrk+0x39>
    return -1;
  return addr;
}
801055ac:	89 d8                	mov    %ebx,%eax
801055ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801055b1:	c9                   	leave  
801055b2:	c3                   	ret    
    return -1;
801055b3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801055b8:	eb f2                	jmp    801055ac <sys_sbrk+0x32>
    return -1;
801055ba:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801055bf:	eb eb                	jmp    801055ac <sys_sbrk+0x32>

801055c1 <sys_sleep>:

int
sys_sleep(void)
{
801055c1:	55                   	push   %ebp
801055c2:	89 e5                	mov    %esp,%ebp
801055c4:	53                   	push   %ebx
801055c5:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801055c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
801055cb:	50                   	push   %eax
801055cc:	6a 00                	push   $0x0
801055ce:	e8 6b f2 ff ff       	call   8010483e <argint>
801055d3:	83 c4 10             	add    $0x10,%esp
801055d6:	85 c0                	test   %eax,%eax
801055d8:	78 75                	js     8010564f <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
801055da:	83 ec 0c             	sub    $0xc,%esp
801055dd:	68 80 5d 11 80       	push   $0x80115d80
801055e2:	e8 60 ef ff ff       	call   80104547 <acquire>
  ticks0 = ticks;
801055e7:	8b 1d c0 65 11 80    	mov    0x801165c0,%ebx
  while(ticks - ticks0 < n){
801055ed:	83 c4 10             	add    $0x10,%esp
801055f0:	a1 c0 65 11 80       	mov    0x801165c0,%eax
801055f5:	29 d8                	sub    %ebx,%eax
801055f7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801055fa:	73 39                	jae    80105635 <sys_sleep+0x74>
    if(myproc()->killed){
801055fc:	e8 cd db ff ff       	call   801031ce <myproc>
80105601:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105605:	75 17                	jne    8010561e <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105607:	83 ec 08             	sub    $0x8,%esp
8010560a:	68 80 5d 11 80       	push   $0x80115d80
8010560f:	68 c0 65 11 80       	push   $0x801165c0
80105614:	e8 45 e5 ff ff       	call   80103b5e <sleep>
80105619:	83 c4 10             	add    $0x10,%esp
8010561c:	eb d2                	jmp    801055f0 <sys_sleep+0x2f>
      release(&tickslock);
8010561e:	83 ec 0c             	sub    $0xc,%esp
80105621:	68 80 5d 11 80       	push   $0x80115d80
80105626:	e8 81 ef ff ff       	call   801045ac <release>
      return -1;
8010562b:	83 c4 10             	add    $0x10,%esp
8010562e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105633:	eb 15                	jmp    8010564a <sys_sleep+0x89>
  }
  release(&tickslock);
80105635:	83 ec 0c             	sub    $0xc,%esp
80105638:	68 80 5d 11 80       	push   $0x80115d80
8010563d:	e8 6a ef ff ff       	call   801045ac <release>
  return 0;
80105642:	83 c4 10             	add    $0x10,%esp
80105645:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010564a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010564d:	c9                   	leave  
8010564e:	c3                   	ret    
    return -1;
8010564f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105654:	eb f4                	jmp    8010564a <sys_sleep+0x89>

80105656 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105656:	55                   	push   %ebp
80105657:	89 e5                	mov    %esp,%ebp
80105659:	53                   	push   %ebx
8010565a:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
8010565d:	68 80 5d 11 80       	push   $0x80115d80
80105662:	e8 e0 ee ff ff       	call   80104547 <acquire>
  xticks = ticks;
80105667:	8b 1d c0 65 11 80    	mov    0x801165c0,%ebx
  release(&tickslock);
8010566d:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
80105674:	e8 33 ef ff ff       	call   801045ac <release>
  return xticks;
}
80105679:	89 d8                	mov    %ebx,%eax
8010567b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010567e:	c9                   	leave  
8010567f:	c3                   	ret    

80105680 <sys_setpri>:

int
sys_setpri(void){
80105680:	55                   	push   %ebp
80105681:	89 e5                	mov    %esp,%ebp
80105683:	83 ec 20             	sub    $0x20,%esp
  int PID;
  int pri;
  if(argint(0, &PID) < 0){
80105686:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105689:	50                   	push   %eax
8010568a:	6a 00                	push   $0x0
8010568c:	e8 ad f1 ff ff       	call   8010483e <argint>
80105691:	83 c4 10             	add    $0x10,%esp
80105694:	85 c0                	test   %eax,%eax
80105696:	78 28                	js     801056c0 <sys_setpri+0x40>
    return -1;
  }
  if(argint(1, &pri) < 0){
80105698:	83 ec 08             	sub    $0x8,%esp
8010569b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010569e:	50                   	push   %eax
8010569f:	6a 01                	push   $0x1
801056a1:	e8 98 f1 ff ff       	call   8010483e <argint>
801056a6:	83 c4 10             	add    $0x10,%esp
801056a9:	85 c0                	test   %eax,%eax
801056ab:	78 1a                	js     801056c7 <sys_setpri+0x47>
    return -1;
  }
  return setpri(PID, pri);
801056ad:	83 ec 08             	sub    $0x8,%esp
801056b0:	ff 75 f0             	pushl  -0x10(%ebp)
801056b3:	ff 75 f4             	pushl  -0xc(%ebp)
801056b6:	e8 5f e7 ff ff       	call   80103e1a <setpri>
801056bb:	83 c4 10             	add    $0x10,%esp
}
801056be:	c9                   	leave  
801056bf:	c3                   	ret    
    return -1;
801056c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056c5:	eb f7                	jmp    801056be <sys_setpri+0x3e>
    return -1;
801056c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056cc:	eb f0                	jmp    801056be <sys_setpri+0x3e>

801056ce <sys_getpri>:

int
sys_getpri(void){
801056ce:	55                   	push   %ebp
801056cf:	89 e5                	mov    %esp,%ebp
801056d1:	83 ec 20             	sub    $0x20,%esp
  int PID;
  if(argint(0, &PID) < 0){
801056d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801056d7:	50                   	push   %eax
801056d8:	6a 00                	push   $0x0
801056da:	e8 5f f1 ff ff       	call   8010483e <argint>
801056df:	83 c4 10             	add    $0x10,%esp
801056e2:	85 c0                	test   %eax,%eax
801056e4:	78 10                	js     801056f6 <sys_getpri+0x28>
    return -1;
  }
  return getpri(PID);
801056e6:	83 ec 0c             	sub    $0xc,%esp
801056e9:	ff 75 f4             	pushl  -0xc(%ebp)
801056ec:	e8 af e8 ff ff       	call   80103fa0 <getpri>
801056f1:	83 c4 10             	add    $0x10,%esp
}
801056f4:	c9                   	leave  
801056f5:	c3                   	ret    
    return -1;
801056f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056fb:	eb f7                	jmp    801056f4 <sys_getpri+0x26>

801056fd <sys_fork2>:

int
sys_fork2(void){
801056fd:	55                   	push   %ebp
801056fe:	89 e5                	mov    %esp,%ebp
80105700:	83 ec 20             	sub    $0x20,%esp
  int pri;
   if(argint(0, &pri) < 0){
80105703:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105706:	50                   	push   %eax
80105707:	6a 00                	push   $0x0
80105709:	e8 30 f1 ff ff       	call   8010483e <argint>
8010570e:	83 c4 10             	add    $0x10,%esp
80105711:	85 c0                	test   %eax,%eax
80105713:	78 10                	js     80105725 <sys_fork2+0x28>
    return -1;
  }
  return fork2(pri);
80105715:	83 ec 0c             	sub    $0xc,%esp
80105718:	ff 75 f4             	pushl  -0xc(%ebp)
8010571b:	e8 ad e8 ff ff       	call   80103fcd <fork2>
80105720:	83 c4 10             	add    $0x10,%esp
}
80105723:	c9                   	leave  
80105724:	c3                   	ret    
    return -1;
80105725:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010572a:	eb f7                	jmp    80105723 <sys_fork2+0x26>

8010572c <sys_getpinfo>:

int
sys_getpinfo(void){
8010572c:	55                   	push   %ebp
8010572d:	89 e5                	mov    %esp,%ebp
8010572f:	83 ec 1c             	sub    $0x1c,%esp
  struct pstat *mystruct;
  if(argptr(0, (void*)&mystruct, sizeof(*mystruct)) < 0){
80105732:	68 00 0c 00 00       	push   $0xc00
80105737:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010573a:	50                   	push   %eax
8010573b:	6a 00                	push   $0x0
8010573d:	e8 24 f1 ff ff       	call   80104866 <argptr>
80105742:	83 c4 10             	add    $0x10,%esp
80105745:	85 c0                	test   %eax,%eax
80105747:	78 10                	js     80105759 <sys_getpinfo+0x2d>
	 return -1;
  }
  return getpinfo(mystruct);
80105749:	83 ec 0c             	sub    $0xc,%esp
8010574c:	ff 75 f4             	pushl  -0xc(%ebp)
8010574f:	e8 d6 ea ff ff       	call   8010422a <getpinfo>
80105754:	83 c4 10             	add    $0x10,%esp
}
80105757:	c9                   	leave  
80105758:	c3                   	ret    
	 return -1;
80105759:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010575e:	eb f7                	jmp    80105757 <sys_getpinfo+0x2b>

80105760 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105760:	1e                   	push   %ds
  pushl %es
80105761:	06                   	push   %es
  pushl %fs
80105762:	0f a0                	push   %fs
  pushl %gs
80105764:	0f a8                	push   %gs
  pushal
80105766:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105767:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
8010576b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010576d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010576f:	54                   	push   %esp
  call trap
80105770:	e8 e3 00 00 00       	call   80105858 <trap>
  addl $4, %esp
80105775:	83 c4 04             	add    $0x4,%esp

80105778 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105778:	61                   	popa   
  popl %gs
80105779:	0f a9                	pop    %gs
  popl %fs
8010577b:	0f a1                	pop    %fs
  popl %es
8010577d:	07                   	pop    %es
  popl %ds
8010577e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010577f:	83 c4 08             	add    $0x8,%esp
  iret
80105782:	cf                   	iret   

80105783 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105783:	55                   	push   %ebp
80105784:	89 e5                	mov    %esp,%ebp
80105786:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80105789:	b8 00 00 00 00       	mov    $0x0,%eax
8010578e:	eb 4a                	jmp    801057da <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105790:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80105797:	66 89 0c c5 c0 5d 11 	mov    %cx,-0x7feea240(,%eax,8)
8010579e:	80 
8010579f:	66 c7 04 c5 c2 5d 11 	movw   $0x8,-0x7feea23e(,%eax,8)
801057a6:	80 08 00 
801057a9:	c6 04 c5 c4 5d 11 80 	movb   $0x0,-0x7feea23c(,%eax,8)
801057b0:	00 
801057b1:	0f b6 14 c5 c5 5d 11 	movzbl -0x7feea23b(,%eax,8),%edx
801057b8:	80 
801057b9:	83 e2 f0             	and    $0xfffffff0,%edx
801057bc:	83 ca 0e             	or     $0xe,%edx
801057bf:	83 e2 8f             	and    $0xffffff8f,%edx
801057c2:	83 ca 80             	or     $0xffffff80,%edx
801057c5:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
801057cc:	c1 e9 10             	shr    $0x10,%ecx
801057cf:	66 89 0c c5 c6 5d 11 	mov    %cx,-0x7feea23a(,%eax,8)
801057d6:	80 
  for(i = 0; i < 256; i++)
801057d7:	83 c0 01             	add    $0x1,%eax
801057da:	3d ff 00 00 00       	cmp    $0xff,%eax
801057df:	7e af                	jle    80105790 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801057e1:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
801057e7:	66 89 15 c0 5f 11 80 	mov    %dx,0x80115fc0
801057ee:	66 c7 05 c2 5f 11 80 	movw   $0x8,0x80115fc2
801057f5:	08 00 
801057f7:	c6 05 c4 5f 11 80 00 	movb   $0x0,0x80115fc4
801057fe:	0f b6 05 c5 5f 11 80 	movzbl 0x80115fc5,%eax
80105805:	83 c8 0f             	or     $0xf,%eax
80105808:	83 e0 ef             	and    $0xffffffef,%eax
8010580b:	83 c8 e0             	or     $0xffffffe0,%eax
8010580e:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
80105813:	c1 ea 10             	shr    $0x10,%edx
80105816:	66 89 15 c6 5f 11 80 	mov    %dx,0x80115fc6

  initlock(&tickslock, "time");
8010581d:	83 ec 08             	sub    $0x8,%esp
80105820:	68 69 76 10 80       	push   $0x80107669
80105825:	68 80 5d 11 80       	push   $0x80115d80
8010582a:	e8 dc eb ff ff       	call   8010440b <initlock>
}
8010582f:	83 c4 10             	add    $0x10,%esp
80105832:	c9                   	leave  
80105833:	c3                   	ret    

80105834 <idtinit>:

void
idtinit(void)
{
80105834:	55                   	push   %ebp
80105835:	89 e5                	mov    %esp,%ebp
80105837:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
8010583a:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80105840:	b8 c0 5d 11 80       	mov    $0x80115dc0,%eax
80105845:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105849:	c1 e8 10             	shr    $0x10,%eax
8010584c:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105850:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105853:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105856:	c9                   	leave  
80105857:	c3                   	ret    

80105858 <trap>:

void
trap(struct trapframe *tf)
{
80105858:	55                   	push   %ebp
80105859:	89 e5                	mov    %esp,%ebp
8010585b:	57                   	push   %edi
8010585c:	56                   	push   %esi
8010585d:	53                   	push   %ebx
8010585e:	83 ec 1c             	sub    $0x1c,%esp
80105861:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105864:	8b 43 30             	mov    0x30(%ebx),%eax
80105867:	83 f8 40             	cmp    $0x40,%eax
8010586a:	74 13                	je     8010587f <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010586c:	83 e8 20             	sub    $0x20,%eax
8010586f:	83 f8 1f             	cmp    $0x1f,%eax
80105872:	0f 87 3a 01 00 00    	ja     801059b2 <trap+0x15a>
80105878:	ff 24 85 10 77 10 80 	jmp    *-0x7fef88f0(,%eax,4)
    if(myproc()->killed)
8010587f:	e8 4a d9 ff ff       	call   801031ce <myproc>
80105884:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105888:	75 1f                	jne    801058a9 <trap+0x51>
    myproc()->tf = tf;
8010588a:	e8 3f d9 ff ff       	call   801031ce <myproc>
8010588f:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105892:	e8 6a f0 ff ff       	call   80104901 <syscall>
    if(myproc()->killed)
80105897:	e8 32 d9 ff ff       	call   801031ce <myproc>
8010589c:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801058a0:	74 7e                	je     80105920 <trap+0xc8>
      exit();
801058a2:	e8 24 e1 ff ff       	call   801039cb <exit>
801058a7:	eb 77                	jmp    80105920 <trap+0xc8>
      exit();
801058a9:	e8 1d e1 ff ff       	call   801039cb <exit>
801058ae:	eb da                	jmp    8010588a <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801058b0:	e8 fe d8 ff ff       	call   801031b3 <cpuid>
801058b5:	85 c0                	test   %eax,%eax
801058b7:	74 6f                	je     80105928 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
801058b9:	e8 db ca ff ff       	call   80102399 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801058be:	e8 0b d9 ff ff       	call   801031ce <myproc>
801058c3:	85 c0                	test   %eax,%eax
801058c5:	74 1c                	je     801058e3 <trap+0x8b>
801058c7:	e8 02 d9 ff ff       	call   801031ce <myproc>
801058cc:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801058d0:	74 11                	je     801058e3 <trap+0x8b>
801058d2:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801058d6:	83 e0 03             	and    $0x3,%eax
801058d9:	66 83 f8 03          	cmp    $0x3,%ax
801058dd:	0f 84 62 01 00 00    	je     80105a45 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801058e3:	e8 e6 d8 ff ff       	call   801031ce <myproc>
801058e8:	85 c0                	test   %eax,%eax
801058ea:	74 0f                	je     801058fb <trap+0xa3>
801058ec:	e8 dd d8 ff ff       	call   801031ce <myproc>
801058f1:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801058f5:	0f 84 54 01 00 00    	je     80105a4f <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801058fb:	e8 ce d8 ff ff       	call   801031ce <myproc>
80105900:	85 c0                	test   %eax,%eax
80105902:	74 1c                	je     80105920 <trap+0xc8>
80105904:	e8 c5 d8 ff ff       	call   801031ce <myproc>
80105909:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010590d:	74 11                	je     80105920 <trap+0xc8>
8010590f:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105913:	83 e0 03             	and    $0x3,%eax
80105916:	66 83 f8 03          	cmp    $0x3,%ax
8010591a:	0f 84 43 01 00 00    	je     80105a63 <trap+0x20b>
    exit();
}
80105920:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105923:	5b                   	pop    %ebx
80105924:	5e                   	pop    %esi
80105925:	5f                   	pop    %edi
80105926:	5d                   	pop    %ebp
80105927:	c3                   	ret    
      acquire(&tickslock);
80105928:	83 ec 0c             	sub    $0xc,%esp
8010592b:	68 80 5d 11 80       	push   $0x80115d80
80105930:	e8 12 ec ff ff       	call   80104547 <acquire>
      ticks++;
80105935:	83 05 c0 65 11 80 01 	addl   $0x1,0x801165c0
      wakeup(&ticks);
8010593c:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
80105943:	e8 7e e3 ff ff       	call   80103cc6 <wakeup>
      release(&tickslock);
80105948:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
8010594f:	e8 58 ec ff ff       	call   801045ac <release>
80105954:	83 c4 10             	add    $0x10,%esp
80105957:	e9 5d ff ff ff       	jmp    801058b9 <trap+0x61>
    ideintr();
8010595c:	e8 12 c4 ff ff       	call   80101d73 <ideintr>
    lapiceoi();
80105961:	e8 33 ca ff ff       	call   80102399 <lapiceoi>
    break;
80105966:	e9 53 ff ff ff       	jmp    801058be <trap+0x66>
    kbdintr();
8010596b:	e8 6d c8 ff ff       	call   801021dd <kbdintr>
    lapiceoi();
80105970:	e8 24 ca ff ff       	call   80102399 <lapiceoi>
    break;
80105975:	e9 44 ff ff ff       	jmp    801058be <trap+0x66>
    uartintr();
8010597a:	e8 05 02 00 00       	call   80105b84 <uartintr>
    lapiceoi();
8010597f:	e8 15 ca ff ff       	call   80102399 <lapiceoi>
    break;
80105984:	e9 35 ff ff ff       	jmp    801058be <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105989:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010598c:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105990:	e8 1e d8 ff ff       	call   801031b3 <cpuid>
80105995:	57                   	push   %edi
80105996:	0f b7 f6             	movzwl %si,%esi
80105999:	56                   	push   %esi
8010599a:	50                   	push   %eax
8010599b:	68 74 76 10 80       	push   $0x80107674
801059a0:	e8 66 ac ff ff       	call   8010060b <cprintf>
    lapiceoi();
801059a5:	e8 ef c9 ff ff       	call   80102399 <lapiceoi>
    break;
801059aa:	83 c4 10             	add    $0x10,%esp
801059ad:	e9 0c ff ff ff       	jmp    801058be <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801059b2:	e8 17 d8 ff ff       	call   801031ce <myproc>
801059b7:	85 c0                	test   %eax,%eax
801059b9:	74 5f                	je     80105a1a <trap+0x1c2>
801059bb:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801059bf:	74 59                	je     80105a1a <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801059c1:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801059c4:	8b 43 38             	mov    0x38(%ebx),%eax
801059c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801059ca:	e8 e4 d7 ff ff       	call   801031b3 <cpuid>
801059cf:	89 45 e0             	mov    %eax,-0x20(%ebp)
801059d2:	8b 53 34             	mov    0x34(%ebx),%edx
801059d5:	89 55 dc             	mov    %edx,-0x24(%ebp)
801059d8:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801059db:	e8 ee d7 ff ff       	call   801031ce <myproc>
801059e0:	8d 48 6c             	lea    0x6c(%eax),%ecx
801059e3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801059e6:	e8 e3 d7 ff ff       	call   801031ce <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801059eb:	57                   	push   %edi
801059ec:	ff 75 e4             	pushl  -0x1c(%ebp)
801059ef:	ff 75 e0             	pushl  -0x20(%ebp)
801059f2:	ff 75 dc             	pushl  -0x24(%ebp)
801059f5:	56                   	push   %esi
801059f6:	ff 75 d8             	pushl  -0x28(%ebp)
801059f9:	ff 70 10             	pushl  0x10(%eax)
801059fc:	68 cc 76 10 80       	push   $0x801076cc
80105a01:	e8 05 ac ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105a06:	83 c4 20             	add    $0x20,%esp
80105a09:	e8 c0 d7 ff ff       	call   801031ce <myproc>
80105a0e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105a15:	e9 a4 fe ff ff       	jmp    801058be <trap+0x66>
80105a1a:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105a1d:	8b 73 38             	mov    0x38(%ebx),%esi
80105a20:	e8 8e d7 ff ff       	call   801031b3 <cpuid>
80105a25:	83 ec 0c             	sub    $0xc,%esp
80105a28:	57                   	push   %edi
80105a29:	56                   	push   %esi
80105a2a:	50                   	push   %eax
80105a2b:	ff 73 30             	pushl  0x30(%ebx)
80105a2e:	68 98 76 10 80       	push   $0x80107698
80105a33:	e8 d3 ab ff ff       	call   8010060b <cprintf>
      panic("trap");
80105a38:	83 c4 14             	add    $0x14,%esp
80105a3b:	68 6e 76 10 80       	push   $0x8010766e
80105a40:	e8 03 a9 ff ff       	call   80100348 <panic>
    exit();
80105a45:	e8 81 df ff ff       	call   801039cb <exit>
80105a4a:	e9 94 fe ff ff       	jmp    801058e3 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105a4f:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105a53:	0f 85 a2 fe ff ff    	jne    801058fb <trap+0xa3>
    yield();
80105a59:	e8 ce e0 ff ff       	call   80103b2c <yield>
80105a5e:	e9 98 fe ff ff       	jmp    801058fb <trap+0xa3>
    exit();
80105a63:	e8 63 df ff ff       	call   801039cb <exit>
80105a68:	e9 b3 fe ff ff       	jmp    80105920 <trap+0xc8>

80105a6d <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105a6d:	55                   	push   %ebp
80105a6e:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105a70:	83 3d c4 a9 10 80 00 	cmpl   $0x0,0x8010a9c4
80105a77:	74 15                	je     80105a8e <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105a79:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105a7e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105a7f:	a8 01                	test   $0x1,%al
80105a81:	74 12                	je     80105a95 <uartgetc+0x28>
80105a83:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105a88:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105a89:	0f b6 c0             	movzbl %al,%eax
}
80105a8c:	5d                   	pop    %ebp
80105a8d:	c3                   	ret    
    return -1;
80105a8e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a93:	eb f7                	jmp    80105a8c <uartgetc+0x1f>
    return -1;
80105a95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9a:	eb f0                	jmp    80105a8c <uartgetc+0x1f>

80105a9c <uartputc>:
  if(!uart)
80105a9c:	83 3d c4 a9 10 80 00 	cmpl   $0x0,0x8010a9c4
80105aa3:	74 3b                	je     80105ae0 <uartputc+0x44>
{
80105aa5:	55                   	push   %ebp
80105aa6:	89 e5                	mov    %esp,%ebp
80105aa8:	53                   	push   %ebx
80105aa9:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105aac:	bb 00 00 00 00       	mov    $0x0,%ebx
80105ab1:	eb 10                	jmp    80105ac3 <uartputc+0x27>
    microdelay(10);
80105ab3:	83 ec 0c             	sub    $0xc,%esp
80105ab6:	6a 0a                	push   $0xa
80105ab8:	e8 fb c8 ff ff       	call   801023b8 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105abd:	83 c3 01             	add    $0x1,%ebx
80105ac0:	83 c4 10             	add    $0x10,%esp
80105ac3:	83 fb 7f             	cmp    $0x7f,%ebx
80105ac6:	7f 0a                	jg     80105ad2 <uartputc+0x36>
80105ac8:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105acd:	ec                   	in     (%dx),%al
80105ace:	a8 20                	test   $0x20,%al
80105ad0:	74 e1                	je     80105ab3 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105ad2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ad5:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105ada:	ee                   	out    %al,(%dx)
}
80105adb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105ade:	c9                   	leave  
80105adf:	c3                   	ret    
80105ae0:	f3 c3                	repz ret 

80105ae2 <uartinit>:
{
80105ae2:	55                   	push   %ebp
80105ae3:	89 e5                	mov    %esp,%ebp
80105ae5:	56                   	push   %esi
80105ae6:	53                   	push   %ebx
80105ae7:	b9 00 00 00 00       	mov    $0x0,%ecx
80105aec:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105af1:	89 c8                	mov    %ecx,%eax
80105af3:	ee                   	out    %al,(%dx)
80105af4:	be fb 03 00 00       	mov    $0x3fb,%esi
80105af9:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105afe:	89 f2                	mov    %esi,%edx
80105b00:	ee                   	out    %al,(%dx)
80105b01:	b8 0c 00 00 00       	mov    $0xc,%eax
80105b06:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105b0b:	ee                   	out    %al,(%dx)
80105b0c:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105b11:	89 c8                	mov    %ecx,%eax
80105b13:	89 da                	mov    %ebx,%edx
80105b15:	ee                   	out    %al,(%dx)
80105b16:	b8 03 00 00 00       	mov    $0x3,%eax
80105b1b:	89 f2                	mov    %esi,%edx
80105b1d:	ee                   	out    %al,(%dx)
80105b1e:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105b23:	89 c8                	mov    %ecx,%eax
80105b25:	ee                   	out    %al,(%dx)
80105b26:	b8 01 00 00 00       	mov    $0x1,%eax
80105b2b:	89 da                	mov    %ebx,%edx
80105b2d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105b2e:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105b33:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105b34:	3c ff                	cmp    $0xff,%al
80105b36:	74 45                	je     80105b7d <uartinit+0x9b>
  uart = 1;
80105b38:	c7 05 c4 a9 10 80 01 	movl   $0x1,0x8010a9c4
80105b3f:	00 00 00 
80105b42:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105b47:	ec                   	in     (%dx),%al
80105b48:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105b4d:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105b4e:	83 ec 08             	sub    $0x8,%esp
80105b51:	6a 00                	push   $0x0
80105b53:	6a 04                	push   $0x4
80105b55:	e8 24 c4 ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105b5a:	83 c4 10             	add    $0x10,%esp
80105b5d:	bb 90 77 10 80       	mov    $0x80107790,%ebx
80105b62:	eb 12                	jmp    80105b76 <uartinit+0x94>
    uartputc(*p);
80105b64:	83 ec 0c             	sub    $0xc,%esp
80105b67:	0f be c0             	movsbl %al,%eax
80105b6a:	50                   	push   %eax
80105b6b:	e8 2c ff ff ff       	call   80105a9c <uartputc>
  for(p="xv6...\n"; *p; p++)
80105b70:	83 c3 01             	add    $0x1,%ebx
80105b73:	83 c4 10             	add    $0x10,%esp
80105b76:	0f b6 03             	movzbl (%ebx),%eax
80105b79:	84 c0                	test   %al,%al
80105b7b:	75 e7                	jne    80105b64 <uartinit+0x82>
}
80105b7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105b80:	5b                   	pop    %ebx
80105b81:	5e                   	pop    %esi
80105b82:	5d                   	pop    %ebp
80105b83:	c3                   	ret    

80105b84 <uartintr>:

void
uartintr(void)
{
80105b84:	55                   	push   %ebp
80105b85:	89 e5                	mov    %esp,%ebp
80105b87:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105b8a:	68 6d 5a 10 80       	push   $0x80105a6d
80105b8f:	e8 aa ab ff ff       	call   8010073e <consoleintr>
}
80105b94:	83 c4 10             	add    $0x10,%esp
80105b97:	c9                   	leave  
80105b98:	c3                   	ret    

80105b99 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105b99:	6a 00                	push   $0x0
  pushl $0
80105b9b:	6a 00                	push   $0x0
  jmp alltraps
80105b9d:	e9 be fb ff ff       	jmp    80105760 <alltraps>

80105ba2 <vector1>:
.globl vector1
vector1:
  pushl $0
80105ba2:	6a 00                	push   $0x0
  pushl $1
80105ba4:	6a 01                	push   $0x1
  jmp alltraps
80105ba6:	e9 b5 fb ff ff       	jmp    80105760 <alltraps>

80105bab <vector2>:
.globl vector2
vector2:
  pushl $0
80105bab:	6a 00                	push   $0x0
  pushl $2
80105bad:	6a 02                	push   $0x2
  jmp alltraps
80105baf:	e9 ac fb ff ff       	jmp    80105760 <alltraps>

80105bb4 <vector3>:
.globl vector3
vector3:
  pushl $0
80105bb4:	6a 00                	push   $0x0
  pushl $3
80105bb6:	6a 03                	push   $0x3
  jmp alltraps
80105bb8:	e9 a3 fb ff ff       	jmp    80105760 <alltraps>

80105bbd <vector4>:
.globl vector4
vector4:
  pushl $0
80105bbd:	6a 00                	push   $0x0
  pushl $4
80105bbf:	6a 04                	push   $0x4
  jmp alltraps
80105bc1:	e9 9a fb ff ff       	jmp    80105760 <alltraps>

80105bc6 <vector5>:
.globl vector5
vector5:
  pushl $0
80105bc6:	6a 00                	push   $0x0
  pushl $5
80105bc8:	6a 05                	push   $0x5
  jmp alltraps
80105bca:	e9 91 fb ff ff       	jmp    80105760 <alltraps>

80105bcf <vector6>:
.globl vector6
vector6:
  pushl $0
80105bcf:	6a 00                	push   $0x0
  pushl $6
80105bd1:	6a 06                	push   $0x6
  jmp alltraps
80105bd3:	e9 88 fb ff ff       	jmp    80105760 <alltraps>

80105bd8 <vector7>:
.globl vector7
vector7:
  pushl $0
80105bd8:	6a 00                	push   $0x0
  pushl $7
80105bda:	6a 07                	push   $0x7
  jmp alltraps
80105bdc:	e9 7f fb ff ff       	jmp    80105760 <alltraps>

80105be1 <vector8>:
.globl vector8
vector8:
  pushl $8
80105be1:	6a 08                	push   $0x8
  jmp alltraps
80105be3:	e9 78 fb ff ff       	jmp    80105760 <alltraps>

80105be8 <vector9>:
.globl vector9
vector9:
  pushl $0
80105be8:	6a 00                	push   $0x0
  pushl $9
80105bea:	6a 09                	push   $0x9
  jmp alltraps
80105bec:	e9 6f fb ff ff       	jmp    80105760 <alltraps>

80105bf1 <vector10>:
.globl vector10
vector10:
  pushl $10
80105bf1:	6a 0a                	push   $0xa
  jmp alltraps
80105bf3:	e9 68 fb ff ff       	jmp    80105760 <alltraps>

80105bf8 <vector11>:
.globl vector11
vector11:
  pushl $11
80105bf8:	6a 0b                	push   $0xb
  jmp alltraps
80105bfa:	e9 61 fb ff ff       	jmp    80105760 <alltraps>

80105bff <vector12>:
.globl vector12
vector12:
  pushl $12
80105bff:	6a 0c                	push   $0xc
  jmp alltraps
80105c01:	e9 5a fb ff ff       	jmp    80105760 <alltraps>

80105c06 <vector13>:
.globl vector13
vector13:
  pushl $13
80105c06:	6a 0d                	push   $0xd
  jmp alltraps
80105c08:	e9 53 fb ff ff       	jmp    80105760 <alltraps>

80105c0d <vector14>:
.globl vector14
vector14:
  pushl $14
80105c0d:	6a 0e                	push   $0xe
  jmp alltraps
80105c0f:	e9 4c fb ff ff       	jmp    80105760 <alltraps>

80105c14 <vector15>:
.globl vector15
vector15:
  pushl $0
80105c14:	6a 00                	push   $0x0
  pushl $15
80105c16:	6a 0f                	push   $0xf
  jmp alltraps
80105c18:	e9 43 fb ff ff       	jmp    80105760 <alltraps>

80105c1d <vector16>:
.globl vector16
vector16:
  pushl $0
80105c1d:	6a 00                	push   $0x0
  pushl $16
80105c1f:	6a 10                	push   $0x10
  jmp alltraps
80105c21:	e9 3a fb ff ff       	jmp    80105760 <alltraps>

80105c26 <vector17>:
.globl vector17
vector17:
  pushl $17
80105c26:	6a 11                	push   $0x11
  jmp alltraps
80105c28:	e9 33 fb ff ff       	jmp    80105760 <alltraps>

80105c2d <vector18>:
.globl vector18
vector18:
  pushl $0
80105c2d:	6a 00                	push   $0x0
  pushl $18
80105c2f:	6a 12                	push   $0x12
  jmp alltraps
80105c31:	e9 2a fb ff ff       	jmp    80105760 <alltraps>

80105c36 <vector19>:
.globl vector19
vector19:
  pushl $0
80105c36:	6a 00                	push   $0x0
  pushl $19
80105c38:	6a 13                	push   $0x13
  jmp alltraps
80105c3a:	e9 21 fb ff ff       	jmp    80105760 <alltraps>

80105c3f <vector20>:
.globl vector20
vector20:
  pushl $0
80105c3f:	6a 00                	push   $0x0
  pushl $20
80105c41:	6a 14                	push   $0x14
  jmp alltraps
80105c43:	e9 18 fb ff ff       	jmp    80105760 <alltraps>

80105c48 <vector21>:
.globl vector21
vector21:
  pushl $0
80105c48:	6a 00                	push   $0x0
  pushl $21
80105c4a:	6a 15                	push   $0x15
  jmp alltraps
80105c4c:	e9 0f fb ff ff       	jmp    80105760 <alltraps>

80105c51 <vector22>:
.globl vector22
vector22:
  pushl $0
80105c51:	6a 00                	push   $0x0
  pushl $22
80105c53:	6a 16                	push   $0x16
  jmp alltraps
80105c55:	e9 06 fb ff ff       	jmp    80105760 <alltraps>

80105c5a <vector23>:
.globl vector23
vector23:
  pushl $0
80105c5a:	6a 00                	push   $0x0
  pushl $23
80105c5c:	6a 17                	push   $0x17
  jmp alltraps
80105c5e:	e9 fd fa ff ff       	jmp    80105760 <alltraps>

80105c63 <vector24>:
.globl vector24
vector24:
  pushl $0
80105c63:	6a 00                	push   $0x0
  pushl $24
80105c65:	6a 18                	push   $0x18
  jmp alltraps
80105c67:	e9 f4 fa ff ff       	jmp    80105760 <alltraps>

80105c6c <vector25>:
.globl vector25
vector25:
  pushl $0
80105c6c:	6a 00                	push   $0x0
  pushl $25
80105c6e:	6a 19                	push   $0x19
  jmp alltraps
80105c70:	e9 eb fa ff ff       	jmp    80105760 <alltraps>

80105c75 <vector26>:
.globl vector26
vector26:
  pushl $0
80105c75:	6a 00                	push   $0x0
  pushl $26
80105c77:	6a 1a                	push   $0x1a
  jmp alltraps
80105c79:	e9 e2 fa ff ff       	jmp    80105760 <alltraps>

80105c7e <vector27>:
.globl vector27
vector27:
  pushl $0
80105c7e:	6a 00                	push   $0x0
  pushl $27
80105c80:	6a 1b                	push   $0x1b
  jmp alltraps
80105c82:	e9 d9 fa ff ff       	jmp    80105760 <alltraps>

80105c87 <vector28>:
.globl vector28
vector28:
  pushl $0
80105c87:	6a 00                	push   $0x0
  pushl $28
80105c89:	6a 1c                	push   $0x1c
  jmp alltraps
80105c8b:	e9 d0 fa ff ff       	jmp    80105760 <alltraps>

80105c90 <vector29>:
.globl vector29
vector29:
  pushl $0
80105c90:	6a 00                	push   $0x0
  pushl $29
80105c92:	6a 1d                	push   $0x1d
  jmp alltraps
80105c94:	e9 c7 fa ff ff       	jmp    80105760 <alltraps>

80105c99 <vector30>:
.globl vector30
vector30:
  pushl $0
80105c99:	6a 00                	push   $0x0
  pushl $30
80105c9b:	6a 1e                	push   $0x1e
  jmp alltraps
80105c9d:	e9 be fa ff ff       	jmp    80105760 <alltraps>

80105ca2 <vector31>:
.globl vector31
vector31:
  pushl $0
80105ca2:	6a 00                	push   $0x0
  pushl $31
80105ca4:	6a 1f                	push   $0x1f
  jmp alltraps
80105ca6:	e9 b5 fa ff ff       	jmp    80105760 <alltraps>

80105cab <vector32>:
.globl vector32
vector32:
  pushl $0
80105cab:	6a 00                	push   $0x0
  pushl $32
80105cad:	6a 20                	push   $0x20
  jmp alltraps
80105caf:	e9 ac fa ff ff       	jmp    80105760 <alltraps>

80105cb4 <vector33>:
.globl vector33
vector33:
  pushl $0
80105cb4:	6a 00                	push   $0x0
  pushl $33
80105cb6:	6a 21                	push   $0x21
  jmp alltraps
80105cb8:	e9 a3 fa ff ff       	jmp    80105760 <alltraps>

80105cbd <vector34>:
.globl vector34
vector34:
  pushl $0
80105cbd:	6a 00                	push   $0x0
  pushl $34
80105cbf:	6a 22                	push   $0x22
  jmp alltraps
80105cc1:	e9 9a fa ff ff       	jmp    80105760 <alltraps>

80105cc6 <vector35>:
.globl vector35
vector35:
  pushl $0
80105cc6:	6a 00                	push   $0x0
  pushl $35
80105cc8:	6a 23                	push   $0x23
  jmp alltraps
80105cca:	e9 91 fa ff ff       	jmp    80105760 <alltraps>

80105ccf <vector36>:
.globl vector36
vector36:
  pushl $0
80105ccf:	6a 00                	push   $0x0
  pushl $36
80105cd1:	6a 24                	push   $0x24
  jmp alltraps
80105cd3:	e9 88 fa ff ff       	jmp    80105760 <alltraps>

80105cd8 <vector37>:
.globl vector37
vector37:
  pushl $0
80105cd8:	6a 00                	push   $0x0
  pushl $37
80105cda:	6a 25                	push   $0x25
  jmp alltraps
80105cdc:	e9 7f fa ff ff       	jmp    80105760 <alltraps>

80105ce1 <vector38>:
.globl vector38
vector38:
  pushl $0
80105ce1:	6a 00                	push   $0x0
  pushl $38
80105ce3:	6a 26                	push   $0x26
  jmp alltraps
80105ce5:	e9 76 fa ff ff       	jmp    80105760 <alltraps>

80105cea <vector39>:
.globl vector39
vector39:
  pushl $0
80105cea:	6a 00                	push   $0x0
  pushl $39
80105cec:	6a 27                	push   $0x27
  jmp alltraps
80105cee:	e9 6d fa ff ff       	jmp    80105760 <alltraps>

80105cf3 <vector40>:
.globl vector40
vector40:
  pushl $0
80105cf3:	6a 00                	push   $0x0
  pushl $40
80105cf5:	6a 28                	push   $0x28
  jmp alltraps
80105cf7:	e9 64 fa ff ff       	jmp    80105760 <alltraps>

80105cfc <vector41>:
.globl vector41
vector41:
  pushl $0
80105cfc:	6a 00                	push   $0x0
  pushl $41
80105cfe:	6a 29                	push   $0x29
  jmp alltraps
80105d00:	e9 5b fa ff ff       	jmp    80105760 <alltraps>

80105d05 <vector42>:
.globl vector42
vector42:
  pushl $0
80105d05:	6a 00                	push   $0x0
  pushl $42
80105d07:	6a 2a                	push   $0x2a
  jmp alltraps
80105d09:	e9 52 fa ff ff       	jmp    80105760 <alltraps>

80105d0e <vector43>:
.globl vector43
vector43:
  pushl $0
80105d0e:	6a 00                	push   $0x0
  pushl $43
80105d10:	6a 2b                	push   $0x2b
  jmp alltraps
80105d12:	e9 49 fa ff ff       	jmp    80105760 <alltraps>

80105d17 <vector44>:
.globl vector44
vector44:
  pushl $0
80105d17:	6a 00                	push   $0x0
  pushl $44
80105d19:	6a 2c                	push   $0x2c
  jmp alltraps
80105d1b:	e9 40 fa ff ff       	jmp    80105760 <alltraps>

80105d20 <vector45>:
.globl vector45
vector45:
  pushl $0
80105d20:	6a 00                	push   $0x0
  pushl $45
80105d22:	6a 2d                	push   $0x2d
  jmp alltraps
80105d24:	e9 37 fa ff ff       	jmp    80105760 <alltraps>

80105d29 <vector46>:
.globl vector46
vector46:
  pushl $0
80105d29:	6a 00                	push   $0x0
  pushl $46
80105d2b:	6a 2e                	push   $0x2e
  jmp alltraps
80105d2d:	e9 2e fa ff ff       	jmp    80105760 <alltraps>

80105d32 <vector47>:
.globl vector47
vector47:
  pushl $0
80105d32:	6a 00                	push   $0x0
  pushl $47
80105d34:	6a 2f                	push   $0x2f
  jmp alltraps
80105d36:	e9 25 fa ff ff       	jmp    80105760 <alltraps>

80105d3b <vector48>:
.globl vector48
vector48:
  pushl $0
80105d3b:	6a 00                	push   $0x0
  pushl $48
80105d3d:	6a 30                	push   $0x30
  jmp alltraps
80105d3f:	e9 1c fa ff ff       	jmp    80105760 <alltraps>

80105d44 <vector49>:
.globl vector49
vector49:
  pushl $0
80105d44:	6a 00                	push   $0x0
  pushl $49
80105d46:	6a 31                	push   $0x31
  jmp alltraps
80105d48:	e9 13 fa ff ff       	jmp    80105760 <alltraps>

80105d4d <vector50>:
.globl vector50
vector50:
  pushl $0
80105d4d:	6a 00                	push   $0x0
  pushl $50
80105d4f:	6a 32                	push   $0x32
  jmp alltraps
80105d51:	e9 0a fa ff ff       	jmp    80105760 <alltraps>

80105d56 <vector51>:
.globl vector51
vector51:
  pushl $0
80105d56:	6a 00                	push   $0x0
  pushl $51
80105d58:	6a 33                	push   $0x33
  jmp alltraps
80105d5a:	e9 01 fa ff ff       	jmp    80105760 <alltraps>

80105d5f <vector52>:
.globl vector52
vector52:
  pushl $0
80105d5f:	6a 00                	push   $0x0
  pushl $52
80105d61:	6a 34                	push   $0x34
  jmp alltraps
80105d63:	e9 f8 f9 ff ff       	jmp    80105760 <alltraps>

80105d68 <vector53>:
.globl vector53
vector53:
  pushl $0
80105d68:	6a 00                	push   $0x0
  pushl $53
80105d6a:	6a 35                	push   $0x35
  jmp alltraps
80105d6c:	e9 ef f9 ff ff       	jmp    80105760 <alltraps>

80105d71 <vector54>:
.globl vector54
vector54:
  pushl $0
80105d71:	6a 00                	push   $0x0
  pushl $54
80105d73:	6a 36                	push   $0x36
  jmp alltraps
80105d75:	e9 e6 f9 ff ff       	jmp    80105760 <alltraps>

80105d7a <vector55>:
.globl vector55
vector55:
  pushl $0
80105d7a:	6a 00                	push   $0x0
  pushl $55
80105d7c:	6a 37                	push   $0x37
  jmp alltraps
80105d7e:	e9 dd f9 ff ff       	jmp    80105760 <alltraps>

80105d83 <vector56>:
.globl vector56
vector56:
  pushl $0
80105d83:	6a 00                	push   $0x0
  pushl $56
80105d85:	6a 38                	push   $0x38
  jmp alltraps
80105d87:	e9 d4 f9 ff ff       	jmp    80105760 <alltraps>

80105d8c <vector57>:
.globl vector57
vector57:
  pushl $0
80105d8c:	6a 00                	push   $0x0
  pushl $57
80105d8e:	6a 39                	push   $0x39
  jmp alltraps
80105d90:	e9 cb f9 ff ff       	jmp    80105760 <alltraps>

80105d95 <vector58>:
.globl vector58
vector58:
  pushl $0
80105d95:	6a 00                	push   $0x0
  pushl $58
80105d97:	6a 3a                	push   $0x3a
  jmp alltraps
80105d99:	e9 c2 f9 ff ff       	jmp    80105760 <alltraps>

80105d9e <vector59>:
.globl vector59
vector59:
  pushl $0
80105d9e:	6a 00                	push   $0x0
  pushl $59
80105da0:	6a 3b                	push   $0x3b
  jmp alltraps
80105da2:	e9 b9 f9 ff ff       	jmp    80105760 <alltraps>

80105da7 <vector60>:
.globl vector60
vector60:
  pushl $0
80105da7:	6a 00                	push   $0x0
  pushl $60
80105da9:	6a 3c                	push   $0x3c
  jmp alltraps
80105dab:	e9 b0 f9 ff ff       	jmp    80105760 <alltraps>

80105db0 <vector61>:
.globl vector61
vector61:
  pushl $0
80105db0:	6a 00                	push   $0x0
  pushl $61
80105db2:	6a 3d                	push   $0x3d
  jmp alltraps
80105db4:	e9 a7 f9 ff ff       	jmp    80105760 <alltraps>

80105db9 <vector62>:
.globl vector62
vector62:
  pushl $0
80105db9:	6a 00                	push   $0x0
  pushl $62
80105dbb:	6a 3e                	push   $0x3e
  jmp alltraps
80105dbd:	e9 9e f9 ff ff       	jmp    80105760 <alltraps>

80105dc2 <vector63>:
.globl vector63
vector63:
  pushl $0
80105dc2:	6a 00                	push   $0x0
  pushl $63
80105dc4:	6a 3f                	push   $0x3f
  jmp alltraps
80105dc6:	e9 95 f9 ff ff       	jmp    80105760 <alltraps>

80105dcb <vector64>:
.globl vector64
vector64:
  pushl $0
80105dcb:	6a 00                	push   $0x0
  pushl $64
80105dcd:	6a 40                	push   $0x40
  jmp alltraps
80105dcf:	e9 8c f9 ff ff       	jmp    80105760 <alltraps>

80105dd4 <vector65>:
.globl vector65
vector65:
  pushl $0
80105dd4:	6a 00                	push   $0x0
  pushl $65
80105dd6:	6a 41                	push   $0x41
  jmp alltraps
80105dd8:	e9 83 f9 ff ff       	jmp    80105760 <alltraps>

80105ddd <vector66>:
.globl vector66
vector66:
  pushl $0
80105ddd:	6a 00                	push   $0x0
  pushl $66
80105ddf:	6a 42                	push   $0x42
  jmp alltraps
80105de1:	e9 7a f9 ff ff       	jmp    80105760 <alltraps>

80105de6 <vector67>:
.globl vector67
vector67:
  pushl $0
80105de6:	6a 00                	push   $0x0
  pushl $67
80105de8:	6a 43                	push   $0x43
  jmp alltraps
80105dea:	e9 71 f9 ff ff       	jmp    80105760 <alltraps>

80105def <vector68>:
.globl vector68
vector68:
  pushl $0
80105def:	6a 00                	push   $0x0
  pushl $68
80105df1:	6a 44                	push   $0x44
  jmp alltraps
80105df3:	e9 68 f9 ff ff       	jmp    80105760 <alltraps>

80105df8 <vector69>:
.globl vector69
vector69:
  pushl $0
80105df8:	6a 00                	push   $0x0
  pushl $69
80105dfa:	6a 45                	push   $0x45
  jmp alltraps
80105dfc:	e9 5f f9 ff ff       	jmp    80105760 <alltraps>

80105e01 <vector70>:
.globl vector70
vector70:
  pushl $0
80105e01:	6a 00                	push   $0x0
  pushl $70
80105e03:	6a 46                	push   $0x46
  jmp alltraps
80105e05:	e9 56 f9 ff ff       	jmp    80105760 <alltraps>

80105e0a <vector71>:
.globl vector71
vector71:
  pushl $0
80105e0a:	6a 00                	push   $0x0
  pushl $71
80105e0c:	6a 47                	push   $0x47
  jmp alltraps
80105e0e:	e9 4d f9 ff ff       	jmp    80105760 <alltraps>

80105e13 <vector72>:
.globl vector72
vector72:
  pushl $0
80105e13:	6a 00                	push   $0x0
  pushl $72
80105e15:	6a 48                	push   $0x48
  jmp alltraps
80105e17:	e9 44 f9 ff ff       	jmp    80105760 <alltraps>

80105e1c <vector73>:
.globl vector73
vector73:
  pushl $0
80105e1c:	6a 00                	push   $0x0
  pushl $73
80105e1e:	6a 49                	push   $0x49
  jmp alltraps
80105e20:	e9 3b f9 ff ff       	jmp    80105760 <alltraps>

80105e25 <vector74>:
.globl vector74
vector74:
  pushl $0
80105e25:	6a 00                	push   $0x0
  pushl $74
80105e27:	6a 4a                	push   $0x4a
  jmp alltraps
80105e29:	e9 32 f9 ff ff       	jmp    80105760 <alltraps>

80105e2e <vector75>:
.globl vector75
vector75:
  pushl $0
80105e2e:	6a 00                	push   $0x0
  pushl $75
80105e30:	6a 4b                	push   $0x4b
  jmp alltraps
80105e32:	e9 29 f9 ff ff       	jmp    80105760 <alltraps>

80105e37 <vector76>:
.globl vector76
vector76:
  pushl $0
80105e37:	6a 00                	push   $0x0
  pushl $76
80105e39:	6a 4c                	push   $0x4c
  jmp alltraps
80105e3b:	e9 20 f9 ff ff       	jmp    80105760 <alltraps>

80105e40 <vector77>:
.globl vector77
vector77:
  pushl $0
80105e40:	6a 00                	push   $0x0
  pushl $77
80105e42:	6a 4d                	push   $0x4d
  jmp alltraps
80105e44:	e9 17 f9 ff ff       	jmp    80105760 <alltraps>

80105e49 <vector78>:
.globl vector78
vector78:
  pushl $0
80105e49:	6a 00                	push   $0x0
  pushl $78
80105e4b:	6a 4e                	push   $0x4e
  jmp alltraps
80105e4d:	e9 0e f9 ff ff       	jmp    80105760 <alltraps>

80105e52 <vector79>:
.globl vector79
vector79:
  pushl $0
80105e52:	6a 00                	push   $0x0
  pushl $79
80105e54:	6a 4f                	push   $0x4f
  jmp alltraps
80105e56:	e9 05 f9 ff ff       	jmp    80105760 <alltraps>

80105e5b <vector80>:
.globl vector80
vector80:
  pushl $0
80105e5b:	6a 00                	push   $0x0
  pushl $80
80105e5d:	6a 50                	push   $0x50
  jmp alltraps
80105e5f:	e9 fc f8 ff ff       	jmp    80105760 <alltraps>

80105e64 <vector81>:
.globl vector81
vector81:
  pushl $0
80105e64:	6a 00                	push   $0x0
  pushl $81
80105e66:	6a 51                	push   $0x51
  jmp alltraps
80105e68:	e9 f3 f8 ff ff       	jmp    80105760 <alltraps>

80105e6d <vector82>:
.globl vector82
vector82:
  pushl $0
80105e6d:	6a 00                	push   $0x0
  pushl $82
80105e6f:	6a 52                	push   $0x52
  jmp alltraps
80105e71:	e9 ea f8 ff ff       	jmp    80105760 <alltraps>

80105e76 <vector83>:
.globl vector83
vector83:
  pushl $0
80105e76:	6a 00                	push   $0x0
  pushl $83
80105e78:	6a 53                	push   $0x53
  jmp alltraps
80105e7a:	e9 e1 f8 ff ff       	jmp    80105760 <alltraps>

80105e7f <vector84>:
.globl vector84
vector84:
  pushl $0
80105e7f:	6a 00                	push   $0x0
  pushl $84
80105e81:	6a 54                	push   $0x54
  jmp alltraps
80105e83:	e9 d8 f8 ff ff       	jmp    80105760 <alltraps>

80105e88 <vector85>:
.globl vector85
vector85:
  pushl $0
80105e88:	6a 00                	push   $0x0
  pushl $85
80105e8a:	6a 55                	push   $0x55
  jmp alltraps
80105e8c:	e9 cf f8 ff ff       	jmp    80105760 <alltraps>

80105e91 <vector86>:
.globl vector86
vector86:
  pushl $0
80105e91:	6a 00                	push   $0x0
  pushl $86
80105e93:	6a 56                	push   $0x56
  jmp alltraps
80105e95:	e9 c6 f8 ff ff       	jmp    80105760 <alltraps>

80105e9a <vector87>:
.globl vector87
vector87:
  pushl $0
80105e9a:	6a 00                	push   $0x0
  pushl $87
80105e9c:	6a 57                	push   $0x57
  jmp alltraps
80105e9e:	e9 bd f8 ff ff       	jmp    80105760 <alltraps>

80105ea3 <vector88>:
.globl vector88
vector88:
  pushl $0
80105ea3:	6a 00                	push   $0x0
  pushl $88
80105ea5:	6a 58                	push   $0x58
  jmp alltraps
80105ea7:	e9 b4 f8 ff ff       	jmp    80105760 <alltraps>

80105eac <vector89>:
.globl vector89
vector89:
  pushl $0
80105eac:	6a 00                	push   $0x0
  pushl $89
80105eae:	6a 59                	push   $0x59
  jmp alltraps
80105eb0:	e9 ab f8 ff ff       	jmp    80105760 <alltraps>

80105eb5 <vector90>:
.globl vector90
vector90:
  pushl $0
80105eb5:	6a 00                	push   $0x0
  pushl $90
80105eb7:	6a 5a                	push   $0x5a
  jmp alltraps
80105eb9:	e9 a2 f8 ff ff       	jmp    80105760 <alltraps>

80105ebe <vector91>:
.globl vector91
vector91:
  pushl $0
80105ebe:	6a 00                	push   $0x0
  pushl $91
80105ec0:	6a 5b                	push   $0x5b
  jmp alltraps
80105ec2:	e9 99 f8 ff ff       	jmp    80105760 <alltraps>

80105ec7 <vector92>:
.globl vector92
vector92:
  pushl $0
80105ec7:	6a 00                	push   $0x0
  pushl $92
80105ec9:	6a 5c                	push   $0x5c
  jmp alltraps
80105ecb:	e9 90 f8 ff ff       	jmp    80105760 <alltraps>

80105ed0 <vector93>:
.globl vector93
vector93:
  pushl $0
80105ed0:	6a 00                	push   $0x0
  pushl $93
80105ed2:	6a 5d                	push   $0x5d
  jmp alltraps
80105ed4:	e9 87 f8 ff ff       	jmp    80105760 <alltraps>

80105ed9 <vector94>:
.globl vector94
vector94:
  pushl $0
80105ed9:	6a 00                	push   $0x0
  pushl $94
80105edb:	6a 5e                	push   $0x5e
  jmp alltraps
80105edd:	e9 7e f8 ff ff       	jmp    80105760 <alltraps>

80105ee2 <vector95>:
.globl vector95
vector95:
  pushl $0
80105ee2:	6a 00                	push   $0x0
  pushl $95
80105ee4:	6a 5f                	push   $0x5f
  jmp alltraps
80105ee6:	e9 75 f8 ff ff       	jmp    80105760 <alltraps>

80105eeb <vector96>:
.globl vector96
vector96:
  pushl $0
80105eeb:	6a 00                	push   $0x0
  pushl $96
80105eed:	6a 60                	push   $0x60
  jmp alltraps
80105eef:	e9 6c f8 ff ff       	jmp    80105760 <alltraps>

80105ef4 <vector97>:
.globl vector97
vector97:
  pushl $0
80105ef4:	6a 00                	push   $0x0
  pushl $97
80105ef6:	6a 61                	push   $0x61
  jmp alltraps
80105ef8:	e9 63 f8 ff ff       	jmp    80105760 <alltraps>

80105efd <vector98>:
.globl vector98
vector98:
  pushl $0
80105efd:	6a 00                	push   $0x0
  pushl $98
80105eff:	6a 62                	push   $0x62
  jmp alltraps
80105f01:	e9 5a f8 ff ff       	jmp    80105760 <alltraps>

80105f06 <vector99>:
.globl vector99
vector99:
  pushl $0
80105f06:	6a 00                	push   $0x0
  pushl $99
80105f08:	6a 63                	push   $0x63
  jmp alltraps
80105f0a:	e9 51 f8 ff ff       	jmp    80105760 <alltraps>

80105f0f <vector100>:
.globl vector100
vector100:
  pushl $0
80105f0f:	6a 00                	push   $0x0
  pushl $100
80105f11:	6a 64                	push   $0x64
  jmp alltraps
80105f13:	e9 48 f8 ff ff       	jmp    80105760 <alltraps>

80105f18 <vector101>:
.globl vector101
vector101:
  pushl $0
80105f18:	6a 00                	push   $0x0
  pushl $101
80105f1a:	6a 65                	push   $0x65
  jmp alltraps
80105f1c:	e9 3f f8 ff ff       	jmp    80105760 <alltraps>

80105f21 <vector102>:
.globl vector102
vector102:
  pushl $0
80105f21:	6a 00                	push   $0x0
  pushl $102
80105f23:	6a 66                	push   $0x66
  jmp alltraps
80105f25:	e9 36 f8 ff ff       	jmp    80105760 <alltraps>

80105f2a <vector103>:
.globl vector103
vector103:
  pushl $0
80105f2a:	6a 00                	push   $0x0
  pushl $103
80105f2c:	6a 67                	push   $0x67
  jmp alltraps
80105f2e:	e9 2d f8 ff ff       	jmp    80105760 <alltraps>

80105f33 <vector104>:
.globl vector104
vector104:
  pushl $0
80105f33:	6a 00                	push   $0x0
  pushl $104
80105f35:	6a 68                	push   $0x68
  jmp alltraps
80105f37:	e9 24 f8 ff ff       	jmp    80105760 <alltraps>

80105f3c <vector105>:
.globl vector105
vector105:
  pushl $0
80105f3c:	6a 00                	push   $0x0
  pushl $105
80105f3e:	6a 69                	push   $0x69
  jmp alltraps
80105f40:	e9 1b f8 ff ff       	jmp    80105760 <alltraps>

80105f45 <vector106>:
.globl vector106
vector106:
  pushl $0
80105f45:	6a 00                	push   $0x0
  pushl $106
80105f47:	6a 6a                	push   $0x6a
  jmp alltraps
80105f49:	e9 12 f8 ff ff       	jmp    80105760 <alltraps>

80105f4e <vector107>:
.globl vector107
vector107:
  pushl $0
80105f4e:	6a 00                	push   $0x0
  pushl $107
80105f50:	6a 6b                	push   $0x6b
  jmp alltraps
80105f52:	e9 09 f8 ff ff       	jmp    80105760 <alltraps>

80105f57 <vector108>:
.globl vector108
vector108:
  pushl $0
80105f57:	6a 00                	push   $0x0
  pushl $108
80105f59:	6a 6c                	push   $0x6c
  jmp alltraps
80105f5b:	e9 00 f8 ff ff       	jmp    80105760 <alltraps>

80105f60 <vector109>:
.globl vector109
vector109:
  pushl $0
80105f60:	6a 00                	push   $0x0
  pushl $109
80105f62:	6a 6d                	push   $0x6d
  jmp alltraps
80105f64:	e9 f7 f7 ff ff       	jmp    80105760 <alltraps>

80105f69 <vector110>:
.globl vector110
vector110:
  pushl $0
80105f69:	6a 00                	push   $0x0
  pushl $110
80105f6b:	6a 6e                	push   $0x6e
  jmp alltraps
80105f6d:	e9 ee f7 ff ff       	jmp    80105760 <alltraps>

80105f72 <vector111>:
.globl vector111
vector111:
  pushl $0
80105f72:	6a 00                	push   $0x0
  pushl $111
80105f74:	6a 6f                	push   $0x6f
  jmp alltraps
80105f76:	e9 e5 f7 ff ff       	jmp    80105760 <alltraps>

80105f7b <vector112>:
.globl vector112
vector112:
  pushl $0
80105f7b:	6a 00                	push   $0x0
  pushl $112
80105f7d:	6a 70                	push   $0x70
  jmp alltraps
80105f7f:	e9 dc f7 ff ff       	jmp    80105760 <alltraps>

80105f84 <vector113>:
.globl vector113
vector113:
  pushl $0
80105f84:	6a 00                	push   $0x0
  pushl $113
80105f86:	6a 71                	push   $0x71
  jmp alltraps
80105f88:	e9 d3 f7 ff ff       	jmp    80105760 <alltraps>

80105f8d <vector114>:
.globl vector114
vector114:
  pushl $0
80105f8d:	6a 00                	push   $0x0
  pushl $114
80105f8f:	6a 72                	push   $0x72
  jmp alltraps
80105f91:	e9 ca f7 ff ff       	jmp    80105760 <alltraps>

80105f96 <vector115>:
.globl vector115
vector115:
  pushl $0
80105f96:	6a 00                	push   $0x0
  pushl $115
80105f98:	6a 73                	push   $0x73
  jmp alltraps
80105f9a:	e9 c1 f7 ff ff       	jmp    80105760 <alltraps>

80105f9f <vector116>:
.globl vector116
vector116:
  pushl $0
80105f9f:	6a 00                	push   $0x0
  pushl $116
80105fa1:	6a 74                	push   $0x74
  jmp alltraps
80105fa3:	e9 b8 f7 ff ff       	jmp    80105760 <alltraps>

80105fa8 <vector117>:
.globl vector117
vector117:
  pushl $0
80105fa8:	6a 00                	push   $0x0
  pushl $117
80105faa:	6a 75                	push   $0x75
  jmp alltraps
80105fac:	e9 af f7 ff ff       	jmp    80105760 <alltraps>

80105fb1 <vector118>:
.globl vector118
vector118:
  pushl $0
80105fb1:	6a 00                	push   $0x0
  pushl $118
80105fb3:	6a 76                	push   $0x76
  jmp alltraps
80105fb5:	e9 a6 f7 ff ff       	jmp    80105760 <alltraps>

80105fba <vector119>:
.globl vector119
vector119:
  pushl $0
80105fba:	6a 00                	push   $0x0
  pushl $119
80105fbc:	6a 77                	push   $0x77
  jmp alltraps
80105fbe:	e9 9d f7 ff ff       	jmp    80105760 <alltraps>

80105fc3 <vector120>:
.globl vector120
vector120:
  pushl $0
80105fc3:	6a 00                	push   $0x0
  pushl $120
80105fc5:	6a 78                	push   $0x78
  jmp alltraps
80105fc7:	e9 94 f7 ff ff       	jmp    80105760 <alltraps>

80105fcc <vector121>:
.globl vector121
vector121:
  pushl $0
80105fcc:	6a 00                	push   $0x0
  pushl $121
80105fce:	6a 79                	push   $0x79
  jmp alltraps
80105fd0:	e9 8b f7 ff ff       	jmp    80105760 <alltraps>

80105fd5 <vector122>:
.globl vector122
vector122:
  pushl $0
80105fd5:	6a 00                	push   $0x0
  pushl $122
80105fd7:	6a 7a                	push   $0x7a
  jmp alltraps
80105fd9:	e9 82 f7 ff ff       	jmp    80105760 <alltraps>

80105fde <vector123>:
.globl vector123
vector123:
  pushl $0
80105fde:	6a 00                	push   $0x0
  pushl $123
80105fe0:	6a 7b                	push   $0x7b
  jmp alltraps
80105fe2:	e9 79 f7 ff ff       	jmp    80105760 <alltraps>

80105fe7 <vector124>:
.globl vector124
vector124:
  pushl $0
80105fe7:	6a 00                	push   $0x0
  pushl $124
80105fe9:	6a 7c                	push   $0x7c
  jmp alltraps
80105feb:	e9 70 f7 ff ff       	jmp    80105760 <alltraps>

80105ff0 <vector125>:
.globl vector125
vector125:
  pushl $0
80105ff0:	6a 00                	push   $0x0
  pushl $125
80105ff2:	6a 7d                	push   $0x7d
  jmp alltraps
80105ff4:	e9 67 f7 ff ff       	jmp    80105760 <alltraps>

80105ff9 <vector126>:
.globl vector126
vector126:
  pushl $0
80105ff9:	6a 00                	push   $0x0
  pushl $126
80105ffb:	6a 7e                	push   $0x7e
  jmp alltraps
80105ffd:	e9 5e f7 ff ff       	jmp    80105760 <alltraps>

80106002 <vector127>:
.globl vector127
vector127:
  pushl $0
80106002:	6a 00                	push   $0x0
  pushl $127
80106004:	6a 7f                	push   $0x7f
  jmp alltraps
80106006:	e9 55 f7 ff ff       	jmp    80105760 <alltraps>

8010600b <vector128>:
.globl vector128
vector128:
  pushl $0
8010600b:	6a 00                	push   $0x0
  pushl $128
8010600d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106012:	e9 49 f7 ff ff       	jmp    80105760 <alltraps>

80106017 <vector129>:
.globl vector129
vector129:
  pushl $0
80106017:	6a 00                	push   $0x0
  pushl $129
80106019:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010601e:	e9 3d f7 ff ff       	jmp    80105760 <alltraps>

80106023 <vector130>:
.globl vector130
vector130:
  pushl $0
80106023:	6a 00                	push   $0x0
  pushl $130
80106025:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010602a:	e9 31 f7 ff ff       	jmp    80105760 <alltraps>

8010602f <vector131>:
.globl vector131
vector131:
  pushl $0
8010602f:	6a 00                	push   $0x0
  pushl $131
80106031:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106036:	e9 25 f7 ff ff       	jmp    80105760 <alltraps>

8010603b <vector132>:
.globl vector132
vector132:
  pushl $0
8010603b:	6a 00                	push   $0x0
  pushl $132
8010603d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106042:	e9 19 f7 ff ff       	jmp    80105760 <alltraps>

80106047 <vector133>:
.globl vector133
vector133:
  pushl $0
80106047:	6a 00                	push   $0x0
  pushl $133
80106049:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010604e:	e9 0d f7 ff ff       	jmp    80105760 <alltraps>

80106053 <vector134>:
.globl vector134
vector134:
  pushl $0
80106053:	6a 00                	push   $0x0
  pushl $134
80106055:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010605a:	e9 01 f7 ff ff       	jmp    80105760 <alltraps>

8010605f <vector135>:
.globl vector135
vector135:
  pushl $0
8010605f:	6a 00                	push   $0x0
  pushl $135
80106061:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106066:	e9 f5 f6 ff ff       	jmp    80105760 <alltraps>

8010606b <vector136>:
.globl vector136
vector136:
  pushl $0
8010606b:	6a 00                	push   $0x0
  pushl $136
8010606d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106072:	e9 e9 f6 ff ff       	jmp    80105760 <alltraps>

80106077 <vector137>:
.globl vector137
vector137:
  pushl $0
80106077:	6a 00                	push   $0x0
  pushl $137
80106079:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010607e:	e9 dd f6 ff ff       	jmp    80105760 <alltraps>

80106083 <vector138>:
.globl vector138
vector138:
  pushl $0
80106083:	6a 00                	push   $0x0
  pushl $138
80106085:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010608a:	e9 d1 f6 ff ff       	jmp    80105760 <alltraps>

8010608f <vector139>:
.globl vector139
vector139:
  pushl $0
8010608f:	6a 00                	push   $0x0
  pushl $139
80106091:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106096:	e9 c5 f6 ff ff       	jmp    80105760 <alltraps>

8010609b <vector140>:
.globl vector140
vector140:
  pushl $0
8010609b:	6a 00                	push   $0x0
  pushl $140
8010609d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801060a2:	e9 b9 f6 ff ff       	jmp    80105760 <alltraps>

801060a7 <vector141>:
.globl vector141
vector141:
  pushl $0
801060a7:	6a 00                	push   $0x0
  pushl $141
801060a9:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801060ae:	e9 ad f6 ff ff       	jmp    80105760 <alltraps>

801060b3 <vector142>:
.globl vector142
vector142:
  pushl $0
801060b3:	6a 00                	push   $0x0
  pushl $142
801060b5:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801060ba:	e9 a1 f6 ff ff       	jmp    80105760 <alltraps>

801060bf <vector143>:
.globl vector143
vector143:
  pushl $0
801060bf:	6a 00                	push   $0x0
  pushl $143
801060c1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801060c6:	e9 95 f6 ff ff       	jmp    80105760 <alltraps>

801060cb <vector144>:
.globl vector144
vector144:
  pushl $0
801060cb:	6a 00                	push   $0x0
  pushl $144
801060cd:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801060d2:	e9 89 f6 ff ff       	jmp    80105760 <alltraps>

801060d7 <vector145>:
.globl vector145
vector145:
  pushl $0
801060d7:	6a 00                	push   $0x0
  pushl $145
801060d9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801060de:	e9 7d f6 ff ff       	jmp    80105760 <alltraps>

801060e3 <vector146>:
.globl vector146
vector146:
  pushl $0
801060e3:	6a 00                	push   $0x0
  pushl $146
801060e5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801060ea:	e9 71 f6 ff ff       	jmp    80105760 <alltraps>

801060ef <vector147>:
.globl vector147
vector147:
  pushl $0
801060ef:	6a 00                	push   $0x0
  pushl $147
801060f1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801060f6:	e9 65 f6 ff ff       	jmp    80105760 <alltraps>

801060fb <vector148>:
.globl vector148
vector148:
  pushl $0
801060fb:	6a 00                	push   $0x0
  pushl $148
801060fd:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106102:	e9 59 f6 ff ff       	jmp    80105760 <alltraps>

80106107 <vector149>:
.globl vector149
vector149:
  pushl $0
80106107:	6a 00                	push   $0x0
  pushl $149
80106109:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010610e:	e9 4d f6 ff ff       	jmp    80105760 <alltraps>

80106113 <vector150>:
.globl vector150
vector150:
  pushl $0
80106113:	6a 00                	push   $0x0
  pushl $150
80106115:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010611a:	e9 41 f6 ff ff       	jmp    80105760 <alltraps>

8010611f <vector151>:
.globl vector151
vector151:
  pushl $0
8010611f:	6a 00                	push   $0x0
  pushl $151
80106121:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106126:	e9 35 f6 ff ff       	jmp    80105760 <alltraps>

8010612b <vector152>:
.globl vector152
vector152:
  pushl $0
8010612b:	6a 00                	push   $0x0
  pushl $152
8010612d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106132:	e9 29 f6 ff ff       	jmp    80105760 <alltraps>

80106137 <vector153>:
.globl vector153
vector153:
  pushl $0
80106137:	6a 00                	push   $0x0
  pushl $153
80106139:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010613e:	e9 1d f6 ff ff       	jmp    80105760 <alltraps>

80106143 <vector154>:
.globl vector154
vector154:
  pushl $0
80106143:	6a 00                	push   $0x0
  pushl $154
80106145:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010614a:	e9 11 f6 ff ff       	jmp    80105760 <alltraps>

8010614f <vector155>:
.globl vector155
vector155:
  pushl $0
8010614f:	6a 00                	push   $0x0
  pushl $155
80106151:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106156:	e9 05 f6 ff ff       	jmp    80105760 <alltraps>

8010615b <vector156>:
.globl vector156
vector156:
  pushl $0
8010615b:	6a 00                	push   $0x0
  pushl $156
8010615d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106162:	e9 f9 f5 ff ff       	jmp    80105760 <alltraps>

80106167 <vector157>:
.globl vector157
vector157:
  pushl $0
80106167:	6a 00                	push   $0x0
  pushl $157
80106169:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010616e:	e9 ed f5 ff ff       	jmp    80105760 <alltraps>

80106173 <vector158>:
.globl vector158
vector158:
  pushl $0
80106173:	6a 00                	push   $0x0
  pushl $158
80106175:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010617a:	e9 e1 f5 ff ff       	jmp    80105760 <alltraps>

8010617f <vector159>:
.globl vector159
vector159:
  pushl $0
8010617f:	6a 00                	push   $0x0
  pushl $159
80106181:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106186:	e9 d5 f5 ff ff       	jmp    80105760 <alltraps>

8010618b <vector160>:
.globl vector160
vector160:
  pushl $0
8010618b:	6a 00                	push   $0x0
  pushl $160
8010618d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106192:	e9 c9 f5 ff ff       	jmp    80105760 <alltraps>

80106197 <vector161>:
.globl vector161
vector161:
  pushl $0
80106197:	6a 00                	push   $0x0
  pushl $161
80106199:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010619e:	e9 bd f5 ff ff       	jmp    80105760 <alltraps>

801061a3 <vector162>:
.globl vector162
vector162:
  pushl $0
801061a3:	6a 00                	push   $0x0
  pushl $162
801061a5:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801061aa:	e9 b1 f5 ff ff       	jmp    80105760 <alltraps>

801061af <vector163>:
.globl vector163
vector163:
  pushl $0
801061af:	6a 00                	push   $0x0
  pushl $163
801061b1:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801061b6:	e9 a5 f5 ff ff       	jmp    80105760 <alltraps>

801061bb <vector164>:
.globl vector164
vector164:
  pushl $0
801061bb:	6a 00                	push   $0x0
  pushl $164
801061bd:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801061c2:	e9 99 f5 ff ff       	jmp    80105760 <alltraps>

801061c7 <vector165>:
.globl vector165
vector165:
  pushl $0
801061c7:	6a 00                	push   $0x0
  pushl $165
801061c9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801061ce:	e9 8d f5 ff ff       	jmp    80105760 <alltraps>

801061d3 <vector166>:
.globl vector166
vector166:
  pushl $0
801061d3:	6a 00                	push   $0x0
  pushl $166
801061d5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801061da:	e9 81 f5 ff ff       	jmp    80105760 <alltraps>

801061df <vector167>:
.globl vector167
vector167:
  pushl $0
801061df:	6a 00                	push   $0x0
  pushl $167
801061e1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801061e6:	e9 75 f5 ff ff       	jmp    80105760 <alltraps>

801061eb <vector168>:
.globl vector168
vector168:
  pushl $0
801061eb:	6a 00                	push   $0x0
  pushl $168
801061ed:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801061f2:	e9 69 f5 ff ff       	jmp    80105760 <alltraps>

801061f7 <vector169>:
.globl vector169
vector169:
  pushl $0
801061f7:	6a 00                	push   $0x0
  pushl $169
801061f9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801061fe:	e9 5d f5 ff ff       	jmp    80105760 <alltraps>

80106203 <vector170>:
.globl vector170
vector170:
  pushl $0
80106203:	6a 00                	push   $0x0
  pushl $170
80106205:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010620a:	e9 51 f5 ff ff       	jmp    80105760 <alltraps>

8010620f <vector171>:
.globl vector171
vector171:
  pushl $0
8010620f:	6a 00                	push   $0x0
  pushl $171
80106211:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106216:	e9 45 f5 ff ff       	jmp    80105760 <alltraps>

8010621b <vector172>:
.globl vector172
vector172:
  pushl $0
8010621b:	6a 00                	push   $0x0
  pushl $172
8010621d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106222:	e9 39 f5 ff ff       	jmp    80105760 <alltraps>

80106227 <vector173>:
.globl vector173
vector173:
  pushl $0
80106227:	6a 00                	push   $0x0
  pushl $173
80106229:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
8010622e:	e9 2d f5 ff ff       	jmp    80105760 <alltraps>

80106233 <vector174>:
.globl vector174
vector174:
  pushl $0
80106233:	6a 00                	push   $0x0
  pushl $174
80106235:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010623a:	e9 21 f5 ff ff       	jmp    80105760 <alltraps>

8010623f <vector175>:
.globl vector175
vector175:
  pushl $0
8010623f:	6a 00                	push   $0x0
  pushl $175
80106241:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106246:	e9 15 f5 ff ff       	jmp    80105760 <alltraps>

8010624b <vector176>:
.globl vector176
vector176:
  pushl $0
8010624b:	6a 00                	push   $0x0
  pushl $176
8010624d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106252:	e9 09 f5 ff ff       	jmp    80105760 <alltraps>

80106257 <vector177>:
.globl vector177
vector177:
  pushl $0
80106257:	6a 00                	push   $0x0
  pushl $177
80106259:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
8010625e:	e9 fd f4 ff ff       	jmp    80105760 <alltraps>

80106263 <vector178>:
.globl vector178
vector178:
  pushl $0
80106263:	6a 00                	push   $0x0
  pushl $178
80106265:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
8010626a:	e9 f1 f4 ff ff       	jmp    80105760 <alltraps>

8010626f <vector179>:
.globl vector179
vector179:
  pushl $0
8010626f:	6a 00                	push   $0x0
  pushl $179
80106271:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106276:	e9 e5 f4 ff ff       	jmp    80105760 <alltraps>

8010627b <vector180>:
.globl vector180
vector180:
  pushl $0
8010627b:	6a 00                	push   $0x0
  pushl $180
8010627d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106282:	e9 d9 f4 ff ff       	jmp    80105760 <alltraps>

80106287 <vector181>:
.globl vector181
vector181:
  pushl $0
80106287:	6a 00                	push   $0x0
  pushl $181
80106289:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010628e:	e9 cd f4 ff ff       	jmp    80105760 <alltraps>

80106293 <vector182>:
.globl vector182
vector182:
  pushl $0
80106293:	6a 00                	push   $0x0
  pushl $182
80106295:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
8010629a:	e9 c1 f4 ff ff       	jmp    80105760 <alltraps>

8010629f <vector183>:
.globl vector183
vector183:
  pushl $0
8010629f:	6a 00                	push   $0x0
  pushl $183
801062a1:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801062a6:	e9 b5 f4 ff ff       	jmp    80105760 <alltraps>

801062ab <vector184>:
.globl vector184
vector184:
  pushl $0
801062ab:	6a 00                	push   $0x0
  pushl $184
801062ad:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801062b2:	e9 a9 f4 ff ff       	jmp    80105760 <alltraps>

801062b7 <vector185>:
.globl vector185
vector185:
  pushl $0
801062b7:	6a 00                	push   $0x0
  pushl $185
801062b9:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801062be:	e9 9d f4 ff ff       	jmp    80105760 <alltraps>

801062c3 <vector186>:
.globl vector186
vector186:
  pushl $0
801062c3:	6a 00                	push   $0x0
  pushl $186
801062c5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801062ca:	e9 91 f4 ff ff       	jmp    80105760 <alltraps>

801062cf <vector187>:
.globl vector187
vector187:
  pushl $0
801062cf:	6a 00                	push   $0x0
  pushl $187
801062d1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801062d6:	e9 85 f4 ff ff       	jmp    80105760 <alltraps>

801062db <vector188>:
.globl vector188
vector188:
  pushl $0
801062db:	6a 00                	push   $0x0
  pushl $188
801062dd:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801062e2:	e9 79 f4 ff ff       	jmp    80105760 <alltraps>

801062e7 <vector189>:
.globl vector189
vector189:
  pushl $0
801062e7:	6a 00                	push   $0x0
  pushl $189
801062e9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801062ee:	e9 6d f4 ff ff       	jmp    80105760 <alltraps>

801062f3 <vector190>:
.globl vector190
vector190:
  pushl $0
801062f3:	6a 00                	push   $0x0
  pushl $190
801062f5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801062fa:	e9 61 f4 ff ff       	jmp    80105760 <alltraps>

801062ff <vector191>:
.globl vector191
vector191:
  pushl $0
801062ff:	6a 00                	push   $0x0
  pushl $191
80106301:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106306:	e9 55 f4 ff ff       	jmp    80105760 <alltraps>

8010630b <vector192>:
.globl vector192
vector192:
  pushl $0
8010630b:	6a 00                	push   $0x0
  pushl $192
8010630d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106312:	e9 49 f4 ff ff       	jmp    80105760 <alltraps>

80106317 <vector193>:
.globl vector193
vector193:
  pushl $0
80106317:	6a 00                	push   $0x0
  pushl $193
80106319:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
8010631e:	e9 3d f4 ff ff       	jmp    80105760 <alltraps>

80106323 <vector194>:
.globl vector194
vector194:
  pushl $0
80106323:	6a 00                	push   $0x0
  pushl $194
80106325:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010632a:	e9 31 f4 ff ff       	jmp    80105760 <alltraps>

8010632f <vector195>:
.globl vector195
vector195:
  pushl $0
8010632f:	6a 00                	push   $0x0
  pushl $195
80106331:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106336:	e9 25 f4 ff ff       	jmp    80105760 <alltraps>

8010633b <vector196>:
.globl vector196
vector196:
  pushl $0
8010633b:	6a 00                	push   $0x0
  pushl $196
8010633d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106342:	e9 19 f4 ff ff       	jmp    80105760 <alltraps>

80106347 <vector197>:
.globl vector197
vector197:
  pushl $0
80106347:	6a 00                	push   $0x0
  pushl $197
80106349:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010634e:	e9 0d f4 ff ff       	jmp    80105760 <alltraps>

80106353 <vector198>:
.globl vector198
vector198:
  pushl $0
80106353:	6a 00                	push   $0x0
  pushl $198
80106355:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010635a:	e9 01 f4 ff ff       	jmp    80105760 <alltraps>

8010635f <vector199>:
.globl vector199
vector199:
  pushl $0
8010635f:	6a 00                	push   $0x0
  pushl $199
80106361:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106366:	e9 f5 f3 ff ff       	jmp    80105760 <alltraps>

8010636b <vector200>:
.globl vector200
vector200:
  pushl $0
8010636b:	6a 00                	push   $0x0
  pushl $200
8010636d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106372:	e9 e9 f3 ff ff       	jmp    80105760 <alltraps>

80106377 <vector201>:
.globl vector201
vector201:
  pushl $0
80106377:	6a 00                	push   $0x0
  pushl $201
80106379:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010637e:	e9 dd f3 ff ff       	jmp    80105760 <alltraps>

80106383 <vector202>:
.globl vector202
vector202:
  pushl $0
80106383:	6a 00                	push   $0x0
  pushl $202
80106385:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
8010638a:	e9 d1 f3 ff ff       	jmp    80105760 <alltraps>

8010638f <vector203>:
.globl vector203
vector203:
  pushl $0
8010638f:	6a 00                	push   $0x0
  pushl $203
80106391:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106396:	e9 c5 f3 ff ff       	jmp    80105760 <alltraps>

8010639b <vector204>:
.globl vector204
vector204:
  pushl $0
8010639b:	6a 00                	push   $0x0
  pushl $204
8010639d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801063a2:	e9 b9 f3 ff ff       	jmp    80105760 <alltraps>

801063a7 <vector205>:
.globl vector205
vector205:
  pushl $0
801063a7:	6a 00                	push   $0x0
  pushl $205
801063a9:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801063ae:	e9 ad f3 ff ff       	jmp    80105760 <alltraps>

801063b3 <vector206>:
.globl vector206
vector206:
  pushl $0
801063b3:	6a 00                	push   $0x0
  pushl $206
801063b5:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801063ba:	e9 a1 f3 ff ff       	jmp    80105760 <alltraps>

801063bf <vector207>:
.globl vector207
vector207:
  pushl $0
801063bf:	6a 00                	push   $0x0
  pushl $207
801063c1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801063c6:	e9 95 f3 ff ff       	jmp    80105760 <alltraps>

801063cb <vector208>:
.globl vector208
vector208:
  pushl $0
801063cb:	6a 00                	push   $0x0
  pushl $208
801063cd:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801063d2:	e9 89 f3 ff ff       	jmp    80105760 <alltraps>

801063d7 <vector209>:
.globl vector209
vector209:
  pushl $0
801063d7:	6a 00                	push   $0x0
  pushl $209
801063d9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801063de:	e9 7d f3 ff ff       	jmp    80105760 <alltraps>

801063e3 <vector210>:
.globl vector210
vector210:
  pushl $0
801063e3:	6a 00                	push   $0x0
  pushl $210
801063e5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801063ea:	e9 71 f3 ff ff       	jmp    80105760 <alltraps>

801063ef <vector211>:
.globl vector211
vector211:
  pushl $0
801063ef:	6a 00                	push   $0x0
  pushl $211
801063f1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801063f6:	e9 65 f3 ff ff       	jmp    80105760 <alltraps>

801063fb <vector212>:
.globl vector212
vector212:
  pushl $0
801063fb:	6a 00                	push   $0x0
  pushl $212
801063fd:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106402:	e9 59 f3 ff ff       	jmp    80105760 <alltraps>

80106407 <vector213>:
.globl vector213
vector213:
  pushl $0
80106407:	6a 00                	push   $0x0
  pushl $213
80106409:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
8010640e:	e9 4d f3 ff ff       	jmp    80105760 <alltraps>

80106413 <vector214>:
.globl vector214
vector214:
  pushl $0
80106413:	6a 00                	push   $0x0
  pushl $214
80106415:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010641a:	e9 41 f3 ff ff       	jmp    80105760 <alltraps>

8010641f <vector215>:
.globl vector215
vector215:
  pushl $0
8010641f:	6a 00                	push   $0x0
  pushl $215
80106421:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106426:	e9 35 f3 ff ff       	jmp    80105760 <alltraps>

8010642b <vector216>:
.globl vector216
vector216:
  pushl $0
8010642b:	6a 00                	push   $0x0
  pushl $216
8010642d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106432:	e9 29 f3 ff ff       	jmp    80105760 <alltraps>

80106437 <vector217>:
.globl vector217
vector217:
  pushl $0
80106437:	6a 00                	push   $0x0
  pushl $217
80106439:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010643e:	e9 1d f3 ff ff       	jmp    80105760 <alltraps>

80106443 <vector218>:
.globl vector218
vector218:
  pushl $0
80106443:	6a 00                	push   $0x0
  pushl $218
80106445:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010644a:	e9 11 f3 ff ff       	jmp    80105760 <alltraps>

8010644f <vector219>:
.globl vector219
vector219:
  pushl $0
8010644f:	6a 00                	push   $0x0
  pushl $219
80106451:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106456:	e9 05 f3 ff ff       	jmp    80105760 <alltraps>

8010645b <vector220>:
.globl vector220
vector220:
  pushl $0
8010645b:	6a 00                	push   $0x0
  pushl $220
8010645d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106462:	e9 f9 f2 ff ff       	jmp    80105760 <alltraps>

80106467 <vector221>:
.globl vector221
vector221:
  pushl $0
80106467:	6a 00                	push   $0x0
  pushl $221
80106469:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010646e:	e9 ed f2 ff ff       	jmp    80105760 <alltraps>

80106473 <vector222>:
.globl vector222
vector222:
  pushl $0
80106473:	6a 00                	push   $0x0
  pushl $222
80106475:	68 de 00 00 00       	push   $0xde
  jmp alltraps
8010647a:	e9 e1 f2 ff ff       	jmp    80105760 <alltraps>

8010647f <vector223>:
.globl vector223
vector223:
  pushl $0
8010647f:	6a 00                	push   $0x0
  pushl $223
80106481:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106486:	e9 d5 f2 ff ff       	jmp    80105760 <alltraps>

8010648b <vector224>:
.globl vector224
vector224:
  pushl $0
8010648b:	6a 00                	push   $0x0
  pushl $224
8010648d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106492:	e9 c9 f2 ff ff       	jmp    80105760 <alltraps>

80106497 <vector225>:
.globl vector225
vector225:
  pushl $0
80106497:	6a 00                	push   $0x0
  pushl $225
80106499:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010649e:	e9 bd f2 ff ff       	jmp    80105760 <alltraps>

801064a3 <vector226>:
.globl vector226
vector226:
  pushl $0
801064a3:	6a 00                	push   $0x0
  pushl $226
801064a5:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801064aa:	e9 b1 f2 ff ff       	jmp    80105760 <alltraps>

801064af <vector227>:
.globl vector227
vector227:
  pushl $0
801064af:	6a 00                	push   $0x0
  pushl $227
801064b1:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801064b6:	e9 a5 f2 ff ff       	jmp    80105760 <alltraps>

801064bb <vector228>:
.globl vector228
vector228:
  pushl $0
801064bb:	6a 00                	push   $0x0
  pushl $228
801064bd:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801064c2:	e9 99 f2 ff ff       	jmp    80105760 <alltraps>

801064c7 <vector229>:
.globl vector229
vector229:
  pushl $0
801064c7:	6a 00                	push   $0x0
  pushl $229
801064c9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801064ce:	e9 8d f2 ff ff       	jmp    80105760 <alltraps>

801064d3 <vector230>:
.globl vector230
vector230:
  pushl $0
801064d3:	6a 00                	push   $0x0
  pushl $230
801064d5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801064da:	e9 81 f2 ff ff       	jmp    80105760 <alltraps>

801064df <vector231>:
.globl vector231
vector231:
  pushl $0
801064df:	6a 00                	push   $0x0
  pushl $231
801064e1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801064e6:	e9 75 f2 ff ff       	jmp    80105760 <alltraps>

801064eb <vector232>:
.globl vector232
vector232:
  pushl $0
801064eb:	6a 00                	push   $0x0
  pushl $232
801064ed:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801064f2:	e9 69 f2 ff ff       	jmp    80105760 <alltraps>

801064f7 <vector233>:
.globl vector233
vector233:
  pushl $0
801064f7:	6a 00                	push   $0x0
  pushl $233
801064f9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801064fe:	e9 5d f2 ff ff       	jmp    80105760 <alltraps>

80106503 <vector234>:
.globl vector234
vector234:
  pushl $0
80106503:	6a 00                	push   $0x0
  pushl $234
80106505:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010650a:	e9 51 f2 ff ff       	jmp    80105760 <alltraps>

8010650f <vector235>:
.globl vector235
vector235:
  pushl $0
8010650f:	6a 00                	push   $0x0
  pushl $235
80106511:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106516:	e9 45 f2 ff ff       	jmp    80105760 <alltraps>

8010651b <vector236>:
.globl vector236
vector236:
  pushl $0
8010651b:	6a 00                	push   $0x0
  pushl $236
8010651d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106522:	e9 39 f2 ff ff       	jmp    80105760 <alltraps>

80106527 <vector237>:
.globl vector237
vector237:
  pushl $0
80106527:	6a 00                	push   $0x0
  pushl $237
80106529:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010652e:	e9 2d f2 ff ff       	jmp    80105760 <alltraps>

80106533 <vector238>:
.globl vector238
vector238:
  pushl $0
80106533:	6a 00                	push   $0x0
  pushl $238
80106535:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010653a:	e9 21 f2 ff ff       	jmp    80105760 <alltraps>

8010653f <vector239>:
.globl vector239
vector239:
  pushl $0
8010653f:	6a 00                	push   $0x0
  pushl $239
80106541:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106546:	e9 15 f2 ff ff       	jmp    80105760 <alltraps>

8010654b <vector240>:
.globl vector240
vector240:
  pushl $0
8010654b:	6a 00                	push   $0x0
  pushl $240
8010654d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106552:	e9 09 f2 ff ff       	jmp    80105760 <alltraps>

80106557 <vector241>:
.globl vector241
vector241:
  pushl $0
80106557:	6a 00                	push   $0x0
  pushl $241
80106559:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010655e:	e9 fd f1 ff ff       	jmp    80105760 <alltraps>

80106563 <vector242>:
.globl vector242
vector242:
  pushl $0
80106563:	6a 00                	push   $0x0
  pushl $242
80106565:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
8010656a:	e9 f1 f1 ff ff       	jmp    80105760 <alltraps>

8010656f <vector243>:
.globl vector243
vector243:
  pushl $0
8010656f:	6a 00                	push   $0x0
  pushl $243
80106571:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106576:	e9 e5 f1 ff ff       	jmp    80105760 <alltraps>

8010657b <vector244>:
.globl vector244
vector244:
  pushl $0
8010657b:	6a 00                	push   $0x0
  pushl $244
8010657d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106582:	e9 d9 f1 ff ff       	jmp    80105760 <alltraps>

80106587 <vector245>:
.globl vector245
vector245:
  pushl $0
80106587:	6a 00                	push   $0x0
  pushl $245
80106589:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010658e:	e9 cd f1 ff ff       	jmp    80105760 <alltraps>

80106593 <vector246>:
.globl vector246
vector246:
  pushl $0
80106593:	6a 00                	push   $0x0
  pushl $246
80106595:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
8010659a:	e9 c1 f1 ff ff       	jmp    80105760 <alltraps>

8010659f <vector247>:
.globl vector247
vector247:
  pushl $0
8010659f:	6a 00                	push   $0x0
  pushl $247
801065a1:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801065a6:	e9 b5 f1 ff ff       	jmp    80105760 <alltraps>

801065ab <vector248>:
.globl vector248
vector248:
  pushl $0
801065ab:	6a 00                	push   $0x0
  pushl $248
801065ad:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801065b2:	e9 a9 f1 ff ff       	jmp    80105760 <alltraps>

801065b7 <vector249>:
.globl vector249
vector249:
  pushl $0
801065b7:	6a 00                	push   $0x0
  pushl $249
801065b9:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801065be:	e9 9d f1 ff ff       	jmp    80105760 <alltraps>

801065c3 <vector250>:
.globl vector250
vector250:
  pushl $0
801065c3:	6a 00                	push   $0x0
  pushl $250
801065c5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801065ca:	e9 91 f1 ff ff       	jmp    80105760 <alltraps>

801065cf <vector251>:
.globl vector251
vector251:
  pushl $0
801065cf:	6a 00                	push   $0x0
  pushl $251
801065d1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801065d6:	e9 85 f1 ff ff       	jmp    80105760 <alltraps>

801065db <vector252>:
.globl vector252
vector252:
  pushl $0
801065db:	6a 00                	push   $0x0
  pushl $252
801065dd:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801065e2:	e9 79 f1 ff ff       	jmp    80105760 <alltraps>

801065e7 <vector253>:
.globl vector253
vector253:
  pushl $0
801065e7:	6a 00                	push   $0x0
  pushl $253
801065e9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801065ee:	e9 6d f1 ff ff       	jmp    80105760 <alltraps>

801065f3 <vector254>:
.globl vector254
vector254:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $254
801065f5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801065fa:	e9 61 f1 ff ff       	jmp    80105760 <alltraps>

801065ff <vector255>:
.globl vector255
vector255:
  pushl $0
801065ff:	6a 00                	push   $0x0
  pushl $255
80106601:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106606:	e9 55 f1 ff ff       	jmp    80105760 <alltraps>

8010660b <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010660b:	55                   	push   %ebp
8010660c:	89 e5                	mov    %esp,%ebp
8010660e:	57                   	push   %edi
8010660f:	56                   	push   %esi
80106610:	53                   	push   %ebx
80106611:	83 ec 0c             	sub    $0xc,%esp
80106614:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106616:	c1 ea 16             	shr    $0x16,%edx
80106619:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
8010661c:	8b 1f                	mov    (%edi),%ebx
8010661e:	f6 c3 01             	test   $0x1,%bl
80106621:	74 22                	je     80106645 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106623:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106629:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
8010662f:	c1 ee 0c             	shr    $0xc,%esi
80106632:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80106638:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
8010663b:	89 d8                	mov    %ebx,%eax
8010663d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106640:	5b                   	pop    %ebx
80106641:	5e                   	pop    %esi
80106642:	5f                   	pop    %edi
80106643:	5d                   	pop    %ebp
80106644:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106645:	85 c9                	test   %ecx,%ecx
80106647:	74 2b                	je     80106674 <walkpgdir+0x69>
80106649:	e8 6d ba ff ff       	call   801020bb <kalloc>
8010664e:	89 c3                	mov    %eax,%ebx
80106650:	85 c0                	test   %eax,%eax
80106652:	74 e7                	je     8010663b <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80106654:	83 ec 04             	sub    $0x4,%esp
80106657:	68 00 10 00 00       	push   $0x1000
8010665c:	6a 00                	push   $0x0
8010665e:	50                   	push   %eax
8010665f:	e8 8f df ff ff       	call   801045f3 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106664:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010666a:	83 c8 07             	or     $0x7,%eax
8010666d:	89 07                	mov    %eax,(%edi)
8010666f:	83 c4 10             	add    $0x10,%esp
80106672:	eb bb                	jmp    8010662f <walkpgdir+0x24>
      return 0;
80106674:	bb 00 00 00 00       	mov    $0x0,%ebx
80106679:	eb c0                	jmp    8010663b <walkpgdir+0x30>

8010667b <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010667b:	55                   	push   %ebp
8010667c:	89 e5                	mov    %esp,%ebp
8010667e:	57                   	push   %edi
8010667f:	56                   	push   %esi
80106680:	53                   	push   %ebx
80106681:	83 ec 1c             	sub    $0x1c,%esp
80106684:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106687:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010668a:	89 d3                	mov    %edx,%ebx
8010668c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106692:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80106696:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010669c:	b9 01 00 00 00       	mov    $0x1,%ecx
801066a1:	89 da                	mov    %ebx,%edx
801066a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066a6:	e8 60 ff ff ff       	call   8010660b <walkpgdir>
801066ab:	85 c0                	test   %eax,%eax
801066ad:	74 2e                	je     801066dd <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
801066af:	f6 00 01             	testb  $0x1,(%eax)
801066b2:	75 1c                	jne    801066d0 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
801066b4:	89 f2                	mov    %esi,%edx
801066b6:	0b 55 0c             	or     0xc(%ebp),%edx
801066b9:	83 ca 01             	or     $0x1,%edx
801066bc:	89 10                	mov    %edx,(%eax)
    if(a == last)
801066be:	39 fb                	cmp    %edi,%ebx
801066c0:	74 28                	je     801066ea <mappages+0x6f>
      break;
    a += PGSIZE;
801066c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
801066c8:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801066ce:	eb cc                	jmp    8010669c <mappages+0x21>
      panic("remap");
801066d0:	83 ec 0c             	sub    $0xc,%esp
801066d3:	68 98 77 10 80       	push   $0x80107798
801066d8:	e8 6b 9c ff ff       	call   80100348 <panic>
      return -1;
801066dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801066e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801066e5:	5b                   	pop    %ebx
801066e6:	5e                   	pop    %esi
801066e7:	5f                   	pop    %edi
801066e8:	5d                   	pop    %ebp
801066e9:	c3                   	ret    
  return 0;
801066ea:	b8 00 00 00 00       	mov    $0x0,%eax
801066ef:	eb f1                	jmp    801066e2 <mappages+0x67>

801066f1 <seginit>:
{
801066f1:	55                   	push   %ebp
801066f2:	89 e5                	mov    %esp,%ebp
801066f4:	53                   	push   %ebx
801066f5:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
801066f8:	e8 b6 ca ff ff       	call   801031b3 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801066fd:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106703:	66 c7 80 18 2c 11 80 	movw   $0xffff,-0x7feed3e8(%eax)
8010670a:	ff ff 
8010670c:	66 c7 80 1a 2c 11 80 	movw   $0x0,-0x7feed3e6(%eax)
80106713:	00 00 
80106715:	c6 80 1c 2c 11 80 00 	movb   $0x0,-0x7feed3e4(%eax)
8010671c:	0f b6 88 1d 2c 11 80 	movzbl -0x7feed3e3(%eax),%ecx
80106723:	83 e1 f0             	and    $0xfffffff0,%ecx
80106726:	83 c9 1a             	or     $0x1a,%ecx
80106729:	83 e1 9f             	and    $0xffffff9f,%ecx
8010672c:	83 c9 80             	or     $0xffffff80,%ecx
8010672f:	88 88 1d 2c 11 80    	mov    %cl,-0x7feed3e3(%eax)
80106735:	0f b6 88 1e 2c 11 80 	movzbl -0x7feed3e2(%eax),%ecx
8010673c:	83 c9 0f             	or     $0xf,%ecx
8010673f:	83 e1 cf             	and    $0xffffffcf,%ecx
80106742:	83 c9 c0             	or     $0xffffffc0,%ecx
80106745:	88 88 1e 2c 11 80    	mov    %cl,-0x7feed3e2(%eax)
8010674b:	c6 80 1f 2c 11 80 00 	movb   $0x0,-0x7feed3e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106752:	66 c7 80 20 2c 11 80 	movw   $0xffff,-0x7feed3e0(%eax)
80106759:	ff ff 
8010675b:	66 c7 80 22 2c 11 80 	movw   $0x0,-0x7feed3de(%eax)
80106762:	00 00 
80106764:	c6 80 24 2c 11 80 00 	movb   $0x0,-0x7feed3dc(%eax)
8010676b:	0f b6 88 25 2c 11 80 	movzbl -0x7feed3db(%eax),%ecx
80106772:	83 e1 f0             	and    $0xfffffff0,%ecx
80106775:	83 c9 12             	or     $0x12,%ecx
80106778:	83 e1 9f             	and    $0xffffff9f,%ecx
8010677b:	83 c9 80             	or     $0xffffff80,%ecx
8010677e:	88 88 25 2c 11 80    	mov    %cl,-0x7feed3db(%eax)
80106784:	0f b6 88 26 2c 11 80 	movzbl -0x7feed3da(%eax),%ecx
8010678b:	83 c9 0f             	or     $0xf,%ecx
8010678e:	83 e1 cf             	and    $0xffffffcf,%ecx
80106791:	83 c9 c0             	or     $0xffffffc0,%ecx
80106794:	88 88 26 2c 11 80    	mov    %cl,-0x7feed3da(%eax)
8010679a:	c6 80 27 2c 11 80 00 	movb   $0x0,-0x7feed3d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801067a1:	66 c7 80 28 2c 11 80 	movw   $0xffff,-0x7feed3d8(%eax)
801067a8:	ff ff 
801067aa:	66 c7 80 2a 2c 11 80 	movw   $0x0,-0x7feed3d6(%eax)
801067b1:	00 00 
801067b3:	c6 80 2c 2c 11 80 00 	movb   $0x0,-0x7feed3d4(%eax)
801067ba:	c6 80 2d 2c 11 80 fa 	movb   $0xfa,-0x7feed3d3(%eax)
801067c1:	0f b6 88 2e 2c 11 80 	movzbl -0x7feed3d2(%eax),%ecx
801067c8:	83 c9 0f             	or     $0xf,%ecx
801067cb:	83 e1 cf             	and    $0xffffffcf,%ecx
801067ce:	83 c9 c0             	or     $0xffffffc0,%ecx
801067d1:	88 88 2e 2c 11 80    	mov    %cl,-0x7feed3d2(%eax)
801067d7:	c6 80 2f 2c 11 80 00 	movb   $0x0,-0x7feed3d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801067de:	66 c7 80 30 2c 11 80 	movw   $0xffff,-0x7feed3d0(%eax)
801067e5:	ff ff 
801067e7:	66 c7 80 32 2c 11 80 	movw   $0x0,-0x7feed3ce(%eax)
801067ee:	00 00 
801067f0:	c6 80 34 2c 11 80 00 	movb   $0x0,-0x7feed3cc(%eax)
801067f7:	c6 80 35 2c 11 80 f2 	movb   $0xf2,-0x7feed3cb(%eax)
801067fe:	0f b6 88 36 2c 11 80 	movzbl -0x7feed3ca(%eax),%ecx
80106805:	83 c9 0f             	or     $0xf,%ecx
80106808:	83 e1 cf             	and    $0xffffffcf,%ecx
8010680b:	83 c9 c0             	or     $0xffffffc0,%ecx
8010680e:	88 88 36 2c 11 80    	mov    %cl,-0x7feed3ca(%eax)
80106814:	c6 80 37 2c 11 80 00 	movb   $0x0,-0x7feed3c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
8010681b:	05 10 2c 11 80       	add    $0x80112c10,%eax
  pd[0] = size-1;
80106820:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106826:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
8010682a:	c1 e8 10             	shr    $0x10,%eax
8010682d:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106831:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106834:	0f 01 10             	lgdtl  (%eax)
}
80106837:	83 c4 14             	add    $0x14,%esp
8010683a:	5b                   	pop    %ebx
8010683b:	5d                   	pop    %ebp
8010683c:	c3                   	ret    

8010683d <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010683d:	55                   	push   %ebp
8010683e:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106840:	a1 c4 65 11 80       	mov    0x801165c4,%eax
80106845:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010684a:	0f 22 d8             	mov    %eax,%cr3
}
8010684d:	5d                   	pop    %ebp
8010684e:	c3                   	ret    

8010684f <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010684f:	55                   	push   %ebp
80106850:	89 e5                	mov    %esp,%ebp
80106852:	57                   	push   %edi
80106853:	56                   	push   %esi
80106854:	53                   	push   %ebx
80106855:	83 ec 1c             	sub    $0x1c,%esp
80106858:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
8010685b:	85 f6                	test   %esi,%esi
8010685d:	0f 84 dd 00 00 00    	je     80106940 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106863:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106867:	0f 84 e0 00 00 00    	je     8010694d <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010686d:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106871:	0f 84 e3 00 00 00    	je     8010695a <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80106877:	e8 ee db ff ff       	call   8010446a <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010687c:	e8 d6 c8 ff ff       	call   80103157 <mycpu>
80106881:	89 c3                	mov    %eax,%ebx
80106883:	e8 cf c8 ff ff       	call   80103157 <mycpu>
80106888:	8d 78 08             	lea    0x8(%eax),%edi
8010688b:	e8 c7 c8 ff ff       	call   80103157 <mycpu>
80106890:	83 c0 08             	add    $0x8,%eax
80106893:	c1 e8 10             	shr    $0x10,%eax
80106896:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106899:	e8 b9 c8 ff ff       	call   80103157 <mycpu>
8010689e:	83 c0 08             	add    $0x8,%eax
801068a1:	c1 e8 18             	shr    $0x18,%eax
801068a4:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801068ab:	67 00 
801068ad:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801068b4:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
801068b8:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801068be:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
801068c5:	83 e2 f0             	and    $0xfffffff0,%edx
801068c8:	83 ca 19             	or     $0x19,%edx
801068cb:	83 e2 9f             	and    $0xffffff9f,%edx
801068ce:	83 ca 80             	or     $0xffffff80,%edx
801068d1:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801068d7:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
801068de:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801068e4:	e8 6e c8 ff ff       	call   80103157 <mycpu>
801068e9:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801068f0:	83 e2 ef             	and    $0xffffffef,%edx
801068f3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801068f9:	e8 59 c8 ff ff       	call   80103157 <mycpu>
801068fe:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106904:	8b 5e 08             	mov    0x8(%esi),%ebx
80106907:	e8 4b c8 ff ff       	call   80103157 <mycpu>
8010690c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106912:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106915:	e8 3d c8 ff ff       	call   80103157 <mycpu>
8010691a:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80106920:	b8 28 00 00 00       	mov    $0x28,%eax
80106925:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106928:	8b 46 04             	mov    0x4(%esi),%eax
8010692b:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106930:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106933:	e8 6f db ff ff       	call   801044a7 <popcli>
}
80106938:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010693b:	5b                   	pop    %ebx
8010693c:	5e                   	pop    %esi
8010693d:	5f                   	pop    %edi
8010693e:	5d                   	pop    %ebp
8010693f:	c3                   	ret    
    panic("switchuvm: no process");
80106940:	83 ec 0c             	sub    $0xc,%esp
80106943:	68 9e 77 10 80       	push   $0x8010779e
80106948:	e8 fb 99 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
8010694d:	83 ec 0c             	sub    $0xc,%esp
80106950:	68 b4 77 10 80       	push   $0x801077b4
80106955:	e8 ee 99 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
8010695a:	83 ec 0c             	sub    $0xc,%esp
8010695d:	68 c9 77 10 80       	push   $0x801077c9
80106962:	e8 e1 99 ff ff       	call   80100348 <panic>

80106967 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106967:	55                   	push   %ebp
80106968:	89 e5                	mov    %esp,%ebp
8010696a:	56                   	push   %esi
8010696b:	53                   	push   %ebx
8010696c:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010696f:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106975:	77 4c                	ja     801069c3 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80106977:	e8 3f b7 ff ff       	call   801020bb <kalloc>
8010697c:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010697e:	83 ec 04             	sub    $0x4,%esp
80106981:	68 00 10 00 00       	push   $0x1000
80106986:	6a 00                	push   $0x0
80106988:	50                   	push   %eax
80106989:	e8 65 dc ff ff       	call   801045f3 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010698e:	83 c4 08             	add    $0x8,%esp
80106991:	6a 06                	push   $0x6
80106993:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106999:	50                   	push   %eax
8010699a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010699f:	ba 00 00 00 00       	mov    $0x0,%edx
801069a4:	8b 45 08             	mov    0x8(%ebp),%eax
801069a7:	e8 cf fc ff ff       	call   8010667b <mappages>
  memmove(mem, init, sz);
801069ac:	83 c4 0c             	add    $0xc,%esp
801069af:	56                   	push   %esi
801069b0:	ff 75 0c             	pushl  0xc(%ebp)
801069b3:	53                   	push   %ebx
801069b4:	e8 b5 dc ff ff       	call   8010466e <memmove>
}
801069b9:	83 c4 10             	add    $0x10,%esp
801069bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801069bf:	5b                   	pop    %ebx
801069c0:	5e                   	pop    %esi
801069c1:	5d                   	pop    %ebp
801069c2:	c3                   	ret    
    panic("inituvm: more than a page");
801069c3:	83 ec 0c             	sub    $0xc,%esp
801069c6:	68 dd 77 10 80       	push   $0x801077dd
801069cb:	e8 78 99 ff ff       	call   80100348 <panic>

801069d0 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801069d0:	55                   	push   %ebp
801069d1:	89 e5                	mov    %esp,%ebp
801069d3:	57                   	push   %edi
801069d4:	56                   	push   %esi
801069d5:	53                   	push   %ebx
801069d6:	83 ec 0c             	sub    $0xc,%esp
801069d9:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801069dc:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801069e3:	75 07                	jne    801069ec <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801069e5:	bb 00 00 00 00       	mov    $0x0,%ebx
801069ea:	eb 3c                	jmp    80106a28 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
801069ec:	83 ec 0c             	sub    $0xc,%esp
801069ef:	68 98 78 10 80       	push   $0x80107898
801069f4:	e8 4f 99 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801069f9:	83 ec 0c             	sub    $0xc,%esp
801069fc:	68 f7 77 10 80       	push   $0x801077f7
80106a01:	e8 42 99 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106a06:	05 00 00 00 80       	add    $0x80000000,%eax
80106a0b:	56                   	push   %esi
80106a0c:	89 da                	mov    %ebx,%edx
80106a0e:	03 55 14             	add    0x14(%ebp),%edx
80106a11:	52                   	push   %edx
80106a12:	50                   	push   %eax
80106a13:	ff 75 10             	pushl  0x10(%ebp)
80106a16:	e8 58 ad ff ff       	call   80101773 <readi>
80106a1b:	83 c4 10             	add    $0x10,%esp
80106a1e:	39 f0                	cmp    %esi,%eax
80106a20:	75 47                	jne    80106a69 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
80106a22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106a28:	39 fb                	cmp    %edi,%ebx
80106a2a:	73 30                	jae    80106a5c <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106a2c:	89 da                	mov    %ebx,%edx
80106a2e:	03 55 0c             	add    0xc(%ebp),%edx
80106a31:	b9 00 00 00 00       	mov    $0x0,%ecx
80106a36:	8b 45 08             	mov    0x8(%ebp),%eax
80106a39:	e8 cd fb ff ff       	call   8010660b <walkpgdir>
80106a3e:	85 c0                	test   %eax,%eax
80106a40:	74 b7                	je     801069f9 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
80106a42:	8b 00                	mov    (%eax),%eax
80106a44:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106a49:	89 fe                	mov    %edi,%esi
80106a4b:	29 de                	sub    %ebx,%esi
80106a4d:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106a53:	76 b1                	jbe    80106a06 <loaduvm+0x36>
      n = PGSIZE;
80106a55:	be 00 10 00 00       	mov    $0x1000,%esi
80106a5a:	eb aa                	jmp    80106a06 <loaduvm+0x36>
      return -1;
  }
  return 0;
80106a5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a61:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106a64:	5b                   	pop    %ebx
80106a65:	5e                   	pop    %esi
80106a66:	5f                   	pop    %edi
80106a67:	5d                   	pop    %ebp
80106a68:	c3                   	ret    
      return -1;
80106a69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a6e:	eb f1                	jmp    80106a61 <loaduvm+0x91>

80106a70 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106a70:	55                   	push   %ebp
80106a71:	89 e5                	mov    %esp,%ebp
80106a73:	57                   	push   %edi
80106a74:	56                   	push   %esi
80106a75:	53                   	push   %ebx
80106a76:	83 ec 0c             	sub    $0xc,%esp
80106a79:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106a7c:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106a7f:	73 11                	jae    80106a92 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106a81:	8b 45 10             	mov    0x10(%ebp),%eax
80106a84:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106a8a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106a90:	eb 19                	jmp    80106aab <deallocuvm+0x3b>
    return oldsz;
80106a92:	89 f8                	mov    %edi,%eax
80106a94:	eb 64                	jmp    80106afa <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106a96:	c1 eb 16             	shr    $0x16,%ebx
80106a99:	83 c3 01             	add    $0x1,%ebx
80106a9c:	c1 e3 16             	shl    $0x16,%ebx
80106a9f:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106aa5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106aab:	39 fb                	cmp    %edi,%ebx
80106aad:	73 48                	jae    80106af7 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106aaf:	b9 00 00 00 00       	mov    $0x0,%ecx
80106ab4:	89 da                	mov    %ebx,%edx
80106ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80106ab9:	e8 4d fb ff ff       	call   8010660b <walkpgdir>
80106abe:	89 c6                	mov    %eax,%esi
    if(!pte)
80106ac0:	85 c0                	test   %eax,%eax
80106ac2:	74 d2                	je     80106a96 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106ac4:	8b 00                	mov    (%eax),%eax
80106ac6:	a8 01                	test   $0x1,%al
80106ac8:	74 db                	je     80106aa5 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106aca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106acf:	74 19                	je     80106aea <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106ad1:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106ad6:	83 ec 0c             	sub    $0xc,%esp
80106ad9:	50                   	push   %eax
80106ada:	e8 c5 b4 ff ff       	call   80101fa4 <kfree>
      *pte = 0;
80106adf:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106ae5:	83 c4 10             	add    $0x10,%esp
80106ae8:	eb bb                	jmp    80106aa5 <deallocuvm+0x35>
        panic("kfree");
80106aea:	83 ec 0c             	sub    $0xc,%esp
80106aed:	68 26 71 10 80       	push   $0x80107126
80106af2:	e8 51 98 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106af7:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106afa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106afd:	5b                   	pop    %ebx
80106afe:	5e                   	pop    %esi
80106aff:	5f                   	pop    %edi
80106b00:	5d                   	pop    %ebp
80106b01:	c3                   	ret    

80106b02 <allocuvm>:
{
80106b02:	55                   	push   %ebp
80106b03:	89 e5                	mov    %esp,%ebp
80106b05:	57                   	push   %edi
80106b06:	56                   	push   %esi
80106b07:	53                   	push   %ebx
80106b08:	83 ec 1c             	sub    $0x1c,%esp
80106b0b:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106b0e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106b11:	85 ff                	test   %edi,%edi
80106b13:	0f 88 c1 00 00 00    	js     80106bda <allocuvm+0xd8>
  if(newsz < oldsz)
80106b19:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106b1c:	72 5c                	jb     80106b7a <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
80106b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b21:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106b27:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106b2d:	39 fb                	cmp    %edi,%ebx
80106b2f:	0f 83 ac 00 00 00    	jae    80106be1 <allocuvm+0xdf>
    mem = kalloc();
80106b35:	e8 81 b5 ff ff       	call   801020bb <kalloc>
80106b3a:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106b3c:	85 c0                	test   %eax,%eax
80106b3e:	74 42                	je     80106b82 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
80106b40:	83 ec 04             	sub    $0x4,%esp
80106b43:	68 00 10 00 00       	push   $0x1000
80106b48:	6a 00                	push   $0x0
80106b4a:	50                   	push   %eax
80106b4b:	e8 a3 da ff ff       	call   801045f3 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106b50:	83 c4 08             	add    $0x8,%esp
80106b53:	6a 06                	push   $0x6
80106b55:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106b5b:	50                   	push   %eax
80106b5c:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106b61:	89 da                	mov    %ebx,%edx
80106b63:	8b 45 08             	mov    0x8(%ebp),%eax
80106b66:	e8 10 fb ff ff       	call   8010667b <mappages>
80106b6b:	83 c4 10             	add    $0x10,%esp
80106b6e:	85 c0                	test   %eax,%eax
80106b70:	78 38                	js     80106baa <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
80106b72:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106b78:	eb b3                	jmp    80106b2d <allocuvm+0x2b>
    return oldsz;
80106b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80106b7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106b80:	eb 5f                	jmp    80106be1 <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
80106b82:	83 ec 0c             	sub    $0xc,%esp
80106b85:	68 15 78 10 80       	push   $0x80107815
80106b8a:	e8 7c 9a ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106b8f:	83 c4 0c             	add    $0xc,%esp
80106b92:	ff 75 0c             	pushl  0xc(%ebp)
80106b95:	57                   	push   %edi
80106b96:	ff 75 08             	pushl  0x8(%ebp)
80106b99:	e8 d2 fe ff ff       	call   80106a70 <deallocuvm>
      return 0;
80106b9e:	83 c4 10             	add    $0x10,%esp
80106ba1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106ba8:	eb 37                	jmp    80106be1 <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106baa:	83 ec 0c             	sub    $0xc,%esp
80106bad:	68 2d 78 10 80       	push   $0x8010782d
80106bb2:	e8 54 9a ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106bb7:	83 c4 0c             	add    $0xc,%esp
80106bba:	ff 75 0c             	pushl  0xc(%ebp)
80106bbd:	57                   	push   %edi
80106bbe:	ff 75 08             	pushl  0x8(%ebp)
80106bc1:	e8 aa fe ff ff       	call   80106a70 <deallocuvm>
      kfree(mem);
80106bc6:	89 34 24             	mov    %esi,(%esp)
80106bc9:	e8 d6 b3 ff ff       	call   80101fa4 <kfree>
      return 0;
80106bce:	83 c4 10             	add    $0x10,%esp
80106bd1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106bd8:	eb 07                	jmp    80106be1 <allocuvm+0xdf>
    return 0;
80106bda:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106be1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106be7:	5b                   	pop    %ebx
80106be8:	5e                   	pop    %esi
80106be9:	5f                   	pop    %edi
80106bea:	5d                   	pop    %ebp
80106beb:	c3                   	ret    

80106bec <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106bec:	55                   	push   %ebp
80106bed:	89 e5                	mov    %esp,%ebp
80106bef:	56                   	push   %esi
80106bf0:	53                   	push   %ebx
80106bf1:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106bf4:	85 f6                	test   %esi,%esi
80106bf6:	74 1a                	je     80106c12 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106bf8:	83 ec 04             	sub    $0x4,%esp
80106bfb:	6a 00                	push   $0x0
80106bfd:	68 00 00 00 80       	push   $0x80000000
80106c02:	56                   	push   %esi
80106c03:	e8 68 fe ff ff       	call   80106a70 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106c08:	83 c4 10             	add    $0x10,%esp
80106c0b:	bb 00 00 00 00       	mov    $0x0,%ebx
80106c10:	eb 10                	jmp    80106c22 <freevm+0x36>
    panic("freevm: no pgdir");
80106c12:	83 ec 0c             	sub    $0xc,%esp
80106c15:	68 49 78 10 80       	push   $0x80107849
80106c1a:	e8 29 97 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106c1f:	83 c3 01             	add    $0x1,%ebx
80106c22:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106c28:	77 1f                	ja     80106c49 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106c2a:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106c2d:	a8 01                	test   $0x1,%al
80106c2f:	74 ee                	je     80106c1f <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106c31:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106c36:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106c3b:	83 ec 0c             	sub    $0xc,%esp
80106c3e:	50                   	push   %eax
80106c3f:	e8 60 b3 ff ff       	call   80101fa4 <kfree>
80106c44:	83 c4 10             	add    $0x10,%esp
80106c47:	eb d6                	jmp    80106c1f <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106c49:	83 ec 0c             	sub    $0xc,%esp
80106c4c:	56                   	push   %esi
80106c4d:	e8 52 b3 ff ff       	call   80101fa4 <kfree>
}
80106c52:	83 c4 10             	add    $0x10,%esp
80106c55:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106c58:	5b                   	pop    %ebx
80106c59:	5e                   	pop    %esi
80106c5a:	5d                   	pop    %ebp
80106c5b:	c3                   	ret    

80106c5c <setupkvm>:
{
80106c5c:	55                   	push   %ebp
80106c5d:	89 e5                	mov    %esp,%ebp
80106c5f:	56                   	push   %esi
80106c60:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106c61:	e8 55 b4 ff ff       	call   801020bb <kalloc>
80106c66:	89 c6                	mov    %eax,%esi
80106c68:	85 c0                	test   %eax,%eax
80106c6a:	74 55                	je     80106cc1 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106c6c:	83 ec 04             	sub    $0x4,%esp
80106c6f:	68 00 10 00 00       	push   $0x1000
80106c74:	6a 00                	push   $0x0
80106c76:	50                   	push   %eax
80106c77:	e8 77 d9 ff ff       	call   801045f3 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106c7c:	83 c4 10             	add    $0x10,%esp
80106c7f:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106c84:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106c8a:	73 35                	jae    80106cc1 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106c8c:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106c8f:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106c92:	29 c1                	sub    %eax,%ecx
80106c94:	83 ec 08             	sub    $0x8,%esp
80106c97:	ff 73 0c             	pushl  0xc(%ebx)
80106c9a:	50                   	push   %eax
80106c9b:	8b 13                	mov    (%ebx),%edx
80106c9d:	89 f0                	mov    %esi,%eax
80106c9f:	e8 d7 f9 ff ff       	call   8010667b <mappages>
80106ca4:	83 c4 10             	add    $0x10,%esp
80106ca7:	85 c0                	test   %eax,%eax
80106ca9:	78 05                	js     80106cb0 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106cab:	83 c3 10             	add    $0x10,%ebx
80106cae:	eb d4                	jmp    80106c84 <setupkvm+0x28>
      freevm(pgdir);
80106cb0:	83 ec 0c             	sub    $0xc,%esp
80106cb3:	56                   	push   %esi
80106cb4:	e8 33 ff ff ff       	call   80106bec <freevm>
      return 0;
80106cb9:	83 c4 10             	add    $0x10,%esp
80106cbc:	be 00 00 00 00       	mov    $0x0,%esi
}
80106cc1:	89 f0                	mov    %esi,%eax
80106cc3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106cc6:	5b                   	pop    %ebx
80106cc7:	5e                   	pop    %esi
80106cc8:	5d                   	pop    %ebp
80106cc9:	c3                   	ret    

80106cca <kvmalloc>:
{
80106cca:	55                   	push   %ebp
80106ccb:	89 e5                	mov    %esp,%ebp
80106ccd:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106cd0:	e8 87 ff ff ff       	call   80106c5c <setupkvm>
80106cd5:	a3 c4 65 11 80       	mov    %eax,0x801165c4
  switchkvm();
80106cda:	e8 5e fb ff ff       	call   8010683d <switchkvm>
}
80106cdf:	c9                   	leave  
80106ce0:	c3                   	ret    

80106ce1 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106ce1:	55                   	push   %ebp
80106ce2:	89 e5                	mov    %esp,%ebp
80106ce4:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106ce7:	b9 00 00 00 00       	mov    $0x0,%ecx
80106cec:	8b 55 0c             	mov    0xc(%ebp),%edx
80106cef:	8b 45 08             	mov    0x8(%ebp),%eax
80106cf2:	e8 14 f9 ff ff       	call   8010660b <walkpgdir>
  if(pte == 0)
80106cf7:	85 c0                	test   %eax,%eax
80106cf9:	74 05                	je     80106d00 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106cfb:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106cfe:	c9                   	leave  
80106cff:	c3                   	ret    
    panic("clearpteu");
80106d00:	83 ec 0c             	sub    $0xc,%esp
80106d03:	68 5a 78 10 80       	push   $0x8010785a
80106d08:	e8 3b 96 ff ff       	call   80100348 <panic>

80106d0d <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106d0d:	55                   	push   %ebp
80106d0e:	89 e5                	mov    %esp,%ebp
80106d10:	57                   	push   %edi
80106d11:	56                   	push   %esi
80106d12:	53                   	push   %ebx
80106d13:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106d16:	e8 41 ff ff ff       	call   80106c5c <setupkvm>
80106d1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106d1e:	85 c0                	test   %eax,%eax
80106d20:	0f 84 c4 00 00 00    	je     80106dea <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106d26:	bf 00 00 00 00       	mov    $0x0,%edi
80106d2b:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106d2e:	0f 83 b6 00 00 00    	jae    80106dea <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106d34:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106d37:	b9 00 00 00 00       	mov    $0x0,%ecx
80106d3c:	89 fa                	mov    %edi,%edx
80106d3e:	8b 45 08             	mov    0x8(%ebp),%eax
80106d41:	e8 c5 f8 ff ff       	call   8010660b <walkpgdir>
80106d46:	85 c0                	test   %eax,%eax
80106d48:	74 65                	je     80106daf <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106d4a:	8b 00                	mov    (%eax),%eax
80106d4c:	a8 01                	test   $0x1,%al
80106d4e:	74 6c                	je     80106dbc <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106d50:	89 c6                	mov    %eax,%esi
80106d52:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106d58:	25 ff 0f 00 00       	and    $0xfff,%eax
80106d5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106d60:	e8 56 b3 ff ff       	call   801020bb <kalloc>
80106d65:	89 c3                	mov    %eax,%ebx
80106d67:	85 c0                	test   %eax,%eax
80106d69:	74 6a                	je     80106dd5 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106d6b:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106d71:	83 ec 04             	sub    $0x4,%esp
80106d74:	68 00 10 00 00       	push   $0x1000
80106d79:	56                   	push   %esi
80106d7a:	50                   	push   %eax
80106d7b:	e8 ee d8 ff ff       	call   8010466e <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106d80:	83 c4 08             	add    $0x8,%esp
80106d83:	ff 75 e0             	pushl  -0x20(%ebp)
80106d86:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106d8c:	50                   	push   %eax
80106d8d:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106d92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106d95:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106d98:	e8 de f8 ff ff       	call   8010667b <mappages>
80106d9d:	83 c4 10             	add    $0x10,%esp
80106da0:	85 c0                	test   %eax,%eax
80106da2:	78 25                	js     80106dc9 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106da4:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106daa:	e9 7c ff ff ff       	jmp    80106d2b <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106daf:	83 ec 0c             	sub    $0xc,%esp
80106db2:	68 64 78 10 80       	push   $0x80107864
80106db7:	e8 8c 95 ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106dbc:	83 ec 0c             	sub    $0xc,%esp
80106dbf:	68 7e 78 10 80       	push   $0x8010787e
80106dc4:	e8 7f 95 ff ff       	call   80100348 <panic>
      kfree(mem);
80106dc9:	83 ec 0c             	sub    $0xc,%esp
80106dcc:	53                   	push   %ebx
80106dcd:	e8 d2 b1 ff ff       	call   80101fa4 <kfree>
      goto bad;
80106dd2:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106dd5:	83 ec 0c             	sub    $0xc,%esp
80106dd8:	ff 75 dc             	pushl  -0x24(%ebp)
80106ddb:	e8 0c fe ff ff       	call   80106bec <freevm>
  return 0;
80106de0:	83 c4 10             	add    $0x10,%esp
80106de3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106dea:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106ded:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106df0:	5b                   	pop    %ebx
80106df1:	5e                   	pop    %esi
80106df2:	5f                   	pop    %edi
80106df3:	5d                   	pop    %ebp
80106df4:	c3                   	ret    

80106df5 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106df5:	55                   	push   %ebp
80106df6:	89 e5                	mov    %esp,%ebp
80106df8:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106dfb:	b9 00 00 00 00       	mov    $0x0,%ecx
80106e00:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e03:	8b 45 08             	mov    0x8(%ebp),%eax
80106e06:	e8 00 f8 ff ff       	call   8010660b <walkpgdir>
  if((*pte & PTE_P) == 0)
80106e0b:	8b 00                	mov    (%eax),%eax
80106e0d:	a8 01                	test   $0x1,%al
80106e0f:	74 10                	je     80106e21 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106e11:	a8 04                	test   $0x4,%al
80106e13:	74 13                	je     80106e28 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106e15:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106e1a:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106e1f:	c9                   	leave  
80106e20:	c3                   	ret    
    return 0;
80106e21:	b8 00 00 00 00       	mov    $0x0,%eax
80106e26:	eb f7                	jmp    80106e1f <uva2ka+0x2a>
    return 0;
80106e28:	b8 00 00 00 00       	mov    $0x0,%eax
80106e2d:	eb f0                	jmp    80106e1f <uva2ka+0x2a>

80106e2f <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106e2f:	55                   	push   %ebp
80106e30:	89 e5                	mov    %esp,%ebp
80106e32:	57                   	push   %edi
80106e33:	56                   	push   %esi
80106e34:	53                   	push   %ebx
80106e35:	83 ec 0c             	sub    $0xc,%esp
80106e38:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106e3b:	eb 25                	jmp    80106e62 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106e3d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e40:	29 f2                	sub    %esi,%edx
80106e42:	01 d0                	add    %edx,%eax
80106e44:	83 ec 04             	sub    $0x4,%esp
80106e47:	53                   	push   %ebx
80106e48:	ff 75 10             	pushl  0x10(%ebp)
80106e4b:	50                   	push   %eax
80106e4c:	e8 1d d8 ff ff       	call   8010466e <memmove>
    len -= n;
80106e51:	29 df                	sub    %ebx,%edi
    buf += n;
80106e53:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106e56:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106e5c:	89 45 0c             	mov    %eax,0xc(%ebp)
80106e5f:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106e62:	85 ff                	test   %edi,%edi
80106e64:	74 2f                	je     80106e95 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106e66:	8b 75 0c             	mov    0xc(%ebp),%esi
80106e69:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106e6f:	83 ec 08             	sub    $0x8,%esp
80106e72:	56                   	push   %esi
80106e73:	ff 75 08             	pushl  0x8(%ebp)
80106e76:	e8 7a ff ff ff       	call   80106df5 <uva2ka>
    if(pa0 == 0)
80106e7b:	83 c4 10             	add    $0x10,%esp
80106e7e:	85 c0                	test   %eax,%eax
80106e80:	74 20                	je     80106ea2 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106e82:	89 f3                	mov    %esi,%ebx
80106e84:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106e87:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106e8d:	39 df                	cmp    %ebx,%edi
80106e8f:	73 ac                	jae    80106e3d <copyout+0xe>
      n = len;
80106e91:	89 fb                	mov    %edi,%ebx
80106e93:	eb a8                	jmp    80106e3d <copyout+0xe>
  }
  return 0;
80106e95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e9a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106e9d:	5b                   	pop    %ebx
80106e9e:	5e                   	pop    %esi
80106e9f:	5f                   	pop    %edi
80106ea0:	5d                   	pop    %ebp
80106ea1:	c3                   	ret    
      return -1;
80106ea2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ea7:	eb f1                	jmp    80106e9a <copyout+0x6b>
