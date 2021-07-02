clear

### Find the Epic saved games ###
try {
	$epic_save_dir =  [Environment]::GetFolderPath('Personal') + "\My Games\SnowRunner\base\storage\"
	$null = Test-Path -Path $epic_save_dir -ErrorAction Stop

	$epic_save_dir = $epic_save_dir + (Get-ChildItem -directory $epic_save_dir | Where-Object {$_.Name -notlike "*backupSlots"} | select -ExpandProperty Name)
	$null = Test-Path -Path $epic_save_dir -ErrorAction Stop

	Write-Host "Found Snowrunner Epic Games version saved games at:"
	Write-Host $epic_save_dir
}
catch {
	Write-Error "Can't find the Epic Games Snowrunner saved games. Expected at $epic_save_dir" -ErrorAction Stop
}

#### Find the XBox Game Pass saved games ###
try {
	$xgp_save_dir = [Environment]::GetFolderPath('LocalApplicationData') + "\Packages\"
	$xgp_save_dir = $xgp_save_dir + (Get-ChildItem -directory $xgp_save_dir | Where-Object {$_.Name -like "FocusHomeInteractiveSA.SnowRunner*"} | select -ExpandProperty Name) + "\SystemAppData\wgs\"
	$null = Test-Path -Path $xgp_save_dir -ErrorAction Stop

	$xgp_save_dir = $xgp_save_dir + (Get-ChildItem -directory $xgp_save_dir | Where-Object {$_.Name -notlike "t"} | select -ExpandProperty Name) + "\"
	$null = Test-Path -Path $xgp_save_dir -ErrorAction Stop

	$xgp_save_dir = $xgp_save_dir + (Get-ChildItem -directory $xgp_save_dir | select -ExpandProperty Name)
	$null = Test-Path -Path $xgp_save_dir -ErrorAction Stop

	Write-Host "`nFound Snowrunner XBox Game Pass version saved games at:"
	Write-Host $xgp_save_dir
}
catch {
	Write-Error "Can't find the XBox Game Pass Snowrunner saved games. Expected at $xgp_save_dir" -ErrorAction Stop
}

### Back up saved games as zip files ##
try {
    Compress-Archive -Path $epic_save_dir -DestinationPath ($epic_save_dir + "_backup.zip")
}
catch {
    Write-Host "`n"
    Write-Warning "Looks like an Epic Games Store saved game backup already exists. Select Yes to overwrite the backup or No to skip"
    Compress-Archive -Path $epic_save_dir -DestinationPath ($epic_save_dir + "_backup.zip") -Update -Confirm
}


try {
    Compress-Archive -Path $xgp_save_dir -DestinationPath ($xgp_save_dir + "_backup.zip")
}
catch {
    Write-Host "`n"
    Write-Warning "Looks like an XBox Game Pass saved game backup already exists. Select Yes to overwrite the backup or No to skip"
    Compress-Archive -Path $xgp_save_dir -DestinationPath ($xgp_save_dir + "_backup.zip") -Update -Confirm
}

### Copying Epic Games Store saves to XBox Game Pass ###
Write-Host "`nCopying saved games..."

# Read the container file to find file types
$container = Get-Content "$xgp_save_dir\container*" -Encoding Byte

# For loop goes through the XGP save files, find the matching Epic file and copies across
foreach ($file in (Get-ChildItem $xgp_save_dir | Where-Object {$_.Name -notlike "container*"})) {
    $hex_array = @()
    $file_type = ''

    # Convert the filename to a byte array
    $name_array = $file.name -split '(\w{2})' | Where-Object {$_}
    foreach ($byte in $name_array) {
        $hex_array = $hex_array + "0x$byte"
    }
    $hex_array = [int[]]$hex_array[3,2,1,0,5,4,7,6,8,9,10,11,12,13,14,15]
    
    # Check the container file to find the matching file type
    for ($i=8; $i -lt $container.length; $i=$i+160) {
        if (Compare-Object $hex_array $container[($i+0x80)..($i+0x8F)]) {
            $null
        } else {
            $file_type = [char[]]$container[($i)..($i+0x7F)] -join ""
            $file_type = $file_type -replace '[\W]',''
            break
        }
    }

    # Check if the file is found in Epic store save game directory and copy across
    try {
        $null = Resolve-Path -Path ("$epic_save_dir\$file_type.dat") -ErrorAction Stop
        Write-Host "Copying $file_type"
        Copy-Item -Path "$epic_save_dir\$file_type.dat" -Destination $file.FullName
    }
    catch {
        Write-Warning "Can't find $epic_save_dir\$file_type.dat"
    }
}
Write-Host "All done! Press any key to close"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")