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

  override func viewDidLoad() {
    super.viewDidLoad()
    slider.setThumbImage(UIImage(named: "Arrow")!, for: .normal)
    setupLangsSegmentedControl()
    setupTagsForFlipping()
  }

  func setupLangsSegmentedControl() {
    segCon.removeAllSegments()
    segCon.semanticContentAttribute = .forceLeftToRight
    for (index, lang) in AppLangs.allCases.enumerated(){
      segCon.insertSegment(withTitle: lang.title, at: index, animated: false)
    }
    let currentLang = SMLocalize.currentLanguage
    let currentIndex = AppLangs.allCases.map { $0.rawValue }.firstIndex(of: currentLang)
    segCon.selectedSegmentIndex = currentIndex ?? 0
  }

  func setupTagsForFlipping() {
    view.subviews.first!.tag = 1 // allow slipping in the first subview.
    stackView.tag = 2
    btn.tag = 3
    imageView.tag = 11 // Exclude it from flipping.
    //SMLocalize.flipImagesInViewsWithTags.insert(15) // add 15 to tags to flip.
    slider.tag = 15 // allow the slider to flip its images.
  }

  @IBAction
  func segConChanged(_ sender: UISegmentedControl) {
    let lang = AppLangs.allCases[sender.selectedSegmentIndex]
    SMLocalize.currentLanguage = lang.rawValue
    let willAnimate = Bool.random()
    SMLocalize.reloadAppDelegate(animation: willAnimate ? .transitionFlipFromRight : nil, duration: 0.5)
  }
}

enum AppLangs:String, CaseIterable{
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
