# Reader - fgdc to internal data structure
# unpack fgdc methodology

# History:
#  Stan Smith 2017-12-19 original script

require 'nokogiri'
require_relative 'module_fgdc'
require_relative 'module_keyword'
require_relative 'module_citation'

module ADIWG
   module Mdtranslator
      module Readers
         module Fgdc

            module Method

               def self.unpack(hLineage, xMethod, hResponseObj)

                  intObj = Fgdc.get_intObj
                  hResourceInfo = intObj[:metadata][:resourceInfo]

                  intMetadataClass = InternalMetadata.new
                  hProcessStep = intMetadataClass.newProcessStep

                  # methodology bio (methtype) - method type (not supported)

                  # methodology bio (methodid) - method identifier [] {keyword}
                  axKeywords = xMethod.xpath('./methodid')
                  unless axKeywords.empty?
                     axKeywords.each do |xKeyword|
                        Keyword.unpack(xKeyword, hResourceInfo, hResponseObj)
                     end
                  end

                  # methodology bio (methdesc) - method description (required)
                  description = xMethod.xpath('./methdesc').text
                  unless description.empty?
                     hProcessStep[:description] = description
                  end
                  if description.empty?
                     hResponseObj[:readerExecutionMessages] << 'WARNING: FGDC reader: BIO lineage methodology description is missing'
                  end

                  # methodology bio (methcite) - method citation [] {citation}
                  axCitations = xMethod.xpath('./methcite')
                  unless axCitations.empty?
                     axCitations.each do |xCitation|
                        hReturn = Citation.unpack(xCitation, hResponseObj)
                        unless hReturn.nil?
                           hProcessStep[:references] << hReturn
                        end
                     end
                  end

                  return hProcessStep
               end
            end

         end
      end
   end
end
