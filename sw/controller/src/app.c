#include <stdint.h>
#include "cic.h"
#include "gvr.h"
#include "hw.h"
#include "led.h"
#include "rtc.h"
#include "task.h"


#define CIC_STACK_SIZE  (256)
#define RTC_STACK_SIZE  (256)
#define LED_STACK_SIZE  (256)
#define GVR_STACK_SIZE  (2048)


uint8_t cic_stack[CIC_STACK_SIZE] __attribute__((aligned(8)));
uint8_t rtc_stack[RTC_STACK_SIZE] __attribute__((aligned(8)));
uint8_t led_stack[LED_STACK_SIZE] __attribute__((aligned(8)));
uint8_t gvr_stack[GVR_STACK_SIZE] __attribute__((aligned(8)));


void app (void) {
    hw_init();
    cic_hw_init();

    task_create(TASK_ID_CIC, cic_task, cic_stack, CIC_STACK_SIZE);
    task_create(TASK_ID_RTC, rtc_task, rtc_stack, RTC_STACK_SIZE);
    task_create(TASK_ID_LED, led_task, led_stack, LED_STACK_SIZE);
    task_create(TASK_ID_GVR, gvr_task, gvr_stack, GVR_STACK_SIZE);

    task_scheduler_start();
}
