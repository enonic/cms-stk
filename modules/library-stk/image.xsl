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
    <xsl:import href="stk-general.xsl" />
    
    <!-- Generates image element -->
    <xsl:template name="stk:image.create" as="element()?">
        <xsl:param name="image" as="element()"/>
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="scale-up" as="xs:boolean" select="true()"/>
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
        <xsl:param name="attr" as="xs:string*"/>
        
        <xsl:variable name="original-image-size" as="xs:integer*" select="stk:image.get-original-size($image)"/>
        
        <xsl:variable name="prescaled-image-sizes" as="xs:double*">
            <xsl:choose>
                <xsl:when test="normalize-space($scaling) and not($scale-up)">                    
                    <xsl:variable name="requested-scaled-width" as="xs:double" select="stk:image.get-final-size($image, $scaling, (), ())[1]"/>                    
                    <xsl:sequence select="$stk:theme-prescaled-image-sizes[. le $requested-scaled-width], $requested-scaled-width[. le $original-image-size[1]]"/>
                </xsl:when>
                <xsl:when test="not($scale-up)">
                    <xsl:sequence select="$stk:theme-prescaled-image-sizes[. le $original-image-size[1]]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$stk:theme-prescaled-image-sizes"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
       
           <xsl:if test="$scale-up or (not($scale-up) and $original-image-size[1] ge min($prescaled-image-sizes))">
               <figure>
                   <xsl:if test="normalize-space($size) or normalize-space($scaling) or normalize-space($class) or not($scale-up)">
                       <xsl:attribute name="class">                
                           <xsl:value-of select="$size"/>
                           <xsl:if test="normalize-space($scaling)">
                               <xsl:text> scaled</xsl:text>
                           </xsl:if>
                           <xsl:if test="not($scale-up)">
                               <xsl:text> no-scale-up</xsl:text>
                           </xsl:if>
                           <xsl:if test="$class">
                               <xsl:value-of select="concat(' ', $class)"/>
                           </xsl:if>
                       </xsl:attribute>
                   </xsl:if>
                   <xsl:if test="normalize-space($style)">
                       <xsl:attribute name="style" select="$style"/>
                   </xsl:if>
                   <xsl:if test="normalize-space($id)">
                       <xsl:attribute name="style" select="$id"/>
                   </xsl:if>
                   
                   <xsl:call-template name="stk:general.add-attributes">
                       <xsl:with-param name="attr" select="$attr"/>
                   </xsl:call-template>
                   
                   
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
                                   <xsl:with-param name="available-width" select="300"/>                            
                                   <xsl:with-param name="background" select="$background"/>
                               </xsl:call-template>
                           </xsl:attribute>
                       </img>
                   </noscript>
                   
                   <xsl:variable name="data-srcset">
                       <xsl:text>{</xsl:text>
                       <xsl:for-each select="distinct-values($prescaled-image-sizes)">
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
                               <xsl:with-param name="available-width" select="$src-width"/>
                               <xsl:with-param name="background" select="$background"/>
                           </xsl:call-template>
                           <xsl:text>"</xsl:text>
                           <xsl:if test="position() != last()">
                               <xsl:text>,</xsl:text>
                           </xsl:if>                    
                       </xsl:for-each>
                       <xsl:text>}</xsl:text>
                   </xsl:variable>
                   
                   <!--
                   <!-\- ensure that we have a trailing semicolon -\->
                   <xsl:variable name="final-scaling" as="xs:string?" select="if (normalize-space($scaling) and not(ends-with($scaling, ';'))) then concat($scaling, ';') else $scaling"/>-->
                   
                   <!--<xsl:variable name="image-ar" as="xs:double*" select="stk:image.calculate-ratio($image, stk:image.create-filter($scaling, $stk:img-max-width, $size, $final-scaling, $image))"/>
                   
                   -->
                   
                   <xsl:variable name="image-ar" as="xs:double*" select="stk:image.get-final-size($image, $scaling, $size, ())"/>
                   
                   
                   <img>
                       <xsl:attribute name="alt" select="$alt"/>
                       <xsl:if test="normalize-space($title)">
                           <xsl:attribute name="title" select="$title"/>
                       </xsl:if>
                       <xsl:attribute name="data-srcset" select="$data-srcset"/>
                       <xsl:attribute name="data-ar" select="$image-ar[1] div $image-ar[2]"/>
                       <xsl:attribute name="class">
                           <xsl:text>js-img </xsl:text>
                           <xsl:value-of select="$size"/>
                           <xsl:if test="normalize-space($scaling)">
                               <xsl:text> scaled</xsl:text>
                           </xsl:if>
                       </xsl:attribute>
                       <xsl:attribute name="src" select="stk:image.create-placeholder($image-ar, $scale-up)"/>                
                   </img>            
               </figure>
           </xsl:if>
       
       
        
    </xsl:template>
    
    <!-- Generates image url -->
    <xsl:template name="stk:image.create-url" as="xs:string">
        <xsl:param name="image" as="element()"/><!-- Image content node -->
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="size" as="xs:string?"/>        
        <xsl:param name="filter" as="xs:string?" select="$stk:config-filter"/><!-- Custom image filters -->
        <xsl:param name="format" as="xs:string?" select="$stk:default-image-format"/>
        <xsl:param name="quality" as="xs:integer?" select="$stk:default-image-quality"/>
        <xsl:param name="available-width" as="xs:double" select="$stk:img-max-width"/>        
        <xsl:param name="background" as="xs:string?"/>
        <!-- ensure that we have a trailing semicolon -->
        <xsl:variable name="final-scaling" as="xs:string?" select="if (normalize-space($scaling) and not(ends-with($scaling, ';'))) then concat($scaling, ';') else $scaling"/>
        <xsl:value-of select="portal:createImageUrl(
            stk:image.get-attachment-key($image, $available-width), 
            stk:image.create-filter($image, $available-width, $scaling, $size, concat($final-scaling, $filter)), 
            $background,
            $format,
            $quality
            )"/>
    </xsl:template>
    
    <xsl:function name="stk:image.get-original-size" as="xs:integer*">
        <xsl:param name="image" as="element()"/>
        <xsl:sequence select="$image/contentdata/sourceimage/@width, $image/contentdata/sourceimage/@height"/>
    </xsl:function>
    
    <xsl:function name="stk:image.create-placeholder" as="xs:string">
        <xsl:param name="aspect-ratio" as="xs:double*"/>
        <xsl:param name="calculate-gcd" as="xs:boolean"/>
        <xsl:variable name="width" select="$aspect-ratio[1]"/>
        <xsl:variable name="height" select="$aspect-ratio[2]"/>
        
        <xsl:variable name="gcd" as="xs:integer" select="stk:image.calculate-gcd($width, $height)"/>
        <xsl:variable name="min-ar" as="xs:double*" select="$width div $gcd, $height div $gcd"/>
        
        <xsl:value-of select="portal:createImagePlaceholder(if ($calculate-gcd) then $min-ar[1] else $aspect-ratio[1], if ($calculate-gcd) then $min-ar[2] else $aspect-ratio[2])" use-when="function-available('portal:createImagePlaceholder')"/> 
        <xsl:value-of select="'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAJCAYAAAA7KqwyAAAAD0lEQVR42mNgGAWjgAoAAAJJAAFgJMPaAAAAAElFTkSuQmCC'" use-when="not(function-available('portal:createImagePlaceholder'))"/>        
    </xsl:function>

   
    
    
    <!-- Returns final image filter as xs:string? -->
    <xsl:function name="stk:image.create-filter" as="xs:string?"> 
        <xsl:param name="image" as="element()"/>
        <xsl:param name="available-width" as="xs:double"/>
        <xsl:param name="scaling" as="xs:string?"/>
        <xsl:param name="size" as="xs:string?"/>
        <xsl:param name="filter" as="xs:string?"/>
        <xsl:variable name="selected-imagesize" select="$stk:config-imagesize[@name = $size]"/>
        <xsl:variable name="original-image-size" as="xs:integer*" select="stk:image.get-original-size($image)"/>
        
        <xsl:variable name="requested-image-size" as="xs:integer*" select="stk:image.get-final-size($image, $scaling, $size, $available-width)"/>  
        
        <xsl:variable name="size-scaled" as="xs:string*">
            <xsl:choose>
                <!-- If custom image size definitions exists -->
                <xsl:when test="$selected-imagesize">
                    <!-- Supports all scale filters -->
                    <xsl:value-of select="concat($selected-imagesize/filter, '(', floor($available-width))"/>
                    <xsl:if test="$selected-imagesize/filter = 'scalewide' and $selected-imagesize/height != ''">
                        <xsl:value-of select="concat(',', floor($available-width * $selected-imagesize/height))"/>
                        <xsl:if test="$selected-imagesize/offset != ''">
                            <xsl:value-of select="concat(',', $selected-imagesize/offset)"/>
                        </xsl:if>
                    </xsl:if>
                    <xsl:text>);</xsl:text>
                </xsl:when>
                <!-- If no custom image size definitions exists default sizes are used -->
                <xsl:when test="$size = 'full' or $size = 'regular' or $size = 'list'">
                    <xsl:value-of select="concat('scalewidth(', $available-width, ');')"/>
                </xsl:when>
                <xsl:when test="$size = 'wide'">
                    <xsl:value-of select="concat('scalewide(', $available-width, ',', $available-width * 0.4, ');')"/>
                </xsl:when>
                <xsl:when test="$size = 'square' or $size = 'thumbnail'">
                    <xsl:value-of select="concat('scalesquare(', $available-width, ');')"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="custom-scaled" as="xs:string*">
            <xsl:variable name="last-scale-filter" as="xs:string?" select="tokenize($filter, ';')[starts-with(., 'scale')][position() = last()]"/>    
            <xsl:variable name="scale-type" as="xs:string?" select="tokenize($last-scale-filter, '\(')[1]"/>
            <xsl:variable name="scale-params" as="xs:double*">
                <xsl:for-each select="tokenize(tokenize($last-scale-filter, '\(|\)')[2], ',')">
                    <xsl:sequence select="number(.)"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="$last-scale-filter">                    
                    <xsl:value-of select="concat($scale-type, '(')"/>
                    <xsl:if test="$scale-type = 'scalewide' or $scale-type = 'scalewidth' or $scale-type = 'scalemax' or $scale-type = 'scalesquare' or $scale-type = 'scaleblock'">
                        <xsl:value-of select="$available-width"/>
                    </xsl:if>
                    <xsl:if test="$scale-type = 'scaleheight'">
                        <xsl:value-of select="stk:image.calculate-dimension($original-image-size, $available-width, ())"/>
                    </xsl:if>
                    <xsl:if test="$scale-type = 'scalewide' or $scale-type = 'scaleblock'">
                        <xsl:text>,</xsl:text>
                        <xsl:variable name="scale-ratio" select="$scale-params[1] div $scale-params[2]"/>
                        <xsl:value-of select="round($available-width div $scale-ratio)"/>
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
                    <xsl:value-of select="concat('scalewidth(', $available-width, ');')"/>
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
    
    <!-- Returns final image attachment key as xs:string -->
    <xsl:function name="stk:image.get-attachment-key" as="xs:string">
        <xsl:param name="source-image" as="element()"/>
        <xsl:param name="available-width" as="xs:double"/>
        <xsl:variable name="attachment-key">
            <xsl:value-of select="$source-image/@key"/>
            <xsl:choose>
                <xsl:when test="$available-width le 256 and $source-image/binaries/binary/@label = 'small'">/label/small</xsl:when>
                <xsl:when test="$available-width le 512 and $source-image/binaries/binary/@label = 'medium'">/label/medium</xsl:when>
                <xsl:when test="$available-width le 1024 and $source-image/binaries/binary/@label = 'large'">/label/large</xsl:when>                
                <xsl:when test="$available-width le 2048 and $source-image/binaries/binary/@label = 'extra-large'">/label/extra-large</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$attachment-key"/>
    </xsl:function>
    
    
    
    <!-- Returns width calculated from new-height, old-width and old-height, or height calculated from new-width, old-width and old-height as xs:double? -->
    <xsl:function name="stk:image.calculate-dimension" as="xs:double?">
        <xsl:param name="original-image-size" as="xs:integer*"/>
        <xsl:param name="new-width" as="xs:double?"/>
        <xsl:param name="new-height" as="xs:double?"/>
        <xsl:if test="$original-image-size[1] and $original-image-size[2]">
            <xsl:choose>
                <xsl:when test="$new-width">
                    <xsl:value-of select="floor($new-width div ($original-image-size[1] div $original-image-size[2]))"/>
                </xsl:when>
                <xsl:when test="$new-height">
                    <xsl:value-of select="floor($new-height * ($original-image-size[1] div $original-image-size[2]))"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    </xsl:function>
        
    
    
    
    
        
    <!--<!-\- calculates the greatest common divisor of two integers -\->
    <xsl:function name="stk:image.calculate-gcd" as="xs:integer">
        <!-\- Recursive template. Call until $num = 0. -\->
        <xsl:param name="gcd" as="xs:double"/>
        <xsl:param name="num" as="xs:double"/>
        <xsl:param name="dom" as="xs:double"/>
        <xsl:choose>
            <xsl:when test="$num gt 0">
                <!-\- Recursive call -\->
                <xsl:value-of select="stk:image.calculate-gcd($num, $dom mod $num, $num)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$gcd"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>-->
    
    
    <!-- calculates the greatest common divisor of two integers -->
    <xsl:function name="stk:image.calculate-gcd" as="xs:integer">
        <xsl:param name="x" as="xs:double"/>
        <xsl:param name="y" as="xs:double"/>
        <xsl:variable name="x-mod-y" as="xs:double" select="$x mod $y"/>
        <xsl:choose>
            <xsl:when test="$x-mod-y gt 0">
                <xsl:value-of select="stk:image.calculate-gcd($y, $x-mod-y)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$y"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    
    <!-- get the size of an image after scaling/sizing has been applied -->
    <xsl:function name="stk:image.get-final-size" as="xs:double*">
        <xsl:param name="image" as="element()"/>
        <xsl:param name="scaling" as="xs:string?"/>        
        <xsl:param name="size" as="xs:string?"/> 
        <xsl:param name="available-width" as="xs:double?"/>
        
        <xsl:variable name="original-image-size" as="xs:integer*" select="stk:image.get-original-size($image)"/>        
        <xsl:variable name="selected-imagesize" as="element()?" select="$stk:config-imagesize[@name = $size]"/>        
        <xsl:variable name="last-scale-filter" as="xs:string?" select="tokenize($scaling, ';')[starts-with(., 'scale')][position() = last()]"/>         
        <xsl:variable name="scale-type" as="xs:string?">
            <xsl:choose>
                <xsl:when test="normalize-space($scaling)">
                    <xsl:value-of select="tokenize($last-scale-filter, '\(')[1]"/>
                </xsl:when>
                <xsl:when test="$selected-imagesize">
                    <xsl:value-of select="$selected-imagesize/filter"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="scale-params" as="xs:double*">
            <xsl:choose>
                <xsl:when test="normalize-space($scaling)">
                    <xsl:for-each select="tokenize(tokenize($last-scale-filter, '\(|\)')[2], ',')">
                        <xsl:sequence select="number(.)"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="$selected-imagesize">
                    <xsl:for-each select="$selected-imagesize/width, $selected-imagesize/height, $selected-imagesize/size">
                        <!-- since size scaling is based on relative sizes, a "default" width of 1000 is set in order to do the calculation -->
                        <xsl:value-of select=". * (if ($available-width castable as xs:integer) then $available-width else 1000)"/>                        
                    </xsl:for-each>
                </xsl:when>
            </xsl:choose>            
        </xsl:variable>        
        
        <xsl:variable name="width" as="xs:double">    
            <xsl:choose>
                <xsl:when test="$scale-type = 'scalewidth' or $scale-type = 'scalewide' or $scale-type = 'scaleblock' or $scale-type = 'scalesquare'">
                    <xsl:value-of select="$scale-params[1]"/>
                </xsl:when>
                <xsl:when test="$scale-type = 'scaleheight'">
                    <xsl:value-of select="stk:image.calculate-dimension($original-image-size, (), $scale-params[1])"/>
                </xsl:when>                
                <xsl:otherwise>
                    <xsl:value-of select="$original-image-size[1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="height" as="xs:double">            
            <xsl:choose>
                <xsl:when test="$scale-type = 'scalewide' or $scale-type = 'scaleblock'">
                    <xsl:value-of select="$scale-params[2]"/>
                </xsl:when>
                <xsl:when test="$scale-type = 'scalesquare' or $scale-type = 'scaleheight'">
                    <xsl:value-of select="$scale-params[1]"/>
                </xsl:when>
                <xsl:when test="$scale-type = 'scalewidth'">
                    <xsl:value-of select="stk:image.calculate-dimension($original-image-size, $scale-params[1], ())"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$original-image-size[2]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="$width, $height"/>        
    </xsl:function>
    
    
    
    
    
    <!-- Returns size based on default ratio as xs:integer -->
    <!--<xsl:function name="stk:image.calculate-size-by-default-ratio" as="xs:integer">
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
    </xsl:function>-->


    <!--<xsl:function name="stk:image.calculate-ratio" as="xs:double*">
        <xsl:param name="image" as="element()"/>
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
        
        <xsl:sequence select="$width, $height"/>
    </xsl:function>-->

</xsl:stylesheet>
