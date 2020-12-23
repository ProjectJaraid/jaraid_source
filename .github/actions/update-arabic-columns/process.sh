#!/bin/bash

echo "Update the Arabic columns in the master with data from the authority file"
saxon -s:tei/jaraid_master.TEIP5.xml -xsl:xslt/tei_add-arabic-columns.xsl -o:tei/jaraid_master.TEIP5.xml p_id-editor='github'