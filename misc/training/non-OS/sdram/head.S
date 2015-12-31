@*************************************************************************
@ File：head.S
@ func：set SDRAM，copy code to SDRAM，then jump to SDRAM & 继续执行
@************************************************************************* 

.equ	S3C2410_SPEC_REGS_BASE,	0x48000000	@ BWSCON: 0x48000000  P55,P206
.equ	SDRAM_BASE,         0x30000000


.text
.global _start

_start:
    bl  peri_port_setup
    bl  disable_watch_dog               @ close WATCHDOG，or CPU会不断重启
    bl  memsetup                        @ 设置存储控制器
    bl  copy_steppingstone_to_sdram     @ 复制代码到SDRAM中
    ldr pc, =on_sdram                   @ 跳到SDRAM中继续执行

halt_loop:
    b   halt_loop

peri_port_setup:
    ldr r0, =0x70000000
    orr r0, r0, #0x13			@ 0001 0011
    mcr p15, 0, r0, c15, c2, 4		@ 256M(0x70000000-0x7fffffff)
    mov pc, lr

disable_watch_dog:
    @mov r1, #0x7e004000		@ Error: invalid constant (7e004000) after fixup
					@ 用mov的话只要立即数大于0x100后有些数可以编译通过但是有些数就不能编译通过
    @mov r2, #0x0
    @str r2, [r1]
    @mov pc, lr
    ldr r0, =0x7e000000
    orr r0, r0, #0x4000			@ WTCON: 0x7e004000
    mov r1, #0x0			@ just only need write 0 to wdog register
    str r1, [r0]
    mov pc. lr

memsetup:
					@ 设置存储控制器以便使用SDRAM等外设
    mov  r1, #S3C2410_SPEC_REGS_BASE	@ 存储控制器的13个寄存器的开始地址
    adrl r2, mem_cfg_val		@ 这13个值的起始存储地址
    add  r3, r1, #52			@ 13*4 = 54
1:
    ldr r4, [r2], #4			@ 读取设置值，并让r2加4
    str r4, [r1], #4			@ 将此值写入寄存器，并让r1加4
    cmp r1, r3				@ 判断是否设置完所有13个寄存器
    bne 1b				@ 若没有写成，继续. xb:往后跳的意思，回到原已经执行过的语句，x达标0~9的某个标签，b代表backward.类似的还有xf
    mov pc, lr				@ 返回

copy_steppingstone_to_sdram:
					@ 将Steppingstone的4K数据全部复制到SDRAM中去
					@ Steppingstone起始地址为0x00000000，SDRAM中起始地址为0x30000000
    mov r1, #0
    ldr r2, =SDRAM_BASE
    mov r3, #4*1024
1:  
    ldr r4, [r1],#4			@ 从Steppingstone读取4字节的数据，并让源地址加4
    str r4, [r2],#4			@ 将此4字节的数据复制到SDRAM中，并让目地地址加4
    cmp r1, r3				@ 判断是否完成：源地址等于Steppingstone的未地址？
    bne 1b				@ 若没有复制完，继续
    mov pc, lr				@ 返回

on_sdram:
    ldr sp, =0x34000000                 @ 设置堆栈
    bl  main
    mov pc, lr

.align 4
mem_cfg_val:
    @ 存储控制器13个寄存器的设置值
    .long   0x22011110      @ BWSCON
    .long   0x00000700      @ BANKCON0
    .long   0x00000700      @ BANKCON1
    .long   0x00000700      @ BANKCON2
    .long   0x00000700      @ BANKCON3  
    .long   0x00000700      @ BANKCON4
    .long   0x00000700      @ BANKCON5
    .long   0x00018005      @ BANKCON6
    .long   0x00018005      @ BANKCON7
    .long   0x008C07A3      @ REFRESH
    .long   0x000000B1      @ BANKSIZE
    .long   0x00000030      @ MRSRB6
    .long   0x00000030      @ MRSRB7

