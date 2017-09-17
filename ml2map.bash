#!/bin/bash
MLDIR=$1
MAPDIR=$2
mlscp=./ml.scp
ml2mapscp=./ml2map.scp
rm $mlscp
rm $ml2mapscp
#./ml2map.bash "C:/Users/Ali/Favorites/Desktop/kenkyuu/ForAimen/02hmm/MFCC_E_D_A/25states/05" "C:/Users/Ali/Favorites/Desktop/kenkyuu/ForAimen/03map"
for mlfile in `ls ${MLDIR}/*.hmm`; do
    mapfile=`echo $mlfile |sed -e "s@${MLDIR}@${MAPDIR}@"`
	echo $mlfile >> $mlscp
    echo "$mlfile $mapfile" >> $ml2mapscp
	echo $mlfile
done

$$MATLAB=/cygdrive/c/Program\ Files/MATLAB/R2016a/bin
$$echo "ml2map('${mlscp}','${ml2mapscp}');quit;" | $MATLAB -nojvm -nosplash -nodesktop
