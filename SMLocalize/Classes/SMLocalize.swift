import Foundation
import UIKit

extension UserDefaults {
  fileprivate enum Keys {
    static let currentLanguage = "SMLocalizeCurrentLanguage"
  }
}

// swiftlint:disable:next type_name
private typealias UD = UserDefaults

public class SMLocalize {
  public static let shared = SMLocalize()
  private var didConfigure = false

  var defaultLanguage = Bundle.main.preferredLocalizations.first ?? "en" {
    willSet {
      guard !didConfigure else { fatalError("defaultLanguage should be set before calling configure()") }
    }
  }

  public var currentLanguage: String {
    set { setCurrentLanguage(newValue) }
    get { return getCurrentLanguage() }
  }

  public var isCurrentLanguageRTL: Bool {
    return Locale.characterDirection(forLanguage: getCurrentLanguage()) == .rightToLeft
  }

  public var currentLocale: Locale {
    return Locale(identifier: getCurrentLanguage())
  }

  private init() {
  }

  public func configure() {
    guard !didConfigure else { return }
    Bundle.swizzle()
    let layoutDirection: UISemanticContentAttribute = isCurrentLanguageRTL ? .forceRightToLeft : .forceLeftToRight
    UIView.appearance().semanticContentAttribute = layoutDirection
    didConfigure = true
  }

  private func setCurrentLanguage(_ lang: String) {
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
  }

  private func getCurrentLanguage() -> String {
    guard didConfigure else { fatalError("SMLocalize is not configured. Please call configure() first.") }
    return UD.standard.string(forKey: UD.Keys.currentLanguage) ?? defaultLanguage
  }

  public func resetLanguageToDefault() {
    setCurrentLanguage(defaultLanguage)
  }
}

extension Bundle {
  fileprivate static func swizzle() {
    let orginalSelector = #selector(localizedString(forKey:value:table:))
    let swizzledSelector = #selector(smSwizzledLocalizedString(forKey:value:table:))

    let orginalMethod = class_getInstanceMethod(Bundle.self, orginalSelector)
    let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector)

    let didAddMethod = class_addMethod(
      self,
      orginalSelector,
      method_getImplementation(swizzledMethod!),
      method_getTypeEncoding(swizzledMethod!)
    )

    if didAddMethod {
      class_replaceMethod(
        self,
        swizzledSelector,
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

  @objc
  private func smSwizzledLocalizedString(forKey: String, value: String?, table: String?) -> String {
    if let path = Bundle.main.path(forResource: SMLocalize.shared.currentLanguage, ofType: "lproj"),
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
