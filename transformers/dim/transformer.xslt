<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/"
  xmlns:oai="http://www.openarchives.org/OAI/2.0/"
  xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/"
  xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
  xmlns:bibo="http://purl.org/ontology/bibo/"
  xmlns:ow="http://www.ontoweb.org/ontology/1#"
  exclude-result-prefixes="xsl xsi oai oai_dc dim"
>

  <xsl:output method="xml"/>
  
  <xsl:template match="/">
   <rdf:RDF>
    <xsl:apply-templates select="oai:OAI-PMH/oai:ListSets"/>
   </rdf:RDF>
  </xsl:template>  
  <xsl:template match="oai:set[starts-with(./oai:setSpec,'com_')]" priority="1">
    <bibo:Collection rdf:about="http://dspace.ucuenca.edu.ec/resource/comunidad/{substring(oai:setSpec,15)}">
     <xsl:apply-templates select="oai:setName"/>
    </bibo:Collection>
  </xsl:template>
  <xsl:template match="oai:set[starts-with(./oai:setSpec,'col_')]" priority="1">
    <bibo:Collection rdf:about="http://dspace.ucuenca.edu.ec/resource/coleccion/{substring(oai:setSpec,15)}">
     <xsl:apply-templates select="oai:setName"/>
    </bibo:Collection>
  </xsl:template>
<!--
  <xsl:template match="oai:set" priority="1">
    <bibo:Collection rdf:about="{oai:set/oai:setSpec}">
     <xsl:apply-templates select="oai:setName"/>
    </bibo:Collection>
  </xsl:template>
-->
  <xsl:template match="oai:setName">
    <dcterms:description rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="."/></dcterms:description>
  </xsl:template>

  <xsl:template match="oai:resumptionToken">
  </xsl:template>    
  
</xsl:stylesheet>
