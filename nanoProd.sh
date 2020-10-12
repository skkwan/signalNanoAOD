#!/bin/bash

# Usage: source runNanoProd.sh [samples.csv]

SAMPLES=$1

# Make sure voms and cmsenv are run
cmsenv
#cmsRun scripts/nanoProd_18abc_NANO.py


BASE_SCRIPT="scripts/SUSYsamples_NANO.py"
# We will append the lines in this .txt file to the example config.py 
TEMPLATE=$(cat "scripts/suffixForSIMNanoProdPython.txt")


while IFS=, read -r YEAR SAMPLE LISTFOLDER
do
    {
	echo ">>> runNanoProd.sh: Produce NanoAOD for sample ${SAMPLE} and input list of files: ${LIST}"

	# Declare scratch directory to put each config.py file
	TEMP_DIR="temp/${YEAR}/${SAMPLE}/"
	# Declare directory for output NanoAOD n-tuples
	OUT_DIR="/eos/user/s/skkwan/signalNanoAOD/${YEAR}/${SAMPLE}/"
	mkdir -p ${TEMP_DIR}
	mkdir -p ${OUT_DIR}

	for s in ${LISTFOLDER}*
	do
	    echo ${s}
	    STEM=$(basename "${s}" ".${s##*.}")
	    echo ${STEM}

	    # Declare output NanoAOD n-tuple file path and name                                                             
            OUT_PATH_ONLY="${OUT_DIR}${STEM}_NANO.root"
            echo ${OUT_PATH_ONLY}

            if test -f "${OUT_PATH_ONLY}"; then
                echo ">>> ${OUT_PATH_ONLY} exists, skipping"
                continue
            fi
            OUT_PATH="file:${OUT_PATH_ONLY}"


	    # Replace INPUT.ROOT and OUTPUT.ROOT in the template with our files
	    list=$(cat ${s})
	    TEMPLATE2="${TEMPLATE/\'INPUT.ROOT\'/${MYLIST}}"
	    TEMPLATE3="${TEMPLATE2/OUTPUT.ROOT/${OUT_PATH}}"

	    # Declare the unique Python script, create it
	    SINGLE_PYTHON="${TEMP_DIR}tempJOB_${STEM}.py"
	    cp ${BASE_SCRIPT} ${SINGLE_PYTHON}
	    echo "${TEMPLATE3}" >> ${SINGLE_PYTHON}
	    
	    LOG=${TEMP_DIR}"logRun_${STEM}"
	    rm ${LOG}
	    echo ${LOG}
	    cmsRun ${SINGLE_PYTHON} | tee ${LOG}
	    
	done
	    #	rm -r ${TEMP_DIR}/*.py
    } &
done < ${SAMPLES} 

wait



echo "All done [Time: $(TZ=America/New_York date)]"
