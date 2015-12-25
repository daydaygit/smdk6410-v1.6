@******************************************************************************
@ File：crt0.S
@ 功能：通过它转入C程序
@******************************************************************************       

.text
.global _start

_start:
	/* Peri port setup */
	ldr     r0, =0x70000000
	orr     r0, r0, #0x13		@ 0001 0011
	mcr     p15,0,r0,c15,c2,4	@ 256M(0x70000000-0x7fffffff)

	/* Disable Watchdog */
	ldr     r0, =0x7e000000		@0x7e004000
	orr     r0, r0, #0x4000
	mov     r1, #0
	str     r1, [r0]

	ldr	sp, =1024*4		@ 设置堆栈，注意：不能大于4k, 因为现在可用的内存只有4K
					@ nand flash中的代码在复位后会移到内部ram中，此ram只有4K

	bl	main			@ 调用C程序中的main函数

halt_loop:
	b	halt_loop

