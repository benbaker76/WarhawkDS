@ Initialise any inserted block-devices.
@ Add the fat device driver to the devoptab, making it available for standard file functions.
@ cacheSize: The number of pages to allocate for each inserted block-device
@ setAsDefaultDevice: if true, make this the default device driver for file operations
@ extern bool fatInit (uint32_t cacheSize, bool setAsDefaultDevice);

.extern fatInit

@ Calls fatInit with setAsDefaultDevice = true and cacheSize optimised for the host system.
@ extern bool fatInitDefault (void);

.extern fatInitDefault

@ Mount the device pointed to by interface, and set up a devoptab entry for it as "name:".
@ You can then access the filesystem using "name:/".
@ This will mount the active partition or the first valid partition on the disc, 
@ and will use a cache size optimized for the host system.
@ extern bool fatMountSimple (const char* name, const DISC_INTERFACE* interface);

.extern fatMountSimple

@ Mount the device pointed to by interface, and set up a devoptab entry for it as "name:".
@ You can then access the filesystem using "name:/".
@ If startSector = 0, it will mount the active partition of the first valid partition on
@ the disc. Otherwise it will try to mount the partition starting at startSector.
@ cacheSize specifies the number of pages to allocate for the cache.
@ This will not startup the disc, so you need to call interface->startup(); first.
@ extern bool fatMount (const char* name, const DISC_INTERFACE* interface, sec_t startSector, uint32_t cacheSize);

.extern fatMount

@ Unmount the partition specified by name.
@ If there are open files, it will attempt to synchronise them to disc.
@ extern void fatUnmount (const char* name);

.extern fatUnmount
