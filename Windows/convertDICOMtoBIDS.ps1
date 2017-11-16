####################
#### TITLE:  Convert DICOM to BIDS format @FPPW.
####
#### Contents:
####
#### Source Files: git@github.com:NeuroStat/CustomFormatBIDS.git
#### First Modified: 25/09/17
#### Notes:
#################


#%%%%%%%%%%%%%%%%%%
## Global Variables
#%%%%%%%%%%%%%%%%%%

# Variables are sourced from user_EDIT.ps1
. ./user_EDIT.ps1

# Working directory of conversion script
$ConvDir=$pwd

# If experiment contains multiple sessions, then flag
$SessFlag=$FALSE
if ($nsession -gt 1) { $SessFlag=$TRUE }

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Warning message
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Write-Host "Please make sure you edit the user_EDIT.ps1 file."

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Log files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Log files: the stdOutLog is a temp log file
$bidsLog = "$RawData/DICOM2BIDS.log"
$stdOutLog = "$RawData/stdOut.log"

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Checks
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Just logical for debugging while using OSX
$debugOSX = $TRUE

if($debugOSX -eq $FALSE){
  # Check whether system is Windows
  if ($IsWindows -eq $False) {
    Write-Host 'ERROR - this script is written for Windows'
    exit 112
  }
  If ($IsWindows -eq $True) {
    $WindowsMessage = "CONVERTING DICOM TO BIDS.
  Windows OS detected.
  The following contains info about your system and log of conversion to BIDS standard."
  Out-File -FilePath $bidsLog -InputObject $WindowsMessage
  }
}

# Write system info (which contains version of PowerShell) to log file
Start-Transcript -path $bidsLog -Append

# Number of task names should match number of sessions
if ($nsession -ne $TASKNAME.length) {
  Write-Host 'ERROR - number of sessions does not match number of task names'
  Write-Host 'Terminating script'
  exit 314
}

# Check whether we have dcm2niix installed
if (-Not (Get-Command $pathDCM2NIIX -errorAction SilentlyContinue)) {
  Write-Host "dcm2niix is not found, please provide the correct path in user_EDIT.ps1"
  exit 111
}

# Write user parameters to log
$ParamMessage="**********************
Parameters inputted by user:
"
Out-File -FilePath $bidsLog -InputObject $ParamMessage -Append
Get-Variable -Scope Local | Out-File -FilePath $bidsLog -Append



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
$DEBUG=$FALSE
if ($DEBUG -eq $FALSE) {

# Convert the structural image for each subject (and possibly session)
for($sub = 1; $sub -le $nsub; $sub++) {
  # For loop over the sessions if needed
  if ($SessFlag -eq $TRUE) {
    for($sess = 1; $sess -le $nsession; $sess++) {
      # Define the output folder
      $outSubAnat="$OutputBIDS/sub-$sub/ses-$sess/anat/"
      # Go to subject's folder
      cd $RawData/$prefsub$sub/
      # Convert using dcm2niix, pipe output to log file
      Start-Process -FilePath $pathDCM2NIIX -ArgumentList "-ba y -z n -v y -o $outSubAnat $ANATNAME" -Wait -RedirectStandardOutput $stdOutLog
      Get-Content $stdOutLog | Out-File $bidsLog -Append
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
    # Convert using dcm2niix, pipe output to log
    Start-Process -FilePath $pathDCM2NIIX -ArgumentList "-ba y -z n -v y -o $outSubAnat $ANATNAME" -Wait -RedirectStandardOutput $stdOutLog
    Get-Content $stdOutLog | Out-File $bidsLog -Append
    # Go back to output folder and rename files to correct BIDS name structure
    cd $outSubAnat
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
# Convert functional files
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# Convert the functional image for each subject (and possibly session)
for($sub = 1; $sub -le $nsub; $sub++) {
  # For loop over the sessions if needed
  if ($SessFlag -eq $TRUE) {
    for($sess = 1; $sess -le $nsession; $sess++) {
      # Define the output folder
      $outSubFunc="$OutputBIDS/sub-$sub/ses-$sess/func/"
      # Go to subject's folder
      cd $RawData/$prefsub$sub/
      # Define session task name
      $SessTASK=$TASKNAME[($sess - 1)]

      # Convert using dcm2niix: take the correct task name provided by user, pipe output to log
      Start-Process -FilePath $pathDCM2NIIX -ArgumentList "-ba y -z n -v y -o $outSubFunc $SessTASK" -Wait -RedirectStandardOutput $stdOutLog
      Get-Content $stdOutLog | Out-File $bidsLog -Append

      # Go back to output folder and rename files to correct BIDS name structure
      cd $outSubFunc
      # First retreive names, then pipe to rename command
      Get-ChildItem *.json | Rename-Item -NewName "sub-$sub`_ses-$sess`_task-$TASKOUTLBL.json"
      Get-ChildItem *.nii | Rename-Item -NewName "sub-$sub`_ses-$sess`_task-$TASKOUTLBL.nii"

      ## Renaming extra info is sequential: add if parameters are supplied
      ## ACQUISITION
      #rename_files "$ACQUISITION" "acq"
      ## Renaming REC
      #rename_files "$RCE" "rce"
      ## Renaming RUN
      #rename_files "$RUN" "run"
      ## Renaming ECHO
      #rename_files "$ECHO" "echo"

      # Add _bold to all files (both .json and .nii)
      # This is done by recursing over the files, then adding _bold to the basename, retaining the extension
      Get-ChildItem $Path *.* -Recurse |
        Rename-Item -NewName {$_.Basename + '_bold' + $_.Extension }
    }
  # End of session, part 1 if statement
  }
  # For loop without the sessions if needed
  if ($SessFlag -eq $FALSE) {
    # Define the output folder
    $outSubFunc="$OutputBIDS/sub-$sub/func/"
    # Go to subject's folder
    cd $RawData/$prefsub$sub/
    # Define session task name
    $SessTASK=$TASKNAME[($sess - 1)]

    # Convert using dcm2niix: take the correct task name provided by user, pipe output to log
    Start-Process -FilePath $pathDCM2NIIX -ArgumentList "-ba y -z n -v y -o $outSubFunc $SessTASK" -Wait -RedirectStandardOutput $stdOutLog
    Get-Content $stdOutLog | Out-File $bidsLog -Append

    # Go back to output folder and rename files to correct BIDS name structure
    cd $outSubFunc
    # First retreive names, then pipe to rename command
    Get-ChildItem *.json | Rename-Item -NewName "sub-$sub`_task-$TASKOUTLBL.json"
    Get-ChildItem *.nii | Rename-Item -NewName "sub-$sub`_task-$TASKOUTLBL.nii"

    ## Renaming extra info is sequential: add if parameters are supplied
    ## ACQUISITION
    #rename_files "$ACQUISITION" "acq"
    ## Renaming REC
    #rename_files "$RCE" "rce"
    ## Renaming RUN
    #rename_files "$RUN" "run"
    ## Renaming ECHO
    #rename_files "$ECHO" "echo"

    # Add _bold to all files (both .json and .nii)
    # This is done by recursing over the files, then adding _bold to the basename, retaining the extension
    Get-ChildItem $Path *.* -Recurse |
      Rename-Item -NewName {$_.Basename + '_bold' + $_.Extension }

  # End of session if statement
  }
}

# Debug bracket
}

#%%%%%%%%%%%%%%%%%%
## Provide warnings
#%%%%%%%%%%%%%%%%%%

Write-Host "WARNING: re-running this script will overwrite all manual changes made to files such as README, CHANGES, etc!"

#%%%%%%%%%%%%%%%%%%%%%%
## THE END
#%%%%%%%%%%%%%%%%%%%%%%

cd $ConvDir

Stop-Transcript

Write-Host "Conversion complete"
