//
//  Created by CN23 on 21/09/26.
//

import Foundation
import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
