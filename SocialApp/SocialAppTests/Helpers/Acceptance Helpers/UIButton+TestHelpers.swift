//
//  UIButton+TestHelpers.swift
//  SocialAppTests
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import UIKit

extension UIButton {
  func simulateTap() {
    simulate(event: .touchUpInside)
  }
}
