import Foundation
import VictoriousIOSSDK

/// A controller to handle receiving, sending, and presenting CreatorQuestionResponse events
class CreatorQuestionResponseController {
    
    private let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    func fetch(creatorQuestionResponse: CreatorQuestionResponse, completion: ((QuestionAnswerPair) -> Void)? = nil) {
        CreatorQuestionResponseFetchOperation(dependencyManager: dependencyManager, creatorQuestionResponse: creatorQuestionResponse)?.queue { result in
            switch result {
                case .success(let questionAnswerPair): completion?(questionAnswerPair)
                case .cancelled, .failure(_): Log.warning("Question Answer Pair Fetching failed or cancelled")
            }
        }
    }
}
