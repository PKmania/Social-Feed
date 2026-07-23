//
//  Created by CN23 on 22/07/26.
//

import Foundation
import UIKit
import SocialFeed

final public class FeedRefreshViewController: NSObject {
  public var refreshControl: UIRefreshControl = UIRefreshControl() {
    didSet {
      setupView()
    }
  }
  
  private let feedLoader: FeedLoader
  init(feedLoader: FeedLoader) {
    self.feedLoader = feedLoader
    super.init()
    setupView()
  }
  private func setupView() {
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

  }
  var onRefresh: (([FeedImage]) -> Void)?
  
  @objc func refresh() {
    refreshControl.beginRefreshing()
    feedLoader.load { [weak self] result in
      if let feed = try? result.get() {
        self?.onRefresh?(feed)
      }
      self?.refreshControl.endRefreshing()
    }
  }
}

