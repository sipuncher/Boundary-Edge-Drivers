-- Copyright 2022 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local log = require "log"

--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version=4 })
--- @type st.zwave.CommandClass.WakeUp
local WakeUp = (require "st.zwave.CommandClass.WakeUp")({ version = 1 })
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})

local devices = {
  BOUNDARY_SIREN = {
    MATCHING_MATRIX = {
      mfrs = 0x044A,
      product_types = 0x0004,
      product_ids = 0x0002
    },
    PARAMETERS = {
      heartBeat = {parameter_number = 2, size = 4},
    }
  },
  BOUNDARY_MOTION = {
    MATCHING_MATRIX = {
      mfrs = 0x044A,
      product_types = 0x0004,
      product_ids = 0x0003
    },
    PARAMETERS = {
      ledEnabled = {parameter_number = 1, size = 4},
      motionSensitivityLevel = {parameter_number = 11, size = 4},
      motionDetectedTimer = {parameter_number = 2, size = 4},
      wakeUpInterval = {parameter_number = -99, size = -99} -- not a z-wave parameter, code will ignore this.
    }
  },
  BOUNDARY_CONTACT = {
    MATCHING_MATRIX = {
      mfrs = 0x044A,
      product_types = 0x0004,
      product_ids = 0x0007
    },
    PARAMETERS = {
      ledEnabled = {parameter_number = 1, size = 4},
      wakeUpInterval = {parameter_number = -99, size = -99} -- not a z-wave parameter, code will ignore this.
    }
  },
}

local preferences = {}

--- Checks if any preferences have changed and then sends to the device.  
--- Special case for wake-up interval handled as not a z-wave parameter.
--- Requests a home security notification from the device (triggered state) to correct any out of sync issues
preferences.update_preferences = function(driver, device, args)
  local prefs = preferences.get_device_parameters(device)
  if prefs ~= nil then
    for id, value in pairs(device.preferences) do
      if not (args and args.old_st_store) or (args.old_st_store.preferences[id] ~= value and prefs and prefs[id]) then
        local new_parameter_value = preferences.to_numeric_value(device.preferences[id])
        if id ~= "wakeUpInterval" then
          device:send(Configuration:Set({parameter_number = prefs[id].parameter_number, size = prefs[id].size, configuration_value = new_parameter_value}))
          log.debug("Updated preferences sent to device")
        else
          device:send(WakeUp:IntervalSet({node_id = driver.environment_info.hub_zwave_id, seconds = new_parameter_value}))
          log.debug("Updated Wake-up interval sent to device")
        end
      end
    end
  end

  device:send(Notification:Get({notification_type = Notification.notification_type.HOME_SECURITY}))
  log.debug("Device state requested")
end

preferences.get_device_parameters = function(zw_device)
  for _, device in pairs(devices) do
    if zw_device:id_match(
      device.MATCHING_MATRIX.mfrs,
      device.MATCHING_MATRIX.product_types,
      device.MATCHING_MATRIX.product_ids) then
      return device.PARAMETERS
    end
  end
  return nil
end

preferences.to_numeric_value = function(new_value)
  local numeric = tonumber(new_value)
  if numeric == nil then -- in case the value is boolean
    numeric = new_value and 1 or 0
  end
  return numeric
end
return preferences
