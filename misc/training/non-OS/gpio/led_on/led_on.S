.text
.global _start

_start:
	/* Peri port setup */
	ldr     r0, =0x70000000
	orr     r0, r0, #0x13		@ 0001 0011
	mcr     p15,0,r0,c15,c2,4	@ 256M(0x70000000-0x7fffffff)

	ldr     r0, =0x7f008000
	ldr     r1, =0x00111111
	str     r1, [r0, #0x820]

	ldr     r1, =0x00000555
	str     r1, [r0, #0x828]

	ldr     r1, =0x0009		@ 1001
	str     r1, [r0, #0x824]

MAIN_LOOP:
	B       MAIN_LOOP
