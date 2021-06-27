# SnowRunner_EGS_to_XGP_Save_Copy
This is a simple PowerShell script to copy Epic Games (EGS) version of Snowrunner to the PC XBox Game Pass (Windows Store / XGP) version. 

How to Install:
1. (Optional) Launch EGS version of SnowRunner and retain all your vehicles
2. Download 'Snowrunner_Epic_to_XGP.ps1'
3. Launch the XGP version of SnowRunner
4. Create a new game in the first slot, or load the first saved game if you already have one
5. Get to the garage and travel to as many other garages as you can
6. Quit
7. Right-click 'Snowrunner_Epic_to_XGP.ps1' and 'Run with PowerShell'
8. Get gaming!

Limitations and Troubleshooting:
* If you get and error saying that running of scripts is disabled, then you need to change your execution policy. Start PowerShell as an administrator and run "Set-ExecutionPolicy Unrestricted" then try running the script again. See https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-7.1
* All saved games are backed up as a zip file. If you need to restore your backup, go to the saved game directory (shown when the script runs) and extract the zip file
* The script needs an XGP saved game to overwrite and will only copy files from EGS that matches the files in the XGP saved folder. This means if you have not been to a map on the XGP version then it won't copy the explored areas for that map and you'll need to re-explore. This also means any vehicles in the unexplored areas are inaccessible until you find them again.
* Only copies the first save slot from EGS version

