#!/bin/bash
# Upload files to Github - git@github.com:talesCPV/strava
.git

read -p "Are you sure to commit strava 1.0 to GitHub ? (Y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

    cp ~/Documentos/SQL/strava/*.sql sql/

    git init

    git add assets/
    git add backend/
    git add config/
    git add scripts/
    git add sql/
    git add style/
    git add templates/
    git add gpx/
    git add index.html
    git add .htaccess
    git add commit.sh

    git commit -m "by_script"

#    git branch -M main
#    git remote add origin git@github.com:talesCPV/strava.git
    git remote set-url origin git@github.com:talesCPV/strava.git

    git push -u -f origin main

fi