<?xml version="1.0" encoding="UTF-8"?>

<!--
   **************************************************
   
   error.xsl
   version: ###VERSION-NUMBER-IS-INSERTED-HERE###
   
   **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:fw="http://www.enonic.com/cms/xslt/framework"
   xmlns:portal="http://www.enonic.com/cms/xslt/portal"
   xmlns:util="http://www.enonic.com/cms/xslt/utilities">
   
   <xsl:import href="/modules/library-utilities/fw-variables.xsl"/>

   <xsl:template name="util:error.create-message">
      <xsl:variable name="error" as="element()?" select="$fw:querystring-parameter[@name = 'http_status_code']"/>
      <xsl:variable name="url" as="xs:string?" select="/result/context/querystring/@url"/>
      <xsl:variable name="exception-message" as="xs:string?" select="$fw:querystring-parameter[@name = 'exception_message']"/>
      <xsl:if test="normalize-space($error)">
         <div class="error">
            <h2>
               <xsl:value-of select="portal:localize(concat('util.error.', $error, '-heading'))"/>
            </h2>
            <p class="description">
               <xsl:value-of select="portal:localize(concat('util.error.', $error, '-description'))"/>               
            </p>
            <xsl:if test="normalize-space($exception-message)">
               <p class="exception-message">
                  <span class="exception-message">
                     <xsl:value-of select="portal:localize('util.error.exception-message')"/>
                  </span>
                  <xsl:value-of select="$exception-message"/>
               </p>               
            </xsl:if>
            <xsl:if test="normalize-space($url)">
               <p class="url">
                  <span class="url">
                     <xsl:value-of select="portal:localize('util.error.url')"/>
                  </span>
                  <xsl:value-of select="$url"/>
               </p>               
            </xsl:if>
         </div>
         <xsl:if test="string($fw:site-admin-name) and string($fw:site-admin-email)">
            <p>
               <xsl:value-of select="concat(portal:localize('util.error.general-text'), ' ')"/>
               <a href="mailto:{$fw:site-admin-email}">
                  <xsl:value-of select="$fw:site-admin-name"/>
               </a>
            </p>
         </xsl:if>
      </xsl:if>      
   </xsl:template>

</xsl:stylesheet>
