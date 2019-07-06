//
//  AppDelegate.swift
//  SMLocalize
//
//  Created by Steven on 04/09/2019.
//  Copyright (c) 2019 Steven. All rights reserved.
//

import UIKit
import SMLocalize

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReloadableAppDelegate {

  func reload() {
    initWindow()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyBoard.instantiateViewController(withIdentifier: "ViewController")
    window?.rootViewController = vc
  }

  var window: UIWindow?

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Uncomment the next line if u want to use Arabic as the default language.
    // SMLocalize.defaultLanguage = "ar"
    SMLocalize.configure()
    SMLocalize.flipImagesInViewsWithTags = Set(1...10) // Tags from 1 to 10
    reload()
    return true
  }

  func initWindow() {
    guard window == nil else { return }
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
  }
}

func localizedString(for key: String) -> String {
  return NSLocalizedString(key, comment: "localizedString for key \(key)")
}
