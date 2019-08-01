Based on [redrocket-backtrace](https://github.com/red-rocket-computing/backtrace) and opencm3 [usart\_console](https://github.com/libopencm3/libopencm3-examples/tree/master/examples/stm32/f4/stm32f429i-discovery/usart_console).

rr-backtrace must be reconfigured for hard-fp:
1) add '-mfloat-abi=hard -mfpu=fpv4-sp-d16'
2) adjust cortex index from 3 to 4

to build:
```bash
make -C rr-btrace/ V=1 Q="" clean
make -C rr-btrace/ V=1 Q=""
make -C rr-btrace/ V=1 Q="" flash
```
