# FPPW fMRI data to BIDS

## Description
Create custom scripts for FPPW to organise fMRI data to the BIDS format. <br>
The [convertDICOMtoBIDS](https://github.com/NeuroStat/CustomFormatBIDS/blob/master/convertDICOMtoBIDS.sh) file contains a script which uses a tool called MRIcroGL to convert DICOM images to *nifti* files together with *json* files that are appropriate for the BIDS format. The main work of the script is to create the correct folder structure and naming of the files according to the BIDS standard. The script is writtin in *bash*, so you need Linux/OS X to try it out or you could try to use Cygwin.

## BIDS
Link to [BIDS information](http://bids.neuroimaging.io).

## Dependencies
You will need [MRIcroGL](https://www.nitrc.org/frs/?group_id=889) to convert DICOM files to nifti files.

## Tutorial

Will be added in the future.

## Bugs
The scripts are still under development. Please report bugs at 
https://github.com/NeuroStat/CustomFormatBIDS/issues

## Contact
Han.Bossier@Ugent.be 
