//
//  ShowTermsOfServiceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowTermsOfServiceOperation: ShowWebContentOperation {
    init(originViewController: UIViewController, forceModal: Bool = false, animated: Bool = true) {
        super.init(
            originViewController: originViewController,
            title: NSLocalizedString("Terms of Service", comment: ""),
            createFetchOperation: { TermsOfServiceOperation() },
            forceModal: forceModal,
            animated: animated
        )
    }
}
