# unpack time interval
# Reader - ADIwg JSON to internal data structure

# History:
#  Stan Smith 2018-02-19 refactored error and warning messaging
#  Stan Smith 2017-11-07 add geologic age
# 	Stan Smith 2016-10-14 original script

require_relative 'module_dateTime'
require_relative 'module_identifier'
require_relative 'module_geologicAge'
require_relative 'module_timeInterval'
require_relative 'module_duration'

module ADIWG
   module Mdtranslator
      module Readers
         module MdJson

            module TimePeriod

               def self.unpack(hTimePeriod, responseObj)

                  # return nil object if input is empty
                  if hTimePeriod.empty?
                     responseObj[:readerExecutionMessages] << 'WARNING: mdJson reader: time period object is empty'
                     return nil
                  end

                  # instance classes needed in script
                  intMetadataClass = InternalMetadata.new
                  intTimePer = intMetadataClass.newTimePeriod

                  haveTime = false

                  # time period - id
                  if hTimePeriod.has_key?('id')
                     unless hTimePeriod['id'] == ''
                        intTimePer[:timeId] = hTimePeriod['id']
                     end
                  end

                  # time period - description
                  if hTimePeriod.has_key?('description')
                     unless hTimePeriod['description'] == ''
                        intTimePer[:description] = hTimePeriod['description']
                     end
                  end

                  # time period - identifier {Identifier}
                  if hTimePeriod.has_key?('identifier')
                     unless hTimePeriod['identifier'].empty?
                        hReturn = Identifier.unpack(hTimePeriod['identifier'], responseObj)
                        unless hReturn.nil?
                           intTimePer[:identifier] = hReturn
                        end
                     end
                  end

                  # time period - period names []
                  if hTimePeriod.has_key?('periodName')
                     hTimePeriod['periodName'].each do |item|
                        unless item == ''
                           intTimePer[:periodNames] << item
                        end
                     end
                  end

                  # time period - start datetime (required if)
                  if hTimePeriod.has_key?('startDateTime')
                     unless hTimePeriod['startDateTime'] == ''
                        hReturn = DateTime.unpack(hTimePeriod['startDateTime'], responseObj)
                        unless hReturn.nil?
                           intTimePer[:startDateTime] = hReturn
                           haveTime = true
                        end
                     end
                  end

                  # time period - end datetime (required if)
                  if hTimePeriod.has_key?('endDateTime')
                     unless hTimePeriod['endDateTime'] == ''
                        hReturn = DateTime.unpack(hTimePeriod['endDateTime'], responseObj)
                        unless hReturn.nil?
                           intTimePer[:endDateTime] = hReturn
                           haveTime = true
                        end
                     end
                  end

                  # time period - start geologic age (required if)
                  if hTimePeriod.has_key?('startGeologicAge')
                     unless hTimePeriod['startGeologicAge'].empty?
                        hReturn = GeologicAge.unpack(hTimePeriod['startGeologicAge'], responseObj)
                        unless hReturn.nil?
                           intTimePer[:startGeologicAge] = hReturn
                           haveTime = true
                        end
                     end
                  end

                  # time period - end geologic age (required if)
                  if hTimePeriod.has_key?('endGeologicAge')
                     unless hTimePeriod['endGeologicAge'].empty?
                        hReturn = GeologicAge.unpack(hTimePeriod['endGeologicAge'], responseObj)
                        unless hReturn.nil?
                           intTimePer[:endGeologicAge] = hReturn
                           haveTime = true
                        end
                     end
                  end

                  # error messages
                  unless haveTime
                     responseObj[:readerExecutionMessages] <<
                        'ERROR: mdJson reader: time period must have a start and/or end dateTime, or geologic age'
                     responseObj[:readerExecutionPass] = false
                     return nil
                  end

                  # time period - time interval
                  # time interval must have a start and/or end time
                  if hTimePeriod.has_key?('timeInterval')
                     unless hTimePeriod['timeInterval'].empty?
                        hReturn = TimeInterval.unpack(hTimePeriod['timeInterval'], responseObj)
                        unless hReturn.nil?
                           intTimePer[:timeInterval] = hReturn
                        end
                     end
                     if intTimePer[:startDateTime].empty? && intTimePer[:endDateTime].empty?
                        responseObj[:readerExecutionMessages] <<
                           'ERROR: mdJson reader: time interval must be accompanied by a start and/or end dateTime'
                        responseObj[:readerExecutionPass] = false
                        return nil
                     end
                  end

                  # time period - time duration
                  # duration must have a start and/or end time
                  if hTimePeriod.has_key?('duration')
                     unless hTimePeriod['duration'].empty?
                        hReturn = Duration.unpack(hTimePeriod['duration'], responseObj)
                        unless hReturn.nil?
                           intTimePer[:duration] = hReturn
                        end
                     end
                     if intTimePer[:startDateTime].empty? && intTimePer[:endDateTime].empty?
                        responseObj[:readerExecutionMessages] <<
                           'ERROR: mdJson reader: duration must be accompanied by a start and/or end dateTime'
                        responseObj[:readerExecutionPass] = false
                        return nil
                     end
                  end

                  return intTimePer

               end

            end

         end
      end
   end
end
