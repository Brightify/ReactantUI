# ReactantUI

## Reactant extension for UI declaration in XML

[![CI Status](https://img.shields.io/travis/Brightify/ReactantUI.svg?style=flat)](https://travis-ci.org/Brightify/ReactantUI)
[![Version](https://img.shields.io/cocoapods/v/ReactantUI.svg?style=flat)][reactant-cocoapods]
[![License](https://img.shields.io/cocoapods/l/ReactantUI.svg?style=flat)][reactant-cocoapods]
[![Platform](https://img.shields.io/cocoapods/p/ReactantUI.svg?style=flat)][reactant-cocoapods]
[![Apps](https://img.shields.io/cocoapods/at/ReactantUI.svg?style=flat)][reactant-cocoapods]
[![Slack Status](https://swiftkit.brightify.org/badge.svg)][slack]

Reactant UI is an extension for Reactant for declaration of views and layout using XML. There is no runtime overhead, as all the XML declarations are precompiled into Swift. Reactant then uses the generated code to create your UI. Reactant Live UI is an optional part responsible for live rendering your XML file in the simulator on every save. Check the [quick-start guide][quick-start] to learn more.

## Important note
Reactant UI is currently a preview. However we’ll try to keep the number of API changes to a minimum.

## Installation
In your `Podfile`:
```
pod 'Reactant'
pod 'ReactantUI'
pod 'ReactantLiveUI', :configuration => 'Debug'
```
Add new Run script phase to Build phases:
```bash
"$PODS_ROOT/ReactantUI/run" --download -- generate --enable-live --inputPath="$SRCROOT/Application/Sources/" --outputFile="$SRCROOT/Application/Generated/GeneratedUI.swift" --xcodeprojPath="$PROJECT_DIR/$PROJECT_NAME.xcodeproj"
```

To download a specific version using the `run` script, simply add semantic versioning number after the `--download` option. However, if you'd like to build the binary instead of downloading it if it's missing, delete the `--download` option altogether.

### Projects using Swift 4.0
In order to compile valid code, add `--swift 4.0` flag to the build script. Swift 4.1 works out of the box.

## Requirements

* iOS 9.0+
* Xcode 8.0+
* Swift 3.0+

## Communication
Feel free to reach us on Slack! [https://swiftkit.brightify.org/][slack]

## Get Started
Head to our [quick-start guide][quick-start] to learn how Reactant works and what it can do to decrease your development costs!

## Versioning
This library uses semantic versioning. We won't introduce any breaking changes without releasing a new major version. Our main goal is to keep the API as stable as possible. We build our applications on top of Reactant as well and we absolutely hate any breaking changes.

## Authors
* Tadeas Kriz, [tadeas@brightify.org](mailto:tadeas@brightify.org)
* Matyas Kriz, [matyas@brightify.org](mailto:matyas@brightify.org)
* Matous Hybl, [matous@brightify.org](mailto:matous@brightify.org)
* Filip Dolník, [filip@brightify.org](mailto:filip@brightify.org)

## Used libraries

### Runtime

* [Result](https://github.com/antitypical/Result)
* [SnapKit](https://github.com/SnapKit/SnapKit)
* [RxSwift](https://github.com/ReactiveX/RxSwift)
* [RxCocoa](https://github.com/ReactiveX/RxSwift)
* [RxOptional](https://github.com/RxSwiftCommunity/RxOptional)
* [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources)

### Tests

* [Quick](https://github.com/Quick/Quick)
* [Nimble](https://github.com/Quick/Nimble)

[quick-start]: https://docs.reactant.tech/getting-started/quickstart.html
[reactant-cocoapods]: https://cocoapods.org/pods/ReactantUI
[slack]: https://swiftkit.brightify.org/
