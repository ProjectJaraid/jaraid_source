#!/bin/bash

# select the file(s) that should be transformed
for f in `ls tei/jaraid_master.TEIP5.xml`
do
  echo "Update the Arabic columns in the master with data from the authority file"
  saxon -s:"$f" -xsl:xslt/tei_add-arabic-columns.xsl -o:"$f"
done