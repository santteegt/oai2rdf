<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:ow="http://www.ontoweb.org/ontology/1#"
  exclude-result-prefixes="xsl xsi oai oai_dc"
>

  <xsl:output method="xml"/>
  
  <xsl:template match="/">
   <rdf:RDF>
    <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record"/>
   </rdf:RDF>
  </xsl:template>
    
  <xsl:template match="oai:record" priority="1">
    <ow:Publication rdf:about="{oai:header/oai:identifier}">
     <xsl:apply-templates select="oai:metadata/oai_dc:dc"/>
    </ow:Publication>
  </xsl:template>
  
  <xsl:template match="oai_dc:dc" priority="1">
      <xsl:apply-templates/>
  </xsl:template>

  
  <xsl:template match="dc:contributor">
    <dc:contributor><xsl:value-of select="."/></dc:contributor>
  </xsl:template>
  
  <xsl:template match="dc:coverage">
    <dc:coverage><xsl:value-of select="."/></dc:coverage>
  </xsl:template>
  
  <xsl:template match="dc:creator">
    <dc:creator><xsl:value-of select="."/></dc:creator>
  </xsl:template>
  
  <xsl:template match="dc:date">
    <dc:date><xsl:value-of select="."/></dc:date>
  </xsl:template>
  
  <xsl:template match="dc:description">
    <dc:description><xsl:value-of select="."/></dc:description>
  </xsl:template>
  
  <xsl:template match="dc:format">
    <dc:format><xsl:value-of select="."/></dc:format>
  </xsl:template>
  
  <!-- NOTE(SM): we remove all the identifiers that are not HTTP URIs. -->
  
  <xsl:template match="dc:identifier">
   <!-- ignore -->
  </xsl:template>
  
  <xsl:template match="dc:identifier[contains(.,'http://')]">
    <dc:identifier><xsl:value-of select="."/></dc:identifier>
  </xsl:template>
  
  <xsl:template match="dc:language">
    <dc:language><xsl:value-of select="."/></dc:language>
  </xsl:template>
  
  <xsl:template match="dc:publisher">
    <dc:publisher><xsl:value-of select="."/></dc:publisher>
  </xsl:template>
  
  <xsl:template match="dc:relation">
    <dc:relation><xsl:value-of select="."/></dc:relation>
  </xsl:template>
  
  <xsl:template match="dc:rights">
    <dc:rights><xsl:value-of select="."/></dc:rights>
  </xsl:template>

  <xsl:template match="dc:source">
    <dc:source><xsl:value-of select="."/></dc:source>
  </xsl:template>
  
  <xsl:template match="dc:subject">
    <dc:subject><xsl:value-of select="."/></dc:subject>
  </xsl:template>
  
  <xsl:template match="dc:title">
    <dc:title><xsl:value-of select="."/></dc:title>
  </xsl:template>

  <xsl:template match="dc:type">
    <dc:type><xsl:value-of select="."/></dc:type>
  </xsl:template>
  
</xsl:stylesheet>
