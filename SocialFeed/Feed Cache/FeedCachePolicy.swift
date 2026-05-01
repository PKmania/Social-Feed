//
//  Created by CN23 on 02/05/26.
//

import Foundation

internal final class FeedCachePolicy {
  private static let calender = Calendar(identifier: .gregorian)

  private static var maxCacheAgeInDays: Int {
    return 7
  }
  internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calender.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else { return false}
    return date < maxCacheAge
  }
}
