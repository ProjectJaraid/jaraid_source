<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:pj="https://projectjaraid.github.io/ns"
    xmlns:oape="https://openarabicpe.github.io/ns" 
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs pj"
    version="3.0">
    <xsl:output encoding="UTF-8" indent="no" omit-xml-declaration="no" method="xml"/>
    <xsl:include href="functions_arabic-transcription.xsl"/>
    
    <xsl:param name="p_id-change" select="generate-id(//tei:change[last()])"/>
    <xsl:param name="p_id-editor" select="'pers_TG'"/>
    <xsl:param name="p_url-authority" select="'../authority-files/jaraid_authority-file.TEIP5.xml'"/>
    <xsl:param name="p_string-separator" select="' / '" as="xs:string"/>
    <xsl:variable name="v_file-entities-master" select="doc($p_url-authority)"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:row[@role = 'data']">
        <xsl:copy>
            <!-- reproduce the current content -->
            <!-- IMPORTANT: in order for the automatically generated columns not being stacked ad infitum, they must be overwritten -->
            <xsl:apply-templates select="@* | node()"/>
            <!-- add rows for Arabic -->
            <!-- titles -->
            <!-- if Arabic titles are already present, they shall not be replaced -->
            <xsl:if test="not(tei:cell[@n = 10]/node())">
                <xsl:apply-templates select="tei:cell[@n = 4]" mode="m_add-arabic"/>
            </xsl:if>
            <!-- persons, organisations -->
            <xsl:apply-templates select="tei:cell[@n = 6]" mode="m_add-arabic"/>
            <!-- places -->
            <xsl:apply-templates select="tei:cell[@n = 5]" mode="m_add-arabic"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- previously generated Arabic columns shall be overwritten -->
    <xsl:template match="tei:row[@role = 'data']/tei:cell[@n = (11, 12)]"/>
    
    <xsl:template match="tei:row[@role = 'data']/tei:cell" mode="m_add-arabic">
        <xsl:copy>
            <!-- document change -->
            <!-- NOTE: as this XSLT is used by a GitHub action, it is frequently run and will infest the master files with <change> nodes. I, therefore removed the documentation -->
            <!-- <xsl:attribute name="change" select="concat('#',$p_id-change)"/> -->
            <!-- add new column numbers -->
            <xsl:choose>
                <!-- titles -->
                <xsl:when test="@n = 4">
                    <xsl:attribute name="n" select="10"/>
                    <xsl:apply-templates select="tei:name" mode="m_add-arabic"/>
                </xsl:when>
                <!-- places -->
                <xsl:when test="@n = 5">
                    <xsl:attribute name="n" select="12"/>
                    <xsl:apply-templates select="tei:placeName" mode="m_add-arabic"/>
                </xsl:when>
                <!-- persons, organisations -->
                <xsl:when test="@n = 6">
                    <xsl:attribute name="n" select="11"/>
                    <xsl:apply-templates mode="m_add-arabic"/>
<!--                    <xsl:apply-templates select="tei:orgName" mode="m_add-arabic"/>-->
                    <!--<xsl:apply-templates select="tei:persName" mode="m_add-arabic"/>-->
                </xsl:when>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:persName | tei:placeName | tei:orgName" mode="m_add-arabic">
        <xsl:copy-of select="pj:entity-names_get-version-from-authority-file(., $v_file-entities-master, 'jaraid', 'ar')"/>
        <xsl:if test="following-sibling::tei:persName | following-sibling::tei:orgName | following-sibling::tei:placeName">
            <xsl:value-of select="$p_string-separator"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:name" mode="m_add-arabic">
        <xsl:element name="title">
            <xsl:attribute name="level" select="'j'"/>
            <xsl:attribute name="xml:lang" select="'ar'"/>
            <xsl:value-of select="oape:string-transliterate-ijmes-to-arabic(.)"/>
        </xsl:element>
    </xsl:template>
    <!-- all other nodes should be supressed -->
    <xsl:template match="node()" mode="m_add-arabic"/>
    
    <xsl:function name="pj:entity-names_get-version-from-authority-file">
        <xsl:param name="p_entity-name"/>
        <xsl:param name="p_authority-file"/>
        <xsl:param name="p_authority"/>
        <xsl:param name="p_target-lang"/>
        <!-- pull the corresponding entity from the authority file -->
        <xsl:variable name="v_entity-from-authority-file" select="oape:get-entity-from-authority-file($p_entity-name, $p_authority, $p_authority-file)"/>
        <xsl:variable name="v_entity-type">
            <xsl:choose>
                <xsl:when test="name($p_entity-name) = 'persName'">
                    <xsl:text>pers</xsl:text>
                </xsl:when>
                <xsl:when test="name($p_entity-name) = 'orgName'">
                    <xsl:text>org</xsl:text>
                </xsl:when>
                <xsl:when test="name($p_entity-name) = 'placeName'">
                    <xsl:text>place</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no">
                        <xsl:text>the input type cannot be looked up</xsl:text>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_entity-name">
            <!-- establish script families based on input language -->
            <xsl:variable name="v_script">
                <xsl:choose>
                    <xsl:when test="$p_target-lang = 'ar'">
                        <xsl:text>Arab</xsl:text>
                    </xsl:when>
                    <xsl:when test="$p_target-lang = 'en'">
                        <xsl:text>Latn</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>
                            <xsl:text>Script of the target language (</xsl:text><xsl:value-of select="$p_target-lang"/><xsl:text>) could not be established.</xsl:text>
                        </xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$v_entity-type = 'pers'">
                    <xsl:choose>
                        <!-- check if target language is present -->
                        <xsl:when test="$v_entity-from-authority-file/descendant::tei:persName[not(@type = 'flattened')][@xml:lang = $p_target-lang]">
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:persName[not(@type = 'flattened')][@xml:lang = $p_target-lang][1]"/>
                        </xsl:when>
                        <!-- check if target script is present -->
                        <xsl:when test="$v_entity-from-authority-file/descendant::tei:persName[not(@type = 'flattened')][contains(@xml:lang,  concat('-',$v_script, '-'))]">
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:persName[not(@type = 'flattened')][contains(@xml:lang,  concat('-',$v_script, '-'))][1]"/>
                        </xsl:when>
                        <!-- fallback: first entry -->
                        <xsl:otherwise>
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:persName[not(@type = 'flattened')][1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$v_entity-type = 'place'">
                    <xsl:choose>
                        <!-- check if target language is present -->
                        <xsl:when test="$v_entity-from-authority-file/descendant::tei:placeName[@xml:lang = $p_target-lang]">
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:placeName[@xml:lang = $p_target-lang][1]"/>
                        </xsl:when>
                        <!-- check if target script is present -->
                        <xsl:when test="$v_entity-from-authority-file/descendant::tei:placeName[contains(@xml:lang,  concat('-',$v_script, '-'))]">
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:placeName[contains(@xml:lang,  concat('-',$v_script, '-'))][1]"/>
                        </xsl:when>
                        <!-- fallback: first entry -->
                        <xsl:otherwise>
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:placeName[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$v_entity-type = 'org'">
                    <xsl:choose>
                        <!-- check if target language is present -->
                        <xsl:when test="$v_entity-from-authority-file/descendant::tei:orgName[@xml:lang = $p_target-lang]">
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:orgName[@xml:lang = $p_target-lang][1]"/>
                        </xsl:when>
                        <!-- check if target script is present -->
                        <xsl:when test="$v_entity-from-authority-file/descendant::tei:orgName[contains(@xml:lang,  concat('-',$v_script, '-'))]">
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:orgName[contains(@xml:lang,  concat('-',$v_script, '-'))][1]"/>
                        </xsl:when>
                        <!-- fallback: first entry -->
                        <xsl:otherwise>
                            <xsl:copy-of select="$v_entity-from-authority-file/descendant::tei:orgName[1]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- output -->
        <xsl:copy select="$p_entity-name">
            <xsl:copy-of select="$p_entity-name/@ref"/>
            <!-- must be based on the entity name  -->
<!--            <xsl:attribute name="xml:lang" select="$v_entity-name/@xml:lang"/>-->
            <xsl:apply-templates select="$v_entity-name/descendant-or-self::tei:persName/@xml:lang | $v_entity-name/descendant-or-self::tei:placeName/@xml:lang | $v_entity-name/descendant-or-self::tei:orgName/@xml:lang" mode="m_copy-from-authority-file"/>
            <xsl:apply-templates select="$v_entity-name/descendant-or-self::tei:persName/node() | $v_entity-name/descendant-or-self::tei:placeName/node() | $v_entity-name/descendant-or-self::tei:orgName/node()" mode="m_copy-from-authority-file"/>
        </xsl:copy>
    </xsl:function>
    
    <xsl:function name="pj:entity-names_get-version-from-authority-file_old">
        <xsl:param name="p_name"/>
        <xsl:param name="p_authority-file"/>
        <xsl:param name="p_target-lang"/>
        <xsl:variable name="v_authority" select="'jaraid'"/>
        <xsl:variable name="v_type" select="replace($p_name/@ref, '.*jaraid:(\w+):\d+.*', '$1')"/>
        <xsl:variable name="v_id" select="replace($p_name/@ref, '.*jaraid:\w+:(\d+).*', '$1')"/>
        <xsl:variable name="v_entity">
            <xsl:choose>
                <xsl:when test="$v_type = 'pers'">
                    <xsl:copy-of select="$p_authority-file/descendant::tei:person[tei:idno[@type = $v_authority] = $v_id]"/>
                </xsl:when>
                <xsl:when test="$v_type = 'place'">
                    <xsl:copy-of select="$p_authority-file/descendant::tei:place[tei:idno[@type = $v_authority] = $v_id]"/>
                </xsl:when>
                <xsl:when test="$v_type = 'org'">
                    <xsl:copy-of select="$p_authority-file/descendant::tei:org[tei:idno[@type = $v_authority] = $v_id]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- there needs to be some fall back to the target name in cases they are not available in the target language -->
        <xsl:variable name="v_entity-name">
            <xsl:choose>
                <xsl:when test="$v_type = 'pers'">
                    <xsl:copy-of select="$v_entity/descendant::tei:persName[@xml:lang = $p_target-lang][1]"/>
                </xsl:when>
                <xsl:when test="$v_type = 'place'">
                    <xsl:copy-of select="$v_entity/descendant::tei:placeName[@xml:lang = $p_target-lang][1]"/>
                </xsl:when>
                <xsl:when test="$v_type = 'org'">
                    <xsl:copy-of select="$v_entity/descendant::tei:orgName[@xml:lang = $p_target-lang][1]"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <!-- output -->
        <xsl:copy select="$p_name">
            <xsl:copy-of select="$p_name/@ref"/>
            <xsl:attribute name="xml:lang" select="$p_target-lang"/>
            <xsl:apply-templates select="$v_entity-name/descendant-or-self::tei:persName/node() | $v_entity-name/descendant-or-self::tei:placeName/node() | $v_entity-name/descendant-or-self::tei:orgName/node()" mode="m_copy-from-authority-file"/>
        </xsl:copy>
    </xsl:function>
    
    <xsl:template match="node() | @*" mode="m_copy-from-authority-file">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="m_copy-from-authority-file"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@xml:id | @change" mode="m_copy-from-authority-file"/>
    
    <!-- this function queries a local authority file
        - input: an entity name such as <persName>, <orgName>, or <placeName>
        - output: an entity: such as <person>, <org>, or <place>
    -->
    <xsl:function name="oape:get-entity-from-authority-file">
        <!-- input: entity such as <persName>, <orgName>, or <placeName> node -->
        <xsl:param name="p_entity"/>
        <xsl:param as="xs:string" name="p_local-authority"/>
        <xsl:param name="p_authority-file"/>
        <xsl:variable name="v_ref" select="$p_entity/@ref"/>
        <xsl:variable name="v_entity-type">
            <xsl:choose>
                <xsl:when test="name($p_entity) = 'persName'">
                    <xsl:text>pers</xsl:text>
                </xsl:when>
                <xsl:when test="name($p_entity) = 'orgName'">
                    <xsl:text>org</xsl:text>
                </xsl:when>
                <xsl:when test="name($p_entity) = 'placeName'">
                    <xsl:text>place</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="no">
                        <xsl:text>the input type cannot be looked up</xsl:text>
                    </xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="v_local-uri-scheme" select="concat($p_local-authority,':', $v_entity-type,':')"/>
        <xsl:choose>
            <!-- check if the entity already links to an authority file by means of the @ref attribute -->
            <xsl:when test="$p_entity/@ref != ''">
                <xsl:variable name="v_authority">
                    <xsl:choose>
                        <xsl:when test="contains($v_ref, 'viaf:')">
                            <xsl:text>VIAF</xsl:text>
                        </xsl:when>
                        <xsl:when test="contains($v_ref, 'geon:')">
                            <xsl:text>geon</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$p_local-authority"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="v_idno">
                    <xsl:choose>
                        <xsl:when test="contains($v_ref, 'viaf:')">
                            <xsl:value-of select="replace($v_ref, '.*viaf:(\d+).*', '$1')"/>
                        </xsl:when>
                        <xsl:when test="contains($v_ref, 'geon:')">
                            <xsl:value-of select="replace($v_ref, '.*geon:(\d+).*', '$1')"/>
                        </xsl:when>
                        <xsl:when test="contains($v_ref, $v_local-uri-scheme)">
                            <xsl:value-of select="replace($v_ref, concat('.*', $v_local-uri-scheme, '(\d+).*'), '$1')"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$v_entity-type = 'pers'">
                        <xsl:choose>
                            <xsl:when test="$p_authority-file//tei:person/tei:idno[@type = $v_authority] = $v_idno">
                                <xsl:copy-of select="$p_authority-file//tei:person[tei:idno[@type = $v_authority] = $v_idno]"/>
                            </xsl:when>
                            <!-- even though the input claims that there is an entry in the authority file, there isn't -->
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:text>There is no person with the ID </xsl:text>
                                    <xsl:value-of select="$v_idno"/>
                                    <xsl:text> in the authority file</xsl:text>
                                </xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$v_entity-type = 'org'">
                        <xsl:choose>
                            <xsl:when test="$p_authority-file//tei:org/tei:idno[@type = $v_authority] = $v_idno">
                                <xsl:copy-of select="$p_authority-file//tei:org[tei:idno[@type = $v_authority] = $v_idno]"/>
                            </xsl:when>
                            <!-- even though the input claims that there is an entry in the authority file, there isn't -->
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:text>There is no org with the ID </xsl:text>
                                    <xsl:value-of select="$v_idno"/>
                                    <xsl:text> in the authority file</xsl:text>
                                </xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$v_entity-type = 'place'">
                        <xsl:choose>
                            <xsl:when test="$p_authority-file//tei:place/tei:idno[@type = $v_authority] = $v_idno">
                                <xsl:copy-of select="$p_authority-file//tei:place[tei:idno[@type = $v_authority] = $v_idno]"/>
                            </xsl:when>
                            <!-- even though the input claims that there is an entry in the authority file, there isn't -->
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:text>There is no place with the ID </xsl:text>
                                    <xsl:value-of select="$v_idno"/>
                                    <xsl:text> in the authority file</xsl:text>
                                </xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- fallback message -->
                    <xsl:otherwise>
                        <!-- one cannot use a boolean value if the default result is non-boolean -->
                        <xsl:value-of select="'false()'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- check if the string is found in the authority file -->
            <xsl:otherwise>
                <xsl:variable name="v_name-flat" select="oape:string-normalise-characters(string($p_entity))"/>
                <xsl:choose>
                    <xsl:when test="$v_entity-type = 'pers'">
                        <xsl:choose>
                            <xsl:when test="$p_authority-file//tei:person[tei:persName = $v_name-flat]">
                                <xsl:copy-of select="$p_authority-file/descendant::tei:person[tei:persName = $v_name-flat][1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:text>The persName </xsl:text>
                                    <xsl:value-of select="$v_name-flat"/>
                                    <xsl:text> was not found in the authority file</xsl:text>
                                </xsl:message>
                                <!-- one cannot use a boolean value if the default result is non-boolean -->
                                <xsl:value-of select="'false()'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$v_entity-type = 'org'">
                        <xsl:choose>
                            <xsl:when test="$p_authority-file//tei:org[tei:orgName = $v_name-flat]">
                                <xsl:copy-of select="$p_authority-file/descendant::tei:org[tei:orgName = $v_name-flat][1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:text>The orgName </xsl:text>
                                    <xsl:value-of select="$v_name-flat"/>
                                    <xsl:text> was not found in the authority file</xsl:text>
                                </xsl:message>
                                <!-- one cannot use a boolean value if the default result is non-boolean -->
                                <xsl:value-of select="'false()'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$v_entity-type = 'place'">
                        <xsl:choose>
                            <xsl:when test="$p_authority-file//tei:place[tei:placeName = $v_name-flat]">
                                <xsl:copy-of select="$p_authority-file/descendant::tei:place[tei:placeName = $v_name-flat][1]"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>
                                    <xsl:text>The placeName </xsl:text>
                                    <xsl:value-of select="$v_name-flat"/>
                                    <xsl:text> was not found in the authority file</xsl:text>
                                </xsl:message>
                                <!-- one cannot use a boolean value if the default result is non-boolean -->
                                <xsl:value-of select="'false()'"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <!-- fallback message -->
                    <xsl:otherwise>
                        <!-- one cannot use a boolean value if the default result is non-boolean -->
                        <xsl:value-of select="'false()'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- parameters for string-replacements -->
    <xsl:param name="p_string-match" select="'([إ|أ|آ])'"/>
    <xsl:param name="p_string-replace" select="'ا'"/>
    <xsl:param name="p_string-harakat" select="'([ِ|ُ|ٓ|ٰ|ْ|ٌ|ٍ|ً|ّ|َ])'"/>
    <xsl:function name="oape:string-normalise-characters">
        <xsl:param name="p_input"/>
        <xsl:variable name="v_self" select="normalize-space(replace(oape:string-remove-harakat($p_input), $p_string-match, $p_string-replace))"/>
        <!--        <xsl:value-of select="replace($v_self, '\W', '')"/>-->
        <xsl:value-of select="$v_self"/>
    </xsl:function>
    <xsl:function name="oape:string-remove-characters">
        <xsl:param as="xs:string" name="p_input"/>
        <xsl:param name="p_string-match"/>
        <xsl:value-of select="normalize-space(replace($p_input, $p_string-match, ''))"/>
    </xsl:function>
    <xsl:function name="oape:string-remove-harakat">
        <xsl:param name="p_input"/>
        <xsl:value-of select="oape:string-remove-characters($p_input, $p_string-harakat)"/>
    </xsl:function>
    
    <!-- generate documentation of change -->
    <!-- NOTE: as this XSLT is used by a GitHub action, it is frequently run and will infest the master files with <change> nodes. I, therefore removed the documentation -->
    <!-- <xsl:template match="tei:revisionDesc" priority="100">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:element name="change">
                <xsl:attribute name="when"
                    select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                <xsl:attribute name="who" select="concat('#', $p_id-editor)"/>
                <xsl:attribute name="xml:id" select="$p_id-change"/>
                <xsl:attribute name="xml:lang" select="'en'"/>
                <xsl:text>Updated Arabic content of rows 11 and 12 based on recent changes to the authority file</xsl:text>
            </xsl:element>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template> -->
</xsl:stylesheet>