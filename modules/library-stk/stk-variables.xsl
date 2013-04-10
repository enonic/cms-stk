<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">

    <xsl:import href="/modules/library-stk/system.xsl"/>
    
    <!-- ########## Context variables ########## -->

    <xsl:variable name="stk:current-resource" as="element()" select="/result/context/resource"/>
    <xsl:variable name="stk:site-name" as="xs:string" select="/result/context/site/name"/>
    <xsl:variable name="stk:rendered-page" as="element()?" select="/result/context/page"/>
    
    <xsl:variable name="stk:path" as="xs:string" select="concat('/', string-join($stk:current-resource/path/resource/name, '/'))"/>
        
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
    <xsl:variable name="stk:theme-region-prefix" as="xs:string?" select="$stk:theme-config/region-prefix"/>
    <xsl:variable name="stk:theme-all-devices" as="element()?" select="$stk:theme-config/device-classes/device-class[@name = 'all']"/>
    <xsl:variable name="stk:theme-device-class" as="element()?" select="if ($stk:theme-config/device-classes/device-class[tokenize(@name, ',')[. = $stk:device-class]]) then $stk:theme-config/device-classes/device-class[tokenize(@name, ',')[. = $stk:device-class]] else $stk:theme-config/device-classes/device-class[tokenize(@name, ',')[. = 'unknown']]"/>
    <xsl:variable name="stk:theme-public" select="concat('/_public/', $stk:config-theme, '/')" as="xs:string"/>
    <xsl:variable name="stk:front-page" as="xs:integer?" select="if (stk:system.get-config-param('front-page', $stk:path) castable as xs:integer) then stk:system.get-config-param('front-page', $stk:path) else /result/context/site/front-page/resource/@key"/>
    <xsl:variable name="stk:error-page" as="xs:integer?" select="/result/context/site/error-page/resource/@key"/>
    <xsl:variable name="stk:login-page" as="xs:integer?" select="/result/context/site/login-page/resource/@key"/>
    <xsl:variable name="stk:config-filter" as="xs:string?">
       <xsl:choose>
           <xsl:when test="not($stk:theme-device-class/image/filters/filter != '') and $stk:theme-all-devices/image/filters/filter[normalize-space(text())]">
               <xsl:value-of select="concat(string-join($stk:theme-all-devices/image/filters/filter[normalize-space(text())], ';'), ';')"/>
           </xsl:when>
           <xsl:when test="$stk:theme-device-class/image/filters/filter[normalize-space(text())]">
               <xsl:value-of select="concat(string-join($stk:theme-device-class/image/filters/filter[normalize-space(text())], ';'), ';')"/>
           </xsl:when>
       </xsl:choose>
    </xsl:variable>
    <xsl:variable name="stk:config-imagesize" as="element()*">
        <xsl:for-each select="'full','wide','regular','list','square','thumbnail'">
            <xsl:sequence select="if ($stk:theme-device-class/image/sizes/size[@name = current()]) then $stk:theme-device-class/image/sizes/size[@name = current()] else $stk:theme-all-devices/image/sizes/size[@name = current()]"/>
        </xsl:for-each>
    </xsl:variable> 
    <xsl:variable name="stk:default-image-format" as="xs:string" select="if ($stk:theme-device-class/image/format/text()) then $stk:theme-device-class/image/format else if ($stk:theme-all-devices/image/format/text()) then $stk:theme-all-devices/image/format else 'jpeg'"/>
    <xsl:variable name="stk:default-image-quality" as="xs:integer" select="if ($stk:theme-device-class/image/quality castable as xs:integer) then $stk:theme-device-class/image/quality else if ($stk:theme-all-devices/image/quality castable as xs:integer) then $stk:theme-all-devices/image/quality else 75"/>

    
</xsl:stylesheet>
