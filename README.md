# FPPW fMRI data to BIDS

## Description
Create custom scripts for FPPW to organize fMRI data to the BIDS format. <br>
The folders [Linux-OSX](https://github.com/NeuroStat/CustomFormatBIDS/tree/master/Linux-OSX) and [Windows](https://github.com/NeuroStat/CustomFormatBIDS/tree/master/Windows) provided here contain a scripts to convert DICOM images to *nifti* files together with *json* files that are appropriate for the BIDS format. They use a tool called MRIcroGL (see dependencies) to do so. Note, many variables have to be entered manually before the script can be run (see tutorial).
Running the scripts should create folder structures and re-name files to the BIDS standard.

## BIDS
Link to [BIDS information](http://bids.neuroimaging.io).

## Dependencies
We try to reduce the amount of dependencies to run these scripts. However, you will need a tool called *dcm2niix*, which is part of *MRIcroGL* to convert DICOM images to nifti files. Please download and install [MRIcroGL](https://www.nitrc.org/frs/?group_id=889) first.

Furthermore, while not necessary, it is useful to have [Git](https://git-scm.com) installed on your system.

## Tutorial

Will be added in the future.

## Bugs
The scripts are still under development! Please report bugs/suggestions at
https://github.com/NeuroStat/CustomFormatBIDS/issues

## Contact
Han.Bossier@Ugent.be
