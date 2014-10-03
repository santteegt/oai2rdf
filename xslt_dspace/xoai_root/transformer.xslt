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
  xmlns:mrel="http://id.loc.gov/vocabulary/relators/"
  xmlns:rdag1="http://rdvocab.info/Elements/"
  exclude-result-prefixes="xsl xsi url oai xoai"
>

  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- %% LECTURA LISTSETS %& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <xsl:param name="file2" select="document('listSets.rdf')"/>
  
  <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'" />
  <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

  <xsl:output method="xml" />


  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- % FUNCION EXTENDIDA %& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
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
  
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- % INICIO DE TRANSF. %& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <xsl:template match="/">
   <rdf:RDF>
    <xsl:apply-templates select="oai:OAI-PMH/oai:ListRecords/oai:record"/>
   </rdf:RDF>
  </xsl:template>  
  

  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- %%% REGISTROS OAI %%%& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <xsl:template match="oai:record" priority="1">
    <xsl:variable name="identifier" select="substring(oai:header/oai:identifier,37)" />
    <xsl:variable name="coll_id" select="substring( oai:header/oai:setSpec[starts-with(.,'col_')]/. ,15)" />   
    <!--
    <xsl:value-of select="translate( $file2//bibo:Collection[substring(@rdf:about, (string-length(@rdf:about) - string-length(concat('coleccion/', $coll_id))) + 1) = concat('coleccion/', $coll_id)]/dcterms:description/. , $smallcase, $uppercase)" />
    -->
    <xsl:variable name="coll_desc" select="translate( $file2//bibo:Collection[substring(@rdf:about, (string-length(@rdf:about) - string-length(concat('coleccion/', $coll_id))) + 1) = concat('coleccion/', $coll_id)]/dcterms:description/. , $smallcase, $uppercase)" />
    

    <!-- %%%%%%%%%%%%%%%%%%%%%% -->
    <!-- %% TIPOS DE RECURSO %& -->
    <!-- %%%%%%%%%%%%%%%%%%%%%% -->
    <xsl:choose>

      <xsl:when test="contains($coll_desc,'TESIS') = 'true' or contains($coll_desc,'MONOGRAF') = 'true'">
        <bibo:Thesis rdf:about="http://dspace.ucuenca.edu.ec/resource/recurso/{$identifier}">
          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'com_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/comunidad/{substring(.,15)}" />
          </xsl:for-each>

          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'col_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/coleccion/{substring(.,15)}" />
          </xsl:for-each>
          <xsl:apply-templates select="oai:metadata/xoai:metadata"/>  
        </bibo:Thesis>
      </xsl:when>

      <xsl:when test="string-length(translate($coll_desc,'1234567890-','')) = 0 or contains($coll_desc,'REVISTA') = 'true'">
        <bibo:Issue rdf:about="http://dspace.ucuenca.edu.ec/resource/recurso/{$identifier}">
        <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'com_')]">
          <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/comunidad/{substring(.,15)}" />
        </xsl:for-each>

        <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'col_')]">
          <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/coleccion/{substring(.,15)}" />
        </xsl:for-each>
        <xsl:apply-templates select="oai:metadata/xoai:metadata"/>  
      </bibo:Issue>
      </xsl:when>
      
      <xsl:when test="contains($coll_desc,'EVENTOS') = 'true'">
        <bibo:Performance rdf:about="http://dspace.ucuenca.edu.ec/resource/recurso/{$identifier}">
          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'com_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/comunidad/{substring(.,15)}" />
          </xsl:for-each>

          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'col_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/coleccion/{substring(.,15)}" />
          </xsl:for-each>
          <xsl:apply-templates select="oai:metadata/xoai:metadata"/>  
        </bibo:Performance>
      </xsl:when>

      <xsl:when test="contains($coll_desc,'LIBRO') = 'true'">
        <bibo:Book rdf:about="http://dspace.ucuenca.edu.ec/resource/recurso/{$identifier}">
          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'com_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/comunidad/{substring(.,15)}" />
          </xsl:for-each>

          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'col_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/coleccion/{substring(.,15)}" />
          </xsl:for-each>
          <xsl:apply-templates select="oai:metadata/xoai:metadata"/>  
        </bibo:Book>
      </xsl:when>

      <xsl:when test="contains($coll_desc,'PUBLICACIONES') = 'true'">
        <bibo:Article rdf:about="http://dspace.ucuenca.edu.ec/resource/recurso/{$identifier}">
          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'com_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/comunidad/{substring(.,15)}" />
          </xsl:for-each>

          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'col_')]">
            <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/coleccion/{substring(.,15)}" />
          </xsl:for-each>
          <xsl:apply-templates select="oai:metadata/xoai:metadata"/>  
        </bibo:Article>
      </xsl:when>

      <xsl:otherwise>
        <bibo:Document rdf:about="http://dspace.ucuenca.edu.ec/resource/recurso/{$identifier}">
          <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'com_')]">
          <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/comunidad/{substring(.,15)}" />
        </xsl:for-each>

        <xsl:for-each select="oai:header/oai:setSpec[starts-with(.,'col_')]">
          <dcterms:isPartOf rdf:resource="http://dspace.ucuenca.edu.ec/resource/coleccion/{substring(.,15)}" />
        </xsl:for-each>
        <xsl:apply-templates select="oai:metadata/xoai:metadata"/>  
      </bibo:Document>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="xoai:metadata" priority="1">
      <xsl:apply-templates/>
  </xsl:template>

  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- %%% CONTRIBUIDORES %%& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'contributor')]/xoai:element[contains(@name,'advisor') or contains(@name,'assessor') or contains(@name,'tutor')]">
    <xsl:for-each select="xoai:element/xoai:field">
      <xsl:variable name="nombre">
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="." />
          <xsl:with-param name="replace" select="', dir'" />
          <xsl:with-param name="by" select="''" />
        </xsl:call-template>  
      </xsl:variable>
      <xsl:variable name="url" select="url:encode(translate(translate($nombre,' ,','_'),' .',''))" />
      <mrel:ths rdf:resource="http://dspace.ucuenca.edu.ec/resource/contribuidor/director/{$url}" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'contributor')]/xoai:element[contains(@name,'author')]">
    <xsl:for-each select="xoai:element/xoai:field">
      <xsl:variable name="url" select="url:encode(translate(translate(.,',','_'),' ',''))" />
      <mrel:aut rdf:resource="http://dspace.ucuenca.edu.ec/resource/contribuidor/autor/{$url}" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'contributor')]/xoai:element[contains(@name,'collaborator')]">
    <xsl:for-each select="xoai:element/xoai:field">
      <xsl:variable name="url" select="url:encode(translate(translate(.,',','_'),' ',''))" />
      <mrel:ctb rdf:resource="http://dspace.ucuenca.edu.ec/resource/contribuidor/colaborador/{$url}" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'contributor')]/xoai:element[contains(@name,'coordinator')]">
    <xsl:for-each select="xoai:element/xoai:field">
      <xsl:variable name="url" select="url:encode(translate(translate(.,',','_'),' ',''))" />
      <mrel:ctb rdf:resource="http://dspace.ucuenca.edu.ec/resource/contribuidor/coordinador/{$url}" />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'contributor')]/xoai:element[contains(@name,'other')]">
    <xsl:for-each select="xoai:element/xoai:field">
      <xsl:variable name="url" select="url:encode(translate(translate(.,',','_'),' ',''))" />
      <mrel:oth rdf:resource="http://dspace.ucuenca.edu.ec/resource/contribuidor/otro/{$url}" />
    </xsl:for-each>
  </xsl:template>

  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- %%%%%%% DATES %%%%%%%& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'date')]/xoai:element[contains(@name,'accessioned')]">
    <dcterms:dateSubmitted rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </dcterms:dateSubmitted>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'date')]/xoai:element[contains(@name,'available')]">
    <dcterms:available rdf:datatype="http://www.w3.org/2001/XMLSchema#dateTime">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </dcterms:available>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'date')]/xoai:element[contains(@name,'issued')]">
    <dcterms:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </dcterms:issued>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'date')]/xoai:element[contains(@name,'none')]">

  </xsl:template>

  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- %%%% DESCRIPTIONS %%%& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'description')]/xoai:element[contains(@name,'es_ES') or contains(@name,'none')]">
    <bibo:abstract rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="es">
      <xsl:value-of select="xoai:field/." />
    </bibo:abstract>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'description')]/xoai:element[contains(@name,'abstract')]">
    <bibo:abstract rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="en">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:abstract>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'description')]/xoai:element[contains(@name,'city')]">
    <mrel:pup rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </mrel:pup>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'description')]/xoai:element[contains(@name,'degree')]">
    <rdag1:academicDegree rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="es">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </rdag1:academicDegree>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'description')]/xoai:element[contains(@name,'numberSequence')]">
    <bibo:issue rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:issue>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'description')]/xoai:element[contains(@name,'provenance')]">
    <xsl:for-each select="xoai:element/xoai:field">
      <dcterms:provenance rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="en">
        <xsl:value-of select="." />
      </dcterms:provenance>
    </xsl:for-each>
    
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'description')]/xoai:element[contains(@name,'sponsorship')]">
    <mrel:spn rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </mrel:spn>
  </xsl:template>
  
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- %%%% IDENTIFIERS %%%%& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'identifier')]/xoai:element[contains(@name,'isbn')]">
    <bibo:isbn13 rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:isbn13>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'identifier')]/xoai:element[contains(@name,'issn')]">
    <bibo:issn rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:issn>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'identifier')]/xoai:element[contains(@name,'other')]">
    <bibo:identifier rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:identifier>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'identifier')]/xoai:element[contains(@name,'uri')]">
    <bibo:handle rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:handle>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'identifier')]/xoai:element[contains(@name,'citation')]">

  </xsl:template>

  <!-- %%%%%%%%%%%%%%%%%%%%%% -->
  <!-- %%%% OTROS %%%& -->
  <!-- %%%%%%%%%%%%%%%%%%%%%% -->

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'format')]">
    <xsl:variable name="url" select="url:encode(translate(xoai:element/xoai:field/.,'/','-'))" />
    <dcterms:format rdf:resource="http://dspace.ucuenca.edu.ec/resource/fileformat/{$url}"/>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'rights')]">
    
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'language')]/xoai:element[contains(@name,'iso')]">
    
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'publisher')]">
    <bibo:issn rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:issn>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'publisher')]">
    <bibo:issn rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:issn>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'relation')]/xoai:element[contains(@name,'ispartofseries')]">
    <dcterms:isPartOf rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </dcterms:isPartOf>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'subject')]">
    <xsl:variable name="type" select="xoai:element/@name" />
    <xsl:if test="$type = 'es_ES'">
      <xsl:for-each select="xoai:element/xoai:field">
        <dcterms:subject rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="es">
          <xsl:value-of select="." />
        </dcterms:subject>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'title')]">
    <dcterms:title rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="es">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </dcterms:title>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'title')]/xoai:element[contains(@name,'alternative')]">
    <bibo:shortTitle rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="{xoai:element/@name}">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:shortTitle>
  </xsl:template>
  
  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'type')]">
    <dcterms:type rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="en">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </dcterms:type>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'ucuenca')]/xoai:element[contains(@name,'paginacion')]">
    <bibo:numPages rdf:datatype="http://www.w3.org/2001/XMLSchema#string" xml:lang="en">
      <xsl:value-of select="xoai:element/xoai:field/." />
    </bibo:numPages>
  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'ucuenca')]/xoai:element[contains(@name,'id')]">

  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'dc')]/xoai:element[contains(@name,'ucuenca')]/xoai:element[contains(@name,'gradoacademico')]">

  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'bundles')]/xoai:element[contains(@name,'bundle')]">
    <xsl:variable name="bundleType" select="xoai:field[contains(@name,'name')]" />
    <xsl:if test="$bundleType = 'ORIGINAL'">
      <bibo:uri rdf:datatype="http://www.w3.org/2001/XMLSchema#anyURI">
        <xsl:value-of select="xoai:element/xoai:element/xoai:field[contains(@name,'url')]/." />
      </bibo:uri>
    </xsl:if>
  </xsl:template>  

  <xsl:template match="xoai:element[contains(@name,'others')]">

  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'repository')]">

  </xsl:template>

  <xsl:template match="xoai:element[contains(@name,'license')]">
    <dcterms:license>
      <xsl:value-of select="xoai:field[contains(@name,'bin')]/." />
    </dcterms:license>
  </xsl:template>


</xsl:stylesheet>
