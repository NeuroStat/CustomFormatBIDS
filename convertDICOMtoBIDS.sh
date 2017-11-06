#!/bin/sh

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
InitialDate="2017-11-06"

# Location of raw data folder, containing subjects in different folders
RawData="/Volumes/1_5_TB_Han_HDD/BIDS_course/AllSub"

# Location of BIDS output
OutputBIDS="/Volumes/1_5_TB_Han_HDD/BIDS_course/OutBIDS"

# Number of subjects
nsub=4

# Number of sessions per subject
nsession=2
# If this number > 1, then flag
SessFlag=FALSE
if [ $nsession > 1 ] ; then
  SessFlag=TRUE
fi

# Does your data contain resting state data (TRUE/FALSE) or DWI (TRUE/FALSE):
REST=TRUE
DWI=FALSE

# NAMESPACE: how are your ORIGINAL folders called?
# Leave empty if not available
# Add between brackets if multiple names for multiple runs
TASKNAME=("EP2D_FEAR_RUN1_0004" "EP2D_FEAR_RUN2_0005")
RESTNAME="EP2D_RESTING_STATE_"
ANATNAME="T1_MPRAGE_0002"
INHOMOGNAME="GRE_FIELD_MAPPING_0006"
B0NAME="GRE_FIELD_MAPPING_0007"

# How do you want your fMRI images to be called: TASK LABEL of OUTPUT
TASKOUTLBL="FEAR"

# NAMESPACE: pre-fix of your subject: without number
prefsub='sub-'

# NAMESPACE: some labels with info
# Leave empty if not available/unknown
ACQUISITION=""  # Custom label to distinguish different sets of parameters used for acquiring data.
CE=""           # CE stands for contrast ehanced images
REC=""          # Can be used to distinguish different reconstruction algorithms
RUN=""          # Index to denote scans of the same modality
MODALITY=""     # Modality
ECHO=""         # Echo for task MRI


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Checks
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Number of task names should match number of sessions
if [ $nsession != ${#TASKNAME[@]} ] ; then
  echo 'WARNING - NUMBER OF SESSIONS DOES NOT MATCH OF NUMER OF TASK NAMES'
  exit 314
fi


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

# Path to dcm2niix
pathDCM2NIIX="/Applications/MRIcroGL/MRIcroGL.app/Contents/Resources/dcm2niix"


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Create BIDS folder structure + meta files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Going to output folder
cd ${OutputBIDS}

# Create folders for each subject (and sessions)
for sub in $(eval echo "{1..$nsub}")
do
  mkdir sub-$sub
  cd sub-$sub
  if [ ${SessFlag} = TRUE ] ; then
    for sess in $(eval echo "{1..$nsession}")
    do
      mkdir ses-$sess
      cd ses-$sess
      mkdir anat
      mkdir func
      cd ..
    done
  fi
  if [ ${SessFlag} = FALSE ] ; then
    mkdir ses-$sess
    cd ses-$sess
    mkdir anat
    mkdir func
    cd ..
  fi
  cd ${OutputBIDS}
done

# Create dataset_description
cat <<EOF > "$OutputBIDS"/dataset_description.json
{
    "BIDSVersion": "1.0.2",
    "License": "This dataset is made available under the Public Domain Dedication and License \nv1.0, whose full text can be found at \nhttp://www.opendatacommons.org/licenses/pddl/1.0/. \nWe hope that all users will follow the ODC Attribution/Share-Alike \nCommunity Norms (http://www.opendatacommons.org/norms/odc-by-sa/); \nin particular, while not legally required, we hope that all users \nof the data will acknowledge the OpenfMRI project and NSF Grant \nOCI-1131441 (R. Poldrack, PI) in any publications.",
    "Name": "Fear Task - FPPW",
    "Authors": Wisniewski, David,
    "Acknowledgements": who should be acknowledged in helping to collect the data,
    "HowToAcknowledge": Instructions how researchers using this dataset should acknowledge the original authors.
    "Funding": source of funding (grant numbers)
}
EOF

# Create README
cat <<EOF > "$OutputBIDS"/README.md
# README
Please edit this file manually. It should contain some general information about the dataset.
EOF

# Create CHANGES
cat <<EOF > "$OutputBIDS"/CHANGES.md
Please provide additional changes here.

1.0.0 $InitialDate

  - initial release
EOF

# Create participant list: tab seperated file
# First create subs array and possibly other variables
declare -a subsA
declare -a varS
for sub in $(eval echo "{1..$nsub}")
do
  subsA[(($sub - 1))]=sub-$sub
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

# Convert the structural image for each subject (and possibly session)
for sub in $(eval echo "{1..$nsub}")
do
  # For loop over the sessions if needed
  if [ ${SessFlag} = TRUE ] ; then
    for sess in $(eval echo "{1..$nsession}")
    do
      # Define the output folder
      outSubAnat="$OutputBIDS"/sub-"$sub"/ses-"$sess"/anat/
      # Go to subject's folder
      cd "$RawData"/"$prefsub"$sub/
      # Convert using dcm2niix
      "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubAnat" "$ANATNAME"
      # Go back to output folder and rename files to correct BIDS name structure
      cd "$outSubAnat"
      mv *.json sub-"$sub"_ses-"$sess".json
      mv *.nii sub-"$sub"_ses-"$sess".nii
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
  # End of session, part 1 if statement
  fi
  # For loop without the sessions if needed
  if [ ${SessFlag} = FALSE ] ; then
    # Define the output folder
    outSubAnat="$OutputBIDS"/sub-"$sub"/anat/
    # Go to subject's folder
    cd "$RawData"/"$prefsub"$sub/
    # Convert using dcm2niix
    "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubAnat" "$ANATNAME"
    # Go back to output folder and rename files to correct BIDS name structure
    cd "$outSubAnat"
    mv *.json sub-"$sub".json
    mv *.nii sub-"$sub".nii

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
  # End of session if statement
  fi
done


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Convert functional files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Convert the functional image for each subject (and possibly session)
for sub in $(eval echo "{1..$nsub}")
do
  # For loop over the sessions if needed
  if [ ${SessFlag} = TRUE ] ; then
    for sess in $(eval echo "{1..$nsession}")
    do
      # Define the output folder
      outSubFunc="$OutputBIDS"/sub-"$sub"/ses-"$sess"/func/
      # Go to subject's folder
      cd "$RawData"/"$prefsub"$sub/
      # Convert using dcm2niix: take the correct task name provided by user
      "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubFunc" ${TASKNAME[($sess - 1)]}
      # Go back to output folder and rename files to correct BIDS name structure
      cd "$outSubFunc"
      mv *.json sub-"$sub"_ses-"$sess"_task-"$TASKOUTLBL".json
      mv *.nii sub-"$sub"_ses-"$sess"_task-"$TASKOUTLBL".nii
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
  # End of session, part 1 if statement
  fi
  # For loop without the sessions if needed
  if [ ${SessFlag} = FALSE ] ; then
    # Define the output folder
    outSubFunc="$OutputBIDS"/sub-"$sub"/func/
    # Go to subject's folder
    cd "$RawData"/"$prefsub"$sub/
    # Convert using dcm2niix: take the correct task name provided by user
    "$pathDCM2NIIX" -ba y -z n -v y -o "$outSubFunc" ${TASKNAME[($sess - 1)]}
    # Go back to output folder and rename files to correct BIDS name structure
    cd "$outSubFunc"
    mv *.json sub-"$sub"_task-"$TASKOUTLBL".json
    mv *.nii sub-"$sub"_task-"$TASKOUTLBL".nii

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

  # End of session if statement
  fi
done


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Convert
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
