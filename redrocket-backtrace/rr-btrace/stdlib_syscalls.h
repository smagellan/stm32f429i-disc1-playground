#ifndef __STDLIB_SYSCALLS_H
#define __STDLIB_SYSCALLS_H

#include <sys/reent.h>

_ssize_t _write(int file, const char *ptr, size_t len);
_ssize_t _write_r(struct _reent *r, int file, const char *ptr, size_t len);
_ssize_t _read_r(struct _reent *r, int fd, char *ptr, size_t len);
_ssize_t _read(int fd, char *ptr, size_t len);

size_t usart_console_gets(char *s, size_t len);

void usart_console_putc(char c);
char usart_console_getc(int wait);

#endif /* generic header protector */