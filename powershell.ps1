
Function Calculate-File-Hash($Filepath){
   $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
   return $filehash
}

Function Erase-Baseline-If-Already-Exists() {
    $baselineExists = Test-Path -Path .\baraii.txt
}

    if ($baselineExists){
    #delete
    Remove-Item -Path .\baraii.txt
}

write-Host ""
write-Host "what would you like to do??"
write-Host "A) Collect new Baseline"
write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"

write-Host "User chose $($response)"



if ($response -eq "A".ToUpper()) {
    #Delete file if already exists
    Erase-Baseline-If-Already-Exists
    #Calculate hash

    #Collect all filesin the target folder
    $files = Get-ChildItem -Path C:\Users\danes\desktop\tt\fack

    #For each file, Calculate the hash + write to baraii.txt

    foreach ($f in $files) {
      $hash = Calculate-File-Hash $f.FullName
      "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baraii.txt -Append
    }

}

elseif ($response -eq "B".ToUpper()) {
    $fileHashDictionary = @{}

    #Load file hash from baraii.txt and store then in dictionary
    $filePathsAndHashes = Get-Content -Path .\baraii.txt

    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    #Begin monitoring files with sved baseline
    while ($true){
        Start-Sleep -Seconds 1
         $files = Get-ChildItem -Path C:\Users\danes\desktop\tt\fack

          #For each file, Calculate the hash + write to baraii.txt

           foreach ($f in $files) {
              $hash = Calculate-File-Hash $f.FullName
              #"$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baraii.txt -Append

              if ($fileHashDictionary[$hash.Path] -eq $null){
                   #new file created
                   Write-Host "$($hash.Path) has been created!" -ForegroundColor DarkGreen
              }

              #Notify if file changed
              if ($fileHashDictionary[$hash.Path] -eq $hash.Hash){
                 #File not changed
              }

              else {
                write-Host "$() has changed" -ForegroundColor Red
           }
    }

    foreach ($key in $fileHashDictionary.Keys){
      $baselineFileStillExists = Test-Path -Path $key
      if (-Not $baselineFileStillExists){
        #one file deleted, inform user
        Write-Host "$($key) has been deleted!" -ForegroundColor White
      }
    }

  }

}
