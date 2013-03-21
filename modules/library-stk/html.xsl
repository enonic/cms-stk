<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    html.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml" version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">
    
    <xsl:import href="/modules/library-stk/stk-variables.xsl"/>
    <xsl:import href="/modules/library-stk/image.xsl"/>
    <xsl:import href="/modules/library-stk/video.xsl"/>
    
    <xsl:template name="stk:html.process">
        <xsl:param name="filter" as="xs:string?" select="$stk:config-filter"/>
        <xsl:param name="imagesize" as="element()*" select="$stk:config-imagesize"/>
        <xsl:param name="document" as="element()"/>
        <xsl:param name="image" as="element()*" select="//content[contentdata/sourceimage]"/>
        <xsl:param name="region-width" as="xs:integer" select="$stk:region-width"/>
        <div class="editor">
            <xsl:apply-templates select="$document/*|$document/text()" mode="html.process">
                <xsl:with-param name="image" tunnel="yes" select="$image"/>
                <xsl:with-param name="filter" tunnel="yes" select="$filter"/>
                <xsl:with-param name="imagesize" tunnel="yes" select="$imagesize"/>
                <xsl:with-param name="region-width" tunnel="yes" select="$region-width"/>
            </xsl:apply-templates>
        </div>        
    </xsl:template>
    
    <xsl:template match="element()" mode="html.process">
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="*|text()|@*" mode="html.process"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text()|@*" mode="html.process">
        <xsl:copy/>
    </xsl:template>
    
    <!-- Replaces td, th @align with @style -->
    <xsl:template match="table/@align|td/@align|th/@align" mode="html.process">
        <xsl:attribute name="style">
            <xsl:value-of select="concat('text-align: ', ., ';')"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Replaces @align with @style -->
    <xsl:template match="@align" mode="html.process">        
        <xsl:attribute name="style">
            <xsl:value-of select="concat('float: ', ., ';')"/>
        </xsl:attribute>
    </xsl:template>    
    
    <!-- Replaces @valign with @style -->
    <xsl:template match="@valign" mode="html.process">
        <xsl:attribute name="style">
            <xsl:value-of select="concat('vertical-align: ', ., ';')"/>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Fixes anchor elements that are empty -->
    <xsl:template match="a[@name and @name != '']" mode="html.process">
        <a>
            <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
            <xsl:if test="@id and @id != ''">
                <xsl:attribute name="id">
                    <xsl:value-of select="@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@href and @href != ''">
                <xsl:attribute name="href">
                    <xsl:value-of select="@href"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="*|text()">
                    <xsl:apply-templates select="*|text()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:comment> </xsl:comment>
                </xsl:otherwise>
            </xsl:choose>
        </a>
    </xsl:template>
    
    <xsl:template match="@src[parent::img][starts-with(., 'image://')]" mode="html.process">
        <xsl:param name="filter" tunnel="yes" as="xs:string?"/><!--
        <xsl:param name="imagesize" tunnel="yes" as="element()*"/> -->
        <xsl:param name="image" tunnel="yes" as="element()*"/>
        <xsl:param name="region-width" tunnel="yes" as="xs:integer?"/>
        <xsl:variable name="url-part" select="tokenize(., '://|\?|&amp;')"/>
        <xsl:variable name="url-type" select="$url-part[1]"/>
        <xsl:variable name="url-key" select="$url-part[2]"/>
        <xsl:variable name="url-parameter" select="$url-part[position() gt 2]"/>
        <xsl:variable name="url-size" select="substring-after($url-parameter[contains(., '_size=')], '=')"/>
        <xsl:variable name="url-filter" select="substring-after($url-parameter[contains(., '_filter=')], '=')"/>
        <xsl:variable name="url-background" select="substring-after($url-parameter[contains(., '_background=')], '=')"/>
        <xsl:variable name="url-format" select="substring-after($url-parameter[contains(., '_format=')], '=')"/>
        <xsl:variable name="url-quality" select="substring-after($url-parameter[contains(., '_quality=')], '=')"/>
        <xsl:variable name="source-image" as="element()?" select="$image[@key = $url-key]"/>
        <xsl:variable name="url-parameters" as="xs:anyAtomicType*">
            <xsl:for-each select="$url-parameter">
                <xsl:sequence select="substring-after(tokenize(., '=')[1], '_'), tokenize(., '=')[2]"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:attribute name="{name()}">
            <xsl:choose>
                <xsl:when test="$source-image">
                    <xsl:call-template name="stk:image.create-url">
                        <xsl:with-param name="image" select="$source-image"/>
                        <xsl:with-param name="size" select="$url-size"/>
                        <xsl:with-param name="background" select="$url-background"/>
                        <xsl:with-param name="format" select="if (normalize-space($url-format)) then $url-format else $stk:default-image-format" />
                        <xsl:with-param name="quality" select="if ($url-quality castable as xs:integer) then $url-quality else $stk:default-image-quality"/>
                        <xsl:with-param name="scaling" select="$url-filter"/>
                    </xsl:call-template>
                </xsl:when>   
                <xsl:otherwise>
                    <xsl:text>image-not-found</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:if test="$source-image">
            <xsl:variable name="image-width" select="stk:image.get-size($region-width, $url-size, concat($url-filter, $filter), $source-image, 'width')"/>
            <xsl:variable name="image-height" select="stk:image.get-size($region-width, $url-size, concat($url-filter, $filter), $source-image, 'height')"/>
            <xsl:if test="$image-width and $image-height">
                <xsl:attribute name="width">
                    <xsl:value-of select="$image-width"/>
                </xsl:attribute>
                <xsl:attribute name="height">
                    <xsl:value-of select="$image-height"/>
                </xsl:attribute>
            </xsl:if>
        </xsl:if>  
    </xsl:template>
    
    <xsl:template match="@href[parent::a]|@data[parent::object]|@src[parent::param]|@src[parent::video]|@src[parent::audio]|@src[parent::source]|@src[parent::track]" mode="html.process">
        <xsl:attribute name="{name()}" select="stk:html.process-url(.)"/>
    </xsl:template>
    
    <xsl:template match="iframe[contains(@src, 'youtube')]" mode="html.process">
        <xsl:param name="region-width" tunnel="yes"/>
        <xsl:call-template name="stk:video.embed-youtube">
            <xsl:with-param name="video-id" select="@src"/>
            <xsl:with-param name="width" select="@width"/>
            <xsl:with-param name="height" select="@height"/>
            <xsl:with-param name="region-width" select="$region-width"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:function name="stk:html.process-url" as="xs:string?">
        <xsl:param name="url" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($url, 'page://\d+')">
                <xsl:value-of select="portal:createPageUrl(substring-after($url, 'page://'), ())"/>
            </xsl:when>
            <xsl:when test="matches($url, 'content://\d+')">
                <xsl:value-of select="portal:createContentUrl(substring-after($url, 'content://'))"/>
            </xsl:when>
            <xsl:when test="matches($url, 'attachment://\d+')">
                <xsl:value-of select="portal:createAttachmentUrl(tokenize(substring-after($url, 'attachment://'), '\?')[1], ('_download', 'true'))"/>
            </xsl:when>
            <xsl:otherwise>                
                <xsl:value-of select="$url"/>    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
