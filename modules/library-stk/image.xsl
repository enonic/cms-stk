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
    
    <xsl:import href="stk-variables.xsl"/>
    
    <!-- Generates image element -->
    <xsl:template name="stk:image.create">
        <xsl:param name="image" as="element()"/><!-- Image content node -->
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="filter" as="xs:string?" select="$stk:config-filter"/>                
        <xsl:param name="format" as="xs:string?" select="$stk:default-image-format"/>
        <xsl:param name="quality" as="xs:integer?" select="$stk:default-image-quality"/>        
        <xsl:param name="background" as="xs:string?"/>
        <xsl:param name="title" as="xs:string?" select="$image/title"/>
        <xsl:param name="alt" as="xs:string?" select="if (normalize-space($image/contentdata/description)) then $image/contentdata/description else $image/title"/>
        <xsl:param name="class" as="xs:string?"/>
        <xsl:param name="style" as="xs:string?"/>
        <xsl:param name="id" as="xs:string?"/>
        
       
        <figure>
            <xsl:attribute name="class">                
                <xsl:value-of select="$size"/>
                <xsl:if test="normalize-space($scaling)">
                    <xsl:text> scaled</xsl:text>
                </xsl:if>
                <xsl:if test="$class">
                    <xsl:value-of select="concat(' ', $class)"/>
                </xsl:if>
            </xsl:attribute>
            
            <noscript>
                <img alt="{$alt}">
                    <xsl:attribute name="src">
                        <xsl:call-template name="stk:image.create-url">
                            <xsl:with-param name="image" select="$image"/>
                            <xsl:with-param name="scaling" select="$scaling"/>
                            <xsl:with-param name="size" select="$size"/>                            
                            <xsl:with-param name="filter" select="$filter"/>
                            <xsl:with-param name="format" select="$format"/>
                            <xsl:with-param name="quality" select="$quality"/>
                            <xsl:with-param name="scale-width" select="300"/>                            
                            <xsl:with-param name="background" select="$background"/>
                        </xsl:call-template>
                    </xsl:attribute>
                </img>
            </noscript>
                        
            <xsl:variable name="data-srcset">
                <xsl:text>{</xsl:text>
                <xsl:for-each select="$stk:theme-prescaled-image-sizes">
                    <xsl:variable name="src-width" select="."/>
                    <xsl:text>"</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>":"</xsl:text>
                    <xsl:call-template name="stk:image.create-url">
                        <xsl:with-param name="image" select="$image"/>
                        <xsl:with-param name="scaling" select="$scaling"/>
                        <xsl:with-param name="size" select="$size"/>                        
                        <xsl:with-param name="filter" select="$filter"/>
                        <xsl:with-param name="format" select="$format"/>
                        <xsl:with-param name="quality" select="$quality"/>
                        <xsl:with-param name="scale-width" select="$src-width"/>
                        <xsl:with-param name="background" select="$background"/>
                    </xsl:call-template>
                    <xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()">
                        <xsl:text>,</xsl:text>
                    </xsl:if>                    
                </xsl:for-each>
                <xsl:text>}</xsl:text>
            </xsl:variable>
            
            
            <!-- ensure that we have a trailing semicolon -->
            <xsl:variable name="final-scaling" as="xs:string?" select="if (normalize-space($scaling) and not(ends-with($scaling, ';'))) then concat($scaling, ';') else $scaling"/>
            
            <xsl:variable name="image-ar" as="xs:double*" select="stk:image.calculate-ratio($image, stk:image.create-filter($scaling, $stk:img-max-width, $size, $final-scaling, $image))"/>
            
            <img>
                <xsl:attribute name="alt" select="$alt"/>
                <xsl:attribute name="data-srcset" select="$data-srcset"/>
                <xsl:attribute name="data-ar" select="$image-ar[1] div $image-ar[2]"/>
                <xsl:attribute name="class">
                    <xsl:text>js-img </xsl:text>
                    <xsl:value-of select="$size"/>
                    <xsl:if test="normalize-space($scaling)">
                        <xsl:text> scaled</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                <xsl:attribute name="src" select="stk:image.create-placeholder($image-ar)"/>                
            </img>            
        </figure>
    </xsl:template>
    
    <!-- Generates image url -->
    <xsl:template name="stk:image.create-url">
        <xsl:param name="image" as="element()"/><!-- Image content node -->
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="size" as="xs:string?"/>        
        <xsl:param name="filter" as="xs:string?" select="$stk:config-filter"/><!-- Custom image filters -->
        <xsl:param name="format" as="xs:string?" select="$stk:default-image-format"/>
        <xsl:param name="quality" as="xs:integer?" select="$stk:default-image-quality"/>
        <xsl:param name="scale-width" as="xs:integer" select="$stk:img-max-width"/>        
        <xsl:param name="background" as="xs:string?"/>
        <!-- ensure that we have a trailing semicolon -->
        <xsl:variable name="final-scaling" as="xs:string?" select="if (normalize-space($scaling) and not(ends-with($scaling, ';'))) then concat($scaling, ';') else $scaling"/>
        <xsl:value-of select="portal:createImageUrl(
            stk:image.get-attachment-key($image, $scale-width), 
            stk:image.create-filter($scaling, $scale-width, $size, concat($final-scaling, $filter), $image), 
            $background,
            $format,
            $quality
            )"/>
    </xsl:template>

    <!-- Returns final image filter as xs:string? -->
    <xsl:function name="stk:image.create-filter" as="xs:string?">        
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="scale-width" as="xs:integer"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="filter" as="xs:string?"/>
        <xsl:param name="image" as="element()"/>
        <xsl:variable name="selected-imagesize" select="$stk:config-imagesize[@name = $size]"/>
        <xsl:variable name="source-image-size" as="xs:integer*" select="$image/contentdata/sourceimage/@width, $image/contentdata/sourceimage/@height"/>
        
        <xsl:variable name="size-scaled" as="xs:string*">
            <xsl:choose>
                <!-- If custom image size definitions exists -->
                <xsl:when test="$selected-imagesize">
                    <!-- Supports all scale filters -->
                    <xsl:variable name="first-filter-parameter">
                        <xsl:choose>
                            <xsl:when test="$selected-imagesize/filter = 'scalemax' or $selected-imagesize/filter = 'scalesquare'">
                                <xsl:value-of select="$selected-imagesize/size"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$selected-imagesize/width"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:value-of select="concat($selected-imagesize/filter, '(', floor($scale-width))"/>
                    <xsl:if test="$selected-imagesize/filter = 'scalewide' and $selected-imagesize/height != ''">
                        <xsl:value-of select="concat(',', floor($scale-width * $selected-imagesize/height))"/>
                        <xsl:if test="$selected-imagesize/offset != ''">
                            <xsl:value-of select="concat(',', $selected-imagesize/offset)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:text>);</xsl:text>
                </xsl:when>
                <!-- If no custom image size definitions exists default sizes are used -->
                <xsl:when test="$size = 'full' or $size = 'regular' or $size = 'list'">
                    <xsl:value-of select="concat('scalewidth(', $scale-width, ');')"/>
                </xsl:when>
                <xsl:when test="$size = 'wide'">
                    <xsl:value-of select="concat('scalewide(', $scale-width, ',', $scale-width * 0.4, ');')"/>
                </xsl:when>
                <xsl:when test="$size = 'square' or $size = 'thumbnail'">
                    <xsl:value-of select="concat('scalesquare(', $scale-width, ');')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="custom-scaled" as="xs:string*">
            <xsl:variable name="last-scale-filter" select="tokenize($filter, ';')[starts-with(., 'scale')][position() = last()]"/>            
            <xsl:choose>
                <xsl:when test="$last-scale-filter">
                    <xsl:variable name="scale-type" select="tokenize($last-scale-filter, '\(')[1]"/>
                    <xsl:variable name="scale-params" as="xs:double*">
                        <xsl:for-each select="tokenize(tokenize($last-scale-filter, '\(|\)')[2], ',')">
                            <xsl:sequence select="number(.)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="concat($scale-type, '(')"/>
                    <xsl:if test="$scale-type = 'scalewide' or $scale-type = 'scalewidth' or $scale-type = 'scalemax' or $scale-type = 'scalesquare' or $scale-type = 'scaleblock'">
                        <!--<xsl:value-of select="if ($scale-params[1] gt $scale-width) then $scale-width else $scale-params[1]"/>-->
                        <xsl:value-of select="$scale-width"/>
                    </xsl:if>
                    <xsl:if test="$scale-type = 'scaleheight'">
                        <xsl:value-of select="if (stk:image.calculate-size($source-image-size, (), $scale-params[1]) gt $scale-width) then stk:image.calculate-size($source-image-size, $scale-width, ()) else $scale-params[1]"/>    
                    </xsl:if>
                    <xsl:if test="$scale-type = 'scalewide' or $scale-type = 'scaleblock'">
                        <xsl:text>,</xsl:text>
                        <xsl:variable name="scale-ratio" select="$scale-params[1] div $scale-params[2]"/>
                        <xsl:value-of select="round($scale-width div $scale-ratio)"/>
                        <!--
                        <xsl:value-of select="if ($scale-params[1] gt $scale-width) then $scale-width * ($scale-params[2] div $scale-params[1]) else $scale-params[2]"/>-->
                        <xsl:if test="$scale-params[3]">
                            <xsl:value-of select="concat(',', $scale-params[3])"/>
                        </xsl:if>
                        <xsl:if test="$scale-params[4]">
                            <xsl:value-of select="concat(',', $scale-params[4])"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:value-of select="');'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('scalewidth(', $scale-width, ');')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="final-filter">
                <xsl:choose>
                    <xsl:when test="$size-scaled != ''">
                        <xsl:value-of select="$size-scaled"/>
                    </xsl:when>
                    <xsl:when test="$custom-scaled != ''">
                        <xsl:value-of select="$custom-scaled"/>
                    </xsl:when>
                </xsl:choose>
                                
                <xsl:for-each select="tokenize($filter, ';')[not(starts-with(., 'scale'))][normalize-space(.)]">
                    <xsl:value-of select="concat(., ';')"/>
                </xsl:for-each> 
            
        </xsl:variable>
        <xsl:value-of select="translate($final-filter, ' ', '')"/>
    </xsl:function>
    
    <!-- Returns final image width or height as xs:integer? -->
    <!--<xsl:function name="stk:image.get-size" as="xs:integer?">
        <xsl:param name="region-width" as="xs:integer"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="source-image" as="element()?"/>
        <xsl:param name="dimension" as="xs:string?"/>
        <xsl:variable name="selected-imagesize" select="$stk:config-imagesize[@name = $size]"/>
        <xsl:variable name="source-image-size" as="xs:integer*" select="$source-image/contentdata/sourceimage/@width, $source-image/contentdata/sourceimage/@height"/> 
        <xsl:variable name="final-image-size" as="xs:double*">
            <xsl:choose>
                <!-\- If custom scale filter applied. Possible weakness here; only the last scalefilter is taken into consideration -\->
                <xsl:when test="normalize-space($scaling) and count(tokenize($scaling, ';')[starts-with(., 'scale')]) gt 0">
                    <xsl:variable name="last-scale-filter" select="tokenize($scaling, ';')[starts-with(., 'scale')][position() = last()]"/>
                    <xsl:variable name="scale-type" select="tokenize($last-scale-filter, '\(')[1]"/>                    
                    <xsl:variable name="scale-params" as="xs:double*">
                        <xsl:for-each select="tokenize(tokenize($last-scale-filter, '\(|\)')[2], ',')">
                            <xsl:sequence select="number(.)"/>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <!-\- make sure that the image fits within the current region width -\->
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
                <!-\- If custom image size definitions exists -\->
                <xsl:when test="$selected-imagesize">
                    <!-\- Supports all scale filters -\->
                    <xsl:choose>
                        <!-\- Scaleheight -\->
                        <xsl:when test="$selected-imagesize/filter = 'scaleheight'">
                            <xsl:sequence select="stk:image.calculate-size($source-image-size, (), floor($region-width * $selected-imagesize/height)), floor($region-width * $selected-imagesize/height)"/>
                        </xsl:when>
                        <!-\- Scalemax -\->
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
                        <!-\- Scalesquare -\->
                        <xsl:when test="$selected-imagesize/filter = 'scalesquare'">
                            <xsl:sequence select="floor($region-width * $selected-imagesize/size), floor($region-width * $selected-imagesize/size)"/>
                        </xsl:when>
                        <!-\- Scalewide -\->
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
                        <!-\- Scaleblock -\->
                        <xsl:when test="$selected-imagesize/filter = 'scaleblock'">
                            <xsl:sequence select="floor($region-width * $selected-imagesize/width), floor($region-width * $selected-imagesize/height)"/>
                        </xsl:when>
                        <!-\- Scalewidth -\->
                        <xsl:when test="$selected-imagesize/filter = 'scalewidth'">
                            <xsl:sequence select="floor($region-width * $selected-imagesize/width), stk:image.calculate-size($source-image-size, floor($region-width * $selected-imagesize/width), ())"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <!-\- If no custom image size definitions exists default sizes are used -\->
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
                <!-\- Original image size -\->
                <!-\-<xsl:otherwise>
                    <xsl:sequence select="$source-image-size[1], $source-image-size[2]"/>
                </xsl:otherwise>-\->
                <xsl:otherwise>
                    <xsl:value-of select="$region-width"/>
                    <xsl:value-of select="stk:image.calculate-size($source-image-size, $region-width, ())"/>  
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
    </xsl:function>-->
    
    <!-- Returns final image attachment key as xs:string -->
    <xsl:function name="stk:image.get-attachment-key" as="xs:string">
        <xsl:param name="source-image" as="element()"/>
        <xsl:param name="scale-width" as="xs:integer"/><!--
        <xsl:param name="size" as="xs:string?"/>--><!--
        <xsl:param name="scaling" as="xs:string?"/>--><!--
        <xsl:variable name="image-width" select="stk:image.get-size($region-width, $size, $scaling, $source-image, 'width')"/>-->
        <xsl:variable name="attachment-key">
            <xsl:value-of select="$source-image/@key"/>
            <xsl:choose>
                <xsl:when test="$scale-width le 256 and $source-image/binaries/binary/@label = 'small'">/label/small</xsl:when>
                <xsl:when test="$scale-width le 512 and $source-image/binaries/binary/@label = 'medium'">/label/medium</xsl:when>
                <xsl:when test="$scale-width le 1024 and $source-image/binaries/binary/@label = 'large'">/label/large</xsl:when>
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
    
    <!--<xsl:function name="stk:image.calculate-ratio" as="xs:double?">
        <xsl:param name="image" as="element()"/><!-\- Image content node -\->
        <xsl:param name="scaling" as="xs:string?"/>        
        <xsl:variable name="scaling-parts" select="tokenize($scaling, '\(|\)|,')"/>
        <xsl:choose>
            <xsl:when test="$scaling-parts[1] = 'scaleblock' and $scaling-parts[2] castable as xs:integer and $scaling-parts[3] castable as xs:integer">
                <xsl:value-of select="round(number($scaling-parts[2]) div number($scaling-parts[3]) * 100) div 100"/>    
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="round($image/contentdata/sourceimage/@width div $image/contentdata/sourceimage/@height * 100) div 100"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>-->
    
    <xsl:function name="stk:image.calculate-ratio" as="xs:double*">
        <xsl:param name="image" as="element()"/><!-- Image content node -->
        <xsl:param name="filter" as="xs:string?"/>   
        <xsl:variable name="last-scale-filter" select="tokenize($filter, ';')[starts-with(., 'scale')][position() = last()]"/>
        <xsl:variable name="scaling-parts" select="tokenize($last-scale-filter, '\(|\)|,')"/>
        <xsl:variable name="width" as="xs:integer">
            <xsl:choose>
                <xsl:when test="($scaling-parts[1] = 'scalewide' or $scaling-parts[1] = 'scalesquare' or $scaling-parts[1] = 'scaleblock') and $scaling-parts[2] castable as xs:integer">
                    <xsl:value-of select="$scaling-parts[2]"/>    
                </xsl:when>
                <xsl:otherwise>                    
                    <xsl:value-of select="$image/contentdata/sourceimage/@width"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="height" as="xs:integer">
            <xsl:choose>
                <xsl:when test="($scaling-parts[1] = 'scalewide' or $scaling-parts[1] = 'scaleblock') and $scaling-parts[3] castable as xs:integer">
                    <xsl:value-of select="$scaling-parts[3]"/>    
                </xsl:when>
                <xsl:when test="$scaling-parts[1] = 'scalesquare' and $scaling-parts[2] castable as xs:integer">
                    <xsl:value-of select="$scaling-parts[2]"/>    
                </xsl:when>
                <xsl:otherwise>                    
                    <xsl:value-of select="$image/contentdata/sourceimage/@height"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
       <!-- <xsl:choose>
            <xsl:when test="$scaling-parts[1] = 'scaleblock' and $scaling-parts[2] castable as xs:integer and $scaling-parts[3] castable as xs:integer">
                <xsl:value-of select="round(number($scaling-parts[2]) div number($scaling-parts[3]) * 100) div 100"/>    
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="round($image/contentdata/sourceimage/@width div $image/contentdata/sourceimage/@height * 100) div 100"/>
            </xsl:otherwise>
        </xsl:choose>-->
        
        <xsl:sequence select="$width, $height"/>
        
        
        
        
    </xsl:function>
    
    <xsl:function name="stk:image.create-placeholder" as="xs:string">
        <xsl:param name="aspect-ratio" as="xs:double*"/>
        <xsl:variable name="width" select="$aspect-ratio[1]"/>
        <xsl:variable name="height" select="$aspect-ratio[2]"/>
        
        <xsl:variable name="gcd" select="stk:image.calculate-gcd($width, $height, $width)"/>
        <xsl:variable name="min-ar" as="xs:double*" select="$width div $gcd, $height div $gcd"/>
    
        <xsl:value-of select="portal:createImagePlaceholder($min-ar[1], $min-ar[2])" use-when="function-available('portal:createImagePlaceholder')"/> 
        <xsl:value-of select="'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAJCAYAAAA7KqwyAAAAD0lEQVR42mNgGAWjgAoAAAJJAAFgJMPaAAAAAElFTkSuQmCC'" use-when="not(function-available('portal:createImagePlaceholder'))"/>        
    </xsl:function>
    
   <!-- <xsl:template name="stk:image.create-placeholder" as="xs:string*">
        <xsl:param name="image" as="element()"/><!-\- Image content node -\->
        <xsl:param name="filter" as="xs:string?"/>           
        <xsl:variable name="last-scale-filter" select="tokenize($filter, ';')[starts-with(., 'scale')][position() = last()]"/>  
        <xsl:variable name="scaling-parts" select="tokenize($last-scale-filter, '\(|\)|,')"/>
        <xsl:variable name="width" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$scaling-parts[1] = 'scaleblock' and $scaling-parts[2] castable as xs:integer and $scaling-parts[3] castable as xs:integer">
                    <xsl:value-of select="number($scaling-parts[2])"/>    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$image/contentdata/sourceimage/@width"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="height" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$scaling-parts[1] = 'scaleblock' and $scaling-parts[2] castable as xs:integer and $scaling-parts[3] castable as xs:integer">
                    <xsl:value-of select="number($scaling-parts[3])"/>    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$image/contentdata/sourceimage/@height"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="gcd" select="stk:image.calculate-gcd($width, $height, $width)"/>
        <xsl:variable name="min-ar" as="xs:double*" select="$width div $gcd, $height div $gcd"/>
        
        
        ORIGINAL:
        
        <xsl:value-of select="$width, $height"/>
        
        OPTIMISED:
        
        <xsl:value-of select="$min-ar"/>
        
    </xsl:template>-->
    
    <!-- calculates the greatest common divisor of two integers -->
    <xsl:function name="stk:image.calculate-gcd">
        <!-- Recursive template. Call until $num = 0. -->
        <xsl:param name="gcd" as="xs:double"/>
        <xsl:param name="num" as="xs:double"/>
        <xsl:param name="dom" as="xs:double"/>
        <xsl:choose>
            <xsl:when test="$num gt 0">
                <!-- Recursive call -->
                <xsl:value-of select="stk:image.calculate-gcd($num, $dom mod $num, $num)"/>
                <!--<xsl:call-template name="stk:image.calculate-gcd">
                    <xsl:with-param name="gcd" select="$num"/>
                    <xsl:with-param name="num" select="$dom mod $num"/>
                    <xsl:with-param name="dom" select="$num"/>
                </xsl:call-template>-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$gcd"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>


</xsl:stylesheet>
