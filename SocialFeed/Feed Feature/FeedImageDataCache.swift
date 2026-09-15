//
//  Created by CN23 on 15/09/26.
//

import Foundation

public protocol FeedImageDataCache {
  typealias Result = Swift.Result<Void, Error>

  func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
