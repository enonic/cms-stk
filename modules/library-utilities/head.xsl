<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:fw="http://www.enonic.com/cms/xslt/framework"
   xmlns:portal="http://www.enonic.com/cms/xslt/portal" 
   xmlns:util="http://www.enonic.com/cms/xslt/utilities">
  
   <xsl:import href="/modules/library-utilities/fw-variables.xsl"/>
   <xsl:import href="/modules/library-utilities/system.xsl"/>
   
   <!-- Metadata template -->
   <xsl:template name="util:head.create-metadata">
      <xsl:param name="description" as="xs:string?"/>
      <xsl:param name="keywords" as="xs:string?"/>
      
      <xsl:variable name="util:head.meta-generator" select="util:system.get-config-param('meta-generator', $fw:path)" as="element()?"/>
      <xsl:variable name="util:head.meta-author" select="util:system.get-config-param('meta-author', $fw:path)" as="element()?"/>      
      <xsl:variable name="util:head.meta-google-site-verification" select="util:system.get-config-param('google-site-verification', $fw:path)" as="element()?"/>
      
      <xsl:variable name="util:head.meta-description">
         <xsl:choose>
            <xsl:when test="/result/contents/content/contentdata/meta-description != ''">
               <xsl:value-of select="/result/contents/content/contentdata/meta-description"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fw:current-resource/description"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="util:head.meta-keywords">
         <xsl:choose>
            <xsl:when test="/result/contents/content/contentdata/meta-keywords != ''">
               <xsl:value-of select="/result/contents/content/contentdata/meta-keywords"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fw:current-resource/keywords"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="util:head.meta-content-key">
         <xsl:value-of select="/result/context/resource[@type = 'content']/@key"/>
      </xsl:variable>
      <xsl:variable name="util:head.meta-content-type">
         <xsl:value-of select="/result/context/resource[@type = 'content']/type"/>
      </xsl:variable>      
      
      <meta charset="utf-8"/>
      
      <xsl:if test="normalize-space($util:head.meta-generator)">
         <meta name="generator" content="{$util:head.meta-generator}"/>
      </xsl:if>
      
      <xsl:if test="normalize-space($util:head.meta-author)">
         <meta name="author" content="{$util:head.meta-author}"/>
      </xsl:if>
      
      <xsl:if test="normalize-space($description) or normalize-space($util:head.meta-description)">
         <meta name="description" content="{if (normalize-space($description)) then $description else $util:head.meta-description}"/>
      </xsl:if>
      
      <xsl:if test="normalize-space($keywords) or normalize-space($util:head.meta-keywords)">
         <meta name="description" content="{if (normalize-space($keywords)) then $keywords else $util:head.meta-keywords}"/>
      </xsl:if>

      <xsl:if test="normalize-space($util:head.meta-google-site-verification)">
         <meta name="google-site-verification" content="{$util:head.meta-google-site-verification}"/>
      </xsl:if>
      
      <!-- for Google Search Appliance -->
      <xsl:if test="normalize-space($util:head.meta-content-key)">
         <meta name="_key" content="{$util:head.meta-content-key}"/>
      </xsl:if>
      <xsl:if test="normalize-space($util:head.meta-content-type)">
         <meta name="_cty" content="{$util:head.meta-content-type}"/>
      </xsl:if>
   </xsl:template>
   
   

   <!-- Css common template -->
   <!-- Renders all CSS files and creates CSS for the regions defined in theme.xml  -->
   <xsl:template name="util:head.create-css">
      <xsl:for-each select="$fw:theme-device-class/styles/style[not(@condition != '')]">
         <link rel="stylesheet" href="{portal:createResourceUrl(.)}" type="text/css">
            <xsl:if test="@media = 'print'">
               <xsl:attribute name="media">print</xsl:attribute>
            </xsl:if>
         </link>
      </xsl:for-each>

      <xsl:if test="$fw:theme-device-class/styles/style[@condition != '']">
         <xsl:text disable-output-escaping="yes">&lt;!--[if </xsl:text>
         <xsl:for-each-group select="$fw:theme-device-class/styles/style[@condition != '']" group-by="@condition">
            <xsl:value-of select="@condition"/>
            <xsl:text disable-output-escaping="yes">]&gt;</xsl:text>
            <xsl:for-each select="$fw:theme-device-class/styles/style[@condition = current()/@condition]">
               <xsl:text disable-output-escaping="yes">&lt;link rel="stylesheet" type="text/css" href="</xsl:text>
               <xsl:value-of select="portal:createResourceUrl(.)"/>
               <xsl:text disable-output-escaping="yes">"/&gt;</xsl:text>
            </xsl:for-each>
            <xsl:text disable-output-escaping="yes">&lt;![endif]--&gt;</xsl:text>
         </xsl:for-each-group>
      </xsl:if>
   </xsl:template>
   
   

   <!-- Script common template -->
   <!-- Renders all javascript for current device as defined in the theme.xml -->
   <xsl:template name="util:head.create-javascript">
      <xsl:for-each select="$fw:theme-device-class/scripts/script">
         <script type="text/javascript" src="{portal:createResourceUrl(current())}"/>
      </xsl:for-each>
   </xsl:template>
   

</xsl:stylesheet>
