<?xml version="1.0" encoding="UTF-8"?>

<!--
    **************************************************
    
    analytics.xsl
    version: ###VERSION-NUMBER-IS-INSERTED-HERE###
    
    **************************************************
-->

<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:stk="http://www.enonic.com/cms/xslt/stk">
    
    <xsl:import href="stk-variables.xsl"/>
    <xsl:import href="system.xsl"/>
    
    <xsl:template name="stk:analytics.google" as="element()?">
        <xsl:variable name="google-analytics-web-property-id" select="stk:system.get-config-param('google-analytics-web-property-id', $stk:path)" as="xs:string?"/>
        <xsl:variable name="google-analytics-type" select="if (normalize-space(stk:system.get-config-param('google-analytics-type', $stk:path))) then stk:system.get-config-param('google-analytics-type', $stk:path) else 'classic'" as="xs:string"/>
        <xsl:if test="normalize-space($google-analytics-web-property-id)">
            <script>
                <xsl:choose>
                    <xsl:when test="$google-analytics-type = 'classic'">
                        var _gaq = _gaq || [];
                        _gaq.push(['_setAccount', '<xsl:value-of select="$google-analytics-web-property-id"/>']);
                        _gaq.push(['_gat._anonymizeIp']);
                        _gaq.push(['_trackPageview']);                        
                        
                        (function() {
                        var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                        ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                        var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                        })();
                    </xsl:when>
                    <xsl:otherwise>
                        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                        (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                        m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                        })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
                        
                        ga('create', '<xsl:value-of select="$google-analytics-web-property-id"/>');
                        ga('set', 'anonymizeIp', true);
                        ga('send', 'pageview');
                    </xsl:otherwise>
                </xsl:choose>                
            </script>
        </xsl:if>
    </xsl:template>
    
</xsl:stylesheet>