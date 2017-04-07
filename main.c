/*******************************************************/                              
/*  - Marc-Antoine Tardif                              */
/*  - Olivier Mirandette                               */
/*******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dip204.h"
#include "FreeRTOS.h"
#include "gpio.h"
#include "spi.h"
#include "task.h"
#include "power_clocks_lib.h"



//! @{
#define mainPRINT_PRIORITY ( tskIDLE_PRIORITY + 1 )
//! @}
#define mainTASK_PERIOD ( ( portTickType ) 100 / portTICK_RATE_MS  )


static void init_display( void );
static void vPrintLCD( void *pvParameters );


static void init_display(void){
    static const gpio_map_t DIP204_SPI_GPIO_MAP = {
        {DIP204_SPI_SCK_PIN,  DIP204_SPI_SCK_FUNCTION },  // SPI Clock
        {DIP204_SPI_MISO_PIN, DIP204_SPI_MISO_FUNCTION},  // MISO
        {DIP204_SPI_MOSI_PIN, DIP204_SPI_MOSI_FUNCTION},  // MOSI
        {DIP204_SPI_NPCS_PIN, DIP204_SPI_NPCS_FUNCTION}   // Chip Select NPCS
    };
    // add the spi options driver structure for the LCD DIP204
    spi_options_t spiOptions = {
        .reg          = DIP204_SPI_NPCS,
        .baudrate     = 1000000,
        .bits         = 8,
        .spck_delay   = 0,
        .trans_delay  = 8,
        .stay_act     = 1,
        .spi_mode     = 0,
        .modfdis      = 1
    };
    // Assign I/Os to SPI
    gpio_enable_module(DIP204_SPI_GPIO_MAP,
        sizeof(DIP204_SPI_GPIO_MAP) / sizeof(DIP204_SPI_GPIO_MAP[0]));
    spi_initMaster(DIP204_SPI, &spiOptions);               // Initialize as master
    spi_selectionMode(DIP204_SPI, 0, 0, 0);                // Set selection mode: variable_ps, pcs_decode, delay
    spi_enable(DIP204_SPI);                                // Enable SPI
    spi_setupChipReg(DIP204_SPI, &spiOptions, FOSC0 * 4);  // setup chip registers
    dip204_init(backlight_PWM, true);                      // initialize LCD
    // Display default
    dip204_set_cursor_position(1,1);
    dip204_write_string("Init");
    dip204_hide_cursor();
}



static void vPrintLCD( void *pvParameters ){
    while (1){
        dip204_set_cursor_position(1,1);
        dip204_write_string("Test");
        vTaskDelay(mainTASK_PERIOD);
    }
}



int main( void ){
    // Configure Osc0 in crystal mode (i.e. use of an external crystal source, with
    // frequency FOSC0 (12Mhz) ) with an appropriate startup time then switch the main clock
    // source to Osc0.
    pcl_switch_to_osc(PCL_OSC0, FOSC0, OSC0_STARTUP);
    init_display();
    xTaskCreate(
        vPrintLCD,
        (const signed portCHAR *)"PrintLCD",
        configMINIMAL_STACK_SIZE,
        NULL,
        mainPRINT_PRIORITY,
        NULL);
    vTaskStartScheduler();
    return 0;  // if we get here, there is insufficient memory for the idle task
}
