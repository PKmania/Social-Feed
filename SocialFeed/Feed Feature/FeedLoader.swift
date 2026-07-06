//
//  Created by CN23 on 17/04/26.
//

import Foundation
public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
  func load(completion: @escaping (LoadFeedResult) -> Void)
}
