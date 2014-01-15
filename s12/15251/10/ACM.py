###########################
## Auto Cannibal Maker   ##
##                       ##
## Name: Karan Sikka     ##
###########################
import sys
def ACM(eat):
    print "imdonewiththis = \'imdonewiththis = %s\\n" + repr(eat)[1:len(repr(eat)) - 1] + "\\nEat(imdonewiththis%% repr(imdonewiththis))\\n\'\n" + eat + "\nEat(imdonewiththis% repr(imdonewiththis))"
    program = sys.stdin.read()
    ACM(program)
