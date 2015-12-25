#define	GPMCON		(*(volatile unsigned long *)0x7F008820)
#define	GPMDAT		(*(volatile unsigned long *)0x7F008824)

#define	GPM0_out	(1<<(0*4))				/* 0000 0000 0000 0000 */
#define	GPM1_out	(1<<(1*4))				/* 0000 0000 0001 0000 */
#define	GPM2_out	(1<<(2*4)) 				/* 0000 0001 0000 0000 */
#define	GPM3_out	(1<<(3*4))				/* 0001 0000 0000 0000 */

void  wait(volatile unsigned long dly)
{
	for(; dly > 0; dly--);
}

int main(void)
{
	unsigned long i = 0;

	GPMDAT = (GPMDAT & 0xF0) | 0x0F;
	GPMCON = GPM0_out | GPM1_out | GPM2_out | GPM3_out;	// 将LED0/1/2/3对应的GPM0/1/2/3引脚设为输出

	while(1) {
		wait(99999);

		GPMDAT = (GPMDAT & 0xF0) | (~(1 << i++));

		if(i >= 4)
			i = 0;
	}

	return 0;
}
