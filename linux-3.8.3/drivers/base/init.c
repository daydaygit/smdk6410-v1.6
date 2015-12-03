/*
 * Copyright (c) 2002-3 Patrick Mochel
 * Copyright (c) 2002-3 Open Source Development Labs
 *
 * This file is released under the GPLv2
 */

#include <linux/device.h>
#include <linux/init.h>
#include <linux/memory.h>

#include "base.h"

/**
 * driver_init - initialize driver model.
 *
 * Call the driver model init functions to initialize their
 * subsystems. Called early from init/main.c.
 */
void __init driver_init(void)
{
	printk(KERN_INFO "%s, devtmpfs_init\n", __FILE__);
	printk(KERN_INFO "%s, devices_init\n", __FILE__);
	printk(KERN_INFO "%s, buses_init\n", __FILE__);
	printk(KERN_INFO "%s, classes_init\n", __FILE__);
	printk(KERN_INFO "%s, firmware_init\n", __FILE__);
	printk(KERN_INFO "%s, hypervisor_init\n", __FILE__);
	printk(KERN_INFO "%s, platform_bus_init\n", __FILE__);
	printk(KERN_INFO "%s, cpu_dev_init\n", __FILE__);
	printk(KERN_INFO "%s, memory_dev_init\n", __FILE__);
	/* These are the core pieces */
	devtmpfs_init();
	devices_init();
	buses_init();
	classes_init();
	firmware_init();
	hypervisor_init();

	/* These are also core pieces, but must come after the
	 * core core pieces.
	 */
	platform_bus_init();
	cpu_dev_init();
	memory_dev_init();
}
