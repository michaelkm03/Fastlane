/// A pair of user question and creator response in live chat
typealias QuestionAnswerPair = (question: Content, answer: Content)

/// Fetches a QuestionAnswerPair given a CreatorQuestionResponse input. 
/// Basically extracts the question content ID and answer content ID and fetch both of them.
/// Only reports success if both content fetch succeeded.
class CreatorQuestionResponseFetchOperation: AsyncOperation<QuestionAnswerPair> {
    private let dependencyManager: VDependencyManager
    private let creatorQuestionResponse: CreatorQuestionResponse
    
    private let questionFetchOperation: ContentFetchOperation
    private let answerFetchOperation: ContentFetchOperation
    
    init?(dependencyManager: VDependencyManager, creatorQuestionResponse: CreatorQuestionResponse) {
        self.dependencyManager = dependencyManager
        self.creatorQuestionResponse = creatorQuestionResponse
        
        // Prepare the necessary information for content fetch
        guard
            let contentFetchAPIPath = dependencyManager.contentFetchAPIPath,
            let currentUserID = VCurrentUser.user?.id
        else {
            Log.warning("Dependency Failure with contentFetchAPIPath: \(dependencyManager.contentFetchAPIPath) and currentUserID: \(VCurrentUser.user?.id)")
            return nil
        }
        
        // Initialize content fetch operations for the question and the answer
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
    
    override func execute(_ finish: @escaping (OperationResult<QuestionAnswerPair>) -> Void) {
        questionFetchOperation.queue { [weak self] questionResult in
            self?.answerFetchOperation.queue { answerResult in
                switch (questionResult, answerResult) {
                    // We report success if both operation succeeded
                    case (.success(let questionContent), .success(let answerContent)):
                        finish(.success(question: questionContent, answer: answerContent))
                    
                    // Otherwise we report failure
                    default:
                        finish(.failure(NSError(domain: "Question or Answer Content fetch failed", code: 2, userInfo: nil)))
                }
            }
        }
    }
}

private extension VDependencyManager {
    var contentFetchAPIPath: APIPath? {
        return networkResources?.apiPath(forKey: "contentFetchURL")
    }
}
