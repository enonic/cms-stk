<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    json.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">
    
    <!-- encodes string for valid json -->
    <!-- don't remove linebreaks -->
    <xsl:function name="stk:json.encode-string" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:sequence
            select="replace(replace(replace(replace(replace(replace(replace(replace(replace($string, '\\','\\\\'), '/', '\\/'), '&quot;', '\\&quot;'), '
            ','\\n'), '
            ','\\r'), '	','\\t'), '\n','\\n'), '\r','\\r'), '\t','\\t')"/>    
    </xsl:function>
    
</xsl:stylesheet>
