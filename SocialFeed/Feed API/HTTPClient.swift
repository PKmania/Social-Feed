//
//  Created by CN23 on 20/04/26.
//

import Foundation

public enum HTTPClientResult {
  case success((Data, HTTPURLResponse))
  case failure(Error)
}

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
