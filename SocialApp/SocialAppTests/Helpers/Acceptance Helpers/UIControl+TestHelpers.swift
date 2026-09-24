//
//  UIControl+TestHelpers.swift
//  SocialAppTests
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import UIKit

extension UIControl {
  func simulate(event: UIControl.Event) {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: event)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}
