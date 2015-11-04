<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal" xmlns:stk="http://www.enonic.com/cms/xslt/stk">

    <xsl:import href="stk-variables.xsl"/>

    <xsl:variable name="stk:region.active-regions" as="element()*">
        <xsl:copy-of select="/result/context/page/regions/region[count(windows/window) gt 0]"/>
    </xsl:variable>

    <!-- Regions template -->
    <!-- Renders region(s), either specified by region-name or all available regions -->
    <xsl:template name="stk:region.create" as="element()*">
        <xsl:param name="layout" as="xs:string" select="'default'"/>
        <xsl:apply-templates select="$stk:theme-device-class/layout[tokenize(@name, ',') = $layout]/row" mode="stk:region.create"/>
    </xsl:template>

    <xsl:template match="row" mode="stk:region.create">
        <div class="{concat('row ', @class)}">
            <xsl:apply-templates select="group|region[@name = $stk:region.active-regions/name]" mode="stk:region.create"/>
        </div>
    </xsl:template>

    <xsl:template match="group" mode="stk:region.create">
        <div>
            <xsl:attribute name="class">
                <xsl:text>group</xsl:text>
                <xsl:value-of select="concat(' span-', @cols)"/>
            </xsl:attribute>
            <xsl:apply-templates select="region[@name = $stk:region.active-regions/name]" mode="stk:region.create"/>
        </div>
    </xsl:template>

    <xsl:template match="region" mode="stk:region.create">
        <xsl:variable name="active-siblings" as="element()*" select="../region[index-of($stk:region.active-regions/name, concat($stk:theme-region-prefix, @name)) castable as xs:integer]"/>

        <xsl:variable name="cols" as="xs:integer">
            <xsl:choose>
                <xsl:when test="scalable = 'true'">
                    <xsl:variable name="cols-of-siblings" as="xs:integer">
                        <xsl:value-of select="sum($active-siblings[not(scalable = 'true')]/cols) + sum($active-siblings[not(scalable = 'true')]/margin/node()[name() = 'left' or name() = 'right'])"/>
                    </xsl:variable>
                    <xsl:value-of select="xs:integer(../@cols) - $cols-of-siblings"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="cols"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{if (current()/@element) then current()/@element else 'div'}">
            <xsl:attribute name="class">
                <xsl:text>region col</xsl:text>
                <xsl:value-of select="concat(' span-', $cols)"/>
                <xsl:value-of select="concat(' ', $stk:theme-region-prefix, current()/@name)"/>
                <xsl:if test="normalize-space(current()/@class)">
                    <xsl:value-of select="concat(' ', current()/@class)"/>
                </xsl:if>
            </xsl:attribute>

            <xsl:if test="normalize-space(current()/@role)">
                <xsl:attribute name="role" select="current()/@role"/>
            </xsl:if>

            <!-- Create portlet placeholder for region -->
            <xsl:for-each select="$stk:rendered-page/regions/region[name = concat($stk:theme-region-prefix, current()/@name)]/windows/window">
                <xsl:value-of select="portal:createWindowPlaceholder(@key, ())"/>
            </xsl:for-each>

        </xsl:element>
    </xsl:template>


</xsl:stylesheet>
