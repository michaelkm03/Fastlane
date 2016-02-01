//
//  VAdBreak+Parsable.swift
//  victorious
//
//  Created by Alex Tamoykin on 1/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension VAdBreak: PersistenceParsable {
    func populate(fromSourceModel adBreak: AdBreak) {
        adSystemID = adBreak.adSystemID
        timeout = adBreak.timeout
        adTag = adBreak.adTag
        cannedAdXML = adBreak.cannedAdXML
    }
}
