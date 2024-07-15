# AndroidExtractor
Simple powershell script to extract and compress files from an android device using adb

## Script Dependencies
This script depends on a few of my other scripts, located in /Dependencies/

## Application Dependencies
This script depends on two applications;
7z.exe - Available at [7-zip.org](https://www.7-zip.org/download.html).
adb.exe - Available at [developer.android.com](https://developer.android.com/tools/releases/platform-tools#downloads).

>Note: This script can be run without any of the dependencies available by adding the "-Auto" flag. This will automatically download and install any depedencies that are missing.


# Usage
## Flags
Extract.ps1 has six different flags;
- ListFile
- Target
- Help
- Example
- Auto
- RootDirectory
>For a complete usage example, you can use the -Help flag.

## ListFile
### Synopsis
| Aliases | Default Value | Description |
| - | - | - |
| F | $null | Defines a file to use as a list of items to extract. |
| File |||
| Src |||
| Source |||
| List |||

### Example
```
extract.ps1 -f example.txt
example.txt => [files] => .\[Today's Date]\
```

## Target
### Synopsis
| Aliases | Default Value | Description |
| - | - | - |
| D | $null | Defines where to extract the items to.
| Folder |||
| SaveTo |||
| Destination |||

### Example
```
extract.ps1 -d "myphone"
[Files] => .\myphone\

extract.ps1 -d $null
[Files] => .\[Today's Date]\
```

## Help
### Synopsis
| Aliases | Default Value | Description |
| - | - | - |
| H || Prints a complete help/tutorial message and then exits. |
| Usage |||
| U |||
| Manual |||
| Man |||
| M |||

### Example
```
extract.ps1 -h
[Full Help/Tutorial]
example.txt => .\example.txt
```

## Example
### Synopsis
| Aliases | Default Value | Description |
| - | - | - |
| GenerateExample || Generates an "example.txt" and then exits. |
| Gen |||
| E |||
| G |||

### Example
```
extract.ps1 -g
example.txt => .\example.txt
```

## Auto
### Synopsis
| Aliases | Default Value | Description |
| - | - | - |
| Full || Tries to grab all files in the root directory. Also tries to install any missing dependencies. |
| All |||
| Everything |||
| Complete |||
| A |||
| Automated |||

### Example
```
extract.ps1 -a
[Dependencies] => .\Dependencies\
[Full list of items] => .\Full.txt
[Full.txt] => .\[Today's Date]\
```

## RootDirectory
### Synopsis
| Aliases | Default Value | Description |
| - | - | - |
| Root | /storage/emulated/0/ | Where on the device to grab files from. |
| From |||
| RD |||

### Example
```
extract.ps1 -Root "/storage/emulated/0/Download"
/storage/emulated/0/Download/[Items] => .\[Today's Date]\
```

## Notes
If ``-ListFile`` is left ``$null`` the script will prompt the user for which files to grab. This is done by entering the filenames into the terminal and pressing enter. Entering an emtpy string breaks the loop and proceeds to extract the files.
>Note: Filenames in unix are case sensitive, I strongly recommend using ``-auto`` for a complete list or ``adb shell ls /storage/emulated/0/`` to grab names from the device directly.

If ``-Target`` is left ``$null`` the script will create a new folder with the name of the date it's being used in the format `` YYYY-MM-DD``.
>Note: The script does NOT check for existing folders, so be careful not to overwrite your files.

Every flag can be combined, but using ``-help`` or ``-example`` will immediately terminate the process after doing their respective tasks. ``-help`` takes precedence over ``-example``. Using ``-auto`` with ``-listFile`` will result in the specified list being ignored and all files will be grabbed from the device.
>Note: Using ``-auto`` is the only way to automatically download and install dependencies. If you're missing 7zip and/or adb; running ``-help`` will print the URLs for downloading the software required.

The script will always return with either ``true`` or ``false``. This is to allow for extensibility and automation.
| True | False |
| - | - |
| Extraction succeded. | Extraction failed somewhere, check the error message in the terminal. |
>Note: If you don't want to see the resulting true/false you can run the script like this: ``extract.ps1 > $null``

The script will provide a progressbar when running.