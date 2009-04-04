#define IPC					0x027FF000

@ 32-bit
#define IPC_SOUND_DATA(n)	(((n) * 0x10) + IPC)
@ 32-bit
#define IPC_SOUND_LEN(n)	(((n) * 0x10) + IPC + 4)
@ 32-bit
#define IPC_SOUND_RATE(n)	(((n) * 0x10) + IPC + 8)
@ 8-bit
#define IPC_SOUND_VOL(n)	(((n) * 0x10) + IPC + 9)
#define IPC_SOUND_PAN(n)	(((n) * 0x10) + IPC + 10)
@ 16-bit
#define IPC_SOUND_FORMAT(n)	(((n) * 0x10) + IPC + 11)

@ 16-bit
#define REG_IPC_SYNC		0x04000180

#define IPC_SYNC_IRQ_ENABLE			BIT(14)
#define IPC_SYNC_IRQ_REQUEST		BIT(13)

#define IPC_SEND_SYNC(n)			((((n) & 0x0f) << 8) | IPC_SYNC_IRQ_REQUEST)
