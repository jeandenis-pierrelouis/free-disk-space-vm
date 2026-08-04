$filestream = [System.IO.File]::Create("C:\Users\User\Documents\testfile.dat")
$filestream.SetLength(70000000000) #70GB Worth
$FileStream.Close()