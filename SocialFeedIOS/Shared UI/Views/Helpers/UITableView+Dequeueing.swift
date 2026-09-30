//
//  Created by CN23 on 09/09/26.
//

import Foundation
import UIKit

extension UITableView {
  func dequeueReusableCell<T: UITableViewCell>() -> T {
    let identifier = String(describing: T.self)
    // Register the cell class only when the cell is created programmatically.
    // Not needed for prototype cells created/configured in Storyboard.
    // register(T.self, forCellReuseIdentifier: identifier)
    return dequeueReusableCell(withIdentifier: identifier) as! T
  }
}
