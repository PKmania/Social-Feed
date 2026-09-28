//
//  Created by CN23 on 28/09/26.
//

import Foundation
import XCTest
import SocialFeed

class ImageCommentsLocalizationTests: XCTestCase {
  
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "ImageComments"
    let bundle = Bundle(for: ImageCommentsPresenter.self)
    
    assertLocalizedKeyAndValuesExist(in: bundle, table)
  }
  
}
