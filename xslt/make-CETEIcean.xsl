<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:f="tei-c.org:functions"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  exclude-result-prefixes="t eg xs"
  version="3.0">
  
  <xsl:output method="html" version="5" indent="no"/>
  <xsl:mode on-no-match="shallow-copy"/>
  <xsl:param name="outfile"/>
  <xsl:variable name="template" select="doc(concat('https://raw.githubusercontent.com/ProjectJaraid/projectjaraid.github.io/master/HTML-templates/', $outfile, '-HTML-template.xml'))"/>
  <xsl:variable name="source" select="/*"/>
  
  <xsl:template match="/">
    <xsl:result-document href="/opt/projectjaraid/pages/{$outfile}.html">
      <xsl:apply-templates select="$template/*"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="div[@id='TEI']">
    <xsl:apply-templates select="$source"/>
  </xsl:template>
  
  <xsl:template match="@*|comment()">
    <xsl:copy><xsl:apply-templates select="node()|@*|comment()"/></xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[namespace-uri(.) = 'http://www.tei-c.org/ns/1.0']">
    <xsl:element name="tei-{lower-case(local-name(.))}" >
      <xsl:if test="namespace-uri(parent::*) != namespace-uri(.)"><xsl:attribute name="data-xmlns"><xsl:value-of select="namespace-uri(.)"/></xsl:attribute></xsl:if>
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@xml:lang">
        <xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="data-origname"><xsl:value-of select="local-name(.)"/></xsl:attribute>
      <xsl:if test="@*">
        <xsl:attribute name="data-origatts">
          <xsl:for-each select="@*">
            <xsl:value-of select="name(.)"/>
            <xsl:if test="not(position() = last())"><xsl:text> </xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="@*[namespace-uri() = '']">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates select="node()|comment()|processing-instruction()"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="t:table" priority="1">
    <tei-table>
      <xsl:if test="namespace-uri(parent::*) != namespace-uri(.)"><xsl:attribute name="data-xmlns"><xsl:value-of select="namespace-uri(.)"/></xsl:attribute></xsl:if>
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@xml:lang">
        <xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="data-origname"><xsl:value-of select="local-name(.)"/></xsl:attribute>
      <xsl:if test="@*">
        <xsl:attribute name="data-origatts">
          <xsl:for-each select="@*">
            <xsl:value-of select="name(.)"/>
            <xsl:if test="not(position() = last())"><xsl:text> </xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="@*[namespace-uri() = '']">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <table>
        <xsl:apply-templates select="t:row">
          <xsl:sort select="f:getDate(t:cell[1]/t:date[1])" data-type="text"/>
          <xsl:sort select="t:cell[4]"/>
        </xsl:apply-templates>
      </table>
    </tei-table>
  </xsl:template>
  
  <xsl:template match="t:row" priority="1">
    <tr>
      <xsl:if test="namespace-uri(parent::*) != namespace-uri(.)"><xsl:attribute name="data-xmlns"><xsl:value-of select="namespace-uri(.)"/></xsl:attribute></xsl:if>
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@xml:lang">
        <xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="data-origname"><xsl:value-of select="local-name(.)"/></xsl:attribute>
      <xsl:if test="@*">
        <xsl:attribute name="data-origatts">
          <xsl:for-each select="@*">
            <xsl:value-of select="name(.)"/>
            <xsl:if test="not(position() = last())"><xsl:text> </xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="@*[namespace-uri() = '']">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </tr>
  </xsl:template>
  
  <xsl:template match="t:cell" priority="1">
    <td>
      <xsl:if test="t:date">
        <xsl:attribute name="thedate" select="f:getDate(t:date)"/>
      </xsl:if>
      <xsl:if test="namespace-uri(parent::*) != namespace-uri(.)"><xsl:attribute name="data-xmlns"><xsl:value-of select="namespace-uri(.)"/></xsl:attribute></xsl:if>
      <xsl:if test="@xml:id">
        <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@xml:lang">
        <xsl:attribute name="lang"><xsl:value-of select="@xml:lang"/></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="data-origname"><xsl:value-of select="local-name(.)"/></xsl:attribute>
      <xsl:if test="@*">
        <xsl:attribute name="data-origatts">
          <xsl:for-each select="@*">
            <xsl:value-of select="name(.)"/>
            <xsl:if test="not(position() = last())"><xsl:text> </xsl:text></xsl:if>
          </xsl:for-each>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="@*[namespace-uri() = '']">
        <xsl:copy-of select="."/>
      </xsl:for-each>
      <xsl:apply-templates/>
    </td>
  </xsl:template>
  
  <xsl:function name="f:getDate">
    <xsl:param name="e"/>
    <xsl:choose>
      <xsl:when test="$e/@notBefore"><xsl:value-of select="$e/@notBefore"/></xsl:when>
      <xsl:when test="$e/@notAfter"><xsl:value-of select="$e/@notAfter"/></xsl:when>
      <xsl:when test="$e/@when"><xsl:value-of select="$e/@when"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="0000-01-01"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
    
</xsl:stylesheet>