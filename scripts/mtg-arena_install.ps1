param($dir)

start msiexec -arg '/a', "$dir\setup.msi", '/qn' -wait
cp $dir\Windows32\* $dir -r -force
rm $dir\Windows32 -r -force
