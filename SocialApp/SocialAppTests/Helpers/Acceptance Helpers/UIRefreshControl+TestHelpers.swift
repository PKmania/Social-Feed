//
//  UIRefreshControl+TestHelpers..swift
//  SocialAppTests
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import UIKit

class FakeUIRefreshControl: UIRefreshControl {
  private var _isRefreshing = false
  override var isRefreshing: Bool { _isRefreshing }
  
  override func beginRefreshing() {
    _isRefreshing = true
  }
  override func endRefreshing() {
    _isRefreshing = false
  }
}


extension UIRefreshControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}
