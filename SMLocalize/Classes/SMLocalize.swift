#if os(iOS)
import Foundation
import UIKit

extension UserDefaults {
  fileprivate enum Keys {
    static let currentLanguage = "SMLocalizeCurrentLanguage"
  }
}

public protocol ReloadableAppDelegate where Self: UIApplicationDelegate {
  func reload()
}

// swiftlint:disable:next type_name
private typealias UD = UserDefaults

public enum SMLocalize {

  /// A notification which will be posted when the language is changed
  /// i.e., when `SMLocalize.currentLanguage` is set or `SMLocalize.resetToDefaultLanguage()` is called.
  ///
  /// The notification object will be the new language of type `String`.
  public static let languageDidChange = Notification.Name(rawValue: "SMLocalizeLanguageDidChange")
  private static var didConfigure = false

  /// The default language of the app if no language is set yet.
  /// Default is the device curent language or english if not found (very Unlikely).
  ///
  /// - Warning: Must be called before `SMLocalize.configure()` or else it will cause a crash.
  public static var defaultLanguage = Bundle.main.preferredLocalizations.first ?? "en" {
    willSet {
      guard !didConfigure else { fatalError("defaultLanguage should be set before calling configure()") }
      guard Bundle.main.localizations.contains(newValue) else {
        fatalError("Selected language is not included in the app bundle.")
      }
    }
  }

  ///  A set of view tags where its images are going to be flipped according to the selected language direction.
  ///
  /// Views where the image needed to be flipped and its superviews must have a tag included in this set.
  /// Default is empty.
  ///
  /// - Remark: UIViewController main view tag doesn't have to be changed.
  public static var flipImagesInViewsWithTags: Set<Int> = []

  /// The current selected language. if no language is selected yet, it will return the value of `SMLocalize.defdefaultLanguage`.
  ///
  /// - Warning: Must be called after `SMLocalize.configure()` or else it will cause a crash.
  public static var currentLanguage: String {
    set { setCurrentLanguage(newValue) }
    get { return getCurrentLanguage() }
  }

  ///  A Boolean value that indicates whether the current selected language is a right-to-left language.
  ///
  /// - Remark: If no selected language is set, the returned bool is based on the default language.
  public static var isCurrentLanguageRTL: Bool {
    return Locale.characterDirection(forLanguage: getCurrentLanguage()) == .rightToLeft
  }

  ///  A Locale representing the current selected language.
  ///
  ///  - Remark: If no selected language is set, the locale of the default language is returned.
  public static var currentLocale: Locale {
    return Locale(identifier: getCurrentLanguage())
  }

  ///  Initialize the library.
  ///
  /// - Important: This method should be called once at the start of the app for the library to function properly.
  public static func configure() {
    guard !didConfigure else { return }
    let bundleClass = Bundle.self
    swizzle(#selector(bundleClass.localizedString(forKey:value:table:)), with: #selector(bundleClass.smSwizzledLocalizedString(forKey:value:table:)), in: bundleClass)
    let vcClass = UIViewController.self
    swizzle(#selector(vcClass.viewDidLayoutSubviews), with: #selector(vcClass.smSwizzledviewDidLayoutSubviews), in: vcClass)
    didConfigure = true
    let layoutDirection: UISemanticContentAttribute = isCurrentLanguageRTL ? .forceRightToLeft : .forceLeftToRight
    UIView.appearance().semanticContentAttribute = layoutDirection
  }

  private static func setCurrentLanguage(_ lang: String) {
    guard didConfigure else { fatalError("SMLocalize is not configured. Please call configure() first.") }
    guard Bundle.main.localizations.contains(lang) else {
      fatalError("Selected language is not included in the app bundle.")
    }
    guard lang != getCurrentLanguage() else { return }
    let isRTL = Locale.characterDirection(forLanguage: lang) == .rightToLeft
    let layoutDirection: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    UIView.appearance().semanticContentAttribute = layoutDirection
    UD.standard.set(lang, forKey: UD.Keys.currentLanguage)
    UD.standard.synchronize()
    NotificationCenter.default.post(name: languageDidChange, object: lang)
    reloadAppDelegate()
  }

  /// Reloads the AppDelegate. The appdelegate must conform to `ReloadableAppDelegate`.
  ///
  /// - Parameters:
  ///   - animation: Animation Options. Default is nil
  ///   - duration: Animation duration. Default is 0.5
  ///
  /// - Warning: The appdelegate must conform to `ReloadableAppDelegate` or else it will cause a crash.
  public static func reloadAppDelegate(animation: UIView.AnimationOptions? = nil, duration: TimeInterval = 0.5 ) {
    guard let delegate = UIApplication.shared.delegate as? ReloadableAppDelegate else {
      fatalError("AppDelegate does not conform to ReloadableAppDelegate.")
    }
    delegate.reload()
    guard let animation = animation, let window = delegate.window as? UIWindow else { return }
    UIView.transition(with: window, duration: duration, options: animation, animations: nil, completion: nil)
  }

  private static func getCurrentLanguage() -> String {
    guard didConfigure else { fatalError("SMLocalize is not configured. Please call configure() first.") }
    return UD.standard.string(forKey: UD.Keys.currentLanguage) ?? defaultLanguage
  }

  /// Resets the the current language to `SMLocalize.defdefaultLanguage`.
  ///
  /// - Warning: Must be called after `SMLocalize.configure()` or else it will cause a crash.
  public static func resetToDefaultLanguage() {
    guard didConfigure else { fatalError("SMLocalize is not configured. Please call configure() first.") }
    let lang = defaultLanguage
    guard lang != getCurrentLanguage() else { return }
    let isRTL = Locale.characterDirection(forLanguage: lang) == .rightToLeft
    let layoutDirection: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
    UIView.appearance().semanticContentAttribute = layoutDirection
    UD.standard.removeObject(forKey: UD.Keys.currentLanguage)
    UD.standard.synchronize()
    NotificationCenter.default.post(name: languageDidChange, object: lang)
  }
}

extension Bundle {
  @objc
  fileprivate func smSwizzledLocalizedString(forKey: String, value: String?, table: String?) -> String {
    if let path = Bundle.main.path(forResource: SMLocalize.currentLanguage, ofType: "lproj"),
      let bundle = Bundle(path: path) {
      return bundle.smSwizzledLocalizedString(forKey: forKey, value: value, table: table)
    } else if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
      let bundle = Bundle(path: path) {
      return bundle.smSwizzledLocalizedString(forKey: forKey, value: value, table: table)
    } else {
      return Bundle.main.smSwizzledLocalizedString(forKey: forKey, value: value, table: table)
    }
  }
}

extension UIViewController {
  @objc
  fileprivate func smSwizzledviewDidLayoutSubviews() {
    self.smSwizzledviewDidLayoutSubviews()
    flipImages(in: view.subviews)
  }
}

private func flipImages(in subViews: [UIView]) {
  let applicableTags = SMLocalize.flipImagesInViewsWithTags
  let states: [UIControl.State] = [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved]
  for subView in subViews where applicableTags.contains(subView.tag) {
    if let btn = subView as? UIButton {
      states.forEach { btn.setImage(btn.image(for: $0)?.flipped, for: $0) }
    } else if let slider = subView as? UISlider {
      states.forEach { slider.setThumbImage(slider.thumbImage(for: $0)?.flipped, for: $0) }
    } else if let imgView = subView as? UIImageView {
      imgView.image = imgView.image?.flipped
    }
    flipImages(in: subView.subviews)
  }
}

private func swizzle(_ oldSelector: Selector, with newSelector: Selector, in anyClass: AnyClass){

  let orginalMethod = class_getInstanceMethod(anyClass, oldSelector)
  let swizzledMethod = class_getInstanceMethod(anyClass, newSelector)

  let didAddMethod = class_addMethod(
    anyClass,
    oldSelector,
    method_getImplementation(swizzledMethod!),
    method_getTypeEncoding(swizzledMethod!)
  )

  if didAddMethod {
    class_replaceMethod(
      anyClass,
      newSelector,
      method_getImplementation(orginalMethod!),
      method_getTypeEncoding(orginalMethod!)
    )
  } else {
    method_exchangeImplementations(
      orginalMethod!,
      swizzledMethod!
    )
  }
}

extension UIImage{
  fileprivate var flipped: UIImage {
    return imageFlippedForRightToLeftLayoutDirection()
  }
}

extension UIView {
  fileprivate var allSubViews: [UIView] {
    var result: [UIView] = []
    subviews.forEach {
      result.append($0)
      result.append(contentsOf: $0.allSubViews)
    }
    return result
  }
}
#endif
