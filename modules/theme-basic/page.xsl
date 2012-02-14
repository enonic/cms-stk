<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fw="http://www.enonic.com/cms/xslt/framework"
    xmlns:util="http://www.enonic.com/cms/xslt/utilities"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal">
    
    <xsl:import href="/modules/library-utilities/fw-variables.xsl"/>
    <xsl:import href="/modules/library-utilities/region.xsl"/>
    <xsl:import href="/modules/library-utilities/head.xsl"/>
    <xsl:import href="/modules/library-utilities/error.xsl"/> 
    <xsl:import href="/modules/library-utilities/accessibility.xsl"/>
    <xsl:import href="/modules/library-utilities/google.xsl"/>    
    <xsl:import href="/modules/library-utilities/system.xsl"/>

    
    <!-- HTML 5 doctype -->
    <xsl:output doctype-system="about:legacy-compat" method="xhtml" encoding="utf-8" indent="yes" omit-xml-declaration="yes" include-content-type="no"/>
    
    <!-- page type -->
    <!-- For multiple layouts on one site. Various layouts can be configured in theme.xml, each with a different 'name' attribute on the 'layout' element. -->
    <xsl:param name="layout" as="xs:string" select="'default'"/>
    
    <!-- regions -->
    <xsl:param name="north">
        <type>region</type>
    </xsl:param>
    <xsl:param name="west">
        <type>region</type>
    </xsl:param>
    <xsl:param name="center">
        <type>region</type>
    </xsl:param>
    <xsl:param name="east">
        <type>region</type>
    </xsl:param>
    <xsl:param name="south">
        <type>region</type>
    </xsl:param>
    
    <!-- Select template based on current device -->
    <xsl:template match="/">
        <!-- Run config check to make sure everything is OK -->
        <xsl:variable name="config-status" select="util:system.check-config()"/>
        <xsl:choose>
            <xsl:when test="$config-status/node()">
                <xsl:copy-of select="$config-status"/>
            </xsl:when>
            <xsl:when test="$fw:device-class = 'mobile'">
                <xsl:call-template name="mobile"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="pc"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- PC template -->
    <xsl:template name="pc">
        <html>
            <head>
                <title>
                    <xsl:value-of select="util:menuitem-name($fw:current-resource)"/>
                    <xsl:value-of select="concat(' - ', $fw:site-name)"/>
                </title>
                <xsl:call-template name="util:head.create-metadata"/>
                <xsl:call-template name="util:head.create-javascript"/>
                <xsl:call-template name="util:head.create-css"/>
                
                <xsl:call-template name="util:region.create-css">
                    <xsl:with-param name="layout" select="$layout"/>
                </xsl:call-template>
            </head>
            <body>
                <div id="container">
                    <!-- Create content bypass links if defined in config -->
                    <xsl:call-template name="util:accessibility.create-bypass-links"/>
                                        
                    <span class="current-device-class">PC version</span>
                    <h1>My first headline</h1>
                    
                    <!-- Renders all regions defined in config -->
                    <xsl:call-template name="util:region.render">
                        <xsl:with-param name="layout" select="$layout" as="xs:string"/>
                    </xsl:call-template>
                    
                    <a href="{portal:createServicesUrl('portal','forceDeviceClass', ('deviceclass', 'mobile', 'lifetime', 'session'))}" class="change-device-class" rel="nofollow">
                        <xsl:value-of select="portal:localize('theme-basic.change-to-mobile-version')"/>
                    </a>
                    
                    
                    <xsl:call-template name="util:error.create-message"/>
                    
                </div>
                <xsl:call-template name="util:google.analytics"/>
            </body>
        </html>
    </xsl:template>
    
    
    <!-- MOBILE template -->
    <xsl:template name="mobile">
        <html>
            <head>                
                <title>
                    <xsl:value-of select="util:menuitem-name($fw:current-resource)"/>
                </title>
                <xsl:call-template name="util:head.create-metadata"/>                
                <meta content="minimum-scale=1.0, width=device-width, user-scalable=yes" name="viewport" />
                <meta name="apple-mobile-web-app-capable" content="yes" />
                
                <xsl:call-template name="util:head.create-javascript"/>
                <xsl:call-template name="util:head.create-css"/>
                
                <xsl:call-template name="util:region.create-css">
                    <xsl:with-param name="layout" select="$layout"/>
                </xsl:call-template>
            </head>
            <body>
                <div id="container">
                    <!-- Create content bypass links if defined in config -->
                    <xsl:call-template name="util:accessibility.create-bypass-links"/>
                                        
                    <span class="current-device-class">Mobile version</span>
                    <h1>My first headline</h1>
                    
                    <!-- Renders all regions defined in config -->
                    <xsl:call-template name="util:region.render">
                        <xsl:with-param name="layout" select="$layout" as="xs:string"/>
                    </xsl:call-template>
                    
                    <a href="{portal:createServicesUrl('portal','forceDeviceClass', ('deviceclass', 'pc', 'lifetime', 'session'))}" class="change-device-class" rel="nofollow">
                        <xsl:value-of select="portal:localize('theme-basic.change-to-pc-version')"/>
                    </a>
                    
                </div>
                <xsl:call-template name="util:google.analytics"/>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>
