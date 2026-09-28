//
//  Created by CN23 on 10/09/26.
//

import Foundation
import XCTest
import SocialFeed

class FeedImagePresenterTests: XCTestCase {
  
  func test_map_createsViewModel() {
    let image = uniqueImage()
    
    let viewModel = FeedImagePresenter.map(image)
    
    XCTAssertEqual(viewModel.description, image.description)
    XCTAssertEqual(viewModel.location, image.location)
  }
  
}
