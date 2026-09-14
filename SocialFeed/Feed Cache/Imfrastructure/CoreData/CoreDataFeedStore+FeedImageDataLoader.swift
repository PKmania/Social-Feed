//
//  Created by CN23 on 14/09/26.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
  
  public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
    
  }
  
  public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
    completion(.success(.none))
  }
  
}
