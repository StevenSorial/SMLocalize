//
//  TableViewCell.swift
//  SMLocalizeExample
//
//  Created by Steven on 7/6/19.
//  Copyright © 2019 Steven. All rights reserved.
//

import UIKit
import SMLocalize

class TableViewCell: UITableViewCell {

  @IBOutlet weak var lbl: UILabel!
  @IBOutlet weak var img: UIImageView!

  func setup() {
    lbl.textAlignment = SMLocalize.isCurrentLanguageRTL ? .right : .left
    lbl.text = localizedString(for: "list_item")
    // Flipping the image manually because its not supported in UITableViewCell and UICollectionViewCell yet.
    img.image = UIImage(named: "LowVolume")?.imageFlippedForRightToLeftLayoutDirection()
  }
}
