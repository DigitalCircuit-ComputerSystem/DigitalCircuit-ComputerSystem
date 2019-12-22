_start:
   ori  $1,$0,0x0001   # $1 = 0x1                
   j    s1
   ori  $1,$0,0x0002   # $1 = 0x2
   ori  $1,$0,0x1111
   ori  $1,$0,0x1100

 s1:
   ori  $1,$0,0x0003   # $1 = 0x3               
   jal  s2
   div  $zero,$31,$1   # $31 = 0x1c, $1 = 0x3
                       # hi = 0x1, lo = 0x9 
   ori  $1,$0,0x0005   # $1 = 0x5
   ori  $1,$0,0x0006   # $1 = 0x6
   j    s3
   nop

s2:               
   jalr $2,$31           
   or   $1,$2,$0        # $1 = 0x40
   ori  $1,$0,0x0009    # $1 = 0x9
   ori  $1,$0,0x000a    # $1 = 0xa
   j s4
   nop

s3:
   ori  $1,$0,0x0007    # $1 = 0x7                
   jr   $2           
   ori  $1,$0,0x0008    # $1 = 0x8
   ori  $1,$0,0x1111
   ori  $1,$0,0x1100

s4:
   nop