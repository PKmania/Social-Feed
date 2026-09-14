//
//  Created by CN23 on 14/09/26.
//

import Foundation

public protocol FeedImageDataStore {
  typealias Result = Swift.Result<Data?, Error>
  
  func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
