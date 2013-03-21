<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    image.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all"
    xmlns="http://www.w3.org/1999/xhtml" version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:portal="http://www.enonic.com/cms/xslt/portal"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">
    
    <xsl:import href="/modules/library-stk/stk-variables.xsl"/>

    <!-- Generates image element -->
    <xsl:template name="stk:image.create">
        <xsl:param name="image" as="element()"/><!-- Image content node -->
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="background" as="xs:string?"/>
        <xsl:param name="title" as="xs:string?" select="$image/title"/>
        <xsl:param name="alt" as="xs:string?" select="if (normalize-space($image/contentdata/description)) then $image/contentdata/description else $image/title"/>
        <xsl:param name="class" as="xs:string?"/>
        <xsl:param name="style" as="xs:string?"/>
        <xsl:param name="id" as="xs:string?"/>
        <xsl:param name="format" as="xs:string?" select="$stk:default-image-format"/>
        <xsl:param name="quality" as="xs:integer?" select="$stk:default-image-quality"/>
        <xsl:param name="region-width" as="xs:integer" select="$stk:region-width"/>
        <xsl:param name="filter" as="xs:string?" select="$stk:config-filter"/>
        <!-- ensure that we have a trailing semicolon -->
        <xsl:variable name="final-scaling" as="xs:string?" select="if (normalize-space($scaling) and not(ends-with($scaling, ';'))) then concat($scaling, ';') else $scaling"/>
        <xsl:variable name="width" select="stk:image.get-size($region-width, $size, concat($final-scaling, $filter), $image, 'width')"/>
        <xsl:variable name="height" select="stk:image.get-size($region-width, $size, concat($final-scaling, $filter), $image, 'height')"/>
       
        <img alt="{$alt}">
            <xsl:attribute name="src">
                <xsl:call-template name="stk:image.create-url">
                    <xsl:with-param name="image" select="$image"/>
                    <xsl:with-param name="scaling" select="$final-scaling"/>
                    <xsl:with-param name="size" select="$size"/>
                    <xsl:with-param name="background" select="$background"/>
                    <xsl:with-param name="format" select="$format"/>
                    <xsl:with-param name="quality" select="$quality"/>
                    <xsl:with-param name="region-width" select="$region-width"/>
                    <xsl:with-param name="filter" select="$filter"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:if test="$title">
                <xsl:attribute name="title">
                    <xsl:value-of select="$title"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$width">
                <xsl:attribute name="width">
                    <xsl:value-of select="$width"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$height">
                <xsl:attribute name="height">
                    <xsl:value-of select="$height"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$class != ''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$class"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$style != ''">
                <xsl:attribute name="style">
                    <xsl:value-of select="$style"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$id != ''">
                <xsl:attribute name="id">
                    <xsl:value-of select="$id"/>
                </xsl:attribute>
            </xsl:if>
        </img>
    </xsl:template>
    
    <!-- Generates image url -->
    <xsl:template name="stk:image.create-url">
        <xsl:param name="image" as="element()"/><!-- Image content node -->
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="background" as="xs:string?"/>
        <xsl:param name="format" as="xs:string?" select="$stk:default-image-format"/>
        <xsl:param name="quality" as="xs:integer?" select="$stk:default-image-quality"/>
        <xsl:param name="region-width" as="xs:integer" select="$stk:region-width"/>
        <xsl:param name="filter" as="xs:string?" select="$stk:config-filter"/><!-- Custom image filters -->
        <!-- ensure that we have a trailing semicolon -->
        <xsl:variable name="final-scaling" as="xs:string?" select="if (normalize-space($scaling) and not(ends-with($scaling, ';'))) then concat($scaling, ';') else $scaling"/>
        <xsl:value-of select="portal:createImageUrl(stk:image.get-attachment-key($image/@key, $region-width, $size, concat($final-scaling, $filter), $image), stk:image.create-filter($region-width, $size, concat($final-scaling, $filter), $image), $background, $format, $quality)"/>
    </xsl:template>

    <!-- Returns final image filter as xs:string? -->
    <xsl:function name="stk:image.create-filter" as="xs:string?">
        <xsl:param name="region-width" as="xs:integer"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="filter" as="xs:string?"/>
        <xsl:param name="image" as="element()"/>
        <xsl:variable name="selected-imagesize" select="$stk:config-imagesize[@name = $size]"/>
        <xsl:variable name="source-image-size" as="xs:integer*" select="$image/contentdata/sourceimage/@width, $image/contentdata/sourceimage/@height"/>
        <xsl:variable name="final-filter">
            <xsl:choose>
                <!-- If custom image size definitions exists -->
                <xsl:when test="$selected-imagesize">
                    <!-- Supports all scale filters -->
                    <xsl:variable name="first-filter-parameter">
                        <xsl:choose>
                            <xsl:when test="$selected-imagesize/filter = 'scaleheight'">
                                <xsl:value-of select="$selected-imagesize/height"/>
                            </xsl:when>
                            <xsl:when test="$selected-imagesize/filter = 'scalemax' or $selected-imagesize/filter = 'scalesquare'">
                                <xsl:value-of select="$selected-imagesize/size"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$selected-imagesize/width"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="concat($selected-imagesize/filter, '(', floor($region-width * $first-filter-parameter))"/>
                    <xsl:if test="$selected-imagesize/filter = 'scalewide' and $selected-imagesize/height != ''">
                        <xsl:value-of select="concat(',', floor($region-width * $selected-imagesize/height))"/>
                        <xsl:if test="$selected-imagesize/offset != ''">
                            <xsl:value-of select="concat(',', $selected-imagesize/offset)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:text>);</xsl:text>
                </xsl:when>
                <!-- If no custom image size definitions exists default sizes are used -->
                <xsl:when test="$size = 'full' or $size = 'regular' or $size = 'list'">
                    <xsl:value-of select="concat('scalewidth(', stk:image.calculate-size-by-default-ratio($region-width, $size), ');')"/>
                </xsl:when>
                <xsl:when test="$size = 'wide'">
                    <xsl:value-of select="concat('scalewide(', stk:image.calculate-size-by-default-ratio($region-width, 'wide-width'), ',', stk:image.calculate-size-by-default-ratio($region-width, 'wide-height'), ');')"/>
                </xsl:when>
                <xsl:when test="$size = 'square' or $size = 'thumbnail'">
                    <xsl:value-of select="concat('scalesquare(', stk:image.calculate-size-by-default-ratio($region-width, $size), ');')"/>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="normalize-space($filter)">
                <xsl:variable name="last-scale-filter" select="tokenize($filter, ';')[starts-with(., 'scale')][position() = last()]"/>
                <xsl:if test="$last-scale-filter">
                    <xsl:variable name="scale-type" select="tokenize($last-scale-filter, '\(')[1]"/>
                    <xsl:variable name="scale-params" as="xs:double*">
                        <xsl:for-each select="tokenize(tokenize($last-scale-filter, '\(|\)')[2], ',')">
                            <xsl:sequence select="number(.)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="concat($scale-type, '(')"/>
                    <xsl:if test="$scale-type = 'scalewide' or $scale-type = 'scalewidth' or $scale-type = 'scalemax' or $scale-type = 'scalesquare' or $scale-type = 'scaleblock'">
                        <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1]"/>
                    </xsl:if>
                    <xsl:if test="$scale-type = 'scaleheight'">
                        <xsl:value-of select="if (stk:image.calculate-size($source-image-size, (), $scale-params[1]) gt $region-width) then stk:image.calculate-size($source-image-size, $region-width, ()) else $scale-params[1]"/>    
                    </xsl:if>
                    <xsl:if test="$scale-type = 'scalewide' or $scale-type = 'scaleblock'">
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width * ($scale-params[2] div $scale-params[1]) else $scale-params[2]"/>
                        <xsl:if test="$scale-params[3]">
                            <xsl:value-of select="concat(',', $scale-params[3])"/>
                        </xsl:if>
                        <xsl:if test="$scale-params[4]">
                            <xsl:value-of select="concat(',', $scale-params[4])"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:value-of select="');'"/>
                </xsl:if>
                <xsl:for-each select="tokenize($filter, ';')[not(starts-with(., 'scale'))][normalize-space(.)]">
                    <xsl:value-of select="concat(., ';')"/>
                </xsl:for-each>      
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="translate($final-filter, ' ', '')"/>
    </xsl:function>
    
    <!-- Returns final image width or height as xs:integer? -->
    <xsl:function name="stk:image.get-size" as="xs:integer?">
        <xsl:param name="region-width" as="xs:integer"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="source-image" as="element()?"/>
        <xsl:param name="dimension" as="xs:string?"/>
        <xsl:variable name="selected-imagesize" select="$stk:config-imagesize[@name = $size]"/>
        <xsl:variable name="source-image-size" as="xs:integer*" select="$source-image/contentdata/sourceimage/@width, $source-image/contentdata/sourceimage/@height"/> 
        <xsl:variable name="final-image-size" as="xs:double*">
            <xsl:choose>
                <!-- If custom scale filter applied. Possible weakness here; only the last scalefilter is taken into consideration -->
                <xsl:when test="normalize-space($scaling) and count(tokenize($scaling, ';')[starts-with(., 'scale')]) gt 0">
                    <xsl:variable name="last-scale-filter" select="tokenize($scaling, ';')[starts-with(., 'scale')][position() = last()]"/>
                    <xsl:variable name="scale-type" select="tokenize($last-scale-filter, '\(')[1]"/>                    
                    <xsl:variable name="scale-params" as="xs:double*">
                        <xsl:for-each select="tokenize(tokenize($last-scale-filter, '\(|\)')[2], ',')">
                            <xsl:sequence select="number(.)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <!-- make sure that the image fits within the current region width -->
                    <xsl:choose>
                        <xsl:when test="$scale-type = 'scalewidth'">
                            <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1]"/>                            
                            <xsl:value-of select="stk:image.calculate-size($source-image-size, if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1], ())"/>   
                         </xsl:when>
                         <xsl:when test="$scale-type = 'scaleheight'">
                            <xsl:value-of select="if (stk:image.calculate-size($source-image-size, (), $scale-params[1]) gt $region-width) then $region-width else stk:image.calculate-size($source-image-size, (), $scale-params[1])"/> 
                            <xsl:value-of select="if (stk:image.calculate-size($source-image-size, (), $scale-params[1]) gt $region-width) then stk:image.calculate-size($source-image-size, $region-width, ()) else $scale-params[1]"/>    
                        </xsl:when>                        
                        <xsl:when test="$scale-type = 'scalesquare'">
                            <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1]"/>
                            <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1]"/>
                        </xsl:when>
                        <xsl:when test="$scale-type = 'scalemax'">
                            <xsl:choose>
                                <xsl:when test="$source-image-size[1] ge $source-image-size[2]">
                                    <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1]"/>
                                    <xsl:value-of select="stk:image.calculate-size($source-image-size, if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1], ())"/> 
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="if (stk:image.calculate-size($source-image-size, (), $scale-params[1]) gt $region-width) then $region-width else stk:image.calculate-size($source-image-size, (), $scale-params[1])"/>    
                                    <xsl:value-of select="if (stk:image.calculate-size($source-image-size, (), $scale-params[1]) gt $region-width) then stk:image.calculate-size($source-image-size, $region-width, ()) else $scale-params[1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:when test="$scale-type = 'scaleblock'">
                            <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1]"/>
                            <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width * ($scale-params[2] div $scale-params[1]) else $scale-params[2]"/>
                        </xsl:when>
                        <xsl:when test="$scale-type = 'scalewide'">
                            <xsl:value-of select="if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1]"/>
                            <xsl:value-of select="min((stk:image.calculate-size($source-image-size, if ($scale-params[1] gt $region-width) then $region-width else $scale-params[1], ()), if ($scale-params[1] gt $region-width) then $scale-params[2] * ($region-width div $scale-params[1]) else $scale-params[2]))"/>
                        </xsl:when>   
                    </xsl:choose>
                </xsl:when>
                <!-- If custom image size definitions exists -->
                <xsl:when test="$selected-imagesize">
                    <!-- Supports all scale filters -->
                    <xsl:choose>
                        <!-- Scaleheight -->
                        <xsl:when test="$selected-imagesize/filter = 'scaleheight'">
                            <xsl:sequence select="stk:image.calculate-size($source-image-size, (), floor($region-width * $selected-imagesize/height)), floor($region-width * $selected-imagesize/height)"/>
                        </xsl:when>
                        <!-- Scalemax -->
                        <xsl:when test="$selected-imagesize/filter = 'scalemax'">
                            <xsl:choose>
                                <xsl:when test="$source-image-size[1] ge $source-image-size[2]">
                                    <xsl:sequence select="floor($region-width * $selected-imagesize/size), stk:image.calculate-size($source-image-size, floor($region-width * $selected-imagesize/size), ())"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="stk:image.calculate-size($source-image-size, (), floor($region-width * $selected-imagesize/size)), floor($region-width * $selected-imagesize/size)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <!-- Scalesquare -->
                        <xsl:when test="$selected-imagesize/filter = 'scalesquare'">
                            <xsl:sequence select="floor($region-width * $selected-imagesize/size), floor($region-width * $selected-imagesize/size)"/>
                        </xsl:when>
                        <!-- Scalewide -->
                        <xsl:when test="$selected-imagesize/filter = 'scalewide'">
                            <xsl:sequence select="floor($region-width * $selected-imagesize/width)"/>
                            <xsl:choose>
                                <xsl:when test="stk:image.calculate-size($source-image-size, floor($region-width * $selected-imagesize/width), ()) le floor($region-width * $selected-imagesize/height)">
                                    <xsl:sequence select="stk:image.calculate-size($source-image-size, floor($region-width * $selected-imagesize/width), ())"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="floor($region-width * $selected-imagesize/height)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <!-- Scaleblock -->
                        <xsl:when test="$selected-imagesize/filter = 'scaleblock'">
                            <xsl:sequence select="floor($region-width * $selected-imagesize/width), floor($region-width * $selected-imagesize/height)"/>
                        </xsl:when>
                        <!-- Scalewidth -->
                        <xsl:when test="$selected-imagesize/filter = 'scalewidth'">
                            <xsl:sequence select="floor($region-width * $selected-imagesize/width), stk:image.calculate-size($source-image-size, floor($region-width * $selected-imagesize/width), ())"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <!-- If no custom image size definitions exists default sizes are used -->
                <xsl:when test="$size = 'full' or $size = 'regular' or $size = 'list'">
                    <xsl:sequence select="stk:image.calculate-size-by-default-ratio($region-width, $size), stk:image.calculate-size($source-image-size, stk:image.calculate-size-by-default-ratio($region-width, $size), ())"/>
                </xsl:when>
                <xsl:when test="$size = 'wide'">
                    <xsl:sequence select="stk:image.calculate-size-by-default-ratio($region-width, 'wide-width')"/>
                    <xsl:choose>
                        <xsl:when test="stk:image.calculate-size($source-image-size, stk:image.calculate-size-by-default-ratio($region-width, 'wide-width'), ()) le stk:image.calculate-size-by-default-ratio($region-width, 'wide-height')">
                            <xsl:sequence select="stk:image.calculate-size($source-image-size, stk:image.calculate-size-by-default-ratio($region-width, 'wide-width'), ())"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="stk:image.calculate-size-by-default-ratio($region-width, 'wide-height')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$size = 'square' or $size = 'thumbnail'">
                    <xsl:sequence select="stk:image.calculate-size-by-default-ratio($region-width, $size), stk:image.calculate-size-by-default-ratio($region-width, $size)"/>
                </xsl:when>
                <!-- Original image size -->
                <xsl:otherwise>
                    <xsl:sequence select="$source-image-size[1], $source-image-size[2]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>        
        <xsl:choose>
            <xsl:when test="$dimension = 'height' and $final-image-size[2]">
                <xsl:value-of select="$final-image-size[2]"/>
            </xsl:when>
            <xsl:when test="$final-image-size[1]">
                <xsl:value-of select="$final-image-size[1]"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- Returns final image attachment key as xs:string -->
    <xsl:function name="stk:image.get-attachment-key" as="xs:string">
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="region-width" as="xs:integer"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="source-image" as="element()?"/>
        <xsl:variable name="image-width" select="stk:image.get-size($region-width, $size, $scaling, $source-image, 'width')"/>
        <xsl:variable name="attachment-key">
            <xsl:value-of select="$key"/>
            <xsl:choose>
                <xsl:when test="$image-width le 256 and $source-image/binaries/binary/@label = 'small'">/label/small</xsl:when>
                <xsl:when test="$image-width le 512 and $source-image/binaries/binary/@label = 'medium'">/label/medium</xsl:when>
                <xsl:when test="$image-width le 1024 and $source-image/binaries/binary/@label = 'large'">/label/large</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$attachment-key"/>
    </xsl:function>
    
    <!-- Returns size based on default ratio as xs:integer -->
    <xsl:function name="stk:image.calculate-size-by-default-ratio" as="xs:integer">
        <xsl:param name="region-width" as="xs:integer"/>
        <xsl:param name="size" as="xs:string"/>
        <xsl:variable name="ratio">
            <xsl:choose>
                <xsl:when test="$size = 'full'">1</xsl:when>
                <xsl:when test="$size = 'wide-width'">1</xsl:when>
                <xsl:when test="$size = 'wide-height'">0.4</xsl:when>
                <xsl:when test="$size = 'regular'">0.4</xsl:when>
                <xsl:when test="$size = 'list'">0.3</xsl:when>
                <xsl:when test="$size = 'square'">0.4</xsl:when>
                <xsl:when test="$size = 'thumbnail'">0.1</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="floor($region-width * $ratio)"/>
    </xsl:function>
    
    <!-- Returns width calculated from new-height, old-width and old-height, or height calculated from new-width, old-width and old-height as xs:double? -->
    <xsl:function name="stk:image.calculate-size" as="xs:double?">
        <xsl:param name="source-image-size" as="xs:integer*"/>
        <xsl:param name="new-width" as="xs:double?"/>
        <xsl:param name="new-height" as="xs:double?"/>
        <!-- $source-image-size[1] is old width -->
        <!-- $source-image-size[2] is old height -->
        <xsl:if test="$source-image-size[1] and $source-image-size[2]">
            <xsl:choose>
                <xsl:when test="$new-width">
                    <xsl:value-of select="floor($new-width div ($source-image-size[1] div $source-image-size[2]))"/>
                </xsl:when>
                <xsl:when test="$new-height">
                    <xsl:value-of select="floor($new-height * ($source-image-size[1] div $source-image-size[2]))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
    
    
    


</xsl:stylesheet>
