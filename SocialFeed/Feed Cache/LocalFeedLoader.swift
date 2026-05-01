//
//  Created by CN23 on 23/04/26.
//

import Foundation

private final class FeedCachePoilcy {
  private static let calender = Calendar(identifier: .gregorian)

  private static var maxCacheAgeInDays: Int {
    return 7
  }
  static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false}
    return date < maxCacheAge
  }
}

public final class LocalFeedLoader {
  private let store: FeedStore
  private let currentDate: () -> Date
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  

}

extension LocalFeedLoader {
  public typealias SaveResult = Error?
  
  public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void ) {
    store.deleteCachedFeed { [ weak self] (error) in
      guard let self = self else { return }
      if let cacheDeletionError = error {
        completion(cacheDeletionError)
      } else {
        self.cache(feed, with: completion)
      }
    }
  }
  
  private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
    store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}

extension LocalFeedLoader: FeedLoader {
  public typealias LoadFeed = LoadFeedResult
  
  public func load(completion: @escaping (LoadFeed) -> Void) {
    store.retrieve { [weak self]( result) in
      guard let self = self else { return }
      switch result {
      case let .failure(error):
        completion(.failure(error))
      case let .found(feed, timestamp) where FeedCachePoilcy.validate(timestamp, against: currentDate()):
        completion(.success(feed.toModels()))
      case .empty, .found:
        completion(.success([]))    // also use --- fallthrough
      }
    }
  }
}

extension LocalFeedLoader {
  public func validateCache() {
    store.retrieve { [weak self] (result) in
      guard let self = self else { return }
      switch result {
      case .failure:
        store.deleteCachedFeed {_ in }
      case let .found(_, timestamp) where !FeedCachePoilcy.validate(timestamp, against: currentDate()):
        store.deleteCachedFeed {_ in }
      case .empty, .found: break
      }
    }
  }
}



private extension Array where Element == FeedImage {
  func toLocal() -> [LocalFeedImage] {
    return map { LocalFeedImage(id: $0.id,
                                description: $0.description,
                                location: $0.location,
                                url: $0.url)}
  }
}

private extension Array where Element == LocalFeedImage {
  func toModels() -> [FeedImage] {
    return map { FeedImage(id: $0.id,
                           description: $0.description,
                           location: $0.location,
                           url: $0.url)}
  }
}
