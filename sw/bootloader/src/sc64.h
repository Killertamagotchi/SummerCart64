#ifndef SC64_H__
#define SC64_H__


#include <stdbool.h>
#include <stdint.h>


typedef enum {
    CFG_ID_BOOTLOADER_SWITCH,
    CFG_ID_ROM_WRITE_ENABLE,
    CFG_ID_ROM_SHADOW_ENABLE,
    CFG_ID_DD_MODE,
    CFG_ID_ISV_ENABLE,
    CFG_ID_BOOT_MODE,
    CFG_ID_SAVE_TYPE,
    CFG_ID_CIC_SEED,
    CFG_ID_TV_TYPE,
    CFG_ID_FLASH_ERASE_BLOCK,
    CFG_ID_DD_DRIVE_TYPE,
    CFG_ID_DD_DISK_STATE,
} cfg_id_t;

typedef enum {
    DD_MODE_DISABLED = 0,
    DD_MODE_REGS = 1,
    DD_MODE_IPL = 2,
    DD_MODE_FULL = 3
} dd_mode_t;

typedef enum {
    BOOT_MODE_MENU_SD = 0,
    BOOT_MODE_MENU_USB = 1,
    BOOT_MODE_ROM = 2,
    BOOT_MODE_DDIPL = 3,
    BOOT_MODE_DIRECT = 4
} boot_mode_t;

typedef enum {
    SAVE_TYPE_NONE = 0,
    SAVE_TYPE_EEPROM_4K = 1,
    SAVE_TYPE_EEPROM_16K = 2,
    SAVE_TYPE_SRAM = 3,
    SAVE_TYPE_FLASHRAM = 4,
    SAVE_TYPE_SRAM_BANKED = 5
} save_type_t;

typedef enum {
    CIC_SEED_UNKNOWN = 0xFFFF
} cic_seed_t;

typedef enum {
    TV_TYPE_PAL = 0,
    TV_TYPE_NTSC = 1,
    TV_TYPE_MPAL = 2,
    TV_TYPE_UNKNOWN = 3
} tv_type_t;


typedef struct {
    boot_mode_t boot_mode;
    uint16_t cic_seed;
    tv_type_t tv_type;
} sc64_boot_info_t;

typedef struct {
    uint8_t second;
    uint8_t minute;
    uint8_t hour;
    uint8_t weekday;
    uint8_t day;
    uint8_t month;
    uint8_t year;
} rtc_time_t;


bool sc64_check_presence (void);
void sc64_init (void);
uint32_t sc64_query_config (cfg_id_t id);
void sc64_change_config (cfg_id_t id, uint32_t value);
void sc64_get_boot_info (sc64_boot_info_t *info);
void sc64_get_time (rtc_time_t *t);
void sc64_set_time (rtc_time_t *t);
bool sc64_write_usb_ready (void);
bool sc64_write_usb (uint32_t *address, uint32_t length);
bool sc64_usb_read_ready (uint8_t *type, uint32_t *length);
bool sc64_usb_read (uint32_t *address, uint32_t length);


#endif