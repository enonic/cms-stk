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
	
	<xsl:import href="stk-variables.xsl"/>
	
	<xsl:template name="stk:pagination.create-header" as="element()?">
		<xsl:param name="contents" as="element()"/>
		<xsl:param name="index" as="xs:integer" select="xs:integer($contents/@index)"/>
		<xsl:param name="content-count" as="xs:integer" select="xs:integer($contents/@resultcount)"/>
		<xsl:param name="total-count" as="xs:integer" select="xs:integer($contents/@totalcount)"/>
		<xsl:param name="contents-per-page" as="xs:integer" select="xs:integer($contents/@count)"/>
		<xsl:param name="always-show" as="xs:boolean" select="false()"/>
		<xsl:if test="$always-show or ($total-count gt $contents-per-page)">
			<xsl:variable name="range" as="xs:string" select="concat($index + 1, if ($content-count gt 1) then concat(' - ', $index + $content-count) else null)"/>
			<div class="pagination header">
				<xsl:value-of select="portal:localize('stk.pagination.header-text', ($range, $total-count))"/>
			</div>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="stk:pagination.create-menu" as="element()?">
		<xsl:param name="contents" as="element()"/>
		<xsl:param name="index" as="xs:integer" select="xs:integer($contents/@index)"/>
		<xsl:param name="content-count" as="xs:integer" select="xs:integer($contents/@resultcount)"/>
		<xsl:param name="total-count" as="xs:integer" select="xs:integer($contents/@totalcount)"/>
		<xsl:param name="contents-per-page" as="xs:integer" select="xs:integer($contents/@count)"/>
		<xsl:param name="parameters" as="element()*" select="$stk:querystring-parameter[not(@name = 'index' or @name = 'id' or starts-with(@name, '_config-'))]"/>
		<xsl:param name="pages-in-pagination" as="xs:integer" select="10"/>
		<xsl:param name="index-parameter-name" as="xs:string" select="'index'"/>
		<xsl:param name="show-more-text" as="xs:string" select="portal:localize('stk.pagination.show-more-text')"/>
		<xsl:param name="showing-text" as="xs:string" select="portal:localize('stk.pagination.showing-text')"/>
		<xsl:variable name="current-page" as="xs:integer" select="($contents-per-page + $index) div $contents-per-page"/>
		<xsl:if test="$total-count gt $contents-per-page">
			<nav class="pagination" aria-labelledby="{generate-id($contents)}" data-count="{$contents-per-page}" data-totalcount="{$total-count}" data-windowurl="{portal:createWindowUrl(('index', 'REPLACEWITHINDEX'))}" data-show-more-text="{$show-more-text}" data-showing-text="{$showing-text}">				
				<h4 id="{generate-id($contents)}" class="audible">Pagination</h4>
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
							<a href="{stk:pagination.create-url($index - $contents-per-page, $parameters, $index-parameter-name)}" title="{portal:localize('stk.pagination.previous-page')}" rel="prev">
								<xsl:value-of select="portal:localize('stk.pagination.previous-page')"/>
							</a>
						</li>
					</xsl:if>
					
					<!-- Middle pagination part -->
					<xsl:variable name="tmp" select="floor(($total-count - ($index + 1)) div $contents-per-page) - floor(($pages-in-pagination - 1) div 2)"/>
					<xsl:variable name="tmp2" select="if ($tmp gt 0) then 0 else $tmp"/>
					<xsl:variable name="tmp3" as="xs:integer" select="xs:integer($index - (floor($pages-in-pagination div 2) * $contents-per-page) + ($tmp2 * $contents-per-page))"/>
										
					<xsl:variable name="max-page" as="xs:integer" select="xs:integer(ceiling($total-count div $contents-per-page))"/>
					<xsl:variable name="start-page" as="xs:integer" select="if ($tmp3 lt 1) then 1 else $tmp3"/>
					<xsl:variable name="stop-page" as="xs:integer" select="if ($max-page lt ($start-page + $pages-in-pagination - 1)) then $max-page else $start-page + $pages-in-pagination - 1"/>

					<xsl:for-each select="$start-page to $stop-page">
						<li>
							<xsl:attribute name="class">
								<xsl:text>number</xsl:text>
								<xsl:if test=". = 1">
									<xsl:text> first-page</xsl:text>
								</xsl:if>
								<xsl:if test=". = $current-page">
									<xsl:text> active</xsl:text>
								</xsl:if>
							</xsl:attribute>
							<xsl:choose>
								<xsl:when test=". = $current-page">
									<span>
										<span class="audible">
											<xsl:value-of select="portal:localize('stk.pagination.page')"/>
										</span>
										<xsl:value-of select="."/>
									</span>
								</xsl:when>
								<xsl:otherwise>
									<a href="{stk:pagination.create-url((. * $contents-per-page) - $contents-per-page, $parameters, $index-parameter-name)}">			
										<xsl:if test=". = $current-page - 1">
											<xsl:attribute name="rel" select="'prev'"/>
										</xsl:if>
										<xsl:if test=". = $current-page + 1">
											<xsl:attribute name="rel" select="'next'"/>
										</xsl:if>
										<span class="audible">
											<xsl:value-of select="portal:localize('stk.pagination.page')"/>
										</span>
										<xsl:value-of select="."/>
									</a>
								</xsl:otherwise>
							</xsl:choose>							
						</li>
					</xsl:for-each>
					
					<!-- Next page -->
					<xsl:if test="$index + $contents-per-page lt $total-count">
						<li class="next">
							<a href="{stk:pagination.create-url($index + $contents-per-page, $parameters, $index-parameter-name)}" title="{portal:localize('stk.pagination.next-page')}" rel="next">
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
