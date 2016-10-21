/// A creator's response to a fan's question in live chat.
/// It contains both the Question Content ID and the Answer Content ID.
public struct CreatorQuestionResponse {
    public let questionContentID: Content.ID
    public let answerContentID: Content.ID
    
    public init?(json: JSON) {
        guard
            let questionID = json["question_content_id"].string,
            let answerID = json["answer_content_id"].string,
            !questionID.isEmpty && !answerID.isEmpty
        else {
            return nil
        }
        
        self.questionContentID = questionID
        self.answerContentID = answerID
    }
    
    public init(questionContentID: Content.ID, answerContentID: Content.ID) {
        self.questionContentID = questionContentID
        self.answerContentID = answerContentID
    }
}
