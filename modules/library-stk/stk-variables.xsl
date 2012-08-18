<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">

    <xsl:import href="/modules/library-stk/system.xsl"/>
    
    <!-- ########## Context variables ########## -->

    <xsl:variable name="stk:current-resource" as="element()" select="/result/context/resource"/>
    <xsl:variable name="stk:site-name" as="xs:string" select="/result/context/site/name"/>
    <xsl:variable name="stk:rendered-page" as="element()" select="/result/context/page"/>
    <xsl:variable name="stk:path" as="xs:string" select="concat('/', string-join(tokenize(/result/context/querystring/@servletpath, '/')[position() gt 3], '/'))"/>
    
    <xsl:variable name="stk:language" as="xs:string" select="if (normalize-space(/result/context/locale)) then /result/context/locale else /result/context/@languagecode"/>
    <xsl:variable name="stk:device-class" as="xs:string" select="if (/result/context/device-class) then /result/context/device-class else 'not-set'"/>
    <xsl:variable name="stk:user" as="element()?" select="/result/context/user"/>
    <xsl:variable name="stk:public-resources" as="xs:string" select="/result/context/site/path-to-public-home-resources"/>
    
    <xsl:variable name="stk:querystring-parameter" as="element()*" select="/result/context/querystring/parameter"/>
    
    <xsl:variable name="stk:region-width" as="xs:integer" select="if (/result/context/querystring/parameter[@name = '_config-region-width']) then /result/context/querystring/parameter[@name = '_config-region-width'] else 300"/>
    
    
    <!-- ########## Configuration variables ########## -->
    
    <xsl:variable name="stk:config" as="element()?" select="if (doc-available(concat(/result/context/site/path-to-home-resources, '/site.xml'))) then document(concat(/result/context/site/path-to-home-resources, '/site.xml'))/config else null"/>
    <xsl:variable name="stk:config-parameter" as="element()*" select="$stk:config/parameters/parameter"/>
    <xsl:variable name="stk:config-theme" as="xs:string?" select="$stk:config/theme"/>
    
    <xsl:variable name="stk:theme-location" as="xs:string" select="concat('/modules/', $stk:config-theme)" />
    <xsl:variable name="stk:theme-config" as="element()?" select="if (doc-available(concat($stk:theme-location, '/theme.xml'))) then document(concat($stk:theme-location, '/theme.xml'))/theme else null"/>
    <xsl:variable name="stk:theme-device-class" as="element()?" select="if ($stk:theme-config/device-classes/device-class[tokenize(@name, ',')[. = $stk:device-class]]) then $stk:theme-config/device-classes/device-class[tokenize(@name, ',')[. = $stk:device-class]] else $stk:theme-config/device-classes/device-class[1]"/>
    <xsl:variable name="stk:theme-region-prefix" as="xs:string?" select="$stk:theme-config/region-prefix"/>
    
    <xsl:variable name="stk:theme-public" select="concat('/_public/', $stk:config-theme, '/')" as="xs:string"/>
    
    <xsl:variable name="stk:front-page" as="element()?" select="stk:system.get-config-param('front-page', $stk:path)"/>
    <xsl:variable name="stk:error-page" as="element()?" select="/result/context/site/error-page/resource"/>
    <xsl:variable name="stk:login-page" as="element()?" select="/result/context/site/login-page/resource"/>
    
   <xsl:variable name="stk:config-filter">
        <xsl:value-of select="string-join($stk:theme-device-class/image/filters/filter, ';')"/>
        <xsl:if test="normalize-space($stk:theme-device-class/image/filters/filter)">;</xsl:if>
    </xsl:variable>
    
    <xsl:variable name="stk:config-imagesize" select="$stk:theme-device-class/image/sizes/size"/>
    
    <xsl:variable name="stk:default-image-format" as="xs:string" select="if ($stk:theme-device-class/image/format/text()) then $stk:theme-device-class/image/format else 'jpeg'"/>
    <xsl:variable name="stk:default-image-quality" as="xs:integer" select="if ($stk:theme-device-class/image/quality castable as xs:integer) then $stk:theme-device-class/image/quality else 75"/>
    
    
    <xsl:variable name="stk:site-admin-name" as="xs:string?" select="stk:system.get-config-param('site-admin-name', $stk:path)"/>
    <xsl:variable name="stk:site-admin-email" as="xs:string?" select="stk:system.get-config-param('site-admin-email', $stk:path)"/>
    


</xsl:stylesheet>
