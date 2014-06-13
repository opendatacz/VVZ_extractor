<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://opendata.cz/xslt/functions#"
    
    version="2.0">
    
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
        <xsl:param name="root" />
        
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
            <xsl:when test="matches($type,'NEGOTIATED_WITH_COMPETITION')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#NegotiatedWithCompetition'" />
            </xsl:when>
            <xsl:when test="matches($type,'NEGOTIATED_WITHOUT_COMPETITION')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#NegotiatedWithoutCompetition'" />
            </xsl:when>
            <xsl:when test="matches($type,'AWARD_WITHOUT_PRIOR_PUBLICATION')">
                <xsl:value-of select="'http://purl.org/procurement/public-contracts-procedure-types#AwardWithoutPriorPublication'" />
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
    
    
    <!--
    The MIT License (MIT)
    
    Copyright (c) 2013 Jiří Skuhrovec, Martin Nečaský
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
    -->
    <xsl:function name="f:validateIC" as="xsd:boolean">
        <xsl:param name="ic" />
        
        <xsl:choose>
            
            <xsl:when test="string-length($ic) = 0">
                <xsl:value-of select="false()" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="$ic" regex="^([0-9])([0-9])([0-9])([0-9])([0-9])([0-9])([0-9])([0-9])$">		
                    <xsl:matching-substring>
                        
                        <xsl:variable name="n8" select="number(regex-group(1))" />
                        <xsl:variable name="n7" select="number(regex-group(2))" />
                        <xsl:variable name="n6" select="number(regex-group(3))" />
                        <xsl:variable name="n5" select="number(regex-group(4))" />
                        <xsl:variable name="n4" select="number(regex-group(5))" />
                        <xsl:variable name="n3" select="number(regex-group(6))" />
                        <xsl:variable name="n2" select="number(regex-group(7))" />
                        <xsl:variable name="checkNumber" select="number(regex-group(8))" />
                        
                        <xsl:variable name="checkSum" select="$n8*8 + $n7*7 + $n6*6 + $n5*5 + $n4*4 + $n3*3 + $n2*2" />
                        
                        <xsl:variable name="checkSumMod" select="(11 - ($checkSum mod 11)) mod 10" />
                        
                        <xsl:choose>
                            <xsl:when test="$checkNumber = $checkSumMod">
                                <xsl:value-of select="true()" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="false()" />
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="false()" />
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    
</xsl:stylesheet>