<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://relaxng.org/ns/structure/1.0"
    xmlns="http://relaxng.org/ns/structure/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 24, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> takeda</xd:p>
            <xd:p>Very simple, and hopefully soon-deletable, stylesheet
            to interleaving.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--Identity transform-->
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xd:doc>
        <xd:desc>Convert the lim.personMacro group to an interleave.</xd:desc>
    </xd:doc>
    <xsl:template match="define[@name='lim.personMacro']/group">
        <interleave>
            <xsl:apply-templates select="@*|node()"/>
        </interleave>
    </xsl:template>
    
    
</xsl:stylesheet>