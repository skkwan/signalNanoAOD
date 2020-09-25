# Embedded samples to NanoAOD

Convert HiggsToTauTau Embedded samples to NanoAOD. See [list of samples](https://twiki.cern.ch/twiki/bin/viewauth/CMS/HiggsToTauTauWorkingLegacyRun2#Embedded_2018) and [official instructions for NanoAOD conversion](https://twiki.cern.ch/twiki/bin/viewauth/CMS/TauTauEmbeddingSamples2018#NanoAOD_Conversion) (TWiki log-in needed).

## Setup
On an lxplus7 machine:
```
cmsrel 10_6_16
cd CMSSW_10_6_16/src
```
and git clone this repo.

## Converting MiniAOD to NanoAOD

1. Get the logical file names to the input MiniAOD samples (edit `logicalFileNames.txt`)
```
cmsenv
voms-proxy-init --voms cms
cd getFilePaths/
cat logicalFileNames.txt   
source getFilePaths.sh
```

2. Make a `.csv` list of datasets like this (Year, name of dataset, path to `.list` logical file names made in previous step) :
`2018,EmbeddingRun2018B-MuTau,getFilePaths/2018/EmbeddingRun2018B-MuTau.list`	    

3. Edit `runNanoProd.sh` so it is pointing to the correct `.csv` list of datasets, and run the script (do this in a screen session
because it is time-consuming; also it makes one task (one PID) per sample, so beware)
```
cmsenv
voms-proxy-init --voms cms
source runNanoProd.sh
```

4. Hadd the individual NanoAOD files into one bigger file (`hadd -help`), save it to EOS area.