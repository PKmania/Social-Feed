//
//  Created by CN23 on 28/04/26.
//

import Foundation


func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
  return URL(string: "http://any-url.com")!
}
