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

--- @type st.zwave.defaults
local defaults = require "st.zwave.defaults"
--- @type st.zwave.Driver
local ZwaveDriver = require "st.zwave.driver"

--- @type st.zwave.CommandClass
local cc = require "st.zwave.CommandClass"
local Basic = (require "st.zwave.CommandClass.Basic")({version=1})
local preferences = require "preferences"

--- Configure device
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
local function do_configure(driver, device)

    local delayed_command = function()
      device:send(Basic:Set({value=0x00}))
    end
    device.thread:call_with_delay(1, delayed_command)
end

local function device_init(self, device)
  device:set_update_preferences_fn(preferences.update_preferences)
end

--- Handle preference changes
---
--- @param driver st.zwave.Driver
--- @param device st.zwave.Device
--- @param event table
--- @param args
local function info_changed(self, device, event, args)
  if not device:is_cc_supported(cc.WAKE_UP) then
    preferences.update_preferences(self, device, args)
  end
end

--------------------------------------------------------------------------------------------
-- Register message handlers and run driver
--------------------------------------------------------------------------------------------

local driver_template = {
  supported_capabilities = {
    capabilities.alarm,
    capabilities.battery,
    capabilities.tamperAlert,
    capabilities.temperatureMeasurement,
    capabilities.contactSensor,
    capabilities.motionSensor
  },
  sub_drivers = {
    --require("boundary-siren"),
  },
  lifecycle_handlers = {
    infoChanged = info_changed,
    doConfigure = do_configure,
    init = device_init
  },
}

defaults.register_for_default_handlers(driver_template, driver_template.supported_capabilities)
--- @type st.zwave.Driver
local boundary_sensors = ZwaveDriver("boundary-sensors", driver_template)
boundary_sensors:run()
