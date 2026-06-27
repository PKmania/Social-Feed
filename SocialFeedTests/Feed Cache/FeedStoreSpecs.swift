//
//  Created by CN23 on 27/06/26.
//

import Foundation

protocol FeedStoreSpecs {
  
  func test_retrieve_deliverEmptyOnEmptyCache()
  func test_retrieve_hasNoSideEffectsOnEmptyCache()
  func test_retrieve_deliversFoundValuesOnNonEmptyCache()
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache()
  
  func test_insert_deliverNoErrorOnEmptyCache()
  func test_insert_deliverNoErrorOnNonEmptyCache()
  func test_insert_overridesPreviouslyInsertedCacheValues()
  
  func test_delete_deliverNoErrorOnEmptyCache()
  func test_delete_deliverNoErrorOnNonEmptyCache()
  func test_delete_hasNoSideEffectsOnEmptyCache()
  func test_delete_emptiesPreviouslyInsertedCache()
  
  func test_storeSideEffects_runSerially()
}

protocol FailiableRetrieveFeedStoreSpecs: FeedStoreSpecs {
  func test_retrieve_deliversFailureOnRetrievalError()
  func test_retrieve_hasNoSideEffectsOnFailure()
}

protocol FailiableInsertFeedStoreSpecs: FeedStoreSpecs {
  func test_insert_deliversErrorOnInsertionError()
  func test_insert_hasNoSideEffectsOnInsertionError()
}

protocol FailiableDeleteFeedStoreSpecs: FeedStoreSpecs {
  func test_delete_deliversErrorOnDeletionError()
  func test_delete_hasNoSideEffectsOnDeletionError()
}

typealias FailableFeedStoreSpecs = FailiableRetrieveFeedStoreSpecs & FailiableInsertFeedStoreSpecs & FailiableDeleteFeedStoreSpecs
