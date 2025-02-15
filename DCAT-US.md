# DCAT-US - mdTranslator proposed mappings
## Quick references
  - DCAT-US [element definitions](https://resources.data.gov/resources/dcat-us/)
  - DCAT-US v1.1 [catalog.json schema](https://resources.data.gov/schemas/dcat-us/v1.1/schema/catalog.json)
  - DCAT-US v1.1 [dataset.json schema](https://resources.data.gov/schemas/dcat-us/v1.1/schema/dataset.json)
  - DCAT-US v1.1 [JSON-LD catalog.json schema](https://resources.data.gov/schemas/dcat-us/v1.1/schema/catalog.jsonld)
  - [Element crosswalks](https://resources.data.gov/resources/podm-field-mapping/#field-mappings) to other standards

## DCAT-US - mdTranslator

### Always (always required)

| Field Name | DCAT Name | Condition | mdJson Source |
| --- | --- | --- | --- |
| Title | title | exists | citation.title |
| Description | description | exists | resourceInfo.abstract |
| Tags | keyword | exists | [resourceInfo.keyword.keyword[0, n] *flatten*] |
| Last Update | modified | if resourceInfo.citation.date[any].dateType = "lastUpdated" or "lastRevised" or "revision" | resourceInfo.citation.date[most recent] |
| Publisher | publisher{name} | if citation.responsibleParty.[any].role = "publisher" |  contactId -> contact.name where isOrganization IS TRUE |
| | | if exists resourceDistribution.distributor.contact | [first contact] contactId -> contact.name where isOrganization IS TRUE |
| Publisher Parent Organization | publisher{subOrganizationOf} | if citation.responsibleParty[any].role = "publisher" and exists contactId -> memberOfOrganization[0] and isOrganization is true | contactId -> contact.name |
| | | if exists resourceDistribution.distributor.contact and exists contactId -> memberOfOrganization[0] and isOrganization IS TRUE | contactId -> contact.name |
| Contact Name | contactPoint{fn} | exists | resourceInfo.pointOfContact.parties[0].contactId -> contact.name |
| Contact Email | contactPoint{email} | exists | resourceInfo.pointOfContact.parties[0].contactId -> contact.eMailList[0] |
| Unique Identifier | identifier | if resourceInfo.citation.identifier.namespace = "DOI" | resourceInfo.citation.onlineResource.uri |
| | | if "DOI" within resourceInfo.citation.onlineResource.uri | resourceInfo.citation.onlineResource.uri |
| Public Access Level | accessLevel | [*extend codelist MD_RestrictionCode to include "public",  "restricted  public", "non-public"*] <br> if resourceInfo.constraints.legal[any] one of {"public", "restricted public", "non-public"} | resourceInfo.constraints.legal[first]. Also resourceInfo.constraint.security.classification [[MD_ClassificationCode](https://mdtools.adiwg.org/#codes-page?c=iso_classification)] |
| Bureau Code | bureauCode | | [*extend role codelist to include "bureau", extend namespace codelist to include "bureauCode"*] <br> for each resourceInfo.citation.responsibleParty[any] role = "bureau" <br>contactId -> contact.identifier [*identifier must conform to https://resources.data.gov/schemas/dcat-us/v1.1/omb_bureau_codes.csv*] |
| Program Code | programCode | | [*add new element of program resourceInfo.programCode, add new codelist of programCode*] <br> resourceInfo.program[0,n] |

### If-Applicable (required if it exists)

| Field Name | DCAT Name | Condition | mdJson Source |
| --- | --- | --- | --- |
| Distribution | distribution | if exists resourceDistribution[any] and if exists resourceDistribution.distributor[any].transferOption[any].onlineOption[any].uri <br> for each resourceDistribution[0, n] where exists resourceDistribution.distributor.transferOption.onlineOption.uri then <br> {description, accessURL, downloadURL, mediaType, title} |
| - Description | distribution.description | exists | resourceDistribution.description |
| - AccessURL | distribution.accessURL | if citation.onlineResources[first occurence].uri [path ends in ".html"] [*required if applicable*] | resourceDistribution.distributor.transferOption.onlineOption.uri |
| - DownloadURL | dcat.distribution.downloadURL | if citation.onlineResources[first occurence].uri [path does not end in ".html"] [*required if applicable*] |resourceDistribution.distributor.transferOption.onlineOption.uri |
| - MediaType | distribution.mediaType | [*add codelist of "dataFormat"*] <br> transferOption.distributionFormat.formatSpecification.title [dataFormat] [*dataFormat should conform to: https://www.iana.org/assignments/media-types/media-types.xhtml*] |
| - Title | distribution.title | exists | resourceDistribution.distributor.transferOption.onlineOption.name |
| License | license | [*add resourceInfo.constraint.reference to mdEditor*] <br> if exists resourceInfo.constraint.reference[0] | resourceInfo.constraint.reference[0] <br> |
| | | else | https://creativecommons.org/publicdomain/zero/1.0/ <br> [*allows author to identify a license to use, or default to CC0 if none provided, CC0 would cover international usage as opposed to publicdomain*] <br> [*others: http://www.usa.gov/publicdomain/label/1.0/, http://opendatacommons.org/licenses/pddl/1.0*] |
| Rights | rights | if constraint.accessLevel in {"restricted public", "non-public"} | resourceInfo.constraint.releasibility.statement + " " + each constraint.releasibility.dessiminationConstraint[0, n] |
| Endpoint | *removed* | *ignored* | *ignored* |
| Spatial | spatial | if exists resourceInfo.extents[0].geographicExtents[0].boundingBox | boundingBox.eastLongitude + "," + boundingBox.southLatitude + "," + boundingBox.westLongitude + "," + boundingBox.northLatitude [*decimal degrees*] |
| | | else | if exists resourceInfo.extents[0].geographicExtents[0].geographicElement[0].type = "point" then <br> geographicElement[0].coordinate[1] + "," + geographicElement[0].coordinate[0] [*lat, long decimal degrees*] |
| Temporal | temporal | if exists resourceInfo.extent[0].temporalExtent[0] then <br> if exists tempororalExtent[0].timePeriod.startDate and exists temporaralExtent[0].timePeriod.endDate | timePeriod[0].startDate + "/" + timePeriod.endDate |
| | | if exists  tempororalExtent[0].timePeriod.startDate and not exists temporaralExtent[0].timePeriod.endDate | tempororalExtent[0].timePeriod.startDate |
| | | if not exists temporalExtent[0].timePeriod.startDate and exists temporaralExtent[0].timePeriod.endDate | tempororalExtent[0].timePeriod.endDate <br> [*may need revisiting relative to decision on date only formatting*] |

### No (not required)

| Field Name | DCAT Name | Condition | mdJson Source |
| --- | --- | --- | --- |
| Release Date | issued | if resourceInfo.citation.date[any].dateType = "publication" or "distributed" | resourceInfo.citation.date[earliest] |
| Frequency | accrualPeriodicity | | [*ISO codelist MD_maintenanceFrequency can be used and several codes intersect with accrualPeriod codelist they are partially corresponding. A column of ISO8601 code equivalents could be added to MD_maintenanceFrequency to provide the coding expected https://resources.data.gov/schemas/dcat-us/v1.1/iso8601_guidance/#accrualperiodicity, community valuation should be determined*]  |
| Language | language | | [*language codelist could be used but needs to be bound with country corresponding to the RFC 5646 format https://datatracker.ietf.org/doc/html/rfc5646, such as "en-US", community valuation should be determined* |
| Data Quality | dataQuality | | [*this is a boolean to indicate whether data "conforms" to agency standards, value seems negligble*] |
| Category | theme | where resourceInfo.keyword[any].thesaurus.title = "ISO Topic Category" | [resourceInfo.keyword.keyword[0, n] *flatten*]  |
| Related Documents | references | | associatedResource[all].resourceCitation.onlineResource[all].uri + additionalDocumentation[all].citation[all].onlineResource[all].uri [*comma separated*]|
| Homepage URL | landingPage | [*Add code "landingPage" to CI_OnlineFunctionCode*] <br> if resourceInfo.citation.onlineResource[any].function = "landingPage" | resourceInfo.citation.onlineResource.uri |
| Collection | isPartOf | for each associatedResource[0, n].initiativeType = "collection" and associatedResource.associationType = "collectiveTitle" | associatedResource.resourceCitation[0].uri |
| System of Records | systemOfRecords | [*Add code "sorn" to DS_InitiativeTypeCode*] <br> for each associatedResource[0, n].initiativeType = "sorn"   | associatedResource.resourceCitation[0].uri |
| Primary IT Investment | primaryITInvestmentUII | | [*Links data to an IT investment identifier relative to Exhibit 53 docs, community valuation should be determined*] |
| Data Dictionary | describedBy | if dataDictionary.dictionaryIncludedWithResource IS NOT TRUE and citation.onlineResource[0].uri exists | dataDictionary.citation.onlineResource[0].uri |
| Data Dictionary Type | describedByType | | [*For simplicity, leave blank implying html page, community decision needed whether to support other format types using mime type and in the form of "application/pdf"*]|
| Data Standard | conformsTo | | [*Currently not able to identify the schema standard the data conforms to, though this has been proposed. Should this be built and there is community decision to support it, then it can be mapped*] |
