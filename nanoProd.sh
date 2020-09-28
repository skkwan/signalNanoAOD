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

	# Each file name is like: root://cmsxrootd.fnal.gov//store/user/jbechtel/gc_storage/MuTau_data_2018ABC_CMSSW1020/TauEmbedding_MuTau_data_2018ABC_CMSSW1020_Run2018A/11/merged_10.root
	# We need the last part /11/merged_10.root for a unique output file name

	# Declare scratch directory to put each config.py file
	TEMP_DIR="temp/${YEAR}/${SAMPLE}"
	# Declare directory for output NanoAOD n-tuples
	OUT_DIR="nanoAODFiles/${YEAR}/${SAMPLE}/"
	mkdir -p ${TEMP_DIR}
	mkdir -p ${OUT_DIR}

	cat ${LIST} | while read s || [[ -n $s ]];
	do
	    
	    # Get the file name with extension (merged_10.root, for example)
	    STEM=$(basename "${s}" ".${s##*.}")
	    
	    # Get just the folder name (everything up until /11/ for example)
	    DIR="$(dirname "${s}")"
	    # Get just the last folder name (11 for example)
	    FOLD="$(basename $DIR)"

	    # We will append the lines in this .txt file to the example config.py
	    TEMPLATE=$(cat "scripts/suffixForNanoProdPython.txt")

	    # Declare output NanoAOD n-tuple file path and name
	    OUT_PATH="file:${OUT_DIR}${FOLD}_${STEM}_nano.root"

	    # Replace INPUT.ROOT and OUTPUT.ROOT in the template with our files
	    TEMPLATE2="${TEMPLATE/INPUT.ROOT/$s}"
	    TEMPLATE3="${TEMPLATE2/OUTPUT.ROOT/${OUT_PATH}}"

	    # Declare the unique Python script, create it
	    SINGLE_PYTHON="${TEMP_DIR}/tempJOB_${FOLD}_${STEM}.py"
	    cp ${BASE_SCRIPT} ${SINGLE_PYTHON}
	    echo "${TEMPLATE3}" >> ${SINGLE_PYTHON}
	    
	    # Run one Python script per input embedded file
	    cmsRun ${SINGLE_PYTHON}
	    
	    LOG="logRun_${SAMPLE}"
	    
	    
	done

#	rm -r ${TEMP_DIR}/*.py
    } &
done < ${SAMPLES} 

wait



echo "All done [Time: $(TZ=America/New_York date)]"
