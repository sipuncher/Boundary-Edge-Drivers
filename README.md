# Boundary drivers for SmartThings

## What are these drivers?

Boundary (https://boundary.co.uk/) made a smart home system in the UK, but went into liquidation in December 2022.  This left customers with systems that no longer worked due to the reliance upon their Cloud.  The motion sensors, contact sensors and siren all communicate to their hub via Z-Wave, so should in theory work with other Z-Wave hubs.  This driver matches the fingerprints of the devices and matches to the SmartThings device capabilities (motion, contact, tamper, temperature, etc.).  There are a few Boundary specific features added over the default handlers, including the specific z-wave parameters used to configure these devices, and dealing with them being sleepy devices.

I'm sharing to help others out in the same position, but use is at your own risk.

The driver is published for use under a SmartThing channel (https://bestow-regional.api.smartthings.com/invite/WnlLqg5qgwjK)

## Documentation and Tutorials

Visit the SmartThings Edge Device Driver documentation on our [developer documentation portal](https://developer.smartthings.com/docs/devices/hub-connected/get-started) to get started.

Be sure to check out the SmartThings Community for [tutorials](https://community.smartthings.com/c/developer-programs/tutorials/103), code samples, and more.

## Code of Conduct

The code of conduct for SmartThingsEdgeDrivers can be found in
[CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

SmartThingsEdgeDrivers is released under the [Apache 2.0 License](LICENSE).
