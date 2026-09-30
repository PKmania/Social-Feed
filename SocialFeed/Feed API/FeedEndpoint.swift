//
//  Created by CN23 on 30/09/26.
//

import Foundation

public enum FeedEndpoint {
  case get
  
  public func url(baseURL: URL) -> URL {
    switch self {
    case .get:
      return baseURL.appendingPathComponent("/v1/feed")
    }
  }
}
