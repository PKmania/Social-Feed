//
//  SceneDelegate.swift
//  SocialApp
//
//  Created by CN23 on 14/09/26.
//

import UIKit
import SocialFeed
import SocialFeedIOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()
  
  private lazy var store: FeedStore & FeedImageDataStore = {
    try! CoreDataFeedStore(storeURL: NSPersistentContainer
      .defaultDirectoryURL()
      .appendingPathComponent("feed-store.sqlite"))
  }()
  
  private lazy var localFeedLoader: LocalFeedLoader = {
    LocalFeedLoader(store: store, currentDate: Date.init)
  }()
  
  private lazy var remoteFeedLoader: RemoteFeedLoader = {
    let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
    return RemoteFeedLoader(url: url, client: httpClient)
  }()
  
  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
    self.init()
    self.httpClient = httpClient
    self.store = store
  }
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let scene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: scene)
    configureWindow()
  }
  
  func configureWindow() {
    let feedViewController = FeedUIComposer.feedComposeWith(
      feedLoader: makeRemoteFeedLoaderWithLocalFallback,
      imageLoader: makeLocalFeedLoaderWithRemoteFallback)
    let navVC =  UINavigationController(rootViewController: feedViewController)
    window?.rootViewController = navVC
    window?.makeKeyAndVisible()
  }
  
  func makeRemoteFeedLoaderWithLocalFallback() -> FeedLoader.Publisher {
    return remoteFeedLoader
      .loadPublisher()
      .caching(to: localFeedLoader)
      .fallback(to: localFeedLoader.loadPublisher)
  }
  
  func makeLocalFeedLoaderWithRemoteFallback(from url: URL) -> FeedImageDataLoader.Publisher {
    let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
    let localImageLoader =  LocalFeedImageDataLoader(store: store)
    return localImageLoader
      .loadImageDataPublisher(from: url)
      .fallback(to: {
        remoteImageLoader
          .loadImageDataPublisher(from: url)
          .caching(to: localImageLoader, using: url)
      })
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    localFeedLoader.validateCache { _ in }
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    
  }
}

extension RemoteLoader: FeedLoader where Resource == [FeedImage] {}
