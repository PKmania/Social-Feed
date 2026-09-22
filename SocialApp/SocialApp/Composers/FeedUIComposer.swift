//
//  Created by CN23 on 23/07/26.
//

import Foundation
import SocialFeed
import UIKit
import SocialFeedIOS
import Combine

public final class FeedUIComposer {
  private init() {}
  public static func feedComposeWith(
    feedLoader: @escaping () -> FeedLoader.Publisher,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
  ) -> FeedViewController {
    let presenterAdapter = FeedLoaderPresentationAdaptor(feedLoader: feedLoader)
    
   let feedController = makeFeedViewController(
    delegate: presenterAdapter,
    title: FeedPresenter.title
   )
    
    let viewAdapter = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
    
    let presenter = FeedPresenter(feedView: viewAdapter, loadingView: WeakRefVirtualProxy(feedController), errorView: WeakRefVirtualProxy(feedController))
    presenterAdapter.presenter = presenter
    return feedController
  }

  private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
    feedController.delegate = delegate
    feedController.title = FeedPresenter.title
    return feedController
  }
}







