<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
        encoding="UTF-8"        
        include-content-type="no"/>
        
    <!-- Generated stuff to remove. -->
    <xsl:template match="//processing-instruction()" />
    
    <xsl:template match="html">
        <html lang="en">
            <xsl:apply-templates />
        </html>
    </xsl:template>
    
    <xsl:template match="head">
        <head>
            <meta charset="utf-8"/>
            <meta http-equiv="Content-Type: text/html; charset=utf-8"></meta>
            <meta name="viewport" content="width=device-width, initial-scale=1"/>
            <xsl:apply-templates />
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous"/>            
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>        
        </head>
    </xsl:template>

    <xsl:template match="body">
        <body>
            <div class='container'>
                <div class='row'>
                    <h1><xsl:value-of select="//title/text()"/></h1>
                </div>
                <div class='row'>
                    <div class='col-md-8'>
                        <xsl:apply-templates select="./div[@id='original']"/>
                    </div>
                    <div class='col-md-4'>
                        <xsl:call-template name="metadata"/>
                    </div>
                </div>
            </div>
        </body>
    </xsl:template>
    
    <xsl:template name="metadata">
        <dl>
            <dt>Newspaper</dt>
            <dd>
                <xsl:apply-templates select="//meta[@name='dc.publisher']" mode="text"/>
                <xsl:if test="//meta[@name='dc.publisher.edition']">
                    - <xsl:apply-templates select="//meta[@name='dc.publisher.edition']" mode="text"/>                                    
                </xsl:if>
            </dd>
            <dt>Date published</dt>
            <dd>
                <xsl:apply-templates select="//meta[@name='dc.date']" mode="text" />
            </dd>
            <dt>Region</dt>
            <dd>
                <xsl:apply-templates select="//meta[@name='dc.region']" mode="text" />,
                <xsl:apply-templates select="//meta[@name='dc.region.city']" mode="text" />
            </dd>
            <dt>Original Language</dt>
            <dd>
                <xsl:apply-templates select="//meta[@name='dc.language']" mode="lang" />
            </dd>
            <dt>Sources</dt>
            <xsl:for-each select="//meta[@name=('dc.source','dc.source.institution','dc.source.database')]">
                <dd>
                    <xsl:apply-templates select='.' mode="text"/>
                </dd>
            </xsl:for-each>
            <xsl:for-each select="//meta[@name='dc.source.url']">
                <dd>
                    <xsl:apply-templates select='.' mode="link"/>
                </dd>
            </xsl:for-each>
            <dt>Facsimile</dt>
            <xsl:for-each select="//meta[@name='dc.source.facsimile']">
                <dd>
                    <xsl:apply-templates select='.' mode="link"/>
                </dd>
            </xsl:for-each>                            
        </dl>        
    </xsl:template>
    
    <xsl:template match="meta" mode="text">
        <xsl:value-of select="@content/string()" />
    </xsl:template>
    
    <xsl:template match="meta" mode="lang">
        <xsl:choose>
            <xsl:when test="@content = 'de'">German</xsl:when>
            <xsl:when test="@content = 'en'">English</xsl:when>
            <xsl:when test="@content = 'fr'">French</xsl:when>
            <xsl:when test="@content = 'it'">Italian</xsl:when>
            <xsl:when test="@content = 'es'">Spanish</xsl:when>
            <xsl:otherwise>
                Unknown Language: <xsl:value-of select="@content/string()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="meta" mode="link">
        <xsl:variable name="url" select="@content/string()"/>
        <xsl:analyze-string select="$url" regex="^https?://([^/]*)">
                <xsl:matching-substring>
                    <a href="{$url}">
                        <xsl:value-of select="regex-group(1)"/>
                    </a>                        
                </xsl:matching-substring>
            </xsl:analyze-string>       
    </xsl:template>

    <!-- Not quite the identity transform, but very close to it. -->
    <xsl:template match="attribute() | node()">
        <xsl:copy>
            <xsl:apply-templates select="attribute() | node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>
