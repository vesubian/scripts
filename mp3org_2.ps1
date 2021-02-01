$controlssource = 1
$controlsdest = 1

$objshell = New-Object -ComObject Shell.Application
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objform = New-Object System.Windows.Forms.Form
$objform.Text = "Move Audio Data"
$objform.Size = New-Object System.Drawing.Size(300,260)
$objform.StartPosition = "CenterScreen"

$objform.KeyPreview = $True
$objform.Add_KeyDown({if ($_.KeyCode -eq "Escape")
{$objform.Close()}})

$movebutton = New-Object System.Windows.Forms.Button
$movebutton.Location = New-Object System.Drawing.Size(20,170)
$movebutton.Size = New-Object System.Drawing.Size(75,23)
$movebutton.Text = "Move"
$movebutton.Add_Click({$x="move";$objform.Close()})
$objform.Controls.Add($movebutton)

$copybutton = New-Object System.Windows.Forms.Button
$copybutton.Location = New-Object System.Drawing.Size(100,170)
$copybutton.Size = New-Object System.Drawing.Size(75,23)
$copybutton.Text = "Copy"
$copybutton.Add_Click({$x="copy";$objform.Close()})
$objform.Controls.Add($copybutton)

$cancelbutton = New-Object System.Windows.Forms.Button
$cancelbutton.Location = New-Object System.Drawing.Size(180,170)
$cancelbutton.Size = New-Object System.Drawing.Size(75,23)
$cancelbutton.Text = "Cancel"
$cancelbutton.Add_Click({$a=0;$x="nil";$objform.Close()})
$objform.Controls.Add($cancelbutton)

$objlabel = New-Object System.Windows.Forms.Label
$objlabel.Location = New-Object System.Drawing.Size(10,110)
$objlabel.Size = New-Object System.Drawing.Size(280,40)
$objlabel.Text = "Please specify whether you want to copy or to move your files. Moving the files will remove them from their original directory."
$objform.Controls.Add($objlabel)

if ($controlssource -eq 1){
$objlabel2 = New-Object System.Windows.Forms.Label
$objlabel2.Location = New-Object System.Drawing.Size(10,10)
$objlabel2.Size = New-Object System.Drawing.Size(280,15)
$objlabel2.Text = "Path to file origin:"
$objform.Controls.Add($objlabel2)}

if ($controlssource -eq 1){
$objtextbox = New-Object System.Windows.Forms.TextBox
$objtextbox.Location = New-Object System.Drawing.Size(10,25)
$objtextbox.Size = New-Object System.Drawing.Size(230,20)
$objform.Controls.Add($objtextbox)}

if ($controlsdest -eq 1){
$objlabel3 = New-Object System.Windows.Forms.Label
$objlabel3.Location = New-Object System.Drawing.Size(10,50)
$objlabel3.Size = New-Object System.Drawing.Size(280,15)
$objlabel3.Text = "Path to music library:"
$objform.Controls.Add($objlabel3)}

if ($controlsdest -eq 1){
$objtextbox2 = New-Object System.Windows.Forms.TextBox
$objtextbox2.Location = New-Object System.Drawing.Size(10,65)
$objtextbox2.Size = New-Object System.Drawing.Size(230,20)
$objform.Controls.Add($objtextbox2)}

if ($controlssource -eq 1){
$browsebutton1 = New-Object System.Windows.Forms.Button
$browsebutton1.Location = New-Object System.Drawing.Size(250,24)
$browsebutton1.Size = New-Object System.Drawing.Size(26,22)
$browsebutton1.Text = "..."
$browsebutton1.Add_Click({$fold1 = $objshell.BrowseForFolder(0, "Select Folder", 0, "");$objtextbox.Text = $fold1.self.path})
$objform.Controls.Add($browsebutton1)}

if ($controlsdest -eq 1){
$browsebutton2 = New-Object System.Windows.Forms.Button
$browsebutton2.Location = New-Object System.Drawing.Size(250,64)
$browsebutton2.Size = New-Object System.Drawing.Size(26,22)
$browsebutton2.Text = "..."
$browsebutton2.Add_Click({$fold2 = $objshell.BrowseForFolder(0, "Select Folder", 0, "");$objtextbox2.Text = $fold2.self.path})
$objform.Controls.Add($browsebutton2)}

$objform.Controls.Add($copybutton)

#$objform.topmost = $True

$objform.Add_Shown({$objform.Activate()})
[void] $objform.ShowDialog()

$sFolder = $objtextbox.Text
$mFolder = $objtextbox2.Text
#$sFolder = "C:\Users\Public\Music\Sample Music"
#$mFolder = "C:\Users\howtoforge\Music"
$objfolder = $objshell.namespace($sFolder)

if ($X -eq "nil") {exit}

foreach ($strfilename in $objfolder.items())
{
for ($a ; $a -le 266; $a++)
{
if ($objfolder.getDetailsOf($objfolder.items, $a) -eq "Contributing artists")
#if ($objfolder.getDetailsOf($objfolder.items, $a) -eq "Albuminterpret")
{
$artist = $objfolder.getDetailsOf($strfilename, $a)
}
if($objfolder.getDetailsOf($objfolder.items, $a) -eq "Album")
{
$album = $objfolder.getDetailsOf($strfilename, $a)
}
}
if ($artist -and $album)
{
if (!(test-path($mFolder + "\" + $artist + "\" + $album + $strfilename)))
{
new-item($mFolder + "\" + $artist + "\" + $album) -itemtype directory
if($x -eq "copy")
{
copy-item $strfilename.Path ($mFolder + "\" + $artist + "\" + $album)
}
if($x -eq "move")
{
move-item $strfilename.Path ($mFolder + "\" + $artist + "\" + $album)
}
}
}
clear-variable artist
clear-variable album
$a=0
}
