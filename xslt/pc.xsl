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
    <xsl:import href="functions.xsl" />
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC" />

    <xsl:variable name="nm_lod">http://linked.opendata.cz/resource/</xsl:variable>
	<xsl:variable name="nm_vvz" select="concat($nm_lod, 'vestnikverejnychzakazek.cz/')"/>
    <xsl:variable name="nm_vvz_pc" select="concat($nm_vvz, 'public-contract/')"/>
    <xsl:variable name="nm_cpv" select="concat($nm_lod,'cpv-2008/concept/')" />
    <xsl:variable name="nm_pcCriteria">http://purl.org/procurement/public-contracts-criteria/</xsl:variable>
    <xsl:variable name="schemeAgency">Ministerstvo pro místní rozvoj</xsl:variable>
    <xsl:variable name="creator">http://linked.opendata.cz/resource/business-entity/CZ66002222</xsl:variable>
    
    <xsl:variable name="root" select="root" />
    
    <xsl:variable name="VVZ_FormId" select="$root/skup_priloha/hlavicka/VvzFormId" />
    <xsl:variable name="VVZ_FormNumber">
        <xsl:choose>
            <xsl:when test="$root/skup_priloha/hlavicka/VvzNumber != ''">
                <xsl:value-of select="$root/skup_priloha/hlavicka/VvzNumber" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="uuid:get-uuid()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="VVZ_PCNumber">
        <xsl:choose>
            <xsl:when test="$root/skup_priloha/hlavicka/CocoCode != ''">
                <xsl:value-of select="$root/skup_priloha/hlavicka/CocoCode" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="uuid:get-uuid()" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="VVZ_SubmitterIC">
        <!-- ICO can be found in two places -->
        <xsl:choose>
            <xsl:when test="$root/Ic_I_1/text()">
                <xsl:value-of select="f:processIC($root/Ic_I_1,$VVZ_FormNumber)" />
            </xsl:when>
            <xsl:when test="$root/skup_priloha/hlavicka/IcoZadavatel/text()">
                <xsl:value-of select="f:processIC($root/skup_priloha/hlavicka/IcoZadavatel,$VVZ_FormNumber)" />
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

    <xsl:variable name="PC_URI" select="concat($nm_vvz_pc,$VVZ_PCNumber,'-',$VVZ_FormNumber)" />
    
    <!-- IDENTIFIERS -->
    <xsl:variable name="id_contractNotice" select="concat($nm_vvz,'contract-notice/',$VVZ_FormNumber)" />
    <xsl:variable name="id_contractNoticeIdentifier" select="concat($nm_vvz,'contract-notice/',$VVZ_FormNumber,'/identifier/1')" />
    <xsl:variable name="id_publicContract" select="$PC_URI" />
    <xsl:variable name="nm_publicContractLot" select="concat($PC_URI,'/lot/')" />
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
    <xsl:variable name="nm_lotEstimatedPrice" select="concat($PC_URI,'/lot-estimated-price/')" />
    <xsl:variable name="id_awardCriteriaCombination" select="concat($PC_URI,'/combination-of-contract-award-criteria/')" />
    <xsl:variable name="nm_contractAwardCriterion" select="concat($PC_URI,'/contract-award-criterion/')" />
    <xsl:variable name="nm_publicContractCriteria" select="concat($PC_URI,'/public-contract-criteria/')" />
    <xsl:variable name="id_pcIdentifier1" select="concat($PC_URI,'/identifier/1')" />
    <xsl:variable name="id_pcIdentifier2" select="concat($PC_URI,'/identifier/2')" />
    <xsl:variable name="id_contractingAuthAddress" select="concat($PC_URI,'/postal-address/1')" />
    <xsl:variable name="nm_behalfOfAddress" select="concat($PC_URI,'/behalf-of-postal-address/')" />
    <xsl:variable name="id_documentsPrice" select="concat($PC_URI,'/documents-price/1')" />
    <xsl:variable name="id_agreedPrice" select="concat($PC_URI,'/agreed-price/1')" />
    <xsl:variable name="id_activityKind" select="concat($PC_URI,'/activity-kind/1')" />
    <xsl:variable name="id_authorityKind" select="concat($PC_URI,'/authority-kind/1')" />
    
    <xsl:template match="root[verze_formulare='0200' or verze_formulare='0300']">
	    
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

	            <pc:publicNotice rdf:resource="{$id_contractNotice}" />
	            
	            <xsl:apply-templates select=".[UvedtePredpokladanouHodnotuBezDph_II_2_1 | RozsahOd_II_2_1 | RozsahDo_II_2_1]" mode="pcEstimatedPrice" />
	            
	            <pc:awardCriteriaCombination>
                    <pc:AwardCriteriaCombination rdf:about="{$id_awardCriteriaCombination}">
                        <!-- nejnizsi cenova nabidka - NejnizsiNabidkovaCena_IV_2_1 form type 2 | KriteriaTyp_IV_2_1 form type 3 -->
                        <xsl:apply-templates select="NejnizsiNabidkovaCena_IV_2_1 | KriteriaTyp_IV_2_1 | Kriteria1_IV_2_1 | Kriteria2_IV_2_1 | Kriteria3_IV_2_1 | Kriteria4_IV_2_1 | Kriteria5_IV_2_1 | Kriteria6_IV_2_1 | Kriteria7_IV_2_1 | Kriteria8_IV_2_1 | Kriteria9_IV_2_1 | Kriteria10_IV_2_1" />
                    </pc:AwardCriteriaCombination>
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
	            
	            <!-- information about parts of contract -->
	            <xsl:apply-templates select="skup_priloha/priloha_B" />
	            
	            <!-- behalf of -->
	            <xsl:apply-templates select="skup_priloha/priloha_A/skup_priloha/oddil_4" />
	            
	            
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
	                            <xsl:when test="skup_priloha/hlavicka/IcoDodavatel/text()">
	                                <xsl:value-of select="concat($nm_businessEntity, f:processIC(skup_priloha/hlavicka/IcoDodavatel,$VVZ_FormNumber))" />
	                            </xsl:when>
	                            <xsl:when test="skup_priloha/oddil_5/NazevDodavatele_V_3/text()">
	                                <xsl:value-of select="concat($nm_businessEntity, f:slugify(skup_priloha/oddil_5/NazevDodavatele_V_3), '-', $VVZ_FormNumber)" />
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
	    
	       
	</xsl:template>
    
    <xsl:template match="oddil_4">
        
        <xsl:variable name="submitterIC">
            <!-- ICO can be found in two places -->
            <xsl:choose>
                <xsl:when test="Ico_IV/text()">
                    <xsl:value-of select="f:processIC(Ico_IV,$VVZ_FormNumber)" />
                </xsl:when>
                <xsl:when test="UredniNazev_IV/text()">
                    <xsl:value-of select="concat(f:slugify(UredniNazev_IV),'-',$VVZ_FormNumber)" />
                </xsl:when>
                <xsl:otherwise>
                    <!-- make UUID -->
                    <xsl:value-of select="concat(uuid:get-uuid(),'-',$VVZ_FormNumber)" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <pc:onBehalfOf>
            <gr:BusinessEntity rdf:about="{concat($nm_businessEntity,$submitterIC)}">
                <xsl:apply-templates select="UredniNazev_IV" mode="legalName" />
                <xsl:apply-templates select=".[Adresa_IV | Psc_IV | Obec_IV | Stat_IV]" mode="contractingAuthorityAddress" />
            </gr:BusinessEntity>
        </pc:onBehalfOf>
        
    </xsl:template>
    
    <xsl:template match="priloha_B">
        
        <xsl:variable name="count" as="xsd:integer">
            <xsl:number/>
        </xsl:variable>
        
        <pc:lot>
            <pc:Contract rdf:about="{concat($nm_publicContractLot,$count)}">
                <xsl:apply-templates select="Nazev_0_0 | StrucnyPopis_1" />
                
                <xsl:apply-templates select="HlavniSlovnikHp_2 | HlavniSlovnikDp1_2 | HlavniSlovnikDp2_2 | HlavniSlovnikDp3_2 | HlavniSlovnikDp4_2" />
                
                <xsl:apply-templates select="PredpokladaneDatumZahajeniStavebnichPraci_4 | PredpokladaneDatumDokonceniStavebnichPraci_4" />

                <xsl:apply-templates select=".[OdhadovanaHodnotaBezDph_3 | RozsahOd_3 | RozsahDo_3]" mode="pcEstimatedPrice" />
                
                <xsl:apply-templates select="DobaTrvaniVMesicich_4 | Dnech_4" />
                
            </pc:Contract>
        </pc:lot>
        
    </xsl:template>
    
    <xsl:template match="priloha_B" mode="pcEstimatedPrice">
        <xsl:variable name="count" as="xsd:integer">
            <xsl:number/>
        </xsl:variable>
        
        <pc:estimatedPrice>
            <gr:PriceSpecification rdf:about="{concat($nm_lotEstimatedPrice,$count)}">
                <xsl:apply-templates select="OdhadovanaHodnotaBezDph_3 | RozsahOd_3 | RozsahDo_3 | MenaRozsah_3 | MenaOdhadovanaHodnota_3" />
                <gr:valueAddedTaxIncluded rdf:datatype="xsd:boolean">false</gr:valueAddedTaxIncluded>
            </gr:PriceSpecification>
        </pc:estimatedPrice>
    </xsl:template>
    
    <xsl:template match="oddil_4" mode="contractingAuthorityAddress">
        
        <xsl:variable name="count" as="xsd:integer">
            <xsl:number/>
        </xsl:variable>
        
        <s:address>
            <s:PostalAddress rdf:about="{concat($nm_behalfOfAddress,$count)}">
                <xsl:apply-templates select="Adresa_IV | Psc_IV | Obec_IV | Stat_IV" />
            </s:PostalAddress>
        </s:address>
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
                <xsl:apply-templates select="UvedtePredpokladanouHodnotuBezDph_II_2_1 | RozsahOd_II_2_1 | RozsahDo_II_2_1 | MenaHodnota_II_2_1 | MenaRozsah_II_1_4" />
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
            <adms:Identifier rdf:about="{$id_contractNoticeIdentifier}">
                <skos:notation>
                    <xsl:value-of select="$VVZ_FormNumber" />
                </skos:notation>
                <adms:schemeAgency>
                    <xsl:value-of select="$schemeAgency" />
                </adms:schemeAgency>
                <dc:creator rdf:resource="{$creator}" />
            </adms:Identifier>
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
    
    <xsl:template match="VMesicich_II_3 | DobaTrvaniVMesicich_4">
        <pc:duration rdf:datatype="xsd:duration">
            <xsl:value-of select="f:getDuration(text(),'M')" />
        </pc:duration>
    </xsl:template>
    
    <xsl:template match="NeboDnech_II_3 | Dnech_4">
        <pc:duration rdf:datatype="xsd:duration">
            <xsl:value-of select="f:getDuration(text(),'D')" />
        </pc:duration>
    </xsl:template>
    
    <xsl:template match="NazevDodavatele_V_3" mode="businessEntity">
        <xsl:if test="text()">
        <gr:legalName><xsl:value-of select="text()" /></gr:legalName>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="AdresaURL_V_3">
        <xsl:if test="text()">
        <foaf:page rdf:resource="{text()}" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="NazevDodavatele_V_3" mode="contactPoint">
        <s:name><xsl:value-of select="text()" /></s:name>
    </xsl:template>
    
    <xsl:template match="Email_V_3">
        <s:email><xsl:value-of select="text()" /></s:email>
    </xsl:template>
    
    <xsl:template match="Telefon_V_3">
        <s:telephone><xsl:value-of select="text()" /></s:telephone>
    </xsl:template>
    
    <xsl:template match="Fax_V_3">
        <s:faxNumber><xsl:value-of select="text()" /></s:faxNumber>
    </xsl:template>
    
    <xsl:template match="Adresa_V_3">
        <xsl:if test="text()">
        <s:streetAddress><xsl:value-of select="text()" /></s:streetAddress>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Psc_V_3">
        <s:postalCode><xsl:value-of select="text()" /></s:postalCode>
    </xsl:template>
    
    <xsl:template match="Obec_V_3">
        <xsl:if test="text()">
        <s:addressLocality><xsl:value-of select="text()" /></s:addressLocality>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Stat_V_3">
        <xsl:if test="text()">
        <s:addressCountry><xsl:value-of select="text()" /></s:addressCountry>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="KontaktniMista_I_1">
        <xsl:if test="text()">
        <s:description xml:lang="cs">
            <xsl:value-of select="text()" />
        </s:description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="KRukam_I_1">
        <s:name>
            <xsl:value-of select="text()" />
        </s:name>
    </xsl:template>
    
    <xsl:template match="E_Mail_I_1">
        <s:email><xsl:value-of select="text()" /></s:email>
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
            <skos:Concept rdf:about="{$id_activityKind}">
                <skos:prefLabel><xsl:value-of select="text()" /></skos:prefLabel>
                <skos:isScheme rdf:resource="http://purl.org/procurement/public-contracts-activities#" />
                <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-activities#" />
            </skos:Concept>
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
    <xsl:template match="HlavniSlovnikDp1_II_1_6 | HlavniSlovnikDp2_II_1_6 | HlavniSlovnikDp3_II_1_6 | HlavniSlovnikDp4_II_1_6 | HlavniSlovnikDp1_II_1_5 | 
                         HlavniSlovnikDp2_II_1_5 | HlavniSlovnikDp3_II_1_5 | HlavniSlovnikDp4_II_1_5 | HlavniSlovnikDp1_2 | HlavniSlovnikDp2_2 | HlavniSlovnikDp3_2 | HlavniSlovnikDp4_2">
        <xsl:if test="text()">
        <pc:additionalObject rdf:resource="{concat($nm_cpv,f:stripDashes(text()))}" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="NazevPridelenyZakazce_II_1_1 | NazevPridelenyZakazceVerejnymZadavatelem_II_1_1 | Nazev_0_0">
        <xsl:if test="text()">
        <dc:title xml:lang="cs">
            <xsl:value-of select="text()" />
        </dc:title> 
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="StrucnyPopisZakazky_II_1_5 | StrucnyPopis_II1_4 | StrucnyPopis_1">
        <xsl:if test="text()">
        <dc:description xml:lang="cs">
            <xsl:value-of select="text()" />
        </dc:description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="DruhZakazkyAMistoProvadeniStavebnichPraci_II_1_2 | DruhZakazky_II_1_2">
        <xsl:if test="text()">
            <xsl:variable name="kind" select="f:getKind(text(),$root)" />
            <xsl:if test="$kind!=''">
                <pc:kind rdf:resource="{$kind}" />
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="UredniNazev_I_1 | Nazev_I_1 | UredniNazev_IV" mode="legalName">
        <xsl:if test="text()">
        <gr:legalName xml:lang="cs">
            <xsl:value-of select="text()" />
        </gr:legalName>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="ObecnaAdresaVerejnehoZadavatele_I_1">
        <xsl:if test="text()">
        <foaf:page rdf:resource="{text()}" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="AdresaProfiluKupujiciho_I_1">
        <xsl:if test="text()">
        <pc:profile rdf:resource="{text()}" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="AdresaProfiluZadavatele_I_1">
        <xsl:if test="text()">
        <pc:profile rdf:resource="{text()}" />
        </xsl:if>
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
            <skos:Concept rdf:about="{$id_authorityKind}">
                <skos:inScheme rdf:resource="http://purl.org/procurement/public-contracts-authority-kinds#" />
                <skos:topConceptOf rdf:resource="http://purl.org/procurement/public-contracts-authority-kinds#"></skos:topConceptOf>
                <skos:prefLabel xml:lang="cs">
                    <xsl:value-of select="text()" />
                </skos:prefLabel>
            </skos:Concept>
        </pc:authorityKind>
    </xsl:template>

    <xsl:template match="DruhRizeni_IV_1_1">
        <xsl:if test="text()">
        <pc:procedureType rdf:resource="{f:getProcedureType(text())}" />
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="PostovniAdresa_I_1 | Adresa_I_1 | Adresa_IV">
        <xsl:if test="text()">
        <s:streetAddress><xsl:value-of select="text()" /></s:streetAddress>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Psc_I_1 | Psc_IV">
        <xsl:if test="text()">
        <s:postalCode><xsl:value-of select="text()" /></s:postalCode>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Obec_I_1 | Obec_IV">
        <xsl:if test="text()">
        <s:addressLocality><xsl:value-of select="text()" /></s:addressLocality>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Stat_I_1 | Stat_IV">
        <xsl:if test="text()">
        <s:addressCountry><xsl:value-of select="text()" /></s:addressCountry>
        </xsl:if>
    </xsl:template>

    <xsl:template match="HlavniSlovnikHp_II_1_6 | HlavniSlovnikHp_II_1_5 | HlavniSlovnikHp_2">
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
    
    <xsl:template match="UvedtePredpokladanouHodnotuBezDph_II_2_1 | OdhadovanaHodnotaBezDph_3">
        <gr:hasCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(text())" /></gr:hasCurrencyValue>
    </xsl:template>
    
    <xsl:template match="RozsahOd_II_2_1 | RozsahOd_3">
        <gr:hasMinCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(text())" /></gr:hasMinCurrencyValue>
    </xsl:template>
    
    <xsl:template match="RozsahDo_II_2_1 | RozsahDo_3">
        <gr:hasMaxCurrencyValue rdf:datatype="xsd:decimal"><xsl:value-of select="f:processPrice(text())" /></gr:hasMaxCurrencyValue>
    </xsl:template>
    
    <xsl:template match="MenaHodnota_II_2_1 | MenaRozsah_II_1_4 | MenaRozsah_3 | MenaOdhadovanaHodnota_3">
        <gr:hasCurrency><xsl:value-of select="text()" /></gr:hasCurrency>
    </xsl:template>
    
    <xsl:template match="NeboZahajeni_II_3 | PredpokladaneDatumZahajeniStavebnichPraci_4">
        <xsl:if test="text()">
           <xsl:variable name="tidyDate" select="f:processDate(text())" />
           <xsl:if test="$tidyDate">
           <pc:startDate rdf:datatype="xsd:date">
               <xsl:value-of select="$tidyDate" />
           </pc:startDate>
           </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Dokonceni_II_3 | PredpokladaneDatumDokonceniStavebnichPraci_4">
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
                <xsl:if test="text()">
                <skos:notation><xsl:value-of select="text()" /></skos:notation>
                </xsl:if>
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
        <xsl:if test="text()">
        <gr:legalName><xsl:value-of select="text()" /></gr:legalName>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="Strucpopis_V_5">
        <xsl:if test="text()">
        <dc:description><xsl:value-of select="text()" /></dc:description>
        </xsl:if>
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
    
</xsl:stylesheet>