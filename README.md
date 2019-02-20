# HelloDependency

[![Build Status](https://travis-ci.com/valitovaza/HelloDependency.svg?branch=master)](https://travis-ci.com/valitovaza/HelloDependency)

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate HelloDependency into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'HelloDependency'
```

## Basic Usage

### Registering a dependency

```swift
import HelloDependency

HelloDependency.register(SomeProtocol.self, {
    SomeClass()
})
```
### Registering a weak singleton

```swift
import HelloDependency

HelloDependency.Single.Weak.register(SomeProtocol.self, {
    SomeClass()
})
```

## Requirements

- iOS 10.0+
- Xcode 10.1+
- Swift 4.2+

## License

HelloDependency is released under the MIT license. See [LICENSE](https://github.com/valitovaza/HelloDependency/blob/master/LICENSE) for more information.
