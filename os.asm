# instruction area 0x0~0x2fff    GRAM area 0x3000~0x3833     KEYBROAD: 0x38fe ENABLE 0x38ff ASCIICODE
# RAM: begin at 0x3900 at least end after 0x4000
# $0===0 $24:column pointer(0~69) $25:line pointer(0~29) $31:return addr(caller's addr+0x08) $30: stack top $29 to modify the stack addr(always 4)
# $28 keybroad ENTER signal $27 unprocessed instrtion line pointer (0~29,begin at 0)
# $23: return data $2: last input ascii $3 $4 $5 $6: temp data  $7: save the old $31 in program ./hello ./fib & ./gdb
# $8: fib data input $9 $10 $11 $13: fib temp data $12: fib count register 
# $14 $15: gdb temp addr $16 $18 $19 $20: gdb temp data $17: gdb testcase retaddr $21 $22: testcase temp

# new mm_io rules:
# ROM 0x0000 0x3fff  GRAM 0x4000 0x4fff   asciicode 0x5000 asciienable 0x5004   RAM 0x6000 0x7fff


.set noreorder
.set nomacro
.org 0x0
_start:
    j	    init				#初始化

#.org 0x100                              
init:
    nop
    ori     $1,$0,0x0
    ori     $2,$0,0x0
    ori     $3,$0,0x0
    ori     $4,$0,0x0
    ori     $5,$0,0x0
    ori     $6,$0,0x0
    ori     $7,$0,0x0
    ori     $8,$0,0x0
    ori     $9,$0,0x0
    ori     $10,$0,0x0
    ori     $11,$0,0x0
    ori     $12,$0,0x0
    ori     $13,$0,0x0
    ori     $14,$0,0x0
    ori     $15,$0,0x0
    ori     $16,$0,0x0
    ori     $17,$0,0x0
    ori     $18,$0,0x0
    ori     $19,$0,0x0
    ori     $20,$0,0x0
    ori     $21,$0,0x0
    ori     $22,$0,0x0
    ori     $23,$0,0x0
    ori     $24,$0,0x0
    ori     $25,$0,0x0
    ori     $26,$0,0x0
    ori     $27,$0,0x0
    ori     $28,$0,0x0
    ori     $29,$0,0x0
    j		mainloop			    	# jump to mainloop
    nop
   
mainloop: 
	nop
	jal key_input
	nop
	jal print_asc  
	nop
	beq $28, $0, run_program
	j mainloop
	
	
# 键盘输入处理，默认将ascii输入0x1600的位置, 23返回值，2上一个输入字符

key_input:
	nop
	lbu $23, 0x1604($0)  #键盘输入使能端
	beq $23, $0, noinput
	nop
	lbu $23, 0x1600($0)  #键盘输入
	beq $23, $2, same_input
	nop
	ori $2, $23, 0x0  #将当前输入作为上一个输入
	jr  $31
noinput:
	nop
	ori $23, $0, 0x0
	ori $2, $0, 0x0
	jr  $31

same_input:
	nop
	ori $23, $0, 0x0
	jr  $31
	
#  以上为键盘输入模块
print_asc:
	nop
	beq $23, $0, finish_input
	ori $4, $0, 0x0d
	xor $28, $4, $23    #enter标识符，输入enter时为0，否则不为0
	beq $23, $4, input_newline  #输入换行  
	nop 
	ori $4, $0, 0x08     
	beq $23, $4, input_delete   #退格键删除
	nop
	j input_asc
#从1900开始存放每一行的行位置, 0x2000起存放vga映射，每行只能显示64个字符
input_newline:
	nop
	sb $25, 0x1900($24) 
	ori $25, $0, 0x0
	addi $24, $24, 0x1
	j finish_input

input_delete:
	nop
	beq $25, $0, prev_line
	sll $5, $24, 0x6   
	add $5, $5, $25
	sb  $0, 0x2000($5)
	subi $25, $25, 0x1
	j finish_input

prev_line: 
	nop
	subi $24, $24, 0x1
	lb $25, 0x1900($24)
	j finish_input
	nop
input_asc:  #输入正常ascii码
	nop
	sll $5, $24, 0x6   
	add $5, $5, $25
	sb  $23, 0x1900($5)
	addi $25, $25, 0x1
	beq $25, 0x40, input_newline #换行
	j finish_input
finish_input:            #结束输入
	nop
	jr $31

	
#比较输入指令是否为运行程序
run_program:  #4为地址索引，5为比较值，6为地址中值
	nop
	sub $4, $24, 0x1
	sll $4, $4, 0x6 
	lb $6, 0x2000($4)
	ori $5, $5, 0x2e
	bne $6, $5, not_program  #不为句号
	addi $4, $4, 1
	lb $6, 0x2000($4)
	ori $5, $5, 0x2f
	bne $6, $5, not_program #不为/
	addi $4, $4, 1
	j is_hello

not_hello:
	nop
	j is_fib
not_fib: 
	nop
	j wrong_program
is_hello: 
	nop
	lb $6, 0x2000($4)
	ori $5, $5, 0x68
	bne $6, $5, not_hello
	nop
	addi $4, $4, 1
	lb $6, 0x2000($4)
	ori $5, $5, 0x65
	bne $6, $5, not_hello
	nop
	addi $4, $4, 1
	lb $6, 0x5200($4)
	ori $5, $5, 0x6c
	bne $6, $5, not_hello
	nop 
	j run_hello

is_fib: 
	nop
	lb $6, 0x2000($4)
	ori $5, $5, 0x66
	bne $6, $5, not_fib
	nop
	addi $4, $4, 1
	lb $6, 0x2000($4)
	ori $5, $5, 0x69
	bne $6, $5, not_fib
	nop
	addi $4, $4, 1
	lb $6, 0x2000($4)
	ori $5, $5, 0x62
	bne $6, $5, not_fib
	nop 
	j run_fib
	nop 
not_program:
	nop
	jr $31
	nop
wrong_program:  #错误程序输出F，并换行
	nop
	ori $23, $0, 0x46
	jal print_asc
	nop
	ori $23, $0, 0x0a
	jal input_newline
	nop 
	j  mainloop
	nop

run_hello:
    nop
    ori     $23,$0,0x68                     # 0x68 h
    jal	   	 print_asc
    nop
    ori     $23,$0,0x65                     # 0x65 e
    jal		print_asc
    nop
    ori     $23,$0,0x6c                     # 0x6c l
    jal		print_asc
    nop
    ori     $23,$0,0x6c                     # 0x6c l
    jal		print_asc
    nop
    ori     $23,$0,0x6f                     # 0x6f o
    jal		print_asc
    nop
    ori     $23,$0,0x20                     # 0x20 (space)
    jal		print_asc
    nop
    ori     $23,$0,0x77                     # 0x77 w
    jal		print_asc
    nop
    ori     $23,$0,0x6f                     # 0x6f o
    jal		print_asc
    nop
    ori     $23,$0,0x72                     # 0x72 r
    jal		print_asc
    nop
    ori     $23,$0,0x6c                     # 0x6c l
    jal		print_asc
    nop
    ori     $23,$0,0x64                     # 0x64 d
    jal		print_asc
    nop
    ori     $23,$0,0x0a                     # 0x0a \n
    jal		print_asc
    nop
    ori     $31,$7,0x0                      # 获得返回地址
    ori     $28,$1,0x0                      # clear the singal(do not forgrt!)
    j 	    mainloop
   
run_fib:
	nop
	jal key_input
	nop
	ori $15, $0, 0x0d
	beq $23, $15, fib_inputing
	nop
	jal fib_getinput
	nop
	ori $9, $0, 0x0    #9,10存放两个临时数值，11存放当前计算位置
	ori $10, $0, 0x1
	ori $11, $0, 0x1
	beq $8, $0, fib_out0

fib_iter:
	nop
	beq $8, $11, fib_out
	or $12 , $0, $9
	or $9, $0, $10
	add $10, $10, $12
	addi $11, $11, 0x1
	j fib_iter
fib_inputing:
	nop
	j run_fib
	
fib_getinput:
	nop
	sub $16, $24, 0x1
	sll $16, $16, 0x6 
	lb $17, 0x2000($16)
	subi $8, $17, 0x30
	jr $31
	
fib_out0:
	nop
	ori $23, $0, 0x0
	j mainloop

fib_out: 
	nop
	or $23, $0, $10
	j mainloop
	
	
	