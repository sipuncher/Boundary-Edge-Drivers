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

local capabilities = require "st.capabilities"
--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
--- @type st.zwave.CommandClass.Basic
local Basic = (require "st.zwave.CommandClass.Basic")({version=1})
--- @type st.zwave.CommandClass.Battery
local Notification = (require "st.zwave.CommandClass.Notification")({version=3})
--- @type st.zwave.CommandClass.Indicator
local Indicator = (require "st.zwave.CommandClass.Indicator")({version=1})

local MULTIFUNCTIONAL_SIREN_FINGERPRINTS = {
  { manufacturerId = 0x044A, productType = 0x0004, productId = 0x0002 }
}

--- Determine whether the passed device is multifunctional siren
---
--- @param driver Driver driver instance
--- @param device Device device isntance
--- @return boolean true if the device proper, else false
local function can_handle_multifunctional_siren(opts, driver, device, ...)
  for _, fingerprint in ipairs(MULTIFUNCTIONAL_SIREN_FINGERPRINTS) do
    if device:id_match(fingerprint.manufacturerId, fingerprint.productType, fingerprint.productId) then
      return true
    end
  end
  return false
end

local do_configure = function(self, device)
  device:refresh()
  device:send(Notification:Get({notification_type = Notification.notification_type.HOME_SECURITY}))
  device:send(Basic:Get({}))
end

local multifunctional_siren = {
  lifecycle_handlers = {
    doConfigure = do_configure
  },
  NAME = "multifunctional siren",
  can_handle = can_handle_multifunctional_siren,
}

return multifunctional_siren
