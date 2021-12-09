#ifndef STORAGE_H__
#define STORAGE_H__


#include "boot.h"
#include "sc64.h"


typedef enum {
    STORAGE_BACKEND_SD = 0,
    STORAGE_BACKEND_USB = 1,
} storage_backend_t;


void storage_run_menu (storage_backend_t storage_backend, boot_info_t *boot_info, sc64_info_t *sc64_info);


#endif
