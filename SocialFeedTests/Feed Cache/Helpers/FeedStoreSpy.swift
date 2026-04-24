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
  private var retrivalCompletions = [RetrivalCompletion]()

  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
  func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(feed, timestamp))
  }
  
  //----- load methods -------

  func retrieve(completion: @escaping RetrivalCompletion) {
    retrivalCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }
  
  func completeRetrival(with error: Error, at index: Int = 0) {
    retrivalCompletions[index](error)
  }

}
