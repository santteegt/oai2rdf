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

  <xsl:template name="string-replace-all">
    <xsl:param name="text" />
    <xsl:param name="replace" />
    <xsl:param name="by" />
    <xsl:choose>
      <xsl:when test="contains($text, $replace)">
        <xsl:value-of select="substring-before($text,$replace)" />
        <xsl:value-of select="$by" />
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text"
          select="substring-after($text,$replace)" />
          <xsl:with-param name="replace" select="$replace" />
          <xsl:with-param name="by" select="$by" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="/">
   <rdf:RDF>
    <!-- <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record"/> -->
    <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record/oai:metadata/xoai:metadata/xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'contributor')]"/>
   </rdf:RDF>
  </xsl:template>  
  <xsl:template match="xoai:element[contains(@name,'contributor')]" priority="1">
      <xsl:apply-templates/>
  </xsl:template>
  
  <!-- <xsl:template match="oai_dim:field[contains(@qualifier,'advisor')]"> -->
  <xsl:template match="xoai:element[contains(@name,'advisor') or contains(@name,'assessor') or contains(@name,'tutor')]">
    <!-- <xsl:variable name="url" select="url:encode(translate(translate(substring-before(xoai:element/xoai:field/.,', dir'),',','_'),' ',''))" /> -->
    <!-- <foaf:Person rdf:about="url:encode(http://dspace.ucuenca.edu.ec/resource/contribuidor/director/{translate(translate(.,',','_'),' ','')})"> -->
    <xsl:variable name="nombre">
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="xoai:element/xoai:field/." />
        <xsl:with-param name="replace" select="', dir'" />
        <xsl:with-param name="by" select="''" />
      </xsl:call-template>  
    </xsl:variable>
    <xsl:variable name="url" select="url:encode(translate(translate($nombre,' ,','_'),' .',''))" />
    <foaf:Person rdf:about="http://dspace.ucuenca.edu.ec/resource/contribuidor/director/{$url}">
      <xsl:variable name="nombres" select="substring-before(xoai:element/xoai:field/.,', dir')" />
      <foaf:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="translate($nombre,'.','')"/></foaf:name>
      <xsl:variable name="lastName1" select="substring-before($nombre,', ')" />
      <xsl:variable name="lastName2" select="substring-before( (substring($nombre,string-length($lastName1)+3,string-length($nombre))), ', ')" />

      <foaf:lastName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        
        <xsl:value-of select="concat(concat($lastName1,' '),$lastName2)"/>
      </foaf:lastName>
      <foaf:firstName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <xsl:value-of select="translate(substring($nombre,string-length($lastName1) + 3 + string-length($lastName2)),',','')"/>
      </foaf:firstName>
    </foaf:Person>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'author')]">
    <xsl:variable name="url" select="url:encode(translate(translate(xoai:element/xoai:field/.,',','_'),' ',''))" /> 
    <!-- <foaf:Person rdf:about="url:encode(http://dspace.ucuenca.edu.ec/resource/contribuidor/director/{translate(translate(.,',','_'),' ','')})"> -->
    <foaf:Person rdf:about="http://dspace.ucuenca.edu.ec/resource/contribuidor/autor/{$url}">
      <xsl:variable name="nombres" select="xoai:element/xoai:field/." />
      <foaf:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="$nombres"/></foaf:name>
      <xsl:variable name="lastName1" select="substring-before($nombres,', ')" />
      <xsl:variable name="lastName2" select="substring-before( (substring($nombres,string-length($lastName1)+3,string-length($nombres))), ', ')" />

      <foaf:lastName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <!-- <xsl:value-of select="concat(substring-before(.,', '), concat(' ', substring-before( (substring(.,string-length(substring-before(.,', '))+3,string-length(.))) , ', ') ) )"/> -->
        <xsl:value-of select="concat(concat($lastName1,' '),$lastName2)"/>
      </foaf:lastName>
      <foaf:firstName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <xsl:value-of select="translate(substring($nombres,string-length($lastName1) + 3 + string-length($lastName2)),',','')"/>
      </foaf:firstName>
    </foaf:Person>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'collaborator')]">
    <xsl:variable name="url" select="url:encode(translate(translate(xoai:element/xoai:field/.,',','_'),' ',''))" /> 
    <!-- <foaf:Person rdf:about="url:encode(http://dspace.ucuenca.edu.ec/resource/contribuidor/director/{translate(translate(.,',','_'),' ','')})"> -->
    <foaf:Person rdf:about="http://dspace.ucuenca.edu.ec/resource/contribuidor/colaborador/{$url}">
      <xsl:variable name="nombres" select="xoai:element/xoai:field/." />
      <foaf:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="$nombres"/></foaf:name>
      <xsl:variable name="lastName1" select="substring-before($nombres,', ')" />
      <xsl:variable name="lastName2" select="substring-before( (substring($nombres,string-length($lastName1)+3,string-length($nombres))), ', ')" />

      <foaf:lastName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <!-- <xsl:value-of select="concat(substring-before(.,', '), concat(' ', substring-before( (substring(.,string-length(substring-before(.,', '))+3,string-length(.))) , ', ') ) )"/> -->
        <xsl:value-of select="concat(concat($lastName1,' '),$lastName2)"/>
      </foaf:lastName>
      <foaf:firstName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <xsl:value-of select="translate(substring($nombres,string-length($lastName1) + 3 + string-length($lastName2)),',','')"/>
      </foaf:firstName>
    </foaf:Person>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'coordinator')]">
    <xsl:variable name="url" select="url:encode(translate(translate(xoai:element/xoai:field/.,',','_'),' ',''))" /> 
    <!-- <foaf:Person rdf:about="url:encode(http://dspace.ucuenca.edu.ec/resource/contribuidor/director/{translate(translate(.,',','_'),' ','')})"> -->
    <foaf:Person rdf:about="http://dspace.ucuenca.edu.ec/resource/contribuidor/coordinador/{$url}">
      <xsl:variable name="nombres" select="xoai:element/xoai:field/." />
      <foaf:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="$nombres"/></foaf:name>
      <xsl:variable name="lastName1" select="substring-before($nombres,', ')" />
      <xsl:variable name="lastName2" select="substring-before( (substring($nombres,string-length($lastName1)+3,string-length($nombres))), ', ')" />

      <foaf:lastName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <!-- <xsl:value-of select="concat(substring-before(.,', '), concat(' ', substring-before( (substring(.,string-length(substring-before(.,', '))+3,string-length(.))) , ', ') ) )"/> -->
        <xsl:value-of select="concat(concat($lastName1,' '),$lastName2)"/>
      </foaf:lastName>
      <foaf:firstName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <xsl:value-of select="translate(substring($nombres,string-length($lastName1) + 3 + string-length($lastName2)),',','')"/>
      </foaf:firstName>
    </foaf:Person>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'other')]">
    <xsl:variable name="url" select="url:encode(translate(translate(xoai:element/xoai:field/.,',','_'),' ',''))" /> 
    <!-- <foaf:Person rdf:about="url:encode(http://dspace.ucuenca.edu.ec/resource/contribuidor/director/{translate(translate(.,',','_'),' ','')})"> -->
    <foaf:Person rdf:about="http://dspace.ucuenca.edu.ec/resource/contribuidor/otro/{$url}">
      <xsl:variable name="nombres" select="xoai:element/xoai:field/." />
      <foaf:name rdf:datatype="http://www.w3.org/2001/XMLSchema#string"><xsl:value-of select="$nombres"/></foaf:name>
      <xsl:variable name="lastName1" select="substring-before($nombres,', ')" />
      <xsl:variable name="lastName2" select="substring-before( (substring($nombres,string-length($lastName1)+3,string-length($nombres))), ', ')" />

      <foaf:lastName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <!-- <xsl:value-of select="concat(substring-before(.,', '), concat(' ', substring-before( (substring(.,string-length(substring-before(.,', '))+3,string-length(.))) , ', ') ) )"/> -->
        <xsl:value-of select="concat(concat($lastName1,' '),$lastName2)"/>
      </foaf:lastName>
      <foaf:firstName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
        <xsl:value-of select="translate(substring($nombres,string-length($lastName1) + 3 + string-length($lastName2)),',','')"/>
      </foaf:firstName>
    </foaf:Person>
  </xsl:template>


</xsl:stylesheet>
