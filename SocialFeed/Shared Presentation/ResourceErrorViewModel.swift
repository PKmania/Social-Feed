//
//  Created by CN23 on 28/09/26.
//

import Foundation

public struct ResourceErrorViewModel {
  public let message: String?
  
  static var noError: ResourceErrorViewModel {
    return ResourceErrorViewModel(message: nil)
  }
  
  static func error(message: String) -> ResourceErrorViewModel {
    return ResourceErrorViewModel(message: message)
  }
}
