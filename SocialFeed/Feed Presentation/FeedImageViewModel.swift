//
//  Created by CN23 on 10/09/26.
//

import Foundation

public struct FeedImageViewModel {
  public let description: String?
  public let location: String?
  
  public var hasLocation: Bool {
    return location != nil
  }
}

