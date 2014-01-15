<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i="http://www.ness.cz/schemas/isvzus/v11.1"
    xmlns:f="http://opendata.cz/xslt/functions#"
    exclude-result-prefixes="f i"
    xpath-default-namespace="http://www.ness.cz/schemas/isvzus/v11.1"
    
    xmlns:gr="http://purl.org/goodrelations/v1#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:pc="http://purl.org/procurement/public-contracts#"
    xmlns:pceu="http://purl.org/procurement/public-contracts-eu#"
    xmlns:pcdt="http://purl.org/procurement/public-contracts-datatypes#"
    xmlns:dc="http://purl.org/dc/terms/"
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:s="http://schema.org/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:activities="http://purl.org/procurement/public-contracts-activities#"
    xmlns:authkinds="http://purl.org/procurement/public-contracts-authority-kinds#"
    xmlns:kinds="http://purl.org/procurement/public-contracts-kinds#"
    xmlns:proctypes="http://purl.org/procurement/public-contracts-procedure-types#"
    xmlns:criteria="http://purl.org/procurement/public-contracts-criteria#">

	<xsl:variable name="nm_lod" select="'http://linked.opendata.cz/resource/'"/>
	<xsl:variable name="nm_vvz" select="concat($nm_lod, 'vestnikverejnychzakazek.cz/')"/>
    <xsl:variable name="nm_cpv" select="concat($nm_lod,'cpv-2008/concept/')" />
    <xsl:variable name="nm_pcCriteria" select="'http://purl.org/procurement/public-contracts-criteria/'" />
    
    <xsl:variable name="schemeAgency">Ministerstvo pro místní rozvoj</xsl:variable>
    <xsl:variable name="creator">http://linked.opendata.cz/resource/business-entity/CZ66002222</xsl:variable>
    
    <xsl:variable name="root" select="root" />
    
    <xsl:variable name="VVZ_FormId" select="$root/skup_priloha/hlavicka/VvzFormId" />
    <xsl:variable name="VVZ_FormNumber" select="$root/skup_priloha/hlavicka/VvzNumber" />
    <xsl:variable name="VVZ_PCNumber" select="$root/skup_priloha/hlavicka/CocoCode" />
    <xsl:variable name="VVZ_SubmitterIC" select="$root/Ic_I_1" /> <!-- TODO osetrit jestli je IC zadano, kdyz ne, tak to bude null. CO s tim? -->
    
    <xsl:variable name="VVZ_FormURL" select="concat('http://www.vestnikverejnychzakazek.cz/cs/Form/Display/', $VVZ_FormId)" />

    <xsl:variable name="PC_URI" select="concat($nm_vvz,'public-contract/',$VVZ_PCNumber,'-',$VVZ_FormNumber)" />
    
    <!-- IDENTIFIERS -->
    <xsl:variable name="id_contractNotice" select="concat($nm_vvz,'contract-notice/',$VVZ_FormNumber)" />
    <xsl:variable name="id_contractNoticeIdentifier" select="concat($nm_vvz,'contract-notice/',$VVZ_FormNumber,'/identifier/1')" />
    <xsl:variable name="id_publicContract" select="$PC_URI" />
    <xsl:variable name="id_tendersOpening" select="concat($PC_URI,'/tenders-opening/1')" />
    <xsl:variable name="id_tenderPlace" select="concat($PC_URI,'/tender-place/1')" />
    <xsl:variable name="id_PCContactPoint" select="concat($PC_URI,'/contact-point/1')" />
    <xsl:variable name="id_contractingAuthority" select="concat($nm_lod,'business-entity/CZ',$VVZ_SubmitterIC,'-',$VVZ_FormNumber)" />
    <xsl:variable name="id_pcPlace" select="concat($PC_URI,'/place/1')" />
    <xsl:variable name="id_estimatedPrice" select="concat($PC_URI,'/estimated-price/1')" />
    <xsl:variable name="id_awardCriteriaCombination" select="concat($PC_URI,'/combination-of-contract-award-criteria/')" />
    <xsl:variable name="nm_contractAwardCriterion" select="concat($PC_URI,'/contract-award-criterion/')" />
    <xsl:variable name="nm_publicContractCriteria" select="concat($PC_URI,'/public-contract-criteria/')" />
    <xsl:variable name="id_pcIdentifier1" select="concat($PC_URI,'/identifier/1')" />
    <xsl:variable name="id_pcIdentifier2" select="concat($PC_URI,'/identifier/2')" />
    <xsl:variable name="id_contractingAuthAddress" select="concat($PC_URI,'/postal-address/1')" />
    <xsl:variable name="id_documentsPrice" select="concat($PC_URI,'/documents-price/1')" />
    <xsl:variable name="id_agreedPrice" select="concat($PC_URI,'/agreed-price/1')" />
    
    <!-- TODO musim osetrit aby se funkcim nepredavaly prazdne parametry -->

    <xsl:output encoding="UTF-8" indent="yes" method="xml" />

	<xsl:template match="root">
	    
	    <rdf:RDF>
	        
	        <pc:TendersOpening rdf:about="{$id_tendersOpening}">
	            <xsl:if test="Datum_IV_3_8/text()">
	            <dc:date rdf:datatype="xsd:dateTime">
	                <xsl:value-of select="f:processDateTime(Datum_IV_3_8,Cas_IV_3_8)" />
	            </dc:date>
	            </xsl:if>
	            <xsl:if test="Misto_IV_3_8/text()">
	            <s:location>
	                <s:Place rdf:about="{$id_tenderPlace}">
	                    <rdfs:label xml:lang="cs">
	                        <xsl:value-of select="Misto_IV_3_8" />
	                    </rdfs:label>
	                </s:Place>
	            </s:location>
	            </xsl:if>
	            <pc:publicNotice>
	                <pc:ContractNotice rdf:about="{$id_contractNotice}">
	                    <xsl:if test="skup_priloha/hlavicka/VvzPublished/text()">
	                    <pc:publicationDate rdf:datatype="xsd:date">
	                        <xsl:value-of select="f:processDate(skup_priloha/hlavicka/VvzPublished)"/>
	                    </pc:publicationDate>
	                    </xsl:if>
	                    <rdfs:seeAlso>
	                        <xsl:value-of select="$VVZ_FormURL" />
	                    </rdfs:seeAlso>
	                    <adms:identifier>
	                        <adms:identifier rdf:about="{$id_contractNoticeIdentifier}">
       	                        <skos:notation rdf:datatype="xsd:string">
       	                            <xsl:value-of select="$VVZ_FormNumber" />
       	                        </skos:notation>
       	                        <adms:schemeAgency>
       	                            <xsl:value-of select="$schemeAgency" />
       	                        </adms:schemeAgency>
       	                        <dc:creator rdf:resource="{$creator}" />
	                        </adms:identifier>
	                    </adms:identifier>
	                </pc:ContractNotice>
	            </pc:publicNotice>
	        </pc:TendersOpening>
	        
	        <pc:Contract rdf:about="{$id_publicContract}">
	            <xsl:if test="NazevPridelenyZakazceVerejnymZadavatelem_II_1_1/text()">
	            <dc:title xml:lang="cs">
	                <xsl:value-of select="NazevPridelenyZakazceVerejnymZadavatelem_II_1_1" />
	            </dc:title>
	            </xsl:if>
	            <xsl:if test="StrucnyPopisZakazky_II_1_5/text()">
	            <dc:description xml:lang="cs">
	                <xsl:value-of select="StrucnyPopisZakazky_II_1_5" />
	            </dc:description>
	            </xsl:if>
	            
	            <xsl:apply-templates select="PCContact">
	                <xsl:with-param name="id_PCContactPoint" select="$id_PCContactPoint" />
	            </xsl:apply-templates>
	            
	            <xsl:if test="DruhZakazkyAMistoProvadeniStavebnichPraci_II_1_2/text()">
	            <pc:kind rdf:resource="{f:getKind(/node())}" />
	            </xsl:if>
	            <xsl:if test="DruhRizeni_IV_1_1/text()">
	            <pc:procedureType rdf:resource="{f:getProcedureType(DruhRizeni_IV_1_1)}" />
	            </xsl:if>
	            <pc:contractingAuthority>
	                <gr:BusinessEntity rdf:about="{$id_contractingAuthority}">
	                    <xsl:if test="UredniNazev_I_1/text()">
	                    <gr:legalName xml:lang="cs">
	                        <xsl:value-of select="UredniNazev_I_1" />
	                    </gr:legalName>
	                    </xsl:if>
	                    <xsl:if test="ObecnaAdresaVerejnehoZadavatele_I_1/text()">
	                    <foaf:page rdf:resource="{ObecnaAdresaVerejnehoZadavatele_I_1}" />
	                    </xsl:if>
	                    <xsl:if test="AdresaProfiluKupujiciho_I_1/text()">
	                    <pc:profile rdf:resource="{AdresaProfiluKupujiciho_I_1}" />
	                    </xsl:if>
	                    
	                    <xsl:if test="Dvz_DruhVerejnehoZadavatele_I_2">
                            <xsl:choose>
                                <xsl:when test="string-length(f:getAuthorityKind(Dvz_DruhVerejnehoZadavatele_I_2)) &gt; 0">
                                    <pc:authorityKind rdf:resource="{f:getAuthorityKind(Dvz_DruhVerejnehoZadavatele_I_2)}" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="Dvz_Upresneni_I_2/text()">
                                    <pc:authorityKind>
                                        <pc:authorityKind> <!-- TODO zde by mohl byt URI, ale jaky? -->
                                            <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-authority-kinds#" />
                                            <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-authority-kinds#"></skos:topConceptOf>
                                            <skos:prefLabel xml:lang="cs">
                                                <xsl:value-of select="Dvz_Upresneni_I_2" />
                                            </skos:prefLabel>
                                        </pc:authorityKind>
                                    </pc:authorityKind>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
	                    </xsl:if>
	                    	                    
	                    <xsl:apply-templates select="Hpc_SluzbyProSirokouVerejnost_I_3 | Hpc_Obrana_I_3 | Hpc_VerejnyPoradekABezpecnost_I_3 | Hpc_ZivotniProstredi_I_3 | Hpc_HospodarskeAFinancniZalezitosti_I_3 | Hpc_Zdravotnictvi_I_3 | Hpc_BydleniAObcanskaVybavenost_I_3 | Hpc_SocialniSluzby_I_3 | Hpc_RekreaceKulturaANabozenstvi_I_3 | Hpc_Skolstvi_I_3" />
	                    <xsl:apply-templates select="Hpc_Jiny_I_3" />
	                    
	                    <s:address>
	                        <s:PostalAddress rdf:about="{$id_contractingAuthAddress}">
	                            <xsl:if test="PostovniAdresa_I_1/text()">
	                            <s:streetAddress><xsl:value-of select="PostovniAdresa_I_1" /></s:streetAddress>
	                            </xsl:if>
	                            <xsl:if test="Psc_I_1/text()">
	                            <s:postalCode><xsl:value-of select="Psc_I_1" /></s:postalCode>
	                            </xsl:if>
	                            <xsl:if test="Obec_I_1/text()">
	                            <s:addressLocality><xsl:value-of select="Obec_I_1" /></s:addressLocality>
	                            </xsl:if>
	                            <xsl:if test="Stat_I_1/text()">
	                            <s:addressCountry><xsl:value-of select="Stat_I_1" /></s:addressCountry>
	                            </xsl:if>
	                        </s:PostalAddress>
	                    </s:address>
	                </gr:BusinessEntity>
	            </pc:contractingAuthority>
	            
	            <xsl:if test="HlavniSlovnikHp_II_1_6">
	            <pc:mainObject rdf:resource="{concat($nm_cpv,f:stripDashes(HlavniSlovnikHp_II_1_6))}" />
	            </xsl:if>
	            
	            <xsl:apply-templates select="HlavniSlovnikDp1_II_1_6 | HlavniSlovnikDp2_II_1_6 | HlavniSlovnikDp3_II_1_6 | HlavniSlovnikDp4_II_1_6" />
	            
	            <xsl:if test="HlavniMistoProvadeniStavebnichPraci_II_1_2/text()">
	            <pc:location>
	                <s:Place rdf:about="{$id_pcPlace}">
	                    <rdfs:label xml:lang="cs"><xsl:value-of select="HlavniMistoProvadeniStavebnichPraci_II_1_2" /></rdfs:label>
	                    <xsl:if test="KodNuts1_II_1_2/text()">
	                    <pceu:hasParentRegion rdf:resource="{concat('http://ec.europa.eu/eurostat/ramon/rdfdata/nuts2008/',KodNuts1_II_1_2)}" />
	                    </xsl:if>
	                </s:Place>
	            </pc:location>
	            </xsl:if>
	            <pc:notice rdf:resource="{$id_contractNotice}" />
	            <pc:estimatedPrice>
                    <gr:UnitPriceSpecification rdf:about="{$id_estimatedPrice}">
                        <xsl:if test="UvedtePredpokladanouHodnotuBezDph_II_2_1/text()">
	                    <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(UvedtePredpokladanouHodnotuBezDph_II_2_1)" /></gr:hasCurrencyValue>
                        </xsl:if>
                        <xsl:if test="RozsahOd_II_2_1/text()">
                       <gr:hasMinCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(RozsahOd_II_2_1)" /></gr:hasMinCurrencyValue>
	                    </xsl:if>
                        <xsl:if test="RozsahDo_II_2_1/text()">
                       <gr:hasMaxCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(RozsahDo_II_2_1)" /></gr:hasMaxCurrencyValue>
	                    </xsl:if>
                        <xsl:if test="MenaHodnota_II_2_1/text()">
	                    <gr:hasCurrency><xsl:value-of select="MenaHodnota_II_2_1" /></gr:hasCurrency>
                        </xsl:if>
	                    <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean">false</gr:valueAddedTaxIncluded>
	                </gr:UnitPriceSpecification>
	            </pc:estimatedPrice>
	            <pc:awardCriteriaCombination>
                    <pc:awardCriteriaCombination rdf:about="{$id_awardCriteriaCombination}">
                        <xsl:apply-templates select="NejnizsiNabidkovaCena_IV_2_1 | Kriteria1_IV_2_1 | Kriteria2_IV_2_1 | Kriteria3_IV_2_1 | Kriteria4_IV_2_1 | Kriteria5_IV_2_1 | Kriteria6_IV_2_1 | Kriteria7_IV_2_1 | Kriteria8_IV_2_1 | Kriteria9_IV_2_1 | Kriteria10_IV_2_1">
                            <xsl:with-param name="nm_criterion"><xsl:value-of select="$nm_contractAwardCriterion" /></xsl:with-param>
                            <xsl:with-param name="nm_criteria"><xsl:value-of select="$nm_publicContractCriteria" /></xsl:with-param>
                        </xsl:apply-templates>
                    </pc:awardCriteriaCombination>
	            </pc:awardCriteriaCombination>
	            <xsl:if test="NeboZahajeni_II_3/text()">
     	            <pc:startDate rdf:datatype="xsd:date">
     	                <xsl:value-of select="f:processDate(NeboZahajeni_II_3)" />
     	            </pc:startDate>
	            </xsl:if>
	            <xsl:if test="Dokonceni_II_3/text()">
    	            <pc:estimatedEndDate rdf:datatype="xsd:date">
    	                <xsl:value-of select="f:processDate(Dokonceni_II_3)" />
    	            </pc:estimatedEndDate>
	            </xsl:if>
	            <xsl:if test="Datum_IV_3_4/text()">
	            <pc:tenderDeadline rdf:datatype="xsd:dateTime">
	                <xsl:value-of select="f:processDateTime(Datum_IV_3_4,Cas_IV_3_4)" />
	            </pc:tenderDeadline>
	            </xsl:if>
	            <xsl:if test="Datum_IV_3_3/text()">
	            <pc:documentationRequestDeadline rdf:datatype="xsd:dateTime">
	                <xsl:value-of select="f:processDateTime(Datum_IV_3_3,Cas_IV_3_3)" />
	            </pc:documentationRequestDeadline>
	            </xsl:if>
	            <xsl:if test="VMesicich_II_3/text() or NeboDnech_II_3/text()">
	            <pc:duration rdf:datatype="xsd:duration">
	                <xsl:value-of select="f:getDuration(VMesicich_II_3,NeboDnech_II_3)" />
	            </pc:duration>
	            </xsl:if>
	            <adms:identifier>
	                <adms:Identifier rdf:about="{$id_pcIdentifier1}">
	                    <xsl:if test="SpisoveCisloPrideleneVerejnymZadavatelem_IV_3_1/text()">
	                    <skos:notation><xsl:value-of select="SpisoveCisloPrideleneVerejnymZadavatelem_IV_3_1" /></skos:notation>
	                    </xsl:if>
	                    <dc:creator><xsl:value-of select="$id_contractingAuthority" /></dc:creator>
	                    <!--<dc:type rdf:resource="http://purl.org/procurement/public-contracts#ContractIdentifierIssuedByContractingAuthority" /> -->
	                    <xsl:if test="UredniNazev_I_1/text()">
	                    <adms:schemeAgency><xsl:value-of select="UredniNazev_I_1" /></adms:schemeAgency>
	                    </xsl:if>
	                </adms:Identifier>
	            </adms:identifier>
	            <adms:identifier>
	                <adms:Identifier rdf:about="{$id_pcIdentifier2}">
	                    <skos:notation rdf:datatype="xsd:string">
	                        <xsl:value-of select="$VVZ_PCNumber" />
	                    </skos:notation>
	                    <adms:schemeAgency>
	                        <xsl:value-of select="$schemeAgency" />
	                    </adms:schemeAgency>
	                    <dc:creator rdf:resource="{$creator}" />
	                </adms:Identifier>
	            </adms:identifier>
	            
	            <xsl:if test="UvedteCenu_IV_3_3">
	            <pc:documentsPrice>
	                <gr:UnitPriceSpecification rdf:about="{$id_documentsPrice}">
	                    <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(UvedteCenu_IV_3_3)" /></gr:hasCurrencyValue>
	                    <xsl:if test="Mena_IV_3_3/text()">
	                    <gr:hasCurrency><xsl:value-of select="Mena_IV_3_3" /></gr:hasCurrency>
	                    </xsl:if>
	                    <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean">false</gr:valueAddedTaxIncluded>
	                </gr:UnitPriceSpecification>
	            </pc:documentsPrice>
	            </xsl:if>
	            
	            <xsl:if test="Hodnota_II_2_1">
	            <pc:agreedPrice>
	                <gr:UnitPriceSpecification rdf:about="{$id_agreedPrice}">
	                    <gr:hasCurrencyValue><xsl:value-of select="f:processPrice(Hodnota_II_2_1)" /></gr:hasCurrencyValue>
	                    <xsl:if test="Mena_II_2_1/text()">
	                    <gr:hasCurrency><xsl:value-of select="Mena_II_2_1" /></gr:hasCurrency>
	                    </xsl:if>
	                    <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean">false</gr:valueAddedTaxIncluded>
	                </gr:UnitPriceSpecification>
	            </pc:agreedPrice>
	            </xsl:if>
	            
	            <!-- TENDERS -->
	            <xsl:if test="count(skup_priloha/oddil_5) &gt; 1">
	                <xsl:for-each select="skup_priloha/oddil_5">
	                    <pc:lot>
	                        <pc:Contract>
	                            <xsl:if test="ZakazkaNazev_V">
	                            <gr:legalName><xsl:value-of select="ZakazkaNazev_V" /></gr:legalName>
                                </xsl:if>
	                            <xsl:if test="Strucpopis_V_5">
	                            <dc:description><xsl:value-of select="Strucpopis_V_5" /></dc:description>
	                            </xsl:if>
	                            <xsl:if test="PocetNabidek_V_2">
	                            <pc:numberOfTenders rdf:datatype="xsd:integer"><xsl:value-of select="PocetNabidek_V_2" /></pc:numberOfTenders>
	                            </xsl:if>
	                            <xsl:call-template name="contractAward">
	                                <xsl:with-param name="award" select="." />
	                            </xsl:call-template>
	                        </pc:Contract>
	                    </pc:lot>
	                </xsl:for-each>
	            </xsl:if>
	            <xsl:if test="count(skup_priloha/oddil_5) = 1">
	                <xsl:call-template name="contractAward">
	                    <xsl:with-param name="award" select="." />
	                </xsl:call-template>
	            </xsl:if>
	            
	        </pc:Contract>
	        

	    </rdf:RDF>
	       
	</xsl:template>
    
    <!-- TENDERS -->
    <xsl:template name="contractAward">
        <xsl:param name="award" />
        
        <xsl:if test="$award/Datum_V_1">
            <pc:awardDate><xsl:value-of select="f:processDate($award/Datum_V_1)" /></pc:awardDate>
        </xsl:if>
        <pc:awardedTender>
            <pc:Tender>
                <pc:supplier>
                    <gr:BusinessEntity>
                        <xsl:if test="$award/NazevDodavatele_V_3">
                        <gr:legalName><xsl:value-of select="$award/NazevDodavatele_V_3" /></gr:legalName>
                        </xsl:if>
                        <xsl:if test="$award/AdresaURL_V_3">
                        <foaf:page><xsl:value-of select="$award/AdresaURL_V_3" /></foaf:page>
                        </xsl:if>
                        <s:contact>
                            <s:ContactPoint>
                                <xsl:if test="$award/NazevDodavatele_V_3">
                                <s:name><xsl:value-of select="$award/NazevDodavatele_V_3" /></s:name>
                                </xsl:if>
                                <xsl:if test="$award/Email_V_3">
                                <s:email><xsl:value-of select="$award/Email_V_3" /></s:email>
                                </xsl:if>
                                <xsl:if test="$award/Telefon_V_3">
                                <s:telephone><xsl:value-of select="$award/Telefon_V_3" /></s:telephone>
                                </xsl:if>
                                <xsl:if test="$award/Fax_V_3">
                                <s:faxNumber><xsl:value-of select="$award/Fax_V_3" /></s:faxNumber>
                                </xsl:if>
                            </s:ContactPoint>
                        </s:contact>
                        <s:address>
                            <s:PostalAddress>
                                <xsl:if test="$award/Adresa_V_3">
                                <s:streetAddress><xsl:value-of select="$award/Adresa_V_3" /></s:streetAddress>
                                </xsl:if>
                                <xsl:if test="$award/Psc_V_3">
                                <s:postalCode><xsl:value-of select="$award/Psc_V_3" /></s:postalCode>
                                </xsl:if>
                                <xsl:if test="$award/Obec_V_3">
                                <s:addressLocality><xsl:value-of select="$award/Obec_V_3" /></s:addressLocality>
                                </xsl:if>
                                <xsl:if test="$award/Stat_V_3">
                                <s:addressCountry><xsl:value-of select="$award/Stat_V_3" /></s:addressCountry>
                                </xsl:if>
                            </s:PostalAddress>
                        </s:address>
                    </gr:BusinessEntity>
                </pc:supplier>
                <xsl:if test="$award/Hodnota2_V_4">
                    <pc:offeredPrice>
                        <gr:UnitPriceSpecification>
                            <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice($award/Hodnota2_V_4)" /></gr:hasCurrencyValue>
                            <gr:hasCurrency><xsl:value-of select="$award/Mena2_V_4" /></gr:hasCurrency>
                            <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean"><xsl:value-of select="$award/Dph2_V_4" /></gr:valueAddedTaxIncluded>
                        </gr:UnitPriceSpecification>
                    </pc:offeredPrice>
                </xsl:if>
                <xsl:if test="$award/Hodnota1_V_4">
                <pc:estimatedPrice>
                    <gr:UnitPriceSpecification>
                        <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice($award/Hodnota1_V_4)" /></gr:hasCurrencyValue>
                        <gr:hasCurrency><xsl:value-of select="$award/Mena1_V_4" /></gr:hasCurrency>
                        <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean"><xsl:value-of select="$award/Dph1_V_4" /></gr:valueAddedTaxIncluded>
                    </gr:UnitPriceSpecification>
                </pc:estimatedPrice>
                </xsl:if>
            </pc:Tender>
        </pc:awardedTender>
    </xsl:template>
   
    <xsl:template match="KontaktniMista_I_1 | KRukam_I_1 | E_Mail_I_1 | Tel_I_1 | Fax_I_1">
       <xsl:param name="id_PCContactPoint" />
       <pc:contact>
           <s:ContactPoint rdf:about="{$id_PCContactPoint}">
               <xsl:if test="KontaktniMista_I_1/text()">
                   <s:description xml:lang="cs">
                       <xsl:value-of select="KontaktniMista_I_1" />
                   </s:description>
               </xsl:if>
               <xsl:if test="KRukam_I_1/text()">
                   <s:name xml:lang="cs">
                       <xsl:value-of select="KRukam_I_1" />
                   </s:name>
               </xsl:if>
               <xsl:if test="E_Mail_I_1/text()">
                   <s:email rdf:resource="{concat('mailto:',E_Mail_I_1)}" />
               </xsl:if>
               <xsl:if test="Tel_I_1/text()">
                   <s:telephone>
                       <xsl:value-of select="Tel_I_1" />
                   </s:telephone>
               </xsl:if>
               <xsl:if test="Fax_I_1/text()">
                   <s:faxNumber>
                       <xsl:value-of select="Fax_I_1" />
                   </s:faxNumber>
               </xsl:if>
           </s:ContactPoint>
       </pc:contact>
   </xsl:template>
   
   
   <!-- ACTIVITIES -->
   
    <xsl:template match="SluzbyProSirokouVerejnost_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#GeneralServices" />
	</xsl:template>
    
    <xsl:template match="Hpc_Obrana_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Defence" />
    </xsl:template>
    
    <xsl:template match="Hpc_VerejnyPoradekABezpecnost_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Safety" />
    </xsl:template>
    
    <xsl:template match="Hpc_ZivotniProstredi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Environment" />
    </xsl:template>
    
    <xsl:template match="Hpc_HospodarskeAFinancniZalezitosti_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#EconomicAffairs" />
    </xsl:template>
    
    <xsl:template match="Hpc_Zdravotnictvi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Health" />
    </xsl:template>
    
    <xsl:template match="Hpc_BydleniAObcanskaVybavenost_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Housing" />
    </xsl:template>
    
    <xsl:template match="Hpc_SocialniSluzby_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#SocialProtection" />
    </xsl:template>
    
    <xsl:template match="Hpc_RekreaceKulturaANabozenstvi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Cultural" />
    </xsl:template>
    
    <xsl:template match="Hpc_Skolstvi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Educational" />
    </xsl:template>
    
    <xsl:template match="Hpc_Jiny_I_3">
        <xsl:if test="$root/Hpc_Upresneni_I_3/text()">
        <pc:activityKind>
            <pc:activityKind> <!-- TODO zde by mohl byt URI -->
                <skos:prefLabel><xsl:value-of select="$root/Hpc_Upresneni_I_3" /></skos:prefLabel>
                <skos:isScheme rdf:resource="http://purl.org/procurement/public-contracts-activities#" />
                <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-activities#" />
            </pc:activityKind>
        </pc:activityKind>
        </xsl:if>
    </xsl:template>

    <!-- CRITERIA -->

    <xsl:template match="NejnizsiNabidkovaCena_IV_2_1">
        <xsl:param name="nm_criterion" />
        <xsl:param name="nm_criteria" />
        <xsl:variable name="id">1</xsl:variable>
        
        <xsl:if test="text()">
        <pc:awardCriterion>
            <pc:CriterionWeighting rdf:about="{concat($nm_criterion,$id)}">
                <pc:weightedCriterion rdf:resource="http://purl.org/procurement/public-contracts-criteria#LowestPrice"></pc:weightedCriterion>
                <pc:criterionWeight rdf:datatype="pcdt:percentage">100</pc:criterionWeight>
            </pc:CriterionWeighting>
        </pc:awardCriterion>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="Kriteria1_IV_2_1">
        <xsl:param name="nm_criterion" />
        <xsl:param name="nm_criteria" />
        <xsl:variable name="id">2</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_criterion,$id)}">
                <xsl:if test="$root/Vaha1_IV_2_1/text()">
                <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha1_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_criteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria2_IV_2_1">
        <xsl:param name="nm_criterion" />
        <xsl:param name="nm_criteria" />
        <xsl:variable name="id">3</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_criterion,$id)}">
                <xsl:if test="$root/Vaha2_IV_2_1/text()">
                <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha2_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_criteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria3_IV_2_1">
        <xsl:param name="nm_criterion" />
        <xsl:param name="nm_criteria" />
        <xsl:variable name="id">4</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_criterion,$id)}">
                <xsl:if test="$root/Vaha3_IV_2_1">
                <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha3_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_criteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <!-- doplnit kriteria 4-10 -->
    

    
    <!-- ADDITIONAL OBJECTS -->
    <xsl:template match="HlavniSlovnikDp1_II_1_6 | HlavniSlovnikDp2_II_1_6 | HlavniSlovnikDp3_II_1_6 | HlavniSlovnikDp4_II_1_6">
        <pc:additionalObject rdf:resource="{concat($nm_cpv,f:stripDashes(text()))}" />
    </xsl:template>
    
	
    <!-- @param date dd/mm/yyyy -->
    <xsl:function name="f:processDate">
        <xsl:param name="date"/>
        <xsl:analyze-string select="$date" regex="(\d{{2}})/(\d{{2}})/(\d{{4}})">
            <xsl:matching-substring>
                <xsl:value-of select="xsd:date(concat(regex-group(3), '-', regex-group(2), '-', regex-group(1)))"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="$date"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- @param date dd/mm/yyyy -->
    <!-- @param time hh:mm -->
    <xsl:function name="f:processDateTime">
        <xsl:param name="date" />
        <xsl:param name="time" />
        <xsl:choose>
            <xsl:when test="$time">
                <xsl:value-of select="concat(f:processDate($date),'T',$time)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(f:processDate($date),'T00:00')" />
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <!-- @param root node -->
    <xsl:function name="f:getKind">
        
        <xsl:param name="root" />
        <xsl:variable name="kindCat" select="$root/DruhZakazkyAMistoProvadeniStavebnichPraci_II_1_2/text()" />
        
        <xsl:variable name="serviceKinds" as="element()*">
            <kind>http://purl.org/procurement/public-contracts-kinds#MaintenanceAndRepairServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#LandTransportServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#AirTransportServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#TransportOfMailServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#TelecommunicationServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#FinancialServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#ComputerServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#ResearchAndDevelopmentServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#AccountingServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#MarketResearchServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#ConsultingServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#ArchitecturalServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#AdvertisingServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#BuildingCleaningServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#PublishingServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#SewageServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#HotelAndRestaurantServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#RailTransportServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#WaterTransportServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#SupportingTransportServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#LegalServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#PersonnelPlacementServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#InvestigationAndSecurityServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#EducationServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#HealthServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#CulturalServices</kind>
            <kind>http://purl.org/procurement/public-contracts-kinds#OtherServices</kind>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="matches($kindCat,'SERVICES')">
                <xsl:value-of select="$serviceKinds[xsd:integer($root/KategorieSluzeb_II_1_2)]" />
            </xsl:when>
            <xsl:when test="matches($kindCat,'WORKS')">
                <xsl:choose>
                    <xsl:when test="$root/StavebniPraceProvadeni_II_1_2">
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#WorksExecution'" />
                    </xsl:when>
                    <xsl:when test="$root/StavebniPraceProjektProvadeni_II_1_2">
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#WorksDesignExecution'" />
                    </xsl:when>
                    <xsl:when test="$root/StavebniPraceProvadeniSouladPozadavky_II_1_2">
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#WorksRealisation'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#WorksDesign'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="matches($kindCat,'SUPPLIES')">
                
                <xsl:variable name="supplyKind" select="$root/Dodavky_II_1_2" as="xsd:string" />
                
                <xsl:choose>
                    <xsl:when test="matches($supplyKind,'PURCHASE')">
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#SuppliesPurchase'" />
                    </xsl:when>
                    <xsl:when test="matches($supplyKind,'LEASE')">
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#SuppliesLease'" />
                    </xsl:when>
                    <xsl:when test="matches($supplyKind,'RENTAL')">
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#SuppliesRental'" />
                    </xsl:when>
                    <xsl:when test="matches($supplyKind,'HIRE_PURCHASE')">
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#SuppliesHire'" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#Supplies'" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-kinds#Services'" />
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <!-- @param type string -->
    <xsl:function name="f:getProcedureType">
        <xsl:param name="type" as="xsd:string" />
        
        <xsl:choose>
            <xsl:when test="matches($type,'OPEN')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#Open'" />
            </xsl:when>
            <xsl:when test="matches($type,'RESTRICTED')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#Restricted'" />
            </xsl:when>
            <xsl:when test="matches($type,'ACCELERATED_RESTRICTED')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#AcceleratedRestricted'" />
            </xsl:when>
            <xsl:when test="matches($type,'NEGOTIATED')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#Negotiated'" />
            </xsl:when>
            <xsl:when test="matches($type,'ACCELERATED_NEGOTIATED')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#AcceleratedNegotiated'" />
            </xsl:when>
            <xsl:when test="matches($type,'COMPETITIVE_DIALOGUE')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#CompetitiveDialogue'" />
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- @param text string -->
    <xsl:function name="f:stripDashes">
        <xsl:param name="text" as="xsd:string" />
        
        <xsl:analyze-string select="$text" regex="(\d*)-(\d*)">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="$text"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
        
    </xsl:function>
    
    <!-- @param price string -->
    <xsl:function name="f:processPrice">
        <xsl:param name="price" as="xsd:string" />
        <xsl:value-of select="translate(translate($price,' ',''),',','.')" />
    </xsl:function>

    
    <!-- @param kind string -->
    <xsl:function name="f:getAuthorityKind">
        <xsl:param name="kind" as="xsd:string" />
        
        <xsl:choose>
            <xsl:when test="matches($kind,'MINISTRY')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-authority-kinds#NationalAuthority'" />
            </xsl:when>
            <xsl:when test="matches($kind,'NATIONAL_AGENCY')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-authority-kinds#NationalAgency'" />
            </xsl:when>
            <xsl:when test="matches($kind,'REGIONAL_AUTHORITY')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-authority-kinds#LocalAuthority'" />
            </xsl:when>
            <xsl:when test="matches($kind,'REGIONAL_AGENCY')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-authority-kinds#LocalAgency'" />
            </xsl:when>
            <xsl:when test="matches($kind,'BODY_PUBLIC')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-authority-kinds#PublicBody'" />
            </xsl:when>
            <xsl:when test="matches($kind,'EU_INSTITUTION')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-authority-kinds#InternationalOrganization'" />
            </xsl:when>
            <xsl:when test="matches($kind,'OTHER')">
                
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- @param months -->
    <!-- @param years -->
    <!-- @param days -->
    <xsl:function name="f:getDuration">
        <xsl:param name="months" />
        <xsl:param name="days" />
        
        <xsl:choose>
            <xsl:when test="$months">
                <xsl:value-of select="concat('P',$months,'M')" />
            </xsl:when>
            <xsl:when test="$days">
                <xsl:value-of select="concat('P',$months,'D')" />
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
</xsl:stylesheet>