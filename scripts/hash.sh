#!/bin/sh

cd $@
# DOS to Unix
vim install.bat -c "set ff=unix" -c ":wq"
vim uninstall.bat -c "set ff=unix" -c ":wq"
sha256sum *.bat

# Unix to DOS
# sed -i 's/$/\r/' $@
# vim install.bat -c "set ff=dos" -c ":wq"
# vim uninstall.bat -c "set ff=dos" -c ":wq"
# sha256sum *.bat

cd ..
