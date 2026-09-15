//
//  Created by CN23 on 15/09/26.
//

import Foundation

public protocol FeedCache {
  typealias Result = Swift.Result<Void, Error>
  
  func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
