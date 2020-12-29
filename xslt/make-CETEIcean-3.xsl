<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:eg="http://www.tei-c.org/ns/Examples"
  exclude-result-prefixes="t eg xs"
  version="3.0">
  
  <xsl:output method="html" indent="no"/>
  
  <!-- Simple XSLT that turns TEI into HTML Custom Elements inside an HTML <div>, with
       the Javascript to run CETEIcean and apply any relevant behaviors. The resulting
       <div> will need to be embedded in an HTML document that links to a CETEI.js and
       any CSS needed to style the output. The first template could be modified to 
       generate a full HTML page. -->
  
  <!-- to do: add a template that sorts the main table chronologically -->
  
  <xsl:template match="/">
   <xsl:variable name="v_file-name" select="replace(base-uri(),'^.+/([^/]+?)\.xml$', '$1')"/>
    <!-- write output file    -->
    <!-- the output path is relative to the repository if run through GitHub actions -->
    <xsl:result-document href="html/{$v_file-name}.html">
    <div><xsl:text>
  </xsl:text>
      <xsl:apply-templates select="node()|comment()"/><xsl:text>
  </xsl:text>
      <script type="text/javascript">
        var c = new CETEI();
        c.els = [<xsl:value-of select="t:elementList(/)"/>];
        c.els.push("egXML");
        c.applyBehaviors();
      </script>
    </div>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="@*|comment()">
    <xsl:copy><xsl:apply-templates select="node()|@*|comment()"/></xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[namespace-uri(.) = 'http://www.tei-c.org/ns/1.0']">
    <!-- create private HTML elements -->
    <xsl:element name="tei-{lower-case(local-name(.))}" >
      <!-- add attributes -->
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
      <!-- child elements -->
      <xsl:choose>
        <!-- special treatment of tables: sorting -->
        <xsl:when test="self::tei:table">
          <xsl:apply-templates select="tei:row[@role = 'label']"/>
          <!-- sort data rows -->
          <xsl:apply-templates select="tei:row[@role = 'data']">
            <xsl:sort select="tei:cell[@n = 1]/tei:date[@when][1]/@when"/>
            <xsl:sort select="tei:cell[@n = 1]/tei:date[@notAfter][1]/@notAfter"/>
            <xsl:sort select="tei:cell[@n = 4]/tei:name[1]"/>
            <xsl:sort select="tei:cell[@n = 4]/tei:title[1]"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- all other elements -->
        <xsl:otherwise>
          <xsl:apply-templates select="node()|comment()|processing-instruction()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:function name="t:elementList">
    <xsl:param name="doc"/>
    <xsl:for-each select="distinct-values($doc//*[namespace-uri(.) = 'http://www.tei-c.org/ns/1.0']/local-name())">"<xsl:value-of select="."/>"<xsl:if test="position() != last()">,</xsl:if></xsl:for-each>
  </xsl:function>
</xsl:stylesheet>