//
//  UIAlertController+Alert.swift
//  ConnectFour
//
//  Created by Yeongweon Park on 21.12.19.
//  Copyright © 2019 young1park. All rights reserved.
//

import UIKit

extension UIAlertController {
  static func alert(
    title: String? = nil,
    message: String,
    context: UIViewController,
    actions: [(title: String, action: () -> Void)]
  ) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach {
      let action = $0.action
      alert.addAction(UIAlertAction(title: $0.title, style: .default, handler: { _ in action() }))
    }
    context.present(alert, animated: true, completion: nil)
  }
}
