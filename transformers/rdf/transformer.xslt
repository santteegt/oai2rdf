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
    <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record/oai:metadata/rdf:RDF"/>
   </rdf:RDF>
  </xsl:template>
    
  <xsl:template match="rdf:RDF">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*|@*|text()">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
