   ori  $1,$0,0xffff                  
   sll  $1,$1,16
   ori  $1,$1,0xfffb           # $1 = -5
   ori  $2,$0,6                # $2 = 6

   mult $1,$2                  # hi = 0xffffffff
                               # lo = 0xffffffe2

   madd $1,$2                  # hi = 0xffffffff
                               # lo = 0xffffffc4

   maddu $1,$2                 # hi = 0x5
                               # lo = 0xffffffa6

   msub $1,$2                  # hi = 0x5
                               # lo = 0xffffffc4   

   msubu $1,$2                 # hi = 0xffffffff
                               # lo = 0xffffffe2
   nop   