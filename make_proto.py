#! /usr/bin/python
# -*- coding: utf-8 -*-

from optparse import OptionParser

#############
# arguments #
#############
usage="usage: %prog [options] > outfile"
parser=OptionParser(usage=usage)

# options
parser.add_option("-d",
                  dest="VecSize", default=12, metavar="N", type=int,
                  help="VecSize                         [%default]")
parser.add_option("-k",
                  dest="TARGETKIND", default="MFCC", metavar="s",
                  help="TARGETKIND                      [%default samples]")
parser.add_option("-s",
                  dest="NumStates", default=3, metavar="N", type=int,
                  help="NumStates (without 1st & Last)  [%default dB]")
# store values
(options, args) = parser.parse_args()
VecSize         = options.VecSize
TARGETKIND      = options.TARGETKIND
NumStates       = options.NumStates


####################
# output proto HMM #
####################

# Print Header
print("~o <VecSize> " + str(VecSize) + " <" + TARGETKIND + ">")
print("<BeginHMM>")
print("<NumStates> " + str(NumStates+2))


# Print States' Parameters
for states in range(NumStates):
    print("<State> " + str(states+2))

    # Mean
    print("<Mean> " + str(VecSize))
    for i in range(VecSize): print("0.0"),
    print("\n"),

    # Variance
    print("<Variance> " + str(VecSize))
    for i in range(VecSize): print("1.0"),
    print("\n"),


# Print Transision Probability
print("<TransP> " + str(NumStates+2))
print("0.0 1.0"),
for states in range(NumStates):
    print("0.0"),
print("\n"),

for states1 in range(1,NumStates+1):
    print("0.0"),
    for states2 in range(1,NumStates+2):
        if states1 == states2:        print("0.6"),
        elif states1 + 1 == states2 : print("0.4"),
        else :                        print("0.0"),
    print("\n"),

for states in range(NumStates+2):
    print("0.0"),
print("\n"),

# Print Footer
print("<EndHMM>"),
