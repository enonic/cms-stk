<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    time.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">    
    
    <xsl:template name="stk:general.add-attributes">
        <xsl:param name="attr" as="xs:string*"/>
        <xsl:for-each select="$attr">
            <xsl:variable name="tokenized-attr" select="tokenize(., '=')"/>
            <xsl:if test="normalize-space($tokenized-attr[1]) and normalize-space($tokenized-attr[2])">
                <xsl:attribute name="{$tokenized-attr[1]}" select="$tokenized-attr[2]"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    

</xsl:stylesheet>
