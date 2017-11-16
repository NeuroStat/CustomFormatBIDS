# Windows

The script in this folder is for Windows-based systems. It is written for the PowerShell.

# Instructions

Make sure you have *dcm2niix* installed, following the [README](https://github.com/NeuroStat/CustomFormatBIDS) at the main page of this repository.

For Windows, we will be using the **PowerShell**. This can be found by pressing the Windows key, typing PowerShell, and clicking on *Windows PowerShel*.

Three commands are important to navigate in the shell. These are used to show the current directory, to list the files and folders in this directory and finally to navigate to specific folders. They are summarized in the table below.

| Command             | Description
|:--------------------|:----------------------
| pwd                 |Show working directory
| ls                  |List files and folders
| cd                  |Change directory


## Getting ready

To run the scripts, you first need to clone/download this repository.
If you have Git installed on your machine, you can type in the **Windows PowerShell**:
```
git clone git@github.com:NeuroStat/CustomFormatBIDS.git
```
Note that this will clone the entire repository (so also the Linux-OSX part, which you can ignore). Otherwise, go to the [main page](https://github.com/NeuroStat/CustomFormatBIDS) and click on *Clone/Download* --> *Download ZIP*.

You (might) need to adjust the [execution policy](https://ss64.com/ps/set-executionpolicy.html) of your shell. This determines whether your system allows scripts that are downloaded from the internet to be executed. To change the policy to *Unrestricted*, type:
```
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
````
in the PowerShell.

## Give information

For the script to work, you need to specify some variables. To do so, you need to open the file:
```
Windows\user_EDIT.ps1
```
in your text editor and follow the comments. See also the Tutorial section for this.

Next save the document. Now we are ready to run the main script.

## Convert images

The conversion of DICOM images is done by running *convertDICOMtoBIDS.ps1*. The most common way to run *PowerShell* scripts is by directly calling them.
```
C:\> & "C:\Documents\CustomFormatBIDS\Windows\convertDICOMtoBIDS.ps1"
```
Or, if you are in the (Windows) directory where the script is saved, you can call it through:
```
& "./convertDICOMtoBIDS.ps1"
```
(don't forget the `&`).

## Safety first

For safety, one can restrict executions of *PowerShell* scripts again (after the script has been executed):
```
Set-ExecutionPolicy Restricted -Scope CurrentUser
````
