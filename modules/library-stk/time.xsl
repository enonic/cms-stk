<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    time.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">    
    
    <xsl:import href="stk-variables.xsl"/>    
    <xsl:import href="stk-general.xsl" />
    
    <!-- Returns timezone as xs:string -->
    <xsl:function name="stk:time.get-timezone" as="xs:string">
        <xsl:variable name="timezone">
            <xsl:choose>
                <xsl:when test="timezone-from-date(current-date()) lt xs:dayTimeDuration('PT0S')">-</xsl:when>
                <xsl:otherwise>+</xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="concat(format-number(xs:integer(tokenize(xs:string(timezone-from-date(current-date())), 'T|S|H')[2]), '00'), ':00')"/>
        </xsl:variable>
        <xsl:value-of select="$timezone"/>
    </xsl:function>

    <!-- Formats date (and time) -->
    <!-- Valid input formats: ISO 8601 -->
    <xsl:template name="stk:time.format-date" as="element()?">
        <xsl:param name="date" as="xs:string"/>
        <xsl:param name="language" as="xs:string" select="$stk:language"/>
        <xsl:param name="picture" as="xs:string?"/>
        <xsl:param name="include-time" as="xs:boolean" select="false()"/>
        <xsl:param name="attr" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="not($date castable as xs:string)">                
                <!-- Erroneous date format -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="date-parts" select="tokenize(xs:string($date), ' |T')"/>
                <xsl:choose>
                    <xsl:when test="not($date-parts[1] castable as xs:date)">                        
                        <!-- Erroneous date format -->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="final-picture">
                            <xsl:choose>
                                <xsl:when test="empty($picture)">
                                    <xsl:choose>
                                        <xsl:when test="$language = 'no'">
                                            <xsl:text>[D01].[M01].[Y0001]</xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>[D01]/[M01]/[Y0001]</xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose> 
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$picture"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable><!--
                        <span class="date">  -->                   
                        <time>
                            <xsl:attribute name="datetime">
                                <xsl:value-of select="$date-parts[1]"/>
                                <xsl:if test="$include-time and normalize-space($date-parts[2])">
                                    <xsl:text>T</xsl:text>
                                    <xsl:value-of select="$date-parts[2]"/>
                                </xsl:if>
                            </xsl:attribute>
                            <xsl:call-template name="stk:general.add-attributes">
                                <xsl:with-param name="attr" select="$attr"/>
                            </xsl:call-template>
                            <span class="date">                                
                                <xsl:value-of select="format-date(xs:date($date-parts[1]), $final-picture, $language, (), ())" disable-output-escaping="yes"/>
                            </span>
                            <xsl:if test="$include-time and normalize-space($date-parts[2])">
                                <xsl:text> </xsl:text>
                                <xsl:call-template name="stk:time.format-time">
                                    <xsl:with-param name="time" select="$date-parts[2]"/>
                                    <xsl:with-param name="language" select="$language"/>
                                    <xsl:with-param name="wrap-in-time" select="false()"/>
                                </xsl:call-template>
                            </xsl:if>
                        </time>
                            <!--
                        </span>-->
                        
                    </xsl:otherwise>
                </xsl:choose>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Formats time -->
    <!-- Valid input formats: ISO 8601 and hh:mm -->
    <xsl:template name="stk:time.format-time" as="element()?">
        <xsl:param name="time" as="xs:string"/>
        <xsl:param name="language" as="xs:string" select="$stk:language"/>
        <xsl:param name="picture" as="xs:string?"/>
        <xsl:param name="wrap-in-time" as="xs:boolean" select="true()"/>        
        <xsl:param name="attr" as="xs:string*"/>
        
        <xsl:variable name="final-time">
            <xsl:value-of select="$time"/>
            <xsl:if test="count(tokenize(xs:string($time), ':')) lt 3">:00</xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not($final-time castable as xs:time)">
                <!-- Erroneous date format -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="final-picture">
                    <xsl:choose>
                        <xsl:when test="empty($picture)">
                            <xsl:choose>
                                <xsl:when test="$language = 'no'">
                                    <xsl:text>[H01].[m01]</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>[H01]:[m01]</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose> 
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$picture"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$wrap-in-time">
                        <time datetime="{$final-time}">
                            <xsl:call-template name="stk:general.add-attributes">
                                <xsl:with-param name="attr" select="$attr"/>
                            </xsl:call-template>
                            <xsl:value-of select="format-time($final-time, $final-picture, $language,(), ())"/>
                        </time>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="time">                    
                            <xsl:value-of select="format-time($final-time, $final-picture, $language,(), ())"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>           
    </xsl:template>

</xsl:stylesheet>
