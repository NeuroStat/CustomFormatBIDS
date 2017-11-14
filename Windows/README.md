# Windows

The script in this folder is for Windows-based systems. It is written for the PowerShell.

# Readme

To run, first clone/download this repository. In the Windows PowerShell, you can type:
```
git clone git@github.com:NeuroStat/CustomFormatBIDS.git
```

You might need to adjust the [execution policy](https://ss64.com/ps/set-executionpolicy.html). To change the policy of your shell to Unrestricted, so that you can run any script downloaded from the internet, type:
```
Set-ExecutionPolicy Unrestricted
````
in the PowerShell.

Now you need to open the file
```
convertDICOMtoBIDS.ps1
```
in your text editor and edit the first part of the file. See also the Tutorial for this.

Next save the script. The most common way to run PowerShell scripts is by directly calling them.
```
C:\> & "C:\Documents\CustomFormatBIDS/Windows\convertDICOMtoBIDS.ps1"
```
Or, if you are in the directory where the script is saved, you can call it through:
```
& "./convertDICOMtoBIDS.ps1"
```
(don't forget the `&`).
