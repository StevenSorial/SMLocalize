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
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    SMLocalize.configure()
    return true
  }
}
