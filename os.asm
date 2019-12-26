

.set noreorder
.set nomacro
.org 0x0
_start:
    j	    init				#初始化

.org 0x10                              
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
    ori     $14,$0,0x1
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
    ori     $28,$0,0x1
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
	nop
	j mainloop
	
	
# 键盘输入处理，默认将ascii输入0x1600的位置, 23返回值，2上一个输入字符

key_input:    #key_input
	nop
#	lbu $23, 0x1604($0)  #键盘输入使能端
#	beq $23, $0, noinput
#	nop
	ori $28, $0, 0x1    #enter清除
	lbu $23, 0x1600($0)  #键盘输入
	lbu $23, 0x1600($0)  #键盘输入
	nop
	beq $23, $0, noinput
	nop
	beq $23, $2, same_input
	nop
	ori $2, $23, 0x0  #将当前输入作为上一个输入
	jr  $31
	nop
noinput:  #noinput
	nop
	ori $23, $0, 0x0
	ori $2, $0, 0x0
	jr  $31
	nop
same_input:  #same_input
	nop
	ori $23, $0, 0x0
	jr  $31
	nop
#  以上为键盘输入模块
print_asc:  #print asc
	nop
	beq $23, $0, finish_input
	nop
	ori $4, $0, 0x0d
#	xor $28, $4, $23    #enter标识符，输入enter时为0，否则不为0
	beq $23, $4, input_newline  #输入换行  
	nop 
	ori $4, $0, 0x08     
	beq $23, $4, input_delete   #退格键删除
	nop
	j input_asc
	nop
#从1900开始存放每一行的行位置, 0x2000起存放vga映射，每行只能显示64个字符
input_newline:  #input newline
	nop
	ori $28, $0, 0x0      #输入enter
	sb $25, 0x1900($24) 
	ori $25, $0, 0x0
	addi $24, $24, 0x1
	j finish_input
	nop
input_delete:   #input delete
	nop
	beq $25, $0, prev_line
	nop
	sub $25, $25, $14
	sll $5, $24, 0x6   
	add $5, $5, $25
	sb  $0, 0x2000($5)
	j finish_input
	nop
prev_line:   #prev line
	nop
	sub $24, $24, $14
	lbu $25, 0x1900($24)
	lbu $25, 0x1900($24)
	j finish_input
	nop
input_asc:  #输入正常ascii码 input asc
	nop
	sll $5, $24, 0x6   
	add $5, $5, $25
	sb  $23, 0x2000($5)
	addi $25, $25, 0x1
	ori $4, $0, 0x40
	beq $25, $4, input_newline #换行
	nop
	j finish_input
	nop
finish_input:            #finish input
	nop
	jr $31
	nop
#比较输入指令是否为运行程序
run_program:  #4为地址索引，5为比较值，6为地址中值    run program
	nop
#	ori $20, $0, 0x1
	sub $4, $24, $14
	sll $4, $4, 0x6 
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	ori $20, $0, 0x2e
	bne $6, $20, not_program  #不为句号
	nop
	addi $4, $4, 1
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	ori $20, $0, 0x2f
	bne $6, $20, not_program #不为/
	nop
	addi $4, $4, 1
	j is_hello
	nop
not_hello:    #not hello
	nop
	j is_fib
	nop
not_fib:    #not fib
	nop
	j wrong_program
	nop
is_hello:   #is hello
	nop
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	bne $6, 0x68, not_hello
	nop
	addi $4, $4, 1
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	ori $20, $0, 0x65
	bne $6, $20, not_hello
	nop
	addi $4, $4, 1
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	ori $5, $5, 0x6c
	bne $6, $5, not_hello
	nop 
	j run_hello

is_fib:   #is fib
	nop
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	ori $5, $5, 0x66
	bne $6, $5, not_fib
	nop
	addi $4, $4, 1
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	ori $5, $5, 0x69
	bne $6, $5, not_fib
	nop
	addi $4, $4, 1
	lbu $6, 0x2000($4)
	lbu $6, 0x2000($4)
	ori $5, $5, 0x62
	bne $6, $5, not_fib
	nop 
	j run_fib
	nop 
not_program:  #not program
	nop
	j mainloop
	nop
wrong_program:  #错误程序输出F，并换行   wrong program
	nop
	ori $23, $0, 0x46   #输出F
	jal print_asc
	nop
	ori $23, $0, 0x0d    #输出换行
	jal print_asc
	nop 
	j  mainloop
	nop

run_hello:   #run hello
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
    ori     $23,$0,0x0d                     # 0x0d  回车
    jal		print_asc
    nop
    ori     $31,$7,0x0                      # 获得返回地址
    ori     $28,$1,0x1                      # clear the singal(do not forgrt!)
    j 	    mainloop
   
run_fib:   #run fib
	nop
	jal key_input
	nop
	beq $23, 0x0d, fib_inputing
	nop
	jal fib_getinput
	nop
	ori $9, $0, 0x0    #9,10存放两个临时数值，11存放当前计算位置
	ori $10, $0, 0x1
	ori $11, $0, 0x1
	beq $8, $0, fib_out0
	nop
fib_iter:  #fib iter
	nop
	beq $8, $11, fib_out
	nop
	or $12 , $0, $9
	or $9, $0, $10
	add $10, $10, $12
	addi $11, $11, 0x1
	j fib_iter
	nop
fib_inputing:  #fib inputing
	nop
	j run_fib
	
fib_getinput:  #fib getinput 
	nop
	sub $16, $24, 0x1
	sll $16, $16, 0x6 
	lbu $17, 0x2000($16)
	lbu $17, 0x2000($16)
	ori $20, $0, 0x30
	sub $8, $17, $20    #减30获得对应数字
	jr $31
	nop
fib_out0:  #fib out0
	nop
	ori $23, $0, 0x0
	j mainloop
	nop
fib_out:   #fib out
	nop
	or 	$23, $0, $10
    	jal		print_asc
        nop
  	ori     $23,$0,0x0d                     # 输出换行
  	jal		print_asc
 	nop
	j mainloop
	nop
	
	
