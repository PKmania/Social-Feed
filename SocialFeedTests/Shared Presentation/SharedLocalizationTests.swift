//
//  Created by CN23 on 28/09/26.
//

import Foundation
import XCTest
import SocialFeed

class SharedLocalizationTests: XCTestCase {
  
  func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
    let table = "Shared"
    let bundle = Bundle(for: LoadResourcePresenter<Any, DummyView>.self)
    
    assertLocalizedKeyAndValuesExist(in: bundle, table)
    
  }
  
  private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
  }
  
}
