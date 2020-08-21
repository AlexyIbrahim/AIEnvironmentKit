# AIEnvironmentKit

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url] 
![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)

A library to determine the iOS app environment

## Requirements

- iOS 11.0+
- Xcode 10.0+

## Installation

#### Swift Package Manager

You can use SPM to install `AIEnvironmentKit` by adding it to your `Package.swift`:

https://github.com/AlexyIbrahim/AIEnvironmentKit.git

## Usage example

```swift
AIEnvironmentKit.environment
```



- Execute code if not on the AppStore

```swift
AIEnvironmentKit.executeIfNotAppStore {
	print("not app store")
}
```

## Meta

Alexy Ibrahim – [@Github](https://github.com/alexyibrahim) – alexy.ib@gmail.com

See ``LICENSE`` for more information.

[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.md

# 