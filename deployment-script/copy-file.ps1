Invoke-WebRequest -Uri https://raw.githubusercontent.com/neilpeterson/2020-arm-talk/master/deployment-script/copy-file.sh -OutFile test.txt

Invoke-WebRequest -Uri https://aka.ms/downloadazcopy-v10-windows -OutFile AzCopy.zip -UseBasicParsing

Expand-Archive ./AzCopy.zip ./AzCopy -Force

get-childitem