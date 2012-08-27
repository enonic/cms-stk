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
        <xsl:value-of select="if (normalize-space($menuitem/display-name)) then $menuitem/display-name else if (normalize-space($menuitem/alternative-name)) then $menuitem/alternative-name else $menuitem/name"/>
    </xsl:function>
    
    <!-- Menu template -->
    <!-- Renders a standard ul-li menutree based on parameters sent as input -->
    <!-- NOTE: SUBJECT TO CHANGE -->
    <xsl:template name="stk:menu.render">
        <xsl:param name="menuitems" as="element()*" select="/result/menus/menu/menuitems"/>
        <xsl:param name="levels" as="xs:integer" select="0"/>
        <xsl:param name="currentLevel" as="xs:integer" select="1"/>
        <xsl:param name="list-class" as="xs:string?"/>
        <xsl:param name="list-id" as="xs:string?"/>
        <xsl:param name="container-element" as="xs:string?" select="'nav'"/>
        
        <xsl:choose>
            <xsl:when test="$menuitems">
                <xsl:if test="$menuitems/menuitem">
                    <xsl:variable name="rendered-tree" as="element()">
                        <ul>
                            <xsl:if test="$list-class != ''">
                                <xsl:attribute name="class">
                                    <xsl:value-of select="$list-class" />
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:if test="$list-id != ''">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="$list-id" />
                                </xsl:attribute>
                            </xsl:if>
                            <xsl:for-each select="$menuitems/menuitem">
                                <xsl:if test="(@type != 'label') or (@type = 'label' and current()/menuitems)">
                                    <li>
                                        <xsl:attribute name="class">
                                            <xsl:value-of select="concat('menu-level-', $currentLevel)"/>
                                            <xsl:if test="@path = 'true'">
                                                <xsl:text> path</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="@active = 'true'">
                                                <xsl:text> active</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="current()/menuitems/menuitem">
                                                <xsl:text> parent</xsl:text>
                                            </xsl:if>
                                        </xsl:attribute>
                                        <xsl:choose>
                                            <xsl:when test="@type = 'label'">
                                                <xsl:value-of select="stk:menu.menuitem-name(current())"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <a href="{portal:createPageUrl(@key, ())}" class="{if (position() = 1) then 'first' else if (position() = last()) then 'last' else ''}">
                                                    <xsl:value-of select="stk:menu.menuitem-name(current())"/>
                                                </a>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if test="current()/menuitems">
                                            <xsl:if test="$levels = 0 or $levels > $currentLevel">
                                                <xsl:call-template name="stk:menu.render">
                                                    <xsl:with-param name="menuitems" select="current()/menuitems"/>
                                                    <xsl:with-param name="currentLevel" select="$currentLevel + 1"/>
                                                    <xsl:with-param name="levels" select="$levels"/>
                                                    <xsl:with-param name="container-element" select="null"/>
                                                </xsl:call-template>
                                            </xsl:if>
                                        </xsl:if>
                                    </li>
                                </xsl:if>
                                
                            </xsl:for-each>
                        </ul>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="normalize-space($container-element)">
                            <xsl:element name="{$container-element}">
                                <xsl:copy-of select="$rendered-tree"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$rendered-tree"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>No menuitems exists on current menu element</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>