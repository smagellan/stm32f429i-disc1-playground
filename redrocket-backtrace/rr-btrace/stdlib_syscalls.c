#include <errno.h>
#include <sys/unistd.h>
#include <libopencm3/stm32/usart.h>

#include "stdlib_syscalls.h"
#include "btrace.h"

int usart_console_puts_l(const char *ptr, size_t len);

_ssize_t _write_r(struct _reent *r, int fd, const char *ptr, size_t len) {
    r = r;
    return _write(fd, ptr, len);
}

_ssize_t _write(int fd, const char *ptr, size_t len) {
    switch (fd) {
        case STDOUT_FILENO:
        case STDERR_FILENO:
            return usart_console_puts_l(ptr, len);
        default:
            errno = EBADF;
            return -1;
    }
}

int usart_console_puts_l(const char *ptr, size_t len) {
    size_t index;
    for (index = 0; index < len; index++) {
        if (ptr[index] == '\n') {
            usart_console_putc('\r');
        }
        usart_console_putc(ptr[index]);
    }
    return len;
}

/*
 * usart_console_putc(char c)
 *
 * Send the character 'c' to the USART, wait for the USART
 * transmit buffer to be empty first.
 */
void usart_console_putc(char c) {
    uint32_t reg;
    do {
        reg = USART_SR(CONSOLE_UART);
    } while ((reg & USART_SR_TXE) == 0);
    USART_DR(CONSOLE_UART) = (uint16_t) c & 0xff;
}

/*
 * char = usart_console_getc(int wait)
 *
 * Check the console for a character. If the wait flag is
 * non-zero. Continue checking until a character is received
 * otherwise return 0 if called and no character was available.
 */
char usart_console_getc(int wait) {
    uint32_t reg;
    do {
        reg = USART_SR(CONSOLE_UART);
    } while ((wait != 0) && ((reg & USART_SR_RXNE) == 0));
    return (reg & USART_SR_RXNE) ? USART_DR(CONSOLE_UART) : '\000';
}




_ssize_t _read_r(struct _reent *r, int fd, char *ptr, size_t len) {
    r = r;
    return _read(fd, ptr, len);
}

_ssize_t _read(int fd, char *ptr, size_t len) {
    switch (fd) {
        case STDIN_FILENO:
            return usart_console_gets(ptr, len);
        default:
            errno = EBADF;
            return -1;
    }
}


/*
 * size_t usart_console_gets(char *s, size_t len)
 *
 * Wait for a string to be entered on the console, limited
 * support for editing characters (back space and delete)
 * end when a <CR> character is received.
 */
size_t usart_console_gets(char *s, size_t len) {
    char *t = s;
    char c;

    *t = '\000';
    /* read until a <CR> is received */
    while ((c = usart_console_getc(1)) != '\r') {
        if ((c == '\010') || (c == '\127')) {
            if (t > s) {
                /* send ^H ^H to erase previous character */
                usart_console_puts_l("\010 \010", 3);
                t--;
            }
        } else {
            *t = c;
            usart_console_putc(c);
            if ((t - s) < len) {
                t++;
            }
        }
        /* update end of string with NUL */
        *t = '\000';
    }
    return t - s;
}