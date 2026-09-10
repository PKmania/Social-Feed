//
//  Created by CN23 on 23/07/26.
//

import Foundation
import SocialFeed
import UIKit

public final class FeedUIComposer {
  private init() {}
  public static func feedComposeWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
    let presenterAdapter = FeedLoaderPresentationAdaptor(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
   let feedController = FeedViewController.makeWith(delegate: presenterAdapter, title: FeedPresenter.title)
    let presenter = FeedPresenter(feedView: FeedViewAdapter(controller: feedController, imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)), feedLoadingView: WeakRefVirtualProxy(feedController))
    presenterAdapter.presenter = presenter
    return feedController
  }
}

private extension FeedViewController {
  static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = delegate
    feedController.title = FeedPresenter.title
    return feedController
  }
}







