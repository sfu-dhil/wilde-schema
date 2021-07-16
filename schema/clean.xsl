<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml" 
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs xhtml" 
    version="2.0">

    <xsl:output 
        method="xhtml" 
        omit-xml-declaration="yes" 
        doctype-public="" 
        doctype-system=""
        indent="yes" 
        include-content-type="no" 
        normalization-form="NFC"/>

    <xsl:variable name="quotes" select="false()"/>

    <!-- Generated stuff to remove. -->
    <xsl:template match="//processing-instruction()"/>
    <xsl:template match="html/@id"/>

    <xsl:template match="meta[@charset | @http-equiv]"/>
    <xsl:template match="meta[@name = ('dc.publisher.id', 'dc.publisher.sortable')]"/>
    <xsl:template
        match="meta[@name = ('wd.translated', 'index.document', 'index.paragraph', 'status')]"/>
    <xsl:template
        match="meta[@name = ('wr.translated', 'wr.wordcount', 'wr.word-count', 'wr.sortable')]"/>
    <xsl:template match="meta/@data-sortable"/>
    <xsl:template match="link"/>

    <xsl:template match="a" priority="1"/>
    <xsl:template match="p/@id"/>
    <xsl:template match="p[text() = '[...]']"/>
    <xsl:template match="div[@id = 'translation']"/>

    <!-- Make sure the head tag starts with a title and then contains only meta 
         elements sorted by @name and @content. -->
    <xsl:template match="head">
        <head>
            <xsl:variable name="publisher" select="//meta[@name = 'dc.publisher']/@content"/>
            <xsl:variable name="date"
                select="format-date(//meta[@name = 'dc.date']/@content, '[FNn], [MNn] [D], [Y0001]')"/>
            <title><xsl:value-of select="$publisher"/> - <xsl:value-of select="$date"/></title>

            <xsl:apply-templates select="meta">
                <xsl:sort select="@name"/>
                <xsl:sort select="@content"/>
            </xsl:apply-templates>
        </head>
    </xsl:template>

    <!-- Normalize Non-mixed content text -->
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space()"/>
    </xsl:template>

    <!-- Normalize mixed content text. Very careful whitespace handling. -->
    <xsl:template match="*[../text()[normalize-space(.) != '']]">
        <xsl:variable name="textbefore" select="preceding-sibling::node()[1][self::text()]"/>
        <xsl:variable name="textafter" select="following-sibling::node()[1][self::text()]"/>
        <xsl:variable name="prevchar" select="substring($textbefore, string-length($textbefore))"/>
        <xsl:variable name="nextchar" select="substring($textafter, 1, 1)"/>

        <xsl:if test="$prevchar != normalize-space($prevchar)">
            <xsl:text> </xsl:text>
        </xsl:if>

        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>

        <xsl:if test="$nextchar != normalize-space($nextchar)">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text()[normalize-space(.) != '']">
        <!-- see https://en.wikipedia.org/wiki/Quotation_mark -->
        <xsl:variable name="lang" select="ancestor-or-self::*/@lang/string()"/>
        <xsl:choose>
            <xsl:when test="$lang = 'de'">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="$lang = 'en'">
                <!-- The replacement must be done in two steps, due to XML's quoting rules. -->
                <xsl:variable name="txt" select='translate(., "‘’", "&apos;&apos;")'/>
                <xsl:value-of select="translate($txt, '“”', '&quot;&quot;')"/>
            </xsl:when>
            <xsl:when test="$lang = 'es'">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="$lang = 'fr'">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="$lang = 'it'">
                <xsl:value-of select="."/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Normalize attribute values -->
    <xsl:template match="attribute()">
        <xsl:attribute name="{local-name(.)}">
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:attribute>
    </xsl:template>

    <!-- Not quite the identity transform, but very close to it. -->
    <xsl:template match="element()">
        <xsl:copy>
            <xsl:choose>
                <xsl:when test="name() = 'meta'">
                    <!-- Sort the meta attributes as @name, @content for readability -->
                    <xsl:apply-templates select="@name"/>
                    <xsl:apply-templates select="@content"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Sort other element attributes by name for consistency -->
                    <xsl:apply-templates select="attribute()">
                        <xsl:sort select="name(.)"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
