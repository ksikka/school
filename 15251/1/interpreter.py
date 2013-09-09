'''
data structures:
   commands:
      list of commands
   tape:
      list of nonnegative numbers (start at 0)
   memory pointer:
      points to the current spot on the tape
   command pointer:
      points to the current command
   locks:
      list of all locked cells
      \{ adds the current memory pointer to the list
      leaving a loop removes the current mem pointer from the list ONCE

notes:
   cells can only be locked by \{

'''


import sys

def interpret(commands):
    tape = [0]
    memoryPointer = 0
    commandPointer = 0
    locks = []
    while (commandPointer<len(commands)):
        cmd = commands[commandPointer].strip()
        if (cmd=="uparrow"):
            if memoryPointer not in locks:
                tape[memoryPointer]+=1
            commandPointer+=1
        elif (cmd=="leftarrow"):
            if memoryPointer>0:
                memoryPointer-=1
            commandPointer+=1
        elif (cmd=="rightarrow"):
            memoryPointer+=1
            if memoryPointer==len(tape):
                tape.append(0)
            commandPointer+=1
        elif (cmd=="downarrow"):
            if tape[memoryPointer]>0:
                tape[memoryPointer]-=1
            commandPointer+=1
        elif (cmd=="{"):
            locks.append(memoryPointer)
            commandPointer+=1
        elif (cmd=="}"):
            if len(locks)>0:
                loopCounter = tape[locks[-1]]
                #if len(locks)==1: print "loop counter: "+str(loopCounter)
                if loopCounter==0:
                    locks.pop()
                else:
                    newLoc = getMatchingPrevParen(commands,commandPointer)
                    if (newLoc!=-1):
                        commandPointer = newLoc
                    tape[locks[-1]]-=1
            commandPointer+=1
        elif (cmd=="varnothing"):
            if len(locks)>0 and tape[locks[-1]]==0:
                #print "broke out of loop. Lock: "+str(locks[-1])
                locks.pop()
                commandPointer = getMatchingPostParen(commands,commandPointer)
            commandPointer+=1
        elif (cmd=="lhd"):
            c = raw_input("")
           # if len(c)!=0:
            tape[memoryPointer] = ord(c)
            commandPointer+=1
        elif (cmd=="rhd"):
            val = tape[memoryPointer]
            c = chr(val)
            if 32<=val<128:
                sys.stdout.write(c)
            commandPointer+=1
        elif (cmd=="unlhd"):
            inpt = raw_input("")
            tape[memoryPointer] = int("".join([c for c in inpt if "0"<=c<="9"]))
            commandPointer+=1
        elif (cmd=="unrhd"):
            sys.stdout.write(str(tape[memoryPointer])+"\n")
            commandPointer+=1
        else:
            if cmd=="":
                commandPointer+=1
                continue
            print "bad command: "+repr(cmd)
            assert False
                    
#  lhd/rhd/uparrow/rightarrow

def getMatchingPrevParen(commands,commandPointer):
    openCount = 1
    commandPointer-=1
    while (commandPointer>=0):
        if commands[commandPointer]=="}":
            openCount+=1
        elif commands[commandPointer]=="{":
            openCount-=1
            if openCount==0: return commandPointer
        commandPointer-=1
    return commandPointer

def getMatchingPostParen(commands,commandPointer):
    openCount = 1
    while (commandPointer<len(commands)):
        if commands[commandPointer]=="{":
            openCount+=1
        elif commands[commandPointer]=="}":
            openCount-=1
            if openCount==0: return commandPointer
        commandPointer+=1
    return commandPointer

def runFile(fileName):
    f = open(fileName)
    s = f.read()
    f.close()
    s = s.split("\\")
    assert(s.pop(0)=="")
    sys.stdout.write("start{")
    interpret(s)
    sys.stdout.write("}end")

if globals()["__name__"] == "__main__":
    runFile("eFib.txt")
