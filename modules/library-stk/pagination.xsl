<?xml version="1.0" encoding="UTF-8"?>

<!--
	**************************************************
	
	pagination.xsl
	version: ###VERSION-NUMBER-IS-INSERTED-HERE###
	
	**************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:portal="http://www.enonic.com/cms/xslt/portal"
	xmlns:stk="http://www.enonic.com/cms/xslt/stk">
	
	<xsl:import href="/modules/library-stk/stk-variables.xsl"/>
	
	<xsl:template name="stk:pagination.create-header">
		<xsl:param name="contents" as="element()"/>
		<xsl:param name="index" as="xs:integer?" select="xs:integer($contents/@index)"/>
		<xsl:param name="content-count" as="xs:integer?" select="xs:integer($contents/@resultcount)"/>
		<xsl:param name="total-count" as="xs:integer?" select="xs:integer($contents/@totalcount)"/>
		<xsl:param name="contents-per-page" as="xs:integer?" select="xs:integer($contents/@count)"/>
		<xsl:param name="always-show" as="xs:boolean" select="false()"/>
		<xsl:if test="$always-show or ($total-count gt $contents-per-page)">
			<div class="pagination-header">
				<xsl:variable name="range">
					<xsl:value-of select="$index + 1"/>
					<xsl:if test="$content-count gt 1">
						<xsl:value-of select="concat(' - ', $index + $content-count)"/>
					</xsl:if>
				</xsl:variable>
				<xsl:value-of select="portal:localize('stk.pagination.header-text', ($range, $total-count))"/>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="stk:pagination.create-menu">
		<xsl:param name="contents" as="element()"/>
		<xsl:param name="index" as="xs:integer?" select="xs:integer($contents/@index)"/>
		<xsl:param name="content-count" as="xs:integer?" select="xs:integer($contents/@resultcount)"/>
		<xsl:param name="total-count" as="xs:integer?" select="xs:integer($contents/@totalcount)"/>
		<xsl:param name="contents-per-page" as="xs:integer?" select="xs:integer($contents/@count)"/>
		<xsl:param name="parameters" as="element()*" select="$stk:querystring-parameter[not(@name = 'index' or @name = 'id' or starts-with(@name, '_config-'))]"/>
		<xsl:param name="pages-in-pagination" select="10" as="xs:integer"/>
		<xsl:param name="index-parameter-name" select="'index'" as="xs:string"/>
		<xsl:if test="$total-count gt $contents-per-page">
			<p id="{generate-id($contents)}" class="audible">Pagination</p>
			<nav class="pagination" aria-labelledby="{generate-id($contents)}">
				<ul>
					<!-- First page -->
					<xsl:if test="$index gt 0">
						<li class="first">
							<a href="{stk:pagination.create-url(0, $parameters, $index-parameter-name)}" title="{portal:localize('stk.pagination.first-page')}">
								<xsl:value-of select="portal:localize('stk.pagination.first-page')"/>
							</a>
						</li>
					</xsl:if>
					<!-- Previous page -->
					<xsl:if test="($index - $contents-per-page) ge 0">
						<li class="previous">
							<a href="{stk:pagination.create-url($index - $contents-per-page, $parameters, $index-parameter-name)}" title="{portal:localize('stk.pagination.previous-page')}">
								<xsl:value-of select="portal:localize('stk.pagination.previous-page')"/>
							</a>
						</li>
					</xsl:if>
					<!-- Middle pagination part -->
					<xsl:variable name="tmp" select="floor(($total-count - ($index + 1)) div $contents-per-page) - floor(($pages-in-pagination - 1) div 2)"/>
					<xsl:variable name="tmp2" select="if ($tmp gt 0) then 0 else $tmp"/>
					<xsl:variable name="tmp3" select="$index - (floor($pages-in-pagination div 2) * $contents-per-page) + ($tmp2 * $contents-per-page)"/>
					<xsl:call-template name="stk:pagination.create-menu-middle">
						<xsl:with-param name="start" tunnel="yes" select="if ($tmp3 lt 0) then 0 else $tmp3"/>
						<xsl:with-param name="max-count" tunnel="yes" select="$pages-in-pagination"/>
						<xsl:with-param name="parameters" tunnel="yes" select="$parameters"/>
						<xsl:with-param name="index" tunnel="yes" select="$index"/>
						<xsl:with-param name="total-count" tunnel="yes" select="$total-count"/>
						<xsl:with-param name="contents-per-page" tunnel="yes" select="$contents-per-page"/>
						<xsl:with-param name="index-parameter-name" tunnel="yes" select="'index'" as="xs:string"/>
					</xsl:call-template>
					<!-- Next page -->
					<xsl:if test="$index + $contents-per-page lt $total-count">
						<li class="next">
							<a href="{stk:pagination.create-url($index + $contents-per-page, $parameters, $index-parameter-name)}" title="{portal:localize('stk.pagination.next-page')}">
								<xsl:value-of select="portal:localize('stk.pagination.next-page')"/>
							</a>
						</li>
					</xsl:if>
					<!-- Last page -->
					<xsl:if test="$index + $contents-per-page lt $total-count">
						<li class="last">
							<a href="{stk:pagination.create-url(xs:integer(ceiling(($total-count div $contents-per-page) - 1) * $contents-per-page), $parameters, $index-parameter-name)}" title="{portal:localize('stk.pagination.last-page')}">
								<xsl:value-of select="portal:localize('stk.pagination.last-page')"/>
							</a>
						</li>
					</xsl:if>
				</ul>
			</nav>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="stk:pagination.create-menu-middle">
		<xsl:param name="parameters" tunnel="yes" as="element()*"/>
		<xsl:param name="index" tunnel="yes" as="xs:integer"/>
		<xsl:param name="total-count" tunnel="yes" as="xs:integer"/>
		<xsl:param name="contents-per-page" tunnel="yes" as="xs:integer"/>
		<xsl:param name="index-parameter-name" tunnel="yes" select="'index'" as="xs:string"/>
		<xsl:param name="start" tunnel="yes"/>
		<xsl:param name="max-count" tunnel="yes"/>
		<xsl:param name="counter" select="1"/>
		<xsl:if test="$counter le $max-count and (($start + (($counter - 1) * $contents-per-page)) lt $total-count)">
			<li>
				<xsl:attribute name="class">
					<xsl:text>number</xsl:text>
					<xsl:if test="$counter = 1">
						<xsl:text> first-page</xsl:text>
					</xsl:if>
					<xsl:if test="$start + (($counter - 1) * $contents-per-page) = $index">
						<xsl:text> active</xsl:text>
					</xsl:if>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="$start + (($counter - 1) * $contents-per-page) = $index">
						<span>
							<span class="audible">
								<xsl:value-of select="portal:localize('stk.pagination.page')"/>
							</span>
							<xsl:value-of select="($start div $contents-per-page) + $counter"/>
						</span>
					</xsl:when>
					<xsl:otherwise>
						<a href="{stk:pagination.create-url(xs:integer($start + (($counter - 1) * $contents-per-page)), $parameters, $index-parameter-name)}">
							<span class="audible">
								<xsl:value-of select="portal:localize('stk.pagination.page')"/>
							</span>
							<xsl:value-of select="($start div $contents-per-page) + $counter"/>
						</a>
					</xsl:otherwise>
				</xsl:choose>
			</li>
			<xsl:call-template name="stk:pagination.create-menu-middle">
				<xsl:with-param name="counter" select="$counter + 1"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:function name="stk:pagination.create-url" as="xs:string">
		<xsl:param name="index" as="xs:integer"/>
		<xsl:param name="parameters" as="element()*"/>
		<xsl:param name="index-parameter-name" as="xs:string"/>
		<xsl:variable name="final-parameters" as="xs:anyAtomicType+">
			<xsl:for-each select="$parameters[not(@name = $index-parameter-name)]">
				<xsl:sequence select="@name, ."/>
			</xsl:for-each>
			<xsl:sequence select="$index-parameter-name, $index"/>
		</xsl:variable>
		<xsl:value-of select="portal:createPageUrl($final-parameters)"/>
	</xsl:function>
	
</xsl:stylesheet>
