<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:xd="https://www.oxygenxml.com/ns/doc/xsl"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:jt="https://github.com/joeytakeda"
    xmlns="http://www.tei-c.org/ns/1.0"
    version="3.0">
    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>Author</xd:b>: joeytakeda</xd:p>
            <xd:p><xd:b>Date</xd:b>: March 2021</xd:p>
            <xd:p>Stylesheet to convert the output of the TEI Stylesheet's odd2lite.xsl into more processable TEI. Derived from
            an early stylesheet for the Winnifred Eaton Archive.</xd:p>
        </xd:desc>
    </xd:doc>
   
    <!--Identity transform-->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output indent="yes" suppress-indentation="ref"/>
    
    <xsl:variable name="processedODD" select="document(replace(document-uri(.),'_lite.xml','_processed.odd'))" as="document-node()"/>
    
    <xsl:variable name="specMap" as="map(xs:string, element())">
        <xsl:map>
            <xsl:for-each select="$processedODD//schemaSpec/*[not(self::constraintSpec)]">
                <xsl:map-entry key="string(@ident)">
                    <xsl:apply-templates select="." mode="spec"/>
                </xsl:map-entry>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    
    <!--Only retrieve the latest version-->
    <xsl:template match="tei:*[lang('en')][@versionDate]" mode="spec">
       <xsl:variable name="name" select="local-name()"/>
       <xsl:variable name="myDate" select="xs:date(@versionDate)"/>
       <xsl:variable name="bestVersion" select="jt:getBestVersion(parent::tei:*, $name)"/> 
       <xsl:if test="current() is $bestVersion">
           <xsl:next-match/>
       </xsl:if>
    </xsl:template> 
    
    <!--Items to remove in the spec sources-->
    <xsl:template match="tei:exemplum | tei:remarks | tei:listRef | @versionDate | @xml:lang | tei:*[not(lang('en'))]" mode="spec"/>
    
    <!--And identity-->
    <xsl:template match="@*|node()" priority="-1" mode="spec">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    
   
   <!--*** STRUCTURE ***-->
    
    <xsl:template match="TEI">
        <xsl:copy>
            <xsl:attribute name="xml:id" select="'documentation'"/>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="back/div/div[not(@xmlid)][head]">
        <xsl:copy>
            <xsl:attribute name="xml:id" select="lower-case(translate(normalize-space(string-join(head,'')),' ', '_'))"/>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    

    
    
    <!--*** LISTS ***-->
    
    <xsl:template match="item[not(ancestor::list)]">
        <list>
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" mode="#current"/>
            </xsl:copy>
        </list>
    </xsl:template>

    <xsl:template match="ab[not(ancestor::ab)][ab]">
        <list>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </list>
    </xsl:template>
    
    <xsl:template match="ab[ancestor::ab]">
        <item>
            <xsl:choose>
                <xsl:when test="ab">
                    <list>
                        <xsl:apply-templates select="@*|node()" mode="#current"/>
                    </list>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </xsl:otherwise>
            </xsl:choose>
        </item>
    </xsl:template>
    
    <!--*** POINTERS/LINKS ***-->
    
    <xsl:template match="ptr[@target]">
        <ref target="{@target}"><xsl:value-of select="@target"/></ref>
    </xsl:template>

    <xsl:template match="ref/text()">
        <xsl:variable name="p1">
            <xsl:choose>
                <xsl:when test="not(preceding-sibling::node()) and not(following-sibling::node())">
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:when>
                <xsl:when test="not(preceding-sibling::node()) and following-sibling::node()">
                    <xsl:value-of select="replace(.,'^\s+','')"/>
                </xsl:when>
                <xsl:when test="preceding-sibling::node() and not(following-sibling::node())">
                    <xsl:value-of select="replace(.,'\s$','')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:analyze-string select="$p1" regex="^&lt;(.+)&gt;$">
            <xsl:matching-substring>
                <gi><xsl:value-of select="regex-group(1)"/></gi>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--*** QUOTATIONS **-->
    
    <xsl:template match="soCalled | mentioned">
        <q>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </q>
    </xsl:template>
    
    <xsl:template match="q[ancestor::back]">
        <xsl:text>"</xsl:text><xsl:apply-templates mode="#current"/><xsl:text>"</xsl:text>
    </xsl:template>

    <!--*** TABLES ***-->
    
    <xsl:template match="div[table[row/cell/@cols='2']]">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="table/preceding-sibling::node()" mode="#current"/>
            <p><xsl:apply-templates select="table/row/cell[@cols='2']/node()" mode="#current"/></p>
            <xsl:apply-templates select="table|table/following-sibling::node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>Template to add in ODD spec.</xd:desc>
    </xd:doc>
    <xsl:template match="div[@type='refdoc']/table">
        <!--Handle the table normally-->
        <xsl:variable name="thisId" select="parent::div/@xml:id"/>
        <xsl:variable name="thisIdent" select="substring-after($thisId,'TEI.')"/>
        <xsl:variable name="thisSpec" select="$specMap($thisIdent)" as="element()?"/>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:for-each-group select="row[not(cell[@cols = '2'])]" group-adjacent="jt:getRowLabel(.)">
                <xsl:choose>
                    <!--Rows to ignore -->
                    <xsl:when test="current-grouping-key() = ('Schema Declaration', 'Declaration', 'Content model')"/>
                    <xsl:when test="current-grouping-key() = 'Schematron'">
                        <row>
                            <cell>
                                <label>Schematron</label>
                                <cell>
                                   <xsl:for-each select="$thisSpec//constraintSpec">
                                       <div>
                                           <xsl:for-each select="desc">
                                               <p><xsl:apply-templates select="node()"/></p>
                                           </xsl:for-each>
                                           <eg:egXML>
                                               <xsl:apply-templates select="constraint/node()"/>
                                           </eg:egXML>
                                       </div>
                                       
                                   </xsl:for-each>
                                </cell>
                            </cell>
                        </row>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <row>
                            <cell>
                                <label><xsl:value-of select="if (current-grouping-key() = 'Example') then 'Examples' else current-grouping-key()"/></label>
                            </cell>
                            <cell>
                                <xsl:apply-templates select="current-group()/cell[2]/node()"/>
                            </cell>
                        </row>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
            <xsl:if test="$thisSpec">
                <row>
                    <cell><label>Source</label></cell>
                    <cell>
                        <ref target="https://github.com/TEIC/TEI/blob/dev/P5/Source/Specs/{$thisIdent}.xml" rend="right">Github</ref>
                        <eg:egXML>
                            <xsl:apply-templates select="$thisSpec" mode="eg"/>
                        </eg:egXML>
                    
                    </cell>
                </row>
                
            </xsl:if>
           
        </xsl:copy>
        
    </xsl:template>
    
    <!--Remove constraint specs now from the cell-->
    <xsl:template match="constraintSpec" mode="eg"/>
    
    <xsl:template match="@*|node()" mode="eg" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
    <!--*** INLINE FIXES ***-->
    
    <xsl:template match="hi[@rend='label']">
        <label>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </label>
    </xsl:template>
    
    <xsl:template match="choice[abbr and expan]">
        <xsl:apply-templates select="expan/node()" mode="#current"/>
    </xsl:template>

    <xsl:template match="hi">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="sch:*">
        <xsl:element name="sch:{local-name()}">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text()[parent::sch:*]">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <!--*** CODE BLOCKS *** -->
    
    <xsl:template match="c|seg">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="ab[@xml:space='preserve'][@rend='pre'][ancestor::back][ancestor::div[normalize-space(string-join(head/text(),''))='Constraints']] | eg[@xml:space='preserve'][not(@rend='eg_rnc')]">
        <code>
            <xsl:value-of select="replace(.,' ',' ')"/>
        </code>
    </xsl:template>

    <xsl:template match="hi[starts-with(string-join(text(),''),'@')]">
        <att>
            <xsl:value-of select="substring-after(string-join(text(),''),'@')"/>
        </att>
    </xsl:template>
    
    <xsl:template match="hi[@rend='att']">
        <att>
            <xsl:apply-templates mode="#current"/>
        </att>
    </xsl:template>
    
    <xsl:template match="hi[@rend='val']">
        <val>
            <xsl:apply-templates mode="#current"/>
        </val>
    </xsl:template>
    

    
    <xsl:template match="cell[@rend='Attribute']/att">
        <xsl:analyze-string select="text()" regex="'^(\w+)(\s+.+)$'">
            <xsl:matching-substring>
                <att><xsl:value-of select="regex-group(1)"/></att><xsl:value-of select="regex-group(2)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:copy>
                    <xsl:value-of select="."/>
                </xsl:copy>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template match="tei:ab[@xml:space='preserve'][contains(.,'&lt;')][not(ancestor::div[head/text()='Constraints'])][not(ancestor::row[jt:getRowLabel(.) = 'Schematron'])] ">
        <code>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </code>
    </xsl:template>
    
    <xsl:template match="eg[@xml:space='preserve'][@rend='eg_rnc']">
        <code>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </code>
    </xsl:template>
    
    <!--*** DELETIONS ***-->
    
    <xsl:template match="index"/>
    <xsl:template match="processing-instruction('TEIVERSION')" />
    <!--Remove the root TEI attribute-->
    <xsl:template match="TEI/@xml:id"/>
    <!--Be explicit about the tei NS here to avoid matching egXMLs-->
    <xsl:template match="tei:*[ancestor::back]/@rend| tei:*/@xml:base | tei:*/@xml:lang | eg:egXML/@xml:space | tei:*/@xml:space" />
    
    
    <xsl:function name="jt:getBestVersion" as="element()" new-each-time="no">
        <xsl:param name="spec" as="element()"/>
        <xsl:param name="name" as="xs:string"/>
        <xsl:variable name="candidates" 
            select="$spec/*[@versionDate][local-name() = $name][lang('en')]" as="element()+"/>
        <xsl:variable name="sorted" 
            select="sort($candidates, (), function($el){xs:date($el/@versionDate)})"/>
        <xsl:sequence select="$candidates[last()]"/>
    </xsl:function>
    
    <xsl:function name="jt:getRowLabel" as="xs:string" new-each-time="no">
        <xsl:param name="row" as="element(row)"/>
        <xsl:sequence select="normalize-space(string-join($row/cell[1]/descendant::text(),''))"/>
    </xsl:function>

</xsl:stylesheet>