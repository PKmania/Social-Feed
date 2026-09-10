//
//  Created by CN23 on 10/09/26.
//

import Foundation
import UIKit

extension UIRefreshControl {
  func update(isRefreshing: Bool) {
    isRefreshing ? beginRefreshing() : endRefreshing()
  }
}
