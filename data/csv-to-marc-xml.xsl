<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  xmlns="http://www.loc.gov/MARC21/slim" xmlns:mrc="http://www.loc.gov/MARC21/slim" version="3.0">
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="mrc:datafield">
        <xsl:copy>
<!--            <xsl:attribute name="n" select="count(preceding-sibling::mrc:datafield) + 1"/>-->
            <!-- look up code in the header -->
            <xsl:variable name="v_tag" select="/descendant::mrc:record[1]/mrc:datafield[@n = current()/@n]/@tag"/>
<!--            <xsl:attribute name="tag" select="substring-before($v_code, '|')"/>-->
            <xsl:apply-templates select="@*"/>
            <xsl:if test="@tag = ''">
                <xsl:attribute name="tag" select="$v_tag"/>
            </xsl:if>
            <xsl:apply-templates/>
            <!--<xsl:for-each select="following-sibling::mrc:datafield[@tag != ''][@tag = current()/@tag]">
                <xsl:apply-templates select="mrc:subfield"/>
            </xsl:for-each>-->
        </xsl:copy>
    </xsl:template>
    <!--<xsl:template match="mrc:datafield[preceding-sibling::mrc:datafield[@tag != '']/@tag = current()/@tag]" mode="m_group">
        <xsl:apply-templates/>
    </xsl:template>-->
<!--    <xsl:template match="mrc:datafield[preceding-sibling::mrc:datafield[@tag != '']/@tag = current()/@tag]" />-->
    
     <!--<xsl:template match="mrc:subfield">
        <xsl:copy>
            <xsl:variable name="v_n" select="count(parent::mrc:datafield/preceding-sibling::mrc:datafield) + 1"/>
            <!-\- look up code in the header -\->
<!-\-            <xsl:variable name="v_code" select="/descendant::mrc:record[1]/mrc:datafield[@n = current()/parent::mrc:datafield/@n]/mrc:subfield"/>-\->
<!-\-            <xsl:attribute name="code" select="substring-after($v_code, '|')"/>-\->
        </xsl:copy>
    </xsl:template>-->
    
</xsl:stylesheet>