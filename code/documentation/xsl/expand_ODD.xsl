<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:dhil="https://dhil.lib.sfu.ca"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 18, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> takeda</xd:p>
            <xd:p>Cleans up the stuff from pandoc</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="docsDir"/>
    
    <xsl:variable name="egNS">http://www.tei-c.org/ns/Examples</xsl:variable>
    
    <xsl:mode name="pandoc" on-no-match="shallow-copy" exclude-result-prefixes="#all"/>
    <xsl:mode name="odd" on-no-match="shallow-copy"/>
    <xsl:mode name="index" on-no-match="shallow-skip"/>
    
    <xsl:template match="/">
        <!--Kick off everything by processing the ODD-->
        <xsl:apply-templates mode="odd"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>Annoyingly, we have to wrap the index divGen in a div for it to valid,
        but we don't want that there in the mean time.</xd:desc>
    </xd:doc>
    <xsl:template match="div[divGen[@xml:id='index']]" mode="odd">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>Template to match the index</xd:desc>
    </xd:doc>
    <xsl:template match="divGen[@xml:id='index']" mode="odd">
        <xsl:apply-templates
            select="outermost(dhil:getMarkdownDoc('index.md')//list)"
            mode="index"/>
    </xsl:template>
    
    <xsl:template match="ref[@target]" mode="index">
         <xsl:variable name="thisDoc" select="dhil:getMarkdownDoc(@target)"/>
         <xsl:apply-templates select="$thisDoc" mode="pandoc">
             <xsl:with-param name="list" select="ancestor::item[1]/list" as="element(list)?" tunnel="yes"/>
         </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="body" mode="pandoc">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="body/div[1]" mode="pandoc">
        <xsl:param name="list" tunnel="yes" as="element(list)?"/>
        <xsl:copy>
            <!--Preserve space within examples esp.-->
            <xsl:attribute name="xml:space">preserve</xsl:attribute>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
            <xsl:apply-templates select="$list" mode="index"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="body/div/@xml:id" mode="pandoc">
        <xsl:attribute name="xml:id" select="tokenize(document-uri(root(.)),'[/\.]')[last() - 1]"/>
    </xsl:template>
    
    <xsl:template match="div/@type" mode="pandoc"/>
    
    <xsl:template match="figure/head" mode="pandoc">
        <figDesc>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </figDesc>
    </xsl:template>
    
    
    <xsl:template match="ref[ref]" mode="pandoc">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
        
    
    <xsl:template match="row[@role='label']/cell/p" mode="pandoc">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="seg[@type='code']" mode="pandoc">
        <xsl:variable name="string" select="string(.)"/>
        <xsl:variable name="rexes" select="map{
            'gi': '^&lt;(.+)&gt;$',
            'att': '^@(.+)$',
            'val': '^&quot;(.+)&quot;$'
            }"/>
        <xsl:iterate select="map:keys($rexes)">
            <xsl:on-completion>
                <code>
                    <xsl:value-of select="$string"/>
                </code>
            </xsl:on-completion>
            <xsl:variable name="el" select="."/>
            <xsl:variable name="rex" select="$rexes($el)"/>
            <xsl:if test="matches($string, $rex)">
                <xsl:break>
                    <xsl:element name="{$el}">
                        <xsl:value-of select="replace($string, $rex, '$1')"/>
                    </xsl:element>
                </xsl:break>
            </xsl:if>
        </xsl:iterate>
    </xsl:template>
    
   
    
    <xsl:template match="ab[contains-token(@type,'codeblock')]" mode="pandoc" exclude-result-prefixes="#all">
        <xsl:try>
            <xsl:variable name="frag" select="parse-xml-fragment(string(.))" exclude-result-prefixes="#all"/>
            <xsl:element name="egXML" namespace="{$egNS}">
                <xsl:apply-templates select="$frag" mode="#current" exclude-result-prefixes="#all"/>
            </xsl:element>
            <xsl:catch>
                <xsl:message>UNABLE TO PARSE <xsl:value-of select="."/></xsl:message>
                <code rend="block">
                    <xsl:apply-templates mode="#current"/>
                </code>
            </xsl:catch>
        </xsl:try>
    </xsl:template>


    <xsl:template match="*[empty(namespace-uri()) or namespace-uri() = '']" mode="pandoc">
        <xsl:element name="{local-name()}" namespace="{$egNS}">
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:function name="dhil:getMarkdownDoc" as="element(body)">
        <xsl:param name="ptr"/>
        <xsl:variable name="uri" select="$docsDir || '/' || replace($ptr,'\.md$','.xml')"/>
        <xsl:message>Processing <xsl:value-of select="$uri"/></xsl:message>
        <xsl:sequence select="document($uri)//body"/>
    </xsl:function>
    
    
    
</xsl:stylesheet>