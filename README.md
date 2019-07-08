# SMLocalize [![Version](https://img.shields.io/cocoapods/v/SMLocalize.svg?style=flat)](https://cocoapods.org/pods/SMLocalize) [![Swift 5](https://img.shields.io/badge/swift-5.0-orange.svg?style=flat)](https://developer.apple.com/swift/) [![License](https://img.shields.io/github/license/StevenMagdy/SMLocalize.svg?style=flat)](https://cocoapods.org/pods/SMLocalize) [![Platform](https://img.shields.io/cocoapods/p/SMLocalize.svg?style=flat)](https://cocoapods.org/pods/SMLocalize)

### An iOS library for changing localization at runtime.
---
**Requirements**: iOS 9.0+ &bull; Swift 5.0+

## Basic Usage

In your AppDelegate:

```swift
import SMLocalize

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReloadableAppDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Uncomment the next line if u want to use Arabic as the default language at the first app launch before the user changes the language manually.
    // SMLocalize.defaultLanguage = "ar"
    SMLocalize.configure()
    reload()
    return true
  }

  func reload() {
    if window == nil {
      window = UIWindow(frame: UIScreen.main.bounds)
      window!.makeKeyAndVisible()
    }
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateInitialViewController()
    window!.rootViewController = vc
  }
}
```

Then in your change language action:
```swift
import SMLocalize

class ViewController: UIViewController {
...
...
@IBAction func changeLanguageTapped(_ sender: UIButton) {
  SMLocalize.currentLanguage = "ar" // Your new language
  SMLocalize.reloadAppDelegate()
  }
}
```

## Animation
Playing an animation during language changes.

In your change language action:
```swift
import SMLocalize

class ViewController: UIViewController {
...
...
@IBAction func changeLanguageTapped(_ sender: UIButton) {
  SMLocalize.currentLanguage = "ar" // Your new language
  // Optional animation. Change to nil if not needed.
  SMLocalize.reloadAppDelegate(animation: [.transitionFlipFromRight, .curveEaseOut], duration: 0.3)
  }
}
```

## Default Language
Setting a default language to be set on the first app launch before the user changes the language.

In your AppDelegate:

```swift
import SMLocalize

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReloadableAppDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    SMLocalize.defaultLanguage = "ar" // Must be set before SMLocalize.configure()
    SMLocalize.configure()
    reload()
    return true
  }
}
```

## Flipping Images
Flipping images to match the current language direction, e.g., Arrows.

In your AppDelegate:

```swift
import SMLocalize

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReloadableAppDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    SMLocalize.configure()
    // Flip images in views with tags from 1 to 10
    // Avoid including 0 in this set since it will cause UIKit issues.
    SMLocalize.flipImagesInViewsWithTags = Set(1...10)
    return true
  }
}
```
In your ViewController:
```swift
import SMLocalize

class ViewController: UIViewController {
...
...
 override func viewDidLoad() {
    super.viewDidLoad()
    arrowImgToFlip.tag = 1
    anotherImgToFlip.tag = 2
    myContainerView.tag = 5
    imgInsideMyContainerView.tag = 6
  }
}
```

#### Views that supports flipping its images:

| View | Does support flipping its images? | Note |
| :---: | :---: | :---: |
| UIImageView | ✅ | _ |
| UIButton | ✅<br>(For all states) | _ |
| UISlider | ✅ Thumb Image (For all states)<br>✅ minimumValueImage<br>✅ maximumValueImage<br>❌ minimumTrackImage<br>❌ maximumTrackImage| _ |
| UICollectionViewCell | ❌ |Use<br>UIImage.imageFlippedForRightToLeftLayoutDirection()<br>in  your cellForItem delegate function |
| UITableViewCell| ❌ |Use<br>UIImage.imageFlippedForRightToLeftLayoutDirection()<br>in your cellForRow delegate function |


## Example for more information about how to use the library

To run the example project, clone the repo, and open SMLocalizeExample.xcworkspace from the Example directory.

## Installation

SMLocalize is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SMLocalize'
```

## TODO

- [ ] Support installation through Carthage & Swift Package Manager (Help Needed)
- [ ] Localize Views with Text automatically
- [ ] Improve the library API?

## Credit

### Other Libraries
SMLocalize was inspired by these libraries. Uses the same techniques in some parts and deviates in others.

- [MOLH](https://github.com/MoathOthman/MOLH)
- [Localize-Swift](https://github.com/marmelroy/Localize-Swift)
- [LanguageManager-iOS](https://github.com/Abedalkareem/LanguageManager-iOS)

### Articles

- [Forcing iOS localization at runtime — the right way](https://medium.com/swift2go/forcing-ios-localization-at-runtime-the-right-way-8afa0569162a) (by [Eldar Eliav](https://github.com/eldare))

## Author

Steven, StevenMagdy92@gmail.com

## License

SMLocalize is available under the MIT license. See the LICENSE file for more info.
