import Foundation
import VictoriousIOSSDK

/// A controller to handle receiving, sending, and presenting CreatorQuestionResponse events
class CreatorQuestionResponseController {
    private let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    func fetch(creatorQuestionResponse: CreatorQuestionResponse, completion: ((Result<(Content, Content)>) -> Void)? = nil) {
        
        
    }
}

private extension VDependencyManager {
    var contentFetchAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentFetchURL")
    }
}

private class QuestionAnswerPairFetchOperation: AsyncOperation<(Content, Content)> {
    private let dependencyManager: VDependencyManager
    private let creatorQuestionResponse: CreatorQuestionResponse
    
    private let questionFetchOperation: ContentFetchOperation
    private let answerFetchOperation: ContentFetchOperation
    
    init?(dependencyManager: VDependencyManager, creatorQuestionResponse: CreatorQuestionResponse) {
        self.dependencyManager = dependencyManager
        self.creatorQuestionResponse = creatorQuestionResponse
        
        guard
            let contentFetchAPIPath = dependencyManager.contentFetchAPIPath,
            let currentUserID = VCurrentUser.user?.id
        else {
            Log.warning("Dependency Failure with contentFetchAPIPath: \(dependencyManager.contentFetchAPIPath) and currentUserID: \(VCurrentUser.user?.id)")
            return nil
        }
        
        guard
            let questionFetchOperation = ContentFetchOperation(apiPath: contentFetchAPIPath, currentUserID: String(currentUserID), contentID: creatorQuestionResponse.questionContentID),
            let answerFetchOperation = ContentFetchOperation(apiPath: contentFetchAPIPath, currentUserID: String(currentUserID), contentID: creatorQuestionResponse.answerContentID)
        else {
            Log.warning("Couldn't initialize question or answer operations")
            return nil
        }
        
        self.questionFetchOperation = questionFetchOperation
        self.answerFetchOperation = answerFetchOperation
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(_ finish: @escaping (OperationResult<(Content, Content)>) -> Void) {
        
    }
}
