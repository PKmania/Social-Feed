//
//  Created by CN23 on 24/04/26.
//

import Foundation
import SocialFeed

class FeedStoreSpy: FeedStore {
  
  enum ReceivedMessage : Equatable {
    case  deleteCachedFeed
    case insert([LocalFeedImage], Date)
    case retrieve
  }
  
  var receivedMessages : [ReceivedMessage] = []
  
  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()
  private var retrievalCompletions = [RetrievalCompletion]()

  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](.failure(error))
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](.success(()))
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](.failure(error))
  }
  
  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](.success(()))
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(feed, timestamp))
  }
  
  //----- load methods -------

  func retrieve(completion: @escaping RetrievalCompletion) {
    retrievalCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }
  
  func completeRetrival(with error: Error, at index: Int = 0) {
    retrievalCompletions[index](.failure(error))
  }
  
  func completeRetrival(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
    retrievalCompletions[index](.success(CachedFeed(feed: feed, timestamp: timestamp)))
  }

  func completeRetrivalWithEmptyCache(at index: Int = 0) {
    retrievalCompletions[index](.success(.none))
  }
}
