#!/bin/bash
####################################
./hcopy.bash ALL # MFCC/MELSPEC calculation #revise database directory inside
./trainHMM.bash ALL # word HMM training 

####################################
MLDIR=  # ex model/MFCC_E_D_A/25states/05
MAPDIR=
./ml2map.bash ${MLDIR} ${MAPDIR}

####################### structure feature calculation #############
INPUTDIR=$MAPDIR
OUTPUTROOT=
dim=  # 39/24
blocksize= # 1?2?

MATLAB=/opt/MATLAB/R2015a/bin/matlab
echo "procedure('${INPUTDIR}','${OUTPUTROOT}','${dim}','${blocksize}');"
echo "procedure('${INPUTDIR}','${OUTPUTROOT}','${dim}','${blocksize}');quit;" | $MATLAB -nojvm -nosplash -nodesktop

#### recognition
STRDIR=${OUTPUTROOT}/block${blockSize}
STRMODELDIR=
echo "rec_procedure('${STRDIR}','${STRMODELDIR}')"
echo "rec_procedure('${STRDIR}','${STRMODELDIR}');quit;"| $MATLAB -nojvm -nosplash -nodesktop
