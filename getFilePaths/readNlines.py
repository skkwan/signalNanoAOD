# readNlines.py

# Example:
# python3 readNlines.py 2018/EmbeddingRun2018A-MuTau.list 2018/EmbeddingRun2018/ EmbeddingRun2018

import argparse
from itertools import islice
import os

def next_n_lines(file_opened, N):
    ''' Each time this function is called, the function returns the next N lines from
    file_opened as a list. '''
    return [x.strip() for x in islice(file_opened, N)]

def main(fullList, outputDir, sample):
    ''' Writes _BATCH_1.list, _BATCH_2.list etc. to outputDir, 250 lines at a time. '''

    if not os.path.exists(outputDir):
        os.mkdir(outputDir)
    print("Directory '%s' opened/created" %outputDir)

    batchNumber = 0
    with open(fullList, 'r') as f:
        while True:
            nextLines = next_n_lines(f, 250)
            if nextLines:
                batchNumber += 1
                print(batchNumber)

                with open(outputDir + sample + '_BATCH_' + str(batchNumber) + '.list', 'w') as targetFile:
                    for l in nextLines:
                        # If not the last line
                        if (l != nextLines[-1]):
                            targetFile.write('\'%s\', ' % l)
                        else:
                            targetFile.write('\'%s\'' % l)

            else:
                break
                

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("fullList", type=str, help="Full path to full .list of logical file names")
    parser.add_argument("outputDir", type=str, help="Folder where smaller .list s will be written")
    parser.add_argument("sample", type=str, help="Name of sample")
    args = parser.parse_args()
    main(args.fullList, args.outputDir, args.sample)
