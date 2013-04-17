<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    file.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">    
    
    <xsl:import href="stk-variables.xsl"/> 
        
    <!-- Formats bytes -->
    <xsl:function name="stk:file.format-bytes" as="xs:string">
        <xsl:param name="bytes" as="xs:integer"/>
        <xsl:value-of select="if ($bytes ge 1073741824) then concat(format-number($bytes div 1073741824, '0.#'), ' GB') else if ($bytes ge 1048576) then concat(format-number($bytes div 1048576, '0.#'), ' MB') else if ($bytes ge 1024) then concat(format-number($bytes div 1024, '0'), ' KB') else concat($bytes, ' B')"/>
    </xsl:function>
    
    <!-- Displays icon image -->
    <xsl:template name="stk:file.create-icon-image">
        <xsl:param name="file-name" as="xs:string"/>
        <xsl:param name="icon-folder-path" as="xs:string" select="concat($stk:theme-public, '/img/all/')"/>
        <xsl:param name="icon-image-prefix" as="xs:string" select="'icon-'"/>
        <xsl:param name="icon-image-file-extension" as="xs:string" select="'png'"/>
        <xsl:variable name="file-extension" select="stk:file.get-extension($file-name)"/>
        <xsl:variable name="image-url">
            <xsl:value-of select="$icon-folder-path"/>
            <xsl:if test="not(ends-with($icon-folder-path, '/'))">/</xsl:if>
            <xsl:value-of select="$icon-image-prefix"/>
            <xsl:choose>
                <xsl:when test="matches($file-extension, 'html?')">
                    <xsl:text>htm</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'ppt|pps')">
                    <xsl:text>ppt</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'png|gif|jpe?g|tif|psd')">
                    <xsl:text>img</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'doc|dot')">
                    <xsl:text>doc</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'pdf')">
                    <xsl:text>pdf</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'avi|mpe?g|wmv')">
                    <xsl:text>vid</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'xls|xlt|csv')">
                    <xsl:text>xls</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'xml')">
                    <xsl:text>xml</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'te?xt|dat')">
                    <xsl:text>txt</xsl:text>
                </xsl:when>
                <xsl:when test="matches($file-extension, 'zip|tar|gz|qz|arj')">
                    <xsl:text>zip</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>file</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(starts-with($icon-image-file-extension, '.'))">.</xsl:if>
            <xsl:value-of select="$icon-image-file-extension"/>
        </xsl:variable>
        <!--
        <xsl:value-of select="stk:file.create-resource-url($image-url)"/>-->
        <img src="{stk:file.create-resource-url($image-url)}" alt="{concat(stk:file.get-type($file-name), ' ', portal:localize('stk.file.icon'))}" class="icon"/>
    </xsl:template>
    
    <!-- Displays file type -->
    <xsl:function name="stk:file.get-type" as="xs:string">
        <xsl:param name="file-name" as="xs:string"/>
        <xsl:variable name="file-extension" select="stk:file.get-extension($file-name)"/>
        <xsl:choose>
            <xsl:when test="matches($file-extension, 'html?')">
                <xsl:value-of select="portal:localize('stk.file.html')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'ppt|pps')">
                <xsl:value-of select="portal:localize('stk.file.powerpoint')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'png|gif|jpe?g|tif|psd')">
                <xsl:value-of select="portal:localize('stk.file.image')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'doc|dot')">
                <xsl:value-of select="portal:localize('stk.file.document')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'pdf')">
                <xsl:value-of select="portal:localize('stk.file.pdf')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'avi|mpe?g|wmv')">
                <xsl:value-of select="portal:localize('stk.file.video')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'xls|xlt|csv')">
                <xsl:value-of select="portal:localize('stk.file.excel')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'xml')">
                <xsl:value-of select="portal:localize('stk.file.xml')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'te?xt|dat')">
                <xsl:value-of select="portal:localize('stk.file.text')"/>
            </xsl:when>
            <xsl:when test="matches($file-extension, 'zip|tar|gz|qz|arj')">
                <xsl:value-of select="portal:localize('stk.file.zip')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="portal:localize('stk.file.file')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="stk:file.get-extension" as="xs:string?">
        <xsl:param name="file-path" as="xs:string"/>
        <xsl:if test="contains($file-path, '.')">
            <xsl:value-of select="lower-case(tokenize($file-path, '\.')[last()])"/>
        </xsl:if>            
    </xsl:function>
    
    <!-- generate public resource url -->
    <xsl:function name="stk:file.create-resource-url">
        <xsl:param name="file-path" as="xs:string"/>
        <xsl:variable name="file-extension" as="xs:string?" select="stk:file.get-extension($file-path)"/>            
        <xsl:if test="normalize-space($file-extension)">
            <xsl:variable name="file-type" as="xs:string?">
                <xsl:choose>
                    <xsl:when test="matches($file-extension, 'png|jpe?g|gif|ico')">
                        <xsl:text>img</xsl:text>
                    </xsl:when>
                    <xsl:when test="matches($file-extension, 'css|less')">
                        <xsl:text>css</xsl:text>
                    </xsl:when>
                    <xsl:when test="$file-extension = 'js'">
                        <xsl:text>js</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="normalize-space($file-type)">                    
                <xsl:value-of select="portal:createResourceUrl(concat($stk:theme-public, '/', $file-type, '/', $file-path))"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>
