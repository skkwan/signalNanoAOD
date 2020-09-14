# Usage: (e.g. on lxplus)
# First make sure your grid certificate is created (voms proxy init etc.)

LFNLIST="logicalFileNames.txt"

while IFS=, read -r YEAR DATASETNAME DASDATASET
do 
  echo "Year: ${YEAR}, dataset name: ${DATASETNAME}, DAS dataset: ${DASDATASET}"
  mkdir -p ${YEAR}
  DESTINATION=${YEAR}/${DATASETNAME}.list  
  TEMP=${YEAR}/${DATASETNAME}-temp.list
  dasgoclient --query="file dataset=${DASDATASET} instance=prod/phys03" > ${TEMP}

  # Pre-pend the redirector in front of each line
  awk '{print "root://cmsxrootd.fnal.gov/" $0}' ${TEMP} > ${DESTINATION}

  # Check it looks ok
  head -5 ${DESTINATION}
  
  # Remoe the temp file
  rm ${TEMP}

done < "${LFNLIST}"
