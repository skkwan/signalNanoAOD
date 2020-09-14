#!/bin/bash

# Usage: source runNanoProd.sh [samples.csv]

SAMPLES=$1

# Make sure voms and cmsenv are run
cmsenv
#cmsRun scripts/nanoProd_18abc_NANO.py


BASE_SCRIPT="scripts/nanoProd_18abc_NANO.py"
# Use different base script if 2018D embedded                                                                                                                                    
if [[ ${SAMPLE} == *"2018D"* ]]; then
    BASE_SCRIPT="scripts/nanoProd_18d_NANO.py"
fi


# Loop through .csv of datasets, check input dir exists
while IFS=, read -r YEAR SAMPLE LIST
do
    if [[ -f ${LIST} ]]; then
        echo "   >>> ${LIST} exists"
    else
        echo "   >>> [ERROR]: Input list of files not found at ${LIST}"
    fi

done < ${SAMPLES}

while IFS=, read -r YEAR SAMPLE LIST
do
    {
	echo ">>> runNanoProd.sh: Produce NanoAOD for sample ${SAMPLE} and input list of files: ${LIST}"

	TEMP_DIR="temp/${YEAR}/${SAMPLE}"
	OUT_DIR="nanoAODFiles/${YEAR}/${SAMPLE}/"
	mkdir -p ${TEMP_DIR}
	mkdir -p ${OUT_DIR}
	rm ${TEMP_DIR}/*.py


	cat ${LIST} | while read s || [[ -n $s ]];
	do
	    STEM=$(basename "${s}" ".${s##*.}")
	    
	    TEMPLATE=$(cat "scripts/suffixForNanoProdPython.txt")
	    echo ${STEM}
	    
	    OUT_PATH="file:${OUT_DIR}${STEM}_nano.root"
	    TEMPLATE2="${TEMPLATE/INPUT.ROOT/$s}"
	    TEMPLATE3="${TEMPLATE2/OUTPUT.ROOT/${OUT_PATH}}"

	    SINGLE_PYTHON="${TEMP_DIR}/tempJOB_${STEM}.py"
	    cp ${BASE_SCRIPT} ${SINGLE_PYTHON}
	    echo "${TEMPLATE3}" >> ${SINGLE_PYTHON}
	    
	    cmsRun ${SINGLE_PYTHON}
	done

	rm -r ${TEMP_DIR}/*.py
    } &
done < ${SAMPLES}

wait



echo "All done [Time: $(TZ=America/New_York date)]"
