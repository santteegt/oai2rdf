<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:url="http://whatever/java/java.net.URLEncoder"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:xoai="http://www.lyncode.com/xoai"
  xmlns:bibo="http://purl.org/ontology/bibo/"
  xmlns:foaf="http://xmlns.com/foaf/0.1/"
  exclude-result-prefixes="xsl xsi url oai xoai"
>

  <xsl:output method="xml" />
  
  <xsl:template match="/">
   <rdf:RDF>
    <!-- <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record"/> -->
    <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record/oai:metadata/xoai:metadata/xoai:element[contains(@name,'bundles')]/xoai:element[contains(@name,'bundle')]"/>
   </rdf:RDF>
  </xsl:template>  
  <!--  /xoai:field[contains(.,'ORIGINAL')]/xoai:element[contains(@name, 'bitstreams')]-->
  
  <xsl:template match="xoai:element[contains(@name,'bundle')]"  priority="1">
    <xsl:variable name="bundleType" select="xoai:field[contains(@name,'name')]" />
    <xsl:if test="$bundleType = 'ORIGINAL'">
      <xsl:apply-templates select="xoai:element[contains(@name, 'bitstreams')]/xoai:element[contains(@name, 'bitstream')]"/>
    </xsl:if>
  </xsl:template>  

  <xsl:template match="xoai:element[contains(@name, 'bitstream')]" priority="1">
    <xsl:variable name="url" select="url:encode(translate(xoai:field[contains(@name,'format')]/.,'/','-'))" />
    <dcterms:FileFormat rdf:about="http://dspace.ucuenca.edu.ec/resource/fileformat/{$url}"/>
  </xsl:template>
<!--
  <xsl:template match="xoai:element[contains(@name,'bitstream')]" priority="1">
    AAABBB111
    <dcterms:FileFormat rdf:about="http://dspace.ucuenca.edu.ec/resource/fileformat/{xoai:field[contains(@name,'format')]/.}"/>
    
  </xsl:template>
  -->

</xsl:stylesheet>
