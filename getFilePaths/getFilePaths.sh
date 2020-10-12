# Usage: (e.g. on lxplus)
# First make sure your grid certificate is created (voms proxy init etc.)

LFNLIST="logicalFileNames.txt"

while IFS=, read -r YEAR DATASETNAME DASDATASET
do 
  echo "Year: ${YEAR}, dataset name: ${DATASETNAME}, DAS dataset: ${DASDATASET}"
  mkdir -p ${YEAR}
  
  FULLLIST=${YEAR}/${DATASETNAME}.list  
  TEMP=${YEAR}/${DATASETNAME}-temp.list
  dasgoclient --query="file dataset=${DASDATASET} instance=prod/phys03" > ${TEMP}

  # Pre-pend the redirector in front of each line
  awk '{print "root://cmsxrootd.fnal.gov/" $0}' ${TEMP} > ${FULLLIST}

  # Check it looks ok
  head -5 ${FULLLIST}

  # Remove the temp file
  rm ${TEMP}

  # Make a directory to hold the batches
  BATCHDIR=${YEAR}/${DATASETNAME}/
  mkdir -p ${BATCHDIR}
  rm ${BATCHDIR}/*

  # python3 readNlines.py 2018/EmbeddingRun2018A-MuTau.list 2018/EmbeddingRun2018A-MuTau/ EmbeddingRun2018
  python3 readNlines.py ${FULLLIST} ${BATCHDIR} ${DATASETNAME}

done < "${LFNLIST}"
