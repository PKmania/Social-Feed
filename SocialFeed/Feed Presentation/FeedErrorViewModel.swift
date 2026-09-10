//
//  Created by CN23 on 10/09/26.
//

import Foundation

public struct FeedErrorViewModel {
  public let message: String?
  
  public static var noError: FeedErrorViewModel {
    return FeedErrorViewModel(message: nil)
  }
  
  public static func error(message: String) -> FeedErrorViewModel {
      return FeedErrorViewModel(message: message)
    }
}
