# MovesenseShowcase-iOS

## 1. Introduction

Movesense Showcase for iOS demonstrates the capabilities of Movesense sensors in a compact package of utility and usability.

Movesense is an open and programmable development environment for sensing solutions, capable of measuring motion, heart rate, temperature, and more. With the tiny, durable, water resistant motion sensor you can track anything that moves.

Connect one or multiple Movesense sensors to Movesense Showcase application, stream data from the sensors to your phone and record your data for further analysing. You can also develop your own app in the Movesense sensor to make it work exactly as you need. With our innovative tools you can build your own wearables.

Main features:
* Sensor connection for one or multiple sensors
* Easy-to-use data recording function
* Sharing recorded data logs (CSV and JSON)
* Device firmware update to selected sensor

More information about [Movesense](https://www.movesense.com) at the official site.

The source code has been published under Apache 2.0 license, with some minor updates after my departure from the project, check it out at: https://bitbucket.org/movesense/movesense-mobile-lib/src/master/IOS/MovesenseShowcase/.

This repository is my personally maintained fork from the point of time when I left the project, mostly for reference purposes and some tinkering.

## 2. Differences vs. The Official Release

* Better modularization: Movesense Swift API, its underlying Objective-C API (MDS), and Device Firmware Update (DFU) API delivered as separate modules.
* Dependency management updated to Swift Package Manager instead of CocoaPods.
* iOS version related bug fixes implemented generally without the need for separate execution branches. 
* Some features missing.

## 3. Build Instructions

Open the project in Xcode and change development team and bundle identifier as you please.
