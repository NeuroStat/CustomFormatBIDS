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


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## USER Specify Global Variables
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Location of raw data folder
RawData="/Volumes/1_5_TB_Han_HDD/BIDS_course/AllSub"

# Location of where we shall write BIDS output
OutputBIDS="/Volumes/1_5_TB_Han_HDD/BIDS_course/OutBIDS"

# Number of subjects
nsub=5

# Number of runs per subject
runs=2

# NAMESPACE: how do you call your folders?
TASKNAME="EP2D_FEAR_"
RESTNAME="EP2D_RESTING_STATE_"
ANATNAME="T1_MPRAGE_0002"
INHOMOGNAME="GRE_FIELD_MAPPING_0006"
B0NAME="GRE_FIELD_MAPPING_0007"

# Select the elements your data contains
TASK=TRUE
REST=TRUE
ANATOMICAL=TRUE
FIELDMAP=TRUE
DWI=FALSE

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Server based global variables
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Path to dcm2niix
pathDCM2NIIX="/Applications/MRIcroGL/MRIcroGL.app/Contents/Resources/dcm2niix"


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
## Create BIDS folder structure
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Going to output folder
cd ${OutputBIDS}

# Create folders




if [ ${TASKNAME} = TRUE ] ; then


#-b y -z y -v y -f "%i_%p_%s" -o "/Volumes/1_5_TB_Han_HDD/BIDS_course/BIDS/"  "sub-1/EP2D_FEAR_RUN1_0004"
