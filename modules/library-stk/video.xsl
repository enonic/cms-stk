<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    video.xsl
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml" version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">
    
    <xsl:import href="/modules/library-stk/stk-variables.xsl"/>
    
    <xsl:template name="stk:video.embed-youtube">
        <xsl:param name="video-id" as="xs:string"/>
        <xsl:param name="width" as="xs:integer" select="560"/>
        <xsl:param name="height" as="xs:integer" select="315"/>
        <xsl:param name="region-width" as="xs:integer" select="$stk:region-width"/>
        <xsl:variable name="aspect-ratio" as="xs:double" select="$width div $height"/>
        
        <iframe class="youtube-video">
            <!-- supports various ways of entering the ID -->
            <xsl:attribute name="src">
                <xsl:text>http://www.youtube.com/embed/</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains($video-id, '?')">
                        <xsl:value-of select="tokenize(tokenize($video-id, '\?|&amp;')[contains(., 'v=')][1], '=')[2]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="tokenize($video-id, '/')[last()]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- make sure the video width fits inside the current region width -->
            <xsl:attribute name="width" select="if ($width gt $region-width) then $region-width else $width"/>
            <xsl:attribute name="height" select="if ($width gt $region-width) then $region-width div $aspect-ratio else $height"/>
        </iframe>
    </xsl:template>
    
</xsl:stylesheet>
