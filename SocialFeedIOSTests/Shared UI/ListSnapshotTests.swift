//
//  Created by CN23 on 29/09/26.
//

import Foundation
import XCTest
import SocialFeedIOS
@testable import SocialFeed

class ListSnapshotTests: XCTestCase {
  
  func test_emptyList() {
    let sut = makeSUT()
    
    sut.display(emptyList())
    
    assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "EMPTY_LIST_light")
    assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "EMPTY_LIST_dark")
  }
  
  func test_listWithErrorMessage() {
    let sut = makeSUT()
    
    sut.display(.error(message: "This is a\nmulti-line\nerror message"))
    
    assert(snapshot: sut.snapshot(for: .iPhone17(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
    assert(snapshot: sut.snapshot(for: .iPhone17(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
  }
  
  // MARK: - Helpers
  
  private func makeSUT() -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let controller = storyboard.instantiateInitialViewController() as! ListViewController
    controller.loadViewIfNeeded()
    controller.tableView.showsVerticalScrollIndicator = false
    controller.tableView.showsHorizontalScrollIndicator = false
    return controller
  }
  
  private func emptyList() -> [CellController] {
    return []
  }
  
}
