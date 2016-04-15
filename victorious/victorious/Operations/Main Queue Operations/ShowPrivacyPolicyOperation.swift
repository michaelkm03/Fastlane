//
//  ShowPrivacyPolicyOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowPrivacyPolicyOperation: ShowWebContentOperation {
    init(originViewController: UIViewController, forceModal: Bool = false, animated: Bool = true) {
        super.init(
            originViewController: originViewController,
            title: NSLocalizedString("Privacy Policy", comment: ""),
            createFetchOperation: { PrivacyPolicyOperation() },
            forceModal: forceModal,
            animated: animated
        )
    }
}
