<?xml version="1.0" encoding="UTF-8"?>
<!--
    **************************************************
    
    navigation.xsl
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
    <xsl:function name="stk:navigation.get-menuitem-name" as="xs:string">
        <xsl:param name="menuitem" as="element()?"/>
        <xsl:value-of select="if (normalize-space($menuitem/menu-name)) then $menuitem/menu-name else $menuitem/display-name"/>
    </xsl:function>
    
    <!-- Creates a standard ul-li menutree based on parameters sent as input -->
    <xsl:template name="stk:navigation.create-menu">
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
                <xsl:apply-templates select="$wrapped-menuitems" mode="stk:navigation.create-menu">
                    <xsl:with-param name="current-level" select="$current-level"/>
                    <xsl:with-param name="levels" select="$levels" tunnel="yes"/>
                    <xsl:with-param name="class" select="$class"/>                            
                    <xsl:with-param name="id" select="$id"/>
                </xsl:apply-templates>
            </xsl:variable>            
            <xsl:choose>
                <xsl:when test="normalize-space($container-element)">
                    <xsl:element name="{$container-element}">
                        <xsl:attribute name="role" select="'navigation'"/>
                        <xsl:sequence select="$rendered-menuitems"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$rendered-menuitems"/>
                </xsl:otherwise>
            </xsl:choose> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="menuitems" mode="stk:navigation.create-menu">
        <xsl:param name="levels" as="xs:integer" tunnel="yes"/>
        <xsl:param name="current-level" as="xs:integer"/>        
        <xsl:param name="class" as="xs:string?"/>
        <xsl:param name="id" as="xs:string?"/>
        <xsl:if test="$current-level le $levels">
            <ol role="menu">
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
                <xsl:apply-templates select="menuitem" mode="stk:navigation.create-menu">
                    
                    <xsl:with-param name="current-level" select="$current-level"/>
                </xsl:apply-templates>
            </ol>
        </xsl:if>        
    </xsl:template>    
    
    <xsl:template match="menuitem" mode="stk:navigation.create-menu">
        <xsl:param name="levels" as="xs:integer" tunnel="yes"/>
        <xsl:param name="current-level" as="xs:integer"/>
        <xsl:if test="((@type != 'label') or (@type = 'label' and menuitems)) and not(parameters/parameter[@name='hideFromMenu'] = 'true') and (@type != 'section')">
            <li role="menuitem">
                <xsl:variable name="classes" as="text()*">
                    <xsl:if test="@path = 'true'">
                        <xsl:text>path</xsl:text>
                    </xsl:if>
                    <xsl:if test="@active = 'true'">
                        <xsl:text>active</xsl:text>
                    </xsl:if>
                    <xsl:if test="menuitems/menuitem">
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
                <xsl:if test="@active = 'true'">
                    <xsl:attribute name="aria-selected" select="'true'"/>
                </xsl:if>                
                <xsl:choose>
                    <xsl:when test="@type = 'label'">
                        <xsl:value-of select="stk:navigation.get-menuitem-name(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <a href="{portal:createPageUrl(@key, ())}">
                            <xsl:value-of select="stk:navigation.get-menuitem-name(.)"/>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="menuitems[menuitem]" mode="stk:navigation.create-menu">
                    <xsl:with-param name="current-level" select="$current-level + 1"/>
                </xsl:apply-templates>
            </li>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="stk:navigation.create-breadcrumbs">
        <xsl:param name="include-home" as="xs:boolean" select="true()"/>
        <xsl:if test="not($stk:current-resource/@key = $stk:front-page)">            
            <nav class="breadcrumbs">
                <xsl:if test="$include-home">
                    <a href="{portal:createPageUrl($stk:front-page,())}" class="home">
                        <xsl:value-of select="portal:localize('stk.navigation.breadcrumbs.home')"/>
                    </a>
                </xsl:if>
                <xsl:apply-templates select="/result/context/resource/path/resource" mode="stk:navigation.create-breadcrumbs">
                    <xsl:with-param name="include-home" select="$include-home"/>
                </xsl:apply-templates>
                <xsl:if test="/result/context/resource/@key != /result/context/resource/path/resource[position() = last()]/@key">
                    <span class="active">                        
                        <xsl:value-of select="stk:navigation.get-menuitem-name(/result/context/resource)"/>
                    </span>
                </xsl:if>
            </nav>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="resource" mode="stk:navigation.create-breadcrumbs">
        <xsl:choose>
            <xsl:when test="type = 'label'">
                <span class="label">                    
                    <xsl:value-of select="stk:navigation.get-menuitem-name(.)"/>
                </span>
            </xsl:when>
            <xsl:when test="position() != last() or (position() = last() and @key != ../../@key)">
                <a href="{portal:createPageUrl(@key,())}">
                    <xsl:value-of select="stk:navigation.get-menuitem-name(.)"/>
                </a>
            </xsl:when>
            <xsl:otherwise>                
                <span class="active">
                    <xsl:value-of select="stk:navigation.get-menuitem-name(.)"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>