
   ori  $3,$0,0xeeff
   sb   $3,0x3($0)       # [0x3] = 0xff
   srl  $3,$3,8
   sb   $3,0x2($0)       # [0x2] = 0xee
   ori  $3,$0,0xccdd
   sb   $3,0x1($0)       # [0x1] = 0xdd
   srl  $3,$3,8
   sb   $3,0x0($0)       # [0x0] = 0xcc
   lb   $1,0x3($0)       # $1 = 0xffffffff
   lbu  $1,0x2($0)       # $1 = 0x000000ee
   nop

   ori  $3,$0,0xaabb
   sh   $3,0x4($0)       # [0x4] = 0xaa, [0x5] = 0xbb
   lhu  $1,0x4($0)       # $1 = 0x0000aabb
   lh   $1,0x4($0)       # $1 = 0xffffaabb
 
   ori  $3,$0,0x8899
   sh   $3,0x6($0)       # [0x6] = 0x88, [0x7] = 0x99
   lh   $1,0x6($0)       # $1 = 0xffff8899
   lhu  $1,0x6($0)       # $1 = 0x00008899

   ori  $3,$0,0x4455
   sll  $3,$3,0x10
   ori  $3,$3,0x6677     
   sw   $3,0x8($0)       # [0x8] = 0x44, [0x9]= 0x55, [0xa]= 0x66, [0xb] = 0x77
   lw   $1,0x8($0)       # $1 = 0x44556677

   lwl  $1, 0x5($0)      # $1 = 0xbb889977
   lwr  $1, 0x8($0)      # $1 = 0xbb889944

   nop
   swr  $1, 0x2($0)      # [0x0] = 0x88, [0x1] = 0x99, [0x2]= 0x44, [0x3] = 0xff
   swl  $1, 0x7($0)      # [0x4] = 0xaa, [0x5] = 0xbb, [0x6] = 0x88, [0x7] = 0x44

   lw   $1, 0x0($0)      # $1 = 0x889944ff
   lw   $1, 0x4($0)      # $1 = 0xaabb8844
   
   nop