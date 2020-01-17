//
//  GameSetting.swift
//  ConnectFour
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import UIKit

struct GameSetting: Codable {
  let id: Int
  let color1: String
  let color2: String
  let name1: String
  let name2: String

  static var offline: GameSetting {
    return GameSetting(id: 0, color1: "", color2: "", name1: "Red", name2: "Blue")
  }
}

extension GameSetting {
  var firstColor: UIColor? { return UIColor(hex: color1) }
  var secondColor: UIColor? { return UIColor(hex: color2) }
}

extension UIColor {
  public convenience init?(hex: String) {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
      cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
      return nil
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    self.init(
      red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
      alpha: CGFloat(1.0)
    )
  }
}
