//
//  Created by CN23 on 11/07/26.
//

import UIKit
import SocialFeed
public protocol FeedImageDataLoaderTask {
  func cancel()
}

public protocol FeedImageDataLoader {
  typealias Result = Swift.Result<Data, Error>
  func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

final public class FeedViewController: UITableViewController {
  private var feedLoader: FeedLoader?
  private var imageLoader: FeedImageDataLoader?
  private var viewAppeared = false
  private var tableModel = [FeedImage]()
  private var tasks = [IndexPath: FeedImageDataLoaderTask]()
  
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
    cell.feedImageView.image = nil
    cell.feedImageContainer.startShimmering()
    cell.feedImageRetryButton.isHidden = true
    
    let loadImage = { [weak self, weak cell] in
      guard let self = self else { return }

      self.tasks[indexPath] = self.imageLoader?.loadImageData(from: model.url) { [weak cell] result in
        let data = try? result.get()
        let image = data.map(UIImage.init) ?? nil
        cell?.feedImageView.image = image
        cell?.feedImageRetryButton.isHidden = (image != nil)
        cell?.feedImageContainer.stopShimmering()
      }
    }

    cell.onRetry = loadImage
    loadImage()
    return cell
  }
  
  public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    tasks[indexPath]?.cancel()
  }
}
