<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:jt="http://github.com/joeytakeda"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:xd="https://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns="http://www.w3.org/1999/xhtml"
    version="3.0">
    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>Author:</xd:b> joeytakeda</xd:p>
            <xd:p>Stylesheet for converting the processed and cleaned "lite" ODD into
            multi-page documentation.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--**************************************************************
       *                                                            * 
       *                        Includes                            *
       *                                                            *
       **************************************************************-->
    
    <xsl:include href="egXML.xsl"/>
    
    
    <!--**************************************************************
       *                                                            * 
       *                        Parameters                          *
       *                                                            *
       **************************************************************-->
    
    <xsl:param name="outDir"/>
    <xsl:param name="templateURI" select="'../assets/template.html'" as="xs:string"/>
    <xsl:param name="facsJsonURI" select="'../assets/js/facs.json'" as="xs:string"/>
    
    
    <!--**************************************************************
       *                                                            * 
       *                        Outputs/Modes                       *
       *                                                            *
       **************************************************************-->
    
    <xsl:output method="xhtml" encoding="UTF-8" indent="yes" normalization-form="NFC"
        exclude-result-prefixes="#all" omit-xml-declaration="yes" html-version="5.0"/>

    <xsl:mode name="xh" on-no-match="shallow-copy"/>    

    <!--**************************************************************
       *                                                            * 
       *                        Variables                           *
       *                                                            *
       **************************************************************-->

    <xsl:variable name="template" select="document($templateURI)" as="document-node()"/>
    <xsl:variable name="sourceDoc" select="TEI"/>
    <xsl:variable name="text" select="//text"/>
    <xsl:variable name="chapters" select="$text/body/div" as="element(div)+"/>
    <xsl:variable name="appendixItems" select="$text/back//div[@xml:id]/div[@xml:id]" as="element(div)+"/>
    <xsl:variable name="tocIds" select="for $div in ($chapters, $appendixItems) return jt:getId($div)" as="xs:string+"/>
    <xsl:variable name="facsArray" select="json-doc($facsJsonURI)" as="array(*)"/>
    
    <xsl:variable name="idMap" as="map(xs:string, xs:string+)">
        <xsl:map>
            <xsl:for-each select="($chapters, $appendixItems)">
                <xsl:variable name="currId" select="jt:getId(.)"/>
                <xsl:map-entry key="$currId" select="$currId"/>
                <xsl:for-each select="descendant::tei:*[self::div or @xml:id]">
                    <xsl:map-entry key="jt:getId(.)" select="$currId"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>
    
    <xsl:variable name="rndMap" 
        as="map(xs:string, xs:string)"
        select="map:merge($sourceDoc//rendition[@xml:id] ! map{string(@xml:id): string(.)})"/>
    
    <xsl:variable name="toc" as="element(xh:ul)">
        <ul>
            <xsl:apply-templates select="$text/(front|body|back)" mode="toc"/>
        </ul>
    </xsl:variable>
    
    <!--**************************************************************
       *                                                            * 
       *                        Named Templates                     *
       *                                                            *
       **************************************************************-->
   
    <xsl:template match="/">
        <xsl:message>Creating documentation pages</xsl:message>
        <!--Create index page-->
        <xsl:call-template name="createDoc">
            <xsl:with-param name="id" select="'index'"/>
            <xsl:with-param name="root" select="$text/front"/>
        </xsl:call-template>
        
        <!--Create main chapters-->
        <xsl:for-each select="($chapters, $appendixItems)">
            <xsl:call-template name="createDoc">
                <xsl:with-param name="id" select="jt:getId(.)"/>
                <xsl:with-param name="root" select="."/>
            </xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createDoc">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="root" select="." as="element()"/>
        <xsl:result-document href="{$outDir}/{$id}.html">
            <xsl:apply-templates select="$template" mode="xh">
                <xsl:with-param name="thisDiv" select="$root" tunnel="yes"/>
                <xsl:with-param name="thisId" select="$id" tunnel="yes"/>
            </xsl:apply-templates>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="createClass">
        <xsl:variable name="tokens" as="xs:string+">
            <xsl:value-of select="local-name()"/>
            <xsl:apply-templates select="@*" mode="class"/>
        </xsl:variable>
        
        <xsl:attribute name="class" select="string-join(tokenize(string-join($tokens,' ')),' ')"/>
    </xsl:template>
    
    <xsl:template match="@rend | @type | @level" mode="class">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="@rendition" mode="class">
        <xsl:value-of select="replace(.,'#','')"/>
    </xsl:template>
    
    <xsl:template match="@*" mode="class"/>


    <!--**************************************************************
       *                                                            * 
       *                        Templates: #xh                      *
       *                                                            *
       **************************************************************-->
    
    
    <xsl:template match="xh:html/@id" mode="xh">
        <xsl:param name="thisId" tunnel="yes"/>
        <xsl:attribute name="id" select="$thisId"/>
    </xsl:template>
    
    <xsl:template match="xh:head" mode="xh">
        <xsl:param name="thisDiv" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
            <xsl:if test="$thisDiv/descendant-or-self::*[@rendition]">
                <xsl:variable name="rndTokens" select="distinct-values($thisDiv/descendant-or-self::*[@rendition]/tokenize(@rendition))"/>
                <style>
                    <xsl:for-each select="$rndTokens">
                        <xsl:variable name="id" select="substring-after(.,'#')"/>
                        <xsl:value-of select="'.' || $id || '{' || $rndMap($id) || '}' || codepoints-to-string(10)"/>
                    </xsl:for-each>
                </style>
               
            </xsl:if>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xh:article" mode="xh">
        <xsl:param name="thisDiv" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*|h2" mode="#current"/>
            <xsl:apply-templates select="$thisDiv/node()" mode="main"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="xh:article/xh:h2" mode="xh">
        <xsl:param name="thisDiv" tunnel="yes"/>
        <xsl:copy>
            <xsl:value-of select="$thisDiv/head"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xh:head/xh:title" mode="xh">
        <xsl:param name="thisDiv" tunnel="yes"/>
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:value-of select="$thisDiv/head[1]"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="xh:nav/xh:ul" mode="xh">
       <xsl:apply-templates select="$toc" mode="#current"/>
    </xsl:template>
    
   <xsl:template match="xh:li" mode="xh">
       <xsl:param name="thisId" as="xs:string" tunnel="yes"/>
       <xsl:variable name="expandable" select="contains-token(@class,'expandable')"/>
       <xsl:variable name="childRefs" 
           select="descendant::xh:a[not(contains(@href,'#'))]/@href!substring-before(.,'.html')"
           as="xs:string*"/>
       <xsl:variable name="current" select="$thisId = $childRefs" as="xs:boolean"/>
       <xsl:copy>
           <xsl:apply-templates select="@*|node()" mode="#current">
               <xsl:with-param name="expandable" select="$expandable" tunnel="yes"/>
               <xsl:with-param name="current" select="$current" tunnel="yes"/>
           </xsl:apply-templates>
       </xsl:copy>
   </xsl:template>
    
    <xsl:template match="xh:li/xh:span/xh:a" mode="xh">
        <xsl:param name="current" tunnel="yes" select="false()" as="xs:boolean"/>
        <xsl:choose>
            <xsl:when test="$current">
                <span>
                    <xsl:apply-templates select="node()" mode="#current"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()" mode="#current"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="xh:li/@class" mode="xh">
        <xsl:param name="expandable" as="xs:boolean" tunnel="yes" select="false()"/>
        <xsl:param name="current" tunnel="yes" select="false()" as="xs:boolean"/>
        <xsl:variable name="newClasses" 
            select="(if ($current) then 'current' else (), if ($expandable and $current) then 'expanded' else ())"
            as="xs:string*"/>
        <xsl:attribute name="class" select="string-join((., $newClasses),' ')"/>
    </xsl:template>
    
    
    <xsl:template match="xh:div[@id='appendix']" mode="xh">
        <xsl:param name="thisDiv" tunnel="yes"/>
        <!--<xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="specLinks" select="$sourceDoc//ref[starts-with(@target,'#TEI.')]/@target/substring-after(.,'#')"/>
            <xsl:for-each select="distinct-values($specLinks)">
                <xsl:variable name="thisLink" select="."/>
                <div id="snippet_{.}">
                    <xsl:apply-templates select="$sourceDoc//div[@xml:id=$thisLink]/p[1]" mode="appendix"/>
                </div>
            </xsl:for-each>
        </xsl:copy>-->
    </xsl:template>
    
    <xsl:template match="xh:a/@href" mode="xh">
        <xsl:param name="currDivId" tunnel="yes"/>
        <xsl:if test="not($currDivId = substring-before(.,'.html'))">
            <xsl:sequence select="."/>
        </xsl:if>
    </xsl:template>
    

    <!--**************************************************************
       *                                                            * 
       *                        Templates: #main                    *
       *                                                            *
       **************************************************************-->
    
    <!--Remove mainHeading and back-->
    <xsl:template match="teiHeader | back" mode="main"/>
    
    <xsl:template match="front | body | TEI | text" mode="main">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!--Block level elements-->
    
    <xsl:template match="p | div | ab | cit[quote] | cit/quote | list | item | list/label" mode="main">
        <div>
            <xsl:call-template name="createClass"/>
            <xsl:attribute name="id" select="jt:getId(.)"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </div>
    </xsl:template>
    
    
    <!-- Special divGen handling for creating facs blocks -->
    <xsl:template match="divGen[@xml:id='helpful_links_facs']" mode="main">
        <div class="img-gallery-ctr">
            <h3>Facsimiles</h3>
            <xsl:for-each select="1 to 11">
                <xsl:variable name="volNum" select="."/>
                <details>
                    <summary>Volume <xsl:value-of select="$volNum"/></summary>
                    <div class="img-gallery">
                        <xsl:variable name="pages" select="array:get($facsArray, .)" as="array(*)"/>
                        <xsl:for-each select="1 to array:size($pages)">
                            <xsl:variable name="id" select="$pages(.) => xs:integer()" as="xs:integer"/>
                            <xsl:variable name="objId" select="'lyoninmourning:' || $id"/>
                            <xsl:variable name="objectUrl" select="'https://digital.lib.sfu.ca/islandora/object/' || encode-for-uri($objId)"/>
                            <a class="img-gallery-item" href="{$objectUrl}" loading="lazy">
                                <xsl:attribute name="target">_blank</xsl:attribute>
                                <xsl:attribute name="rel">noopener noreferrer</xsl:attribute>
                                <div>Page <xsl:value-of select="."/></div>
                                <img data-src="{$objectUrl}/datastream/TN/view" width="165px" height="200px" alt="Lyon in Mourning, Vol {$volNum}, p. {$id}"/>
                                
                            </a>
                        </xsl:for-each>
                    </div>
                </details>
            </xsl:for-each>
        </div>
    </xsl:template>
        
    
    <!--Headings-->
    
    <xsl:template match="head" mode="main">
        <xsl:param name="thisDiv" tunnel="yes"/>
        <xsl:variable name="count" select="count(ancestor::div[ancestor::div[. is $thisDiv]])"/>
        <xsl:element name="h{$count + 1}">
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    
    <!--Tables-->
    
    <xsl:template match="table[not(ancestor::table)]" mode="main">
        <div class="table-container">
            <xsl:next-match/>
        </div>
    </xsl:template>
    
    <xsl:template match="table" mode="main">
        <table>
            <xsl:if test="row[@role='label']">
                <thead>
                    <xsl:apply-templates select="row[@role='label']" mode="#current"/>
                </thead>
            </xsl:if>
            <tbody>
                <xsl:apply-templates select="row[not(@role='label')]" mode="#current"/>
            </tbody>
        </table>
    </xsl:template>
    
    
    <xsl:template match="row" mode="main">
        <tr>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </tr>
    </xsl:template>
    
    <xsl:template match="cell/@rend | table/@rend" mode="main"/>
    
    <xsl:template match="@role" mode="main">
        <xsl:attribute name="data-role" select="."/>
    </xsl:template>
    
    <xsl:template match="cell" mode="main">
        <td>
            <xsl:if test="@cols">
                <xsl:attribute name="colspan" select="@cols"/>
            </xsl:if>
            <xsl:apply-templates mode="#current"/>
        </td>
    </xsl:template>
    
    
    <!--Lists-->

 <!--   <xsl:template match="list[count(item) = 1 and item[list]]" mode="main">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="item[list][parent::list[count(item) = 1]]" mode="main">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>-->
    
    <!--Figures and graphics-->
    
    
    <xsl:template match="figure" mode="main">
        <figure>
            <xsl:apply-templates mode="#current"/>
        </figure>
    </xsl:template>
    
    <xsl:template match="graphic" mode="main">
        <img>
            <xsl:attribute name="alt" select="normalize-space((../figDesc, desc)[1])"/>
            <xsl:apply-templates select="@url|node()" mode="#current"/>
        </img>
    </xsl:template>
    
    <xsl:template match="graphic/@url" mode="main">
        <xsl:attribute name="src" select="."/>
    </xsl:template>
    
    
    <xsl:template match="graphic/desc" mode="main"/>
   
   <xsl:template match="figDesc" mode="main">
       <figcaption>
           <xsl:apply-templates mode="#current"/>
       </figcaption>
   </xsl:template>

    <!--Inline elements-->
    
    <xsl:template
        match="q | quote[not(ancestor::cit)] | title[not(@level)] | emph | label | gi | att | val | ident | label | term | foreign | title"
        mode="main">
        <span>
            <xsl:call-template name="createClass"/>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>
    
    <!--Code blocks-->
    <xsl:template match="code" mode="main">
        <xsl:element name="{if (ancestor::head) then 'span' else 'pre'}">
            <xsl:call-template name="createClass"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Links -->
    <xsl:template match="ref" mode="main">
        <xsl:param name="thisId" tunnel="yes"/>
        <xsl:variable name="external" select="matches(@target,'^https?')" as="xs:boolean"/>
        
        <xsl:variable name="resolvedTarget" select="jt:resolveRef(xs:string(@target))" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="exists($resolvedTarget)">
                <a href="{$resolvedTarget}">
                    <!--Make external links new tab-->
                    <xsl:if test="$external">
                        <xsl:attribute name="target">_blank</xsl:attribute>
                        <xsl:attribute name="rel">noopener noreferrer</xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="createClass"/>
                    <xsl:apply-templates mode="#current"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    
    <!--EG XML-->
    <xsl:template match="eg:egXML" mode="main">
        <xsl:apply-templates select="." mode="tei"/>
    </xsl:template>

   

    <!--**************************************************************
       *                                                            * 
       *                        Templates: #appendix                *
       *                                                            *
       **************************************************************-->
    
    
    <xsl:template match="p" mode="appendix">
        <div class="p">
            <xsl:apply-templates mode="#current"/>
        </div>
    </xsl:template>
    
    <xsl:template match="*" priority="-1" mode="appendix">
        <xsl:apply-templates select="." mode="main"/>
    </xsl:template>
    
    <xsl:template match="ref" mode="appendix"/>
    
    <xsl:template match="p/text()" mode="appendix">
        <xsl:value-of select="replace(replace(.,'\[\s*$',''),'^\s*\]','')"/>
    </xsl:template>
    
    <!--**************************************************************
       *                                                            * 
       *                        Templates: #toc                     *
       *                                                            *
       **************************************************************-->
    
    <xsl:template match="front" mode="toc">
        <li>
            <span class="nav-item">
                <a href="index.html">Home</a>
            </span>
        </li>
    </xsl:template>
    
    <xsl:template match="div" mode="toc">
        <xsl:variable name="thisId" select="jt:getId(.)" as="xs:string"/>
        <xsl:variable name="link" select="jt:resolveRef('#' || $thisId)" as="xs:string?"/>
        <xsl:variable name="title" select="(head, jt:getId(.))[1] => string()"/>
        <xsl:variable name="items" select="div" as="element(div)*"/>
        <li>
            <xsl:if test="exists($items)">
                <xsl:attribute name="class" select="'expandable'"/>
            </xsl:if>
            <span class="nav-item">
                <xsl:choose>
                    <xsl:when test="exists($link)">
                        <a href="{$link}"><xsl:value-of select="$title"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <span><xsl:value-of select="$title"/></span>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="exists($items)">
                    <span class="nav-dropdown">
                        <svg xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24" fill="black" width="18px" height="18px">
                            <path d="M16.59 8.59L12 13.17 7.41 8.59 6 10l6 6 6-6z"/>
                        </svg>
                    </span>
                </xsl:if>
            </span>
            <xsl:if test="exists($items)">
                <ul>
                    <xsl:apply-templates select="$items" mode="#current"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>
    
    
    <!--**************************************************************
       *                                                            * 
       *                       Functions                            *
       *                                                            *
       **************************************************************-->
    
    <xsl:function name="jt:resolveRef" as="xs:string?" new-each-time="no">
        <xsl:param name="target" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not(starts-with($target,'#'))">
                <xsl:sequence select="$target"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="targId" select="substring-after($target,'#')"/>
                <xsl:variable name="ancestorId" select="$idMap($targId)"/>
                <xsl:if test="exists($ancestorId)">
                    <xsl:choose>
                        <xsl:when test="$ancestorId = $targId">
                            <xsl:sequence select="$targId || '.html'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$ancestorId || '.html#' || $targId"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="jt:getId" as="xs:string" new-each-time="no">
        <xsl:param name="thing" as="element()"/>
        <xsl:choose>
            <xsl:when test="$thing/@xml:id">
                <xsl:value-of select="$thing/@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="head" select="$thing/head[1]" as="element(head)?"/>
                <xsl:variable name="slug" select="replace(lower-case($head), '[^A-Za-z0-9_-]+','_')" as="xs:string?"/>
                <xsl:value-of select="string-join(($slug, generate-id($thing)),'_')"/>
            </xsl:otherwise>
        </xsl:choose>
      
    </xsl:function>
    
</xsl:stylesheet>