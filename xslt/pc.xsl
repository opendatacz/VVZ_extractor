<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:i="http://www.ness.cz/schemas/isvzus/v11.1"
    xmlns:f="http://opendata.cz/xslt/functions#"
    xmlns:uuid="http://www.uuid.org"
    exclude-result-prefixes="f i uuid"
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
    
    <xsl:import href="uuid.xslt" />
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" />

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
    <xsl:variable name="VVZ_SubmitterIC">
        <!-- ICO can be found in two places -->
        <xsl:choose>
            <xsl:when test="$root/Ic_I_1/text()">
                <xsl:value-of select="concat('CZ',$root/Ic_I_1)" />
            </xsl:when>
            <xsl:when test="$root/skup_priloha/hlavicka/IcoZadavatel/text()">
                <xsl:value-of select="concat('CZ',$root/skup_priloha/hlavicka/IcoZadavatel)" />
            </xsl:when>
            <xsl:when test="$root/Nazev_I_1/text()">
                <xsl:value-of select="concat(f:slugify($root/Nazev_I_1),'-',$VVZ_FormNumber)" />
            </xsl:when>
            <xsl:when test="$root/UredniNazev_I_1/text()">
                <xsl:value-of select="concat(f:slugify($root/UredniNazev_I_1),'-',$VVZ_FormNumber)" />
            </xsl:when>
            <xsl:otherwise>
                <!-- make UUID -->
                <xsl:value-of select="concat(uuid:get-uuid(),'-',$VVZ_FormNumber)" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="VVZ_FormURL" select="concat('http://www.vestnikverejnychzakazek.cz/cs/Form/Display/', $VVZ_FormId)" />

    <xsl:variable name="PC_URI" select="concat($nm_vvz,'public-contract/',$VVZ_PCNumber,'-',$VVZ_FormNumber)" />
    
    <!-- IDENTIFIERS -->
    <xsl:variable name="id_contractNotice" select="concat($nm_vvz,'contract-notice/',$VVZ_FormNumber)" />
    <xsl:variable name="id_contractNoticeIdentifier" select="concat($nm_vvz,'contract-notice/',$VVZ_FormNumber,'/identifier/1')" />
    <xsl:variable name="id_publicContract" select="$PC_URI" />
    <xsl:variable name="id_tendersOpening" select="concat($PC_URI,'/tenders-opening/1')" />
    <xsl:variable name="id_tendersOpeningPlace" select="concat($PC_URI,'/tenders-opening-place/1')" />
    <xsl:variable name="id_PCContactPoint" select="concat($PC_URI,'/pc-contact-point/1')" />
    <xsl:variable name="nm_tendersContactPoint" select="concat($PC_URI,'/tenders-contact-point/')" />
    <xsl:variable name="nm_tender" select="concat($PC_URI,'/tender/')" />
    <xsl:variable name="nm_tendersContract" select="concat($PC_URI,'/tenders-contract/')" />
    <xsl:variable name="nm_tendersOfferedPrice" select="concat($PC_URI,'/tenders-offered-price/')" />
    <xsl:variable name="nm_tendersEstimatedPrice" select="concat($PC_URI,'/tenders-estimated-price/')" />
    <xsl:variable name="nm_supplier" select="concat($PC_URI,'/supplier/')" />
    <xsl:variable name="nm_tendersPlace" select="concat($PC_URI,'/tenders-place/')" />
    <xsl:variable name="nm_businessEntity" select="concat($nm_lod,'business-entity/')" />
    <xsl:variable name="id_contractingAuthority" select="concat($nm_businessEntity,$VVZ_SubmitterIC)" />
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
    <xsl:variable name="id_activityKind" select="concat($PC_URI,'/activity-kind/1')" />
    <xsl:variable name="id_authorityKind" select="concat($PC_URI,'/authority-kind/1')" />
    
	<xsl:template match="root">
	    
	    <xsl:if test="verze_formulare='0200' or verze_formulare='0300'">
	    <rdf:RDF>
	        <xsl:choose>
	            <xsl:when test="verze_formulare='0200'"> <!-- ContractNotice -->
	                <xsl:if test="Datum_IV_3_8 | Misto_IV_3_8">
	                    <pc:TendersOpening rdf:about="{$id_tendersOpening}">
	                        <xsl:apply-templates select="Datum_IV_3_8 | Misto_IV_3_8" />
	                        <pc:publicNotice>
	                            <pc:ContractNotice rdf:about="{$id_contractNotice}">
	                                <xsl:apply-templates select="skup_priloha/hlavicka/VvzPublished" />
	                            </pc:ContractNotice>
	                        </pc:publicNotice>
	                    </pc:TendersOpening>
	                </xsl:if>
	            </xsl:when>
	            <xsl:when test="verze_formulare='0300'"> <!-- ContractAwardNotice -->
	                <pc:ContractAwardNotice rdf:about="{$id_contractNotice}">
	                    <xsl:apply-templates select="skup_priloha/hlavicka/VvzPublished" />
	                </pc:ContractAwardNotice>
	            </xsl:when>
	        </xsl:choose>
	        
	        
	        <pc:Contract rdf:about="{$id_publicContract}">
	            <xsl:apply-templates select="NazevPridelenyZakazce_II_1_1 | NazevPridelenyZakazceVerejnymZadavatelem_II_1_1" />

	            <xsl:apply-templates select="StrucnyPopisZakazky_II_1_5 | StrucnyPopis_II1_4" />
	            
	            <xsl:apply-templates select=".[KontaktniMista_I_1 | KRukam_I_1 | E_Mail_I_1 | Tel_I_1 | Fax_I_1]" mode="pcContactPoint" />
	            
	            <xsl:apply-templates select="DruhZakazkyAMistoProvadeniStavebnichPraci_II_1_2 | DruhZakazky_II_1_2" />
	            
	            <xsl:apply-templates select="DruhRizeni_IV_1_1" />

	            <pc:contractingAuthority>
	                <gr:BusinessEntity rdf:about="{$id_contractingAuthority}">
	                    <xsl:apply-templates select="UredniNazev_I_1 | Nazev_I_1" mode="legalName" />
	                    <xsl:apply-templates select="ObecnaAdresaVerejnehoZadavatele_I_1 | AdresaProfiluKupujiciho_I_1 | AdresaProfiluZadavatele_I_1 | Dvz_DruhVerejnehoZadavatele_I_2 | DruhVerejnehoZadavatele_I_2" />
	 	                    	
	                    <!-- form type 2 -->
	                    <xsl:apply-templates select="Hpc_SluzbyProSirokouVerejnost_I_3 | Hpc_Obrana_I_3 | Hpc_VerejnyPoradekABezpecnost_I_3 | Hpc_ZivotniProstredi_I_3 | Hpc_HospodarskeAFinancniZalezitosti_I_3 | Hpc_Zdravotnictvi_I_3 | Hpc_BydleniAObcanskaVybavenost_I_3 | Hpc_SocialniSluzby_I_3 | Hpc_RekreaceKulturaANabozenstvi_I_3 | Hpc_Skolstvi_I_3" />
	                    <xsl:apply-templates select="Hpc_Jiny_I_3" />
	                    <!-- form type 3 -->
	                    <xsl:apply-templates select="SluzbyProSirokouVerejnost_I_3 | Obrana_I_3 | VerejnyPoradekABezpecnost_I_3 | ZivotniProstredi_I_3 | HospodarskeAFinancniZalezitosti_I_3 | Zdravotnictvi_I_3 | BydleniAObcanskaVybavenost_I_3 | SocialniSluzby_I_3 | RekreaceKulturaANabozenstvi_I_3 | Skolstvi_I_3" />
	                    <xsl:apply-templates select="JinyProsimSpecifikujte_I_3" />
	                    
	                    <xsl:apply-templates select=".[PostovniAdresa_I_1 | Psc_I_1 | Obec_I_1 | Stat_I_1]" mode="contractingAuthorityAddress" />
	                    
	                </gr:BusinessEntity>
	            </pc:contractingAuthority>
	            
	            <xsl:apply-templates select="HlavniSlovnikHp_II_1_6 | HlavniSlovnikHp_II_1_5" />
	            
	            <!-- form type 2 -->
	            <xsl:apply-templates select="HlavniSlovnikDp1_II_1_6 | HlavniSlovnikDp2_II_1_6 | HlavniSlovnikDp3_II_1_6 | HlavniSlovnikDp4_II_1_6" />
	            <!-- form type 3 -->
	            <xsl:apply-templates select="HlavniSlovnikDp1_II_1_5 | HlavniSlovnikDp2_II_1_5 | HlavniSlovnikDp3_II_1_5 | HlavniSlovnikDp4_II_1_5" />
	            
	            <xsl:apply-templates select="HlavniMistoProvadeniStavebnichPraci_II_1_2 | HlavniMisto_II_1_2" />

	            <pc:notice rdf:resource="{$id_contractNotice}" />
	            
	            <xsl:apply-templates select=".[UvedtePredpokladanouHodnotuBezDph_II_2_1 | RozsahOd_II_2_1 | RozsahDo_II_2_1]" mode="pcEstimatedPrice" />
	            
	            <pc:awardCriteriaCombination>
                    <pc:awardCriteriaCombination rdf:about="{$id_awardCriteriaCombination}">
                        <!-- nejnizsi cenova nabidka - NejnizsiNabidkovaCena_IV_2_1 form type 2 | KriteriaTyp_IV_2_1 form type 3 -->
                        <xsl:apply-templates select="NejnizsiNabidkovaCena_IV_2_1 | KriteriaTyp_IV_2_1 | Kriteria1_IV_2_1 | Kriteria2_IV_2_1 | Kriteria3_IV_2_1 | Kriteria4_IV_2_1 | Kriteria5_IV_2_1 | Kriteria6_IV_2_1 | Kriteria7_IV_2_1 | Kriteria8_IV_2_1 | Kriteria9_IV_2_1 | Kriteria10_IV_2_1" />
                    </pc:awardCriteriaCombination>
	            </pc:awardCriteriaCombination>
	            
	            <xsl:apply-templates select="NeboZahajeni_II_3 | Dokonceni_II_3 | Datum_IV_3_4 | Datum_IV_3_3" />
	            
	            <xsl:apply-templates select="VMesicich_II_3 | NeboDnech_II_3" />
	            
	            <xsl:apply-templates select="SpisoveCisloPrideleneVerejnymZadavatelem_IV_3_1 | SpisCislo_IV_3_1" />
	            
	            <adms:identifier>
	                <adms:Identifier rdf:about="{$id_pcIdentifier2}">
	                    <skos:notation>
	                        <xsl:value-of select="$VVZ_PCNumber" />
	                    </skos:notation>
	                    <adms:schemeAgency xml:lang="cs">
	                        <xsl:value-of select="$schemeAgency" />
	                    </adms:schemeAgency>
	                    <dc:creator rdf:resource="{$creator}" />
	                </adms:Identifier>
	            </adms:identifier>
	            
	            <xsl:apply-templates select="UvedteCenu_IV_3_3 | Hodnota_II_2_1" />
	            
	            <!-- TENDERS -->
	            <xsl:if test="count(skup_priloha/oddil_5) &gt; 1">
	                <xsl:for-each select="skup_priloha/oddil_5">
	                    <pc:lot>
	                        <pc:Contract rdf:about="{concat($nm_tendersContract,position())}">
	                            <xsl:apply-templates select="ZakazkaNazev_V | Strucpopis_V_5 | PocetNabidek_V_2" />
	                            
	                            <xsl:call-template name="contractAward">
	                                <xsl:with-param name="award" select="." />
	                                <xsl:with-param name="bussinesEntityURI">
	                                    <xsl:choose>
	                                        <xsl:when test="NazevDodavatele_V_3/text()">
	                                            <xsl:value-of select="concat($nm_businessEntity, f:slugify(NazevDodavatele_V_3), '-', $VVZ_FormNumber)" />
	                                        </xsl:when>
	                                        <xsl:otherwise>
	                                            <!-- make UUID -->
	                                            <xsl:value-of select="concat($nm_businessEntity, uuid:get-uuid(), '-', $VVZ_FormNumber)" />
	                                        </xsl:otherwise>
	                                    </xsl:choose>
	                                </xsl:with-param>
	                            </xsl:call-template>
	                        </pc:Contract>
	                    </pc:lot>
	                </xsl:for-each>
	            </xsl:if>
	            <xsl:if test="count(skup_priloha/oddil_5) = 1">
	                <xsl:call-template name="contractAward">
	                    <xsl:with-param name="award" select="skup_priloha/oddil_5" />
	                    <xsl:with-param name="bussinesEntityURI">
	                        <xsl:choose>
	                            <xsl:when test="$root/skup_priloha/IcoDodavatel/text()">
	                                <xsl:value-of select="concat($nm_businessEntity, $root/skup_priloha/IcoDodavatel)" />
	                            </xsl:when>
	                            <xsl:when test="NazevDodavatele_V_3/text()">
	                                <xsl:value-of select="concat($nm_businessEntity, f:slugify(NazevDodavatele_V_3), '-', $VVZ_FormNumber)" />
	                            </xsl:when>
	                            <xsl:otherwise>
	                                <!-- make UUID -->
	                                <xsl:value-of select="concat($nm_businessEntity, uuid:get-uuid(), '-', $VVZ_FormNumber)" />
	                            </xsl:otherwise>
	                        </xsl:choose>
	                    </xsl:with-param>
	                </xsl:call-template>
	            </xsl:if>
	            
	        </pc:Contract>

	    </rdf:RDF>
	    </xsl:if>
	       
	</xsl:template>
    
    <xsl:template match="root" mode="pcContactPoint">
        <pc:contact>
            <s:ContactPoint rdf:about="{$id_PCContactPoint}">
                <xsl:apply-templates select="KontaktniMista_I_1 | KRukam_I_1 | E_Mail_I_1 | Tel_I_1 | Fax_I_1" />
            </s:ContactPoint>
        </pc:contact>
    </xsl:template>
    
    <xsl:template match="root" mode="contractingAuthorityAddress">
        <s:address>
            <s:PostalAddress rdf:about="{$id_contractingAuthAddress}">
                <xsl:apply-templates select="PostovniAdresa_I_1 | Adresa_I_1 | Psc_I_1 | Obec_I_1 | Stat_I_1" />
            </s:PostalAddress>
        </s:address>
    </xsl:template>
    
    <xsl:template match="root" mode="pcEstimatedPrice">
        <pc:estimatedPrice>
            <gr:PriceSpecification rdf:about="{$id_estimatedPrice}">
                <xsl:apply-templates select="UvedtePredpokladanouHodnotuBezDph_II_2_1 | RozsahOd_II_2_1 | RozsahDo_II_2_1 | MenaHodnota_II_2_1" />
                <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean">false</gr:valueAddedTaxIncluded>
            </gr:PriceSpecification>
        </pc:estimatedPrice>
    </xsl:template>
    
    <!-- TENDERS OPENING -->
    
    <xsl:template match="Datum_IV_3_8">
        
        <xsl:variable name="time">
            <xsl:choose>
                <xsl:when test="$root/Cas_IV_3_8">
                    <xsl:value-of select="$root/Cas_IV_3_8" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'00:00'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="text()">
           <xsl:variable name="tidyDateTime" select="f:processDateTime(text(),$time)" />
           <xsl:if test="$tidyDateTime">
               <dc:date rdf:datatype="xsd:dateTime">
                   <xsl:value-of select="$tidyDateTime" />
               </dc:date>    
           </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Misto_IV_3_8">
        <s:location>
            <s:Place rdf:about="{$id_tendersOpeningPlace}">
                <s:name>
                    <xsl:value-of select="text()" />
                </s:name>
            </s:Place>
        </s:location>
    </xsl:template>
    
    <xsl:template match="VvzPublished">
        <xsl:if test="text()">
            <xsl:variable name="tidyDate" select="f:processDate(text())" />
            <xsl:if test="$tidyDate">
            <pc:publicationDate rdf:datatype="xsd:date">
            <xsl:value-of select="$tidyDate"/>
            </pc:publicationDate>
            </xsl:if>
        </xsl:if>
        <rdfs:seeAlso rdf:resource="{$VVZ_FormURL}" />
        <adms:identifier>
            <adms:identifier rdf:about="{$id_contractNoticeIdentifier}">
                <skos:notation>
                    <xsl:value-of select="$VVZ_FormNumber" />
                </skos:notation>
                <adms:schemeAgency>
                    <xsl:value-of select="$schemeAgency" />
                </adms:schemeAgency>
                <dc:creator rdf:resource="{$creator}" />
            </adms:identifier>
        </adms:identifier>
    </xsl:template>
    
    <!-- TENDERS -->
    <xsl:template name="contractAward">
        <xsl:param name="award" as="node()" />
        <xsl:param name="bussinesEntityURI" as="xsd:string" />
        
        <xsl:variable name="count" as="xsd:integer">
            <xsl:number/>
        </xsl:variable>

        <xsl:apply-templates select="$award/Datum_V_1" />
        
        <pc:awardedTender>
            <pc:Tender rdf:about="{concat($nm_tender,$count)}">
                <pc:supplier>
                    <gr:BusinessEntity rdf:about="{$bussinesEntityURI}">
                        <xsl:apply-templates select="$award/NazevDodavatele_V_3" mode="businessEntity" />
                        <xsl:apply-templates select="$award/AdresaURL_V_3" />
                        
                        <xsl:if test="$award/NazevDodavatele_V_3 | $award/Email_V_3 | $award/Telefon_V_3 | $award/Fax_V_3">
                        <s:contact>
                            <s:ContactPoint rdf:about="{concat($nm_tendersContactPoint,$count)}">
                                <xsl:apply-templates select="$award/NazevDodavatele_V_3" mode="contactPoint" />
                                <xsl:apply-templates select="$award/Email_V_3 | $award/Telefon_V_3 | $award/Fax_V_3" />
                            </s:ContactPoint>
                        </s:contact>
                        </xsl:if>
                        <xsl:if test="$award/Adresa_V_3 | $award/Psc_V_3 | $award/Obec_V_3 | $award/Stat_V_3">
                        <s:address>
                            <s:PostalAddress rdf:about="{concat($nm_tendersPlace,$count)}">
                                <xsl:apply-templates select="$award/Adresa_V_3 | $award/Psc_V_3 | $award/Obec_V_3 | $award/Stat_V_3" />
                            </s:PostalAddress>
                        </s:address>
                        </xsl:if>
                    </gr:BusinessEntity>
                </pc:supplier>

                <xsl:if test="$award/Hodnota2_V_4">
                    <pc:offeredPrice>
                        <gr:PriceSpecification rdf:about="{concat($nm_tendersOfferedPrice,$count)}">
                            <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice($award/Hodnota2_V_4)" /></gr:hasCurrencyValue>
                            <xsl:if test="$award/Mena2_V_4">
                            <gr:hasCurrency><xsl:value-of select="$award/Mena2_V_4" /></gr:hasCurrency>
                            </xsl:if>
                            <xsl:if test="$award/Dph2_V_4">
                            <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean"><xsl:value-of select="$award/Dph2_V_4" /></gr:valueAddedTaxIncluded>
                            </xsl:if>
                        </gr:PriceSpecification>
                    </pc:offeredPrice>
                </xsl:if>
                <xsl:if test="$award/Hodnota1_V_4">
                <pc:estimatedPrice>
                    <gr:PriceSpecification rdf:about="{concat($nm_tendersEstimatedPrice,$count)}">
                        <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice($award/Hodnota1_V_4)" /></gr:hasCurrencyValue>
                        <xsl:if test="$award/Mena1_V_4">
                        <gr:hasCurrency><xsl:value-of select="$award/Mena1_V_4" /></gr:hasCurrency>
                        </xsl:if>
                        <xsl:if test="$award/Dph1_V_4">
                        <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean"><xsl:value-of select="$award/Dph1_V_4" /></gr:valueAddedTaxIncluded>
                        </xsl:if>
                    </gr:PriceSpecification>
                </pc:estimatedPrice>
                </xsl:if>
            </pc:Tender>
        </pc:awardedTender>
    </xsl:template>
    
    <xsl:template match="VMesicich_II_3">
        <pc:duration rdf:datatype="xsd:duration">
            <xsl:value-of select="f:getDuration(text(),'M')" />
        </pc:duration>
    </xsl:template>
    
    <xsl:template match="NeboDnech_II_3">
        <pc:duration rdf:datatype="xsd:duration">
            <xsl:value-of select="f:getDuration(text(),'D')" />
        </pc:duration>
    </xsl:template>
    
    <xsl:template match="NazevDodavatele_V_3" mode="businessEntity">
        <gr:legalName><xsl:value-of select="text()" /></gr:legalName>
    </xsl:template>
    
    <xsl:template match="AdresaURL_V_3">
        <foaf:page rdf:resource="{text()}" />
    </xsl:template>
    
    <xsl:template match="NazevDodavatele_V_3" mode="contactPoint">
        <s:name><xsl:value-of select="text()" /></s:name>
    </xsl:template>
    
    <xsl:template match="Email_V_3">
        <s:email rdf:resource="{concat('mailto:',text())}" />
    </xsl:template>
    
    <xsl:template match="Telefon_V_3">
        <s:telephone><xsl:value-of select="text()" /></s:telephone>
    </xsl:template>
    
    <xsl:template match="Fax_V_3">
        <s:faxNumber><xsl:value-of select="text()" /></s:faxNumber>
    </xsl:template>
    
    <xsl:template match="Adresa_V_3">
        <s:streetAddress><xsl:value-of select="text()" /></s:streetAddress>
    </xsl:template>
    
    <xsl:template match="Psc_V_3">
        <s:postalCode><xsl:value-of select="text()" /></s:postalCode>
    </xsl:template>
    
    <xsl:template match="Obec_V_3">
        <s:addressLocality><xsl:value-of select="text()" /></s:addressLocality>
    </xsl:template>
    
    <xsl:template match="Stat_V_3">
        <s:addressCountry><xsl:value-of select="text()" /></s:addressCountry>
    </xsl:template>
    
    <xsl:template match="KontaktniMista_I_1">
        <s:description xml:lang="cs">
            <xsl:value-of select="text()" />
        </s:description>
    </xsl:template>
    
    <xsl:template match="KRukam_I_1">
        <s:name>
            <xsl:value-of select="text()" />
        </s:name>
    </xsl:template>
    
    <xsl:template match="E_Mail_I_1">
        <s:email rdf:resource="{concat('mailto:',text())}" />
    </xsl:template>
    
    <xsl:template match="Tel_I_1">
        <s:telephone>
            <xsl:value-of select="text()" />
        </s:telephone>
    </xsl:template>
    
    <xsl:template match="Fax_I_1">
        <s:faxNumber>
            <xsl:value-of select="text()" />
        </s:faxNumber>
    </xsl:template>
   
   
   <!-- ACTIVITIES -->
   
    <xsl:template match="Hpc_SluzbyProSirokouVerejnost_I_3 | SluzbyProSirokouVerejnost_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#GeneralServices" />
	</xsl:template>
    
    <xsl:template match="Hpc_Obrana_I_3 | Obrana_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Defence" />
    </xsl:template>
    
    <xsl:template match="Hpc_VerejnyPoradekABezpecnost_I_3 | VerejnyPoradekABezpecnost_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Safety" />
    </xsl:template>
    
    <xsl:template match="Hpc_ZivotniProstredi_I_3 | ZivotniProstredi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Environment" />
    </xsl:template>
    
    <xsl:template match="Hpc_HospodarskeAFinancniZalezitosti_I_3 | HospodarskeAFinancniZalezitosti_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#EconomicAffairs" />
    </xsl:template>
    
    <xsl:template match="Hpc_Zdravotnictvi_I_3 | Zdravotnictvi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Health" />
    </xsl:template>
    
    <xsl:template match="Hpc_BydleniAObcanskaVybavenost_I_3 | BydleniAObcanskaVybavenost_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Housing" />
    </xsl:template>
    
    <xsl:template match="Hpc_SocialniSluzby_I_3 | SocialniSluzby_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#SocialProtection" />
    </xsl:template>
    
    <xsl:template match="Hpc_RekreaceKulturaANabozenstvi_I_3 | RekreaceKulturaANabozenstvi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Cultural" />
    </xsl:template>
    
    <xsl:template match="Hpc_Skolstvi_I_3 | Skolstvi_I_3">
        <pc:activityKind rdf:resource="http://purl.org/procurement/public-contracts-activities#Educational" />
    </xsl:template>
    
    <xsl:template match="Hpc_Jiny_I_3">
        <xsl:apply-templates select="$root/Hpc_Upresneni_I_3" />
    </xsl:template>
    
    <xsl:template match="JinyProsimSpecifikujte_I_3">
        <xsl:apply-templates select="$root/JinyProsimSpecifikujteB_I_3" />
    </xsl:template>
    
    <xsl:template match="Hpc_Upresneni_I_3 | JinyProsimSpecifikujteB_I_3">
        <pc:activityKind>
            <pc:activityKind rdf:about="{$id_activityKind}">
                <skos:prefLabel><xsl:value-of select="text()" /></skos:prefLabel>
                <skos:isScheme rdf:resource="http://purl.org/procurement/public-contracts-activities#" />
                <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-activities#" />
            </pc:activityKind>
        </pc:activityKind>
    </xsl:template>

    <!-- CRITERIA -->

    <xsl:template match="NejnizsiNabidkovaCena_IV_2_1 | KriteriaTyp_IV_2_1">

        <xsl:variable name="id" as="xsd:integer">1</xsl:variable>
        
        <xsl:if test="text() = true()">
        <pc:awardCriterion>
            <pc:CriterionWeighting rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <pc:weightedCriterion rdf:resource="http://purl.org/procurement/public-contracts-criteria#LowestPrice"></pc:weightedCriterion>
                <pc:criterionWeight rdf:datatype="pcdt:percentage">100</pc:criterionWeight>
            </pc:CriterionWeighting>
        </pc:awardCriterion>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="Kriteria1_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">2</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha1_IV_2_1/text()">
                <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha1_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria2_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">3</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha2_IV_2_1/text()">
                <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha2_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria3_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">4</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha3_IV_2_1">
                <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha3_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria4_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">5</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha4_IV_2_1">
                    <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha4_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria5_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">6</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha5_IV_2_1">
                    <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha5_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria6_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">7</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha6_IV_2_1">
                    <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha6_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria7_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">8</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha7_IV_2_1">
                    <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha7_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria8_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">9</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha8_IV_2_1">
                    <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha8_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria9_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">10</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha9_IV_2_1">
                    <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha9_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <xsl:template match="Kriteria10_IV_2_1">
        <xsl:variable name="id" as="xsd:integer">11</xsl:variable>
        <pc:awardCriterion>
            <pc:AwardCriterion rdf:about="{concat($nm_contractAwardCriterion,$id)}">
                <xsl:if test="$root/Vaha10_IV_2_1">
                    <pc:criterionWeight rdf:datatype="pcdt:percentage"><xsl:value-of select="$root/Vaha10_IV_2_1" /></pc:criterionWeight>
                </xsl:if>
                <pc:weightedCriterion>
                    <skos:Concept rdf:about="{concat($nm_publicContractCriteria,$id)}">
                        <skos:prefLabel xml:lang="cs"><xsl:value-of select="text()" /></skos:prefLabel>
                        <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                        <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-criteria#" />
                    </skos:Concept>
                </pc:weightedCriterion>                    
            </pc:AwardCriterion>
        </pc:awardCriterion>
    </xsl:template>
    
    <!-- ADDITIONAL OBJECTS -->
    <xsl:template match="HlavniSlovnikDp1_II_1_6 | HlavniSlovnikDp2_II_1_6 | HlavniSlovnikDp3_II_1_6 | HlavniSlovnikDp4_II_1_6 | HlavniSlovnikDp1_II_1_5 | HlavniSlovnikDp2_II_1_5 | HlavniSlovnikDp3_II_1_5 | HlavniSlovnikDp4_II_1_5">
        <pc:additionalObject rdf:resource="{concat($nm_cpv,f:stripDashes(text()))}" />
    </xsl:template>

    <xsl:template match="NazevPridelenyZakazce_II_1_1 | NazevPridelenyZakazceVerejnymZadavatelem_II_1_1">
        <dc:title xml:lang="cs">
            <xsl:value-of select="text()" />
        </dc:title> 
    </xsl:template>
    
    <xsl:template match="StrucnyPopisZakazky_II_1_5 | StrucnyPopis_II1_4s">
        <dc:description xml:lang="cs">
            <xsl:value-of select="text()" />
        </dc:description>
    </xsl:template>
    
    <xsl:template match="DruhZakazkyAMistoProvadeniStavebnichPraci_II_1_2 | DruhZakazky_II_1_2">
        <xsl:if test="text()">
            <xsl:variable name="kind" select="f:getKind(text())" />
            <xsl:if test="$kind!=''">
                <pc:kind rdf:resource="{$kind}" />
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="UredniNazev_I_1 | Nazev_I_1" mode="legalName">
        <gr:legalName xml:lang="cs">
            <xsl:value-of select="text()" />
        </gr:legalName>
    </xsl:template>
    
    <xsl:template match="ObecnaAdresaVerejnehoZadavatele_I_1">
        <foaf:page rdf:resource="{text()}" />
    </xsl:template>
    
    <xsl:template match="AdresaProfiluKupujiciho_I_1">
        <pc:profile rdf:resource="{text()}" />
    </xsl:template>
    
    <xsl:template match="AdresaProfiluZadavatele_I_1">
        <pc:profile rdf:resource="{text()}" />
    </xsl:template>
    
    <xsl:template match="Dvz_DruhVerejnehoZadavatele_I_2 | DruhVerejnehoZadavatele_I_2">
        <xsl:choose>
            <xsl:when test="string-length(f:getAuthorityKind(text())) &gt; 0">
                <pc:authorityKind rdf:resource="{f:getAuthorityKind(text())}" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$root/Dvz_Upresneni_I_2 | $root/ProsimUpresnete_I_2" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="Dvz_Upresneni_I_2 | ProsimUpresnete_I_2">
        <pc:authorityKind>
            <pc:authorityKind rdf:about="{$id_authorityKind}">
                <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-authority-kinds#" />
                <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-authority-kinds#"></skos:topConceptOf>
                <skos:prefLabel xml:lang="cs">
                    <xsl:value-of select="text()" />
                </skos:prefLabel>
            </pc:authorityKind>
        </pc:authorityKind>
    </xsl:template>

    <xsl:template match="DruhRizeni_IV_1_1">
        <xsl:if test="DruhRizeni_IV_1_1/text()">
            <pc:procedureType rdf:resource="{f:getProcedureType(text())}" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="PostovniAdresa_I_1 | Adresa_I_1">
        <s:streetAddress><xsl:value-of select="text()" /></s:streetAddress>
    </xsl:template>
    
    <xsl:template match="Psc_I_1">
        <s:postalCode><xsl:value-of select="text()" /></s:postalCode>
    </xsl:template>
    
    <xsl:template match="Obec_I_1">
        <s:addressLocality><xsl:value-of select="text()" /></s:addressLocality>
    </xsl:template>
    
    <xsl:template match="Stat_I_1">
        <s:addressCountry><xsl:value-of select="text()" /></s:addressCountry>
    </xsl:template>

    <xsl:template match="HlavniSlovnikHp_II_1_6 | HlavniSlovnikHp_II_1_5">
        <xsl:if test="text()">
            <pc:mainObject rdf:resource="{concat($nm_cpv,f:stripDashes(text()))}" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="HlavniMistoProvadeniStavebnichPraci_II_1_2 | HlavniMisto_II_1_2">
        <pc:location>
            <s:Place rdf:about="{$id_pcPlace}">
                <s:name><xsl:value-of select="text()" /></s:name>
                <xsl:apply-templates select="$root/KodNuts1_II_1_2 | $root/NUTS1_II_1_2" />
            </s:Place>
        </pc:location>
    </xsl:template>
    
    <xsl:template match="KodNuts1_II_1_2 | NUTS1_II_1_2">
        <pceu:hasParentRegion rdf:resource="{concat('http://ec.europa.eu/eurostat/ramon/rdfdata/nuts2008/',text())}" />
    </xsl:template>
    
    <xsl:template match="UvedtePredpokladanouHodnotuBezDph_II_2_1">
        <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(text())" /></gr:hasCurrencyValue>
    </xsl:template>
    
    <xsl:template match="RozsahOd_II_2_1">
        <gr:hasMinCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(text())" /></gr:hasMinCurrencyValue>
    </xsl:template>
    
    <xsl:template match="RozsahDo_II_2_1">
        <gr:hasMaxCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(text())" /></gr:hasMaxCurrencyValue>
    </xsl:template>
    
    <xsl:template match="MenaHodnota_II_2_1">
        <gr:hasCurrency><xsl:value-of select="text()" /></gr:hasCurrency>
    </xsl:template>
    
    <xsl:template match="NeboZahajeni_II_3">
        <xsl:if test="text()">
           <xsl:variable name="tidyDate" select="f:processDate(text())" />
           <xsl:if test="$tidyDate">
           <pc:startDate rdf:datatype="xsd:date">
               <xsl:value-of select="$tidyDate" />
           </pc:startDate>
           </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Dokonceni_II_3">
        <xsl:if test="text()">
           <xsl:variable name="tidyDate" select="f:processDate(text())" />
           <xsl:if test="$tidyDate">
           <pc:estimatedEndDate rdf:datatype="xsd:date">
               <xsl:value-of select="$tidyDate" />
           </pc:estimatedEndDate>
           </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Datum_IV_3_4">
        <xsl:if test="text()">
           <xsl:variable name="tidyDateTime" select="f:processDate(text())" />
           <xsl:if test="$tidyDateTime">
           <pc:tenderDeadline rdf:datatype="xsd:dateTime">
               <xsl:value-of select="$tidyDateTime" />
           </pc:tenderDeadline>
           </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Datum_IV_3_3">
        <xsl:if test="text()">
           <xsl:variable name="tidyDateTime" select="f:processDate(text())" />
           <xsl:if test="$tidyDateTime">
           <pc:documentationRequestDeadline rdf:datatype="xsd:dateTime">
               <xsl:value-of select="$tidyDateTime" />
           </pc:documentationRequestDeadline>
           </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="SpisoveCisloPrideleneVerejnymZadavatelem_IV_3_1 | SpisCislo_IV_3_1">
        <adms:identifier>
            <adms:Identifier rdf:about="{$id_pcIdentifier1}">
                <skos:notation><xsl:value-of select="text()" /></skos:notation>
                <dc:creator rdf:resource="{$id_contractingAuthority}" />
                <!--<dc:type rdf:resource="http://purl.org/procurement/public-contracts#ContractIdentifierIssuedByContractingAuthority" /> -->
                <xsl:apply-templates select="$root/UredniNazev_I_1 | $root/Nazev_I_1" mode="schemeAgency" />
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>
    
    <xsl:template match="UredniNazev_I_1 | Nazev_I_1" mode="schemeAgency">
        <adms:schemeAgency><xsl:value-of select="text()" /></adms:schemeAgency>
    </xsl:template>
    
    <xsl:template match="UvedteCenu_IV_3_3">
        <pc:documentsPrice>
            <gr:PriceSpecification rdf:about="{$id_documentsPrice}">
                <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(text())" /></gr:hasCurrencyValue>
                <xsl:apply-templates select="$root/Mena_IV_3_3" />
                <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean">false</gr:valueAddedTaxIncluded>
            </gr:PriceSpecification>
        </pc:documentsPrice>
    </xsl:template>
    
    <xsl:template match="Mena_IV_3_3">
        <gr:hasCurrency><xsl:value-of select="text()" /></gr:hasCurrency>
    </xsl:template>
    
    <xsl:template match="Hodnota_II_2_1">
        <pc:agreedPrice>
            <gr:PriceSpecification rdf:about="{$id_agreedPrice}">
                <gr:hasCurrencyValue><xsl:value-of select="f:processPrice(text())" /></gr:hasCurrencyValue>
                <xsl:apply-templates select="$root/Mena_II_2_1" />
                <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean">false</gr:valueAddedTaxIncluded>
            </gr:PriceSpecification>
        </pc:agreedPrice>
    </xsl:template>
    
    <xsl:template match="Mena_II_2_1">
        <gr:hasCurrency><xsl:value-of select="text()" /></gr:hasCurrency>
    </xsl:template>

    <xsl:template match="ZakazkaNazev_V">
        <gr:legalName><xsl:value-of select="text()" /></gr:legalName>
    </xsl:template>
    
    <xsl:template match="Strucpopis_V_5">
        <dc:description><xsl:value-of select="text()" /></dc:description>
    </xsl:template>
    
    <xsl:template match="PocetNabidek_V_2">
        <pc:numberOfTenders rdf:datatype="xsd:integer"><xsl:value-of select="text()" /></pc:numberOfTenders>
    </xsl:template>

    <xsl:template match="Datum_V_1">
        <xsl:variable name="tidyDate" select="f:processDate(text())" />
        <xsl:if test="$tidyDate">
        <pc:awardDate rdf:datatype="xsd:date"><xsl:value-of select="$tidyDate" /></pc:awardDate>
        </xsl:if>
    </xsl:template>

    <!-- @param date dd/mm/yyyy -->
    <xsl:function name="f:processDate">
        <xsl:param name="date" as="xsd:string" />
        <xsl:analyze-string select="$date" regex="(\d{{2}})/(\d{{2}})/(\d{{4}})">
            <xsl:matching-substring>
                <xsl:variable name="tidyDate" select="concat(regex-group(3), '-', regex-group(2), '-', regex-group(1))" />
                
                <xsl:choose>
                    <xsl:when test="$tidyDate castable as xsd:date">
                        <xsl:value-of select="xsd:date($tidyDate)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- try take off one day -->
                        <xsl:variable name="dayTakeOf" select="concat(regex-group(3), '-', regex-group(2), '-', number(regex-group(1))-1)" />
                        <xsl:if test="$dayTakeOf castable as xsd:date">
                            <xsl:value-of select="xsd:date($dayTakeOf)"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- @param date dd/mm/yyyy -->
    <!-- @param time hh:mm -->
    <xsl:function name="f:processDateTime">
        <xsl:param name="date" as="xsd:string" />
        <xsl:param name="time" as="xsd:string" />
        
        <xsl:variable name="tidyDate" select="f:processDate($date)" />
        
        <xsl:choose>
            <xsl:when  test="$tidyDate">
                <xsl:choose>
                    <xsl:when test="$time">
                        <xsl:value-of select="concat($tidyDate,'T',$time,':00')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($tidyDate,'T00:00:00')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
    <!-- @param root node -->
    <xsl:function name="f:getKind">

        <xsl:param name="kindCat" as="xsd:string" />
        
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
                <xsl:if test="$root/Sluzby_II_1_2"> <!-- form type 3 -->
                    <xsl:if test="string(number($root/Sluzby_II_1_2)) != 'NaN'">
                    <xsl:value-of select="$serviceKinds[xsd:integer($root/Sluzby_II_1_2)]" />
                    </xsl:if>
                </xsl:if>
                <xsl:if test="$root/KategorieSluzeb_II_1_2"> <!-- form type 2 -->
                    <xsl:if test="string(number($root/KategorieSluzeb_II_1_2)) != 'NaN'">
                    <xsl:value-of select="$serviceKinds[xsd:integer($root/KategorieSluzeb_II_1_2)]" />
                    </xsl:if>
                </xsl:if>
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
                
                <xsl:choose>
                    <xsl:when test="$root/Dodavky_II_1_2">
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
    <xsl:function name="f:stripDashes" as="xsd:string">
        <xsl:param name="text" as="xsd:string" />
        
        <xsl:value-of select="substring-before($text,'-')" />
        <!-- 
        <xsl:analyze-string select="$text" regex="(\d*)-.*">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="$text"/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
         -->
        
    </xsl:function>
    
    <!-- @param price string -->
    <xsl:function name="f:processPrice" as="xsd:decimal">
        <xsl:param name="price" as="xsd:string" />

        <xsl:variable name="tidyPrice" select="translate($price,' -.','')" />
        
        <xsl:choose>
            <xsl:when test="contains(substring-after($tidyPrice,','), ',')">
                <xsl:value-of select="translate(substring($tidyPrice,1, index-of(string-to-codepoints($tidyPrice), string-to-codepoints(','))[last()] -1),',','')" />
            </xsl:when>
            <xsl:when test="contains($tidyPrice, ',') and string-length($tidyPrice)>1">
                <xsl:value-of select="(translate(substring-before($tidyPrice,','),',',''),substring-after($tidyPrice,','))" separator="." />       
            </xsl:when>
            <xsl:when test="string(number($tidyPrice)) != 'NaN'">
                <xsl:value-of select="$tidyPrice" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0" />
            </xsl:otherwise>
        </xsl:choose>
        
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
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:getDuration">
        <xsl:param name="value" as="xsd:integer" />
        <xsl:param name="unit" as="xsd:string" />
        
        <xsl:value-of select="concat('P',$value,$unit)" />
        
    </xsl:function>
    
    <xsl:function name="f:slugify" as="xsd:anyURI">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="encode-for-uri(translate(replace(lower-case(normalize-unicode($text, 'NFKD')), '\P{IsBasicLatin}', ''), ' ', '-'))" />
        <!--  <xsl:value-of select="encode-for-uri(translate(replace(lower-case(normalize-space($text)), '\s', '-'),'áàâäéèêëěíìîïóòôöúùûüůýžščřďňť','aaaaeeeeeiiiioooouuuuuyzscrdnt'))"/>-->
    </xsl:function>
    
</xsl:stylesheet>