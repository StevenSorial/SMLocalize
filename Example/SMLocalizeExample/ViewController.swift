//
//  ViewController.swift
//  SMLocalizeExample
//
//  Created by Steven on 7/6/19.
//  Copyright © 2019 Steven. All rights reserved.
//

import UIKit
import SMLocalize

class ViewController: UIViewController {
  @IBOutlet private weak var slider: UISlider!
  @IBOutlet private weak var segCon: UISegmentedControl!
  @IBOutlet private weak var btn: UIButton!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var tableView: UITableView!

  override func viewDidLoad() {
    super.viewDidLoad()
    slider.setThumbImage(UIImage(named: "Arrow")!, for: .normal)
    setupLangsSegmentedControl()
    setupTagsForFlipping()
    tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
    tableView.delegate = self
    tableView.dataSource = self
    NotificationCenter.default.addObserver(self,
                                           selector:#selector(languageChangedObserver(_:)),
                                           name: SMLocalize.languageDidChange,
                                           object: nil)
  }

  @objc
  func languageChangedObserver(_ notification: Notification) {
    // handle language change manually here.
    guard let newLang = notification.object as? String else { return }
    print("language changed to \(newLang)")
  }

  func setupLangsSegmentedControl() {
    segCon.removeAllSegments()
    segCon.semanticContentAttribute = .forceLeftToRight // Disable segmentedControl flipping.
    for (index, lang) in AppLangs.allCases.enumerated(){
      segCon.insertSegment(withTitle: lang.title, at: index, animated: false)
    }
    let currentLang = SMLocalize.currentLanguage
    let currentIndex = AppLangs.allCases.map { $0.rawValue }.firstIndex(of: currentLang)
    segCon.selectedSegmentIndex = currentIndex ?? 0
  }

  func setupTagsForFlipping() {
    view.subviews.first!.tag = 1 // allow flipping images in the first subview.
    stackView.tag = 2
    btn.tag = 3
    imageView.tag = 11 // Exclude it from image flipping.
    SMLocalize.flipImagesInViewsWithTags.insert(15) // add 15 to tags to flip.
    slider.tag = 15 // allow the slider to flip its images.
  }

  @IBAction
  func segConChanged(_ sender: UISegmentedControl) {
    // Plays an animation based on the new language direction.
    // If the new language is the same direction as the previous one, No animation.
    let isPrevLangRTL = SMLocalize.isCurrentLanguageRTL
    let newLang = AppLangs.allCases[sender.selectedSegmentIndex]
    SMLocalize.currentLanguage = newLang.rawValue
    let isNewRTL = SMLocalize.isCurrentLanguageRTL
    let willDoAnimation = isNewRTL != isPrevLangRTL
    let potentialAnimation: UIView.AnimationOptions = isNewRTL
      ? .transitionFlipFromRight : .transitionFlipFromLeft
    let animation: UIView.AnimationOptions? = willDoAnimation ? [potentialAnimation, .curveEaseOut] : nil
    SMLocalize.reloadAppDelegate(animation: animation, duration: 0.4)
  }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
    cell.setup()
    return cell
  }
}

enum AppLangs: String, CaseIterable {
  case english = "en"
  case french = "fr"
  case arabic = "ar"

  var title: String {
    switch self {
      case .arabic: return "Arabic"
      case .english : return "English"
      case .french: return "French"
    }
  }
}
