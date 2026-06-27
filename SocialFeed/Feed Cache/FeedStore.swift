//
//  Created by CN23 on 23/04/26.
//

import Foundation

public enum RetrieveCachedFeedResult {
  case found(feed: [LocalFeedImage], timestamp: Date)
  case empty
  case failure(Error)
}

public protocol FeedStore {
  
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrivalCompletion = (RetrieveCachedFeedResult) -> Void
  
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
  
  /// The completion handler can be invoked in any thread.
  /// Clients are responsible to dispatch to appropriate threads, if needed.
  func retrieve(completion: @escaping RetrivalCompletion)
}
