//
//  Created by CN23 on 28/04/26.
//

import Foundation
import SocialFeed

func uniqueImage() -> FeedImage {
  return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueImageFeed() -> (model: [FeedImage], local: [LocalFeedImage]) {
  let feed = [uniqueImage(), uniqueImage()]
  let localItems = feed.map { LocalFeedImage(id: $0.id,
                                             description: $0.description,
                                             location: $0.location,
                                             url: $0.url)}
  return (feed, localItems)
}

extension Date {
  func adding(days: Int) -> Date {
    Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
  
  func adding(seconds: TimeInterval) -> Date {
    return self + seconds
  }
}
