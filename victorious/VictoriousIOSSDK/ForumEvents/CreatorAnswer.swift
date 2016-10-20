/// A creator's answer to a fan's question in live chat.
/// It contains both the Question Content ID and the Answer Content ID.
public struct CreatorAnswer {
    public let section: StageSection
    public let questionContentID: Content.ID
    public let answerContentID: Content.ID
    
    public init?(json: JSON) {
        let sectionString = json["section"].stringValue
        
        guard
            let section = StageSection(section: sectionString),
            let questionID = json["question_content_id"].string,
            let answerID = json["answer_content_id"].string,
            !questionID.isEmpty && !answerID.isEmpty
        else {
            return nil
        }
        
        self.section = section
        self.questionContentID = questionID
        self.answerContentID = answerID
    }
}
