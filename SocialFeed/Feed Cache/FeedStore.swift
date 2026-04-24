//
//  Created by CN23 on 23/04/26.
//

import Foundation

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
}
