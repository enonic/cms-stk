<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"    
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">
    
    <xsl:import href="/modules/library-stk/stk-variables.xsl"/>
    <xsl:import href="/modules/library-stk/region.xsl"/>
    <xsl:import href="/modules/library-stk/head.xsl"/>
    <xsl:import href="/modules/library-stk/accessibility.xsl"/>    
    <xsl:import href="/modules/library-stk/navigation.xsl"/>
    <xsl:import href="/modules/library-stk/analytics.xsl"/>    
    <xsl:import href="/modules/library-stk/system.xsl"/>   

    
    <!-- HTML 5 doctype -->
    <xsl:output doctype-system="about:legacy-compat" method="xhtml" encoding="utf-8" indent="no" omit-xml-declaration="yes" include-content-type="no"/>
    
    <!-- Select template based on current device -->
    <xsl:template match="/">
        <!-- Run config check to make sure everything is OK -->
        <xsl:variable name="config-status" select="stk:system.check-config()"/>
        <xsl:choose>
            <xsl:when test="$config-status/node()">
                <xsl:copy-of select="$config-status"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="page"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Desktop template -->
    <xsl:template name="page">
        <html lang="{$stk:language}">
            <head>
                <title>
                    <xsl:value-of select="stk:navigation.get-menuitem-name($stk:current-resource)"/>
                    <xsl:value-of select="concat(' - ', $stk:site-name)"/>
                </title>
                
                <link rel="shortcut icon" type="image/x-icon" href="{stk:file.create-resource-url('/all/favicon.ico')}"/>

                <!-- With a getContent on each "show" Page Template we'll be able to fetch the preface field and use it for meta description -->
                <xsl:call-template name="stk:head.create-metadata">
                    <xsl:with-param name="description">
                         <xsl:choose>
                            <xsl:when test="/result/contents/content/contentdata/preface != ''">
                               <xsl:value-of select="/result/contents/content/contentdata/preface"/>
                            </xsl:when>
                            <xsl:when test="/result/contents/content/contentdata/description != ''">
                               <xsl:value-of select="/result/contents/content/contentdata/description"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text></xsl:text><!-- empty -->
                            </xsl:otherwise>
                         </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>

                <xsl:call-template name="stk:head.create-css"/>                
                <xsl:call-template name="stk:head.create-open-graph-meta"/>
                
                <script src="{portal:createResourceUrl('/_public/library-stk/js/head.load.min.js')}"/>
                <xsl:call-template name="stk:head.create-js">
                    <xsl:with-param name="placement" select="'head'"/>
                </xsl:call-template>
                <noscript>
                    <style>
                        .js-img {display:none;}
                    </style>
                </noscript>
            </head>
            <body>
                <div id="container">
                    <!-- Create content bypass links if defined in config -->
                    <xsl:call-template name="stk:accessibility.create-bypass-links"/>
                                        
                    <h1>My first headline</h1>
                    
                    <!-- Renders all regions defined in config -->
                    <xsl:call-template name="stk:region.create">
                        <xsl:with-param name="layout" select="$layout" as="xs:string"/>
                    </xsl:call-template>
                    
                </div>
                <!-- This is outputted if set in config -->
                <xsl:call-template name="stk:analytics.google"/>
                
                <xsl:call-template name="stk:head.create-js">
                    <xsl:with-param name="placement" select="'body'"/>
                </xsl:call-template>  
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>
