//
//  Created by CN23 on 09/09/26.
//

import Foundation
import UIKit

extension UIImageView {
  func setImageAnimated(_ newImage: UIImage?) {
    image = newImage
    guard newImage != nil else { return }
    
    alpha = 0
    UIView.animate(withDuration: 0.25) { [weak self] in
      self?.alpha = 1
    }
  }
}
