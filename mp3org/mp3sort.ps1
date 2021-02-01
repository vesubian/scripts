Param([String] $Folder)
$INVALIDCHARS = [System.IO.Path]::GetInvalidPathChars() + "/", "\", "*", "?", ":", "|", "<", ">"
$CHARACTERSTOESCAPE = "\.", "\[", "\]", "\'", ".", "\..."
$MUSICATTRIBS = "*.m4a", "*.m4b", "*.mp3", "*.mp4", "*.wma", "*.flac", "*.wav", "*.ogg", "*.aiff"
$PLAYLISTATTRIBS = "*.m3u", "*.zpl"
$ALLATTRIBS = $MUSICATTRIBS + $PLAYLISTATTRIBS
$PLAYLISTSFOLDER = "Playlists"
$objShell = New-Object -ComObject Shell.Application
$iTotalFiles = 0
$iCurrentFile = 0

function checkFolderName($FolderName)
{
	# Make sure the folder doesn't contain any invalid characters
	if(!$FolderName) { $FolderName = "Unknown" }
	$INVALIDCHARS | % {$FolderName = $FolderName.replace($_, "-")}
  $CHARACTERSTOESCAPE | % {$FolderName = $FolderName.replace($_, "$_")}
	return $FolderName
}



function MoveFiles($startDir)
{
	Write-Host "Indexing playlists..."
	# Do a recursive DIR in the starting directory, include everything with the attributes of a playlist.
	# Filter the result by excluding everything that is a Container (folder)
	$dirResult = get-childitem -force -path $startDir -recurse -include $PLAYLISTATTRIBS | where{! $_.PSIsContainer}
	if($dirResult)
	{
		Write-Host "Moving playlists..."

		foreach($dirItem in $dirResult)
		{
			move-item $dirItem.FullName ($PLAYLISTSFOLDER + "\" + $dirItem.Name)
		}
	}
	Write-Host "Indexing music..."

	# Do a recursive DIR in the starting directory, include everything with the attributes of a music file.
	# Again we filter the result by excluding everything that is a Container.
	$dirResult = get-childitem -force -path $startDir -recurse -include $MUSICATTRIBS | where{! $_.PSIsContainer}

	# Make a note of how many hits we got, so we can show the progress to the client.
	$iTotalFiles = $dirResult.Count
	if($dirResult)
	{
		foreach($dirItem in $dirResult)
		{
			# Up the counter for how many files we've processed so that we can show progress
			$iCurrentFile +=1

			# Get the metadata for the file
			$fileData = getMP3MetaData($dirItem.FullName)
			# Find the path where we the song should be stored
			$ArtistPath = $fileData["Album Artist"]
			if (!$ArtistPath) { $ArtistPath = $fileData["Artists"] }
			if (!$ArtistPath) { $ArtistName = "Unknown" }

			# Make shure it's a valid path
			$ArtistPath = checkFolderName($ArtistPath)
			$AlbumPath = checkFolderName($fileData.Album)
			$ArtistPath = join-path $startDir $ArtistPath
			$AlbumPath = join-path $ArtistPath $AlbumPath

			# Check if the file should be moved
			if($dirItem.DirectoryName -ne $AlbumPath)
			{
				if(!(test-path $ArtistPath)) # If the Artist folder doesn't exist
				{
					MKDIR $ArtistPath | out-null
				}
				if(!(test-path $AlbumPath)) # If the Album folder doesn't exist
				{
					MKDIR $AlbumPath | out-null
				}
				move-item $dirItem.FullName ($AlbumPath + "\" + $dirItem.Name)
			}

			# Show progress
			$percentage = ([int](($iCurrentFile / $iTotalFiles)*100))
			cls
			Write-Host "$percentage% ($iCurrentFile files of $iTotalFiles) complete"
		}
	}
}


function removeEmptyFolders($startDir)
{
	# Get all folders and subfolders
	$dirResult = Get-childitem $startDir -recurse | where{$_.PSIsContainer}
	if($dirResult)
	{
		foreach($dirItem in $dirResult)
		{
			# If the folder is empty (Doesn't contain any music or playlists) it should be deleted
			if(isfolderempty($dirItem.FullName))
			{
				# Check if the path is still valid, we may have deleted the folder already recursively.
				if(Test-Path $dirItem.FullName)
				{
					remove-item -path $dirItem.FullName -force -recurse
				}
			}
		}
	}
}

function removeOtherFiles($startDir)
{
	# Get all non-music files (except *.jpg-files) and remove them
	$dirResult = Get-childitem $startDir -recurse -exclude ($ALLATTRIBS + "*.jpg") | where{! $_.PSIsContainer}
	if($dirResult)
	{
		foreach($dirItem in $dirResult)
		{
			if(Test-Path $dirItem.FullName)
			{
				# Make sure the file still exists, and hasn't been deleted already
				remove-item -path $dirItem.FullName -force
			}
		}
	}
}

function isFolderEmpty($folderPath)
{
	# Search for any remaining music items in the folder.
	if(Test-Path $folderPath)
	{
		$dirChildren = get-childitem -force -path $folderPath -recurse -include $ALLATTRIBS | where{! $_.PSIsContainer}
		if($dirChildren -ne $null)
		{
			return $false
		}
		else
		{
			return $true
		}
	}
	else
	{
		# No use trying to delete the folder if it doesn't exist
		return $false
	}
}

function getMP3MetaData($path)
{
	# Get the file name, and the folder it exists in
	$file = split-path $path -leaf
	$path = split-path $path
	$objFolder = $objShell.namespace($path)
	$objFile = $objFolder.parsename($file)
	$result = @{}
	0..266 | % {
		if ($objFolder.getDetailsOf($objFile, $_))
		{
			$result[$($objFolder.getDetailsOf($objFolder.items, $_))] = $objFolder.getDetailsOf($objFile, $_)
		}
	}
	return $result
}

# MAIN FUNCTION

# If no argument was passed, see if anything was piped to the function instead.
if (!$Folder)
{
	$input | % { $Folder = $_ }
}

# Check if the path is valid, if not reset it to ""
if ($Folder) { if (!(Test-Path -path $Folder)) { $Folder = "" }}

# Since no valid path was given, prompt the user for a proper path.
while (!$Folder)
{
	"Please enter the full path to the folder where you wish to rearrange your MP3's"
	$Folder = Read-Host
	if ($Folder) { if (!(Test-Path -path $Folder)) { $Folder = "" }}
}

# Make sure we have a folder to store the playlists in.
$PLAYLISTSFOLDER = join-path $Folder $PLAYLISTSFOLDER
if(!(test-path $PLAYLISTSFOLDER)) # If the Playlists folder doesn't exist
{
	MKDIR $PLAYLISTSFOLDER | out-null
}

# Now that everything is ready, begin rearranging the files.
MoveFiles($Folder)
removeOtherFiles($Folder)
removeEmptyFolders($Folder)
