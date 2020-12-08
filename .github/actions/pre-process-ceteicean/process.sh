#!/bin/bash
for f in `ls tei/jaraid_master*.xml`
do
  echo "Pre-process master file for publication with CETEIcean and save as HTML"
  saxon -s:"$f" -xsl:xslt/make-CETEIcean-3.xsl
done