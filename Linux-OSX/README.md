# Linux or OSX

> At the moment, the Windows development is ahead!
> This version does not contain check-points yet!

The script in this folder is for Linux-based systems. It is written in bash.

# Instructions

Make sure you have *dcm2niix* installed, following the [README](https://github.com/NeuroStat/CustomFormatBIDS) at the main page of this repository.

For Linux/OSX, we will be using the **terminal** which launches a *bash shell*. This can be found under applications.

Three commands are important to navigate in the shell. These are used to show the current directory, to list the files and folders in this directory and finally to navigate to specific folders. They are summarized in the table below.

| Command             | Description
|:--------------------|:----------------------
| pwd                 |Show working directory
| ls                  |List files and folders
| cd                  |Change directory


## Getting ready

To run the scripts, you first need to clone/download this repository.
If you have Git installed on your machine, you can type in your **terminal**:
```
git clone git@github.com:NeuroStat/CustomFormatBIDS.git
```
Note that this will clone the entire repository (so also the Windows part, which you can ignore). Otherwise, go to the [main page](https://github.com/NeuroStat/CustomFormatBIDS) and click on *Clone/Download* --> *Download ZIP*.


## Convert images

You need to open the file
```
/Linux-OSX/convertDICOMtoBIDS.sh
```
in your text editor and edit the first part of the file.

Then save, and run the script using:
```
./convertDICOMtoBIDS.sh
```
in your terminal.
