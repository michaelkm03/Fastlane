//
//  LiveStreamOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 2/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VLiveStreamModel: NSObject {
    var displayOrder: NSNumber! = 0
    
    let username: String
    let createdAt: NSDate
    let text: String
    
    init(text: String, username: String = "Patrick", createdAt: NSDate = NSDate()) {
        self.username = username
        self.createdAt = createdAt
        self.text = text
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return self === object
    }
}

func createModels() -> [VLiveStreamModel] {
    return [
        VLiveStreamModel(text: "I love you Ariana!"),
        VLiveStreamModel(text: "You rocked at iHeartRadio!!", username: "Sky"),
        VLiveStreamModel(text: "OMG your so cute your dimple!  Why can't I look like you!"),
        VLiveStreamModel(text: "I have no words"),
        VLiveStreamModel(text: "I love you Ariana!", username: "Sky"),
        VLiveStreamModel(text: "You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!"),
        VLiveStreamModel(text: "OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!"),
        VLiveStreamModel(text: "I have no words", username: "Sky"),
        VLiveStreamModel(text: "I love you Ariana!"),
        VLiveStreamModel(text: "You rocked at iHeartRadio!!", username: "Sky"),
        VLiveStreamModel(text: "OMG your so cute your dimple!  Why can't I look like you!"),
        VLiveStreamModel(text: "I have no words"),
        VLiveStreamModel(text: "I love you Ariana!", username: "Sky"),
        VLiveStreamModel(text: "You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!  You rocked at iHeartRadio!!"),
        VLiveStreamModel(text: "OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!  OMG your so cute your dimple!  Why can't I look like you!"),
        VLiveStreamModel(text: "I have no words", username: "Sky"),
    ]
}

final class LiveStreamOperation: RequestOperation, PaginatedOperation {
    
    let request: StreamRequest
    
    required init( request: StreamRequest ) {
        self.request = request
    }
    
    override convenience init() {
        self.init( request: StreamRequest(apiPath: "", sequenceID: nil)! )
    }
    
    override func main() {
        dispatch_sync( dispatch_get_main_queue() ) {
            var displayOrder = self.request.paginator.displayOrderCounterStart
            let models = createModels()
            for model in models {
                model.displayOrder = displayOrder++
            }
            self.results = models
        }
    }
}

final class LiveStreamOperationUpdate: RequestOperation, PaginatedOperation {
    
    let request: StreamRequest
    
    required init( request: StreamRequest ) {
        self.request = request
    }
    
    override convenience init() {
        self.init( request: StreamRequest(apiPath: "", sequenceID: nil)! )
    }
    
    override func main() {
        dispatch_sync( dispatch_get_main_queue() ) {
            if arc4random() % 10 > 2 {
                let models = createModels()
                var results = [AnyObject]()
                for _ in 0..<Int(arc4random() % 4) {
                    let rnd = Int(arc4random() % UInt32(models.count) )
                    results.append( models[rnd] )
                }
                self.results = results
            } else {
                self.results = []
            }
        }
    }
}
