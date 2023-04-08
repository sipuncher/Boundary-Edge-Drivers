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

--- @type st.zwave.CommandClass.Configuration
local Configuration = (require "st.zwave.CommandClass.Configuration")({ version=4 })

local log = require "log"

local BOUNDARY_SIREN_FINGERPRINTS = {
  { manufacturerId = 0x044A, productType = 0x0004, productId = 0x0002 }
}

--- Determine whether the passed device is multifunctional siren
---
--- @param driver Driver driver instance
--- @param device Device device isntance
--- @return boolean true if the device proper, else false
local function can_handle_boundary_siren(opts, driver, device, ...)
  for _, fingerprint in ipairs(BOUNDARY_SIREN_FINGERPRINTS) do
    if device:id_match(fingerprint.manufacturerId, fingerprint.productType, fingerprint.productId) then
      return true
    end
  end
  return false
end

--- Setup a timer to a) disable/enable the Blue LED at night time and b) call refresh to get updated temp/battery
local function device_init(self, device)
  local timer_tick = 3630 -- just over an hour to avoid it being the same minutes past the hour every hour

  device.thread:call_on_schedule(timer_tick, function()
    if device.preferences.ledEnabled ~= nil then
      local ledEnabled = 0

      if device.preferences.ledEnabled == "1" then
        ledEnabled = Enable_led_parameter()
      end

      device:send(Configuration:Set({parameter_number = 1, size = 4, configuration_value = ledEnabled}))
    end

    log.debug("Hourly siren status refresh requested")
    device:default_refresh()
  end, 'Siren Poll Schedule')
end

--- Determines whether to enable the LED based upon time of day
--- @return integer 1 or 0 to set the device parameter
function Enable_led_parameter()
  local start_hour = 4
  local end_hour = 20
  
  local current_hour = tonumber(os.date("%H"))

  if current_hour > start_hour and current_hour < end_hour then
    log.debug("Time is between " .. start_hour .. " and " .. end_hour .. " so disabling siren LED")
    return 0
  end
  log.debug("Time is not between " .. start_hour .. " and " .. end_hour .. " so enabling siren LED")
  return 1
end


local boundary_siren = {
  lifecycle_handlers = {
    init = device_init
  },
  NAME = "Boundary siren",
  can_handle = can_handle_boundary_siren,
}

return boundary_siren
