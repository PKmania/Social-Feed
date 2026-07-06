//
//  Created by CN23 on 17/04/26.
//

import Foundation


public protocol FeedLoader {
  typealias Result = Swift.Result<[FeedImage], Error>
  func load(completion: @escaping (Result) -> Void)
}
