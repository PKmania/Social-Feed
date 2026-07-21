//
//  Created by CN23 on 11/07/26.
//

import UIKit
import SocialFeed
public protocol FeedImageDataLoader {
  func loadImageData(from url: URL)
  func cancelImageDataLoad(from url: URL)
}

final public class FeedViewController: UITableViewController {
  private var feedLoader: FeedLoader?
  private var imageLoader: FeedImageDataLoader?
  private var viewAppeared = false
  private var tableModel = [FeedImage]()
  
  public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
    self.init()
    self.feedLoader = feedLoader
    self.imageLoader = imageLoader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    
    load()
  }
  
  public override func viewIsAppearing(_ animated: Bool) {
    super.viewIsAppearing(animated)
    if !viewAppeared {
      refreshControl?.beginRefreshing()
      viewAppeared = true
    }
  }
  
  @objc private func load() {
    refreshControl?.beginRefreshing()
    feedLoader?.load { [weak self] result in
      if let feed = try? result.get() {
        self?.tableModel = feed
        self?.tableView.reloadData()
      }
      self?.refreshControl?.endRefreshing()
    }
  }
}

extension FeedViewController {
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tableModel.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = tableModel[indexPath.item]
    let cell = FeedImageCell()
    cell.locationContainer.isHidden = (model.location == nil)
    cell.descriptionLabel.text = model.description
    cell.locationLabel.text = model.location
    imageLoader?.loadImageData(from: model.url)
    return cell
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let model = tableModel[indexPath.item]
    imageLoader?.cancelImageDataLoad(from: model.url)
  }
}
