<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
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
     <xsl:apply-templates select="oai:metadata"/>
    </ow:Publication>
  </xsl:template>
  
  <xsl:template match="oai:metadata" priority="1">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="dcterms:dateAccepted">
    <dc:date><xsl:value-of select="."/></dc:date>
  </xsl:template>
  <xsl:template match="dcterms:dateAccepted">
    <dcterms:dateAccepted><xsl:value-of select="."/></dcterms:dateAccepted>
  </xsl:template>
  <xsl:template match="dcterms:available">
    <dcterms:available><xsl:value-of select="."/></dcterms:available>
  </xsl:template>
  <xsl:template match="dcterms:created">
    <dcterms:created><xsl:value-of select="."/></dcterms:created>
  </xsl:template>
  <xsl:template match="dcterms:issued">
    <dcterms:issued><xsl:value-of select="."/></dcterms:issued>
  </xsl:template>

  <xsl:template match="dcterms:abstract">
    <dcterms:abstract><xsl:value-of select="."/></dcterms:abstract>
  </xsl:template>
  

  <xsl:template match="dc:contributor">
  </xsl:template>
  
  <xsl:template match="dc:coverage">
  </xsl:template>
  
  <xsl:template match="dc:creator">
  </xsl:template>
  
  <xsl:template match="dc:date">
  </xsl:template>
  
  <xsl:template match="dc:description">
  </xsl:template>
  
  <xsl:template match="dc:format">
  </xsl:template>
  
  <xsl:template match="dc:identifier">
   <!-- ignore -->
  </xsl:template>
  
  
  <xsl:template match="dc:language">
  </xsl:template>
  
  <xsl:template match="dc:publisher">
  </xsl:template>
  
  <xsl:template match="dc:relation">
  </xsl:template>
  
  <xsl:template match="dc:rights">
  </xsl:template>

  <xsl:template match="dc:source">
  </xsl:template>
  
  <xsl:template match="dc:subject">
  </xsl:template>
  
  <xsl:template match="dc:title">
  </xsl:template>

  <xsl:template match="dc:type">
  </xsl:template>
  
</xsl:stylesheet>
