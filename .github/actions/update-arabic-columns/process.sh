#!/bin/bash
for f in `ls tei/jaraid_master*.xml`
do
  echo "Update the Arabic columns in the master with data from the authority file"
  saxon -s:"$f" -xsl:xslt/tei_add-arabic-columns.xsl -o:"$f" p_id-editor='github'
done