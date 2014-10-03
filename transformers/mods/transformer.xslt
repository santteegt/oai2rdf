<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:ow="http://www.ontoweb.org/ontology/1#"
  xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xsl xsi oai mods"
>

  <xsl:output method="xml"/>
  
  <xsl:template match="/">
   <rdf:RDF>
    <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record"/>
   </rdf:RDF>
  </xsl:template>
    
  <xsl:template match="oai:record" priority="1">
    <ow:Publication rdf:about="{oai:header/oai:identifier}">
     <xsl:apply-templates select="oai:metadata/mods:mods"/>
    </ow:Publication>
  </xsl:template>
  
  <xsl:template match="mods:mods" priority="1">
      <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="mods:subject/mods:geographic">
    <dc:coverage><xsl:value-of select="."/></dc:coverage>
  </xsl:template>
  
  <xsl:template match="mods:subject/mods:temporal">
    <dc:coverage><xsl:value-of select="."/></dc:coverage>
  </xsl:template>
  
  <xsl:template match="mods:name/mods:role">
    <!-- ignore -->
  </xsl:template>
  
  <xsl:template match="mods:name/mods:namePart">
    <dc:creator><xsl:value-of select="."/></dc:creator>
  </xsl:template>
  
  <xsl:template match="mods:extension/mods:dateAccessioned">
    <dc:date><xsl:value-of select="."/></dc:date>
  </xsl:template>
  
  <xsl:template match="mods:extension/mods:dateAvailable">
    <!-- dspace assigns this and accessioned date together - one is redundant -->
  </xsl:template>
  
  <xsl:template match="mods:originInfo/mods:dateIssued">
    <dc:date><xsl:value-of select="."/></dc:date>
  </xsl:template>
  
  <xsl:template match="mods:abstract">
    <dc:description><xsl:value-of select="."/></dc:description>
  </xsl:template>
  
  <xsl:template match="mods:note">
    <!-- provenance data - discard -->
  </xsl:template>
  
  <xsl:template match="mods:physicalDescription/mods:internetMediaType">
    <dc:format><xsl:value-of select="."/></dc:format>
  </xsl:template>
  
  <xsl:template match="mods:physicalDescription/mods:extent">
    <!-- discard -->
  </xsl:template>
  
  <!-- NOTE(SM): we remove all the identifiers that are not HTTP URIs. -->
  
  <xsl:template match="mods:identifier">
   <!-- ignore -->
  </xsl:template>
  
  <xsl:template match="mods:identifier[contains(.,'http://')]">
    <dc:identifier><xsl:value-of select="."/></dc:identifier>
  </xsl:template>
  
  <xsl:template match="mods:language/mods:languageTerm">
    <dc:language><xsl:value-of select="."/></dc:language>
  </xsl:template>
  
  <xsl:template match="mods:originInfo/mods:publisher">
    <dc:publisher><xsl:value-of select="."/></dc:publisher>
  </xsl:template>
  
  <xsl:template match="mods:relatedItem">
    <dc:relation><xsl:value-of select="."/></dc:relation>
  </xsl:template>
  
  <xsl:template match="mods:accessCondition">
    <dc:rights><xsl:value-of select="."/></dc:rights>
  </xsl:template>
  
  <xsl:template match="mods:classification">
    <dc:subject><xsl:value-of select="."/></dc:subject>
  </xsl:template>
  
  <xsl:template match="mods:titleInfo/mods:title">
    <dc:title><xsl:value-of select="."/></dc:title>
  </xsl:template>

  <xsl:template match="mods:genre">
    <dc:type><xsl:value-of select="."/></dc:type>
  </xsl:template>
  
</xsl:stylesheet>
