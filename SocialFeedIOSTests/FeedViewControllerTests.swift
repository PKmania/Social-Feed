//
//  Created by CN23 on 10/07/26.
//

import XCTest
import UIKit
import SocialFeed
class FeedViewController: UITableViewController {
  private var loader: FeedLoader?
  private var viewAppeared = false
  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)

    load()
  }

  override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    if !viewAppeared {
      refreshControl?.beginRefreshing()
      viewAppeared = true
    }
   

  }
  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    }
  }
}

final class FeedViewControllerTests: XCTestCase {
  
  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    
    XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading requests before view is loaded")
    
    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request once view is loaded")
    
    sut.simulateUserInitiatedFeedLoad()
    XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request once user initiates a reload")
    
    sut.simulateUserInitiatedFeedLoad()
    XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request once user initiates another reload")
  }
  
  func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
    let (sut, loader) = makeSUT()
    sut.simulateAppearance()
    
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
    
    loader.completeFeedLoading(at: 0)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading is completed")
    
    sut.simulateUserInitiatedFeedLoad()
    XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
    
    loader.completeFeedLoading(at: 1)
    XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
  }

  //MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackMemoryLeaks(loader, file: file, line: line)
    trackMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }
  class LoaderSpy: FeedLoader {
    private var completions = [(FeedLoader.Result) -> Void]()
    var loadCallCount: Int {
      completions.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
      completions.append(completion)
    }
    
    func completeFeedLoading(at index: Int) {
      completions[index](.success([]))
    }
  }
}

private extension FeedViewController {
  func simulateUserInitiatedFeedLoad() {
    refreshControl?.simulatePullToRefresh()
  }
  
  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}
private extension UITableViewController {
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      replaceRefreshControlWithFake()
    }
    beginAppearanceTransition(true, animated: false)
    endAppearanceTransition()
  }
  func replaceRefreshControlWithFake() {
    let fake = FakeUIRefreshControl()
    refreshControl?.allTargets.forEach { target in
      refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
        fake.addTarget(target, action: Selector(action), for: .valueChanged)
      }
    }
    refreshControl = fake
    
  }
}
private class FakeUIRefreshControl: UIRefreshControl {
  private var _isRefreshing = false
  override var isRefreshing: Bool { _isRefreshing }
  
  override func beginRefreshing() {
    _isRefreshing = true
  }
  override func endRefreshing() {
    _isRefreshing = false
  }
}
