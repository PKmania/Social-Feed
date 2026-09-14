//
//  Created by CN23 on 30/06/26.
//

import CoreData

public final class CoreDataFeedStore {
  private static let modelName = "FeedStore"
  private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))
  private let container: NSPersistentContainer
  private let context: NSManagedObjectContext
  public init(storeURL: URL) throws {
    guard let model = CoreDataFeedStore.model else {
      throw StoreError.modelNotFound
    }
    
    do {
      container = try NSPersistentContainer.load(name: CoreDataFeedStore.modelName, model: model, url: storeURL)
      context = container.newBackgroundContext()
    } catch {
      throw StoreError.failedToLoadPersistentContainer(error)
    }
  }
  
  enum StoreError: Error {
    case modelNotFound
    case failedToLoadPersistentContainer(Error)
  }
  
  func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
    let context = self.context
    context.perform { action(context) }
  }
  
  private func cleanUpReferencesToPersistentStores() {
    context.performAndWait {
      let coordinator = self.container.persistentStoreCoordinator
      try? coordinator.persistentStores.forEach(coordinator.remove)
    }
  }
  
  deinit {
    cleanUpReferencesToPersistentStores()
  }
}
