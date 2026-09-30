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
  
  private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
  
  public static func feedComposeWith(
    feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
    imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
    selection: @escaping (FeedImage) -> Void = { _ in }
  ) -> ListViewController {
    let presenterAdapter = FeedPresentationAdapter(loader: feedLoader)
    
   let feedController = makeFeedViewController(
    title: FeedPresenter.title
   )
    feedController.onRefresh = presenterAdapter.loadResource
    
    let viewAdapter = FeedViewAdapter(
      controller: feedController,
      imageLoader: imageLoader,
      selection: selection
    )
    
    let presenter = LoadResourcePresenter(
      resourceView: viewAdapter,
      loadingView: WeakRefVirtualProxy(feedController),
      errorView: WeakRefVirtualProxy(feedController),
      mapper: FeedPresenter.map
    )
    presenterAdapter.presenter = presenter
    return feedController
  }

  private static func makeFeedViewController(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
    let feedController = storyboard.instantiateInitialViewController() as! ListViewController
    feedController.title = FeedPresenter.title
    return feedController
  }
}







