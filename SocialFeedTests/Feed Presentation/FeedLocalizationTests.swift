//
//  Created by CN23 on 10/09/26.
//

import XCTest
import SocialFeed

final class FeedLocalizationTests: XCTestCase {
  
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Feed"
    let bundle = Bundle(for: FeedPresenter.self)
    
    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
}
