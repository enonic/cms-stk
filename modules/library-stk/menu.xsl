<?xml version="1.0" encoding="UTF-8"?>
<!--
    **************************************************
    
    menu.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">
    
    <xsl:import href="/modules/library-stk/stk-variables.xsl"/>
    <xsl:import href="/modules/library-stk/system.xsl"/>    
    
    <!-- Displays menu item name -->
    <xsl:function name="stk:menu.menuitem-name" as="xs:string">
        <xsl:param name="menuitem" as="element()?"/>
        <xsl:value-of select="if (normalize-space($menuitem/menu-name)) then $menuitem/menu-name else $menuitem/display-name"/>
    </xsl:function>
    
    <!-- Renders a standard ul-li menutree based on parameters sent as input -->
    <xsl:template name="stk:menu.render">
        <xsl:param name="menuitems" as="element()*" select="/result/menus/menu/menuitems/menuitem"/>
        <xsl:param name="levels" as="xs:integer" select="99"/>
        <xsl:param name="current-level" as="xs:integer" select="1"/>
        <xsl:param name="class" as="xs:string?"/>
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="container-element" as="xs:string?" select="'nav'"/>
        
        <xsl:if test="$menuitems">
            <xsl:variable name="wrapped-menuitems" as="element()">
                <xsl:choose>
                    <xsl:when test="count($menuitems) = 1 and local-name($menuitems) = 'menuitems'">
                        <xsl:sequence select="$menuitems"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="menuitems" xmlns="">                 
                            <xsl:sequence select="$menuitems"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            
            <xsl:variable name="rendered-menuitems" as="element()*">  
                <xsl:apply-templates select="$wrapped-menuitems" mode="stk:menu.render">
                    <xsl:with-param name="current-level" select="$current-level"/>
                    <xsl:with-param name="levels" select="$levels" tunnel="yes"/>
                    <xsl:with-param name="class" select="$class"/>                            
                    <xsl:with-param name="id" select="$id"/>
                </xsl:apply-templates>
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="normalize-space($container-element)">
                    <xsl:element name="{$container-element}">
                        <xsl:sequence select="$rendered-menuitems"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$rendered-menuitems"/>
                </xsl:otherwise>
            </xsl:choose> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="menuitems" mode="stk:menu.render">
        <xsl:param name="levels" as="xs:integer" tunnel="yes"/>
        <xsl:param name="current-level" as="xs:integer"/>        
        <xsl:param name="class" as="xs:string?"/>
        <xsl:param name="id" as="xs:string?"/>
        <xsl:if test="$current-level le $levels">
            <ul>
                <xsl:attribute name="class">
                    <xsl:value-of select="concat('menu-level-', $current-level)"/>
                    <xsl:if test="normalize-space($class)">
                        <xsl:value-of select="concat(' ', $class)" />                        
                    </xsl:if>
                </xsl:attribute>
                <xsl:if test="normalize-space($id)">
                    <xsl:attribute name="id">
                        <xsl:value-of select="$id" />
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="menuitem" mode="stk:menu.render">
                    
                    <xsl:with-param name="current-level" select="$current-level"/>
                </xsl:apply-templates>
            </ul>
        </xsl:if>        
    </xsl:template>    
    
    <xsl:template match="menuitem" mode="stk:menu.render">
        <xsl:param name="levels" as="xs:integer" tunnel="yes"/>
        <xsl:param name="current-level" as="xs:integer"/>
        <xsl:if test="((@type != 'label') or (@type = 'label' and ./menuitems)) and not(./parameters/parameter[@name='hideFromMenu'] = 'true') and (@type != 'section')">
            <li>
                <xsl:variable name="classes" as="text()*">
                    <xsl:if test="./@path = 'true'">
                        <xsl:text>path</xsl:text>
                    </xsl:if>
                    <xsl:if test="./@active = 'true'">
                        <xsl:text>active</xsl:text>
                    </xsl:if>
                    <xsl:if test="./menuitems/menuitem">
                        <xsl:text>parent</xsl:text>
                    </xsl:if>                    
                </xsl:variable>
                <xsl:if test="$classes">
                    <xsl:attribute name="class">
                        <xsl:for-each select="$classes">
                            <xsl:value-of select="."/>
                            <xsl:if test="position() != last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </xsl:for-each>    
                    </xsl:attribute>
                </xsl:if>                
                <xsl:choose>
                    <xsl:when test="@type = 'label'">
                        <xsl:value-of select="stk:menu.menuitem-name(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{portal:createPageUrl(@key, ())}">
                            <xsl:value-of select="stk:menu.menuitem-name(.)"/>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="menuitems[menuitem]" mode="stk:menu.render">
                    <xsl:with-param name="current-level" select="$current-level + 1"/>
                </xsl:apply-templates>
            </li>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>