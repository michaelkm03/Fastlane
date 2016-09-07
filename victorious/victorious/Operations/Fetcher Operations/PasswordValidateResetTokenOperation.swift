//
//  PasswordValidateResetTokenOperationswift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

final class PasswordValidateResetTokenOperation: RemoteFetcherOperation {
    
    let request: PasswordResetRequest!
    
    init(userToken: String, deviceToken: String) {
        self.request = PasswordResetRequest(userToken: userToken, deviceToken: deviceToken)
    }
    
    override func main() {
        requestExecutor.executeRequest(request, onComplete: nil, onError: nil)
    }
}
