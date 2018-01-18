#!/bin/bash

####################
#### TITLE:  Convert DICOM to BIDS format @FPPW.
####
#### Contents:
####
#### Source Files: git@github.com:NeuroStat/CustomFormatBIDS.git
#### First Modified: 25/09/17
#### Notes:
#################


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Global Variables specified by USER
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Date of initial data release: format YEAR-MM-DD
InitialDate="2018-01-17"

# Location of raw data folder, containing subjects in different folders
RawData="/home/hannelore/Documents/BIDS/mydicom"

# Location of BIDS output
OutputBIDS="/home/hannelore/Documents/BIDS/mybids"

# Number of subjects
nsub=$(ls $RawData | wc -l)
echo "Number of subjects to convert: $nsub"

# List subject names (how they should be called in BIDS format)
subID[1]="CON01"
subID[2]="CON02"
subID[3]="CON03"
subID[4]="CON04"
subID[5]="CON05"
subID[6]="CON06"
subID[7]="CON07"
subID[8]="CON08"
subID[9]="CON09"
subID[10]="CON10"
subID[11]="CON11"
subID[12]="PAT01"
subID[13]="PAT02"
subID[14]="PAT03"
subID[15]="PAT05"
subID[16]="PAT06"
subID[17]="PAT07"
subID[18]="PAT08"
subID[19]="PAT10"
subID[20]="PAT11"
subID[21]="PAT13"
subID[22]="PAT14"
subID[23]="PAT15"
subID[24]="PAT16"
subID[25]="PAT17"
subID[26]="PAT19"
subID[27]="PAT20"
subID[28]="PAT22"
subID[29]="PAT23"
subID[30]="PAT24"
subID[31]="PAT25"
subID[32]="PAT26"
subID[33]="PAT27"
subID[34]="PAT28"
subID[35]="PAT29"
subID[36]="PAT31"


# NAMESPACE: how are your ORIGINAL folders called?
# Leave empty if not available
# Add between brackets if multiple names for multiple runs
ANATNAME="T1"
RESTNAME="fMRI"
DWINAME="DWI"
DWIPANAME="DWI_PA"


# NAMESPACE: some labels with info
# Leave empty if not available/unknown
ACQUISITION=""  # Custom label to distinguish different sets of parameters used for acquiring data.
CE=""           # CE stands for contrast ehanced images
REC=""          # Can be used to distinguish different reconstruction algorithms
RUN=""          # Index to denote scans of the same modality
MODALITY=""     # Modality
ECHO=""         # Echo for task MRI



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Custom functions
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Rename files sequentially: add parameters to files if needed
function rename_files {
  # Get the BIDS key
  bkey=$2
  # Check whether first parameter is of non zero-length
  if [ -n "$1" ] ; then   # If not so, rename
    # First json files
    for f in *.json
    do
      # The following line adds strings to existing name
      mv $f "${f%.json}_$bkey-"$param".json"
    done
    # Now nifti
    for f in *.nii
    do
      mv $f "${f%.nii}_$bkey-"$param".nii"
    done
  fi
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Global variables
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# to Path dcm2niix
pathDCM2NIIX="/home/hannelore/Programs/dcm2niix/build/bin/dcm2niix"


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Create BIDS folder structure + meta files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Going to output folder
cd ${OutputBIDS}

# Create folders for each subject (and sessions)
for sub in $(eval echo "{1..$nsub}")
do
  subject=${subID[sub]}
  mkdir sub-$subject
  cd sub-$subject
  mkdir ses-preop
  cd ses-preop
  mkdir anat
  mkdir func
  mkdir dwi
  mkdir dwi_PA
  cd ${OutputBIDS}
done

# Create dataset_description
cat <<EOF > "$OutputBIDS"/dataset_description.json
{
    "BIDSVersion": "1.0.2",
    "License": "This dataset is made available under the Public Domain Dedication and License \nv1.0, whose full text can be found at \nhttp://www.opendatacommons.org/licenses/pddl/1.0/. \nWe hope that all users will follow the ODC Attribution/Share-Alike \nCommunity Norms (http://www.opendatacommons.org/norms/odc-by-sa/); \nin particular, while not legally required, we hope that all users \nof the data will acknowledge the OpenfMRI project and NSF Grant \nOCI-1131441 (R. Poldrack, PI) in any publications.",
    "Name": "Brain Tumor Connectomics - FPPW",
    "Authors": ["Hannelore Aerts", "Daniele Marinazzo"],
    "Acknowledgements": "Data acquisition was funded by ..."
    "HowToAcknowledge": "Instructions how researchers using this dataset should acknowledge the original authors.",
    "Funding": "BOF (grant numbers)"
}
EOF

# Create README
cat <<EOF > "$OutputBIDS"/README.md
# README
Please edit this file manually. It should contain some general information about the dataset.
EOF

# Create CHANGES
cat <<EOF > "$OutputBIDS"/CHANGES.md
Please add additional changes with dates and version numbers of dataset here [this line can be removed].

1.0.0 $InitialDate

  - initial release
EOF

# Create participant list: tab seperated file
# First create subs array and possibly other variables
declare -a subsA
declare -a varS
for sub in $(eval echo "{1..$nsub}")
do
  subsA[(($sub - 1))]=sub-$subject
  varS[(($sub - 1))]=NA        # Empty array for participants list
done
# Then create 3 columns, with the subject ids and extra info
# First print header
printf '%-14s\t %-3s\t %-3s\n' \
  participant_id sex age >> participants.tsv
# Now add the information
for ((i=0; i< "${#subsA[@]}"; i++))
do
  printf "%-14s\t %-3s\t %3s\n" "${subsA[$i]}" "${varS[$i]}" "${varS[$i]}" >> participants.tsv
done
echo "EDIT THIS FILE" >> participants.tsv



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Convert anatomical files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for sub in $(eval echo "{1..$nsub}")
do
  subject=${subID[sub]}
  # Define the output folder
  outSubAnat="$OutputBIDS"/sub-"$subject"/ses-preop/anat/
  # Go to subject's folder
  cd "$RawData"/"$subject"T1
  # Convert using dcm2niix
  "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubAnat" "$ANATNAME"
  # Go back to output folder and rename files to correct BIDS name structure
  cd "$outSubAnat"
  mv *.json sub-"$subject"_T1w.json
  mv *.nii sub-"$subject"_T1w.nii

  # Renaming extra info is sequential: add if parameters are supplied
  # ACQUISITION
  rename_files "$ACQUISITION" "acq"
  # Renaming CE
  rename_files "$CE" "ce"
  # Renaming REC
  rename_files "$RCE" "rce"
  # Renaming RUN
  rename_files "$RUN" "run"
  # Renaming MODALITY
  rename_files "$MODALITY" "mod"
done


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Convert functional files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for sub in $(eval echo "{1..$nsub}")
do
  subject=${subID[sub]}
  # Define the output folder
  outSubFunc="$OutputBIDS"/sub-"$subject"/ses-preop/func/
  # Go to subject's folder
  cd "$RawData"/"$subject"T1
  # Convert using dcm2niix: take the correct task name provided by user
  "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubFunc" ${RESTNAME}
  # Go back to output folder and rename files to correct BIDS name structure
  cd "$outSubFunc"
  mv *.json sub-"$subject"_task-rest.json
  mv *.nii sub-"$subject"_task-rest.nii

  # Renaming extra info is sequential: add if parameters are supplied
  # ACQUISITION
  rename_files "$ACQUISITION" "acq"
  # Renaming REC
  rename_files "$RCE" "rce"
  # Renaming RUN
  rename_files "$RUN" "run"
  # Renaming ECHO
  rename_files "$ECHO" "echo"

  # Add _bold to files
  for f in *.json
  do
    mv $f "${f%.json}_bold.json"
  done
  for f in *.nii
  do
    mv $f "${f%.nii}_bold.nii"
  done
done


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Convert diffusion files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for sub in $(eval echo "{1..$nsub}")
do
  subject=${subID[sub]}
  # Define the output folder
  outSubDwi="$OutputBIDS"/sub-"$subject"/ses-preop/dwi/
  # Go to subject's folder
  cd "$RawData"/"$subject"T1
  # Convert using dcm2niix: take the correct task name provided by user
  "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubDwi" ${DWINAME}
  # Go back to output folder and rename files to correct BIDS name structure
  cd "$outSubDwi"
  mv *.json sub-"$subject"_dwi.json
  mv *.nii sub-"$subject"_dwi.nii
  mv *.bval sub-"$subject"_dwi.bval
  mv *.bvec sub-"$subject"_dwi.bvec

  # Renaming extra info is sequential: add if parameters are supplied
  # ACQUISITION
  rename_files "$ACQUISITION" "acq"
  # Renaming REC
  rename_files "$RCE" "rce"
  # Renaming RUN
  rename_files "$RUN" "run"
  # Renaming ECHO
  rename_files "$ECHO" "echo"
done


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Convert diffusion PA files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for sub in $(eval echo "{1..$nsub}")
do
  subject=${subID[sub]}
  # Define the output folder
  outSubDwiPA="$OutputBIDS"/sub-"$subject"/ses-preop/dwi_PA/
  # Go to subject's folder
  cd "$RawData"/"$subject"T1
  # Convert using dcm2niix: take the correct task name provided by user
  "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubDwiPA" ${DWIPANAME}
  # Go back to output folder and rename files to correct BIDS name structure
  cd "$outSubDwiPA"
  mv *.json sub-"$subject"_dwi_PA.json
  mv *.nii sub-"$subject"_dwi_PA.nii

  # Renaming extra info is sequential: add if parameters are supplied
  # ACQUISITION
  rename_files "$ACQUISITION" "acq"
  # Renaming REC
  rename_files "$RCE" "rce"
  # Renaming RUN
  rename_files "$RUN" "run"
  # Renaming ECHO
  rename_files "$ECHO" "echo"
done

