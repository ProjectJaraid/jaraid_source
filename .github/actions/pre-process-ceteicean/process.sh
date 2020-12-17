#!/bin/bash

git config --global user.email "$ACTION_USER_EMAIL"
git config --global user.name "$ACTION_USER_NAME"
git clone --single-branch --branch master "https://x-access-token:$API_TOKEN@github.com/ProjectJaraid/projectjaraid.github.io.git" /opt/projectjaraid

echo "Pre-process master file for publication with CETEIcean and save as HTML"
saxon -s:tei/jaraid_master.TEIP5.xml -xsl:xslt/make-CETEIcean.xsl outfile=chrono
saxon -s:jaraid_master.TEIP5.xml -xsl:xslt/make-CETEIcean.xsl outfile=fihris

cd /opt/projectjaraid
git commit -am "Update from jaraid_source, commit $GITHUB_SHA."
git push origin master