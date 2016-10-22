import Foundation
import VictoriousIOSSDK

/// A controller to handle receiving, sending, and presenting CreatorQuestionResponse events
class CreatorQuestionResponseController {
    
    private let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    /// Completion block is only called when fetch is performed successfully
    func fetch(creatorQuestionResponse: CreatorQuestionResponse, completion: ((QuestionAnswerPair) -> Void)? = nil) {
        guard
            let apiPath = dependencyManager.contentFetchAPIPath,
            let currentUserID = VCurrentUser.user?.id
        else {
            Log.warning("Missing Content Fetch APIPath or Current User ID")
            return
        }
        
        CreatorQuestionResponseFetchOperation(apiPath: apiPath, creatorQuestionResponse: creatorQuestionResponse, currentUserID: currentUserID)?.queue { result in
            switch result {
                case .success(let questionAnswerPair): completion?(questionAnswerPair)
                case .cancelled, .failure(_): Log.warning("Question Answer Pair Fetching failed or cancelled")
            }
        }
    }
}

private extension VDependencyManager {
    var contentFetchAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentFetchURL")
    }
}
