//
//  Created by CN23 on 09/09/26.
//

import XCTest
import UIKit
import SocialFeed
import SocialFeedIOS

extension FeedUIIntegrationTests {
  
  private class DummyView: ResourceView {
         func display(_ viewModel: Any) {}
     }
     
     var loadError: String {
         LoadResourcePresenter<Any, DummyView>.loadError
     }
     
     var feedTitle: String {
         FeedPresenter.title
     }
}
