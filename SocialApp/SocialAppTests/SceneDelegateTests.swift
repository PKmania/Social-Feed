//
//  Created by CN23 on 21/09/26.
//

import Foundation
import XCTest
import SocialFeedIOS
@testable import SocialApp

class SceneDelegateTests: XCTestCase {
  
  func test_sceneWillConnectToSession_configuresRootViewController() {
    let sut = SceneDelegate()
    sut.window = UIWindow(frame: .zero)
    
    sut.configureWindow()
    
    let root = sut.window?.rootViewController
    let rootNavigation = root as? UINavigationController
    let topController = rootNavigation?.topViewController
    
    XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root)) instead")
    XCTAssertTrue(topController is FeedViewController, "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
  }
  
}

