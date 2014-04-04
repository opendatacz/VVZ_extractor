VVZ extractor DPU for ODCleanStore
==================================

VVZ extractor cooperates via SOAP with vestnikverejnychzakazek.cz (VVZ).
At first, extractor will send soap request to VVZ for getting public contracts list, which want process.
Request contains userID, which extractor has assigned in PCReceiver class in his source code. UserID has been acquired by registration in the VVZ.

Soap request further contains query parameters, which specify what public contracts forms extractor want.
The parameters include date from and date to, which specifies period in which public contracts have been published.
If date from or date to is not present, extractor will process all public contracts to the past or to the future.
When extractor get public contracts list, which contains identificators of individual contracts, he will start sending requests for each form from the given list.
Received form has XML format and must be transformed to RDF/XML.

using:

Public contracts receiver
-------------------------
Receiving public contracts from vestnikverejnychzakazek.cz using SOAP Web Services.

XSLT for public contract form
-----------------------------
Transformation from XML TO RDF/XML.
Transform form type 2 - public contract notation.


XML interface and XML Schema for public contract notation form can be found [here](http://www.vestnikverejnychzakazek.cz/cs/PublishAForm/XMLInterfaceForISVZUS)
