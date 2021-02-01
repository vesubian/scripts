Get-ChildItem -recurse |  Where {$_.PSIsContainer -and @(Get-ChildItem $_.Fullname. | Where {!$_.PSIsContainer}).Length -eq 1} |  % { $_.FullName } > "c:\users\admin\desktop\dirtorm.txt"
