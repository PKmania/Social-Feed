//
//  Created by CN23 on 17/04/26.
//

import Foundation
public enum LoadFeedResult {
  case success([FeedImage])
  case failure(Error)
}

public protocol FeedLoader {
  associatedtype Error: Swift.Error
  func load(completion: @escaping (LoadFeedResult) -> Void)
}
