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
$InitialDate="2017-11-06"

# Location of raw data folder, containing subjects in different folders
$RawData="/Volumes/1_5_TB_Han_HDD/BIDS_course/AllSub"

# Location of BIDS output
$OutputBIDS="/Volumes/1_5_TB_Han_HDD/BIDS_course/OutBIDS"

# Number of subjects
$nsub=2

# Number of sessions per subject
$nsession=2
# If this number > 1, then flag
$SessFlag=$FALSE
if ($nsession -gt 1) { $SessFlag=$TRUE }

# Does your data contain resting state data (TRUE/FALSE) or DWI (TRUE/FALSE):
$REST=$TRUE
$DWI=$FALSE

# NAMESPACE: how are your ORIGINAL folders called?
# Leave empty if not available
# Add between brackets (seperated by comma)
#     if multiple names for multiple runs
$TASKNAME=@("EP2D_FEAR_RUN1_0004", "EP2D_FEAR_RUN2_0005")
$RESTNAME="EP2D_RESTING_STATE_"
$ANATNAME="T1_MPRAGE_0002"

$INHOMOGNAME="GRE_FIELD_MAPPING_0006"
$B0NAME="GRE_FIELD_MAPPING_0007"

# How do you want your fMRI images to be called: TASK LABEL of OUTPUT
$TASKOUTLBL="FEAR"

# NAMESPACE: pre-fix of your subject: without number
$prefsub='sub-'

# NAMESPACE: some labels with info
# Leave empty if not available/unknown
$ACQUISITION=""  # Custom label to distinguish different sets of parameters used for acquiring data.
$CE=""           # CE stands for contrast ehanced images
$REC=""          # Can be used to distinguish different reconstruction algorithms
$RUN=""          # Index to denote scans of the same modality
$MODALITY=""     # Modality
$ECHO=""         # Echo for task MRI


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Checks
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Check whether system is Windows
If ($IsWindows -eq $False) {
  Write-Host 'WARNING - this script is written for Windows'
}
If ($IsWindows -eq $False) {
  $WindowsMessage = "CONVERTING DICOM TO BIDS.
Windows OS detected.
The following contains info about your system and log of conversion to BIDS standard."
Out-File -FilePath $RawData/logBIDS.txt -InputObject $WindowsMessage
}

# Write system info and version of PowerShell to logBIDS.txt
Start-Transcript -path $RawData/logBIDS.txt -append
Out-File -FilePath $RawData/logBIDS.txt -InputObject $PSVersionTable.PSVersion -Append

# Number of task names should match number of sessions
if ($nsession -ne $TASKNAME.length) {
  Write-Host 'ERROR - number of sessions does not match number of task names'
  Write-Host 'Terminating script'
  exit 314
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Global variables
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Point to dcm2niix
$pathDCM2NIIX="/Applications/MRIcroGL/MRIcroGL.app/Contents/Resources/dcm2niix"


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Create BIDS folder structure + meta files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Going to output folder
cd ${OutputBIDS}

# Create folders for each subject (and sessions)
for($sub=1; $sub -le $nsub; $sub++){
  mkdir sub-$sub
  cd sub-$sub
  if ($SessFlag -eq $TRUE) {
    for($sess=1; $sess -le $nsession; $sess++){
      mkdir ses-$sess
      cd ses-$sess
      mkdir anat
      mkdir func
      cd ..
    }
  }
  if ($SessFlag -eq $FALSE) {
    mkdir ses-$sess
    cd ses-$sess
    mkdir anat
    mkdir func
    cd ..
  }
  cd ${OutputBIDS}
}


# Create dataset_description
$DatDescr=('{
    "BIDSVersion": "1.0.2",
    "License": "This dataset is made available under the Public Domain Dedication and License \nv1.0, whose full text can be found at \nhttp://www.opendatacommons.org/licenses/pddl/1.0/. \nWe hope that all users will follow the ODC Attribution/Share-Alike \nCommunity Norms (http://www.opendatacommons.org/norms/odc-by-sa/); \nin particular, while not legally required, we hope that all users \nof the data will acknowledge the OpenfMRI project and NSF Grant \nOCI-1131441 (R. Poldrack, PI) in any   publications.",
    "Name": "Fear Task - FPPW",
    "Authors": ["1st author", "2nd author"],
    "Acknowledgements": "who should be acknowledged in helping to collect the data",
    "HowToAcknowledge": "Instructions how researchers using this dataset should acknowledge the original authors.",
    "Funding": "source of funding (grant numbers)"
}')
# Write to file
Out-File -FilePath $OutputBIDS\dataset_description.json -InputObject $DatDescr

# Create README
$readme='#README
Please edit this file manually. It should contain some general information about the dataset.'
Out-File -FilePath $OutputBIDS\README.md -InputObject $readme

# Create CHANGES
$changes = "Please add additional changes with dates and version numbers of dataset here [this line can be removed].

1.0.0 $InitialDate

  - initial release"
Out-File -FilePath $OutputBIDS\CHANGES.md -InputObject $changes


# Create participant list: tab seperated file
# To start with, we just have the list of subjects and two extra variables.
# User should change this.
# Create 3 columns, with the subject ids and extra info
# First create header
$headerPart= "participant_id `t sex `t age"
Out-File -FilePath $OutputBIDS\participants.tsv -InputObject $headerPart -Width 50
# Now add info
for($sub = 1; $sub -le $nsub; $sub++) {
  $SubjInfo="sub-$sub `t` NA `t` NA"
  Out-File -FilePath $OutputBIDS\participants.tsv -InputObject $SubjInfo -Append
}
$closeMessagePart="`n `n Please edit this file manually or replace it with your own tab separated subject info."
Out-File -FilePath $OutputBIDS\participants.tsv -InputObject $closeMessagePart -Append



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Convert anatomical files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Convert the structural image for each subject (and possibly session)
for($sub = 1; $sub -le $nsub; $sub++) {
  # For loop over the sessions if needed
  if ($SessFlag -eq $TRUE) {
    for($sess = 1; $sess -le $nsession; $sess++) {
      # Define the output folder
      $outSubAnat="$OutputBIDS/sub-$sub/ses-$sess/anat/"
      # Go to subject's folder
      cd $RawData/$prefsub$sub/
      # Convert using dcm2niix, pipe output to logBIDS.txt
      Start-Process -FilePath $pathDCM2NIIX -ArgumentList "-ba y -z n -v y -o $outSubAnat $ANATNAME" -Wait -RedirectStandardOutput $RawData/logBIDS.txt
      # Go back to output folder and rename files to correct BIDS name structure
      cd $outSubAnat
      # Rename files to correct BIDS name structure.
      # First retreive names, then pipe to rename command
      Get-ChildItem *.json | Rename-Item -NewName "sub-$sub`_ses-$sess.json"
      Get-ChildItem *.nii | Rename-Item -NewName "sub-$sub`_ses-$sess.nii"

      ## Renaming extra info is sequential: add if parameters are supplied
      ## ACQUISITION
      #rename_files "$ACQUISITION" "acq"
      ## Renaming CE
      #rename_files "$CE" "ce"
      ## Renaming REC
      #rename_files "$RCE" "rce"
      ## Renaming RUN
      #rename_files "$RUN" "run"
      ## Renaming MODALITY
      #rename_files "$MODALITY" "mod"
    }
  # End of session, part 1 if statement
  }
  # Only one session
  if ($SessFlag -eq $FALSE) {
    # Define the output folder
    $outSubAnat="$OutputBIDS/sub-$sub/anat/"
    # Go to subject's folder
    cd $RawData/$prefsub$sub/
    # Convert using dcm2niix, pipe output to log.txt
    Start-Process -FilePath $pathDCM2NIIX -ArgumentList "-ba y -z n -v y -o $outSubAnat $ANATNAME" -Wait -RedirectStandardOutput $RawData/logBIDS.txt
    # Go back to output folder and rename files to correct BIDS name structure
    cd "$outSubAnat"
    # First retreive names, then pipe to rename command
    Get-ChildItem *.json | Rename-Item -NewName "sub-$sub.json"
    Get-ChildItem *.nii | Rename-Item -NewName "sub-$sub.nii"

    ## Renaming extra info is sequential: add if parameters are supplied
    ## ACQUISITION
    #rename_files "$ACQUISITION" "acq"
    ## Renaming CE
    #rename_files "$CE" "ce"
    ## Renaming REC
    #rename_files "$RCE" "rce"
    ## Renaming RUN
    #rename_files "$RUN" "run"
    ## Renaming MODALITY
    #rename_files "$MODALITY" "mod"
  # End of session if statement
  }
}



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Provide warnings
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Write-Host "WARNING: re-running this script will overwrite all manual changes made to files such as README, CHANGES, etc!"

Stop-Transcript
