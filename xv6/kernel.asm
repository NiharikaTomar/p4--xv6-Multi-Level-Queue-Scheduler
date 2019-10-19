
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
80100046:	e8 da 41 00 00       	call   80104225 <acquire>

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
8010007c:	e8 09 42 00 00       	call   8010428a <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 85 3f 00 00       	call   80104011 <acquiresleep>
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
801000ca:	e8 bb 41 00 00       	call   8010428a <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 37 3f 00 00       	call   80104011 <acquiresleep>
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
801000ea:	68 a0 6b 10 80       	push   $0x80106ba0
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 b1 6b 10 80       	push   $0x80106bb1
80100100:	68 e0 b9 10 80       	push   $0x8010b9e0
80100105:	e8 df 3f 00 00       	call   801040e9 <initlock>
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
8010013a:	68 b8 6b 10 80       	push   $0x80106bb8
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 96 3e 00 00       	call   80103fde <initsleeplock>
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
801001a8:	e8 ee 3e 00 00       	call   8010409b <holdingsleep>
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
801001cb:	68 bf 6b 10 80       	push   $0x80106bbf
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
801001e4:	e8 b2 3e 00 00       	call   8010409b <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 67 3e 00 00       	call   80104060 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 b9 10 80 	movl   $0x8010b9e0,(%esp)
80100200:	e8 20 40 00 00       	call   80104225 <acquire>
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
8010024c:	e8 39 40 00 00       	call   8010428a <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 c6 6b 10 80       	push   $0x80106bc6
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
8010028a:	e8 96 3f 00 00       	call   80104225 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 03 11 80       	mov    0x801103c0,%eax
8010029f:	3b 05 c4 03 11 80    	cmp    0x801103c4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 d2 2f 00 00       	call   8010327e <myproc>
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
801002bf:	e8 21 38 00 00       	call   80103ae5 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 b4 3f 00 00       	call   8010428a <release>
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
80100331:	e8 54 3f 00 00       	call   8010428a <release>
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
80100363:	68 cd 6b 10 80       	push   $0x80106bcd
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 27 75 10 80 	movl   $0x80107527,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 70 3d 00 00       	call   80104104 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 e1 6b 10 80       	push   $0x80106be1
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
8010049e:	68 e5 6b 10 80       	push   $0x80106be5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 8d 3e 00 00       	call   8010434c <memmove>
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
801004d9:	e8 f3 3d 00 00       	call   801042d1 <memset>
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
80100506:	e8 6f 52 00 00       	call   8010577a <uartputc>
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
8010051f:	e8 56 52 00 00       	call   8010577a <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 4a 52 00 00       	call   8010577a <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 3e 52 00 00       	call   8010577a <uartputc>
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
80100576:	0f b6 92 10 6c 10 80 	movzbl -0x7fef93f0(%edx),%edx
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
801005ca:	e8 56 3c 00 00       	call   80104225 <acquire>
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
801005f1:	e8 94 3c 00 00       	call   8010428a <release>
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
80100638:	e8 e8 3b 00 00       	call   80104225 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 ff 6b 10 80       	push   $0x80106bff
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
801006ee:	be f8 6b 10 80       	mov    $0x80106bf8,%esi
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
80100734:	e8 51 3b 00 00       	call   8010428a <release>
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
8010074f:	e8 d1 3a 00 00       	call   80104225 <acquire>
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
801007de:	e8 6a 34 00 00       	call   80103c4d <wakeup>
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
80100873:	e8 12 3a 00 00       	call   8010428a <release>
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
80100887:	e8 60 34 00 00       	call   80103cec <procdump>
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
80100894:	68 08 6c 10 80       	push   $0x80106c08
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 46 38 00 00       	call   801040e9 <initlock>

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
801008de:	e8 9b 29 00 00       	call   8010327e <myproc>
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
80100952:	68 21 6c 10 80       	push   $0x80106c21
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
80100972:	e8 c3 5f 00 00       	call   8010693a <setupkvm>
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
80100a06:	e8 d5 5d 00 00       	call   801067e0 <allocuvm>
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
80100a38:	e8 71 5c 00 00       	call   801066ae <loaduvm>
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
80100a74:	e8 67 5d 00 00       	call   801067e0 <allocuvm>
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
80100a9d:	e8 28 5e 00 00       	call   801068ca <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 fe 5e 00 00       	call   801069bf <clearpteu>
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
80100ae2:	e8 8c 39 00 00       	call   80104473 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 7a 39 00 00       	call   80104473 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 02 60 00 00       	call   80106b0d <copyout>
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
80100b66:	e8 a2 5f 00 00       	call   80106b0d <copyout>
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
80100ba3:	e8 90 38 00 00       	call   80104438 <safestrcpy>
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
80100bd1:	e8 57 59 00 00       	call   8010652d <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 ec 5c 00 00       	call   801068ca <freevm>
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
80100c19:	68 2d 6c 10 80       	push   $0x80106c2d
80100c1e:	68 e0 03 11 80       	push   $0x801103e0
80100c23:	e8 c1 34 00 00       	call   801040e9 <initlock>
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
80100c39:	e8 e7 35 00 00       	call   80104225 <acquire>
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
80100c68:	e8 1d 36 00 00       	call   8010428a <release>
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
80100c7f:	e8 06 36 00 00       	call   8010428a <release>
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
80100c9d:	e8 83 35 00 00       	call   80104225 <acquire>
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
80100cba:	e8 cb 35 00 00       	call   8010428a <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 34 6c 10 80       	push   $0x80106c34
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
80100ce2:	e8 3e 35 00 00       	call   80104225 <acquire>
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
80100d03:	e8 82 35 00 00       	call   8010428a <release>
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
80100d13:	68 3c 6c 10 80       	push   $0x80106c3c
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
80100d49:	e8 3c 35 00 00       	call   8010428a <release>
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
80100e4b:	68 46 6c 10 80       	push   $0x80106c46
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
80100f10:	68 4f 6c 10 80       	push   $0x80106c4f
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
80100f2d:	68 55 6c 10 80       	push   $0x80106c55
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
80100f8a:	e8 bd 33 00 00       	call   8010434c <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 ad 33 00 00       	call   8010434c <memmove>
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
80100fdf:	e8 ed 32 00 00       	call   801042d1 <memset>
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
801010a3:	68 5f 6c 10 80       	push   $0x80106c5f
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
8010117d:	68 75 6c 10 80       	push   $0x80106c75
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
8010119a:	e8 86 30 00 00       	call   80104225 <acquire>
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
801011e1:	e8 a4 30 00 00       	call   8010428a <release>
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
80101217:	e8 6e 30 00 00       	call   8010428a <release>
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
8010122c:	68 88 6c 10 80       	push   $0x80106c88
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
80101255:	e8 f2 30 00 00       	call   8010434c <memmove>
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
801012e2:	68 98 6c 10 80       	push   $0x80106c98
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 ab 6c 10 80       	push   $0x80106cab
801012f8:	68 00 0e 11 80       	push   $0x80110e00
801012fd:	e8 e7 2d 00 00       	call   801040e9 <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 b2 6c 10 80       	push   $0x80106cb2
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 40 0e 11 80       	add    $0x80110e40,%eax
80101321:	50                   	push   %eax
80101322:	e8 b7 2c 00 00       	call   80103fde <initsleeplock>
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
8010136c:	68 18 6d 10 80       	push   $0x80106d18
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
801013df:	68 b8 6c 10 80       	push   $0x80106cb8
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 db 2e 00 00       	call   801042d1 <memset>
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
80101480:	e8 c7 2e 00 00       	call   8010434c <memmove>
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
80101560:	e8 c0 2c 00 00       	call   80104225 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
80101575:	e8 10 2d 00 00       	call   8010428a <release>
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
8010159a:	e8 72 2a 00 00       	call   80104011 <acquiresleep>
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
801015b2:	68 ca 6c 10 80       	push   $0x80106cca
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
80101614:	e8 33 2d 00 00       	call   8010434c <memmove>
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
80101639:	68 d0 6c 10 80       	push   $0x80106cd0
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
80101656:	e8 40 2a 00 00       	call   8010409b <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 ef 29 00 00       	call   80104060 <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 df 6c 10 80       	push   $0x80106cdf
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
80101698:	e8 74 29 00 00       	call   80104011 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 aa 29 00 00       	call   80104060 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
801016bd:	e8 63 2b 00 00       	call   80104225 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
801016d2:	e8 b3 2b 00 00       	call   8010428a <release>
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
801016ea:	e8 36 2b 00 00       	call   80104225 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 0e 11 80 	movl   $0x80110e00,(%esp)
801016f9:	e8 8c 2b 00 00       	call   8010428a <release>
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
8010182a:	e8 1d 2b 00 00       	call   8010434c <memmove>
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
80101926:	e8 21 2a 00 00       	call   8010434c <memmove>
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
801019a9:	e8 05 2a 00 00       	call   801043b3 <strncmp>
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
801019d0:	68 e7 6c 10 80       	push   $0x80106ce7
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 f9 6c 10 80       	push   $0x80106cf9
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
80101a5a:	e8 1f 18 00 00       	call   8010327e <myproc>
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
80101b92:	68 08 6d 10 80       	push   $0x80106d08
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 42 28 00 00       	call   801043f0 <strncpy>
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
80101bd7:	68 20 73 10 80       	push   $0x80107320
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
80101ccc:	68 6b 6d 10 80       	push   $0x80106d6b
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 74 6d 10 80       	push   $0x80106d74
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
80101d06:	68 86 6d 10 80       	push   $0x80106d86
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 d4 23 00 00       	call   801040e9 <initlock>
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
80101d80:	e8 a0 24 00 00       	call   80104225 <acquire>

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
80101dad:	e8 9b 1e 00 00       	call   80103c4d <wakeup>

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
80101dcb:	e8 ba 24 00 00       	call   8010428a <release>
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
80101de2:	e8 a3 24 00 00       	call   8010428a <release>
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
80101e1a:	e8 7c 22 00 00       	call   8010409b <holdingsleep>
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
80101e47:	e8 d9 23 00 00       	call   80104225 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 8a 6d 10 80       	push   $0x80106d8a
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 a0 6d 10 80       	push   $0x80106da0
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 b5 6d 10 80       	push   $0x80106db5
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
80101ea9:	e8 37 1c 00 00       	call   80103ae5 <sleep>
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
80101ec3:	e8 c2 23 00 00       	call   8010428a <release>
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
80101f3f:	68 d4 6d 10 80       	push   $0x80106dd4
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
80101fd6:	e8 f6 22 00 00       	call   801042d1 <memset>

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
80102005:	68 06 6e 10 80       	push   $0x80106e06
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 60 2a 11 80       	push   $0x80112a60
80102017:	e8 09 22 00 00       	call   80104225 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 60 2a 11 80       	push   $0x80112a60
80102029:	e8 5c 22 00 00       	call   8010428a <release>
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
8010206f:	68 0c 6e 10 80       	push   $0x80106e0c
80102074:	68 60 2a 11 80       	push   $0x80112a60
80102079:	e8 6b 20 00 00       	call   801040e9 <initlock>
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
801020f4:	e8 2c 21 00 00       	call   80104225 <acquire>
801020f9:	83 c4 10             	add    $0x10,%esp
801020fc:	eb cd                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
801020fe:	83 ec 0c             	sub    $0xc,%esp
80102101:	68 60 2a 11 80       	push   $0x80112a60
80102106:	e8 7f 21 00 00       	call   8010428a <release>
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
80102150:	0f b6 8a 40 6f 10 80 	movzbl -0x7fef90c0(%edx),%ecx
80102157:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
8010215d:	0f b6 82 40 6e 10 80 	movzbl -0x7fef91c0(%edx),%eax
80102164:	31 c1                	xor    %eax,%ecx
80102166:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
8010216c:	89 c8                	mov    %ecx,%eax
8010216e:	83 e0 03             	and    $0x3,%eax
80102171:	8b 04 85 20 6e 10 80 	mov    -0x7fef91e0(,%eax,4),%eax
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
801021ac:	0f b6 82 40 6f 10 80 	movzbl -0x7fef90c0(%edx),%eax
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
80102497:	e8 7b 1e 00 00       	call   80104317 <memcmp>
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
80102602:	e8 45 1d 00 00       	call   8010434c <memmove>
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
80102701:	e8 46 1c 00 00       	call   8010434c <memmove>
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
8010276f:	68 40 70 10 80       	push   $0x80107040
80102774:	68 a0 2a 11 80       	push   $0x80112aa0
80102779:	e8 6b 19 00 00       	call   801040e9 <initlock>
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
801027b9:	e8 67 1a 00 00       	call   80104225 <acquire>
801027be:	83 c4 10             	add    $0x10,%esp
801027c1:	eb 15                	jmp    801027d8 <begin_op+0x2a>
      sleep(&log, &log.lock);
801027c3:	83 ec 08             	sub    $0x8,%esp
801027c6:	68 a0 2a 11 80       	push   $0x80112aa0
801027cb:	68 a0 2a 11 80       	push   $0x80112aa0
801027d0:	e8 10 13 00 00       	call   80103ae5 <sleep>
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
80102807:	e8 d9 12 00 00       	call   80103ae5 <sleep>
8010280c:	83 c4 10             	add    $0x10,%esp
8010280f:	eb c7                	jmp    801027d8 <begin_op+0x2a>
      log.outstanding += 1;
80102811:	a3 dc 2a 11 80       	mov    %eax,0x80112adc
      release(&log.lock);
80102816:	83 ec 0c             	sub    $0xc,%esp
80102819:	68 a0 2a 11 80       	push   $0x80112aa0
8010281e:	e8 67 1a 00 00       	call   8010428a <release>
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
80102834:	e8 ec 19 00 00       	call   80104225 <acquire>
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
8010286e:	e8 17 1a 00 00       	call   8010428a <release>
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
80102882:	68 44 70 10 80       	push   $0x80107044
80102887:	e8 bc da ff ff       	call   80100348 <panic>
    wakeup(&log);
8010288c:	83 ec 0c             	sub    $0xc,%esp
8010288f:	68 a0 2a 11 80       	push   $0x80112aa0
80102894:	e8 b4 13 00 00       	call   80103c4d <wakeup>
80102899:	83 c4 10             	add    $0x10,%esp
8010289c:	eb c8                	jmp    80102866 <end_op+0x3e>
    commit();
8010289e:	e8 91 fe ff ff       	call   80102734 <commit>
    acquire(&log.lock);
801028a3:	83 ec 0c             	sub    $0xc,%esp
801028a6:	68 a0 2a 11 80       	push   $0x80112aa0
801028ab:	e8 75 19 00 00       	call   80104225 <acquire>
    log.committing = 0;
801028b0:	c7 05 e0 2a 11 80 00 	movl   $0x0,0x80112ae0
801028b7:	00 00 00 
    wakeup(&log);
801028ba:	c7 04 24 a0 2a 11 80 	movl   $0x80112aa0,(%esp)
801028c1:	e8 87 13 00 00       	call   80103c4d <wakeup>
    release(&log.lock);
801028c6:	c7 04 24 a0 2a 11 80 	movl   $0x80112aa0,(%esp)
801028cd:	e8 b8 19 00 00       	call   8010428a <release>
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
80102909:	e8 17 19 00 00       	call   80104225 <acquire>
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
80102934:	68 53 70 10 80       	push   $0x80107053
80102939:	e8 0a da ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 69 70 10 80       	push   $0x80107069
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
80102964:	e8 21 19 00 00       	call   8010428a <release>
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
80102992:	e8 b5 19 00 00       	call   8010434c <memmove>

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
801029ba:	e8 48 08 00 00       	call   80103207 <mycpu>
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
80102a12:	e8 4c 08 00 00       	call   80103263 <cpuid>
80102a17:	89 c3                	mov    %eax,%ebx
80102a19:	e8 45 08 00 00       	call   80103263 <cpuid>
80102a1e:	83 ec 04             	sub    $0x4,%esp
80102a21:	53                   	push   %ebx
80102a22:	50                   	push   %eax
80102a23:	68 84 70 10 80       	push   $0x80107084
80102a28:	e8 de db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a2d:	e8 e0 2a 00 00       	call   80105512 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a32:	e8 d0 07 00 00       	call   80103207 <mycpu>
80102a37:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a39:	b8 01 00 00 00       	mov    $0x1,%eax
80102a3e:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a45:	e8 00 0a 00 00       	call   8010344a <scheduler>

80102a4a <mpenter>:
{
80102a4a:	55                   	push   %ebp
80102a4b:	89 e5                	mov    %esp,%ebp
80102a4d:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a50:	e8 c6 3a 00 00       	call   8010651b <switchkvm>
  seginit();
80102a55:	e8 75 39 00 00       	call   801063cf <seginit>
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
80102a84:	e8 1f 3f 00 00       	call   801069a8 <kvmalloc>
  mpinit();        // detect other processors
80102a89:	e8 c9 01 00 00       	call   80102c57 <mpinit>
  lapicinit();     // interrupt controller
80102a8e:	e8 e1 f7 ff ff       	call   80102274 <lapicinit>
  seginit();       // segment descriptors
80102a93:	e8 37 39 00 00       	call   801063cf <seginit>
  picinit();       // disable pic
80102a98:	e8 82 02 00 00       	call   80102d1f <picinit>
  ioapicinit();    // another interrupt controller
80102a9d:	e8 58 f4 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102aa2:	e8 e7 dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102aa7:	e8 14 2d 00 00       	call   801057c0 <uartinit>
  pinit();         // process table
80102aac:	e8 3c 07 00 00       	call   801031ed <pinit>
  tvinit();        // trap vectors
80102ab1:	e8 ab 29 00 00       	call   80105461 <tvinit>
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
80102adc:	e8 c1 07 00 00       	call   801032a2 <userinit>
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
80102b27:	68 98 70 10 80       	push   $0x80107098
80102b2c:	53                   	push   %ebx
80102b2d:	e8 e5 17 00 00       	call   80104317 <memcmp>
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
80102bec:	68 9d 70 10 80       	push   $0x8010709d
80102bf1:	56                   	push   %esi
80102bf2:	e8 20 17 00 00       	call   80104317 <memcmp>
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
80102c88:	68 a2 70 10 80       	push   $0x801070a2
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
80102cc7:	ff 24 85 dc 70 10 80 	jmp    *-0x7fef8f24(,%eax,4)
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
80102d15:	68 bc 70 10 80       	push   $0x801070bc
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
80102dd1:	68 f0 70 10 80       	push   $0x801070f0
80102dd6:	50                   	push   %eax
80102dd7:	e8 0d 13 00 00       	call   801040e9 <initlock>
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
80102e2d:	e8 f3 13 00 00       	call   80104225 <acquire>
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
80102e4f:	e8 f9 0d 00 00       	call   80103c4d <wakeup>
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
80102e6d:	e8 18 14 00 00       	call   8010428a <release>
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
80102e8e:	e8 ba 0d 00 00       	call   80103c4d <wakeup>
80102e93:	83 c4 10             	add    $0x10,%esp
80102e96:	eb bf                	jmp    80102e57 <pipeclose+0x35>
    release(&p->lock);
80102e98:	83 ec 0c             	sub    $0xc,%esp
80102e9b:	53                   	push   %ebx
80102e9c:	e8 e9 13 00 00       	call   8010428a <release>
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
80102ebd:	e8 63 13 00 00       	call   80104225 <acquire>
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
80102ef1:	e8 88 03 00 00       	call   8010327e <myproc>
80102ef6:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102efa:	75 24                	jne    80102f20 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102efc:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f02:	83 ec 0c             	sub    $0xc,%esp
80102f05:	50                   	push   %eax
80102f06:	e8 42 0d 00 00       	call   80103c4d <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f0b:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f11:	83 c4 08             	add    $0x8,%esp
80102f14:	56                   	push   %esi
80102f15:	50                   	push   %eax
80102f16:	e8 ca 0b 00 00       	call   80103ae5 <sleep>
80102f1b:	83 c4 10             	add    $0x10,%esp
80102f1e:	eb b3                	jmp    80102ed3 <pipewrite+0x25>
        release(&p->lock);
80102f20:	83 ec 0c             	sub    $0xc,%esp
80102f23:	53                   	push   %ebx
80102f24:	e8 61 13 00 00       	call   8010428a <release>
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
80102f65:	e8 e3 0c 00 00       	call   80103c4d <wakeup>
  release(&p->lock);
80102f6a:	89 1c 24             	mov    %ebx,(%esp)
80102f6d:	e8 18 13 00 00       	call   8010428a <release>
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
80102f89:	e8 97 12 00 00       	call   80104225 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102f8e:	83 c4 10             	add    $0x10,%esp
80102f91:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102f97:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102f9d:	75 3d                	jne    80102fdc <piperead+0x62>
80102f9f:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fa5:	85 f6                	test   %esi,%esi
80102fa7:	74 38                	je     80102fe1 <piperead+0x67>
    if(myproc()->killed){
80102fa9:	e8 d0 02 00 00       	call   8010327e <myproc>
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
80102fbf:	e8 21 0b 00 00       	call   80103ae5 <sleep>
80102fc4:	83 c4 10             	add    $0x10,%esp
80102fc7:	eb c8                	jmp    80102f91 <piperead+0x17>
      release(&p->lock);
80102fc9:	83 ec 0c             	sub    $0xc,%esp
80102fcc:	53                   	push   %ebx
80102fcd:	e8 b8 12 00 00       	call   8010428a <release>
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
8010301c:	e8 2c 0c 00 00       	call   80103c4d <wakeup>
  release(&p->lock);
80103021:	89 1c 24             	mov    %ebx,(%esp)
80103024:	e8 61 12 00 00       	call   8010428a <release>
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

80103036 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103036:	55                   	push   %ebp
80103037:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103039:	ba 74 31 11 80       	mov    $0x80113174,%edx
8010303e:	eb 06                	jmp    80103046 <wakeup1+0x10>
80103040:	81 c2 b0 00 00 00    	add    $0xb0,%edx
80103046:	81 fa 74 5d 11 80    	cmp    $0x80115d74,%edx
8010304c:	73 14                	jae    80103062 <wakeup1+0x2c>
    if(p->state == SLEEPING && p->chan == chan){
8010304e:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103052:	75 ec                	jne    80103040 <wakeup1+0xa>
80103054:	39 42 20             	cmp    %eax,0x20(%edx)
80103057:	75 e7                	jne    80103040 <wakeup1+0xa>
      p->state = RUNNABLE;
80103059:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103060:	eb de                	jmp    80103040 <wakeup1+0xa>
    }
  }
}
80103062:	5d                   	pop    %ebp
80103063:	c3                   	ret    

80103064 <allocproc>:
{
80103064:	55                   	push   %ebp
80103065:	89 e5                	mov    %esp,%ebp
80103067:	53                   	push   %ebx
80103068:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
8010306b:	68 40 31 11 80       	push   $0x80113140
80103070:	e8 b0 11 00 00       	call   80104225 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103075:	83 c4 10             	add    $0x10,%esp
80103078:	bb 74 31 11 80       	mov    $0x80113174,%ebx
8010307d:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103083:	73 0e                	jae    80103093 <allocproc+0x2f>
    if(p->state == UNUSED)
80103085:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103089:	74 22                	je     801030ad <allocproc+0x49>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010308b:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103091:	eb ea                	jmp    8010307d <allocproc+0x19>
  release(&ptable.lock);
80103093:	83 ec 0c             	sub    $0xc,%esp
80103096:	68 40 31 11 80       	push   $0x80113140
8010309b:	e8 ea 11 00 00       	call   8010428a <release>
  return 0;
801030a0:	83 c4 10             	add    $0x10,%esp
801030a3:	bb 00 00 00 00       	mov    $0x0,%ebx
801030a8:	e9 e8 00 00 00       	jmp    80103195 <allocproc+0x131>
  p->state = EMBRYO;
801030ad:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801030b4:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801030b9:	8d 50 01             	lea    0x1(%eax),%edx
801030bc:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
801030c2:	89 43 10             	mov    %eax,0x10(%ebx)
  p->priority = 0;
801030c5:	c7 83 9c 00 00 00 00 	movl   $0x0,0x9c(%ebx)
801030cc:	00 00 00 
  p->ticks[0] = 0;
801030cf:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
801030d6:	00 00 00 
  p->ticks[1] = 0;
801030d9:	c7 83 90 00 00 00 00 	movl   $0x0,0x90(%ebx)
801030e0:	00 00 00 
  p->ticks[2] = 0;
801030e3:	c7 83 94 00 00 00 00 	movl   $0x0,0x94(%ebx)
801030ea:	00 00 00 
  p->ticks[3] = 0;
801030ed:	c7 83 98 00 00 00 00 	movl   $0x0,0x98(%ebx)
801030f4:	00 00 00 
  p->ticksUsed[0] = 0;
801030f7:	c7 83 a0 00 00 00 00 	movl   $0x0,0xa0(%ebx)
801030fe:	00 00 00 
  p->ticksUsed[1] = 0;
80103101:	c7 83 a4 00 00 00 00 	movl   $0x0,0xa4(%ebx)
80103108:	00 00 00 
  p->ticksUsed[2] = 0;
8010310b:	c7 83 a8 00 00 00 00 	movl   $0x0,0xa8(%ebx)
80103112:	00 00 00 
  p->ticksUsed[3] = 0;
80103115:	c7 83 ac 00 00 00 00 	movl   $0x0,0xac(%ebx)
8010311c:	00 00 00 
  p->qtail[0] = 0;
8010311f:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
  p->qtail[1] = 0;
80103126:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
8010312d:	00 00 00 
  p->qtail[2] = 0;
80103130:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
80103137:	00 00 00 
  p->qtail[3] = 0;
8010313a:	c7 83 88 00 00 00 00 	movl   $0x0,0x88(%ebx)
80103141:	00 00 00 
  release(&ptable.lock);
80103144:	83 ec 0c             	sub    $0xc,%esp
80103147:	68 40 31 11 80       	push   $0x80113140
8010314c:	e8 39 11 00 00       	call   8010428a <release>
  if((p->kstack = kalloc()) == 0){
80103151:	e8 65 ef ff ff       	call   801020bb <kalloc>
80103156:	89 43 08             	mov    %eax,0x8(%ebx)
80103159:	83 c4 10             	add    $0x10,%esp
8010315c:	85 c0                	test   %eax,%eax
8010315e:	74 3c                	je     8010319c <allocproc+0x138>
  sp -= sizeof *p->tf;
80103160:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103166:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103169:	c7 80 b0 0f 00 00 56 	movl   $0x80105456,0xfb0(%eax)
80103170:	54 10 80 
  sp -= sizeof *p->context;
80103173:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103178:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010317b:	83 ec 04             	sub    $0x4,%esp
8010317e:	6a 14                	push   $0x14
80103180:	6a 00                	push   $0x0
80103182:	50                   	push   %eax
80103183:	e8 49 11 00 00       	call   801042d1 <memset>
  p->context->eip = (uint)forkret;
80103188:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010318b:	c7 40 10 aa 31 10 80 	movl   $0x801031aa,0x10(%eax)
  return p;
80103192:	83 c4 10             	add    $0x10,%esp
}
80103195:	89 d8                	mov    %ebx,%eax
80103197:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010319a:	c9                   	leave  
8010319b:	c3                   	ret    
    p->state = UNUSED;
8010319c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801031a3:	bb 00 00 00 00       	mov    $0x0,%ebx
801031a8:	eb eb                	jmp    80103195 <allocproc+0x131>

801031aa <forkret>:
{
801031aa:	55                   	push   %ebp
801031ab:	89 e5                	mov    %esp,%ebp
801031ad:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801031b0:	68 40 31 11 80       	push   $0x80113140
801031b5:	e8 d0 10 00 00       	call   8010428a <release>
  if (first) {
801031ba:	83 c4 10             	add    $0x10,%esp
801031bd:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801031c4:	75 02                	jne    801031c8 <forkret+0x1e>
}
801031c6:	c9                   	leave  
801031c7:	c3                   	ret    
    first = 0;
801031c8:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801031cf:	00 00 00 
    iinit(ROOTDEV);
801031d2:	83 ec 0c             	sub    $0xc,%esp
801031d5:	6a 01                	push   $0x1
801031d7:	e8 10 e1 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
801031dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031e3:	e8 7d f5 ff ff       	call   80102765 <initlog>
801031e8:	83 c4 10             	add    $0x10,%esp
}
801031eb:	eb d9                	jmp    801031c6 <forkret+0x1c>

801031ed <pinit>:
{
801031ed:	55                   	push   %ebp
801031ee:	89 e5                	mov    %esp,%ebp
801031f0:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801031f3:	68 f5 70 10 80       	push   $0x801070f5
801031f8:	68 40 31 11 80       	push   $0x80113140
801031fd:	e8 e7 0e 00 00       	call   801040e9 <initlock>
}
80103202:	83 c4 10             	add    $0x10,%esp
80103205:	c9                   	leave  
80103206:	c3                   	ret    

80103207 <mycpu>:
{
80103207:	55                   	push   %ebp
80103208:	89 e5                	mov    %esp,%ebp
8010320a:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010320d:	9c                   	pushf  
8010320e:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010320f:	f6 c4 02             	test   $0x2,%ah
80103212:	75 28                	jne    8010323c <mycpu+0x35>
  apicid = lapicid();
80103214:	e8 65 f1 ff ff       	call   8010237e <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103219:	ba 00 00 00 00       	mov    $0x0,%edx
8010321e:	39 15 20 31 11 80    	cmp    %edx,0x80113120
80103224:	7e 23                	jle    80103249 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103226:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010322c:	0f b6 89 a0 2b 11 80 	movzbl -0x7feed460(%ecx),%ecx
80103233:	39 c1                	cmp    %eax,%ecx
80103235:	74 1f                	je     80103256 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103237:	83 c2 01             	add    $0x1,%edx
8010323a:	eb e2                	jmp    8010321e <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
8010323c:	83 ec 0c             	sub    $0xc,%esp
8010323f:	68 d8 71 10 80       	push   $0x801071d8
80103244:	e8 ff d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103249:	83 ec 0c             	sub    $0xc,%esp
8010324c:	68 fc 70 10 80       	push   $0x801070fc
80103251:	e8 f2 d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
80103256:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010325c:	05 a0 2b 11 80       	add    $0x80112ba0,%eax
}
80103261:	c9                   	leave  
80103262:	c3                   	ret    

80103263 <cpuid>:
cpuid() {
80103263:	55                   	push   %ebp
80103264:	89 e5                	mov    %esp,%ebp
80103266:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103269:	e8 99 ff ff ff       	call   80103207 <mycpu>
8010326e:	2d a0 2b 11 80       	sub    $0x80112ba0,%eax
80103273:	c1 f8 04             	sar    $0x4,%eax
80103276:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010327c:	c9                   	leave  
8010327d:	c3                   	ret    

8010327e <myproc>:
myproc(void) {
8010327e:	55                   	push   %ebp
8010327f:	89 e5                	mov    %esp,%ebp
80103281:	53                   	push   %ebx
80103282:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103285:	e8 be 0e 00 00       	call   80104148 <pushcli>
  c = mycpu();
8010328a:	e8 78 ff ff ff       	call   80103207 <mycpu>
  p = c->proc;
8010328f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103295:	e8 eb 0e 00 00       	call   80104185 <popcli>
}
8010329a:	89 d8                	mov    %ebx,%eax
8010329c:	83 c4 04             	add    $0x4,%esp
8010329f:	5b                   	pop    %ebx
801032a0:	5d                   	pop    %ebp
801032a1:	c3                   	ret    

801032a2 <userinit>:
{
801032a2:	55                   	push   %ebp
801032a3:	89 e5                	mov    %esp,%ebp
801032a5:	53                   	push   %ebx
801032a6:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801032a9:	e8 b6 fd ff ff       	call   80103064 <allocproc>
801032ae:	89 c3                	mov    %eax,%ebx
  initproc = p;
801032b0:	a3 c0 a9 10 80       	mov    %eax,0x8010a9c0
  if((p->pgdir = setupkvm()) == 0)
801032b5:	e8 80 36 00 00       	call   8010693a <setupkvm>
801032ba:	89 43 04             	mov    %eax,0x4(%ebx)
801032bd:	85 c0                	test   %eax,%eax
801032bf:	0f 84 b7 00 00 00    	je     8010337c <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801032c5:	83 ec 04             	sub    $0x4,%esp
801032c8:	68 2c 00 00 00       	push   $0x2c
801032cd:	68 60 a4 10 80       	push   $0x8010a460
801032d2:	50                   	push   %eax
801032d3:	e8 6d 33 00 00       	call   80106645 <inituvm>
  p->sz = PGSIZE;
801032d8:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801032de:	83 c4 0c             	add    $0xc,%esp
801032e1:	6a 4c                	push   $0x4c
801032e3:	6a 00                	push   $0x0
801032e5:	ff 73 18             	pushl  0x18(%ebx)
801032e8:	e8 e4 0f 00 00       	call   801042d1 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801032ed:	8b 43 18             	mov    0x18(%ebx),%eax
801032f0:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801032f6:	8b 43 18             	mov    0x18(%ebx),%eax
801032f9:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801032ff:	8b 43 18             	mov    0x18(%ebx),%eax
80103302:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103306:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010330a:	8b 43 18             	mov    0x18(%ebx),%eax
8010330d:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103311:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103315:	8b 43 18             	mov    0x18(%ebx),%eax
80103318:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010331f:	8b 43 18             	mov    0x18(%ebx),%eax
80103322:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103329:	8b 43 18             	mov    0x18(%ebx),%eax
8010332c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103333:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103336:	83 c4 0c             	add    $0xc,%esp
80103339:	6a 10                	push   $0x10
8010333b:	68 25 71 10 80       	push   $0x80107125
80103340:	50                   	push   %eax
80103341:	e8 f2 10 00 00       	call   80104438 <safestrcpy>
  p->cwd = namei("/");
80103346:	c7 04 24 2e 71 10 80 	movl   $0x8010712e,(%esp)
8010334d:	e8 8f e8 ff ff       	call   80101be1 <namei>
80103352:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103355:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
8010335c:	e8 c4 0e 00 00       	call   80104225 <acquire>
  p->state = RUNNABLE;
80103361:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103368:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
8010336f:	e8 16 0f 00 00       	call   8010428a <release>
}
80103374:	83 c4 10             	add    $0x10,%esp
80103377:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010337a:	c9                   	leave  
8010337b:	c3                   	ret    
    panic("userinit: out of memory?");
8010337c:	83 ec 0c             	sub    $0xc,%esp
8010337f:	68 0c 71 10 80       	push   $0x8010710c
80103384:	e8 bf cf ff ff       	call   80100348 <panic>

80103389 <growproc>:
{
80103389:	55                   	push   %ebp
8010338a:	89 e5                	mov    %esp,%ebp
8010338c:	56                   	push   %esi
8010338d:	53                   	push   %ebx
8010338e:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103391:	e8 e8 fe ff ff       	call   8010327e <myproc>
80103396:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103398:	8b 00                	mov    (%eax),%eax
  if(n > 0){
8010339a:	85 f6                	test   %esi,%esi
8010339c:	7f 21                	jg     801033bf <growproc+0x36>
  } else if(n < 0){
8010339e:	85 f6                	test   %esi,%esi
801033a0:	79 33                	jns    801033d5 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033a2:	83 ec 04             	sub    $0x4,%esp
801033a5:	01 c6                	add    %eax,%esi
801033a7:	56                   	push   %esi
801033a8:	50                   	push   %eax
801033a9:	ff 73 04             	pushl  0x4(%ebx)
801033ac:	e8 9d 33 00 00       	call   8010674e <deallocuvm>
801033b1:	83 c4 10             	add    $0x10,%esp
801033b4:	85 c0                	test   %eax,%eax
801033b6:	75 1d                	jne    801033d5 <growproc+0x4c>
      return -1;
801033b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033bd:	eb 29                	jmp    801033e8 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033bf:	83 ec 04             	sub    $0x4,%esp
801033c2:	01 c6                	add    %eax,%esi
801033c4:	56                   	push   %esi
801033c5:	50                   	push   %eax
801033c6:	ff 73 04             	pushl  0x4(%ebx)
801033c9:	e8 12 34 00 00       	call   801067e0 <allocuvm>
801033ce:	83 c4 10             	add    $0x10,%esp
801033d1:	85 c0                	test   %eax,%eax
801033d3:	74 1a                	je     801033ef <growproc+0x66>
  curproc->sz = sz;
801033d5:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801033d7:	83 ec 0c             	sub    $0xc,%esp
801033da:	53                   	push   %ebx
801033db:	e8 4d 31 00 00       	call   8010652d <switchuvm>
  return 0;
801033e0:	83 c4 10             	add    $0x10,%esp
801033e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033eb:	5b                   	pop    %ebx
801033ec:	5e                   	pop    %esi
801033ed:	5d                   	pop    %ebp
801033ee:	c3                   	ret    
      return -1;
801033ef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033f4:	eb f2                	jmp    801033e8 <growproc+0x5f>

801033f6 <delete>:
delete(struct proc **queue){
801033f6:	55                   	push   %ebp
801033f7:	89 e5                	mov    %esp,%ebp
801033f9:	53                   	push   %ebx
801033fa:	81 ec 00 01 00 00    	sub    $0x100,%esp
80103400:	8b 45 08             	mov    0x8(%ebp),%eax
  for(int i = 0; i < NPROC; i++){
80103403:	ba 00 00 00 00       	mov    $0x0,%edx
80103408:	eb 0f                	jmp    80103419 <delete+0x23>
    temp[i] = queue[i+1];
8010340a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010340d:	8b 1c 88             	mov    (%eax,%ecx,4),%ebx
80103410:	89 9c 95 fc fe ff ff 	mov    %ebx,-0x104(%ebp,%edx,4)
  for(int i = 0; i < NPROC; i++){
80103417:	89 ca                	mov    %ecx,%edx
80103419:	83 fa 3f             	cmp    $0x3f,%edx
8010341c:	7e ec                	jle    8010340a <delete+0x14>
  for(int i = 0; i < NPROC; i++){
8010341e:	ba 00 00 00 00       	mov    $0x0,%edx
80103423:	eb 0d                	jmp    80103432 <delete+0x3c>
    queue[i] = temp[i];
80103425:	8b 8c 95 fc fe ff ff 	mov    -0x104(%ebp,%edx,4),%ecx
8010342c:	89 0c 90             	mov    %ecx,(%eax,%edx,4)
  for(int i = 0; i < NPROC; i++){
8010342f:	83 c2 01             	add    $0x1,%edx
80103432:	83 fa 3f             	cmp    $0x3f,%edx
80103435:	7e ee                	jle    80103425 <delete+0x2f>
  queue[NPROC-1] = 0;
80103437:	c7 80 fc 00 00 00 00 	movl   $0x0,0xfc(%eax)
8010343e:	00 00 00 
}
80103441:	81 c4 00 01 00 00    	add    $0x100,%esp
80103447:	5b                   	pop    %ebx
80103448:	5d                   	pop    %ebp
80103449:	c3                   	ret    

8010344a <scheduler>:
{
8010344a:	55                   	push   %ebp
8010344b:	89 e5                	mov    %esp,%ebp
8010344d:	57                   	push   %edi
8010344e:	56                   	push   %esi
8010344f:	53                   	push   %ebx
80103450:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103453:	e8 af fd ff ff       	call   80103207 <mycpu>
80103458:	89 c7                	mov    %eax,%edi
  c->proc = 0;
8010345a:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103461:	00 00 00 
80103464:	e9 c3 04 00 00       	jmp    8010392c <scheduler+0x4e2>
          for(int i = 0; i < NPROC; i++){
80103469:	83 c2 01             	add    $0x1,%edx
8010346c:	83 fa 3f             	cmp    $0x3f,%edx
8010346f:	7f 3b                	jg     801034ac <scheduler+0x62>
          	 if(q3[i] == 0){
80103471:	8b 0c 95 c0 a5 10 80 	mov    -0x7fef5a40(,%edx,4),%ecx
80103478:	85 c9                	test   %ecx,%ecx
8010347a:	74 ed                	je     80103469 <scheduler+0x1f>
            if(q3[i]->pid == p->pid){
8010347c:	8b 58 10             	mov    0x10(%eax),%ebx
8010347f:	39 59 10             	cmp    %ebx,0x10(%ecx)
80103482:	75 e5                	jne    80103469 <scheduler+0x1f>
              match = 1;
80103484:	ba 01 00 00 00       	mov    $0x1,%edx
          if (match == 0) {
80103489:	85 d2                	test   %edx,%edx
8010348b:	0f 85 43 02 00 00    	jne    801036d4 <scheduler+0x28a>
            for(int i = 0; i < NPROC; i++){
80103491:	83 fa 3f             	cmp    $0x3f,%edx
80103494:	7f 24                	jg     801034ba <scheduler+0x70>
              if(q3[i] == 0){
80103496:	83 3c 95 c0 a5 10 80 	cmpl   $0x0,-0x7fef5a40(,%edx,4)
8010349d:	00 
8010349e:	74 13                	je     801034b3 <scheduler+0x69>
            for(int i = 0; i < NPROC; i++){
801034a0:	83 c2 01             	add    $0x1,%edx
801034a3:	eb ec                	jmp    80103491 <scheduler+0x47>
          for(int i = 0; i < NPROC; i++){
801034a5:	ba 00 00 00 00       	mov    $0x0,%edx
801034aa:	eb c0                	jmp    8010346c <scheduler+0x22>
          int match = 0;
801034ac:	ba 00 00 00 00       	mov    $0x0,%edx
801034b1:	eb d6                	jmp    80103489 <scheduler+0x3f>
                q3[i] = p;
801034b3:	89 04 95 c0 a5 10 80 	mov    %eax,-0x7fef5a40(,%edx,4)
            p->qtail[3] = p->qtail[3] + 1;
801034ba:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
801034c0:	8d 51 01             	lea    0x1(%ecx),%edx
801034c3:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
            p->ticks[3] = 8;
801034c9:	c7 80 98 00 00 00 08 	movl   $0x8,0x98(%eax)
801034d0:	00 00 00 
801034d3:	e9 fc 01 00 00       	jmp    801036d4 <scheduler+0x28a>
          for(int i = 0; i < NPROC; i++){
801034d8:	83 c2 01             	add    $0x1,%edx
801034db:	83 fa 3f             	cmp    $0x3f,%edx
801034de:	7f 3b                	jg     8010351b <scheduler+0xd1>
          	 if(q2[i] == 0){
801034e0:	8b 0c 95 c0 a6 10 80 	mov    -0x7fef5940(,%edx,4),%ecx
801034e7:	85 c9                	test   %ecx,%ecx
801034e9:	74 ed                	je     801034d8 <scheduler+0x8e>
            if(q2[i]->pid == p->pid){
801034eb:	8b 58 10             	mov    0x10(%eax),%ebx
801034ee:	39 59 10             	cmp    %ebx,0x10(%ecx)
801034f1:	75 e5                	jne    801034d8 <scheduler+0x8e>
              match = 1;
801034f3:	ba 01 00 00 00       	mov    $0x1,%edx
          if (match == 0) {
801034f8:	85 d2                	test   %edx,%edx
801034fa:	0f 85 d4 01 00 00    	jne    801036d4 <scheduler+0x28a>
            for(int i = 0; i < NPROC; i++){
80103500:	83 fa 3f             	cmp    $0x3f,%edx
80103503:	7f 24                	jg     80103529 <scheduler+0xdf>
              if(q2[i] == 0){
80103505:	83 3c 95 c0 a6 10 80 	cmpl   $0x0,-0x7fef5940(,%edx,4)
8010350c:	00 
8010350d:	74 13                	je     80103522 <scheduler+0xd8>
            for(int i = 0; i < NPROC; i++){
8010350f:	83 c2 01             	add    $0x1,%edx
80103512:	eb ec                	jmp    80103500 <scheduler+0xb6>
          for(int i = 0; i < NPROC; i++){
80103514:	ba 00 00 00 00       	mov    $0x0,%edx
80103519:	eb c0                	jmp    801034db <scheduler+0x91>
          int match = 0;
8010351b:	ba 00 00 00 00       	mov    $0x0,%edx
80103520:	eb d6                	jmp    801034f8 <scheduler+0xae>
                q2[i] = p;
80103522:	89 04 95 c0 a6 10 80 	mov    %eax,-0x7fef5940(,%edx,4)
            p->qtail[2] = p->qtail[2] + 1;
80103529:	8b 88 84 00 00 00    	mov    0x84(%eax),%ecx
8010352f:	8d 51 01             	lea    0x1(%ecx),%edx
80103532:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
            p->ticks[2] = 12;
80103538:	c7 80 94 00 00 00 0c 	movl   $0xc,0x94(%eax)
8010353f:	00 00 00 
80103542:	e9 8d 01 00 00       	jmp    801036d4 <scheduler+0x28a>
          for(int i = 0; i < NPROC; i++){
80103547:	83 c1 01             	add    $0x1,%ecx
8010354a:	83 f9 3f             	cmp    $0x3f,%ecx
8010354d:	7f 36                	jg     80103585 <scheduler+0x13b>
          	 if(q1[i] == 0){
8010354f:	8b 1c 8d c0 a7 10 80 	mov    -0x7fef5840(,%ecx,4),%ebx
80103556:	85 db                	test   %ebx,%ebx
80103558:	74 ed                	je     80103547 <scheduler+0xfd>
            if(q1[i]->pid == p->pid){
8010355a:	8b 70 10             	mov    0x10(%eax),%esi
8010355d:	39 73 10             	cmp    %esi,0x10(%ebx)
80103560:	75 e5                	jne    80103547 <scheduler+0xfd>
          if (match == 0) {
80103562:	85 d2                	test   %edx,%edx
80103564:	0f 85 6a 01 00 00    	jne    801036d4 <scheduler+0x28a>
            for(int i = 0; i < NPROC; i++){
8010356a:	83 fa 3f             	cmp    $0x3f,%edx
8010356d:	7f 24                	jg     80103593 <scheduler+0x149>
              if(q1[i] == 0){
8010356f:	83 3c 95 c0 a7 10 80 	cmpl   $0x0,-0x7fef5840(,%edx,4)
80103576:	00 
80103577:	74 13                	je     8010358c <scheduler+0x142>
            for(int i = 0; i < NPROC; i++){
80103579:	83 c2 01             	add    $0x1,%edx
8010357c:	eb ec                	jmp    8010356a <scheduler+0x120>
          for(int i = 0; i < NPROC; i++){
8010357e:	b9 00 00 00 00       	mov    $0x0,%ecx
80103583:	eb c5                	jmp    8010354a <scheduler+0x100>
          int match = 0;
80103585:	ba 00 00 00 00       	mov    $0x0,%edx
8010358a:	eb d6                	jmp    80103562 <scheduler+0x118>
                q1[i] = p;
8010358c:	89 04 95 c0 a7 10 80 	mov    %eax,-0x7fef5840(,%edx,4)
            p->qtail[1] = p->qtail[1] + 1;
80103593:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
80103599:	8d 51 01             	lea    0x1(%ecx),%edx
8010359c:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
            p->ticks[1] = 16;
801035a2:	c7 80 90 00 00 00 10 	movl   $0x10,0x90(%eax)
801035a9:	00 00 00 
801035ac:	e9 23 01 00 00       	jmp    801036d4 <scheduler+0x28a>
          for(int i = 0; i < NPROC; i++){
801035b1:	83 c1 01             	add    $0x1,%ecx
801035b4:	83 f9 3f             	cmp    $0x3f,%ecx
801035b7:	7f 18                	jg     801035d1 <scheduler+0x187>
            if(q0[i] == 0){
801035b9:	8b 1c 8d c0 a8 10 80 	mov    -0x7fef5740(,%ecx,4),%ebx
801035c0:	85 db                	test   %ebx,%ebx
801035c2:	74 ed                	je     801035b1 <scheduler+0x167>
            if(q0[i]->pid == p->pid){
801035c4:	8b 70 10             	mov    0x10(%eax),%esi
801035c7:	39 73 10             	cmp    %esi,0x10(%ebx)
801035ca:	75 e5                	jne    801035b1 <scheduler+0x167>
              match = 1;
801035cc:	ba 01 00 00 00       	mov    $0x1,%edx
          if (match == 0) {
801035d1:	85 d2                	test   %edx,%edx
801035d3:	0f 85 fb 00 00 00    	jne    801036d4 <scheduler+0x28a>
            for(int i = 0; i < NPROC; i++){
801035d9:	83 fa 3f             	cmp    $0x3f,%edx
801035dc:	7f 1a                	jg     801035f8 <scheduler+0x1ae>
              if(q0[i] == 0){
801035de:	83 3c 95 c0 a8 10 80 	cmpl   $0x0,-0x7fef5740(,%edx,4)
801035e5:	00 
801035e6:	74 09                	je     801035f1 <scheduler+0x1a7>
            for(int i = 0; i < NPROC; i++){
801035e8:	83 c2 01             	add    $0x1,%edx
801035eb:	eb ec                	jmp    801035d9 <scheduler+0x18f>
          for(int i = 0; i < NPROC; i++){
801035ed:	89 d1                	mov    %edx,%ecx
801035ef:	eb c3                	jmp    801035b4 <scheduler+0x16a>
                q0[i] = p;
801035f1:	89 04 95 c0 a8 10 80 	mov    %eax,-0x7fef5740(,%edx,4)
            p->qtail[0] = p->qtail[0] + 1;
801035f8:	8b 48 7c             	mov    0x7c(%eax),%ecx
801035fb:	8d 51 01             	lea    0x1(%ecx),%edx
801035fe:	89 50 7c             	mov    %edx,0x7c(%eax)
            p->ticks[0] = 20;
80103601:	c7 80 8c 00 00 00 14 	movl   $0x14,0x8c(%eax)
80103608:	00 00 00 
8010360b:	e9 c4 00 00 00       	jmp    801036d4 <scheduler+0x28a>
      		p = q3[0];
80103610:	8b 35 c0 a5 10 80    	mov    0x8010a5c0,%esi
      	for(int i=0; i<NPROC; i++){
80103616:	83 c3 01             	add    $0x1,%ebx
80103619:	83 fb 3f             	cmp    $0x3f,%ebx
8010361c:	7f 22                	jg     80103640 <scheduler+0x1f6>
      		if(p->state != RUNNABLE){
8010361e:	83 7e 0c 03          	cmpl   $0x3,0xc(%esi)
80103622:	74 ec                	je     80103610 <scheduler+0x1c6>
	      		delete(q3);
80103624:	83 ec 0c             	sub    $0xc,%esp
80103627:	68 c0 a5 10 80       	push   $0x8010a5c0
8010362c:	e8 c5 fd ff ff       	call   801033f6 <delete>
	          	p->ticksUsed[3] = 0;
80103631:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103638:	00 00 00 
8010363b:	83 c4 10             	add    $0x10,%esp
8010363e:	eb d0                	jmp    80103610 <scheduler+0x1c6>
        if(p->ticksUsed[3] < 8){
80103640:	83 be ac 00 00 00 07 	cmpl   $0x7,0xac(%esi)
80103647:	0f 8f 9b 00 00 00    	jg     801036e8 <scheduler+0x29e>
          c->proc = p;
8010364d:	89 b7 ac 00 00 00    	mov    %esi,0xac(%edi)
          switchuvm(p);
80103653:	83 ec 0c             	sub    $0xc,%esp
80103656:	56                   	push   %esi
80103657:	e8 d1 2e 00 00       	call   8010652d <switchuvm>
          p->state = RUNNING;
8010365c:	c7 46 0c 04 00 00 00 	movl   $0x4,0xc(%esi)
          swtch(&(c->scheduler), p->context);
80103663:	83 c4 08             	add    $0x8,%esp
80103666:	ff 76 1c             	pushl  0x1c(%esi)
80103669:	8d 47 04             	lea    0x4(%edi),%eax
8010366c:	50                   	push   %eax
8010366d:	e8 19 0e 00 00       	call   8010448b <swtch>
          switchkvm();
80103672:	e8 a4 2e 00 00       	call   8010651b <switchkvm>
          p->ticksUsed[3] = p->ticksUsed[3] + 1;
80103677:	8b 86 ac 00 00 00    	mov    0xac(%esi),%eax
8010367d:	83 c0 01             	add    $0x1,%eax
80103680:	89 86 ac 00 00 00    	mov    %eax,0xac(%esi)
80103686:	83 c4 10             	add    $0x10,%esp
80103689:	89 f0                	mov    %esi,%eax
      c->proc = 0;
8010368b:	c7 87 ac 00 00 00 00 	movl   $0x0,0xac(%edi)
80103692:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103695:	05 b0 00 00 00       	add    $0xb0,%eax
8010369a:	3d 74 5d 11 80       	cmp    $0x80115d74,%eax
8010369f:	0f 83 77 02 00 00    	jae    8010391c <scheduler+0x4d2>
    	if(p->state != RUNNABLE)
801036a5:	83 78 0c 03          	cmpl   $0x3,0xc(%eax)
801036a9:	75 ea                	jne    80103695 <scheduler+0x24b>
        if(p->priority == 3){
801036ab:	8b 90 9c 00 00 00    	mov    0x9c(%eax),%edx
801036b1:	83 fa 03             	cmp    $0x3,%edx
801036b4:	0f 84 eb fd ff ff    	je     801034a5 <scheduler+0x5b>
        else if(p->priority == 2){
801036ba:	83 fa 02             	cmp    $0x2,%edx
801036bd:	0f 84 51 fe ff ff    	je     80103514 <scheduler+0xca>
        else if(p->priority == 1){
801036c3:	83 fa 01             	cmp    $0x1,%edx
801036c6:	0f 84 b2 fe ff ff    	je     8010357e <scheduler+0x134>
        else if(p->priority == 0){
801036cc:	85 d2                	test   %edx,%edx
801036ce:	0f 84 19 ff ff ff    	je     801035ed <scheduler+0x1a3>
      if(q3[0] != 0){
801036d4:	8b 35 c0 a5 10 80    	mov    0x8010a5c0,%esi
801036da:	85 f6                	test   %esi,%esi
801036dc:	74 28                	je     80103706 <scheduler+0x2bc>
      	for(int i=0; i<NPROC; i++){
801036de:	bb 00 00 00 00       	mov    $0x0,%ebx
801036e3:	e9 31 ff ff ff       	jmp    80103619 <scheduler+0x1cf>
          delete(q3);
801036e8:	83 ec 0c             	sub    $0xc,%esp
801036eb:	68 c0 a5 10 80       	push   $0x8010a5c0
801036f0:	e8 01 fd ff ff       	call   801033f6 <delete>
          p->ticksUsed[3] = 0;
801036f5:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801036fc:	00 00 00 
801036ff:	83 c4 10             	add    $0x10,%esp
80103702:	89 f0                	mov    %esi,%eax
80103704:	eb 85                	jmp    8010368b <scheduler+0x241>
      } else if(q2[0] != 0) {
80103706:	8b 35 c0 a6 10 80    	mov    0x8010a6c0,%esi
8010370c:	85 f6                	test   %esi,%esi
8010370e:	0f 84 a4 00 00 00    	je     801037b8 <scheduler+0x36e>
      	for(int i=0; i<NPROC; i++){
80103714:	bb 00 00 00 00       	mov    $0x0,%ebx
80103719:	eb 09                	jmp    80103724 <scheduler+0x2da>
      		p = q2[0];
8010371b:	8b 35 c0 a6 10 80    	mov    0x8010a6c0,%esi
      	for(int i=0; i<NPROC; i++){
80103721:	83 c3 01             	add    $0x1,%ebx
80103724:	83 fb 3f             	cmp    $0x3f,%ebx
80103727:	7f 22                	jg     8010374b <scheduler+0x301>
      		if(p->state != RUNNABLE){
80103729:	83 7e 0c 03          	cmpl   $0x3,0xc(%esi)
8010372d:	74 ec                	je     8010371b <scheduler+0x2d1>
	      		delete(q2);
8010372f:	83 ec 0c             	sub    $0xc,%esp
80103732:	68 c0 a6 10 80       	push   $0x8010a6c0
80103737:	e8 ba fc ff ff       	call   801033f6 <delete>
	          	p->ticksUsed[2] = 0;
8010373c:	c7 86 a8 00 00 00 00 	movl   $0x0,0xa8(%esi)
80103743:	00 00 00 
80103746:	83 c4 10             	add    $0x10,%esp
80103749:	eb d0                	jmp    8010371b <scheduler+0x2d1>
        if(p->ticksUsed[2] < 12){
8010374b:	83 be a8 00 00 00 0b 	cmpl   $0xb,0xa8(%esi)
80103752:	7f 43                	jg     80103797 <scheduler+0x34d>
          c->proc = p;
80103754:	89 b7 ac 00 00 00    	mov    %esi,0xac(%edi)
          switchuvm(p);
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	56                   	push   %esi
8010375e:	e8 ca 2d 00 00       	call   8010652d <switchuvm>
          p->state = RUNNING;
80103763:	c7 46 0c 04 00 00 00 	movl   $0x4,0xc(%esi)
          swtch(&(c->scheduler), p->context);
8010376a:	83 c4 08             	add    $0x8,%esp
8010376d:	ff 76 1c             	pushl  0x1c(%esi)
80103770:	8d 47 04             	lea    0x4(%edi),%eax
80103773:	50                   	push   %eax
80103774:	e8 12 0d 00 00       	call   8010448b <swtch>
          switchkvm();
80103779:	e8 9d 2d 00 00       	call   8010651b <switchkvm>
          p->ticksUsed[2] = p->ticksUsed[2] + 1;
8010377e:	8b 86 a8 00 00 00    	mov    0xa8(%esi),%eax
80103784:	83 c0 01             	add    $0x1,%eax
80103787:	89 86 a8 00 00 00    	mov    %eax,0xa8(%esi)
8010378d:	83 c4 10             	add    $0x10,%esp
80103790:	89 f0                	mov    %esi,%eax
80103792:	e9 f4 fe ff ff       	jmp    8010368b <scheduler+0x241>
          delete(q2);
80103797:	83 ec 0c             	sub    $0xc,%esp
8010379a:	68 c0 a6 10 80       	push   $0x8010a6c0
8010379f:	e8 52 fc ff ff       	call   801033f6 <delete>
          p->ticksUsed[2] = 0;
801037a4:	c7 86 a8 00 00 00 00 	movl   $0x0,0xa8(%esi)
801037ab:	00 00 00 
801037ae:	83 c4 10             	add    $0x10,%esp
801037b1:	89 f0                	mov    %esi,%eax
801037b3:	e9 d3 fe ff ff       	jmp    8010368b <scheduler+0x241>
      } else if(q1[0] != 0) {
801037b8:	8b 35 c0 a7 10 80    	mov    0x8010a7c0,%esi
801037be:	85 f6                	test   %esi,%esi
801037c0:	0f 84 a4 00 00 00    	je     8010386a <scheduler+0x420>
      	for(int i=0; i<NPROC; i++){
801037c6:	bb 00 00 00 00       	mov    $0x0,%ebx
801037cb:	eb 09                	jmp    801037d6 <scheduler+0x38c>
      		p = q1[0];
801037cd:	8b 35 c0 a7 10 80    	mov    0x8010a7c0,%esi
      	for(int i=0; i<NPROC; i++){
801037d3:	83 c3 01             	add    $0x1,%ebx
801037d6:	83 fb 3f             	cmp    $0x3f,%ebx
801037d9:	7f 22                	jg     801037fd <scheduler+0x3b3>
      		if(p->state != RUNNABLE){
801037db:	83 7e 0c 03          	cmpl   $0x3,0xc(%esi)
801037df:	74 ec                	je     801037cd <scheduler+0x383>
	      		delete(q1);
801037e1:	83 ec 0c             	sub    $0xc,%esp
801037e4:	68 c0 a7 10 80       	push   $0x8010a7c0
801037e9:	e8 08 fc ff ff       	call   801033f6 <delete>
	          	p->ticksUsed[1] = 0;
801037ee:	c7 86 a4 00 00 00 00 	movl   $0x0,0xa4(%esi)
801037f5:	00 00 00 
801037f8:	83 c4 10             	add    $0x10,%esp
801037fb:	eb d0                	jmp    801037cd <scheduler+0x383>
        if(p->ticksUsed[1] < 16){
801037fd:	83 be a4 00 00 00 0f 	cmpl   $0xf,0xa4(%esi)
80103804:	7f 43                	jg     80103849 <scheduler+0x3ff>
          c->proc = p;
80103806:	89 b7 ac 00 00 00    	mov    %esi,0xac(%edi)
          switchuvm(p);
8010380c:	83 ec 0c             	sub    $0xc,%esp
8010380f:	56                   	push   %esi
80103810:	e8 18 2d 00 00       	call   8010652d <switchuvm>
          p->state = RUNNING;
80103815:	c7 46 0c 04 00 00 00 	movl   $0x4,0xc(%esi)
          swtch(&(c->scheduler), p->context);
8010381c:	83 c4 08             	add    $0x8,%esp
8010381f:	ff 76 1c             	pushl  0x1c(%esi)
80103822:	8d 47 04             	lea    0x4(%edi),%eax
80103825:	50                   	push   %eax
80103826:	e8 60 0c 00 00       	call   8010448b <swtch>
          switchkvm();
8010382b:	e8 eb 2c 00 00       	call   8010651b <switchkvm>
          p->ticksUsed[1] = p->ticksUsed[1] + 1;
80103830:	8b 86 a4 00 00 00    	mov    0xa4(%esi),%eax
80103836:	83 c0 01             	add    $0x1,%eax
80103839:	89 86 a4 00 00 00    	mov    %eax,0xa4(%esi)
8010383f:	83 c4 10             	add    $0x10,%esp
80103842:	89 f0                	mov    %esi,%eax
80103844:	e9 42 fe ff ff       	jmp    8010368b <scheduler+0x241>
          delete(q1);
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	68 c0 a7 10 80       	push   $0x8010a7c0
80103851:	e8 a0 fb ff ff       	call   801033f6 <delete>
          p->ticksUsed[1] = 0;
80103856:	c7 86 a4 00 00 00 00 	movl   $0x0,0xa4(%esi)
8010385d:	00 00 00 
80103860:	83 c4 10             	add    $0x10,%esp
80103863:	89 f0                	mov    %esi,%eax
80103865:	e9 21 fe ff ff       	jmp    8010368b <scheduler+0x241>
      } else if(q0[0] != 0) {
8010386a:	8b 1d c0 a8 10 80    	mov    0x8010a8c0,%ebx
80103870:	85 db                	test   %ebx,%ebx
80103872:	0f 84 13 fe ff ff    	je     8010368b <scheduler+0x241>
      	for(int i=0; i<NPROC; i++){
80103878:	be 00 00 00 00       	mov    $0x0,%esi
8010387d:	eb 09                	jmp    80103888 <scheduler+0x43e>
      		p = q0[0];
8010387f:	8b 1d c0 a8 10 80    	mov    0x8010a8c0,%ebx
      	for(int i=0; i<NPROC; i++){
80103885:	83 c6 01             	add    $0x1,%esi
80103888:	83 fe 3f             	cmp    $0x3f,%esi
8010388b:	7f 22                	jg     801038af <scheduler+0x465>
      		if(p->state != RUNNABLE){
8010388d:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103891:	74 ec                	je     8010387f <scheduler+0x435>
	      		delete(q0);
80103893:	83 ec 0c             	sub    $0xc,%esp
80103896:	68 c0 a8 10 80       	push   $0x8010a8c0
8010389b:	e8 56 fb ff ff       	call   801033f6 <delete>
	          	p->ticksUsed[0] = 0;
801038a0:	c7 83 a0 00 00 00 00 	movl   $0x0,0xa0(%ebx)
801038a7:	00 00 00 
801038aa:	83 c4 10             	add    $0x10,%esp
801038ad:	eb d0                	jmp    8010387f <scheduler+0x435>
        if(p->ticksUsed[0] < 20){
801038af:	83 bb a0 00 00 00 13 	cmpl   $0x13,0xa0(%ebx)
801038b6:	7f 43                	jg     801038fb <scheduler+0x4b1>
          c->proc = p;
801038b8:	89 9f ac 00 00 00    	mov    %ebx,0xac(%edi)
          switchuvm(p);
801038be:	83 ec 0c             	sub    $0xc,%esp
801038c1:	53                   	push   %ebx
801038c2:	e8 66 2c 00 00       	call   8010652d <switchuvm>
          p->state = RUNNING;
801038c7:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
          swtch(&(c->scheduler), p->context);
801038ce:	83 c4 08             	add    $0x8,%esp
801038d1:	ff 73 1c             	pushl  0x1c(%ebx)
801038d4:	8d 47 04             	lea    0x4(%edi),%eax
801038d7:	50                   	push   %eax
801038d8:	e8 ae 0b 00 00       	call   8010448b <swtch>
          switchkvm();
801038dd:	e8 39 2c 00 00       	call   8010651b <switchkvm>
          p->ticksUsed[0] = p->ticksUsed[0] + 1;
801038e2:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
801038e8:	83 c0 01             	add    $0x1,%eax
801038eb:	89 83 a0 00 00 00    	mov    %eax,0xa0(%ebx)
801038f1:	83 c4 10             	add    $0x10,%esp
801038f4:	89 d8                	mov    %ebx,%eax
801038f6:	e9 90 fd ff ff       	jmp    8010368b <scheduler+0x241>
          delete(q0);
801038fb:	83 ec 0c             	sub    $0xc,%esp
801038fe:	68 c0 a8 10 80       	push   $0x8010a8c0
80103903:	e8 ee fa ff ff       	call   801033f6 <delete>
          p->ticksUsed[0] = 0;
80103908:	c7 83 a0 00 00 00 00 	movl   $0x0,0xa0(%ebx)
8010390f:	00 00 00 
80103912:	83 c4 10             	add    $0x10,%esp
80103915:	89 d8                	mov    %ebx,%eax
80103917:	e9 6f fd ff ff       	jmp    8010368b <scheduler+0x241>
    release(&ptable.lock);
8010391c:	83 ec 0c             	sub    $0xc,%esp
8010391f:	68 40 31 11 80       	push   $0x80113140
80103924:	e8 61 09 00 00       	call   8010428a <release>
    sti();
80103929:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
8010392c:	fb                   	sti    
    acquire(&ptable.lock);
8010392d:	83 ec 0c             	sub    $0xc,%esp
80103930:	68 40 31 11 80       	push   $0x80113140
80103935:	e8 eb 08 00 00       	call   80104225 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010393a:	83 c4 10             	add    $0x10,%esp
8010393d:	b8 74 31 11 80       	mov    $0x80113174,%eax
80103942:	e9 53 fd ff ff       	jmp    8010369a <scheduler+0x250>

80103947 <sched>:
{
80103947:	55                   	push   %ebp
80103948:	89 e5                	mov    %esp,%ebp
8010394a:	56                   	push   %esi
8010394b:	53                   	push   %ebx
  struct proc *p = myproc();
8010394c:	e8 2d f9 ff ff       	call   8010327e <myproc>
80103951:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103953:	83 ec 0c             	sub    $0xc,%esp
80103956:	68 40 31 11 80       	push   $0x80113140
8010395b:	e8 85 08 00 00       	call   801041e5 <holding>
80103960:	83 c4 10             	add    $0x10,%esp
80103963:	85 c0                	test   %eax,%eax
80103965:	74 4f                	je     801039b6 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103967:	e8 9b f8 ff ff       	call   80103207 <mycpu>
8010396c:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103973:	75 4e                	jne    801039c3 <sched+0x7c>
  if(p->state == RUNNING)
80103975:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103979:	74 55                	je     801039d0 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010397b:	9c                   	pushf  
8010397c:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010397d:	f6 c4 02             	test   $0x2,%ah
80103980:	75 5b                	jne    801039dd <sched+0x96>
  intena = mycpu()->intena;
80103982:	e8 80 f8 ff ff       	call   80103207 <mycpu>
80103987:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010398d:	e8 75 f8 ff ff       	call   80103207 <mycpu>
80103992:	83 ec 08             	sub    $0x8,%esp
80103995:	ff 70 04             	pushl  0x4(%eax)
80103998:	83 c3 1c             	add    $0x1c,%ebx
8010399b:	53                   	push   %ebx
8010399c:	e8 ea 0a 00 00       	call   8010448b <swtch>
  mycpu()->intena = intena;
801039a1:	e8 61 f8 ff ff       	call   80103207 <mycpu>
801039a6:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801039ac:	83 c4 10             	add    $0x10,%esp
801039af:	8d 65 f8             	lea    -0x8(%ebp),%esp
801039b2:	5b                   	pop    %ebx
801039b3:	5e                   	pop    %esi
801039b4:	5d                   	pop    %ebp
801039b5:	c3                   	ret    
    panic("sched ptable.lock");
801039b6:	83 ec 0c             	sub    $0xc,%esp
801039b9:	68 30 71 10 80       	push   $0x80107130
801039be:	e8 85 c9 ff ff       	call   80100348 <panic>
    panic("sched locks");
801039c3:	83 ec 0c             	sub    $0xc,%esp
801039c6:	68 42 71 10 80       	push   $0x80107142
801039cb:	e8 78 c9 ff ff       	call   80100348 <panic>
    panic("sched running");
801039d0:	83 ec 0c             	sub    $0xc,%esp
801039d3:	68 4e 71 10 80       	push   $0x8010714e
801039d8:	e8 6b c9 ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801039dd:	83 ec 0c             	sub    $0xc,%esp
801039e0:	68 5c 71 10 80       	push   $0x8010715c
801039e5:	e8 5e c9 ff ff       	call   80100348 <panic>

801039ea <exit>:
{
801039ea:	55                   	push   %ebp
801039eb:	89 e5                	mov    %esp,%ebp
801039ed:	56                   	push   %esi
801039ee:	53                   	push   %ebx
  struct proc *curproc = myproc();
801039ef:	e8 8a f8 ff ff       	call   8010327e <myproc>
  if(curproc == initproc)
801039f4:	39 05 c0 a9 10 80    	cmp    %eax,0x8010a9c0
801039fa:	74 09                	je     80103a05 <exit+0x1b>
801039fc:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801039fe:	bb 00 00 00 00       	mov    $0x0,%ebx
80103a03:	eb 10                	jmp    80103a15 <exit+0x2b>
    panic("init exiting");
80103a05:	83 ec 0c             	sub    $0xc,%esp
80103a08:	68 70 71 10 80       	push   $0x80107170
80103a0d:	e8 36 c9 ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103a12:	83 c3 01             	add    $0x1,%ebx
80103a15:	83 fb 0f             	cmp    $0xf,%ebx
80103a18:	7f 1e                	jg     80103a38 <exit+0x4e>
    if(curproc->ofile[fd]){
80103a1a:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103a1e:	85 c0                	test   %eax,%eax
80103a20:	74 f0                	je     80103a12 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103a22:	83 ec 0c             	sub    $0xc,%esp
80103a25:	50                   	push   %eax
80103a26:	e8 a8 d2 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103a2b:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103a32:	00 
80103a33:	83 c4 10             	add    $0x10,%esp
80103a36:	eb da                	jmp    80103a12 <exit+0x28>
  begin_op();
80103a38:	e8 71 ed ff ff       	call   801027ae <begin_op>
  iput(curproc->cwd);
80103a3d:	83 ec 0c             	sub    $0xc,%esp
80103a40:	ff 76 68             	pushl  0x68(%esi)
80103a43:	e8 40 dc ff ff       	call   80101688 <iput>
  end_op();
80103a48:	e8 db ed ff ff       	call   80102828 <end_op>
  curproc->cwd = 0;
80103a4d:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103a54:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103a5b:	e8 c5 07 00 00       	call   80104225 <acquire>
  wakeup1(curproc->parent);
80103a60:	8b 46 14             	mov    0x14(%esi),%eax
80103a63:	e8 ce f5 ff ff       	call   80103036 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a68:	83 c4 10             	add    $0x10,%esp
80103a6b:	bb 74 31 11 80       	mov    $0x80113174,%ebx
80103a70:	eb 06                	jmp    80103a78 <exit+0x8e>
80103a72:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103a78:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103a7e:	73 1a                	jae    80103a9a <exit+0xb0>
    if(p->parent == curproc){
80103a80:	39 73 14             	cmp    %esi,0x14(%ebx)
80103a83:	75 ed                	jne    80103a72 <exit+0x88>
      p->parent = initproc;
80103a85:	a1 c0 a9 10 80       	mov    0x8010a9c0,%eax
80103a8a:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103a8d:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103a91:	75 df                	jne    80103a72 <exit+0x88>
        wakeup1(initproc);
80103a93:	e8 9e f5 ff ff       	call   80103036 <wakeup1>
80103a98:	eb d8                	jmp    80103a72 <exit+0x88>
  curproc->state = ZOMBIE;
80103a9a:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103aa1:	e8 a1 fe ff ff       	call   80103947 <sched>
  panic("zombie exit");
80103aa6:	83 ec 0c             	sub    $0xc,%esp
80103aa9:	68 7d 71 10 80       	push   $0x8010717d
80103aae:	e8 95 c8 ff ff       	call   80100348 <panic>

80103ab3 <yield>:
{
80103ab3:	55                   	push   %ebp
80103ab4:	89 e5                	mov    %esp,%ebp
80103ab6:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103ab9:	68 40 31 11 80       	push   $0x80113140
80103abe:	e8 62 07 00 00       	call   80104225 <acquire>
  myproc()->state = RUNNABLE;
80103ac3:	e8 b6 f7 ff ff       	call   8010327e <myproc>
80103ac8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103acf:	e8 73 fe ff ff       	call   80103947 <sched>
  release(&ptable.lock);
80103ad4:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103adb:	e8 aa 07 00 00       	call   8010428a <release>
}
80103ae0:	83 c4 10             	add    $0x10,%esp
80103ae3:	c9                   	leave  
80103ae4:	c3                   	ret    

80103ae5 <sleep>:
{
80103ae5:	55                   	push   %ebp
80103ae6:	89 e5                	mov    %esp,%ebp
80103ae8:	56                   	push   %esi
80103ae9:	53                   	push   %ebx
80103aea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103aed:	e8 8c f7 ff ff       	call   8010327e <myproc>
  if(p == 0)
80103af2:	85 c0                	test   %eax,%eax
80103af4:	74 66                	je     80103b5c <sleep+0x77>
80103af6:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103af8:	85 db                	test   %ebx,%ebx
80103afa:	74 6d                	je     80103b69 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103afc:	81 fb 40 31 11 80    	cmp    $0x80113140,%ebx
80103b02:	74 18                	je     80103b1c <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103b04:	83 ec 0c             	sub    $0xc,%esp
80103b07:	68 40 31 11 80       	push   $0x80113140
80103b0c:	e8 14 07 00 00       	call   80104225 <acquire>
    release(lk);
80103b11:	89 1c 24             	mov    %ebx,(%esp)
80103b14:	e8 71 07 00 00       	call   8010428a <release>
80103b19:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103b1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103b1f:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103b22:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103b29:	e8 19 fe ff ff       	call   80103947 <sched>
  p->chan = 0;
80103b2e:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103b35:	81 fb 40 31 11 80    	cmp    $0x80113140,%ebx
80103b3b:	74 18                	je     80103b55 <sleep+0x70>
    release(&ptable.lock);
80103b3d:	83 ec 0c             	sub    $0xc,%esp
80103b40:	68 40 31 11 80       	push   $0x80113140
80103b45:	e8 40 07 00 00       	call   8010428a <release>
    acquire(lk);
80103b4a:	89 1c 24             	mov    %ebx,(%esp)
80103b4d:	e8 d3 06 00 00       	call   80104225 <acquire>
80103b52:	83 c4 10             	add    $0x10,%esp
}
80103b55:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b58:	5b                   	pop    %ebx
80103b59:	5e                   	pop    %esi
80103b5a:	5d                   	pop    %ebp
80103b5b:	c3                   	ret    
    panic("sleep");
80103b5c:	83 ec 0c             	sub    $0xc,%esp
80103b5f:	68 89 71 10 80       	push   $0x80107189
80103b64:	e8 df c7 ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103b69:	83 ec 0c             	sub    $0xc,%esp
80103b6c:	68 8f 71 10 80       	push   $0x8010718f
80103b71:	e8 d2 c7 ff ff       	call   80100348 <panic>

80103b76 <wait>:
{
80103b76:	55                   	push   %ebp
80103b77:	89 e5                	mov    %esp,%ebp
80103b79:	56                   	push   %esi
80103b7a:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103b7b:	e8 fe f6 ff ff       	call   8010327e <myproc>
80103b80:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103b82:	83 ec 0c             	sub    $0xc,%esp
80103b85:	68 40 31 11 80       	push   $0x80113140
80103b8a:	e8 96 06 00 00       	call   80104225 <acquire>
80103b8f:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103b92:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b97:	bb 74 31 11 80       	mov    $0x80113174,%ebx
80103b9c:	eb 5e                	jmp    80103bfc <wait+0x86>
        pid = p->pid;
80103b9e:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103ba1:	83 ec 0c             	sub    $0xc,%esp
80103ba4:	ff 73 08             	pushl  0x8(%ebx)
80103ba7:	e8 f8 e3 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
80103bac:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103bb3:	83 c4 04             	add    $0x4,%esp
80103bb6:	ff 73 04             	pushl  0x4(%ebx)
80103bb9:	e8 0c 2d 00 00       	call   801068ca <freevm>
        p->pid = 0;
80103bbe:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103bc5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103bcc:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103bd0:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103bd7:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103bde:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103be5:	e8 a0 06 00 00       	call   8010428a <release>
        return pid;
80103bea:	83 c4 10             	add    $0x10,%esp
}
80103bed:	89 f0                	mov    %esi,%eax
80103bef:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bf2:	5b                   	pop    %ebx
80103bf3:	5e                   	pop    %esi
80103bf4:	5d                   	pop    %ebp
80103bf5:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103bf6:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103bfc:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103c02:	73 12                	jae    80103c16 <wait+0xa0>
      if(p->parent != curproc)
80103c04:	39 73 14             	cmp    %esi,0x14(%ebx)
80103c07:	75 ed                	jne    80103bf6 <wait+0x80>
      if(p->state == ZOMBIE){
80103c09:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103c0d:	74 8f                	je     80103b9e <wait+0x28>
      havekids = 1;
80103c0f:	b8 01 00 00 00       	mov    $0x1,%eax
80103c14:	eb e0                	jmp    80103bf6 <wait+0x80>
    if(!havekids || curproc->killed){
80103c16:	85 c0                	test   %eax,%eax
80103c18:	74 06                	je     80103c20 <wait+0xaa>
80103c1a:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103c1e:	74 17                	je     80103c37 <wait+0xc1>
      release(&ptable.lock);
80103c20:	83 ec 0c             	sub    $0xc,%esp
80103c23:	68 40 31 11 80       	push   $0x80113140
80103c28:	e8 5d 06 00 00       	call   8010428a <release>
      return -1;
80103c2d:	83 c4 10             	add    $0x10,%esp
80103c30:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103c35:	eb b6                	jmp    80103bed <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103c37:	83 ec 08             	sub    $0x8,%esp
80103c3a:	68 40 31 11 80       	push   $0x80113140
80103c3f:	56                   	push   %esi
80103c40:	e8 a0 fe ff ff       	call   80103ae5 <sleep>
    havekids = 0;
80103c45:	83 c4 10             	add    $0x10,%esp
80103c48:	e9 45 ff ff ff       	jmp    80103b92 <wait+0x1c>

80103c4d <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103c4d:	55                   	push   %ebp
80103c4e:	89 e5                	mov    %esp,%ebp
80103c50:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103c53:	68 40 31 11 80       	push   $0x80113140
80103c58:	e8 c8 05 00 00       	call   80104225 <acquire>
  wakeup1(chan);
80103c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103c60:	e8 d1 f3 ff ff       	call   80103036 <wakeup1>
  release(&ptable.lock);
80103c65:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103c6c:	e8 19 06 00 00       	call   8010428a <release>
}
80103c71:	83 c4 10             	add    $0x10,%esp
80103c74:	c9                   	leave  
80103c75:	c3                   	ret    

80103c76 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103c76:	55                   	push   %ebp
80103c77:	89 e5                	mov    %esp,%ebp
80103c79:	53                   	push   %ebx
80103c7a:	83 ec 10             	sub    $0x10,%esp
80103c7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103c80:	68 40 31 11 80       	push   $0x80113140
80103c85:	e8 9b 05 00 00       	call   80104225 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c8a:	83 c4 10             	add    $0x10,%esp
80103c8d:	b8 74 31 11 80       	mov    $0x80113174,%eax
80103c92:	3d 74 5d 11 80       	cmp    $0x80115d74,%eax
80103c97:	73 3c                	jae    80103cd5 <kill+0x5f>
    if(p->pid == pid){
80103c99:	39 58 10             	cmp    %ebx,0x10(%eax)
80103c9c:	74 07                	je     80103ca5 <kill+0x2f>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103c9e:	05 b0 00 00 00       	add    $0xb0,%eax
80103ca3:	eb ed                	jmp    80103c92 <kill+0x1c>
      p->killed = 1;
80103ca5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103cac:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103cb0:	74 1a                	je     80103ccc <kill+0x56>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103cb2:	83 ec 0c             	sub    $0xc,%esp
80103cb5:	68 40 31 11 80       	push   $0x80113140
80103cba:	e8 cb 05 00 00       	call   8010428a <release>
      return 0;
80103cbf:	83 c4 10             	add    $0x10,%esp
80103cc2:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103cc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103cca:	c9                   	leave  
80103ccb:	c3                   	ret    
        p->state = RUNNABLE;
80103ccc:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103cd3:	eb dd                	jmp    80103cb2 <kill+0x3c>
  release(&ptable.lock);
80103cd5:	83 ec 0c             	sub    $0xc,%esp
80103cd8:	68 40 31 11 80       	push   $0x80113140
80103cdd:	e8 a8 05 00 00       	call   8010428a <release>
  return -1;
80103ce2:	83 c4 10             	add    $0x10,%esp
80103ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103cea:	eb db                	jmp    80103cc7 <kill+0x51>

80103cec <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103cec:	55                   	push   %ebp
80103ced:	89 e5                	mov    %esp,%ebp
80103cef:	56                   	push   %esi
80103cf0:	53                   	push   %ebx
80103cf1:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103cf4:	bb 74 31 11 80       	mov    $0x80113174,%ebx
80103cf9:	eb 36                	jmp    80103d31 <procdump+0x45>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103cfb:	b8 a0 71 10 80       	mov    $0x801071a0,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103d00:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103d03:	52                   	push   %edx
80103d04:	50                   	push   %eax
80103d05:	ff 73 10             	pushl  0x10(%ebx)
80103d08:	68 a4 71 10 80       	push   $0x801071a4
80103d0d:	e8 f9 c8 ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103d12:	83 c4 10             	add    $0x10,%esp
80103d15:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103d19:	74 3c                	je     80103d57 <procdump+0x6b>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103d1b:	83 ec 0c             	sub    $0xc,%esp
80103d1e:	68 27 75 10 80       	push   $0x80107527
80103d23:	e8 e3 c8 ff ff       	call   8010060b <cprintf>
80103d28:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d2b:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103d31:	81 fb 74 5d 11 80    	cmp    $0x80115d74,%ebx
80103d37:	73 61                	jae    80103d9a <procdump+0xae>
    if(p->state == UNUSED)
80103d39:	8b 43 0c             	mov    0xc(%ebx),%eax
80103d3c:	85 c0                	test   %eax,%eax
80103d3e:	74 eb                	je     80103d2b <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103d40:	83 f8 05             	cmp    $0x5,%eax
80103d43:	77 b6                	ja     80103cfb <procdump+0xf>
80103d45:	8b 04 85 00 72 10 80 	mov    -0x7fef8e00(,%eax,4),%eax
80103d4c:	85 c0                	test   %eax,%eax
80103d4e:	75 b0                	jne    80103d00 <procdump+0x14>
      state = "???";
80103d50:	b8 a0 71 10 80       	mov    $0x801071a0,%eax
80103d55:	eb a9                	jmp    80103d00 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103d57:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103d5a:	8b 40 0c             	mov    0xc(%eax),%eax
80103d5d:	83 c0 08             	add    $0x8,%eax
80103d60:	83 ec 08             	sub    $0x8,%esp
80103d63:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103d66:	52                   	push   %edx
80103d67:	50                   	push   %eax
80103d68:	e8 97 03 00 00       	call   80104104 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103d6d:	83 c4 10             	add    $0x10,%esp
80103d70:	be 00 00 00 00       	mov    $0x0,%esi
80103d75:	eb 14                	jmp    80103d8b <procdump+0x9f>
        cprintf(" %p", pc[i]);
80103d77:	83 ec 08             	sub    $0x8,%esp
80103d7a:	50                   	push   %eax
80103d7b:	68 e1 6b 10 80       	push   $0x80106be1
80103d80:	e8 86 c8 ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103d85:	83 c6 01             	add    $0x1,%esi
80103d88:	83 c4 10             	add    $0x10,%esp
80103d8b:	83 fe 09             	cmp    $0x9,%esi
80103d8e:	7f 8b                	jg     80103d1b <procdump+0x2f>
80103d90:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103d94:	85 c0                	test   %eax,%eax
80103d96:	75 df                	jne    80103d77 <procdump+0x8b>
80103d98:	eb 81                	jmp    80103d1b <procdump+0x2f>
  }
}
80103d9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103d9d:	5b                   	pop    %ebx
80103d9e:	5e                   	pop    %esi
80103d9f:	5d                   	pop    %ebp
80103da0:	c3                   	ret    

80103da1 <setpri>:

int setpri(int PID, int pri){
80103da1:	55                   	push   %ebp
80103da2:	89 e5                	mov    %esp,%ebp
80103da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103daa:	ba 74 31 11 80       	mov    $0x80113174,%edx
80103daf:	eb 06                	jmp    80103db7 <setpri+0x16>
80103db1:	81 c2 b0 00 00 00    	add    $0xb0,%edx
80103db7:	81 fa 74 5d 11 80    	cmp    $0x80115d74,%edx
80103dbd:	73 0d                	jae    80103dcc <setpri+0x2b>
    if(p->pid == PID){
80103dbf:	39 4a 10             	cmp    %ecx,0x10(%edx)
80103dc2:	75 ed                	jne    80103db1 <setpri+0x10>
      p->priority = pri;
80103dc4:	89 82 9c 00 00 00    	mov    %eax,0x9c(%edx)
80103dca:	eb e5                	jmp    80103db1 <setpri+0x10>
    }
  }
  return pri;
}
80103dcc:	5d                   	pop    %ebp
80103dcd:	c3                   	ret    

80103dce <getpri>:

int getpri(int PID){
80103dce:	55                   	push   %ebp
80103dcf:	89 e5                	mov    %esp,%ebp
80103dd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int pri = -1;
  struct proc *p;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103dd4:	ba 74 31 11 80       	mov    $0x80113174,%edx
  int pri = -1;
80103dd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103dde:	eb 06                	jmp    80103de6 <getpri+0x18>
80103de0:	81 c2 b0 00 00 00    	add    $0xb0,%edx
80103de6:	81 fa 74 5d 11 80    	cmp    $0x80115d74,%edx
80103dec:	73 0d                	jae    80103dfb <getpri+0x2d>
    if(p->pid == PID){
80103dee:	39 4a 10             	cmp    %ecx,0x10(%edx)
80103df1:	75 ed                	jne    80103de0 <getpri+0x12>
        pri = p->priority;
80103df3:	8b 82 9c 00 00 00    	mov    0x9c(%edx),%eax
80103df9:	eb e5                	jmp    80103de0 <getpri+0x12>
    }
  }
  return pri;
}
80103dfb:	5d                   	pop    %ebp
80103dfc:	c3                   	ret    

80103dfd <fork2>:

// fork 2 has original fork implementation in addition
// to setting the desired priority of a process
int
fork2(int pri)
{
80103dfd:	55                   	push   %ebp
80103dfe:	89 e5                	mov    %esp,%ebp
80103e00:	57                   	push   %edi
80103e01:	56                   	push   %esi
80103e02:	53                   	push   %ebx
80103e03:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103e06:	e8 73 f4 ff ff       	call   8010327e <myproc>
80103e0b:	89 c3                	mov    %eax,%ebx

  // Allocate process.
  if((np = allocproc()) == 0){
80103e0d:	e8 52 f2 ff ff       	call   80103064 <allocproc>
80103e12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103e15:	85 c0                	test   %eax,%eax
80103e17:	0f 84 e9 00 00 00    	je     80103f06 <fork2+0x109>
80103e1d:	89 c7                	mov    %eax,%edi
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103e1f:	83 ec 08             	sub    $0x8,%esp
80103e22:	ff 33                	pushl  (%ebx)
80103e24:	ff 73 04             	pushl  0x4(%ebx)
80103e27:	e8 bf 2b 00 00       	call   801069eb <copyuvm>
80103e2c:	89 47 04             	mov    %eax,0x4(%edi)
80103e2f:	83 c4 10             	add    $0x10,%esp
80103e32:	85 c0                	test   %eax,%eax
80103e34:	74 33                	je     80103e69 <fork2+0x6c>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
80103e36:	8b 03                	mov    (%ebx),%eax
80103e38:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e3b:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103e3d:	89 59 14             	mov    %ebx,0x14(%ecx)
  np->priority = pri;  // setting desired priority
80103e40:	8b 45 08             	mov    0x8(%ebp),%eax
80103e43:	89 81 9c 00 00 00    	mov    %eax,0x9c(%ecx)
  *np->tf = *curproc->tf;
80103e49:	8b 73 18             	mov    0x18(%ebx),%esi
80103e4c:	89 c8                	mov    %ecx,%eax
80103e4e:	8b 79 18             	mov    0x18(%ecx),%edi
80103e51:	b9 13 00 00 00       	mov    $0x13,%ecx
80103e56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103e58:	8b 40 18             	mov    0x18(%eax),%eax
80103e5b:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103e62:	be 00 00 00 00       	mov    $0x0,%esi
80103e67:	eb 29                	jmp    80103e92 <fork2+0x95>
    kfree(np->kstack);
80103e69:	83 ec 0c             	sub    $0xc,%esp
80103e6c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103e6f:	ff 73 08             	pushl  0x8(%ebx)
80103e72:	e8 2d e1 ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
80103e77:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103e7e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103e85:	83 c4 10             	add    $0x10,%esp
80103e88:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103e8d:	eb 6d                	jmp    80103efc <fork2+0xff>
  for(i = 0; i < NOFILE; i++)
80103e8f:	83 c6 01             	add    $0x1,%esi
80103e92:	83 fe 0f             	cmp    $0xf,%esi
80103e95:	7f 1d                	jg     80103eb4 <fork2+0xb7>
    if(curproc->ofile[i])
80103e97:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103e9b:	85 c0                	test   %eax,%eax
80103e9d:	74 f0                	je     80103e8f <fork2+0x92>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e9f:	83 ec 0c             	sub    $0xc,%esp
80103ea2:	50                   	push   %eax
80103ea3:	e8 e6 cd ff ff       	call   80100c8e <filedup>
80103ea8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103eab:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103eaf:	83 c4 10             	add    $0x10,%esp
80103eb2:	eb db                	jmp    80103e8f <fork2+0x92>
  np->cwd = idup(curproc->cwd);
80103eb4:	83 ec 0c             	sub    $0xc,%esp
80103eb7:	ff 73 68             	pushl  0x68(%ebx)
80103eba:	e8 92 d6 ff ff       	call   80101551 <idup>
80103ebf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103ec2:	89 47 68             	mov    %eax,0x68(%edi)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103ec5:	83 c3 6c             	add    $0x6c,%ebx
80103ec8:	8d 47 6c             	lea    0x6c(%edi),%eax
80103ecb:	83 c4 0c             	add    $0xc,%esp
80103ece:	6a 10                	push   $0x10
80103ed0:	53                   	push   %ebx
80103ed1:	50                   	push   %eax
80103ed2:	e8 61 05 00 00       	call   80104438 <safestrcpy>

  pid = np->pid;
80103ed7:	8b 5f 10             	mov    0x10(%edi),%ebx

  acquire(&ptable.lock);
80103eda:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103ee1:	e8 3f 03 00 00       	call   80104225 <acquire>

  np->state = RUNNABLE;
80103ee6:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)

  release(&ptable.lock);
80103eed:	c7 04 24 40 31 11 80 	movl   $0x80113140,(%esp)
80103ef4:	e8 91 03 00 00       	call   8010428a <release>

  return pid;
80103ef9:	83 c4 10             	add    $0x10,%esp
}
80103efc:	89 d8                	mov    %ebx,%eax
80103efe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103f01:	5b                   	pop    %ebx
80103f02:	5e                   	pop    %esi
80103f03:	5f                   	pop    %edi
80103f04:	5d                   	pop    %ebp
80103f05:	c3                   	ret    
    return -1;
80103f06:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103f0b:	eb ef                	jmp    80103efc <fork2+0xff>

80103f0d <fork>:
{
80103f0d:	55                   	push   %ebp
80103f0e:	89 e5                	mov    %esp,%ebp
80103f10:	83 ec 08             	sub    $0x8,%esp
  struct proc *p = myproc();
80103f13:	e8 66 f3 ff ff       	call   8010327e <myproc>
  return fork2(getpri(p->pid));
80103f18:	83 ec 0c             	sub    $0xc,%esp
80103f1b:	ff 70 10             	pushl  0x10(%eax)
80103f1e:	e8 ab fe ff ff       	call   80103dce <getpri>
80103f23:	89 04 24             	mov    %eax,(%esp)
80103f26:	e8 d2 fe ff ff       	call   80103dfd <fork2>
}
80103f2b:	c9                   	leave  
80103f2c:	c3                   	ret    

80103f2d <getpinfo>:

int getpinfo(struct pstat *mystruct){ // FIXME
80103f2d:	55                   	push   %ebp
80103f2e:	89 e5                	mov    %esp,%ebp
80103f30:	56                   	push   %esi
80103f31:	53                   	push   %ebx
80103f32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
80103f35:	83 ec 0c             	sub    $0xc,%esp
80103f38:	68 40 31 11 80       	push   $0x80113140
80103f3d:	e8 e3 02 00 00       	call   80104225 <acquire>
  struct proc *p = ptable.proc;

    for(int i = 0; i < NPROC; i++){
80103f42:	83 c4 10             	add    $0x10,%esp
80103f45:	ba 00 00 00 00       	mov    $0x0,%edx
80103f4a:	eb 33                	jmp    80103f7f <getpinfo+0x52>
    if (p[i].state == UNUSED){
      mystruct->inuse[i] = 0;
    } else {
      mystruct->inuse[i] = 1;
80103f4c:	c7 04 93 01 00 00 00 	movl   $0x1,(%ebx,%edx,4)
80103f53:	eb 45                	jmp    80103f9a <getpinfo+0x6d>
    }
    mystruct->pid[i] = p->pid;
    mystruct->state[i] = p->state;
    mystruct->priority[i] = p->priority;
    for (int j = 0; j < 4; j++) {
      mystruct->ticks[i][j] = p->ticks[j];
80103f55:	8d 0c 90             	lea    (%eax,%edx,4),%ecx
80103f58:	8b 34 85 00 32 11 80 	mov    -0x7feece00(,%eax,4),%esi
80103f5f:	89 b4 8b 00 04 00 00 	mov    %esi,0x400(%ebx,%ecx,4)
      mystruct->qtail[i][j] = p->qtail[j];
80103f66:	8b 34 85 f0 31 11 80 	mov    -0x7feece10(,%eax,4),%esi
80103f6d:	89 b4 8b 00 08 00 00 	mov    %esi,0x800(%ebx,%ecx,4)
    for (int j = 0; j < 4; j++) {
80103f74:	83 c0 01             	add    $0x1,%eax
80103f77:	83 f8 03             	cmp    $0x3,%eax
80103f7a:	7e d9                	jle    80103f55 <getpinfo+0x28>
    for(int i = 0; i < NPROC; i++){
80103f7c:	83 c2 01             	add    $0x1,%edx
80103f7f:	83 fa 3f             	cmp    $0x3f,%edx
80103f82:	7f 41                	jg     80103fc5 <getpinfo+0x98>
    if (p[i].state == UNUSED){
80103f84:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103f8a:	83 b8 80 31 11 80 00 	cmpl   $0x0,-0x7feece80(%eax)
80103f91:	75 b9                	jne    80103f4c <getpinfo+0x1f>
      mystruct->inuse[i] = 0;
80103f93:	c7 04 93 00 00 00 00 	movl   $0x0,(%ebx,%edx,4)
    mystruct->pid[i] = p->pid;
80103f9a:	a1 84 31 11 80       	mov    0x80113184,%eax
80103f9f:	89 84 93 00 01 00 00 	mov    %eax,0x100(%ebx,%edx,4)
    mystruct->state[i] = p->state;
80103fa6:	a1 80 31 11 80       	mov    0x80113180,%eax
80103fab:	89 84 93 00 03 00 00 	mov    %eax,0x300(%ebx,%edx,4)
    mystruct->priority[i] = p->priority;
80103fb2:	a1 10 32 11 80       	mov    0x80113210,%eax
80103fb7:	89 84 93 00 02 00 00 	mov    %eax,0x200(%ebx,%edx,4)
    for (int j = 0; j < 4; j++) {
80103fbe:	b8 00 00 00 00       	mov    $0x0,%eax
80103fc3:	eb b2                	jmp    80103f77 <getpinfo+0x4a>
    }
  }
  release(&ptable.lock);
80103fc5:	83 ec 0c             	sub    $0xc,%esp
80103fc8:	68 40 31 11 80       	push   $0x80113140
80103fcd:	e8 b8 02 00 00       	call   8010428a <release>
  return -1;
}
80103fd2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103fda:	5b                   	pop    %ebx
80103fdb:	5e                   	pop    %esi
80103fdc:	5d                   	pop    %ebp
80103fdd:	c3                   	ret    

80103fde <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103fde:	55                   	push   %ebp
80103fdf:	89 e5                	mov    %esp,%ebp
80103fe1:	53                   	push   %ebx
80103fe2:	83 ec 0c             	sub    $0xc,%esp
80103fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103fe8:	68 18 72 10 80       	push   $0x80107218
80103fed:	8d 43 04             	lea    0x4(%ebx),%eax
80103ff0:	50                   	push   %eax
80103ff1:	e8 f3 00 00 00       	call   801040e9 <initlock>
  lk->name = name;
80103ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff9:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103ffc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80104002:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80104009:	83 c4 10             	add    $0x10,%esp
8010400c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010400f:	c9                   	leave  
80104010:	c3                   	ret    

80104011 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80104011:	55                   	push   %ebp
80104012:	89 e5                	mov    %esp,%ebp
80104014:	56                   	push   %esi
80104015:	53                   	push   %ebx
80104016:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104019:	8d 73 04             	lea    0x4(%ebx),%esi
8010401c:	83 ec 0c             	sub    $0xc,%esp
8010401f:	56                   	push   %esi
80104020:	e8 00 02 00 00       	call   80104225 <acquire>
  while (lk->locked) {
80104025:	83 c4 10             	add    $0x10,%esp
80104028:	eb 0d                	jmp    80104037 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
8010402a:	83 ec 08             	sub    $0x8,%esp
8010402d:	56                   	push   %esi
8010402e:	53                   	push   %ebx
8010402f:	e8 b1 fa ff ff       	call   80103ae5 <sleep>
80104034:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104037:	83 3b 00             	cmpl   $0x0,(%ebx)
8010403a:	75 ee                	jne    8010402a <acquiresleep+0x19>
  }
  lk->locked = 1;
8010403c:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104042:	e8 37 f2 ff ff       	call   8010327e <myproc>
80104047:	8b 40 10             	mov    0x10(%eax),%eax
8010404a:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
8010404d:	83 ec 0c             	sub    $0xc,%esp
80104050:	56                   	push   %esi
80104051:	e8 34 02 00 00       	call   8010428a <release>
}
80104056:	83 c4 10             	add    $0x10,%esp
80104059:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010405c:	5b                   	pop    %ebx
8010405d:	5e                   	pop    %esi
8010405e:	5d                   	pop    %ebp
8010405f:	c3                   	ret    

80104060 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104060:	55                   	push   %ebp
80104061:	89 e5                	mov    %esp,%ebp
80104063:	56                   	push   %esi
80104064:	53                   	push   %ebx
80104065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104068:	8d 73 04             	lea    0x4(%ebx),%esi
8010406b:	83 ec 0c             	sub    $0xc,%esp
8010406e:	56                   	push   %esi
8010406f:	e8 b1 01 00 00       	call   80104225 <acquire>
  lk->locked = 0;
80104074:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010407a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104081:	89 1c 24             	mov    %ebx,(%esp)
80104084:	e8 c4 fb ff ff       	call   80103c4d <wakeup>
  release(&lk->lk);
80104089:	89 34 24             	mov    %esi,(%esp)
8010408c:	e8 f9 01 00 00       	call   8010428a <release>
}
80104091:	83 c4 10             	add    $0x10,%esp
80104094:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104097:	5b                   	pop    %ebx
80104098:	5e                   	pop    %esi
80104099:	5d                   	pop    %ebp
8010409a:	c3                   	ret    

8010409b <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010409b:	55                   	push   %ebp
8010409c:	89 e5                	mov    %esp,%ebp
8010409e:	56                   	push   %esi
8010409f:	53                   	push   %ebx
801040a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
801040a3:	8d 73 04             	lea    0x4(%ebx),%esi
801040a6:	83 ec 0c             	sub    $0xc,%esp
801040a9:	56                   	push   %esi
801040aa:	e8 76 01 00 00       	call   80104225 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
801040af:	83 c4 10             	add    $0x10,%esp
801040b2:	83 3b 00             	cmpl   $0x0,(%ebx)
801040b5:	75 17                	jne    801040ce <holdingsleep+0x33>
801040b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
801040bc:	83 ec 0c             	sub    $0xc,%esp
801040bf:	56                   	push   %esi
801040c0:	e8 c5 01 00 00       	call   8010428a <release>
  return r;
}
801040c5:	89 d8                	mov    %ebx,%eax
801040c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040ca:	5b                   	pop    %ebx
801040cb:	5e                   	pop    %esi
801040cc:	5d                   	pop    %ebp
801040cd:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
801040ce:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801040d1:	e8 a8 f1 ff ff       	call   8010327e <myproc>
801040d6:	3b 58 10             	cmp    0x10(%eax),%ebx
801040d9:	74 07                	je     801040e2 <holdingsleep+0x47>
801040db:	bb 00 00 00 00       	mov    $0x0,%ebx
801040e0:	eb da                	jmp    801040bc <holdingsleep+0x21>
801040e2:	bb 01 00 00 00       	mov    $0x1,%ebx
801040e7:	eb d3                	jmp    801040bc <holdingsleep+0x21>

801040e9 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801040e9:	55                   	push   %ebp
801040ea:	89 e5                	mov    %esp,%ebp
801040ec:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801040ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801040f2:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801040f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801040fb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104102:	5d                   	pop    %ebp
80104103:	c3                   	ret    

80104104 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104104:	55                   	push   %ebp
80104105:	89 e5                	mov    %esp,%ebp
80104107:	53                   	push   %ebx
80104108:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80104111:	b8 00 00 00 00       	mov    $0x0,%eax
80104116:	83 f8 09             	cmp    $0x9,%eax
80104119:	7f 25                	jg     80104140 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010411b:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104121:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104127:	77 17                	ja     80104140 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104129:	8b 5a 04             	mov    0x4(%edx),%ebx
8010412c:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
8010412f:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80104131:	83 c0 01             	add    $0x1,%eax
80104134:	eb e0                	jmp    80104116 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80104136:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
8010413d:	83 c0 01             	add    $0x1,%eax
80104140:	83 f8 09             	cmp    $0x9,%eax
80104143:	7e f1                	jle    80104136 <getcallerpcs+0x32>
}
80104145:	5b                   	pop    %ebx
80104146:	5d                   	pop    %ebp
80104147:	c3                   	ret    

80104148 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104148:	55                   	push   %ebp
80104149:	89 e5                	mov    %esp,%ebp
8010414b:	53                   	push   %ebx
8010414c:	83 ec 04             	sub    $0x4,%esp
8010414f:	9c                   	pushf  
80104150:	5b                   	pop    %ebx
  asm volatile("cli");
80104151:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80104152:	e8 b0 f0 ff ff       	call   80103207 <mycpu>
80104157:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
8010415e:	74 12                	je     80104172 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104160:	e8 a2 f0 ff ff       	call   80103207 <mycpu>
80104165:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
8010416c:	83 c4 04             	add    $0x4,%esp
8010416f:	5b                   	pop    %ebx
80104170:	5d                   	pop    %ebp
80104171:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80104172:	e8 90 f0 ff ff       	call   80103207 <mycpu>
80104177:	81 e3 00 02 00 00    	and    $0x200,%ebx
8010417d:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104183:	eb db                	jmp    80104160 <pushcli+0x18>

80104185 <popcli>:

void
popcli(void)
{
80104185:	55                   	push   %ebp
80104186:	89 e5                	mov    %esp,%ebp
80104188:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010418b:	9c                   	pushf  
8010418c:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010418d:	f6 c4 02             	test   $0x2,%ah
80104190:	75 28                	jne    801041ba <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80104192:	e8 70 f0 ff ff       	call   80103207 <mycpu>
80104197:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
8010419d:	8d 51 ff             	lea    -0x1(%ecx),%edx
801041a0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
801041a6:	85 d2                	test   %edx,%edx
801041a8:	78 1d                	js     801041c7 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
801041aa:	e8 58 f0 ff ff       	call   80103207 <mycpu>
801041af:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
801041b6:	74 1c                	je     801041d4 <popcli+0x4f>
    sti();
}
801041b8:	c9                   	leave  
801041b9:	c3                   	ret    
    panic("popcli - interruptible");
801041ba:	83 ec 0c             	sub    $0xc,%esp
801041bd:	68 23 72 10 80       	push   $0x80107223
801041c2:	e8 81 c1 ff ff       	call   80100348 <panic>
    panic("popcli");
801041c7:	83 ec 0c             	sub    $0xc,%esp
801041ca:	68 3a 72 10 80       	push   $0x8010723a
801041cf:	e8 74 c1 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
801041d4:	e8 2e f0 ff ff       	call   80103207 <mycpu>
801041d9:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
801041e0:	74 d6                	je     801041b8 <popcli+0x33>
  asm volatile("sti");
801041e2:	fb                   	sti    
}
801041e3:	eb d3                	jmp    801041b8 <popcli+0x33>

801041e5 <holding>:
{
801041e5:	55                   	push   %ebp
801041e6:	89 e5                	mov    %esp,%ebp
801041e8:	53                   	push   %ebx
801041e9:	83 ec 04             	sub    $0x4,%esp
801041ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
801041ef:	e8 54 ff ff ff       	call   80104148 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
801041f4:	83 3b 00             	cmpl   $0x0,(%ebx)
801041f7:	75 12                	jne    8010420b <holding+0x26>
801041f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
801041fe:	e8 82 ff ff ff       	call   80104185 <popcli>
}
80104203:	89 d8                	mov    %ebx,%eax
80104205:	83 c4 04             	add    $0x4,%esp
80104208:	5b                   	pop    %ebx
80104209:	5d                   	pop    %ebp
8010420a:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
8010420b:	8b 5b 08             	mov    0x8(%ebx),%ebx
8010420e:	e8 f4 ef ff ff       	call   80103207 <mycpu>
80104213:	39 c3                	cmp    %eax,%ebx
80104215:	74 07                	je     8010421e <holding+0x39>
80104217:	bb 00 00 00 00       	mov    $0x0,%ebx
8010421c:	eb e0                	jmp    801041fe <holding+0x19>
8010421e:	bb 01 00 00 00       	mov    $0x1,%ebx
80104223:	eb d9                	jmp    801041fe <holding+0x19>

80104225 <acquire>:
{
80104225:	55                   	push   %ebp
80104226:	89 e5                	mov    %esp,%ebp
80104228:	53                   	push   %ebx
80104229:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010422c:	e8 17 ff ff ff       	call   80104148 <pushcli>
  if(holding(lk))
80104231:	83 ec 0c             	sub    $0xc,%esp
80104234:	ff 75 08             	pushl  0x8(%ebp)
80104237:	e8 a9 ff ff ff       	call   801041e5 <holding>
8010423c:	83 c4 10             	add    $0x10,%esp
8010423f:	85 c0                	test   %eax,%eax
80104241:	75 3a                	jne    8010427d <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80104243:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80104246:	b8 01 00 00 00       	mov    $0x1,%eax
8010424b:	f0 87 02             	lock xchg %eax,(%edx)
8010424e:	85 c0                	test   %eax,%eax
80104250:	75 f1                	jne    80104243 <acquire+0x1e>
  __sync_synchronize();
80104252:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104257:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010425a:	e8 a8 ef ff ff       	call   80103207 <mycpu>
8010425f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104262:	8b 45 08             	mov    0x8(%ebp),%eax
80104265:	83 c0 0c             	add    $0xc,%eax
80104268:	83 ec 08             	sub    $0x8,%esp
8010426b:	50                   	push   %eax
8010426c:	8d 45 08             	lea    0x8(%ebp),%eax
8010426f:	50                   	push   %eax
80104270:	e8 8f fe ff ff       	call   80104104 <getcallerpcs>
}
80104275:	83 c4 10             	add    $0x10,%esp
80104278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010427b:	c9                   	leave  
8010427c:	c3                   	ret    
    panic("acquire");
8010427d:	83 ec 0c             	sub    $0xc,%esp
80104280:	68 41 72 10 80       	push   $0x80107241
80104285:	e8 be c0 ff ff       	call   80100348 <panic>

8010428a <release>:
{
8010428a:	55                   	push   %ebp
8010428b:	89 e5                	mov    %esp,%ebp
8010428d:	53                   	push   %ebx
8010428e:	83 ec 10             	sub    $0x10,%esp
80104291:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80104294:	53                   	push   %ebx
80104295:	e8 4b ff ff ff       	call   801041e5 <holding>
8010429a:	83 c4 10             	add    $0x10,%esp
8010429d:	85 c0                	test   %eax,%eax
8010429f:	74 23                	je     801042c4 <release+0x3a>
  lk->pcs[0] = 0;
801042a1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
801042a8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
801042af:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801042b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
801042ba:	e8 c6 fe ff ff       	call   80104185 <popcli>
}
801042bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801042c2:	c9                   	leave  
801042c3:	c3                   	ret    
    panic("release");
801042c4:	83 ec 0c             	sub    $0xc,%esp
801042c7:	68 49 72 10 80       	push   $0x80107249
801042cc:	e8 77 c0 ff ff       	call   80100348 <panic>

801042d1 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801042d1:	55                   	push   %ebp
801042d2:	89 e5                	mov    %esp,%ebp
801042d4:	57                   	push   %edi
801042d5:	53                   	push   %ebx
801042d6:	8b 55 08             	mov    0x8(%ebp),%edx
801042d9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
801042dc:	f6 c2 03             	test   $0x3,%dl
801042df:	75 05                	jne    801042e6 <memset+0x15>
801042e1:	f6 c1 03             	test   $0x3,%cl
801042e4:	74 0e                	je     801042f4 <memset+0x23>
  asm volatile("cld; rep stosb" :
801042e6:	89 d7                	mov    %edx,%edi
801042e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801042eb:	fc                   	cld    
801042ec:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
801042ee:	89 d0                	mov    %edx,%eax
801042f0:	5b                   	pop    %ebx
801042f1:	5f                   	pop    %edi
801042f2:	5d                   	pop    %ebp
801042f3:	c3                   	ret    
    c &= 0xFF;
801042f4:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801042f8:	c1 e9 02             	shr    $0x2,%ecx
801042fb:	89 f8                	mov    %edi,%eax
801042fd:	c1 e0 18             	shl    $0x18,%eax
80104300:	89 fb                	mov    %edi,%ebx
80104302:	c1 e3 10             	shl    $0x10,%ebx
80104305:	09 d8                	or     %ebx,%eax
80104307:	89 fb                	mov    %edi,%ebx
80104309:	c1 e3 08             	shl    $0x8,%ebx
8010430c:	09 d8                	or     %ebx,%eax
8010430e:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104310:	89 d7                	mov    %edx,%edi
80104312:	fc                   	cld    
80104313:	f3 ab                	rep stos %eax,%es:(%edi)
80104315:	eb d7                	jmp    801042ee <memset+0x1d>

80104317 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104317:	55                   	push   %ebp
80104318:	89 e5                	mov    %esp,%ebp
8010431a:	56                   	push   %esi
8010431b:	53                   	push   %ebx
8010431c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010431f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104322:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104325:	8d 70 ff             	lea    -0x1(%eax),%esi
80104328:	85 c0                	test   %eax,%eax
8010432a:	74 1c                	je     80104348 <memcmp+0x31>
    if(*s1 != *s2)
8010432c:	0f b6 01             	movzbl (%ecx),%eax
8010432f:	0f b6 1a             	movzbl (%edx),%ebx
80104332:	38 d8                	cmp    %bl,%al
80104334:	75 0a                	jne    80104340 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80104336:	83 c1 01             	add    $0x1,%ecx
80104339:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
8010433c:	89 f0                	mov    %esi,%eax
8010433e:	eb e5                	jmp    80104325 <memcmp+0xe>
      return *s1 - *s2;
80104340:	0f b6 c0             	movzbl %al,%eax
80104343:	0f b6 db             	movzbl %bl,%ebx
80104346:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104348:	5b                   	pop    %ebx
80104349:	5e                   	pop    %esi
8010434a:	5d                   	pop    %ebp
8010434b:	c3                   	ret    

8010434c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010434c:	55                   	push   %ebp
8010434d:	89 e5                	mov    %esp,%ebp
8010434f:	56                   	push   %esi
80104350:	53                   	push   %ebx
80104351:	8b 45 08             	mov    0x8(%ebp),%eax
80104354:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80104357:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010435a:	39 c1                	cmp    %eax,%ecx
8010435c:	73 3a                	jae    80104398 <memmove+0x4c>
8010435e:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80104361:	39 c3                	cmp    %eax,%ebx
80104363:	76 37                	jbe    8010439c <memmove+0x50>
    s += n;
    d += n;
80104365:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80104368:	eb 0d                	jmp    80104377 <memmove+0x2b>
      *--d = *--s;
8010436a:	83 eb 01             	sub    $0x1,%ebx
8010436d:	83 e9 01             	sub    $0x1,%ecx
80104370:	0f b6 13             	movzbl (%ebx),%edx
80104373:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80104375:	89 f2                	mov    %esi,%edx
80104377:	8d 72 ff             	lea    -0x1(%edx),%esi
8010437a:	85 d2                	test   %edx,%edx
8010437c:	75 ec                	jne    8010436a <memmove+0x1e>
8010437e:	eb 14                	jmp    80104394 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104380:	0f b6 11             	movzbl (%ecx),%edx
80104383:	88 13                	mov    %dl,(%ebx)
80104385:	8d 5b 01             	lea    0x1(%ebx),%ebx
80104388:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
8010438b:	89 f2                	mov    %esi,%edx
8010438d:	8d 72 ff             	lea    -0x1(%edx),%esi
80104390:	85 d2                	test   %edx,%edx
80104392:	75 ec                	jne    80104380 <memmove+0x34>

  return dst;
}
80104394:	5b                   	pop    %ebx
80104395:	5e                   	pop    %esi
80104396:	5d                   	pop    %ebp
80104397:	c3                   	ret    
80104398:	89 c3                	mov    %eax,%ebx
8010439a:	eb f1                	jmp    8010438d <memmove+0x41>
8010439c:	89 c3                	mov    %eax,%ebx
8010439e:	eb ed                	jmp    8010438d <memmove+0x41>

801043a0 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
801043a0:	55                   	push   %ebp
801043a1:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
801043a3:	ff 75 10             	pushl  0x10(%ebp)
801043a6:	ff 75 0c             	pushl  0xc(%ebp)
801043a9:	ff 75 08             	pushl  0x8(%ebp)
801043ac:	e8 9b ff ff ff       	call   8010434c <memmove>
}
801043b1:	c9                   	leave  
801043b2:	c3                   	ret    

801043b3 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
801043b3:	55                   	push   %ebp
801043b4:	89 e5                	mov    %esp,%ebp
801043b6:	53                   	push   %ebx
801043b7:	8b 55 08             	mov    0x8(%ebp),%edx
801043ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801043bd:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
801043c0:	eb 09                	jmp    801043cb <strncmp+0x18>
    n--, p++, q++;
801043c2:	83 e8 01             	sub    $0x1,%eax
801043c5:	83 c2 01             	add    $0x1,%edx
801043c8:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
801043cb:	85 c0                	test   %eax,%eax
801043cd:	74 0b                	je     801043da <strncmp+0x27>
801043cf:	0f b6 1a             	movzbl (%edx),%ebx
801043d2:	84 db                	test   %bl,%bl
801043d4:	74 04                	je     801043da <strncmp+0x27>
801043d6:	3a 19                	cmp    (%ecx),%bl
801043d8:	74 e8                	je     801043c2 <strncmp+0xf>
  if(n == 0)
801043da:	85 c0                	test   %eax,%eax
801043dc:	74 0b                	je     801043e9 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
801043de:	0f b6 02             	movzbl (%edx),%eax
801043e1:	0f b6 11             	movzbl (%ecx),%edx
801043e4:	29 d0                	sub    %edx,%eax
}
801043e6:	5b                   	pop    %ebx
801043e7:	5d                   	pop    %ebp
801043e8:	c3                   	ret    
    return 0;
801043e9:	b8 00 00 00 00       	mov    $0x0,%eax
801043ee:	eb f6                	jmp    801043e6 <strncmp+0x33>

801043f0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801043f0:	55                   	push   %ebp
801043f1:	89 e5                	mov    %esp,%ebp
801043f3:	57                   	push   %edi
801043f4:	56                   	push   %esi
801043f5:	53                   	push   %ebx
801043f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801043f9:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
801043fc:	8b 45 08             	mov    0x8(%ebp),%eax
801043ff:	eb 04                	jmp    80104405 <strncpy+0x15>
80104401:	89 fb                	mov    %edi,%ebx
80104403:	89 f0                	mov    %esi,%eax
80104405:	8d 51 ff             	lea    -0x1(%ecx),%edx
80104408:	85 c9                	test   %ecx,%ecx
8010440a:	7e 1d                	jle    80104429 <strncpy+0x39>
8010440c:	8d 7b 01             	lea    0x1(%ebx),%edi
8010440f:	8d 70 01             	lea    0x1(%eax),%esi
80104412:	0f b6 1b             	movzbl (%ebx),%ebx
80104415:	88 18                	mov    %bl,(%eax)
80104417:	89 d1                	mov    %edx,%ecx
80104419:	84 db                	test   %bl,%bl
8010441b:	75 e4                	jne    80104401 <strncpy+0x11>
8010441d:	89 f0                	mov    %esi,%eax
8010441f:	eb 08                	jmp    80104429 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80104421:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104424:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104426:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80104429:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010442c:	85 d2                	test   %edx,%edx
8010442e:	7f f1                	jg     80104421 <strncpy+0x31>
  return os;
}
80104430:	8b 45 08             	mov    0x8(%ebp),%eax
80104433:	5b                   	pop    %ebx
80104434:	5e                   	pop    %esi
80104435:	5f                   	pop    %edi
80104436:	5d                   	pop    %ebp
80104437:	c3                   	ret    

80104438 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104438:	55                   	push   %ebp
80104439:	89 e5                	mov    %esp,%ebp
8010443b:	57                   	push   %edi
8010443c:	56                   	push   %esi
8010443d:	53                   	push   %ebx
8010443e:	8b 45 08             	mov    0x8(%ebp),%eax
80104441:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104444:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104447:	85 d2                	test   %edx,%edx
80104449:	7e 23                	jle    8010446e <safestrcpy+0x36>
8010444b:	89 c1                	mov    %eax,%ecx
8010444d:	eb 04                	jmp    80104453 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
8010444f:	89 fb                	mov    %edi,%ebx
80104451:	89 f1                	mov    %esi,%ecx
80104453:	83 ea 01             	sub    $0x1,%edx
80104456:	85 d2                	test   %edx,%edx
80104458:	7e 11                	jle    8010446b <safestrcpy+0x33>
8010445a:	8d 7b 01             	lea    0x1(%ebx),%edi
8010445d:	8d 71 01             	lea    0x1(%ecx),%esi
80104460:	0f b6 1b             	movzbl (%ebx),%ebx
80104463:	88 19                	mov    %bl,(%ecx)
80104465:	84 db                	test   %bl,%bl
80104467:	75 e6                	jne    8010444f <safestrcpy+0x17>
80104469:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
8010446b:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
8010446e:	5b                   	pop    %ebx
8010446f:	5e                   	pop    %esi
80104470:	5f                   	pop    %edi
80104471:	5d                   	pop    %ebp
80104472:	c3                   	ret    

80104473 <strlen>:

int
strlen(const char *s)
{
80104473:	55                   	push   %ebp
80104474:	89 e5                	mov    %esp,%ebp
80104476:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80104479:	b8 00 00 00 00       	mov    $0x0,%eax
8010447e:	eb 03                	jmp    80104483 <strlen+0x10>
80104480:	83 c0 01             	add    $0x1,%eax
80104483:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104487:	75 f7                	jne    80104480 <strlen+0xd>
    ;
  return n;
}
80104489:	5d                   	pop    %ebp
8010448a:	c3                   	ret    

8010448b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010448b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010448f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104493:	55                   	push   %ebp
  pushl %ebx
80104494:	53                   	push   %ebx
  pushl %esi
80104495:	56                   	push   %esi
  pushl %edi
80104496:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104497:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104499:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010449b:	5f                   	pop    %edi
  popl %esi
8010449c:	5e                   	pop    %esi
  popl %ebx
8010449d:	5b                   	pop    %ebx
  popl %ebp
8010449e:	5d                   	pop    %ebp
  ret
8010449f:	c3                   	ret    

801044a0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
801044a0:	55                   	push   %ebp
801044a1:	89 e5                	mov    %esp,%ebp
801044a3:	53                   	push   %ebx
801044a4:	83 ec 04             	sub    $0x4,%esp
801044a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
801044aa:	e8 cf ed ff ff       	call   8010327e <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801044af:	8b 00                	mov    (%eax),%eax
801044b1:	39 d8                	cmp    %ebx,%eax
801044b3:	76 19                	jbe    801044ce <fetchint+0x2e>
801044b5:	8d 53 04             	lea    0x4(%ebx),%edx
801044b8:	39 d0                	cmp    %edx,%eax
801044ba:	72 19                	jb     801044d5 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
801044bc:	8b 13                	mov    (%ebx),%edx
801044be:	8b 45 0c             	mov    0xc(%ebp),%eax
801044c1:	89 10                	mov    %edx,(%eax)
  return 0;
801044c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044c8:	83 c4 04             	add    $0x4,%esp
801044cb:	5b                   	pop    %ebx
801044cc:	5d                   	pop    %ebp
801044cd:	c3                   	ret    
    return -1;
801044ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d3:	eb f3                	jmp    801044c8 <fetchint+0x28>
801044d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044da:	eb ec                	jmp    801044c8 <fetchint+0x28>

801044dc <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801044dc:	55                   	push   %ebp
801044dd:	89 e5                	mov    %esp,%ebp
801044df:	53                   	push   %ebx
801044e0:	83 ec 04             	sub    $0x4,%esp
801044e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801044e6:	e8 93 ed ff ff       	call   8010327e <myproc>

  if(addr >= curproc->sz)
801044eb:	39 18                	cmp    %ebx,(%eax)
801044ed:	76 26                	jbe    80104515 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
801044ef:	8b 55 0c             	mov    0xc(%ebp),%edx
801044f2:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801044f4:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
801044f6:	89 d8                	mov    %ebx,%eax
801044f8:	39 d0                	cmp    %edx,%eax
801044fa:	73 0e                	jae    8010450a <fetchstr+0x2e>
    if(*s == 0)
801044fc:	80 38 00             	cmpb   $0x0,(%eax)
801044ff:	74 05                	je     80104506 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80104501:	83 c0 01             	add    $0x1,%eax
80104504:	eb f2                	jmp    801044f8 <fetchstr+0x1c>
      return s - *pp;
80104506:	29 d8                	sub    %ebx,%eax
80104508:	eb 05                	jmp    8010450f <fetchstr+0x33>
  }
  return -1;
8010450a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010450f:	83 c4 04             	add    $0x4,%esp
80104512:	5b                   	pop    %ebx
80104513:	5d                   	pop    %ebp
80104514:	c3                   	ret    
    return -1;
80104515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010451a:	eb f3                	jmp    8010450f <fetchstr+0x33>

8010451c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010451c:	55                   	push   %ebp
8010451d:	89 e5                	mov    %esp,%ebp
8010451f:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104522:	e8 57 ed ff ff       	call   8010327e <myproc>
80104527:	8b 50 18             	mov    0x18(%eax),%edx
8010452a:	8b 45 08             	mov    0x8(%ebp),%eax
8010452d:	c1 e0 02             	shl    $0x2,%eax
80104530:	03 42 44             	add    0x44(%edx),%eax
80104533:	83 ec 08             	sub    $0x8,%esp
80104536:	ff 75 0c             	pushl  0xc(%ebp)
80104539:	83 c0 04             	add    $0x4,%eax
8010453c:	50                   	push   %eax
8010453d:	e8 5e ff ff ff       	call   801044a0 <fetchint>
}
80104542:	c9                   	leave  
80104543:	c3                   	ret    

80104544 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104544:	55                   	push   %ebp
80104545:	89 e5                	mov    %esp,%ebp
80104547:	56                   	push   %esi
80104548:	53                   	push   %ebx
80104549:	83 ec 10             	sub    $0x10,%esp
8010454c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010454f:	e8 2a ed ff ff       	call   8010327e <myproc>
80104554:	89 c6                	mov    %eax,%esi

  if(argint(n, &i) < 0)
80104556:	83 ec 08             	sub    $0x8,%esp
80104559:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010455c:	50                   	push   %eax
8010455d:	ff 75 08             	pushl  0x8(%ebp)
80104560:	e8 b7 ff ff ff       	call   8010451c <argint>
80104565:	83 c4 10             	add    $0x10,%esp
80104568:	85 c0                	test   %eax,%eax
8010456a:	78 24                	js     80104590 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010456c:	85 db                	test   %ebx,%ebx
8010456e:	78 27                	js     80104597 <argptr+0x53>
80104570:	8b 16                	mov    (%esi),%edx
80104572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104575:	39 c2                	cmp    %eax,%edx
80104577:	76 25                	jbe    8010459e <argptr+0x5a>
80104579:	01 c3                	add    %eax,%ebx
8010457b:	39 da                	cmp    %ebx,%edx
8010457d:	72 26                	jb     801045a5 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010457f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104582:	89 02                	mov    %eax,(%edx)
  return 0;
80104584:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104589:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010458c:	5b                   	pop    %ebx
8010458d:	5e                   	pop    %esi
8010458e:	5d                   	pop    %ebp
8010458f:	c3                   	ret    
    return -1;
80104590:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104595:	eb f2                	jmp    80104589 <argptr+0x45>
    return -1;
80104597:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010459c:	eb eb                	jmp    80104589 <argptr+0x45>
8010459e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045a3:	eb e4                	jmp    80104589 <argptr+0x45>
801045a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045aa:	eb dd                	jmp    80104589 <argptr+0x45>

801045ac <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801045ac:	55                   	push   %ebp
801045ad:	89 e5                	mov    %esp,%ebp
801045af:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801045b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801045b5:	50                   	push   %eax
801045b6:	ff 75 08             	pushl  0x8(%ebp)
801045b9:	e8 5e ff ff ff       	call   8010451c <argint>
801045be:	83 c4 10             	add    $0x10,%esp
801045c1:	85 c0                	test   %eax,%eax
801045c3:	78 13                	js     801045d8 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801045c5:	83 ec 08             	sub    $0x8,%esp
801045c8:	ff 75 0c             	pushl  0xc(%ebp)
801045cb:	ff 75 f4             	pushl  -0xc(%ebp)
801045ce:	e8 09 ff ff ff       	call   801044dc <fetchstr>
801045d3:	83 c4 10             	add    $0x10,%esp
}
801045d6:	c9                   	leave  
801045d7:	c3                   	ret    
    return -1;
801045d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045dd:	eb f7                	jmp    801045d6 <argstr+0x2a>

801045df <syscall>:
[SYS_getpinfo]  sys_getpinfo,
};

void
syscall(void)
{
801045df:	55                   	push   %ebp
801045e0:	89 e5                	mov    %esp,%ebp
801045e2:	53                   	push   %ebx
801045e3:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801045e6:	e8 93 ec ff ff       	call   8010327e <myproc>
801045eb:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801045ed:	8b 40 18             	mov    0x18(%eax),%eax
801045f0:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801045f3:	8d 50 ff             	lea    -0x1(%eax),%edx
801045f6:	83 fa 18             	cmp    $0x18,%edx
801045f9:	77 18                	ja     80104613 <syscall+0x34>
801045fb:	8b 14 85 80 72 10 80 	mov    -0x7fef8d80(,%eax,4),%edx
80104602:	85 d2                	test   %edx,%edx
80104604:	74 0d                	je     80104613 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104606:	ff d2                	call   *%edx
80104608:	8b 53 18             	mov    0x18(%ebx),%edx
8010460b:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010460e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104611:	c9                   	leave  
80104612:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104613:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104616:	50                   	push   %eax
80104617:	52                   	push   %edx
80104618:	ff 73 10             	pushl  0x10(%ebx)
8010461b:	68 51 72 10 80       	push   $0x80107251
80104620:	e8 e6 bf ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104625:	8b 43 18             	mov    0x18(%ebx),%eax
80104628:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010462f:	83 c4 10             	add    $0x10,%esp
}
80104632:	eb da                	jmp    8010460e <syscall+0x2f>

80104634 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104634:	55                   	push   %ebp
80104635:	89 e5                	mov    %esp,%ebp
80104637:	56                   	push   %esi
80104638:	53                   	push   %ebx
80104639:	83 ec 18             	sub    $0x18,%esp
8010463c:	89 d6                	mov    %edx,%esi
8010463e:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104640:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104643:	52                   	push   %edx
80104644:	50                   	push   %eax
80104645:	e8 d2 fe ff ff       	call   8010451c <argint>
8010464a:	83 c4 10             	add    $0x10,%esp
8010464d:	85 c0                	test   %eax,%eax
8010464f:	78 2e                	js     8010467f <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104651:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104655:	77 2f                	ja     80104686 <argfd+0x52>
80104657:	e8 22 ec ff ff       	call   8010327e <myproc>
8010465c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010465f:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104663:	85 c0                	test   %eax,%eax
80104665:	74 26                	je     8010468d <argfd+0x59>
    return -1;
  if(pfd)
80104667:	85 f6                	test   %esi,%esi
80104669:	74 02                	je     8010466d <argfd+0x39>
    *pfd = fd;
8010466b:	89 16                	mov    %edx,(%esi)
  if(pf)
8010466d:	85 db                	test   %ebx,%ebx
8010466f:	74 23                	je     80104694 <argfd+0x60>
    *pf = f;
80104671:	89 03                	mov    %eax,(%ebx)
  return 0;
80104673:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104678:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010467b:	5b                   	pop    %ebx
8010467c:	5e                   	pop    %esi
8010467d:	5d                   	pop    %ebp
8010467e:	c3                   	ret    
    return -1;
8010467f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104684:	eb f2                	jmp    80104678 <argfd+0x44>
    return -1;
80104686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010468b:	eb eb                	jmp    80104678 <argfd+0x44>
8010468d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104692:	eb e4                	jmp    80104678 <argfd+0x44>
  return 0;
80104694:	b8 00 00 00 00       	mov    $0x0,%eax
80104699:	eb dd                	jmp    80104678 <argfd+0x44>

8010469b <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010469b:	55                   	push   %ebp
8010469c:	89 e5                	mov    %esp,%ebp
8010469e:	53                   	push   %ebx
8010469f:	83 ec 04             	sub    $0x4,%esp
801046a2:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801046a4:	e8 d5 eb ff ff       	call   8010327e <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801046a9:	ba 00 00 00 00       	mov    $0x0,%edx
801046ae:	83 fa 0f             	cmp    $0xf,%edx
801046b1:	7f 18                	jg     801046cb <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801046b3:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801046b8:	74 05                	je     801046bf <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801046ba:	83 c2 01             	add    $0x1,%edx
801046bd:	eb ef                	jmp    801046ae <fdalloc+0x13>
      curproc->ofile[fd] = f;
801046bf:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801046c3:	89 d0                	mov    %edx,%eax
801046c5:	83 c4 04             	add    $0x4,%esp
801046c8:	5b                   	pop    %ebx
801046c9:	5d                   	pop    %ebp
801046ca:	c3                   	ret    
  return -1;
801046cb:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801046d0:	eb f1                	jmp    801046c3 <fdalloc+0x28>

801046d2 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801046d2:	55                   	push   %ebp
801046d3:	89 e5                	mov    %esp,%ebp
801046d5:	56                   	push   %esi
801046d6:	53                   	push   %ebx
801046d7:	83 ec 10             	sub    $0x10,%esp
801046da:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801046dc:	b8 20 00 00 00       	mov    $0x20,%eax
801046e1:	89 c6                	mov    %eax,%esi
801046e3:	39 43 58             	cmp    %eax,0x58(%ebx)
801046e6:	76 2e                	jbe    80104716 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046e8:	6a 10                	push   $0x10
801046ea:	50                   	push   %eax
801046eb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801046ee:	50                   	push   %eax
801046ef:	53                   	push   %ebx
801046f0:	e8 7e d0 ff ff       	call   80101773 <readi>
801046f5:	83 c4 10             	add    $0x10,%esp
801046f8:	83 f8 10             	cmp    $0x10,%eax
801046fb:	75 0c                	jne    80104709 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801046fd:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
80104702:	75 1e                	jne    80104722 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104704:	8d 46 10             	lea    0x10(%esi),%eax
80104707:	eb d8                	jmp    801046e1 <isdirempty+0xf>
      panic("isdirempty: readi");
80104709:	83 ec 0c             	sub    $0xc,%esp
8010470c:	68 e8 72 10 80       	push   $0x801072e8
80104711:	e8 32 bc ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104716:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010471b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010471e:	5b                   	pop    %ebx
8010471f:	5e                   	pop    %esi
80104720:	5d                   	pop    %ebp
80104721:	c3                   	ret    
      return 0;
80104722:	b8 00 00 00 00       	mov    $0x0,%eax
80104727:	eb f2                	jmp    8010471b <isdirempty+0x49>

80104729 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104729:	55                   	push   %ebp
8010472a:	89 e5                	mov    %esp,%ebp
8010472c:	57                   	push   %edi
8010472d:	56                   	push   %esi
8010472e:	53                   	push   %ebx
8010472f:	83 ec 44             	sub    $0x44,%esp
80104732:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104735:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104738:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010473b:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010473e:	52                   	push   %edx
8010473f:	50                   	push   %eax
80104740:	e8 b4 d4 ff ff       	call   80101bf9 <nameiparent>
80104745:	89 c6                	mov    %eax,%esi
80104747:	83 c4 10             	add    $0x10,%esp
8010474a:	85 c0                	test   %eax,%eax
8010474c:	0f 84 3a 01 00 00    	je     8010488c <create+0x163>
    return 0;
  ilock(dp);
80104752:	83 ec 0c             	sub    $0xc,%esp
80104755:	50                   	push   %eax
80104756:	e8 26 ce ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010475b:	83 c4 0c             	add    $0xc,%esp
8010475e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104761:	50                   	push   %eax
80104762:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104765:	50                   	push   %eax
80104766:	56                   	push   %esi
80104767:	e8 44 d2 ff ff       	call   801019b0 <dirlookup>
8010476c:	89 c3                	mov    %eax,%ebx
8010476e:	83 c4 10             	add    $0x10,%esp
80104771:	85 c0                	test   %eax,%eax
80104773:	74 3f                	je     801047b4 <create+0x8b>
    iunlockput(dp);
80104775:	83 ec 0c             	sub    $0xc,%esp
80104778:	56                   	push   %esi
80104779:	e8 aa cf ff ff       	call   80101728 <iunlockput>
    ilock(ip);
8010477e:	89 1c 24             	mov    %ebx,(%esp)
80104781:	e8 fb cd ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104786:	83 c4 10             	add    $0x10,%esp
80104789:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
8010478e:	75 11                	jne    801047a1 <create+0x78>
80104790:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104795:	75 0a                	jne    801047a1 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104797:	89 d8                	mov    %ebx,%eax
80104799:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010479c:	5b                   	pop    %ebx
8010479d:	5e                   	pop    %esi
8010479e:	5f                   	pop    %edi
8010479f:	5d                   	pop    %ebp
801047a0:	c3                   	ret    
    iunlockput(ip);
801047a1:	83 ec 0c             	sub    $0xc,%esp
801047a4:	53                   	push   %ebx
801047a5:	e8 7e cf ff ff       	call   80101728 <iunlockput>
    return 0;
801047aa:	83 c4 10             	add    $0x10,%esp
801047ad:	bb 00 00 00 00       	mov    $0x0,%ebx
801047b2:	eb e3                	jmp    80104797 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801047b4:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801047b8:	83 ec 08             	sub    $0x8,%esp
801047bb:	50                   	push   %eax
801047bc:	ff 36                	pushl  (%esi)
801047be:	e8 bb cb ff ff       	call   8010137e <ialloc>
801047c3:	89 c3                	mov    %eax,%ebx
801047c5:	83 c4 10             	add    $0x10,%esp
801047c8:	85 c0                	test   %eax,%eax
801047ca:	74 55                	je     80104821 <create+0xf8>
  ilock(ip);
801047cc:	83 ec 0c             	sub    $0xc,%esp
801047cf:	50                   	push   %eax
801047d0:	e8 ac cd ff ff       	call   80101581 <ilock>
  ip->major = major;
801047d5:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801047d9:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801047dd:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801047e1:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801047e7:	89 1c 24             	mov    %ebx,(%esp)
801047ea:	e8 31 cc ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801047ef:	83 c4 10             	add    $0x10,%esp
801047f2:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
801047f7:	74 35                	je     8010482e <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
801047f9:	83 ec 04             	sub    $0x4,%esp
801047fc:	ff 73 04             	pushl  0x4(%ebx)
801047ff:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104802:	50                   	push   %eax
80104803:	56                   	push   %esi
80104804:	e8 27 d3 ff ff       	call   80101b30 <dirlink>
80104809:	83 c4 10             	add    $0x10,%esp
8010480c:	85 c0                	test   %eax,%eax
8010480e:	78 6f                	js     8010487f <create+0x156>
  iunlockput(dp);
80104810:	83 ec 0c             	sub    $0xc,%esp
80104813:	56                   	push   %esi
80104814:	e8 0f cf ff ff       	call   80101728 <iunlockput>
  return ip;
80104819:	83 c4 10             	add    $0x10,%esp
8010481c:	e9 76 ff ff ff       	jmp    80104797 <create+0x6e>
    panic("create: ialloc");
80104821:	83 ec 0c             	sub    $0xc,%esp
80104824:	68 fa 72 10 80       	push   $0x801072fa
80104829:	e8 1a bb ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010482e:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104832:	83 c0 01             	add    $0x1,%eax
80104835:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104839:	83 ec 0c             	sub    $0xc,%esp
8010483c:	56                   	push   %esi
8010483d:	e8 de cb ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104842:	83 c4 0c             	add    $0xc,%esp
80104845:	ff 73 04             	pushl  0x4(%ebx)
80104848:	68 0a 73 10 80       	push   $0x8010730a
8010484d:	53                   	push   %ebx
8010484e:	e8 dd d2 ff ff       	call   80101b30 <dirlink>
80104853:	83 c4 10             	add    $0x10,%esp
80104856:	85 c0                	test   %eax,%eax
80104858:	78 18                	js     80104872 <create+0x149>
8010485a:	83 ec 04             	sub    $0x4,%esp
8010485d:	ff 76 04             	pushl  0x4(%esi)
80104860:	68 09 73 10 80       	push   $0x80107309
80104865:	53                   	push   %ebx
80104866:	e8 c5 d2 ff ff       	call   80101b30 <dirlink>
8010486b:	83 c4 10             	add    $0x10,%esp
8010486e:	85 c0                	test   %eax,%eax
80104870:	79 87                	jns    801047f9 <create+0xd0>
      panic("create dots");
80104872:	83 ec 0c             	sub    $0xc,%esp
80104875:	68 0c 73 10 80       	push   $0x8010730c
8010487a:	e8 c9 ba ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010487f:	83 ec 0c             	sub    $0xc,%esp
80104882:	68 18 73 10 80       	push   $0x80107318
80104887:	e8 bc ba ff ff       	call   80100348 <panic>
    return 0;
8010488c:	89 c3                	mov    %eax,%ebx
8010488e:	e9 04 ff ff ff       	jmp    80104797 <create+0x6e>

80104893 <sys_dup>:
{
80104893:	55                   	push   %ebp
80104894:	89 e5                	mov    %esp,%ebp
80104896:	53                   	push   %ebx
80104897:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010489a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010489d:	ba 00 00 00 00       	mov    $0x0,%edx
801048a2:	b8 00 00 00 00       	mov    $0x0,%eax
801048a7:	e8 88 fd ff ff       	call   80104634 <argfd>
801048ac:	85 c0                	test   %eax,%eax
801048ae:	78 23                	js     801048d3 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801048b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b3:	e8 e3 fd ff ff       	call   8010469b <fdalloc>
801048b8:	89 c3                	mov    %eax,%ebx
801048ba:	85 c0                	test   %eax,%eax
801048bc:	78 1c                	js     801048da <sys_dup+0x47>
  filedup(f);
801048be:	83 ec 0c             	sub    $0xc,%esp
801048c1:	ff 75 f4             	pushl  -0xc(%ebp)
801048c4:	e8 c5 c3 ff ff       	call   80100c8e <filedup>
  return fd;
801048c9:	83 c4 10             	add    $0x10,%esp
}
801048cc:	89 d8                	mov    %ebx,%eax
801048ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048d1:	c9                   	leave  
801048d2:	c3                   	ret    
    return -1;
801048d3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801048d8:	eb f2                	jmp    801048cc <sys_dup+0x39>
    return -1;
801048da:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801048df:	eb eb                	jmp    801048cc <sys_dup+0x39>

801048e1 <sys_read>:
{
801048e1:	55                   	push   %ebp
801048e2:	89 e5                	mov    %esp,%ebp
801048e4:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801048e7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801048ea:	ba 00 00 00 00       	mov    $0x0,%edx
801048ef:	b8 00 00 00 00       	mov    $0x0,%eax
801048f4:	e8 3b fd ff ff       	call   80104634 <argfd>
801048f9:	85 c0                	test   %eax,%eax
801048fb:	78 43                	js     80104940 <sys_read+0x5f>
801048fd:	83 ec 08             	sub    $0x8,%esp
80104900:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104903:	50                   	push   %eax
80104904:	6a 02                	push   $0x2
80104906:	e8 11 fc ff ff       	call   8010451c <argint>
8010490b:	83 c4 10             	add    $0x10,%esp
8010490e:	85 c0                	test   %eax,%eax
80104910:	78 35                	js     80104947 <sys_read+0x66>
80104912:	83 ec 04             	sub    $0x4,%esp
80104915:	ff 75 f0             	pushl  -0x10(%ebp)
80104918:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010491b:	50                   	push   %eax
8010491c:	6a 01                	push   $0x1
8010491e:	e8 21 fc ff ff       	call   80104544 <argptr>
80104923:	83 c4 10             	add    $0x10,%esp
80104926:	85 c0                	test   %eax,%eax
80104928:	78 24                	js     8010494e <sys_read+0x6d>
  return fileread(f, p, n);
8010492a:	83 ec 04             	sub    $0x4,%esp
8010492d:	ff 75 f0             	pushl  -0x10(%ebp)
80104930:	ff 75 ec             	pushl  -0x14(%ebp)
80104933:	ff 75 f4             	pushl  -0xc(%ebp)
80104936:	e8 9c c4 ff ff       	call   80100dd7 <fileread>
8010493b:	83 c4 10             	add    $0x10,%esp
}
8010493e:	c9                   	leave  
8010493f:	c3                   	ret    
    return -1;
80104940:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104945:	eb f7                	jmp    8010493e <sys_read+0x5d>
80104947:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010494c:	eb f0                	jmp    8010493e <sys_read+0x5d>
8010494e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104953:	eb e9                	jmp    8010493e <sys_read+0x5d>

80104955 <sys_write>:
{
80104955:	55                   	push   %ebp
80104956:	89 e5                	mov    %esp,%ebp
80104958:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010495b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010495e:	ba 00 00 00 00       	mov    $0x0,%edx
80104963:	b8 00 00 00 00       	mov    $0x0,%eax
80104968:	e8 c7 fc ff ff       	call   80104634 <argfd>
8010496d:	85 c0                	test   %eax,%eax
8010496f:	78 43                	js     801049b4 <sys_write+0x5f>
80104971:	83 ec 08             	sub    $0x8,%esp
80104974:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104977:	50                   	push   %eax
80104978:	6a 02                	push   $0x2
8010497a:	e8 9d fb ff ff       	call   8010451c <argint>
8010497f:	83 c4 10             	add    $0x10,%esp
80104982:	85 c0                	test   %eax,%eax
80104984:	78 35                	js     801049bb <sys_write+0x66>
80104986:	83 ec 04             	sub    $0x4,%esp
80104989:	ff 75 f0             	pushl  -0x10(%ebp)
8010498c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010498f:	50                   	push   %eax
80104990:	6a 01                	push   $0x1
80104992:	e8 ad fb ff ff       	call   80104544 <argptr>
80104997:	83 c4 10             	add    $0x10,%esp
8010499a:	85 c0                	test   %eax,%eax
8010499c:	78 24                	js     801049c2 <sys_write+0x6d>
  return filewrite(f, p, n);
8010499e:	83 ec 04             	sub    $0x4,%esp
801049a1:	ff 75 f0             	pushl  -0x10(%ebp)
801049a4:	ff 75 ec             	pushl  -0x14(%ebp)
801049a7:	ff 75 f4             	pushl  -0xc(%ebp)
801049aa:	e8 ad c4 ff ff       	call   80100e5c <filewrite>
801049af:	83 c4 10             	add    $0x10,%esp
}
801049b2:	c9                   	leave  
801049b3:	c3                   	ret    
    return -1;
801049b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049b9:	eb f7                	jmp    801049b2 <sys_write+0x5d>
801049bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c0:	eb f0                	jmp    801049b2 <sys_write+0x5d>
801049c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049c7:	eb e9                	jmp    801049b2 <sys_write+0x5d>

801049c9 <sys_close>:
{
801049c9:	55                   	push   %ebp
801049ca:	89 e5                	mov    %esp,%ebp
801049cc:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801049cf:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801049d2:	8d 55 f4             	lea    -0xc(%ebp),%edx
801049d5:	b8 00 00 00 00       	mov    $0x0,%eax
801049da:	e8 55 fc ff ff       	call   80104634 <argfd>
801049df:	85 c0                	test   %eax,%eax
801049e1:	78 25                	js     80104a08 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801049e3:	e8 96 e8 ff ff       	call   8010327e <myproc>
801049e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801049eb:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801049f2:	00 
  fileclose(f);
801049f3:	83 ec 0c             	sub    $0xc,%esp
801049f6:	ff 75 f0             	pushl  -0x10(%ebp)
801049f9:	e8 d5 c2 ff ff       	call   80100cd3 <fileclose>
  return 0;
801049fe:	83 c4 10             	add    $0x10,%esp
80104a01:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a06:	c9                   	leave  
80104a07:	c3                   	ret    
    return -1;
80104a08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a0d:	eb f7                	jmp    80104a06 <sys_close+0x3d>

80104a0f <sys_fstat>:
{
80104a0f:	55                   	push   %ebp
80104a10:	89 e5                	mov    %esp,%ebp
80104a12:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104a15:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104a18:	ba 00 00 00 00       	mov    $0x0,%edx
80104a1d:	b8 00 00 00 00       	mov    $0x0,%eax
80104a22:	e8 0d fc ff ff       	call   80104634 <argfd>
80104a27:	85 c0                	test   %eax,%eax
80104a29:	78 2a                	js     80104a55 <sys_fstat+0x46>
80104a2b:	83 ec 04             	sub    $0x4,%esp
80104a2e:	6a 14                	push   $0x14
80104a30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a33:	50                   	push   %eax
80104a34:	6a 01                	push   $0x1
80104a36:	e8 09 fb ff ff       	call   80104544 <argptr>
80104a3b:	83 c4 10             	add    $0x10,%esp
80104a3e:	85 c0                	test   %eax,%eax
80104a40:	78 1a                	js     80104a5c <sys_fstat+0x4d>
  return filestat(f, st);
80104a42:	83 ec 08             	sub    $0x8,%esp
80104a45:	ff 75 f0             	pushl  -0x10(%ebp)
80104a48:	ff 75 f4             	pushl  -0xc(%ebp)
80104a4b:	e8 40 c3 ff ff       	call   80100d90 <filestat>
80104a50:	83 c4 10             	add    $0x10,%esp
}
80104a53:	c9                   	leave  
80104a54:	c3                   	ret    
    return -1;
80104a55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a5a:	eb f7                	jmp    80104a53 <sys_fstat+0x44>
80104a5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a61:	eb f0                	jmp    80104a53 <sys_fstat+0x44>

80104a63 <sys_link>:
{
80104a63:	55                   	push   %ebp
80104a64:	89 e5                	mov    %esp,%ebp
80104a66:	56                   	push   %esi
80104a67:	53                   	push   %ebx
80104a68:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104a6b:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104a6e:	50                   	push   %eax
80104a6f:	6a 00                	push   $0x0
80104a71:	e8 36 fb ff ff       	call   801045ac <argstr>
80104a76:	83 c4 10             	add    $0x10,%esp
80104a79:	85 c0                	test   %eax,%eax
80104a7b:	0f 88 32 01 00 00    	js     80104bb3 <sys_link+0x150>
80104a81:	83 ec 08             	sub    $0x8,%esp
80104a84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104a87:	50                   	push   %eax
80104a88:	6a 01                	push   $0x1
80104a8a:	e8 1d fb ff ff       	call   801045ac <argstr>
80104a8f:	83 c4 10             	add    $0x10,%esp
80104a92:	85 c0                	test   %eax,%eax
80104a94:	0f 88 20 01 00 00    	js     80104bba <sys_link+0x157>
  begin_op();
80104a9a:	e8 0f dd ff ff       	call   801027ae <begin_op>
  if((ip = namei(old)) == 0){
80104a9f:	83 ec 0c             	sub    $0xc,%esp
80104aa2:	ff 75 e0             	pushl  -0x20(%ebp)
80104aa5:	e8 37 d1 ff ff       	call   80101be1 <namei>
80104aaa:	89 c3                	mov    %eax,%ebx
80104aac:	83 c4 10             	add    $0x10,%esp
80104aaf:	85 c0                	test   %eax,%eax
80104ab1:	0f 84 99 00 00 00    	je     80104b50 <sys_link+0xed>
  ilock(ip);
80104ab7:	83 ec 0c             	sub    $0xc,%esp
80104aba:	50                   	push   %eax
80104abb:	e8 c1 ca ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
80104ac0:	83 c4 10             	add    $0x10,%esp
80104ac3:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104ac8:	0f 84 8e 00 00 00    	je     80104b5c <sys_link+0xf9>
  ip->nlink++;
80104ace:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104ad2:	83 c0 01             	add    $0x1,%eax
80104ad5:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104ad9:	83 ec 0c             	sub    $0xc,%esp
80104adc:	53                   	push   %ebx
80104add:	e8 3e c9 ff ff       	call   80101420 <iupdate>
  iunlock(ip);
80104ae2:	89 1c 24             	mov    %ebx,(%esp)
80104ae5:	e8 59 cb ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104aea:	83 c4 08             	add    $0x8,%esp
80104aed:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104af0:	50                   	push   %eax
80104af1:	ff 75 e4             	pushl  -0x1c(%ebp)
80104af4:	e8 00 d1 ff ff       	call   80101bf9 <nameiparent>
80104af9:	89 c6                	mov    %eax,%esi
80104afb:	83 c4 10             	add    $0x10,%esp
80104afe:	85 c0                	test   %eax,%eax
80104b00:	74 7e                	je     80104b80 <sys_link+0x11d>
  ilock(dp);
80104b02:	83 ec 0c             	sub    $0xc,%esp
80104b05:	50                   	push   %eax
80104b06:	e8 76 ca ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104b0b:	83 c4 10             	add    $0x10,%esp
80104b0e:	8b 03                	mov    (%ebx),%eax
80104b10:	39 06                	cmp    %eax,(%esi)
80104b12:	75 60                	jne    80104b74 <sys_link+0x111>
80104b14:	83 ec 04             	sub    $0x4,%esp
80104b17:	ff 73 04             	pushl  0x4(%ebx)
80104b1a:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104b1d:	50                   	push   %eax
80104b1e:	56                   	push   %esi
80104b1f:	e8 0c d0 ff ff       	call   80101b30 <dirlink>
80104b24:	83 c4 10             	add    $0x10,%esp
80104b27:	85 c0                	test   %eax,%eax
80104b29:	78 49                	js     80104b74 <sys_link+0x111>
  iunlockput(dp);
80104b2b:	83 ec 0c             	sub    $0xc,%esp
80104b2e:	56                   	push   %esi
80104b2f:	e8 f4 cb ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104b34:	89 1c 24             	mov    %ebx,(%esp)
80104b37:	e8 4c cb ff ff       	call   80101688 <iput>
  end_op();
80104b3c:	e8 e7 dc ff ff       	call   80102828 <end_op>
  return 0;
80104b41:	83 c4 10             	add    $0x10,%esp
80104b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b49:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b4c:	5b                   	pop    %ebx
80104b4d:	5e                   	pop    %esi
80104b4e:	5d                   	pop    %ebp
80104b4f:	c3                   	ret    
    end_op();
80104b50:	e8 d3 dc ff ff       	call   80102828 <end_op>
    return -1;
80104b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b5a:	eb ed                	jmp    80104b49 <sys_link+0xe6>
    iunlockput(ip);
80104b5c:	83 ec 0c             	sub    $0xc,%esp
80104b5f:	53                   	push   %ebx
80104b60:	e8 c3 cb ff ff       	call   80101728 <iunlockput>
    end_op();
80104b65:	e8 be dc ff ff       	call   80102828 <end_op>
    return -1;
80104b6a:	83 c4 10             	add    $0x10,%esp
80104b6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b72:	eb d5                	jmp    80104b49 <sys_link+0xe6>
    iunlockput(dp);
80104b74:	83 ec 0c             	sub    $0xc,%esp
80104b77:	56                   	push   %esi
80104b78:	e8 ab cb ff ff       	call   80101728 <iunlockput>
    goto bad;
80104b7d:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104b80:	83 ec 0c             	sub    $0xc,%esp
80104b83:	53                   	push   %ebx
80104b84:	e8 f8 c9 ff ff       	call   80101581 <ilock>
  ip->nlink--;
80104b89:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104b8d:	83 e8 01             	sub    $0x1,%eax
80104b90:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104b94:	89 1c 24             	mov    %ebx,(%esp)
80104b97:	e8 84 c8 ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104b9c:	89 1c 24             	mov    %ebx,(%esp)
80104b9f:	e8 84 cb ff ff       	call   80101728 <iunlockput>
  end_op();
80104ba4:	e8 7f dc ff ff       	call   80102828 <end_op>
  return -1;
80104ba9:	83 c4 10             	add    $0x10,%esp
80104bac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb1:	eb 96                	jmp    80104b49 <sys_link+0xe6>
    return -1;
80104bb3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bb8:	eb 8f                	jmp    80104b49 <sys_link+0xe6>
80104bba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bbf:	eb 88                	jmp    80104b49 <sys_link+0xe6>

80104bc1 <sys_unlink>:
{
80104bc1:	55                   	push   %ebp
80104bc2:	89 e5                	mov    %esp,%ebp
80104bc4:	57                   	push   %edi
80104bc5:	56                   	push   %esi
80104bc6:	53                   	push   %ebx
80104bc7:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104bca:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104bcd:	50                   	push   %eax
80104bce:	6a 00                	push   $0x0
80104bd0:	e8 d7 f9 ff ff       	call   801045ac <argstr>
80104bd5:	83 c4 10             	add    $0x10,%esp
80104bd8:	85 c0                	test   %eax,%eax
80104bda:	0f 88 83 01 00 00    	js     80104d63 <sys_unlink+0x1a2>
  begin_op();
80104be0:	e8 c9 db ff ff       	call   801027ae <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104be5:	83 ec 08             	sub    $0x8,%esp
80104be8:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104beb:	50                   	push   %eax
80104bec:	ff 75 c4             	pushl  -0x3c(%ebp)
80104bef:	e8 05 d0 ff ff       	call   80101bf9 <nameiparent>
80104bf4:	89 c6                	mov    %eax,%esi
80104bf6:	83 c4 10             	add    $0x10,%esp
80104bf9:	85 c0                	test   %eax,%eax
80104bfb:	0f 84 ed 00 00 00    	je     80104cee <sys_unlink+0x12d>
  ilock(dp);
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	50                   	push   %eax
80104c05:	e8 77 c9 ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104c0a:	83 c4 08             	add    $0x8,%esp
80104c0d:	68 0a 73 10 80       	push   $0x8010730a
80104c12:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104c15:	50                   	push   %eax
80104c16:	e8 80 cd ff ff       	call   8010199b <namecmp>
80104c1b:	83 c4 10             	add    $0x10,%esp
80104c1e:	85 c0                	test   %eax,%eax
80104c20:	0f 84 fc 00 00 00    	je     80104d22 <sys_unlink+0x161>
80104c26:	83 ec 08             	sub    $0x8,%esp
80104c29:	68 09 73 10 80       	push   $0x80107309
80104c2e:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104c31:	50                   	push   %eax
80104c32:	e8 64 cd ff ff       	call   8010199b <namecmp>
80104c37:	83 c4 10             	add    $0x10,%esp
80104c3a:	85 c0                	test   %eax,%eax
80104c3c:	0f 84 e0 00 00 00    	je     80104d22 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104c42:	83 ec 04             	sub    $0x4,%esp
80104c45:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104c48:	50                   	push   %eax
80104c49:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104c4c:	50                   	push   %eax
80104c4d:	56                   	push   %esi
80104c4e:	e8 5d cd ff ff       	call   801019b0 <dirlookup>
80104c53:	89 c3                	mov    %eax,%ebx
80104c55:	83 c4 10             	add    $0x10,%esp
80104c58:	85 c0                	test   %eax,%eax
80104c5a:	0f 84 c2 00 00 00    	je     80104d22 <sys_unlink+0x161>
  ilock(ip);
80104c60:	83 ec 0c             	sub    $0xc,%esp
80104c63:	50                   	push   %eax
80104c64:	e8 18 c9 ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
80104c69:	83 c4 10             	add    $0x10,%esp
80104c6c:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104c71:	0f 8e 83 00 00 00    	jle    80104cfa <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104c77:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104c7c:	0f 84 85 00 00 00    	je     80104d07 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104c82:	83 ec 04             	sub    $0x4,%esp
80104c85:	6a 10                	push   $0x10
80104c87:	6a 00                	push   $0x0
80104c89:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104c8c:	57                   	push   %edi
80104c8d:	e8 3f f6 ff ff       	call   801042d1 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104c92:	6a 10                	push   $0x10
80104c94:	ff 75 c0             	pushl  -0x40(%ebp)
80104c97:	57                   	push   %edi
80104c98:	56                   	push   %esi
80104c99:	e8 d2 cb ff ff       	call   80101870 <writei>
80104c9e:	83 c4 20             	add    $0x20,%esp
80104ca1:	83 f8 10             	cmp    $0x10,%eax
80104ca4:	0f 85 90 00 00 00    	jne    80104d3a <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104caa:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104caf:	0f 84 92 00 00 00    	je     80104d47 <sys_unlink+0x186>
  iunlockput(dp);
80104cb5:	83 ec 0c             	sub    $0xc,%esp
80104cb8:	56                   	push   %esi
80104cb9:	e8 6a ca ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
80104cbe:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104cc2:	83 e8 01             	sub    $0x1,%eax
80104cc5:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104cc9:	89 1c 24             	mov    %ebx,(%esp)
80104ccc:	e8 4f c7 ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104cd1:	89 1c 24             	mov    %ebx,(%esp)
80104cd4:	e8 4f ca ff ff       	call   80101728 <iunlockput>
  end_op();
80104cd9:	e8 4a db ff ff       	call   80102828 <end_op>
  return 0;
80104cde:	83 c4 10             	add    $0x10,%esp
80104ce1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ce6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ce9:	5b                   	pop    %ebx
80104cea:	5e                   	pop    %esi
80104ceb:	5f                   	pop    %edi
80104cec:	5d                   	pop    %ebp
80104ced:	c3                   	ret    
    end_op();
80104cee:	e8 35 db ff ff       	call   80102828 <end_op>
    return -1;
80104cf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cf8:	eb ec                	jmp    80104ce6 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104cfa:	83 ec 0c             	sub    $0xc,%esp
80104cfd:	68 28 73 10 80       	push   $0x80107328
80104d02:	e8 41 b6 ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104d07:	89 d8                	mov    %ebx,%eax
80104d09:	e8 c4 f9 ff ff       	call   801046d2 <isdirempty>
80104d0e:	85 c0                	test   %eax,%eax
80104d10:	0f 85 6c ff ff ff    	jne    80104c82 <sys_unlink+0xc1>
    iunlockput(ip);
80104d16:	83 ec 0c             	sub    $0xc,%esp
80104d19:	53                   	push   %ebx
80104d1a:	e8 09 ca ff ff       	call   80101728 <iunlockput>
    goto bad;
80104d1f:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104d22:	83 ec 0c             	sub    $0xc,%esp
80104d25:	56                   	push   %esi
80104d26:	e8 fd c9 ff ff       	call   80101728 <iunlockput>
  end_op();
80104d2b:	e8 f8 da ff ff       	call   80102828 <end_op>
  return -1;
80104d30:	83 c4 10             	add    $0x10,%esp
80104d33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d38:	eb ac                	jmp    80104ce6 <sys_unlink+0x125>
    panic("unlink: writei");
80104d3a:	83 ec 0c             	sub    $0xc,%esp
80104d3d:	68 3a 73 10 80       	push   $0x8010733a
80104d42:	e8 01 b6 ff ff       	call   80100348 <panic>
    dp->nlink--;
80104d47:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104d4b:	83 e8 01             	sub    $0x1,%eax
80104d4e:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104d52:	83 ec 0c             	sub    $0xc,%esp
80104d55:	56                   	push   %esi
80104d56:	e8 c5 c6 ff ff       	call   80101420 <iupdate>
80104d5b:	83 c4 10             	add    $0x10,%esp
80104d5e:	e9 52 ff ff ff       	jmp    80104cb5 <sys_unlink+0xf4>
    return -1;
80104d63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d68:	e9 79 ff ff ff       	jmp    80104ce6 <sys_unlink+0x125>

80104d6d <sys_open>:

int
sys_open(void)
{
80104d6d:	55                   	push   %ebp
80104d6e:	89 e5                	mov    %esp,%ebp
80104d70:	57                   	push   %edi
80104d71:	56                   	push   %esi
80104d72:	53                   	push   %ebx
80104d73:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104d76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104d79:	50                   	push   %eax
80104d7a:	6a 00                	push   $0x0
80104d7c:	e8 2b f8 ff ff       	call   801045ac <argstr>
80104d81:	83 c4 10             	add    $0x10,%esp
80104d84:	85 c0                	test   %eax,%eax
80104d86:	0f 88 30 01 00 00    	js     80104ebc <sys_open+0x14f>
80104d8c:	83 ec 08             	sub    $0x8,%esp
80104d8f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104d92:	50                   	push   %eax
80104d93:	6a 01                	push   $0x1
80104d95:	e8 82 f7 ff ff       	call   8010451c <argint>
80104d9a:	83 c4 10             	add    $0x10,%esp
80104d9d:	85 c0                	test   %eax,%eax
80104d9f:	0f 88 21 01 00 00    	js     80104ec6 <sys_open+0x159>
    return -1;

  begin_op();
80104da5:	e8 04 da ff ff       	call   801027ae <begin_op>

  if(omode & O_CREATE){
80104daa:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104dae:	0f 84 84 00 00 00    	je     80104e38 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104db4:	83 ec 0c             	sub    $0xc,%esp
80104db7:	6a 00                	push   $0x0
80104db9:	b9 00 00 00 00       	mov    $0x0,%ecx
80104dbe:	ba 02 00 00 00       	mov    $0x2,%edx
80104dc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104dc6:	e8 5e f9 ff ff       	call   80104729 <create>
80104dcb:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104dcd:	83 c4 10             	add    $0x10,%esp
80104dd0:	85 c0                	test   %eax,%eax
80104dd2:	74 58                	je     80104e2c <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104dd4:	e8 54 be ff ff       	call   80100c2d <filealloc>
80104dd9:	89 c3                	mov    %eax,%ebx
80104ddb:	85 c0                	test   %eax,%eax
80104ddd:	0f 84 ae 00 00 00    	je     80104e91 <sys_open+0x124>
80104de3:	e8 b3 f8 ff ff       	call   8010469b <fdalloc>
80104de8:	89 c7                	mov    %eax,%edi
80104dea:	85 c0                	test   %eax,%eax
80104dec:	0f 88 9f 00 00 00    	js     80104e91 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104df2:	83 ec 0c             	sub    $0xc,%esp
80104df5:	56                   	push   %esi
80104df6:	e8 48 c8 ff ff       	call   80101643 <iunlock>
  end_op();
80104dfb:	e8 28 da ff ff       	call   80102828 <end_op>

  f->type = FD_INODE;
80104e00:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104e06:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104e09:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104e13:	83 c4 10             	add    $0x10,%esp
80104e16:	a8 01                	test   $0x1,%al
80104e18:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104e1c:	a8 03                	test   $0x3,%al
80104e1e:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104e22:	89 f8                	mov    %edi,%eax
80104e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104e27:	5b                   	pop    %ebx
80104e28:	5e                   	pop    %esi
80104e29:	5f                   	pop    %edi
80104e2a:	5d                   	pop    %ebp
80104e2b:	c3                   	ret    
      end_op();
80104e2c:	e8 f7 d9 ff ff       	call   80102828 <end_op>
      return -1;
80104e31:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104e36:	eb ea                	jmp    80104e22 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104e38:	83 ec 0c             	sub    $0xc,%esp
80104e3b:	ff 75 e4             	pushl  -0x1c(%ebp)
80104e3e:	e8 9e cd ff ff       	call   80101be1 <namei>
80104e43:	89 c6                	mov    %eax,%esi
80104e45:	83 c4 10             	add    $0x10,%esp
80104e48:	85 c0                	test   %eax,%eax
80104e4a:	74 39                	je     80104e85 <sys_open+0x118>
    ilock(ip);
80104e4c:	83 ec 0c             	sub    $0xc,%esp
80104e4f:	50                   	push   %eax
80104e50:	e8 2c c7 ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104e55:	83 c4 10             	add    $0x10,%esp
80104e58:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104e5d:	0f 85 71 ff ff ff    	jne    80104dd4 <sys_open+0x67>
80104e63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104e67:	0f 84 67 ff ff ff    	je     80104dd4 <sys_open+0x67>
      iunlockput(ip);
80104e6d:	83 ec 0c             	sub    $0xc,%esp
80104e70:	56                   	push   %esi
80104e71:	e8 b2 c8 ff ff       	call   80101728 <iunlockput>
      end_op();
80104e76:	e8 ad d9 ff ff       	call   80102828 <end_op>
      return -1;
80104e7b:	83 c4 10             	add    $0x10,%esp
80104e7e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104e83:	eb 9d                	jmp    80104e22 <sys_open+0xb5>
      end_op();
80104e85:	e8 9e d9 ff ff       	call   80102828 <end_op>
      return -1;
80104e8a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104e8f:	eb 91                	jmp    80104e22 <sys_open+0xb5>
    if(f)
80104e91:	85 db                	test   %ebx,%ebx
80104e93:	74 0c                	je     80104ea1 <sys_open+0x134>
      fileclose(f);
80104e95:	83 ec 0c             	sub    $0xc,%esp
80104e98:	53                   	push   %ebx
80104e99:	e8 35 be ff ff       	call   80100cd3 <fileclose>
80104e9e:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104ea1:	83 ec 0c             	sub    $0xc,%esp
80104ea4:	56                   	push   %esi
80104ea5:	e8 7e c8 ff ff       	call   80101728 <iunlockput>
    end_op();
80104eaa:	e8 79 d9 ff ff       	call   80102828 <end_op>
    return -1;
80104eaf:	83 c4 10             	add    $0x10,%esp
80104eb2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104eb7:	e9 66 ff ff ff       	jmp    80104e22 <sys_open+0xb5>
    return -1;
80104ebc:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ec1:	e9 5c ff ff ff       	jmp    80104e22 <sys_open+0xb5>
80104ec6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ecb:	e9 52 ff ff ff       	jmp    80104e22 <sys_open+0xb5>

80104ed0 <sys_mkdir>:

int
sys_mkdir(void)
{
80104ed0:	55                   	push   %ebp
80104ed1:	89 e5                	mov    %esp,%ebp
80104ed3:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104ed6:	e8 d3 d8 ff ff       	call   801027ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104edb:	83 ec 08             	sub    $0x8,%esp
80104ede:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ee1:	50                   	push   %eax
80104ee2:	6a 00                	push   $0x0
80104ee4:	e8 c3 f6 ff ff       	call   801045ac <argstr>
80104ee9:	83 c4 10             	add    $0x10,%esp
80104eec:	85 c0                	test   %eax,%eax
80104eee:	78 36                	js     80104f26 <sys_mkdir+0x56>
80104ef0:	83 ec 0c             	sub    $0xc,%esp
80104ef3:	6a 00                	push   $0x0
80104ef5:	b9 00 00 00 00       	mov    $0x0,%ecx
80104efa:	ba 01 00 00 00       	mov    $0x1,%edx
80104eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f02:	e8 22 f8 ff ff       	call   80104729 <create>
80104f07:	83 c4 10             	add    $0x10,%esp
80104f0a:	85 c0                	test   %eax,%eax
80104f0c:	74 18                	je     80104f26 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104f0e:	83 ec 0c             	sub    $0xc,%esp
80104f11:	50                   	push   %eax
80104f12:	e8 11 c8 ff ff       	call   80101728 <iunlockput>
  end_op();
80104f17:	e8 0c d9 ff ff       	call   80102828 <end_op>
  return 0;
80104f1c:	83 c4 10             	add    $0x10,%esp
80104f1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f24:	c9                   	leave  
80104f25:	c3                   	ret    
    end_op();
80104f26:	e8 fd d8 ff ff       	call   80102828 <end_op>
    return -1;
80104f2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f30:	eb f2                	jmp    80104f24 <sys_mkdir+0x54>

80104f32 <sys_mknod>:

int
sys_mknod(void)
{
80104f32:	55                   	push   %ebp
80104f33:	89 e5                	mov    %esp,%ebp
80104f35:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104f38:	e8 71 d8 ff ff       	call   801027ae <begin_op>
  if((argstr(0, &path)) < 0 ||
80104f3d:	83 ec 08             	sub    $0x8,%esp
80104f40:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f43:	50                   	push   %eax
80104f44:	6a 00                	push   $0x0
80104f46:	e8 61 f6 ff ff       	call   801045ac <argstr>
80104f4b:	83 c4 10             	add    $0x10,%esp
80104f4e:	85 c0                	test   %eax,%eax
80104f50:	78 62                	js     80104fb4 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104f52:	83 ec 08             	sub    $0x8,%esp
80104f55:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f58:	50                   	push   %eax
80104f59:	6a 01                	push   $0x1
80104f5b:	e8 bc f5 ff ff       	call   8010451c <argint>
  if((argstr(0, &path)) < 0 ||
80104f60:	83 c4 10             	add    $0x10,%esp
80104f63:	85 c0                	test   %eax,%eax
80104f65:	78 4d                	js     80104fb4 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104f67:	83 ec 08             	sub    $0x8,%esp
80104f6a:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f6d:	50                   	push   %eax
80104f6e:	6a 02                	push   $0x2
80104f70:	e8 a7 f5 ff ff       	call   8010451c <argint>
     argint(1, &major) < 0 ||
80104f75:	83 c4 10             	add    $0x10,%esp
80104f78:	85 c0                	test   %eax,%eax
80104f7a:	78 38                	js     80104fb4 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104f7c:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104f80:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104f84:	83 ec 0c             	sub    $0xc,%esp
80104f87:	50                   	push   %eax
80104f88:	ba 03 00 00 00       	mov    $0x3,%edx
80104f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f90:	e8 94 f7 ff ff       	call   80104729 <create>
80104f95:	83 c4 10             	add    $0x10,%esp
80104f98:	85 c0                	test   %eax,%eax
80104f9a:	74 18                	je     80104fb4 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104f9c:	83 ec 0c             	sub    $0xc,%esp
80104f9f:	50                   	push   %eax
80104fa0:	e8 83 c7 ff ff       	call   80101728 <iunlockput>
  end_op();
80104fa5:	e8 7e d8 ff ff       	call   80102828 <end_op>
  return 0;
80104faa:	83 c4 10             	add    $0x10,%esp
80104fad:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104fb2:	c9                   	leave  
80104fb3:	c3                   	ret    
    end_op();
80104fb4:	e8 6f d8 ff ff       	call   80102828 <end_op>
    return -1;
80104fb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fbe:	eb f2                	jmp    80104fb2 <sys_mknod+0x80>

80104fc0 <sys_chdir>:

int
sys_chdir(void)
{
80104fc0:	55                   	push   %ebp
80104fc1:	89 e5                	mov    %esp,%ebp
80104fc3:	56                   	push   %esi
80104fc4:	53                   	push   %ebx
80104fc5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104fc8:	e8 b1 e2 ff ff       	call   8010327e <myproc>
80104fcd:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104fcf:	e8 da d7 ff ff       	call   801027ae <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104fd4:	83 ec 08             	sub    $0x8,%esp
80104fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fda:	50                   	push   %eax
80104fdb:	6a 00                	push   $0x0
80104fdd:	e8 ca f5 ff ff       	call   801045ac <argstr>
80104fe2:	83 c4 10             	add    $0x10,%esp
80104fe5:	85 c0                	test   %eax,%eax
80104fe7:	78 52                	js     8010503b <sys_chdir+0x7b>
80104fe9:	83 ec 0c             	sub    $0xc,%esp
80104fec:	ff 75 f4             	pushl  -0xc(%ebp)
80104fef:	e8 ed cb ff ff       	call   80101be1 <namei>
80104ff4:	89 c3                	mov    %eax,%ebx
80104ff6:	83 c4 10             	add    $0x10,%esp
80104ff9:	85 c0                	test   %eax,%eax
80104ffb:	74 3e                	je     8010503b <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104ffd:	83 ec 0c             	sub    $0xc,%esp
80105000:	50                   	push   %eax
80105001:	e8 7b c5 ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80105006:	83 c4 10             	add    $0x10,%esp
80105009:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010500e:	75 37                	jne    80105047 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105010:	83 ec 0c             	sub    $0xc,%esp
80105013:	53                   	push   %ebx
80105014:	e8 2a c6 ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80105019:	83 c4 04             	add    $0x4,%esp
8010501c:	ff 76 68             	pushl  0x68(%esi)
8010501f:	e8 64 c6 ff ff       	call   80101688 <iput>
  end_op();
80105024:	e8 ff d7 ff ff       	call   80102828 <end_op>
  curproc->cwd = ip;
80105029:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
8010502c:	83 c4 10             	add    $0x10,%esp
8010502f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105034:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105037:	5b                   	pop    %ebx
80105038:	5e                   	pop    %esi
80105039:	5d                   	pop    %ebp
8010503a:	c3                   	ret    
    end_op();
8010503b:	e8 e8 d7 ff ff       	call   80102828 <end_op>
    return -1;
80105040:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105045:	eb ed                	jmp    80105034 <sys_chdir+0x74>
    iunlockput(ip);
80105047:	83 ec 0c             	sub    $0xc,%esp
8010504a:	53                   	push   %ebx
8010504b:	e8 d8 c6 ff ff       	call   80101728 <iunlockput>
    end_op();
80105050:	e8 d3 d7 ff ff       	call   80102828 <end_op>
    return -1;
80105055:	83 c4 10             	add    $0x10,%esp
80105058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010505d:	eb d5                	jmp    80105034 <sys_chdir+0x74>

8010505f <sys_exec>:

int
sys_exec(void)
{
8010505f:	55                   	push   %ebp
80105060:	89 e5                	mov    %esp,%ebp
80105062:	53                   	push   %ebx
80105063:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105069:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010506c:	50                   	push   %eax
8010506d:	6a 00                	push   $0x0
8010506f:	e8 38 f5 ff ff       	call   801045ac <argstr>
80105074:	83 c4 10             	add    $0x10,%esp
80105077:	85 c0                	test   %eax,%eax
80105079:	0f 88 a8 00 00 00    	js     80105127 <sys_exec+0xc8>
8010507f:	83 ec 08             	sub    $0x8,%esp
80105082:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105088:	50                   	push   %eax
80105089:	6a 01                	push   $0x1
8010508b:	e8 8c f4 ff ff       	call   8010451c <argint>
80105090:	83 c4 10             	add    $0x10,%esp
80105093:	85 c0                	test   %eax,%eax
80105095:	0f 88 93 00 00 00    	js     8010512e <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
8010509b:	83 ec 04             	sub    $0x4,%esp
8010509e:	68 80 00 00 00       	push   $0x80
801050a3:	6a 00                	push   $0x0
801050a5:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
801050ab:	50                   	push   %eax
801050ac:	e8 20 f2 ff ff       	call   801042d1 <memset>
801050b1:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801050b4:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
801050b9:	83 fb 1f             	cmp    $0x1f,%ebx
801050bc:	77 77                	ja     80105135 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801050be:	83 ec 08             	sub    $0x8,%esp
801050c1:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801050c7:	50                   	push   %eax
801050c8:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
801050ce:	8d 04 98             	lea    (%eax,%ebx,4),%eax
801050d1:	50                   	push   %eax
801050d2:	e8 c9 f3 ff ff       	call   801044a0 <fetchint>
801050d7:	83 c4 10             	add    $0x10,%esp
801050da:	85 c0                	test   %eax,%eax
801050dc:	78 5e                	js     8010513c <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
801050de:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801050e4:	85 c0                	test   %eax,%eax
801050e6:	74 1d                	je     80105105 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801050e8:	83 ec 08             	sub    $0x8,%esp
801050eb:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
801050f2:	52                   	push   %edx
801050f3:	50                   	push   %eax
801050f4:	e8 e3 f3 ff ff       	call   801044dc <fetchstr>
801050f9:	83 c4 10             	add    $0x10,%esp
801050fc:	85 c0                	test   %eax,%eax
801050fe:	78 46                	js     80105146 <sys_exec+0xe7>
  for(i=0;; i++){
80105100:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105103:	eb b4                	jmp    801050b9 <sys_exec+0x5a>
      argv[i] = 0;
80105105:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
8010510c:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80105110:	83 ec 08             	sub    $0x8,%esp
80105113:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80105119:	50                   	push   %eax
8010511a:	ff 75 f4             	pushl  -0xc(%ebp)
8010511d:	e8 b0 b7 ff ff       	call   801008d2 <exec>
80105122:	83 c4 10             	add    $0x10,%esp
80105125:	eb 1a                	jmp    80105141 <sys_exec+0xe2>
    return -1;
80105127:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010512c:	eb 13                	jmp    80105141 <sys_exec+0xe2>
8010512e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105133:	eb 0c                	jmp    80105141 <sys_exec+0xe2>
      return -1;
80105135:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010513a:	eb 05                	jmp    80105141 <sys_exec+0xe2>
      return -1;
8010513c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105144:	c9                   	leave  
80105145:	c3                   	ret    
      return -1;
80105146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010514b:	eb f4                	jmp    80105141 <sys_exec+0xe2>

8010514d <sys_pipe>:

int
sys_pipe(void)
{
8010514d:	55                   	push   %ebp
8010514e:	89 e5                	mov    %esp,%ebp
80105150:	53                   	push   %ebx
80105151:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105154:	6a 08                	push   $0x8
80105156:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105159:	50                   	push   %eax
8010515a:	6a 00                	push   $0x0
8010515c:	e8 e3 f3 ff ff       	call   80104544 <argptr>
80105161:	83 c4 10             	add    $0x10,%esp
80105164:	85 c0                	test   %eax,%eax
80105166:	78 77                	js     801051df <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105168:	83 ec 08             	sub    $0x8,%esp
8010516b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010516e:	50                   	push   %eax
8010516f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105172:	50                   	push   %eax
80105173:	e8 bd db ff ff       	call   80102d35 <pipealloc>
80105178:	83 c4 10             	add    $0x10,%esp
8010517b:	85 c0                	test   %eax,%eax
8010517d:	78 67                	js     801051e6 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010517f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105182:	e8 14 f5 ff ff       	call   8010469b <fdalloc>
80105187:	89 c3                	mov    %eax,%ebx
80105189:	85 c0                	test   %eax,%eax
8010518b:	78 21                	js     801051ae <sys_pipe+0x61>
8010518d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105190:	e8 06 f5 ff ff       	call   8010469b <fdalloc>
80105195:	85 c0                	test   %eax,%eax
80105197:	78 15                	js     801051ae <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80105199:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010519c:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
8010519e:	8b 55 f4             	mov    -0xc(%ebp),%edx
801051a1:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
801051a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801051a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801051ac:	c9                   	leave  
801051ad:	c3                   	ret    
    if(fd0 >= 0)
801051ae:	85 db                	test   %ebx,%ebx
801051b0:	78 0d                	js     801051bf <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
801051b2:	e8 c7 e0 ff ff       	call   8010327e <myproc>
801051b7:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
801051be:	00 
    fileclose(rf);
801051bf:	83 ec 0c             	sub    $0xc,%esp
801051c2:	ff 75 f0             	pushl  -0x10(%ebp)
801051c5:	e8 09 bb ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
801051ca:	83 c4 04             	add    $0x4,%esp
801051cd:	ff 75 ec             	pushl  -0x14(%ebp)
801051d0:	e8 fe ba ff ff       	call   80100cd3 <fileclose>
    return -1;
801051d5:	83 c4 10             	add    $0x10,%esp
801051d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051dd:	eb ca                	jmp    801051a9 <sys_pipe+0x5c>
    return -1;
801051df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051e4:	eb c3                	jmp    801051a9 <sys_pipe+0x5c>
    return -1;
801051e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051eb:	eb bc                	jmp    801051a9 <sys_pipe+0x5c>

801051ed <sys_fork>:
#include "proc.h"
#include "pstat.h"

int
sys_fork(void)
{
801051ed:	55                   	push   %ebp
801051ee:	89 e5                	mov    %esp,%ebp
801051f0:	83 ec 08             	sub    $0x8,%esp
  return fork();
801051f3:	e8 15 ed ff ff       	call   80103f0d <fork>
}
801051f8:	c9                   	leave  
801051f9:	c3                   	ret    

801051fa <sys_exit>:

int
sys_exit(void)
{
801051fa:	55                   	push   %ebp
801051fb:	89 e5                	mov    %esp,%ebp
801051fd:	83 ec 08             	sub    $0x8,%esp
  exit();
80105200:	e8 e5 e7 ff ff       	call   801039ea <exit>
  return 0;  // not reached
}
80105205:	b8 00 00 00 00       	mov    $0x0,%eax
8010520a:	c9                   	leave  
8010520b:	c3                   	ret    

8010520c <sys_wait>:

int
sys_wait(void)
{
8010520c:	55                   	push   %ebp
8010520d:	89 e5                	mov    %esp,%ebp
8010520f:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105212:	e8 5f e9 ff ff       	call   80103b76 <wait>
}
80105217:	c9                   	leave  
80105218:	c3                   	ret    

80105219 <sys_kill>:

int
sys_kill(void)
{
80105219:	55                   	push   %ebp
8010521a:	89 e5                	mov    %esp,%ebp
8010521c:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010521f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105222:	50                   	push   %eax
80105223:	6a 00                	push   $0x0
80105225:	e8 f2 f2 ff ff       	call   8010451c <argint>
8010522a:	83 c4 10             	add    $0x10,%esp
8010522d:	85 c0                	test   %eax,%eax
8010522f:	78 10                	js     80105241 <sys_kill+0x28>
    return -1;
  return kill(pid);
80105231:	83 ec 0c             	sub    $0xc,%esp
80105234:	ff 75 f4             	pushl  -0xc(%ebp)
80105237:	e8 3a ea ff ff       	call   80103c76 <kill>
8010523c:	83 c4 10             	add    $0x10,%esp
}
8010523f:	c9                   	leave  
80105240:	c3                   	ret    
    return -1;
80105241:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105246:	eb f7                	jmp    8010523f <sys_kill+0x26>

80105248 <sys_getpid>:

int
sys_getpid(void)
{
80105248:	55                   	push   %ebp
80105249:	89 e5                	mov    %esp,%ebp
8010524b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010524e:	e8 2b e0 ff ff       	call   8010327e <myproc>
80105253:	8b 40 10             	mov    0x10(%eax),%eax
}
80105256:	c9                   	leave  
80105257:	c3                   	ret    

80105258 <sys_sbrk>:

int
sys_sbrk(void)
{
80105258:	55                   	push   %ebp
80105259:	89 e5                	mov    %esp,%ebp
8010525b:	53                   	push   %ebx
8010525c:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010525f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105262:	50                   	push   %eax
80105263:	6a 00                	push   $0x0
80105265:	e8 b2 f2 ff ff       	call   8010451c <argint>
8010526a:	83 c4 10             	add    $0x10,%esp
8010526d:	85 c0                	test   %eax,%eax
8010526f:	78 27                	js     80105298 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105271:	e8 08 e0 ff ff       	call   8010327e <myproc>
80105276:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105278:	83 ec 0c             	sub    $0xc,%esp
8010527b:	ff 75 f4             	pushl  -0xc(%ebp)
8010527e:	e8 06 e1 ff ff       	call   80103389 <growproc>
80105283:	83 c4 10             	add    $0x10,%esp
80105286:	85 c0                	test   %eax,%eax
80105288:	78 07                	js     80105291 <sys_sbrk+0x39>
    return -1;
  return addr;
}
8010528a:	89 d8                	mov    %ebx,%eax
8010528c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010528f:	c9                   	leave  
80105290:	c3                   	ret    
    return -1;
80105291:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105296:	eb f2                	jmp    8010528a <sys_sbrk+0x32>
    return -1;
80105298:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010529d:	eb eb                	jmp    8010528a <sys_sbrk+0x32>

8010529f <sys_sleep>:

int
sys_sleep(void)
{
8010529f:	55                   	push   %ebp
801052a0:	89 e5                	mov    %esp,%ebp
801052a2:	53                   	push   %ebx
801052a3:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801052a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801052a9:	50                   	push   %eax
801052aa:	6a 00                	push   $0x0
801052ac:	e8 6b f2 ff ff       	call   8010451c <argint>
801052b1:	83 c4 10             	add    $0x10,%esp
801052b4:	85 c0                	test   %eax,%eax
801052b6:	78 75                	js     8010532d <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
801052b8:	83 ec 0c             	sub    $0xc,%esp
801052bb:	68 80 5d 11 80       	push   $0x80115d80
801052c0:	e8 60 ef ff ff       	call   80104225 <acquire>
  ticks0 = ticks;
801052c5:	8b 1d c0 65 11 80    	mov    0x801165c0,%ebx
  while(ticks - ticks0 < n){
801052cb:	83 c4 10             	add    $0x10,%esp
801052ce:	a1 c0 65 11 80       	mov    0x801165c0,%eax
801052d3:	29 d8                	sub    %ebx,%eax
801052d5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801052d8:	73 39                	jae    80105313 <sys_sleep+0x74>
    if(myproc()->killed){
801052da:	e8 9f df ff ff       	call   8010327e <myproc>
801052df:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801052e3:	75 17                	jne    801052fc <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
801052e5:	83 ec 08             	sub    $0x8,%esp
801052e8:	68 80 5d 11 80       	push   $0x80115d80
801052ed:	68 c0 65 11 80       	push   $0x801165c0
801052f2:	e8 ee e7 ff ff       	call   80103ae5 <sleep>
801052f7:	83 c4 10             	add    $0x10,%esp
801052fa:	eb d2                	jmp    801052ce <sys_sleep+0x2f>
      release(&tickslock);
801052fc:	83 ec 0c             	sub    $0xc,%esp
801052ff:	68 80 5d 11 80       	push   $0x80115d80
80105304:	e8 81 ef ff ff       	call   8010428a <release>
      return -1;
80105309:	83 c4 10             	add    $0x10,%esp
8010530c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105311:	eb 15                	jmp    80105328 <sys_sleep+0x89>
  }
  release(&tickslock);
80105313:	83 ec 0c             	sub    $0xc,%esp
80105316:	68 80 5d 11 80       	push   $0x80115d80
8010531b:	e8 6a ef ff ff       	call   8010428a <release>
  return 0;
80105320:	83 c4 10             	add    $0x10,%esp
80105323:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105328:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010532b:	c9                   	leave  
8010532c:	c3                   	ret    
    return -1;
8010532d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105332:	eb f4                	jmp    80105328 <sys_sleep+0x89>

80105334 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105334:	55                   	push   %ebp
80105335:	89 e5                	mov    %esp,%ebp
80105337:	53                   	push   %ebx
80105338:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
8010533b:	68 80 5d 11 80       	push   $0x80115d80
80105340:	e8 e0 ee ff ff       	call   80104225 <acquire>
  xticks = ticks;
80105345:	8b 1d c0 65 11 80    	mov    0x801165c0,%ebx
  release(&tickslock);
8010534b:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
80105352:	e8 33 ef ff ff       	call   8010428a <release>
  return xticks;
}
80105357:	89 d8                	mov    %ebx,%eax
80105359:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010535c:	c9                   	leave  
8010535d:	c3                   	ret    

8010535e <sys_setpri>:

int
sys_setpri(void){
8010535e:	55                   	push   %ebp
8010535f:	89 e5                	mov    %esp,%ebp
80105361:	83 ec 20             	sub    $0x20,%esp
  int PID;
  int pri;
  if(argint(0, &PID) < 0){
80105364:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105367:	50                   	push   %eax
80105368:	6a 00                	push   $0x0
8010536a:	e8 ad f1 ff ff       	call   8010451c <argint>
8010536f:	83 c4 10             	add    $0x10,%esp
80105372:	85 c0                	test   %eax,%eax
80105374:	78 28                	js     8010539e <sys_setpri+0x40>
    return -1;
  }
  if(argint(1, &pri) < 0){
80105376:	83 ec 08             	sub    $0x8,%esp
80105379:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010537c:	50                   	push   %eax
8010537d:	6a 01                	push   $0x1
8010537f:	e8 98 f1 ff ff       	call   8010451c <argint>
80105384:	83 c4 10             	add    $0x10,%esp
80105387:	85 c0                	test   %eax,%eax
80105389:	78 1a                	js     801053a5 <sys_setpri+0x47>
    return -1;
  }
  return setpri(PID, pri);
8010538b:	83 ec 08             	sub    $0x8,%esp
8010538e:	ff 75 f0             	pushl  -0x10(%ebp)
80105391:	ff 75 f4             	pushl  -0xc(%ebp)
80105394:	e8 08 ea ff ff       	call   80103da1 <setpri>
80105399:	83 c4 10             	add    $0x10,%esp
}
8010539c:	c9                   	leave  
8010539d:	c3                   	ret    
    return -1;
8010539e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a3:	eb f7                	jmp    8010539c <sys_setpri+0x3e>
    return -1;
801053a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053aa:	eb f0                	jmp    8010539c <sys_setpri+0x3e>

801053ac <sys_getpri>:

int
sys_getpri(void){
801053ac:	55                   	push   %ebp
801053ad:	89 e5                	mov    %esp,%ebp
801053af:	83 ec 20             	sub    $0x20,%esp
  int PID;
  if(argint(0, &PID) < 0){
801053b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053b5:	50                   	push   %eax
801053b6:	6a 00                	push   $0x0
801053b8:	e8 5f f1 ff ff       	call   8010451c <argint>
801053bd:	83 c4 10             	add    $0x10,%esp
801053c0:	85 c0                	test   %eax,%eax
801053c2:	78 10                	js     801053d4 <sys_getpri+0x28>
    return -1;
  }
  return getpri(PID);
801053c4:	83 ec 0c             	sub    $0xc,%esp
801053c7:	ff 75 f4             	pushl  -0xc(%ebp)
801053ca:	e8 ff e9 ff ff       	call   80103dce <getpri>
801053cf:	83 c4 10             	add    $0x10,%esp
}
801053d2:	c9                   	leave  
801053d3:	c3                   	ret    
    return -1;
801053d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053d9:	eb f7                	jmp    801053d2 <sys_getpri+0x26>

801053db <sys_fork2>:

int
sys_fork2(void){
801053db:	55                   	push   %ebp
801053dc:	89 e5                	mov    %esp,%ebp
801053de:	83 ec 20             	sub    $0x20,%esp
  int pri;
   if(argint(1, &pri) < 0){
801053e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053e4:	50                   	push   %eax
801053e5:	6a 01                	push   $0x1
801053e7:	e8 30 f1 ff ff       	call   8010451c <argint>
801053ec:	83 c4 10             	add    $0x10,%esp
801053ef:	85 c0                	test   %eax,%eax
801053f1:	78 10                	js     80105403 <sys_fork2+0x28>
    return -1;
  }
  return fork2(pri);
801053f3:	83 ec 0c             	sub    $0xc,%esp
801053f6:	ff 75 f4             	pushl  -0xc(%ebp)
801053f9:	e8 ff e9 ff ff       	call   80103dfd <fork2>
801053fe:	83 c4 10             	add    $0x10,%esp
}
80105401:	c9                   	leave  
80105402:	c3                   	ret    
    return -1;
80105403:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105408:	eb f7                	jmp    80105401 <sys_fork2+0x26>

8010540a <sys_getpinfo>:

int
sys_getpinfo(void){
8010540a:	55                   	push   %ebp
8010540b:	89 e5                	mov    %esp,%ebp
8010540d:	83 ec 1c             	sub    $0x1c,%esp
  struct pstat *mystruct;
  if(argptr(0, (void*)&mystruct, sizeof(*mystruct)) <0){
80105410:	68 00 0c 00 00       	push   $0xc00
80105415:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105418:	50                   	push   %eax
80105419:	6a 00                	push   $0x0
8010541b:	e8 24 f1 ff ff       	call   80104544 <argptr>
80105420:	83 c4 10             	add    $0x10,%esp
80105423:	85 c0                	test   %eax,%eax
80105425:	78 10                	js     80105437 <sys_getpinfo+0x2d>
	 return -1;
  }
  return getpinfo(mystruct);
80105427:	83 ec 0c             	sub    $0xc,%esp
8010542a:	ff 75 f4             	pushl  -0xc(%ebp)
8010542d:	e8 fb ea ff ff       	call   80103f2d <getpinfo>
80105432:	83 c4 10             	add    $0x10,%esp
}
80105435:	c9                   	leave  
80105436:	c3                   	ret    
	 return -1;
80105437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010543c:	eb f7                	jmp    80105435 <sys_getpinfo+0x2b>

8010543e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010543e:	1e                   	push   %ds
  pushl %es
8010543f:	06                   	push   %es
  pushl %fs
80105440:	0f a0                	push   %fs
  pushl %gs
80105442:	0f a8                	push   %gs
  pushal
80105444:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105445:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105449:	8e d8                	mov    %eax,%ds
  movw %ax, %es
8010544b:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010544d:	54                   	push   %esp
  call trap
8010544e:	e8 e3 00 00 00       	call   80105536 <trap>
  addl $4, %esp
80105453:	83 c4 04             	add    $0x4,%esp

80105456 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105456:	61                   	popa   
  popl %gs
80105457:	0f a9                	pop    %gs
  popl %fs
80105459:	0f a1                	pop    %fs
  popl %es
8010545b:	07                   	pop    %es
  popl %ds
8010545c:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010545d:	83 c4 08             	add    $0x8,%esp
  iret
80105460:	cf                   	iret   

80105461 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105461:	55                   	push   %ebp
80105462:	89 e5                	mov    %esp,%ebp
80105464:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80105467:	b8 00 00 00 00       	mov    $0x0,%eax
8010546c:	eb 4a                	jmp    801054b8 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010546e:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80105475:	66 89 0c c5 c0 5d 11 	mov    %cx,-0x7feea240(,%eax,8)
8010547c:	80 
8010547d:	66 c7 04 c5 c2 5d 11 	movw   $0x8,-0x7feea23e(,%eax,8)
80105484:	80 08 00 
80105487:	c6 04 c5 c4 5d 11 80 	movb   $0x0,-0x7feea23c(,%eax,8)
8010548e:	00 
8010548f:	0f b6 14 c5 c5 5d 11 	movzbl -0x7feea23b(,%eax,8),%edx
80105496:	80 
80105497:	83 e2 f0             	and    $0xfffffff0,%edx
8010549a:	83 ca 0e             	or     $0xe,%edx
8010549d:	83 e2 8f             	and    $0xffffff8f,%edx
801054a0:	83 ca 80             	or     $0xffffff80,%edx
801054a3:	88 14 c5 c5 5d 11 80 	mov    %dl,-0x7feea23b(,%eax,8)
801054aa:	c1 e9 10             	shr    $0x10,%ecx
801054ad:	66 89 0c c5 c6 5d 11 	mov    %cx,-0x7feea23a(,%eax,8)
801054b4:	80 
  for(i = 0; i < 256; i++)
801054b5:	83 c0 01             	add    $0x1,%eax
801054b8:	3d ff 00 00 00       	cmp    $0xff,%eax
801054bd:	7e af                	jle    8010546e <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801054bf:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
801054c5:	66 89 15 c0 5f 11 80 	mov    %dx,0x80115fc0
801054cc:	66 c7 05 c2 5f 11 80 	movw   $0x8,0x80115fc2
801054d3:	08 00 
801054d5:	c6 05 c4 5f 11 80 00 	movb   $0x0,0x80115fc4
801054dc:	0f b6 05 c5 5f 11 80 	movzbl 0x80115fc5,%eax
801054e3:	83 c8 0f             	or     $0xf,%eax
801054e6:	83 e0 ef             	and    $0xffffffef,%eax
801054e9:	83 c8 e0             	or     $0xffffffe0,%eax
801054ec:	a2 c5 5f 11 80       	mov    %al,0x80115fc5
801054f1:	c1 ea 10             	shr    $0x10,%edx
801054f4:	66 89 15 c6 5f 11 80 	mov    %dx,0x80115fc6

  initlock(&tickslock, "time");
801054fb:	83 ec 08             	sub    $0x8,%esp
801054fe:	68 49 73 10 80       	push   $0x80107349
80105503:	68 80 5d 11 80       	push   $0x80115d80
80105508:	e8 dc eb ff ff       	call   801040e9 <initlock>
}
8010550d:	83 c4 10             	add    $0x10,%esp
80105510:	c9                   	leave  
80105511:	c3                   	ret    

80105512 <idtinit>:

void
idtinit(void)
{
80105512:	55                   	push   %ebp
80105513:	89 e5                	mov    %esp,%ebp
80105515:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105518:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
8010551e:	b8 c0 5d 11 80       	mov    $0x80115dc0,%eax
80105523:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105527:	c1 e8 10             	shr    $0x10,%eax
8010552a:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010552e:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105531:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105534:	c9                   	leave  
80105535:	c3                   	ret    

80105536 <trap>:

void
trap(struct trapframe *tf)
{
80105536:	55                   	push   %ebp
80105537:	89 e5                	mov    %esp,%ebp
80105539:	57                   	push   %edi
8010553a:	56                   	push   %esi
8010553b:	53                   	push   %ebx
8010553c:	83 ec 1c             	sub    $0x1c,%esp
8010553f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105542:	8b 43 30             	mov    0x30(%ebx),%eax
80105545:	83 f8 40             	cmp    $0x40,%eax
80105548:	74 13                	je     8010555d <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
8010554a:	83 e8 20             	sub    $0x20,%eax
8010554d:	83 f8 1f             	cmp    $0x1f,%eax
80105550:	0f 87 3a 01 00 00    	ja     80105690 <trap+0x15a>
80105556:	ff 24 85 f0 73 10 80 	jmp    *-0x7fef8c10(,%eax,4)
    if(myproc()->killed)
8010555d:	e8 1c dd ff ff       	call   8010327e <myproc>
80105562:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105566:	75 1f                	jne    80105587 <trap+0x51>
    myproc()->tf = tf;
80105568:	e8 11 dd ff ff       	call   8010327e <myproc>
8010556d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105570:	e8 6a f0 ff ff       	call   801045df <syscall>
    if(myproc()->killed)
80105575:	e8 04 dd ff ff       	call   8010327e <myproc>
8010557a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010557e:	74 7e                	je     801055fe <trap+0xc8>
      exit();
80105580:	e8 65 e4 ff ff       	call   801039ea <exit>
80105585:	eb 77                	jmp    801055fe <trap+0xc8>
      exit();
80105587:	e8 5e e4 ff ff       	call   801039ea <exit>
8010558c:	eb da                	jmp    80105568 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010558e:	e8 d0 dc ff ff       	call   80103263 <cpuid>
80105593:	85 c0                	test   %eax,%eax
80105595:	74 6f                	je     80105606 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105597:	e8 fd cd ff ff       	call   80102399 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010559c:	e8 dd dc ff ff       	call   8010327e <myproc>
801055a1:	85 c0                	test   %eax,%eax
801055a3:	74 1c                	je     801055c1 <trap+0x8b>
801055a5:	e8 d4 dc ff ff       	call   8010327e <myproc>
801055aa:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801055ae:	74 11                	je     801055c1 <trap+0x8b>
801055b0:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801055b4:	83 e0 03             	and    $0x3,%eax
801055b7:	66 83 f8 03          	cmp    $0x3,%ax
801055bb:	0f 84 62 01 00 00    	je     80105723 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801055c1:	e8 b8 dc ff ff       	call   8010327e <myproc>
801055c6:	85 c0                	test   %eax,%eax
801055c8:	74 0f                	je     801055d9 <trap+0xa3>
801055ca:	e8 af dc ff ff       	call   8010327e <myproc>
801055cf:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801055d3:	0f 84 54 01 00 00    	je     8010572d <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801055d9:	e8 a0 dc ff ff       	call   8010327e <myproc>
801055de:	85 c0                	test   %eax,%eax
801055e0:	74 1c                	je     801055fe <trap+0xc8>
801055e2:	e8 97 dc ff ff       	call   8010327e <myproc>
801055e7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801055eb:	74 11                	je     801055fe <trap+0xc8>
801055ed:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801055f1:	83 e0 03             	and    $0x3,%eax
801055f4:	66 83 f8 03          	cmp    $0x3,%ax
801055f8:	0f 84 43 01 00 00    	je     80105741 <trap+0x20b>
    exit();
}
801055fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105601:	5b                   	pop    %ebx
80105602:	5e                   	pop    %esi
80105603:	5f                   	pop    %edi
80105604:	5d                   	pop    %ebp
80105605:	c3                   	ret    
      acquire(&tickslock);
80105606:	83 ec 0c             	sub    $0xc,%esp
80105609:	68 80 5d 11 80       	push   $0x80115d80
8010560e:	e8 12 ec ff ff       	call   80104225 <acquire>
      ticks++;
80105613:	83 05 c0 65 11 80 01 	addl   $0x1,0x801165c0
      wakeup(&ticks);
8010561a:	c7 04 24 c0 65 11 80 	movl   $0x801165c0,(%esp)
80105621:	e8 27 e6 ff ff       	call   80103c4d <wakeup>
      release(&tickslock);
80105626:	c7 04 24 80 5d 11 80 	movl   $0x80115d80,(%esp)
8010562d:	e8 58 ec ff ff       	call   8010428a <release>
80105632:	83 c4 10             	add    $0x10,%esp
80105635:	e9 5d ff ff ff       	jmp    80105597 <trap+0x61>
    ideintr();
8010563a:	e8 34 c7 ff ff       	call   80101d73 <ideintr>
    lapiceoi();
8010563f:	e8 55 cd ff ff       	call   80102399 <lapiceoi>
    break;
80105644:	e9 53 ff ff ff       	jmp    8010559c <trap+0x66>
    kbdintr();
80105649:	e8 8f cb ff ff       	call   801021dd <kbdintr>
    lapiceoi();
8010564e:	e8 46 cd ff ff       	call   80102399 <lapiceoi>
    break;
80105653:	e9 44 ff ff ff       	jmp    8010559c <trap+0x66>
    uartintr();
80105658:	e8 05 02 00 00       	call   80105862 <uartintr>
    lapiceoi();
8010565d:	e8 37 cd ff ff       	call   80102399 <lapiceoi>
    break;
80105662:	e9 35 ff ff ff       	jmp    8010559c <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105667:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
8010566a:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010566e:	e8 f0 db ff ff       	call   80103263 <cpuid>
80105673:	57                   	push   %edi
80105674:	0f b7 f6             	movzwl %si,%esi
80105677:	56                   	push   %esi
80105678:	50                   	push   %eax
80105679:	68 54 73 10 80       	push   $0x80107354
8010567e:	e8 88 af ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105683:	e8 11 cd ff ff       	call   80102399 <lapiceoi>
    break;
80105688:	83 c4 10             	add    $0x10,%esp
8010568b:	e9 0c ff ff ff       	jmp    8010559c <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105690:	e8 e9 db ff ff       	call   8010327e <myproc>
80105695:	85 c0                	test   %eax,%eax
80105697:	74 5f                	je     801056f8 <trap+0x1c2>
80105699:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010569d:	74 59                	je     801056f8 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010569f:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801056a2:	8b 43 38             	mov    0x38(%ebx),%eax
801056a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801056a8:	e8 b6 db ff ff       	call   80103263 <cpuid>
801056ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
801056b0:	8b 53 34             	mov    0x34(%ebx),%edx
801056b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
801056b6:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
801056b9:	e8 c0 db ff ff       	call   8010327e <myproc>
801056be:	8d 48 6c             	lea    0x6c(%eax),%ecx
801056c1:	89 4d d8             	mov    %ecx,-0x28(%ebp)
801056c4:	e8 b5 db ff ff       	call   8010327e <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801056c9:	57                   	push   %edi
801056ca:	ff 75 e4             	pushl  -0x1c(%ebp)
801056cd:	ff 75 e0             	pushl  -0x20(%ebp)
801056d0:	ff 75 dc             	pushl  -0x24(%ebp)
801056d3:	56                   	push   %esi
801056d4:	ff 75 d8             	pushl  -0x28(%ebp)
801056d7:	ff 70 10             	pushl  0x10(%eax)
801056da:	68 ac 73 10 80       	push   $0x801073ac
801056df:	e8 27 af ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
801056e4:	83 c4 20             	add    $0x20,%esp
801056e7:	e8 92 db ff ff       	call   8010327e <myproc>
801056ec:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801056f3:	e9 a4 fe ff ff       	jmp    8010559c <trap+0x66>
801056f8:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801056fb:	8b 73 38             	mov    0x38(%ebx),%esi
801056fe:	e8 60 db ff ff       	call   80103263 <cpuid>
80105703:	83 ec 0c             	sub    $0xc,%esp
80105706:	57                   	push   %edi
80105707:	56                   	push   %esi
80105708:	50                   	push   %eax
80105709:	ff 73 30             	pushl  0x30(%ebx)
8010570c:	68 78 73 10 80       	push   $0x80107378
80105711:	e8 f5 ae ff ff       	call   8010060b <cprintf>
      panic("trap");
80105716:	83 c4 14             	add    $0x14,%esp
80105719:	68 4e 73 10 80       	push   $0x8010734e
8010571e:	e8 25 ac ff ff       	call   80100348 <panic>
    exit();
80105723:	e8 c2 e2 ff ff       	call   801039ea <exit>
80105728:	e9 94 fe ff ff       	jmp    801055c1 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
8010572d:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105731:	0f 85 a2 fe ff ff    	jne    801055d9 <trap+0xa3>
    yield();
80105737:	e8 77 e3 ff ff       	call   80103ab3 <yield>
8010573c:	e9 98 fe ff ff       	jmp    801055d9 <trap+0xa3>
    exit();
80105741:	e8 a4 e2 ff ff       	call   801039ea <exit>
80105746:	e9 b3 fe ff ff       	jmp    801055fe <trap+0xc8>

8010574b <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
8010574b:	55                   	push   %ebp
8010574c:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010574e:	83 3d c4 a9 10 80 00 	cmpl   $0x0,0x8010a9c4
80105755:	74 15                	je     8010576c <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105757:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010575c:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010575d:	a8 01                	test   $0x1,%al
8010575f:	74 12                	je     80105773 <uartgetc+0x28>
80105761:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105766:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105767:	0f b6 c0             	movzbl %al,%eax
}
8010576a:	5d                   	pop    %ebp
8010576b:	c3                   	ret    
    return -1;
8010576c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105771:	eb f7                	jmp    8010576a <uartgetc+0x1f>
    return -1;
80105773:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105778:	eb f0                	jmp    8010576a <uartgetc+0x1f>

8010577a <uartputc>:
  if(!uart)
8010577a:	83 3d c4 a9 10 80 00 	cmpl   $0x0,0x8010a9c4
80105781:	74 3b                	je     801057be <uartputc+0x44>
{
80105783:	55                   	push   %ebp
80105784:	89 e5                	mov    %esp,%ebp
80105786:	53                   	push   %ebx
80105787:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010578a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010578f:	eb 10                	jmp    801057a1 <uartputc+0x27>
    microdelay(10);
80105791:	83 ec 0c             	sub    $0xc,%esp
80105794:	6a 0a                	push   $0xa
80105796:	e8 1d cc ff ff       	call   801023b8 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010579b:	83 c3 01             	add    $0x1,%ebx
8010579e:	83 c4 10             	add    $0x10,%esp
801057a1:	83 fb 7f             	cmp    $0x7f,%ebx
801057a4:	7f 0a                	jg     801057b0 <uartputc+0x36>
801057a6:	ba fd 03 00 00       	mov    $0x3fd,%edx
801057ab:	ec                   	in     (%dx),%al
801057ac:	a8 20                	test   $0x20,%al
801057ae:	74 e1                	je     80105791 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801057b0:	8b 45 08             	mov    0x8(%ebp),%eax
801057b3:	ba f8 03 00 00       	mov    $0x3f8,%edx
801057b8:	ee                   	out    %al,(%dx)
}
801057b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801057bc:	c9                   	leave  
801057bd:	c3                   	ret    
801057be:	f3 c3                	repz ret 

801057c0 <uartinit>:
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	56                   	push   %esi
801057c4:	53                   	push   %ebx
801057c5:	b9 00 00 00 00       	mov    $0x0,%ecx
801057ca:	ba fa 03 00 00       	mov    $0x3fa,%edx
801057cf:	89 c8                	mov    %ecx,%eax
801057d1:	ee                   	out    %al,(%dx)
801057d2:	be fb 03 00 00       	mov    $0x3fb,%esi
801057d7:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801057dc:	89 f2                	mov    %esi,%edx
801057de:	ee                   	out    %al,(%dx)
801057df:	b8 0c 00 00 00       	mov    $0xc,%eax
801057e4:	ba f8 03 00 00       	mov    $0x3f8,%edx
801057e9:	ee                   	out    %al,(%dx)
801057ea:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801057ef:	89 c8                	mov    %ecx,%eax
801057f1:	89 da                	mov    %ebx,%edx
801057f3:	ee                   	out    %al,(%dx)
801057f4:	b8 03 00 00 00       	mov    $0x3,%eax
801057f9:	89 f2                	mov    %esi,%edx
801057fb:	ee                   	out    %al,(%dx)
801057fc:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105801:	89 c8                	mov    %ecx,%eax
80105803:	ee                   	out    %al,(%dx)
80105804:	b8 01 00 00 00       	mov    $0x1,%eax
80105809:	89 da                	mov    %ebx,%edx
8010580b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010580c:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105811:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105812:	3c ff                	cmp    $0xff,%al
80105814:	74 45                	je     8010585b <uartinit+0x9b>
  uart = 1;
80105816:	c7 05 c4 a9 10 80 01 	movl   $0x1,0x8010a9c4
8010581d:	00 00 00 
80105820:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105825:	ec                   	in     (%dx),%al
80105826:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010582b:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
8010582c:	83 ec 08             	sub    $0x8,%esp
8010582f:	6a 00                	push   $0x0
80105831:	6a 04                	push   $0x4
80105833:	e8 46 c7 ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105838:	83 c4 10             	add    $0x10,%esp
8010583b:	bb 70 74 10 80       	mov    $0x80107470,%ebx
80105840:	eb 12                	jmp    80105854 <uartinit+0x94>
    uartputc(*p);
80105842:	83 ec 0c             	sub    $0xc,%esp
80105845:	0f be c0             	movsbl %al,%eax
80105848:	50                   	push   %eax
80105849:	e8 2c ff ff ff       	call   8010577a <uartputc>
  for(p="xv6...\n"; *p; p++)
8010584e:	83 c3 01             	add    $0x1,%ebx
80105851:	83 c4 10             	add    $0x10,%esp
80105854:	0f b6 03             	movzbl (%ebx),%eax
80105857:	84 c0                	test   %al,%al
80105859:	75 e7                	jne    80105842 <uartinit+0x82>
}
8010585b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010585e:	5b                   	pop    %ebx
8010585f:	5e                   	pop    %esi
80105860:	5d                   	pop    %ebp
80105861:	c3                   	ret    

80105862 <uartintr>:

void
uartintr(void)
{
80105862:	55                   	push   %ebp
80105863:	89 e5                	mov    %esp,%ebp
80105865:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105868:	68 4b 57 10 80       	push   $0x8010574b
8010586d:	e8 cc ae ff ff       	call   8010073e <consoleintr>
}
80105872:	83 c4 10             	add    $0x10,%esp
80105875:	c9                   	leave  
80105876:	c3                   	ret    

80105877 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105877:	6a 00                	push   $0x0
  pushl $0
80105879:	6a 00                	push   $0x0
  jmp alltraps
8010587b:	e9 be fb ff ff       	jmp    8010543e <alltraps>

80105880 <vector1>:
.globl vector1
vector1:
  pushl $0
80105880:	6a 00                	push   $0x0
  pushl $1
80105882:	6a 01                	push   $0x1
  jmp alltraps
80105884:	e9 b5 fb ff ff       	jmp    8010543e <alltraps>

80105889 <vector2>:
.globl vector2
vector2:
  pushl $0
80105889:	6a 00                	push   $0x0
  pushl $2
8010588b:	6a 02                	push   $0x2
  jmp alltraps
8010588d:	e9 ac fb ff ff       	jmp    8010543e <alltraps>

80105892 <vector3>:
.globl vector3
vector3:
  pushl $0
80105892:	6a 00                	push   $0x0
  pushl $3
80105894:	6a 03                	push   $0x3
  jmp alltraps
80105896:	e9 a3 fb ff ff       	jmp    8010543e <alltraps>

8010589b <vector4>:
.globl vector4
vector4:
  pushl $0
8010589b:	6a 00                	push   $0x0
  pushl $4
8010589d:	6a 04                	push   $0x4
  jmp alltraps
8010589f:	e9 9a fb ff ff       	jmp    8010543e <alltraps>

801058a4 <vector5>:
.globl vector5
vector5:
  pushl $0
801058a4:	6a 00                	push   $0x0
  pushl $5
801058a6:	6a 05                	push   $0x5
  jmp alltraps
801058a8:	e9 91 fb ff ff       	jmp    8010543e <alltraps>

801058ad <vector6>:
.globl vector6
vector6:
  pushl $0
801058ad:	6a 00                	push   $0x0
  pushl $6
801058af:	6a 06                	push   $0x6
  jmp alltraps
801058b1:	e9 88 fb ff ff       	jmp    8010543e <alltraps>

801058b6 <vector7>:
.globl vector7
vector7:
  pushl $0
801058b6:	6a 00                	push   $0x0
  pushl $7
801058b8:	6a 07                	push   $0x7
  jmp alltraps
801058ba:	e9 7f fb ff ff       	jmp    8010543e <alltraps>

801058bf <vector8>:
.globl vector8
vector8:
  pushl $8
801058bf:	6a 08                	push   $0x8
  jmp alltraps
801058c1:	e9 78 fb ff ff       	jmp    8010543e <alltraps>

801058c6 <vector9>:
.globl vector9
vector9:
  pushl $0
801058c6:	6a 00                	push   $0x0
  pushl $9
801058c8:	6a 09                	push   $0x9
  jmp alltraps
801058ca:	e9 6f fb ff ff       	jmp    8010543e <alltraps>

801058cf <vector10>:
.globl vector10
vector10:
  pushl $10
801058cf:	6a 0a                	push   $0xa
  jmp alltraps
801058d1:	e9 68 fb ff ff       	jmp    8010543e <alltraps>

801058d6 <vector11>:
.globl vector11
vector11:
  pushl $11
801058d6:	6a 0b                	push   $0xb
  jmp alltraps
801058d8:	e9 61 fb ff ff       	jmp    8010543e <alltraps>

801058dd <vector12>:
.globl vector12
vector12:
  pushl $12
801058dd:	6a 0c                	push   $0xc
  jmp alltraps
801058df:	e9 5a fb ff ff       	jmp    8010543e <alltraps>

801058e4 <vector13>:
.globl vector13
vector13:
  pushl $13
801058e4:	6a 0d                	push   $0xd
  jmp alltraps
801058e6:	e9 53 fb ff ff       	jmp    8010543e <alltraps>

801058eb <vector14>:
.globl vector14
vector14:
  pushl $14
801058eb:	6a 0e                	push   $0xe
  jmp alltraps
801058ed:	e9 4c fb ff ff       	jmp    8010543e <alltraps>

801058f2 <vector15>:
.globl vector15
vector15:
  pushl $0
801058f2:	6a 00                	push   $0x0
  pushl $15
801058f4:	6a 0f                	push   $0xf
  jmp alltraps
801058f6:	e9 43 fb ff ff       	jmp    8010543e <alltraps>

801058fb <vector16>:
.globl vector16
vector16:
  pushl $0
801058fb:	6a 00                	push   $0x0
  pushl $16
801058fd:	6a 10                	push   $0x10
  jmp alltraps
801058ff:	e9 3a fb ff ff       	jmp    8010543e <alltraps>

80105904 <vector17>:
.globl vector17
vector17:
  pushl $17
80105904:	6a 11                	push   $0x11
  jmp alltraps
80105906:	e9 33 fb ff ff       	jmp    8010543e <alltraps>

8010590b <vector18>:
.globl vector18
vector18:
  pushl $0
8010590b:	6a 00                	push   $0x0
  pushl $18
8010590d:	6a 12                	push   $0x12
  jmp alltraps
8010590f:	e9 2a fb ff ff       	jmp    8010543e <alltraps>

80105914 <vector19>:
.globl vector19
vector19:
  pushl $0
80105914:	6a 00                	push   $0x0
  pushl $19
80105916:	6a 13                	push   $0x13
  jmp alltraps
80105918:	e9 21 fb ff ff       	jmp    8010543e <alltraps>

8010591d <vector20>:
.globl vector20
vector20:
  pushl $0
8010591d:	6a 00                	push   $0x0
  pushl $20
8010591f:	6a 14                	push   $0x14
  jmp alltraps
80105921:	e9 18 fb ff ff       	jmp    8010543e <alltraps>

80105926 <vector21>:
.globl vector21
vector21:
  pushl $0
80105926:	6a 00                	push   $0x0
  pushl $21
80105928:	6a 15                	push   $0x15
  jmp alltraps
8010592a:	e9 0f fb ff ff       	jmp    8010543e <alltraps>

8010592f <vector22>:
.globl vector22
vector22:
  pushl $0
8010592f:	6a 00                	push   $0x0
  pushl $22
80105931:	6a 16                	push   $0x16
  jmp alltraps
80105933:	e9 06 fb ff ff       	jmp    8010543e <alltraps>

80105938 <vector23>:
.globl vector23
vector23:
  pushl $0
80105938:	6a 00                	push   $0x0
  pushl $23
8010593a:	6a 17                	push   $0x17
  jmp alltraps
8010593c:	e9 fd fa ff ff       	jmp    8010543e <alltraps>

80105941 <vector24>:
.globl vector24
vector24:
  pushl $0
80105941:	6a 00                	push   $0x0
  pushl $24
80105943:	6a 18                	push   $0x18
  jmp alltraps
80105945:	e9 f4 fa ff ff       	jmp    8010543e <alltraps>

8010594a <vector25>:
.globl vector25
vector25:
  pushl $0
8010594a:	6a 00                	push   $0x0
  pushl $25
8010594c:	6a 19                	push   $0x19
  jmp alltraps
8010594e:	e9 eb fa ff ff       	jmp    8010543e <alltraps>

80105953 <vector26>:
.globl vector26
vector26:
  pushl $0
80105953:	6a 00                	push   $0x0
  pushl $26
80105955:	6a 1a                	push   $0x1a
  jmp alltraps
80105957:	e9 e2 fa ff ff       	jmp    8010543e <alltraps>

8010595c <vector27>:
.globl vector27
vector27:
  pushl $0
8010595c:	6a 00                	push   $0x0
  pushl $27
8010595e:	6a 1b                	push   $0x1b
  jmp alltraps
80105960:	e9 d9 fa ff ff       	jmp    8010543e <alltraps>

80105965 <vector28>:
.globl vector28
vector28:
  pushl $0
80105965:	6a 00                	push   $0x0
  pushl $28
80105967:	6a 1c                	push   $0x1c
  jmp alltraps
80105969:	e9 d0 fa ff ff       	jmp    8010543e <alltraps>

8010596e <vector29>:
.globl vector29
vector29:
  pushl $0
8010596e:	6a 00                	push   $0x0
  pushl $29
80105970:	6a 1d                	push   $0x1d
  jmp alltraps
80105972:	e9 c7 fa ff ff       	jmp    8010543e <alltraps>

80105977 <vector30>:
.globl vector30
vector30:
  pushl $0
80105977:	6a 00                	push   $0x0
  pushl $30
80105979:	6a 1e                	push   $0x1e
  jmp alltraps
8010597b:	e9 be fa ff ff       	jmp    8010543e <alltraps>

80105980 <vector31>:
.globl vector31
vector31:
  pushl $0
80105980:	6a 00                	push   $0x0
  pushl $31
80105982:	6a 1f                	push   $0x1f
  jmp alltraps
80105984:	e9 b5 fa ff ff       	jmp    8010543e <alltraps>

80105989 <vector32>:
.globl vector32
vector32:
  pushl $0
80105989:	6a 00                	push   $0x0
  pushl $32
8010598b:	6a 20                	push   $0x20
  jmp alltraps
8010598d:	e9 ac fa ff ff       	jmp    8010543e <alltraps>

80105992 <vector33>:
.globl vector33
vector33:
  pushl $0
80105992:	6a 00                	push   $0x0
  pushl $33
80105994:	6a 21                	push   $0x21
  jmp alltraps
80105996:	e9 a3 fa ff ff       	jmp    8010543e <alltraps>

8010599b <vector34>:
.globl vector34
vector34:
  pushl $0
8010599b:	6a 00                	push   $0x0
  pushl $34
8010599d:	6a 22                	push   $0x22
  jmp alltraps
8010599f:	e9 9a fa ff ff       	jmp    8010543e <alltraps>

801059a4 <vector35>:
.globl vector35
vector35:
  pushl $0
801059a4:	6a 00                	push   $0x0
  pushl $35
801059a6:	6a 23                	push   $0x23
  jmp alltraps
801059a8:	e9 91 fa ff ff       	jmp    8010543e <alltraps>

801059ad <vector36>:
.globl vector36
vector36:
  pushl $0
801059ad:	6a 00                	push   $0x0
  pushl $36
801059af:	6a 24                	push   $0x24
  jmp alltraps
801059b1:	e9 88 fa ff ff       	jmp    8010543e <alltraps>

801059b6 <vector37>:
.globl vector37
vector37:
  pushl $0
801059b6:	6a 00                	push   $0x0
  pushl $37
801059b8:	6a 25                	push   $0x25
  jmp alltraps
801059ba:	e9 7f fa ff ff       	jmp    8010543e <alltraps>

801059bf <vector38>:
.globl vector38
vector38:
  pushl $0
801059bf:	6a 00                	push   $0x0
  pushl $38
801059c1:	6a 26                	push   $0x26
  jmp alltraps
801059c3:	e9 76 fa ff ff       	jmp    8010543e <alltraps>

801059c8 <vector39>:
.globl vector39
vector39:
  pushl $0
801059c8:	6a 00                	push   $0x0
  pushl $39
801059ca:	6a 27                	push   $0x27
  jmp alltraps
801059cc:	e9 6d fa ff ff       	jmp    8010543e <alltraps>

801059d1 <vector40>:
.globl vector40
vector40:
  pushl $0
801059d1:	6a 00                	push   $0x0
  pushl $40
801059d3:	6a 28                	push   $0x28
  jmp alltraps
801059d5:	e9 64 fa ff ff       	jmp    8010543e <alltraps>

801059da <vector41>:
.globl vector41
vector41:
  pushl $0
801059da:	6a 00                	push   $0x0
  pushl $41
801059dc:	6a 29                	push   $0x29
  jmp alltraps
801059de:	e9 5b fa ff ff       	jmp    8010543e <alltraps>

801059e3 <vector42>:
.globl vector42
vector42:
  pushl $0
801059e3:	6a 00                	push   $0x0
  pushl $42
801059e5:	6a 2a                	push   $0x2a
  jmp alltraps
801059e7:	e9 52 fa ff ff       	jmp    8010543e <alltraps>

801059ec <vector43>:
.globl vector43
vector43:
  pushl $0
801059ec:	6a 00                	push   $0x0
  pushl $43
801059ee:	6a 2b                	push   $0x2b
  jmp alltraps
801059f0:	e9 49 fa ff ff       	jmp    8010543e <alltraps>

801059f5 <vector44>:
.globl vector44
vector44:
  pushl $0
801059f5:	6a 00                	push   $0x0
  pushl $44
801059f7:	6a 2c                	push   $0x2c
  jmp alltraps
801059f9:	e9 40 fa ff ff       	jmp    8010543e <alltraps>

801059fe <vector45>:
.globl vector45
vector45:
  pushl $0
801059fe:	6a 00                	push   $0x0
  pushl $45
80105a00:	6a 2d                	push   $0x2d
  jmp alltraps
80105a02:	e9 37 fa ff ff       	jmp    8010543e <alltraps>

80105a07 <vector46>:
.globl vector46
vector46:
  pushl $0
80105a07:	6a 00                	push   $0x0
  pushl $46
80105a09:	6a 2e                	push   $0x2e
  jmp alltraps
80105a0b:	e9 2e fa ff ff       	jmp    8010543e <alltraps>

80105a10 <vector47>:
.globl vector47
vector47:
  pushl $0
80105a10:	6a 00                	push   $0x0
  pushl $47
80105a12:	6a 2f                	push   $0x2f
  jmp alltraps
80105a14:	e9 25 fa ff ff       	jmp    8010543e <alltraps>

80105a19 <vector48>:
.globl vector48
vector48:
  pushl $0
80105a19:	6a 00                	push   $0x0
  pushl $48
80105a1b:	6a 30                	push   $0x30
  jmp alltraps
80105a1d:	e9 1c fa ff ff       	jmp    8010543e <alltraps>

80105a22 <vector49>:
.globl vector49
vector49:
  pushl $0
80105a22:	6a 00                	push   $0x0
  pushl $49
80105a24:	6a 31                	push   $0x31
  jmp alltraps
80105a26:	e9 13 fa ff ff       	jmp    8010543e <alltraps>

80105a2b <vector50>:
.globl vector50
vector50:
  pushl $0
80105a2b:	6a 00                	push   $0x0
  pushl $50
80105a2d:	6a 32                	push   $0x32
  jmp alltraps
80105a2f:	e9 0a fa ff ff       	jmp    8010543e <alltraps>

80105a34 <vector51>:
.globl vector51
vector51:
  pushl $0
80105a34:	6a 00                	push   $0x0
  pushl $51
80105a36:	6a 33                	push   $0x33
  jmp alltraps
80105a38:	e9 01 fa ff ff       	jmp    8010543e <alltraps>

80105a3d <vector52>:
.globl vector52
vector52:
  pushl $0
80105a3d:	6a 00                	push   $0x0
  pushl $52
80105a3f:	6a 34                	push   $0x34
  jmp alltraps
80105a41:	e9 f8 f9 ff ff       	jmp    8010543e <alltraps>

80105a46 <vector53>:
.globl vector53
vector53:
  pushl $0
80105a46:	6a 00                	push   $0x0
  pushl $53
80105a48:	6a 35                	push   $0x35
  jmp alltraps
80105a4a:	e9 ef f9 ff ff       	jmp    8010543e <alltraps>

80105a4f <vector54>:
.globl vector54
vector54:
  pushl $0
80105a4f:	6a 00                	push   $0x0
  pushl $54
80105a51:	6a 36                	push   $0x36
  jmp alltraps
80105a53:	e9 e6 f9 ff ff       	jmp    8010543e <alltraps>

80105a58 <vector55>:
.globl vector55
vector55:
  pushl $0
80105a58:	6a 00                	push   $0x0
  pushl $55
80105a5a:	6a 37                	push   $0x37
  jmp alltraps
80105a5c:	e9 dd f9 ff ff       	jmp    8010543e <alltraps>

80105a61 <vector56>:
.globl vector56
vector56:
  pushl $0
80105a61:	6a 00                	push   $0x0
  pushl $56
80105a63:	6a 38                	push   $0x38
  jmp alltraps
80105a65:	e9 d4 f9 ff ff       	jmp    8010543e <alltraps>

80105a6a <vector57>:
.globl vector57
vector57:
  pushl $0
80105a6a:	6a 00                	push   $0x0
  pushl $57
80105a6c:	6a 39                	push   $0x39
  jmp alltraps
80105a6e:	e9 cb f9 ff ff       	jmp    8010543e <alltraps>

80105a73 <vector58>:
.globl vector58
vector58:
  pushl $0
80105a73:	6a 00                	push   $0x0
  pushl $58
80105a75:	6a 3a                	push   $0x3a
  jmp alltraps
80105a77:	e9 c2 f9 ff ff       	jmp    8010543e <alltraps>

80105a7c <vector59>:
.globl vector59
vector59:
  pushl $0
80105a7c:	6a 00                	push   $0x0
  pushl $59
80105a7e:	6a 3b                	push   $0x3b
  jmp alltraps
80105a80:	e9 b9 f9 ff ff       	jmp    8010543e <alltraps>

80105a85 <vector60>:
.globl vector60
vector60:
  pushl $0
80105a85:	6a 00                	push   $0x0
  pushl $60
80105a87:	6a 3c                	push   $0x3c
  jmp alltraps
80105a89:	e9 b0 f9 ff ff       	jmp    8010543e <alltraps>

80105a8e <vector61>:
.globl vector61
vector61:
  pushl $0
80105a8e:	6a 00                	push   $0x0
  pushl $61
80105a90:	6a 3d                	push   $0x3d
  jmp alltraps
80105a92:	e9 a7 f9 ff ff       	jmp    8010543e <alltraps>

80105a97 <vector62>:
.globl vector62
vector62:
  pushl $0
80105a97:	6a 00                	push   $0x0
  pushl $62
80105a99:	6a 3e                	push   $0x3e
  jmp alltraps
80105a9b:	e9 9e f9 ff ff       	jmp    8010543e <alltraps>

80105aa0 <vector63>:
.globl vector63
vector63:
  pushl $0
80105aa0:	6a 00                	push   $0x0
  pushl $63
80105aa2:	6a 3f                	push   $0x3f
  jmp alltraps
80105aa4:	e9 95 f9 ff ff       	jmp    8010543e <alltraps>

80105aa9 <vector64>:
.globl vector64
vector64:
  pushl $0
80105aa9:	6a 00                	push   $0x0
  pushl $64
80105aab:	6a 40                	push   $0x40
  jmp alltraps
80105aad:	e9 8c f9 ff ff       	jmp    8010543e <alltraps>

80105ab2 <vector65>:
.globl vector65
vector65:
  pushl $0
80105ab2:	6a 00                	push   $0x0
  pushl $65
80105ab4:	6a 41                	push   $0x41
  jmp alltraps
80105ab6:	e9 83 f9 ff ff       	jmp    8010543e <alltraps>

80105abb <vector66>:
.globl vector66
vector66:
  pushl $0
80105abb:	6a 00                	push   $0x0
  pushl $66
80105abd:	6a 42                	push   $0x42
  jmp alltraps
80105abf:	e9 7a f9 ff ff       	jmp    8010543e <alltraps>

80105ac4 <vector67>:
.globl vector67
vector67:
  pushl $0
80105ac4:	6a 00                	push   $0x0
  pushl $67
80105ac6:	6a 43                	push   $0x43
  jmp alltraps
80105ac8:	e9 71 f9 ff ff       	jmp    8010543e <alltraps>

80105acd <vector68>:
.globl vector68
vector68:
  pushl $0
80105acd:	6a 00                	push   $0x0
  pushl $68
80105acf:	6a 44                	push   $0x44
  jmp alltraps
80105ad1:	e9 68 f9 ff ff       	jmp    8010543e <alltraps>

80105ad6 <vector69>:
.globl vector69
vector69:
  pushl $0
80105ad6:	6a 00                	push   $0x0
  pushl $69
80105ad8:	6a 45                	push   $0x45
  jmp alltraps
80105ada:	e9 5f f9 ff ff       	jmp    8010543e <alltraps>

80105adf <vector70>:
.globl vector70
vector70:
  pushl $0
80105adf:	6a 00                	push   $0x0
  pushl $70
80105ae1:	6a 46                	push   $0x46
  jmp alltraps
80105ae3:	e9 56 f9 ff ff       	jmp    8010543e <alltraps>

80105ae8 <vector71>:
.globl vector71
vector71:
  pushl $0
80105ae8:	6a 00                	push   $0x0
  pushl $71
80105aea:	6a 47                	push   $0x47
  jmp alltraps
80105aec:	e9 4d f9 ff ff       	jmp    8010543e <alltraps>

80105af1 <vector72>:
.globl vector72
vector72:
  pushl $0
80105af1:	6a 00                	push   $0x0
  pushl $72
80105af3:	6a 48                	push   $0x48
  jmp alltraps
80105af5:	e9 44 f9 ff ff       	jmp    8010543e <alltraps>

80105afa <vector73>:
.globl vector73
vector73:
  pushl $0
80105afa:	6a 00                	push   $0x0
  pushl $73
80105afc:	6a 49                	push   $0x49
  jmp alltraps
80105afe:	e9 3b f9 ff ff       	jmp    8010543e <alltraps>

80105b03 <vector74>:
.globl vector74
vector74:
  pushl $0
80105b03:	6a 00                	push   $0x0
  pushl $74
80105b05:	6a 4a                	push   $0x4a
  jmp alltraps
80105b07:	e9 32 f9 ff ff       	jmp    8010543e <alltraps>

80105b0c <vector75>:
.globl vector75
vector75:
  pushl $0
80105b0c:	6a 00                	push   $0x0
  pushl $75
80105b0e:	6a 4b                	push   $0x4b
  jmp alltraps
80105b10:	e9 29 f9 ff ff       	jmp    8010543e <alltraps>

80105b15 <vector76>:
.globl vector76
vector76:
  pushl $0
80105b15:	6a 00                	push   $0x0
  pushl $76
80105b17:	6a 4c                	push   $0x4c
  jmp alltraps
80105b19:	e9 20 f9 ff ff       	jmp    8010543e <alltraps>

80105b1e <vector77>:
.globl vector77
vector77:
  pushl $0
80105b1e:	6a 00                	push   $0x0
  pushl $77
80105b20:	6a 4d                	push   $0x4d
  jmp alltraps
80105b22:	e9 17 f9 ff ff       	jmp    8010543e <alltraps>

80105b27 <vector78>:
.globl vector78
vector78:
  pushl $0
80105b27:	6a 00                	push   $0x0
  pushl $78
80105b29:	6a 4e                	push   $0x4e
  jmp alltraps
80105b2b:	e9 0e f9 ff ff       	jmp    8010543e <alltraps>

80105b30 <vector79>:
.globl vector79
vector79:
  pushl $0
80105b30:	6a 00                	push   $0x0
  pushl $79
80105b32:	6a 4f                	push   $0x4f
  jmp alltraps
80105b34:	e9 05 f9 ff ff       	jmp    8010543e <alltraps>

80105b39 <vector80>:
.globl vector80
vector80:
  pushl $0
80105b39:	6a 00                	push   $0x0
  pushl $80
80105b3b:	6a 50                	push   $0x50
  jmp alltraps
80105b3d:	e9 fc f8 ff ff       	jmp    8010543e <alltraps>

80105b42 <vector81>:
.globl vector81
vector81:
  pushl $0
80105b42:	6a 00                	push   $0x0
  pushl $81
80105b44:	6a 51                	push   $0x51
  jmp alltraps
80105b46:	e9 f3 f8 ff ff       	jmp    8010543e <alltraps>

80105b4b <vector82>:
.globl vector82
vector82:
  pushl $0
80105b4b:	6a 00                	push   $0x0
  pushl $82
80105b4d:	6a 52                	push   $0x52
  jmp alltraps
80105b4f:	e9 ea f8 ff ff       	jmp    8010543e <alltraps>

80105b54 <vector83>:
.globl vector83
vector83:
  pushl $0
80105b54:	6a 00                	push   $0x0
  pushl $83
80105b56:	6a 53                	push   $0x53
  jmp alltraps
80105b58:	e9 e1 f8 ff ff       	jmp    8010543e <alltraps>

80105b5d <vector84>:
.globl vector84
vector84:
  pushl $0
80105b5d:	6a 00                	push   $0x0
  pushl $84
80105b5f:	6a 54                	push   $0x54
  jmp alltraps
80105b61:	e9 d8 f8 ff ff       	jmp    8010543e <alltraps>

80105b66 <vector85>:
.globl vector85
vector85:
  pushl $0
80105b66:	6a 00                	push   $0x0
  pushl $85
80105b68:	6a 55                	push   $0x55
  jmp alltraps
80105b6a:	e9 cf f8 ff ff       	jmp    8010543e <alltraps>

80105b6f <vector86>:
.globl vector86
vector86:
  pushl $0
80105b6f:	6a 00                	push   $0x0
  pushl $86
80105b71:	6a 56                	push   $0x56
  jmp alltraps
80105b73:	e9 c6 f8 ff ff       	jmp    8010543e <alltraps>

80105b78 <vector87>:
.globl vector87
vector87:
  pushl $0
80105b78:	6a 00                	push   $0x0
  pushl $87
80105b7a:	6a 57                	push   $0x57
  jmp alltraps
80105b7c:	e9 bd f8 ff ff       	jmp    8010543e <alltraps>

80105b81 <vector88>:
.globl vector88
vector88:
  pushl $0
80105b81:	6a 00                	push   $0x0
  pushl $88
80105b83:	6a 58                	push   $0x58
  jmp alltraps
80105b85:	e9 b4 f8 ff ff       	jmp    8010543e <alltraps>

80105b8a <vector89>:
.globl vector89
vector89:
  pushl $0
80105b8a:	6a 00                	push   $0x0
  pushl $89
80105b8c:	6a 59                	push   $0x59
  jmp alltraps
80105b8e:	e9 ab f8 ff ff       	jmp    8010543e <alltraps>

80105b93 <vector90>:
.globl vector90
vector90:
  pushl $0
80105b93:	6a 00                	push   $0x0
  pushl $90
80105b95:	6a 5a                	push   $0x5a
  jmp alltraps
80105b97:	e9 a2 f8 ff ff       	jmp    8010543e <alltraps>

80105b9c <vector91>:
.globl vector91
vector91:
  pushl $0
80105b9c:	6a 00                	push   $0x0
  pushl $91
80105b9e:	6a 5b                	push   $0x5b
  jmp alltraps
80105ba0:	e9 99 f8 ff ff       	jmp    8010543e <alltraps>

80105ba5 <vector92>:
.globl vector92
vector92:
  pushl $0
80105ba5:	6a 00                	push   $0x0
  pushl $92
80105ba7:	6a 5c                	push   $0x5c
  jmp alltraps
80105ba9:	e9 90 f8 ff ff       	jmp    8010543e <alltraps>

80105bae <vector93>:
.globl vector93
vector93:
  pushl $0
80105bae:	6a 00                	push   $0x0
  pushl $93
80105bb0:	6a 5d                	push   $0x5d
  jmp alltraps
80105bb2:	e9 87 f8 ff ff       	jmp    8010543e <alltraps>

80105bb7 <vector94>:
.globl vector94
vector94:
  pushl $0
80105bb7:	6a 00                	push   $0x0
  pushl $94
80105bb9:	6a 5e                	push   $0x5e
  jmp alltraps
80105bbb:	e9 7e f8 ff ff       	jmp    8010543e <alltraps>

80105bc0 <vector95>:
.globl vector95
vector95:
  pushl $0
80105bc0:	6a 00                	push   $0x0
  pushl $95
80105bc2:	6a 5f                	push   $0x5f
  jmp alltraps
80105bc4:	e9 75 f8 ff ff       	jmp    8010543e <alltraps>

80105bc9 <vector96>:
.globl vector96
vector96:
  pushl $0
80105bc9:	6a 00                	push   $0x0
  pushl $96
80105bcb:	6a 60                	push   $0x60
  jmp alltraps
80105bcd:	e9 6c f8 ff ff       	jmp    8010543e <alltraps>

80105bd2 <vector97>:
.globl vector97
vector97:
  pushl $0
80105bd2:	6a 00                	push   $0x0
  pushl $97
80105bd4:	6a 61                	push   $0x61
  jmp alltraps
80105bd6:	e9 63 f8 ff ff       	jmp    8010543e <alltraps>

80105bdb <vector98>:
.globl vector98
vector98:
  pushl $0
80105bdb:	6a 00                	push   $0x0
  pushl $98
80105bdd:	6a 62                	push   $0x62
  jmp alltraps
80105bdf:	e9 5a f8 ff ff       	jmp    8010543e <alltraps>

80105be4 <vector99>:
.globl vector99
vector99:
  pushl $0
80105be4:	6a 00                	push   $0x0
  pushl $99
80105be6:	6a 63                	push   $0x63
  jmp alltraps
80105be8:	e9 51 f8 ff ff       	jmp    8010543e <alltraps>

80105bed <vector100>:
.globl vector100
vector100:
  pushl $0
80105bed:	6a 00                	push   $0x0
  pushl $100
80105bef:	6a 64                	push   $0x64
  jmp alltraps
80105bf1:	e9 48 f8 ff ff       	jmp    8010543e <alltraps>

80105bf6 <vector101>:
.globl vector101
vector101:
  pushl $0
80105bf6:	6a 00                	push   $0x0
  pushl $101
80105bf8:	6a 65                	push   $0x65
  jmp alltraps
80105bfa:	e9 3f f8 ff ff       	jmp    8010543e <alltraps>

80105bff <vector102>:
.globl vector102
vector102:
  pushl $0
80105bff:	6a 00                	push   $0x0
  pushl $102
80105c01:	6a 66                	push   $0x66
  jmp alltraps
80105c03:	e9 36 f8 ff ff       	jmp    8010543e <alltraps>

80105c08 <vector103>:
.globl vector103
vector103:
  pushl $0
80105c08:	6a 00                	push   $0x0
  pushl $103
80105c0a:	6a 67                	push   $0x67
  jmp alltraps
80105c0c:	e9 2d f8 ff ff       	jmp    8010543e <alltraps>

80105c11 <vector104>:
.globl vector104
vector104:
  pushl $0
80105c11:	6a 00                	push   $0x0
  pushl $104
80105c13:	6a 68                	push   $0x68
  jmp alltraps
80105c15:	e9 24 f8 ff ff       	jmp    8010543e <alltraps>

80105c1a <vector105>:
.globl vector105
vector105:
  pushl $0
80105c1a:	6a 00                	push   $0x0
  pushl $105
80105c1c:	6a 69                	push   $0x69
  jmp alltraps
80105c1e:	e9 1b f8 ff ff       	jmp    8010543e <alltraps>

80105c23 <vector106>:
.globl vector106
vector106:
  pushl $0
80105c23:	6a 00                	push   $0x0
  pushl $106
80105c25:	6a 6a                	push   $0x6a
  jmp alltraps
80105c27:	e9 12 f8 ff ff       	jmp    8010543e <alltraps>

80105c2c <vector107>:
.globl vector107
vector107:
  pushl $0
80105c2c:	6a 00                	push   $0x0
  pushl $107
80105c2e:	6a 6b                	push   $0x6b
  jmp alltraps
80105c30:	e9 09 f8 ff ff       	jmp    8010543e <alltraps>

80105c35 <vector108>:
.globl vector108
vector108:
  pushl $0
80105c35:	6a 00                	push   $0x0
  pushl $108
80105c37:	6a 6c                	push   $0x6c
  jmp alltraps
80105c39:	e9 00 f8 ff ff       	jmp    8010543e <alltraps>

80105c3e <vector109>:
.globl vector109
vector109:
  pushl $0
80105c3e:	6a 00                	push   $0x0
  pushl $109
80105c40:	6a 6d                	push   $0x6d
  jmp alltraps
80105c42:	e9 f7 f7 ff ff       	jmp    8010543e <alltraps>

80105c47 <vector110>:
.globl vector110
vector110:
  pushl $0
80105c47:	6a 00                	push   $0x0
  pushl $110
80105c49:	6a 6e                	push   $0x6e
  jmp alltraps
80105c4b:	e9 ee f7 ff ff       	jmp    8010543e <alltraps>

80105c50 <vector111>:
.globl vector111
vector111:
  pushl $0
80105c50:	6a 00                	push   $0x0
  pushl $111
80105c52:	6a 6f                	push   $0x6f
  jmp alltraps
80105c54:	e9 e5 f7 ff ff       	jmp    8010543e <alltraps>

80105c59 <vector112>:
.globl vector112
vector112:
  pushl $0
80105c59:	6a 00                	push   $0x0
  pushl $112
80105c5b:	6a 70                	push   $0x70
  jmp alltraps
80105c5d:	e9 dc f7 ff ff       	jmp    8010543e <alltraps>

80105c62 <vector113>:
.globl vector113
vector113:
  pushl $0
80105c62:	6a 00                	push   $0x0
  pushl $113
80105c64:	6a 71                	push   $0x71
  jmp alltraps
80105c66:	e9 d3 f7 ff ff       	jmp    8010543e <alltraps>

80105c6b <vector114>:
.globl vector114
vector114:
  pushl $0
80105c6b:	6a 00                	push   $0x0
  pushl $114
80105c6d:	6a 72                	push   $0x72
  jmp alltraps
80105c6f:	e9 ca f7 ff ff       	jmp    8010543e <alltraps>

80105c74 <vector115>:
.globl vector115
vector115:
  pushl $0
80105c74:	6a 00                	push   $0x0
  pushl $115
80105c76:	6a 73                	push   $0x73
  jmp alltraps
80105c78:	e9 c1 f7 ff ff       	jmp    8010543e <alltraps>

80105c7d <vector116>:
.globl vector116
vector116:
  pushl $0
80105c7d:	6a 00                	push   $0x0
  pushl $116
80105c7f:	6a 74                	push   $0x74
  jmp alltraps
80105c81:	e9 b8 f7 ff ff       	jmp    8010543e <alltraps>

80105c86 <vector117>:
.globl vector117
vector117:
  pushl $0
80105c86:	6a 00                	push   $0x0
  pushl $117
80105c88:	6a 75                	push   $0x75
  jmp alltraps
80105c8a:	e9 af f7 ff ff       	jmp    8010543e <alltraps>

80105c8f <vector118>:
.globl vector118
vector118:
  pushl $0
80105c8f:	6a 00                	push   $0x0
  pushl $118
80105c91:	6a 76                	push   $0x76
  jmp alltraps
80105c93:	e9 a6 f7 ff ff       	jmp    8010543e <alltraps>

80105c98 <vector119>:
.globl vector119
vector119:
  pushl $0
80105c98:	6a 00                	push   $0x0
  pushl $119
80105c9a:	6a 77                	push   $0x77
  jmp alltraps
80105c9c:	e9 9d f7 ff ff       	jmp    8010543e <alltraps>

80105ca1 <vector120>:
.globl vector120
vector120:
  pushl $0
80105ca1:	6a 00                	push   $0x0
  pushl $120
80105ca3:	6a 78                	push   $0x78
  jmp alltraps
80105ca5:	e9 94 f7 ff ff       	jmp    8010543e <alltraps>

80105caa <vector121>:
.globl vector121
vector121:
  pushl $0
80105caa:	6a 00                	push   $0x0
  pushl $121
80105cac:	6a 79                	push   $0x79
  jmp alltraps
80105cae:	e9 8b f7 ff ff       	jmp    8010543e <alltraps>

80105cb3 <vector122>:
.globl vector122
vector122:
  pushl $0
80105cb3:	6a 00                	push   $0x0
  pushl $122
80105cb5:	6a 7a                	push   $0x7a
  jmp alltraps
80105cb7:	e9 82 f7 ff ff       	jmp    8010543e <alltraps>

80105cbc <vector123>:
.globl vector123
vector123:
  pushl $0
80105cbc:	6a 00                	push   $0x0
  pushl $123
80105cbe:	6a 7b                	push   $0x7b
  jmp alltraps
80105cc0:	e9 79 f7 ff ff       	jmp    8010543e <alltraps>

80105cc5 <vector124>:
.globl vector124
vector124:
  pushl $0
80105cc5:	6a 00                	push   $0x0
  pushl $124
80105cc7:	6a 7c                	push   $0x7c
  jmp alltraps
80105cc9:	e9 70 f7 ff ff       	jmp    8010543e <alltraps>

80105cce <vector125>:
.globl vector125
vector125:
  pushl $0
80105cce:	6a 00                	push   $0x0
  pushl $125
80105cd0:	6a 7d                	push   $0x7d
  jmp alltraps
80105cd2:	e9 67 f7 ff ff       	jmp    8010543e <alltraps>

80105cd7 <vector126>:
.globl vector126
vector126:
  pushl $0
80105cd7:	6a 00                	push   $0x0
  pushl $126
80105cd9:	6a 7e                	push   $0x7e
  jmp alltraps
80105cdb:	e9 5e f7 ff ff       	jmp    8010543e <alltraps>

80105ce0 <vector127>:
.globl vector127
vector127:
  pushl $0
80105ce0:	6a 00                	push   $0x0
  pushl $127
80105ce2:	6a 7f                	push   $0x7f
  jmp alltraps
80105ce4:	e9 55 f7 ff ff       	jmp    8010543e <alltraps>

80105ce9 <vector128>:
.globl vector128
vector128:
  pushl $0
80105ce9:	6a 00                	push   $0x0
  pushl $128
80105ceb:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105cf0:	e9 49 f7 ff ff       	jmp    8010543e <alltraps>

80105cf5 <vector129>:
.globl vector129
vector129:
  pushl $0
80105cf5:	6a 00                	push   $0x0
  pushl $129
80105cf7:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105cfc:	e9 3d f7 ff ff       	jmp    8010543e <alltraps>

80105d01 <vector130>:
.globl vector130
vector130:
  pushl $0
80105d01:	6a 00                	push   $0x0
  pushl $130
80105d03:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105d08:	e9 31 f7 ff ff       	jmp    8010543e <alltraps>

80105d0d <vector131>:
.globl vector131
vector131:
  pushl $0
80105d0d:	6a 00                	push   $0x0
  pushl $131
80105d0f:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105d14:	e9 25 f7 ff ff       	jmp    8010543e <alltraps>

80105d19 <vector132>:
.globl vector132
vector132:
  pushl $0
80105d19:	6a 00                	push   $0x0
  pushl $132
80105d1b:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105d20:	e9 19 f7 ff ff       	jmp    8010543e <alltraps>

80105d25 <vector133>:
.globl vector133
vector133:
  pushl $0
80105d25:	6a 00                	push   $0x0
  pushl $133
80105d27:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105d2c:	e9 0d f7 ff ff       	jmp    8010543e <alltraps>

80105d31 <vector134>:
.globl vector134
vector134:
  pushl $0
80105d31:	6a 00                	push   $0x0
  pushl $134
80105d33:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105d38:	e9 01 f7 ff ff       	jmp    8010543e <alltraps>

80105d3d <vector135>:
.globl vector135
vector135:
  pushl $0
80105d3d:	6a 00                	push   $0x0
  pushl $135
80105d3f:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105d44:	e9 f5 f6 ff ff       	jmp    8010543e <alltraps>

80105d49 <vector136>:
.globl vector136
vector136:
  pushl $0
80105d49:	6a 00                	push   $0x0
  pushl $136
80105d4b:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105d50:	e9 e9 f6 ff ff       	jmp    8010543e <alltraps>

80105d55 <vector137>:
.globl vector137
vector137:
  pushl $0
80105d55:	6a 00                	push   $0x0
  pushl $137
80105d57:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105d5c:	e9 dd f6 ff ff       	jmp    8010543e <alltraps>

80105d61 <vector138>:
.globl vector138
vector138:
  pushl $0
80105d61:	6a 00                	push   $0x0
  pushl $138
80105d63:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105d68:	e9 d1 f6 ff ff       	jmp    8010543e <alltraps>

80105d6d <vector139>:
.globl vector139
vector139:
  pushl $0
80105d6d:	6a 00                	push   $0x0
  pushl $139
80105d6f:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105d74:	e9 c5 f6 ff ff       	jmp    8010543e <alltraps>

80105d79 <vector140>:
.globl vector140
vector140:
  pushl $0
80105d79:	6a 00                	push   $0x0
  pushl $140
80105d7b:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105d80:	e9 b9 f6 ff ff       	jmp    8010543e <alltraps>

80105d85 <vector141>:
.globl vector141
vector141:
  pushl $0
80105d85:	6a 00                	push   $0x0
  pushl $141
80105d87:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105d8c:	e9 ad f6 ff ff       	jmp    8010543e <alltraps>

80105d91 <vector142>:
.globl vector142
vector142:
  pushl $0
80105d91:	6a 00                	push   $0x0
  pushl $142
80105d93:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105d98:	e9 a1 f6 ff ff       	jmp    8010543e <alltraps>

80105d9d <vector143>:
.globl vector143
vector143:
  pushl $0
80105d9d:	6a 00                	push   $0x0
  pushl $143
80105d9f:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105da4:	e9 95 f6 ff ff       	jmp    8010543e <alltraps>

80105da9 <vector144>:
.globl vector144
vector144:
  pushl $0
80105da9:	6a 00                	push   $0x0
  pushl $144
80105dab:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105db0:	e9 89 f6 ff ff       	jmp    8010543e <alltraps>

80105db5 <vector145>:
.globl vector145
vector145:
  pushl $0
80105db5:	6a 00                	push   $0x0
  pushl $145
80105db7:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105dbc:	e9 7d f6 ff ff       	jmp    8010543e <alltraps>

80105dc1 <vector146>:
.globl vector146
vector146:
  pushl $0
80105dc1:	6a 00                	push   $0x0
  pushl $146
80105dc3:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105dc8:	e9 71 f6 ff ff       	jmp    8010543e <alltraps>

80105dcd <vector147>:
.globl vector147
vector147:
  pushl $0
80105dcd:	6a 00                	push   $0x0
  pushl $147
80105dcf:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105dd4:	e9 65 f6 ff ff       	jmp    8010543e <alltraps>

80105dd9 <vector148>:
.globl vector148
vector148:
  pushl $0
80105dd9:	6a 00                	push   $0x0
  pushl $148
80105ddb:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105de0:	e9 59 f6 ff ff       	jmp    8010543e <alltraps>

80105de5 <vector149>:
.globl vector149
vector149:
  pushl $0
80105de5:	6a 00                	push   $0x0
  pushl $149
80105de7:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105dec:	e9 4d f6 ff ff       	jmp    8010543e <alltraps>

80105df1 <vector150>:
.globl vector150
vector150:
  pushl $0
80105df1:	6a 00                	push   $0x0
  pushl $150
80105df3:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105df8:	e9 41 f6 ff ff       	jmp    8010543e <alltraps>

80105dfd <vector151>:
.globl vector151
vector151:
  pushl $0
80105dfd:	6a 00                	push   $0x0
  pushl $151
80105dff:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105e04:	e9 35 f6 ff ff       	jmp    8010543e <alltraps>

80105e09 <vector152>:
.globl vector152
vector152:
  pushl $0
80105e09:	6a 00                	push   $0x0
  pushl $152
80105e0b:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105e10:	e9 29 f6 ff ff       	jmp    8010543e <alltraps>

80105e15 <vector153>:
.globl vector153
vector153:
  pushl $0
80105e15:	6a 00                	push   $0x0
  pushl $153
80105e17:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105e1c:	e9 1d f6 ff ff       	jmp    8010543e <alltraps>

80105e21 <vector154>:
.globl vector154
vector154:
  pushl $0
80105e21:	6a 00                	push   $0x0
  pushl $154
80105e23:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105e28:	e9 11 f6 ff ff       	jmp    8010543e <alltraps>

80105e2d <vector155>:
.globl vector155
vector155:
  pushl $0
80105e2d:	6a 00                	push   $0x0
  pushl $155
80105e2f:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105e34:	e9 05 f6 ff ff       	jmp    8010543e <alltraps>

80105e39 <vector156>:
.globl vector156
vector156:
  pushl $0
80105e39:	6a 00                	push   $0x0
  pushl $156
80105e3b:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105e40:	e9 f9 f5 ff ff       	jmp    8010543e <alltraps>

80105e45 <vector157>:
.globl vector157
vector157:
  pushl $0
80105e45:	6a 00                	push   $0x0
  pushl $157
80105e47:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105e4c:	e9 ed f5 ff ff       	jmp    8010543e <alltraps>

80105e51 <vector158>:
.globl vector158
vector158:
  pushl $0
80105e51:	6a 00                	push   $0x0
  pushl $158
80105e53:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105e58:	e9 e1 f5 ff ff       	jmp    8010543e <alltraps>

80105e5d <vector159>:
.globl vector159
vector159:
  pushl $0
80105e5d:	6a 00                	push   $0x0
  pushl $159
80105e5f:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105e64:	e9 d5 f5 ff ff       	jmp    8010543e <alltraps>

80105e69 <vector160>:
.globl vector160
vector160:
  pushl $0
80105e69:	6a 00                	push   $0x0
  pushl $160
80105e6b:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105e70:	e9 c9 f5 ff ff       	jmp    8010543e <alltraps>

80105e75 <vector161>:
.globl vector161
vector161:
  pushl $0
80105e75:	6a 00                	push   $0x0
  pushl $161
80105e77:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105e7c:	e9 bd f5 ff ff       	jmp    8010543e <alltraps>

80105e81 <vector162>:
.globl vector162
vector162:
  pushl $0
80105e81:	6a 00                	push   $0x0
  pushl $162
80105e83:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105e88:	e9 b1 f5 ff ff       	jmp    8010543e <alltraps>

80105e8d <vector163>:
.globl vector163
vector163:
  pushl $0
80105e8d:	6a 00                	push   $0x0
  pushl $163
80105e8f:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105e94:	e9 a5 f5 ff ff       	jmp    8010543e <alltraps>

80105e99 <vector164>:
.globl vector164
vector164:
  pushl $0
80105e99:	6a 00                	push   $0x0
  pushl $164
80105e9b:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105ea0:	e9 99 f5 ff ff       	jmp    8010543e <alltraps>

80105ea5 <vector165>:
.globl vector165
vector165:
  pushl $0
80105ea5:	6a 00                	push   $0x0
  pushl $165
80105ea7:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105eac:	e9 8d f5 ff ff       	jmp    8010543e <alltraps>

80105eb1 <vector166>:
.globl vector166
vector166:
  pushl $0
80105eb1:	6a 00                	push   $0x0
  pushl $166
80105eb3:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105eb8:	e9 81 f5 ff ff       	jmp    8010543e <alltraps>

80105ebd <vector167>:
.globl vector167
vector167:
  pushl $0
80105ebd:	6a 00                	push   $0x0
  pushl $167
80105ebf:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105ec4:	e9 75 f5 ff ff       	jmp    8010543e <alltraps>

80105ec9 <vector168>:
.globl vector168
vector168:
  pushl $0
80105ec9:	6a 00                	push   $0x0
  pushl $168
80105ecb:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105ed0:	e9 69 f5 ff ff       	jmp    8010543e <alltraps>

80105ed5 <vector169>:
.globl vector169
vector169:
  pushl $0
80105ed5:	6a 00                	push   $0x0
  pushl $169
80105ed7:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105edc:	e9 5d f5 ff ff       	jmp    8010543e <alltraps>

80105ee1 <vector170>:
.globl vector170
vector170:
  pushl $0
80105ee1:	6a 00                	push   $0x0
  pushl $170
80105ee3:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105ee8:	e9 51 f5 ff ff       	jmp    8010543e <alltraps>

80105eed <vector171>:
.globl vector171
vector171:
  pushl $0
80105eed:	6a 00                	push   $0x0
  pushl $171
80105eef:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105ef4:	e9 45 f5 ff ff       	jmp    8010543e <alltraps>

80105ef9 <vector172>:
.globl vector172
vector172:
  pushl $0
80105ef9:	6a 00                	push   $0x0
  pushl $172
80105efb:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105f00:	e9 39 f5 ff ff       	jmp    8010543e <alltraps>

80105f05 <vector173>:
.globl vector173
vector173:
  pushl $0
80105f05:	6a 00                	push   $0x0
  pushl $173
80105f07:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105f0c:	e9 2d f5 ff ff       	jmp    8010543e <alltraps>

80105f11 <vector174>:
.globl vector174
vector174:
  pushl $0
80105f11:	6a 00                	push   $0x0
  pushl $174
80105f13:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105f18:	e9 21 f5 ff ff       	jmp    8010543e <alltraps>

80105f1d <vector175>:
.globl vector175
vector175:
  pushl $0
80105f1d:	6a 00                	push   $0x0
  pushl $175
80105f1f:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105f24:	e9 15 f5 ff ff       	jmp    8010543e <alltraps>

80105f29 <vector176>:
.globl vector176
vector176:
  pushl $0
80105f29:	6a 00                	push   $0x0
  pushl $176
80105f2b:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105f30:	e9 09 f5 ff ff       	jmp    8010543e <alltraps>

80105f35 <vector177>:
.globl vector177
vector177:
  pushl $0
80105f35:	6a 00                	push   $0x0
  pushl $177
80105f37:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105f3c:	e9 fd f4 ff ff       	jmp    8010543e <alltraps>

80105f41 <vector178>:
.globl vector178
vector178:
  pushl $0
80105f41:	6a 00                	push   $0x0
  pushl $178
80105f43:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105f48:	e9 f1 f4 ff ff       	jmp    8010543e <alltraps>

80105f4d <vector179>:
.globl vector179
vector179:
  pushl $0
80105f4d:	6a 00                	push   $0x0
  pushl $179
80105f4f:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105f54:	e9 e5 f4 ff ff       	jmp    8010543e <alltraps>

80105f59 <vector180>:
.globl vector180
vector180:
  pushl $0
80105f59:	6a 00                	push   $0x0
  pushl $180
80105f5b:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105f60:	e9 d9 f4 ff ff       	jmp    8010543e <alltraps>

80105f65 <vector181>:
.globl vector181
vector181:
  pushl $0
80105f65:	6a 00                	push   $0x0
  pushl $181
80105f67:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105f6c:	e9 cd f4 ff ff       	jmp    8010543e <alltraps>

80105f71 <vector182>:
.globl vector182
vector182:
  pushl $0
80105f71:	6a 00                	push   $0x0
  pushl $182
80105f73:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105f78:	e9 c1 f4 ff ff       	jmp    8010543e <alltraps>

80105f7d <vector183>:
.globl vector183
vector183:
  pushl $0
80105f7d:	6a 00                	push   $0x0
  pushl $183
80105f7f:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105f84:	e9 b5 f4 ff ff       	jmp    8010543e <alltraps>

80105f89 <vector184>:
.globl vector184
vector184:
  pushl $0
80105f89:	6a 00                	push   $0x0
  pushl $184
80105f8b:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105f90:	e9 a9 f4 ff ff       	jmp    8010543e <alltraps>

80105f95 <vector185>:
.globl vector185
vector185:
  pushl $0
80105f95:	6a 00                	push   $0x0
  pushl $185
80105f97:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105f9c:	e9 9d f4 ff ff       	jmp    8010543e <alltraps>

80105fa1 <vector186>:
.globl vector186
vector186:
  pushl $0
80105fa1:	6a 00                	push   $0x0
  pushl $186
80105fa3:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105fa8:	e9 91 f4 ff ff       	jmp    8010543e <alltraps>

80105fad <vector187>:
.globl vector187
vector187:
  pushl $0
80105fad:	6a 00                	push   $0x0
  pushl $187
80105faf:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105fb4:	e9 85 f4 ff ff       	jmp    8010543e <alltraps>

80105fb9 <vector188>:
.globl vector188
vector188:
  pushl $0
80105fb9:	6a 00                	push   $0x0
  pushl $188
80105fbb:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105fc0:	e9 79 f4 ff ff       	jmp    8010543e <alltraps>

80105fc5 <vector189>:
.globl vector189
vector189:
  pushl $0
80105fc5:	6a 00                	push   $0x0
  pushl $189
80105fc7:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105fcc:	e9 6d f4 ff ff       	jmp    8010543e <alltraps>

80105fd1 <vector190>:
.globl vector190
vector190:
  pushl $0
80105fd1:	6a 00                	push   $0x0
  pushl $190
80105fd3:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105fd8:	e9 61 f4 ff ff       	jmp    8010543e <alltraps>

80105fdd <vector191>:
.globl vector191
vector191:
  pushl $0
80105fdd:	6a 00                	push   $0x0
  pushl $191
80105fdf:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105fe4:	e9 55 f4 ff ff       	jmp    8010543e <alltraps>

80105fe9 <vector192>:
.globl vector192
vector192:
  pushl $0
80105fe9:	6a 00                	push   $0x0
  pushl $192
80105feb:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105ff0:	e9 49 f4 ff ff       	jmp    8010543e <alltraps>

80105ff5 <vector193>:
.globl vector193
vector193:
  pushl $0
80105ff5:	6a 00                	push   $0x0
  pushl $193
80105ff7:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105ffc:	e9 3d f4 ff ff       	jmp    8010543e <alltraps>

80106001 <vector194>:
.globl vector194
vector194:
  pushl $0
80106001:	6a 00                	push   $0x0
  pushl $194
80106003:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106008:	e9 31 f4 ff ff       	jmp    8010543e <alltraps>

8010600d <vector195>:
.globl vector195
vector195:
  pushl $0
8010600d:	6a 00                	push   $0x0
  pushl $195
8010600f:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106014:	e9 25 f4 ff ff       	jmp    8010543e <alltraps>

80106019 <vector196>:
.globl vector196
vector196:
  pushl $0
80106019:	6a 00                	push   $0x0
  pushl $196
8010601b:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106020:	e9 19 f4 ff ff       	jmp    8010543e <alltraps>

80106025 <vector197>:
.globl vector197
vector197:
  pushl $0
80106025:	6a 00                	push   $0x0
  pushl $197
80106027:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
8010602c:	e9 0d f4 ff ff       	jmp    8010543e <alltraps>

80106031 <vector198>:
.globl vector198
vector198:
  pushl $0
80106031:	6a 00                	push   $0x0
  pushl $198
80106033:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106038:	e9 01 f4 ff ff       	jmp    8010543e <alltraps>

8010603d <vector199>:
.globl vector199
vector199:
  pushl $0
8010603d:	6a 00                	push   $0x0
  pushl $199
8010603f:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106044:	e9 f5 f3 ff ff       	jmp    8010543e <alltraps>

80106049 <vector200>:
.globl vector200
vector200:
  pushl $0
80106049:	6a 00                	push   $0x0
  pushl $200
8010604b:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106050:	e9 e9 f3 ff ff       	jmp    8010543e <alltraps>

80106055 <vector201>:
.globl vector201
vector201:
  pushl $0
80106055:	6a 00                	push   $0x0
  pushl $201
80106057:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010605c:	e9 dd f3 ff ff       	jmp    8010543e <alltraps>

80106061 <vector202>:
.globl vector202
vector202:
  pushl $0
80106061:	6a 00                	push   $0x0
  pushl $202
80106063:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106068:	e9 d1 f3 ff ff       	jmp    8010543e <alltraps>

8010606d <vector203>:
.globl vector203
vector203:
  pushl $0
8010606d:	6a 00                	push   $0x0
  pushl $203
8010606f:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106074:	e9 c5 f3 ff ff       	jmp    8010543e <alltraps>

80106079 <vector204>:
.globl vector204
vector204:
  pushl $0
80106079:	6a 00                	push   $0x0
  pushl $204
8010607b:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106080:	e9 b9 f3 ff ff       	jmp    8010543e <alltraps>

80106085 <vector205>:
.globl vector205
vector205:
  pushl $0
80106085:	6a 00                	push   $0x0
  pushl $205
80106087:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010608c:	e9 ad f3 ff ff       	jmp    8010543e <alltraps>

80106091 <vector206>:
.globl vector206
vector206:
  pushl $0
80106091:	6a 00                	push   $0x0
  pushl $206
80106093:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106098:	e9 a1 f3 ff ff       	jmp    8010543e <alltraps>

8010609d <vector207>:
.globl vector207
vector207:
  pushl $0
8010609d:	6a 00                	push   $0x0
  pushl $207
8010609f:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801060a4:	e9 95 f3 ff ff       	jmp    8010543e <alltraps>

801060a9 <vector208>:
.globl vector208
vector208:
  pushl $0
801060a9:	6a 00                	push   $0x0
  pushl $208
801060ab:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801060b0:	e9 89 f3 ff ff       	jmp    8010543e <alltraps>

801060b5 <vector209>:
.globl vector209
vector209:
  pushl $0
801060b5:	6a 00                	push   $0x0
  pushl $209
801060b7:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801060bc:	e9 7d f3 ff ff       	jmp    8010543e <alltraps>

801060c1 <vector210>:
.globl vector210
vector210:
  pushl $0
801060c1:	6a 00                	push   $0x0
  pushl $210
801060c3:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801060c8:	e9 71 f3 ff ff       	jmp    8010543e <alltraps>

801060cd <vector211>:
.globl vector211
vector211:
  pushl $0
801060cd:	6a 00                	push   $0x0
  pushl $211
801060cf:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801060d4:	e9 65 f3 ff ff       	jmp    8010543e <alltraps>

801060d9 <vector212>:
.globl vector212
vector212:
  pushl $0
801060d9:	6a 00                	push   $0x0
  pushl $212
801060db:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801060e0:	e9 59 f3 ff ff       	jmp    8010543e <alltraps>

801060e5 <vector213>:
.globl vector213
vector213:
  pushl $0
801060e5:	6a 00                	push   $0x0
  pushl $213
801060e7:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801060ec:	e9 4d f3 ff ff       	jmp    8010543e <alltraps>

801060f1 <vector214>:
.globl vector214
vector214:
  pushl $0
801060f1:	6a 00                	push   $0x0
  pushl $214
801060f3:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801060f8:	e9 41 f3 ff ff       	jmp    8010543e <alltraps>

801060fd <vector215>:
.globl vector215
vector215:
  pushl $0
801060fd:	6a 00                	push   $0x0
  pushl $215
801060ff:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106104:	e9 35 f3 ff ff       	jmp    8010543e <alltraps>

80106109 <vector216>:
.globl vector216
vector216:
  pushl $0
80106109:	6a 00                	push   $0x0
  pushl $216
8010610b:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106110:	e9 29 f3 ff ff       	jmp    8010543e <alltraps>

80106115 <vector217>:
.globl vector217
vector217:
  pushl $0
80106115:	6a 00                	push   $0x0
  pushl $217
80106117:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
8010611c:	e9 1d f3 ff ff       	jmp    8010543e <alltraps>

80106121 <vector218>:
.globl vector218
vector218:
  pushl $0
80106121:	6a 00                	push   $0x0
  pushl $218
80106123:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106128:	e9 11 f3 ff ff       	jmp    8010543e <alltraps>

8010612d <vector219>:
.globl vector219
vector219:
  pushl $0
8010612d:	6a 00                	push   $0x0
  pushl $219
8010612f:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106134:	e9 05 f3 ff ff       	jmp    8010543e <alltraps>

80106139 <vector220>:
.globl vector220
vector220:
  pushl $0
80106139:	6a 00                	push   $0x0
  pushl $220
8010613b:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106140:	e9 f9 f2 ff ff       	jmp    8010543e <alltraps>

80106145 <vector221>:
.globl vector221
vector221:
  pushl $0
80106145:	6a 00                	push   $0x0
  pushl $221
80106147:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010614c:	e9 ed f2 ff ff       	jmp    8010543e <alltraps>

80106151 <vector222>:
.globl vector222
vector222:
  pushl $0
80106151:	6a 00                	push   $0x0
  pushl $222
80106153:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106158:	e9 e1 f2 ff ff       	jmp    8010543e <alltraps>

8010615d <vector223>:
.globl vector223
vector223:
  pushl $0
8010615d:	6a 00                	push   $0x0
  pushl $223
8010615f:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106164:	e9 d5 f2 ff ff       	jmp    8010543e <alltraps>

80106169 <vector224>:
.globl vector224
vector224:
  pushl $0
80106169:	6a 00                	push   $0x0
  pushl $224
8010616b:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106170:	e9 c9 f2 ff ff       	jmp    8010543e <alltraps>

80106175 <vector225>:
.globl vector225
vector225:
  pushl $0
80106175:	6a 00                	push   $0x0
  pushl $225
80106177:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010617c:	e9 bd f2 ff ff       	jmp    8010543e <alltraps>

80106181 <vector226>:
.globl vector226
vector226:
  pushl $0
80106181:	6a 00                	push   $0x0
  pushl $226
80106183:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106188:	e9 b1 f2 ff ff       	jmp    8010543e <alltraps>

8010618d <vector227>:
.globl vector227
vector227:
  pushl $0
8010618d:	6a 00                	push   $0x0
  pushl $227
8010618f:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106194:	e9 a5 f2 ff ff       	jmp    8010543e <alltraps>

80106199 <vector228>:
.globl vector228
vector228:
  pushl $0
80106199:	6a 00                	push   $0x0
  pushl $228
8010619b:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801061a0:	e9 99 f2 ff ff       	jmp    8010543e <alltraps>

801061a5 <vector229>:
.globl vector229
vector229:
  pushl $0
801061a5:	6a 00                	push   $0x0
  pushl $229
801061a7:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801061ac:	e9 8d f2 ff ff       	jmp    8010543e <alltraps>

801061b1 <vector230>:
.globl vector230
vector230:
  pushl $0
801061b1:	6a 00                	push   $0x0
  pushl $230
801061b3:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801061b8:	e9 81 f2 ff ff       	jmp    8010543e <alltraps>

801061bd <vector231>:
.globl vector231
vector231:
  pushl $0
801061bd:	6a 00                	push   $0x0
  pushl $231
801061bf:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801061c4:	e9 75 f2 ff ff       	jmp    8010543e <alltraps>

801061c9 <vector232>:
.globl vector232
vector232:
  pushl $0
801061c9:	6a 00                	push   $0x0
  pushl $232
801061cb:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801061d0:	e9 69 f2 ff ff       	jmp    8010543e <alltraps>

801061d5 <vector233>:
.globl vector233
vector233:
  pushl $0
801061d5:	6a 00                	push   $0x0
  pushl $233
801061d7:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801061dc:	e9 5d f2 ff ff       	jmp    8010543e <alltraps>

801061e1 <vector234>:
.globl vector234
vector234:
  pushl $0
801061e1:	6a 00                	push   $0x0
  pushl $234
801061e3:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801061e8:	e9 51 f2 ff ff       	jmp    8010543e <alltraps>

801061ed <vector235>:
.globl vector235
vector235:
  pushl $0
801061ed:	6a 00                	push   $0x0
  pushl $235
801061ef:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801061f4:	e9 45 f2 ff ff       	jmp    8010543e <alltraps>

801061f9 <vector236>:
.globl vector236
vector236:
  pushl $0
801061f9:	6a 00                	push   $0x0
  pushl $236
801061fb:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106200:	e9 39 f2 ff ff       	jmp    8010543e <alltraps>

80106205 <vector237>:
.globl vector237
vector237:
  pushl $0
80106205:	6a 00                	push   $0x0
  pushl $237
80106207:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010620c:	e9 2d f2 ff ff       	jmp    8010543e <alltraps>

80106211 <vector238>:
.globl vector238
vector238:
  pushl $0
80106211:	6a 00                	push   $0x0
  pushl $238
80106213:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106218:	e9 21 f2 ff ff       	jmp    8010543e <alltraps>

8010621d <vector239>:
.globl vector239
vector239:
  pushl $0
8010621d:	6a 00                	push   $0x0
  pushl $239
8010621f:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106224:	e9 15 f2 ff ff       	jmp    8010543e <alltraps>

80106229 <vector240>:
.globl vector240
vector240:
  pushl $0
80106229:	6a 00                	push   $0x0
  pushl $240
8010622b:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106230:	e9 09 f2 ff ff       	jmp    8010543e <alltraps>

80106235 <vector241>:
.globl vector241
vector241:
  pushl $0
80106235:	6a 00                	push   $0x0
  pushl $241
80106237:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010623c:	e9 fd f1 ff ff       	jmp    8010543e <alltraps>

80106241 <vector242>:
.globl vector242
vector242:
  pushl $0
80106241:	6a 00                	push   $0x0
  pushl $242
80106243:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106248:	e9 f1 f1 ff ff       	jmp    8010543e <alltraps>

8010624d <vector243>:
.globl vector243
vector243:
  pushl $0
8010624d:	6a 00                	push   $0x0
  pushl $243
8010624f:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106254:	e9 e5 f1 ff ff       	jmp    8010543e <alltraps>

80106259 <vector244>:
.globl vector244
vector244:
  pushl $0
80106259:	6a 00                	push   $0x0
  pushl $244
8010625b:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106260:	e9 d9 f1 ff ff       	jmp    8010543e <alltraps>

80106265 <vector245>:
.globl vector245
vector245:
  pushl $0
80106265:	6a 00                	push   $0x0
  pushl $245
80106267:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010626c:	e9 cd f1 ff ff       	jmp    8010543e <alltraps>

80106271 <vector246>:
.globl vector246
vector246:
  pushl $0
80106271:	6a 00                	push   $0x0
  pushl $246
80106273:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106278:	e9 c1 f1 ff ff       	jmp    8010543e <alltraps>

8010627d <vector247>:
.globl vector247
vector247:
  pushl $0
8010627d:	6a 00                	push   $0x0
  pushl $247
8010627f:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106284:	e9 b5 f1 ff ff       	jmp    8010543e <alltraps>

80106289 <vector248>:
.globl vector248
vector248:
  pushl $0
80106289:	6a 00                	push   $0x0
  pushl $248
8010628b:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106290:	e9 a9 f1 ff ff       	jmp    8010543e <alltraps>

80106295 <vector249>:
.globl vector249
vector249:
  pushl $0
80106295:	6a 00                	push   $0x0
  pushl $249
80106297:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010629c:	e9 9d f1 ff ff       	jmp    8010543e <alltraps>

801062a1 <vector250>:
.globl vector250
vector250:
  pushl $0
801062a1:	6a 00                	push   $0x0
  pushl $250
801062a3:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801062a8:	e9 91 f1 ff ff       	jmp    8010543e <alltraps>

801062ad <vector251>:
.globl vector251
vector251:
  pushl $0
801062ad:	6a 00                	push   $0x0
  pushl $251
801062af:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801062b4:	e9 85 f1 ff ff       	jmp    8010543e <alltraps>

801062b9 <vector252>:
.globl vector252
vector252:
  pushl $0
801062b9:	6a 00                	push   $0x0
  pushl $252
801062bb:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801062c0:	e9 79 f1 ff ff       	jmp    8010543e <alltraps>

801062c5 <vector253>:
.globl vector253
vector253:
  pushl $0
801062c5:	6a 00                	push   $0x0
  pushl $253
801062c7:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801062cc:	e9 6d f1 ff ff       	jmp    8010543e <alltraps>

801062d1 <vector254>:
.globl vector254
vector254:
  pushl $0
801062d1:	6a 00                	push   $0x0
  pushl $254
801062d3:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801062d8:	e9 61 f1 ff ff       	jmp    8010543e <alltraps>

801062dd <vector255>:
.globl vector255
vector255:
  pushl $0
801062dd:	6a 00                	push   $0x0
  pushl $255
801062df:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801062e4:	e9 55 f1 ff ff       	jmp    8010543e <alltraps>

801062e9 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801062e9:	55                   	push   %ebp
801062ea:	89 e5                	mov    %esp,%ebp
801062ec:	57                   	push   %edi
801062ed:	56                   	push   %esi
801062ee:	53                   	push   %ebx
801062ef:	83 ec 0c             	sub    $0xc,%esp
801062f2:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801062f4:	c1 ea 16             	shr    $0x16,%edx
801062f7:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
801062fa:	8b 1f                	mov    (%edi),%ebx
801062fc:	f6 c3 01             	test   $0x1,%bl
801062ff:	74 22                	je     80106323 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106301:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106307:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
8010630d:	c1 ee 0c             	shr    $0xc,%esi
80106310:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80106316:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80106319:	89 d8                	mov    %ebx,%eax
8010631b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010631e:	5b                   	pop    %ebx
8010631f:	5e                   	pop    %esi
80106320:	5f                   	pop    %edi
80106321:	5d                   	pop    %ebp
80106322:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106323:	85 c9                	test   %ecx,%ecx
80106325:	74 2b                	je     80106352 <walkpgdir+0x69>
80106327:	e8 8f bd ff ff       	call   801020bb <kalloc>
8010632c:	89 c3                	mov    %eax,%ebx
8010632e:	85 c0                	test   %eax,%eax
80106330:	74 e7                	je     80106319 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80106332:	83 ec 04             	sub    $0x4,%esp
80106335:	68 00 10 00 00       	push   $0x1000
8010633a:	6a 00                	push   $0x0
8010633c:	50                   	push   %eax
8010633d:	e8 8f df ff ff       	call   801042d1 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106342:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106348:	83 c8 07             	or     $0x7,%eax
8010634b:	89 07                	mov    %eax,(%edi)
8010634d:	83 c4 10             	add    $0x10,%esp
80106350:	eb bb                	jmp    8010630d <walkpgdir+0x24>
      return 0;
80106352:	bb 00 00 00 00       	mov    $0x0,%ebx
80106357:	eb c0                	jmp    80106319 <walkpgdir+0x30>

80106359 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106359:	55                   	push   %ebp
8010635a:	89 e5                	mov    %esp,%ebp
8010635c:	57                   	push   %edi
8010635d:	56                   	push   %esi
8010635e:	53                   	push   %ebx
8010635f:	83 ec 1c             	sub    $0x1c,%esp
80106362:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106365:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80106368:	89 d3                	mov    %edx,%ebx
8010636a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106370:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80106374:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010637a:	b9 01 00 00 00       	mov    $0x1,%ecx
8010637f:	89 da                	mov    %ebx,%edx
80106381:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106384:	e8 60 ff ff ff       	call   801062e9 <walkpgdir>
80106389:	85 c0                	test   %eax,%eax
8010638b:	74 2e                	je     801063bb <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
8010638d:	f6 00 01             	testb  $0x1,(%eax)
80106390:	75 1c                	jne    801063ae <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106392:	89 f2                	mov    %esi,%edx
80106394:	0b 55 0c             	or     0xc(%ebp),%edx
80106397:	83 ca 01             	or     $0x1,%edx
8010639a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010639c:	39 fb                	cmp    %edi,%ebx
8010639e:	74 28                	je     801063c8 <mappages+0x6f>
      break;
    a += PGSIZE;
801063a0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
801063a6:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801063ac:	eb cc                	jmp    8010637a <mappages+0x21>
      panic("remap");
801063ae:	83 ec 0c             	sub    $0xc,%esp
801063b1:	68 78 74 10 80       	push   $0x80107478
801063b6:	e8 8d 9f ff ff       	call   80100348 <panic>
      return -1;
801063bb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
801063c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801063c3:	5b                   	pop    %ebx
801063c4:	5e                   	pop    %esi
801063c5:	5f                   	pop    %edi
801063c6:	5d                   	pop    %ebp
801063c7:	c3                   	ret    
  return 0;
801063c8:	b8 00 00 00 00       	mov    $0x0,%eax
801063cd:	eb f1                	jmp    801063c0 <mappages+0x67>

801063cf <seginit>:
{
801063cf:	55                   	push   %ebp
801063d0:	89 e5                	mov    %esp,%ebp
801063d2:	53                   	push   %ebx
801063d3:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
801063d6:	e8 88 ce ff ff       	call   80103263 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801063db:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801063e1:	66 c7 80 18 2c 11 80 	movw   $0xffff,-0x7feed3e8(%eax)
801063e8:	ff ff 
801063ea:	66 c7 80 1a 2c 11 80 	movw   $0x0,-0x7feed3e6(%eax)
801063f1:	00 00 
801063f3:	c6 80 1c 2c 11 80 00 	movb   $0x0,-0x7feed3e4(%eax)
801063fa:	0f b6 88 1d 2c 11 80 	movzbl -0x7feed3e3(%eax),%ecx
80106401:	83 e1 f0             	and    $0xfffffff0,%ecx
80106404:	83 c9 1a             	or     $0x1a,%ecx
80106407:	83 e1 9f             	and    $0xffffff9f,%ecx
8010640a:	83 c9 80             	or     $0xffffff80,%ecx
8010640d:	88 88 1d 2c 11 80    	mov    %cl,-0x7feed3e3(%eax)
80106413:	0f b6 88 1e 2c 11 80 	movzbl -0x7feed3e2(%eax),%ecx
8010641a:	83 c9 0f             	or     $0xf,%ecx
8010641d:	83 e1 cf             	and    $0xffffffcf,%ecx
80106420:	83 c9 c0             	or     $0xffffffc0,%ecx
80106423:	88 88 1e 2c 11 80    	mov    %cl,-0x7feed3e2(%eax)
80106429:	c6 80 1f 2c 11 80 00 	movb   $0x0,-0x7feed3e1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106430:	66 c7 80 20 2c 11 80 	movw   $0xffff,-0x7feed3e0(%eax)
80106437:	ff ff 
80106439:	66 c7 80 22 2c 11 80 	movw   $0x0,-0x7feed3de(%eax)
80106440:	00 00 
80106442:	c6 80 24 2c 11 80 00 	movb   $0x0,-0x7feed3dc(%eax)
80106449:	0f b6 88 25 2c 11 80 	movzbl -0x7feed3db(%eax),%ecx
80106450:	83 e1 f0             	and    $0xfffffff0,%ecx
80106453:	83 c9 12             	or     $0x12,%ecx
80106456:	83 e1 9f             	and    $0xffffff9f,%ecx
80106459:	83 c9 80             	or     $0xffffff80,%ecx
8010645c:	88 88 25 2c 11 80    	mov    %cl,-0x7feed3db(%eax)
80106462:	0f b6 88 26 2c 11 80 	movzbl -0x7feed3da(%eax),%ecx
80106469:	83 c9 0f             	or     $0xf,%ecx
8010646c:	83 e1 cf             	and    $0xffffffcf,%ecx
8010646f:	83 c9 c0             	or     $0xffffffc0,%ecx
80106472:	88 88 26 2c 11 80    	mov    %cl,-0x7feed3da(%eax)
80106478:	c6 80 27 2c 11 80 00 	movb   $0x0,-0x7feed3d9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010647f:	66 c7 80 28 2c 11 80 	movw   $0xffff,-0x7feed3d8(%eax)
80106486:	ff ff 
80106488:	66 c7 80 2a 2c 11 80 	movw   $0x0,-0x7feed3d6(%eax)
8010648f:	00 00 
80106491:	c6 80 2c 2c 11 80 00 	movb   $0x0,-0x7feed3d4(%eax)
80106498:	c6 80 2d 2c 11 80 fa 	movb   $0xfa,-0x7feed3d3(%eax)
8010649f:	0f b6 88 2e 2c 11 80 	movzbl -0x7feed3d2(%eax),%ecx
801064a6:	83 c9 0f             	or     $0xf,%ecx
801064a9:	83 e1 cf             	and    $0xffffffcf,%ecx
801064ac:	83 c9 c0             	or     $0xffffffc0,%ecx
801064af:	88 88 2e 2c 11 80    	mov    %cl,-0x7feed3d2(%eax)
801064b5:	c6 80 2f 2c 11 80 00 	movb   $0x0,-0x7feed3d1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801064bc:	66 c7 80 30 2c 11 80 	movw   $0xffff,-0x7feed3d0(%eax)
801064c3:	ff ff 
801064c5:	66 c7 80 32 2c 11 80 	movw   $0x0,-0x7feed3ce(%eax)
801064cc:	00 00 
801064ce:	c6 80 34 2c 11 80 00 	movb   $0x0,-0x7feed3cc(%eax)
801064d5:	c6 80 35 2c 11 80 f2 	movb   $0xf2,-0x7feed3cb(%eax)
801064dc:	0f b6 88 36 2c 11 80 	movzbl -0x7feed3ca(%eax),%ecx
801064e3:	83 c9 0f             	or     $0xf,%ecx
801064e6:	83 e1 cf             	and    $0xffffffcf,%ecx
801064e9:	83 c9 c0             	or     $0xffffffc0,%ecx
801064ec:	88 88 36 2c 11 80    	mov    %cl,-0x7feed3ca(%eax)
801064f2:	c6 80 37 2c 11 80 00 	movb   $0x0,-0x7feed3c9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801064f9:	05 10 2c 11 80       	add    $0x80112c10,%eax
  pd[0] = size-1;
801064fe:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106504:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106508:	c1 e8 10             	shr    $0x10,%eax
8010650b:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010650f:	8d 45 f2             	lea    -0xe(%ebp),%eax
80106512:	0f 01 10             	lgdtl  (%eax)
}
80106515:	83 c4 14             	add    $0x14,%esp
80106518:	5b                   	pop    %ebx
80106519:	5d                   	pop    %ebp
8010651a:	c3                   	ret    

8010651b <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010651b:	55                   	push   %ebp
8010651c:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
8010651e:	a1 c4 65 11 80       	mov    0x801165c4,%eax
80106523:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106528:	0f 22 d8             	mov    %eax,%cr3
}
8010652b:	5d                   	pop    %ebp
8010652c:	c3                   	ret    

8010652d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010652d:	55                   	push   %ebp
8010652e:	89 e5                	mov    %esp,%ebp
80106530:	57                   	push   %edi
80106531:	56                   	push   %esi
80106532:	53                   	push   %ebx
80106533:	83 ec 1c             	sub    $0x1c,%esp
80106536:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106539:	85 f6                	test   %esi,%esi
8010653b:	0f 84 dd 00 00 00    	je     8010661e <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106541:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80106545:	0f 84 e0 00 00 00    	je     8010662b <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
8010654b:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
8010654f:	0f 84 e3 00 00 00    	je     80106638 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80106555:	e8 ee db ff ff       	call   80104148 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010655a:	e8 a8 cc ff ff       	call   80103207 <mycpu>
8010655f:	89 c3                	mov    %eax,%ebx
80106561:	e8 a1 cc ff ff       	call   80103207 <mycpu>
80106566:	8d 78 08             	lea    0x8(%eax),%edi
80106569:	e8 99 cc ff ff       	call   80103207 <mycpu>
8010656e:	83 c0 08             	add    $0x8,%eax
80106571:	c1 e8 10             	shr    $0x10,%eax
80106574:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106577:	e8 8b cc ff ff       	call   80103207 <mycpu>
8010657c:	83 c0 08             	add    $0x8,%eax
8010657f:	c1 e8 18             	shr    $0x18,%eax
80106582:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106589:	67 00 
8010658b:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106592:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106596:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010659c:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
801065a3:	83 e2 f0             	and    $0xfffffff0,%edx
801065a6:	83 ca 19             	or     $0x19,%edx
801065a9:	83 e2 9f             	and    $0xffffff9f,%edx
801065ac:	83 ca 80             	or     $0xffffff80,%edx
801065af:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801065b5:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
801065bc:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801065c2:	e8 40 cc ff ff       	call   80103207 <mycpu>
801065c7:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801065ce:	83 e2 ef             	and    $0xffffffef,%edx
801065d1:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801065d7:	e8 2b cc ff ff       	call   80103207 <mycpu>
801065dc:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801065e2:	8b 5e 08             	mov    0x8(%esi),%ebx
801065e5:	e8 1d cc ff ff       	call   80103207 <mycpu>
801065ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801065f0:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801065f3:	e8 0f cc ff ff       	call   80103207 <mycpu>
801065f8:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801065fe:	b8 28 00 00 00       	mov    $0x28,%eax
80106603:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106606:	8b 46 04             	mov    0x4(%esi),%eax
80106609:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010660e:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80106611:	e8 6f db ff ff       	call   80104185 <popcli>
}
80106616:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106619:	5b                   	pop    %ebx
8010661a:	5e                   	pop    %esi
8010661b:	5f                   	pop    %edi
8010661c:	5d                   	pop    %ebp
8010661d:	c3                   	ret    
    panic("switchuvm: no process");
8010661e:	83 ec 0c             	sub    $0xc,%esp
80106621:	68 7e 74 10 80       	push   $0x8010747e
80106626:	e8 1d 9d ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
8010662b:	83 ec 0c             	sub    $0xc,%esp
8010662e:	68 94 74 10 80       	push   $0x80107494
80106633:	e8 10 9d ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106638:	83 ec 0c             	sub    $0xc,%esp
8010663b:	68 a9 74 10 80       	push   $0x801074a9
80106640:	e8 03 9d ff ff       	call   80100348 <panic>

80106645 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80106645:	55                   	push   %ebp
80106646:	89 e5                	mov    %esp,%ebp
80106648:	56                   	push   %esi
80106649:	53                   	push   %ebx
8010664a:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
8010664d:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106653:	77 4c                	ja     801066a1 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80106655:	e8 61 ba ff ff       	call   801020bb <kalloc>
8010665a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010665c:	83 ec 04             	sub    $0x4,%esp
8010665f:	68 00 10 00 00       	push   $0x1000
80106664:	6a 00                	push   $0x0
80106666:	50                   	push   %eax
80106667:	e8 65 dc ff ff       	call   801042d1 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010666c:	83 c4 08             	add    $0x8,%esp
8010666f:	6a 06                	push   $0x6
80106671:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106677:	50                   	push   %eax
80106678:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010667d:	ba 00 00 00 00       	mov    $0x0,%edx
80106682:	8b 45 08             	mov    0x8(%ebp),%eax
80106685:	e8 cf fc ff ff       	call   80106359 <mappages>
  memmove(mem, init, sz);
8010668a:	83 c4 0c             	add    $0xc,%esp
8010668d:	56                   	push   %esi
8010668e:	ff 75 0c             	pushl  0xc(%ebp)
80106691:	53                   	push   %ebx
80106692:	e8 b5 dc ff ff       	call   8010434c <memmove>
}
80106697:	83 c4 10             	add    $0x10,%esp
8010669a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010669d:	5b                   	pop    %ebx
8010669e:	5e                   	pop    %esi
8010669f:	5d                   	pop    %ebp
801066a0:	c3                   	ret    
    panic("inituvm: more than a page");
801066a1:	83 ec 0c             	sub    $0xc,%esp
801066a4:	68 bd 74 10 80       	push   $0x801074bd
801066a9:	e8 9a 9c ff ff       	call   80100348 <panic>

801066ae <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801066ae:	55                   	push   %ebp
801066af:	89 e5                	mov    %esp,%ebp
801066b1:	57                   	push   %edi
801066b2:	56                   	push   %esi
801066b3:	53                   	push   %ebx
801066b4:	83 ec 0c             	sub    $0xc,%esp
801066b7:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801066ba:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
801066c1:	75 07                	jne    801066ca <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801066c3:	bb 00 00 00 00       	mov    $0x0,%ebx
801066c8:	eb 3c                	jmp    80106706 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
801066ca:	83 ec 0c             	sub    $0xc,%esp
801066cd:	68 78 75 10 80       	push   $0x80107578
801066d2:	e8 71 9c ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801066d7:	83 ec 0c             	sub    $0xc,%esp
801066da:	68 d7 74 10 80       	push   $0x801074d7
801066df:	e8 64 9c ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801066e4:	05 00 00 00 80       	add    $0x80000000,%eax
801066e9:	56                   	push   %esi
801066ea:	89 da                	mov    %ebx,%edx
801066ec:	03 55 14             	add    0x14(%ebp),%edx
801066ef:	52                   	push   %edx
801066f0:	50                   	push   %eax
801066f1:	ff 75 10             	pushl  0x10(%ebp)
801066f4:	e8 7a b0 ff ff       	call   80101773 <readi>
801066f9:	83 c4 10             	add    $0x10,%esp
801066fc:	39 f0                	cmp    %esi,%eax
801066fe:	75 47                	jne    80106747 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
80106700:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106706:	39 fb                	cmp    %edi,%ebx
80106708:	73 30                	jae    8010673a <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010670a:	89 da                	mov    %ebx,%edx
8010670c:	03 55 0c             	add    0xc(%ebp),%edx
8010670f:	b9 00 00 00 00       	mov    $0x0,%ecx
80106714:	8b 45 08             	mov    0x8(%ebp),%eax
80106717:	e8 cd fb ff ff       	call   801062e9 <walkpgdir>
8010671c:	85 c0                	test   %eax,%eax
8010671e:	74 b7                	je     801066d7 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
80106720:	8b 00                	mov    (%eax),%eax
80106722:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106727:	89 fe                	mov    %edi,%esi
80106729:	29 de                	sub    %ebx,%esi
8010672b:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106731:	76 b1                	jbe    801066e4 <loaduvm+0x36>
      n = PGSIZE;
80106733:	be 00 10 00 00       	mov    $0x1000,%esi
80106738:	eb aa                	jmp    801066e4 <loaduvm+0x36>
      return -1;
  }
  return 0;
8010673a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010673f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106742:	5b                   	pop    %ebx
80106743:	5e                   	pop    %esi
80106744:	5f                   	pop    %edi
80106745:	5d                   	pop    %ebp
80106746:	c3                   	ret    
      return -1;
80106747:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674c:	eb f1                	jmp    8010673f <loaduvm+0x91>

8010674e <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010674e:	55                   	push   %ebp
8010674f:	89 e5                	mov    %esp,%ebp
80106751:	57                   	push   %edi
80106752:	56                   	push   %esi
80106753:	53                   	push   %ebx
80106754:	83 ec 0c             	sub    $0xc,%esp
80106757:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010675a:	39 7d 10             	cmp    %edi,0x10(%ebp)
8010675d:	73 11                	jae    80106770 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
8010675f:	8b 45 10             	mov    0x10(%ebp),%eax
80106762:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106768:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010676e:	eb 19                	jmp    80106789 <deallocuvm+0x3b>
    return oldsz;
80106770:	89 f8                	mov    %edi,%eax
80106772:	eb 64                	jmp    801067d8 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106774:	c1 eb 16             	shr    $0x16,%ebx
80106777:	83 c3 01             	add    $0x1,%ebx
8010677a:	c1 e3 16             	shl    $0x16,%ebx
8010677d:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106783:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106789:	39 fb                	cmp    %edi,%ebx
8010678b:	73 48                	jae    801067d5 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010678d:	b9 00 00 00 00       	mov    $0x0,%ecx
80106792:	89 da                	mov    %ebx,%edx
80106794:	8b 45 08             	mov    0x8(%ebp),%eax
80106797:	e8 4d fb ff ff       	call   801062e9 <walkpgdir>
8010679c:	89 c6                	mov    %eax,%esi
    if(!pte)
8010679e:	85 c0                	test   %eax,%eax
801067a0:	74 d2                	je     80106774 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
801067a2:	8b 00                	mov    (%eax),%eax
801067a4:	a8 01                	test   $0x1,%al
801067a6:	74 db                	je     80106783 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
801067a8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801067ad:	74 19                	je     801067c8 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
801067af:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801067b4:	83 ec 0c             	sub    $0xc,%esp
801067b7:	50                   	push   %eax
801067b8:	e8 e7 b7 ff ff       	call   80101fa4 <kfree>
      *pte = 0;
801067bd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
801067c3:	83 c4 10             	add    $0x10,%esp
801067c6:	eb bb                	jmp    80106783 <deallocuvm+0x35>
        panic("kfree");
801067c8:	83 ec 0c             	sub    $0xc,%esp
801067cb:	68 06 6e 10 80       	push   $0x80106e06
801067d0:	e8 73 9b ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801067d5:	8b 45 10             	mov    0x10(%ebp),%eax
}
801067d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801067db:	5b                   	pop    %ebx
801067dc:	5e                   	pop    %esi
801067dd:	5f                   	pop    %edi
801067de:	5d                   	pop    %ebp
801067df:	c3                   	ret    

801067e0 <allocuvm>:
{
801067e0:	55                   	push   %ebp
801067e1:	89 e5                	mov    %esp,%ebp
801067e3:	57                   	push   %edi
801067e4:	56                   	push   %esi
801067e5:	53                   	push   %ebx
801067e6:	83 ec 1c             	sub    $0x1c,%esp
801067e9:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801067ec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801067ef:	85 ff                	test   %edi,%edi
801067f1:	0f 88 c1 00 00 00    	js     801068b8 <allocuvm+0xd8>
  if(newsz < oldsz)
801067f7:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801067fa:	72 5c                	jb     80106858 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
801067fc:	8b 45 0c             	mov    0xc(%ebp),%eax
801067ff:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106805:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
8010680b:	39 fb                	cmp    %edi,%ebx
8010680d:	0f 83 ac 00 00 00    	jae    801068bf <allocuvm+0xdf>
    mem = kalloc();
80106813:	e8 a3 b8 ff ff       	call   801020bb <kalloc>
80106818:	89 c6                	mov    %eax,%esi
    if(mem == 0){
8010681a:	85 c0                	test   %eax,%eax
8010681c:	74 42                	je     80106860 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
8010681e:	83 ec 04             	sub    $0x4,%esp
80106821:	68 00 10 00 00       	push   $0x1000
80106826:	6a 00                	push   $0x0
80106828:	50                   	push   %eax
80106829:	e8 a3 da ff ff       	call   801042d1 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010682e:	83 c4 08             	add    $0x8,%esp
80106831:	6a 06                	push   $0x6
80106833:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106839:	50                   	push   %eax
8010683a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010683f:	89 da                	mov    %ebx,%edx
80106841:	8b 45 08             	mov    0x8(%ebp),%eax
80106844:	e8 10 fb ff ff       	call   80106359 <mappages>
80106849:	83 c4 10             	add    $0x10,%esp
8010684c:	85 c0                	test   %eax,%eax
8010684e:	78 38                	js     80106888 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
80106850:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106856:	eb b3                	jmp    8010680b <allocuvm+0x2b>
    return oldsz;
80106858:	8b 45 0c             	mov    0xc(%ebp),%eax
8010685b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010685e:	eb 5f                	jmp    801068bf <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
80106860:	83 ec 0c             	sub    $0xc,%esp
80106863:	68 f5 74 10 80       	push   $0x801074f5
80106868:	e8 9e 9d ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010686d:	83 c4 0c             	add    $0xc,%esp
80106870:	ff 75 0c             	pushl  0xc(%ebp)
80106873:	57                   	push   %edi
80106874:	ff 75 08             	pushl  0x8(%ebp)
80106877:	e8 d2 fe ff ff       	call   8010674e <deallocuvm>
      return 0;
8010687c:	83 c4 10             	add    $0x10,%esp
8010687f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106886:	eb 37                	jmp    801068bf <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106888:	83 ec 0c             	sub    $0xc,%esp
8010688b:	68 0d 75 10 80       	push   $0x8010750d
80106890:	e8 76 9d ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106895:	83 c4 0c             	add    $0xc,%esp
80106898:	ff 75 0c             	pushl  0xc(%ebp)
8010689b:	57                   	push   %edi
8010689c:	ff 75 08             	pushl  0x8(%ebp)
8010689f:	e8 aa fe ff ff       	call   8010674e <deallocuvm>
      kfree(mem);
801068a4:	89 34 24             	mov    %esi,(%esp)
801068a7:	e8 f8 b6 ff ff       	call   80101fa4 <kfree>
      return 0;
801068ac:	83 c4 10             	add    $0x10,%esp
801068af:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801068b6:	eb 07                	jmp    801068bf <allocuvm+0xdf>
    return 0;
801068b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801068bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801068c5:	5b                   	pop    %ebx
801068c6:	5e                   	pop    %esi
801068c7:	5f                   	pop    %edi
801068c8:	5d                   	pop    %ebp
801068c9:	c3                   	ret    

801068ca <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801068ca:	55                   	push   %ebp
801068cb:	89 e5                	mov    %esp,%ebp
801068cd:	56                   	push   %esi
801068ce:	53                   	push   %ebx
801068cf:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801068d2:	85 f6                	test   %esi,%esi
801068d4:	74 1a                	je     801068f0 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801068d6:	83 ec 04             	sub    $0x4,%esp
801068d9:	6a 00                	push   $0x0
801068db:	68 00 00 00 80       	push   $0x80000000
801068e0:	56                   	push   %esi
801068e1:	e8 68 fe ff ff       	call   8010674e <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801068e6:	83 c4 10             	add    $0x10,%esp
801068e9:	bb 00 00 00 00       	mov    $0x0,%ebx
801068ee:	eb 10                	jmp    80106900 <freevm+0x36>
    panic("freevm: no pgdir");
801068f0:	83 ec 0c             	sub    $0xc,%esp
801068f3:	68 29 75 10 80       	push   $0x80107529
801068f8:	e8 4b 9a ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801068fd:	83 c3 01             	add    $0x1,%ebx
80106900:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106906:	77 1f                	ja     80106927 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106908:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
8010690b:	a8 01                	test   $0x1,%al
8010690d:	74 ee                	je     801068fd <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010690f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106914:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106919:	83 ec 0c             	sub    $0xc,%esp
8010691c:	50                   	push   %eax
8010691d:	e8 82 b6 ff ff       	call   80101fa4 <kfree>
80106922:	83 c4 10             	add    $0x10,%esp
80106925:	eb d6                	jmp    801068fd <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106927:	83 ec 0c             	sub    $0xc,%esp
8010692a:	56                   	push   %esi
8010692b:	e8 74 b6 ff ff       	call   80101fa4 <kfree>
}
80106930:	83 c4 10             	add    $0x10,%esp
80106933:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106936:	5b                   	pop    %ebx
80106937:	5e                   	pop    %esi
80106938:	5d                   	pop    %ebp
80106939:	c3                   	ret    

8010693a <setupkvm>:
{
8010693a:	55                   	push   %ebp
8010693b:	89 e5                	mov    %esp,%ebp
8010693d:	56                   	push   %esi
8010693e:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
8010693f:	e8 77 b7 ff ff       	call   801020bb <kalloc>
80106944:	89 c6                	mov    %eax,%esi
80106946:	85 c0                	test   %eax,%eax
80106948:	74 55                	je     8010699f <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
8010694a:	83 ec 04             	sub    $0x4,%esp
8010694d:	68 00 10 00 00       	push   $0x1000
80106952:	6a 00                	push   $0x0
80106954:	50                   	push   %eax
80106955:	e8 77 d9 ff ff       	call   801042d1 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010695a:	83 c4 10             	add    $0x10,%esp
8010695d:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106962:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106968:	73 35                	jae    8010699f <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
8010696a:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010696d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106970:	29 c1                	sub    %eax,%ecx
80106972:	83 ec 08             	sub    $0x8,%esp
80106975:	ff 73 0c             	pushl  0xc(%ebx)
80106978:	50                   	push   %eax
80106979:	8b 13                	mov    (%ebx),%edx
8010697b:	89 f0                	mov    %esi,%eax
8010697d:	e8 d7 f9 ff ff       	call   80106359 <mappages>
80106982:	83 c4 10             	add    $0x10,%esp
80106985:	85 c0                	test   %eax,%eax
80106987:	78 05                	js     8010698e <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106989:	83 c3 10             	add    $0x10,%ebx
8010698c:	eb d4                	jmp    80106962 <setupkvm+0x28>
      freevm(pgdir);
8010698e:	83 ec 0c             	sub    $0xc,%esp
80106991:	56                   	push   %esi
80106992:	e8 33 ff ff ff       	call   801068ca <freevm>
      return 0;
80106997:	83 c4 10             	add    $0x10,%esp
8010699a:	be 00 00 00 00       	mov    $0x0,%esi
}
8010699f:	89 f0                	mov    %esi,%eax
801069a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801069a4:	5b                   	pop    %ebx
801069a5:	5e                   	pop    %esi
801069a6:	5d                   	pop    %ebp
801069a7:	c3                   	ret    

801069a8 <kvmalloc>:
{
801069a8:	55                   	push   %ebp
801069a9:	89 e5                	mov    %esp,%ebp
801069ab:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801069ae:	e8 87 ff ff ff       	call   8010693a <setupkvm>
801069b3:	a3 c4 65 11 80       	mov    %eax,0x801165c4
  switchkvm();
801069b8:	e8 5e fb ff ff       	call   8010651b <switchkvm>
}
801069bd:	c9                   	leave  
801069be:	c3                   	ret    

801069bf <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801069bf:	55                   	push   %ebp
801069c0:	89 e5                	mov    %esp,%ebp
801069c2:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801069c5:	b9 00 00 00 00       	mov    $0x0,%ecx
801069ca:	8b 55 0c             	mov    0xc(%ebp),%edx
801069cd:	8b 45 08             	mov    0x8(%ebp),%eax
801069d0:	e8 14 f9 ff ff       	call   801062e9 <walkpgdir>
  if(pte == 0)
801069d5:	85 c0                	test   %eax,%eax
801069d7:	74 05                	je     801069de <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801069d9:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801069dc:	c9                   	leave  
801069dd:	c3                   	ret    
    panic("clearpteu");
801069de:	83 ec 0c             	sub    $0xc,%esp
801069e1:	68 3a 75 10 80       	push   $0x8010753a
801069e6:	e8 5d 99 ff ff       	call   80100348 <panic>

801069eb <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801069eb:	55                   	push   %ebp
801069ec:	89 e5                	mov    %esp,%ebp
801069ee:	57                   	push   %edi
801069ef:	56                   	push   %esi
801069f0:	53                   	push   %ebx
801069f1:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801069f4:	e8 41 ff ff ff       	call   8010693a <setupkvm>
801069f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
801069fc:	85 c0                	test   %eax,%eax
801069fe:	0f 84 c4 00 00 00    	je     80106ac8 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106a04:	bf 00 00 00 00       	mov    $0x0,%edi
80106a09:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106a0c:	0f 83 b6 00 00 00    	jae    80106ac8 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106a12:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106a15:	b9 00 00 00 00       	mov    $0x0,%ecx
80106a1a:	89 fa                	mov    %edi,%edx
80106a1c:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1f:	e8 c5 f8 ff ff       	call   801062e9 <walkpgdir>
80106a24:	85 c0                	test   %eax,%eax
80106a26:	74 65                	je     80106a8d <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106a28:	8b 00                	mov    (%eax),%eax
80106a2a:	a8 01                	test   $0x1,%al
80106a2c:	74 6c                	je     80106a9a <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106a2e:	89 c6                	mov    %eax,%esi
80106a30:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106a36:	25 ff 0f 00 00       	and    $0xfff,%eax
80106a3b:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106a3e:	e8 78 b6 ff ff       	call   801020bb <kalloc>
80106a43:	89 c3                	mov    %eax,%ebx
80106a45:	85 c0                	test   %eax,%eax
80106a47:	74 6a                	je     80106ab3 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106a49:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106a4f:	83 ec 04             	sub    $0x4,%esp
80106a52:	68 00 10 00 00       	push   $0x1000
80106a57:	56                   	push   %esi
80106a58:	50                   	push   %eax
80106a59:	e8 ee d8 ff ff       	call   8010434c <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106a5e:	83 c4 08             	add    $0x8,%esp
80106a61:	ff 75 e0             	pushl  -0x20(%ebp)
80106a64:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106a6a:	50                   	push   %eax
80106a6b:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106a70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106a73:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106a76:	e8 de f8 ff ff       	call   80106359 <mappages>
80106a7b:	83 c4 10             	add    $0x10,%esp
80106a7e:	85 c0                	test   %eax,%eax
80106a80:	78 25                	js     80106aa7 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
80106a82:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106a88:	e9 7c ff ff ff       	jmp    80106a09 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106a8d:	83 ec 0c             	sub    $0xc,%esp
80106a90:	68 44 75 10 80       	push   $0x80107544
80106a95:	e8 ae 98 ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106a9a:	83 ec 0c             	sub    $0xc,%esp
80106a9d:	68 5e 75 10 80       	push   $0x8010755e
80106aa2:	e8 a1 98 ff ff       	call   80100348 <panic>
      kfree(mem);
80106aa7:	83 ec 0c             	sub    $0xc,%esp
80106aaa:	53                   	push   %ebx
80106aab:	e8 f4 b4 ff ff       	call   80101fa4 <kfree>
      goto bad;
80106ab0:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106ab3:	83 ec 0c             	sub    $0xc,%esp
80106ab6:	ff 75 dc             	pushl  -0x24(%ebp)
80106ab9:	e8 0c fe ff ff       	call   801068ca <freevm>
  return 0;
80106abe:	83 c4 10             	add    $0x10,%esp
80106ac1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106ac8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106acb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ace:	5b                   	pop    %ebx
80106acf:	5e                   	pop    %esi
80106ad0:	5f                   	pop    %edi
80106ad1:	5d                   	pop    %ebp
80106ad2:	c3                   	ret    

80106ad3 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106ad3:	55                   	push   %ebp
80106ad4:	89 e5                	mov    %esp,%ebp
80106ad6:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106ad9:	b9 00 00 00 00       	mov    $0x0,%ecx
80106ade:	8b 55 0c             	mov    0xc(%ebp),%edx
80106ae1:	8b 45 08             	mov    0x8(%ebp),%eax
80106ae4:	e8 00 f8 ff ff       	call   801062e9 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106ae9:	8b 00                	mov    (%eax),%eax
80106aeb:	a8 01                	test   $0x1,%al
80106aed:	74 10                	je     80106aff <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106aef:	a8 04                	test   $0x4,%al
80106af1:	74 13                	je     80106b06 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106af3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106af8:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106afd:	c9                   	leave  
80106afe:	c3                   	ret    
    return 0;
80106aff:	b8 00 00 00 00       	mov    $0x0,%eax
80106b04:	eb f7                	jmp    80106afd <uva2ka+0x2a>
    return 0;
80106b06:	b8 00 00 00 00       	mov    $0x0,%eax
80106b0b:	eb f0                	jmp    80106afd <uva2ka+0x2a>

80106b0d <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106b0d:	55                   	push   %ebp
80106b0e:	89 e5                	mov    %esp,%ebp
80106b10:	57                   	push   %edi
80106b11:	56                   	push   %esi
80106b12:	53                   	push   %ebx
80106b13:	83 ec 0c             	sub    $0xc,%esp
80106b16:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106b19:	eb 25                	jmp    80106b40 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80106b1e:	29 f2                	sub    %esi,%edx
80106b20:	01 d0                	add    %edx,%eax
80106b22:	83 ec 04             	sub    $0x4,%esp
80106b25:	53                   	push   %ebx
80106b26:	ff 75 10             	pushl  0x10(%ebp)
80106b29:	50                   	push   %eax
80106b2a:	e8 1d d8 ff ff       	call   8010434c <memmove>
    len -= n;
80106b2f:	29 df                	sub    %ebx,%edi
    buf += n;
80106b31:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106b34:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106b3a:	89 45 0c             	mov    %eax,0xc(%ebp)
80106b3d:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106b40:	85 ff                	test   %edi,%edi
80106b42:	74 2f                	je     80106b73 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106b44:	8b 75 0c             	mov    0xc(%ebp),%esi
80106b47:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106b4d:	83 ec 08             	sub    $0x8,%esp
80106b50:	56                   	push   %esi
80106b51:	ff 75 08             	pushl  0x8(%ebp)
80106b54:	e8 7a ff ff ff       	call   80106ad3 <uva2ka>
    if(pa0 == 0)
80106b59:	83 c4 10             	add    $0x10,%esp
80106b5c:	85 c0                	test   %eax,%eax
80106b5e:	74 20                	je     80106b80 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106b60:	89 f3                	mov    %esi,%ebx
80106b62:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106b65:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106b6b:	39 df                	cmp    %ebx,%edi
80106b6d:	73 ac                	jae    80106b1b <copyout+0xe>
      n = len;
80106b6f:	89 fb                	mov    %edi,%ebx
80106b71:	eb a8                	jmp    80106b1b <copyout+0xe>
  }
  return 0;
80106b73:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b78:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106b7b:	5b                   	pop    %ebx
80106b7c:	5e                   	pop    %esi
80106b7d:	5f                   	pop    %edi
80106b7e:	5d                   	pop    %ebp
80106b7f:	c3                   	ret    
      return -1;
80106b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b85:	eb f1                	jmp    80106b78 <copyout+0x6b>
