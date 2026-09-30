//
//  FeedViewController+TestHelpers.swift
//  SocialAppTests
//
//  Created by CN23 on 21/09/26.
//

import Foundation
import SocialFeedIOS
import UIKit

extension ListViewController {
  
  func simulateUserInitiatedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  func simulateErrorViewTap() {
    errorView.simulateTap()
  }
  
  var errorMessage: String? {
    return errorView.message
  }
  
  var isShowingLoadingIndicator: Bool {
    refreshControl?.isRefreshing == true
  }
  
  private var feedImageSection: Int {
    return 0
  }
  
  func numberOfRenderedFeedImageViews() -> Int{
    tableView.numberOfSections == 0 ? 0 :  tableView.numberOfRows(inSection: feedImageSection)
  }
  
  @discardableResult
  func simulateFeedImageViewVisible(at row: Int) -> FeedImageCell? {
    return feedImageView(at: row) as? FeedImageCell
  }
  
  @discardableResult
  func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
    let view = simulateFeedImageViewVisible(at: row)
    
    let ds = tableView.delegate
    let indexPath = IndexPath(row: row, section: feedImageSection)
    ds?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    return view
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    guard numberOfRenderedFeedImageViews() > row else {
      return nil
    }
    let ds = tableView.dataSource
    let indexPath = IndexPath(row: row, section: feedImageSection)
    return ds?.tableView(tableView, cellForRowAt: indexPath)
  }
  
  func simulateFeedImageViewNearVisible(at row: Int) {
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImageSection)
    ds?.tableView(tableView, prefetchRowsAt: [index])
  }
  
  func simulateFeedImageViewNotNearVisible(at row: Int) {
    simulateFeedImageViewNearVisible(at: row)
    let ds = tableView.prefetchDataSource
    let index = IndexPath(row: row, section: feedImageSection)
    ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
  }
  
  func renderedFeedImageData(at index: Int) -> Data? {
    return simulateFeedImageViewVisible(at: index)?.renderedImage
  }
  
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        tableView.numberOfSections == 0 ? 0 :  tableView.numberOfRows(inSection: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
        guard numberOfRenderedComments() > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index) as? ImageCommentCell
    }

    private var commentsSection: Int {
        return 0
    }
}
 
extension ListViewController {
  func simulateAppearance() {
    if !isViewLoaded {
      loadViewIfNeeded()
      prepareForFirstAppearance()
    }
    beginAppearanceTransition(true, animated: false)
    endAppearanceTransition()
  }
  
  private func prepareForFirstAppearance() {
    setSmallFrameToPreventRenderingCells()
    replaceRefreshControlWithFake()
  }
  
  private func setSmallFrameToPreventRenderingCells() {
    //      tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
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
