import XCTest
@testable import VictoriousIOSSDK

class CreatorAnswerTests: XCTestCase {
    func testInitializationSuccess() {
        let payload = [
            "section": "VIP_STAGE",
            "question_content_id": "2454",
            "answer_content_id": "6844"
        ]
        
        let validJSON = JSON(payload)
        
        guard let creatorAnswer = CreatorAnswer(json: validJSON) else {
            XCTFail("CreatorAnswer initialization failed.")
            return
        }
        XCTAssertEqual(creatorAnswer.questionContentID, "2454")
        XCTAssertEqual(creatorAnswer.answerContentID, "6844")
        XCTAssertEqual(creatorAnswer.section, .vip)
    }
    
    func testInitializationFailure() {
        let payload1 = [
            "section": "",
            "question_content_id": "2454",
            "answer_content_id": "6844"
        ]
        
        let payload2 = [
            "section": "VIP_STAGE",
            "question_content_id": "",
            "answer_content_id": "6844"
        ]
        
        let payload3 = [
            "section": "VIP_STAGE",
            "question_content_id": "2454",
            "answer_content_id": ""
        ]
        
        for payload in [payload1, payload2, payload3] {
            let invalidJSON = JSON(payload)
            XCTAssertNil(CreatorAnswer(json: invalidJSON))
        }
    }
}
