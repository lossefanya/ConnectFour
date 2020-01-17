//
//  BoardCell.swift
//  ConnectFour
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import UIKit

class BoardCell: UICollectionViewCell {
  var viewModel: BoardCellViewModel? {
    didSet {
      guard let vm = viewModel else { return }
      contentView.backgroundColor = vm.color
    }
  }

  override func awakeFromNib() {
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 2
  }
}
