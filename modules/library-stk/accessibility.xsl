<?xml version="1.0" encoding="UTF-8"?>

<!--
   **************************************************
   
   accessibility.xsl
   version: ###VERSION-NUMBER-IS-INSERTED-HERE###
   
   **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:portal="http://www.enonic.com/cms/xslt/portal"
   xmlns:stk="http://www.enonic.com/cms/xslt/stk">
   
   <xsl:import href="/modules/library-stk/stk-variables.xsl"/>
   
   <!-- Accessibility links -->
   <!-- Renders hotkeys to access different anchors as defined in the theme.xml -->
   <xsl:template name="stk:accessibility.create-bypass-links">
      <xsl:if test="exists($stk:theme-config/accessibility/bypass[@text][@anchor])">
         <ul class="accessibility bypass-links">
            <xsl:for-each select="$stk:theme-config/accessibility/bypass[@text][@anchor]">
               <li>
                  <a href="#{@anchor}">
                     <xsl:if test="normalize-space(@access-key)">
                        <xsl:attribute name="accesskey" select="@access-key"/>
                     </xsl:if>
                     <xsl:value-of select="portal:localize(@text)"/>
                  </a>
               </li>
            </xsl:for-each>
         </ul>         
      </xsl:if>
   </xsl:template>
   
   <xsl:template name="stk:accessibility.create-text-resizing-guidance">
      <div class="accessibility text-resizing-guidance">
         <span>
            <xsl:for-each select="1 to 3">               
               <span>A</span>
            </xsl:for-each>
         </span>
         <p>
            <xsl:value-of select="portal:localize('stk.accessibility.text-resizing-guidance')"/>
         </p>
      </div>
   </xsl:template>
   
</xsl:stylesheet>
