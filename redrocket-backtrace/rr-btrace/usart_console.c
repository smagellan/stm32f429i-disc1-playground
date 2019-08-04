/*
 * This file is part of the libopencm3 project.
 *
 * Copyright (C) 2013 Chuck McManis <cmcmanis@mcmanis.com>
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * USART example (alternate console)
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <libopencm3/stm32/gpio.h>
#include <libopencm3/stm32/rcc.h>
#include <libopencm3/stm32/usart.h>
#include "clock.h"
#include "btrace.h"
#include "stdlib_syscalls.h"
#include "cpptestexterns.h"

/*
 * Some definitions of our console "functions" attached to the
 * USART.
 *
 * These define sort of the minimum "library" of functions which
 * we can use on a serial port.
 */
//#define CONSOLE_UART	USART1

void usart_console_puts_zeroterm(const char *s);

void init_uart(void);

void trace_if_needed(char *cmd);

/*
 * void usart_console_puts(char *s)
 *
 * Send a string to the console, one character at a time, return
 * after the last character, as indicated by a NUL character, is
 * reached.
 */
void usart_console_puts_zeroterm(const char *s) {
    while (*s != '\000') {
        usart_console_putc(*s);
        /* Add in a carraige return, after sending line feed */
        if (*s == '\n') {
            usart_console_putc('\r');
        }
        s++;
    }
}

void init_uart(void) {
    /* Set up USART/UART parameters using the libopencm3 helper functions */
    usart_set_baudrate(CONSOLE_UART, 115200);
    usart_set_databits(CONSOLE_UART, 8);
    usart_set_stopbits(CONSOLE_UART, USART_STOPBITS_1);
    usart_set_mode(CONSOLE_UART, USART_MODE_TX_RX);
    usart_set_parity(CONSOLE_UART, USART_PARITY_NONE);
    usart_set_flow_control(CONSOLE_UART, USART_FLOWCONTROL_NONE);
    usart_enable(CONSOLE_UART);
}

void trace_if_needed(char *cmd) {
    if (strcmp(cmd, "trace") == 0) {
        print_backtrace();
    } else {
        if (strcmp(cmd, "cpp") == 0) {
            printf("\ncpp test: %d\n", do_cpp_test());
        }
    }
}

/*
 * Set up the GPIO subsystem with an "Alternate Function"
 * on some of the pins, in this case connected to a
 * USART.
 */
int main(void) {
    char buf[128];
    int len;

    clock_setup(); /* initialize our clock */

    /* MUST enable the GPIO clock in ADDITION to the USART clock */
    rcc_periph_clock_enable(RCC_GPIOA);

    /* This example uses PA9 and PA10 for Tx and Rx respectively
     * but other pins are available for this role on USART1 (our chosen
     * USART) as it is connected to the programmer interface through
     * jumpers.
     */
    gpio_mode_setup(GPIOA, GPIO_MODE_AF, GPIO_PUPD_NONE, GPIO9 | GPIO10);

    /* Actual Alternate function number (in this case 7) is part
     * depenedent, check the data sheet for the right number to
     * use.
     */
    gpio_set_af(GPIOA, GPIO_AF7, GPIO9 | GPIO10);

    /* This then enables the clock to the USART1 peripheral which is
     * attached inside the chip to the APB1 bus. Different peripherals
     * attach to different buses, and even some UARTS are attached to
     * APB1 and some to APB2, again the data sheet is useful here.
     * We use the rcc_periph_clock_enable function that knows on which bus
     * the peripheral is and sets things up accordingly.
     */
    rcc_periph_clock_enable(RCC_USART1);

    init_uart();

    /* At this point our console is ready to go so we can create our
     * simple application to run on it.
     */
    printf("\nUART Demonstration Application\n");
    while (1) {
        printf("Enter a string: ");
        len = usart_console_gets(buf, 128);
        if (len) {
            printf("\nYou entered: '%s'\n", buf);
            trace_if_needed(buf);
        } else {
            printf("\nNo string entered\n");
        }
    }
}
