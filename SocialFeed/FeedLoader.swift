//
//  Created by CN23 on 17/04/26.
//

import Foundation
enum LoadFeedResult {
  case success([FeedItem])
  case failure(Error)
}

protocol FeedLoader {
  func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
