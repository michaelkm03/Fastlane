import XCTest
@testable import VictoriousIOSSDK

class CreatorQuestionResponseTests: XCTestCase {
    func testInitializationSuccess() {
        let payload = [
            "section": "VIP_STAGE",
            "question_content_id": "2454",
            "answer_content_id": "6844"
        ]
        
        let validJSON = JSON(payload)
        
        guard let CreatorQuestionResponse = CreatorQuestionResponse(json: validJSON) else {
            XCTFail("CreatorQuestionResponse initialization failed.")
            return
        }
        XCTAssertEqual(CreatorQuestionResponse.questionContentID, "2454")
        XCTAssertEqual(CreatorQuestionResponse.answerContentID, "6844")
        XCTAssertEqual(CreatorQuestionResponse.section, .vip)
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
            XCTAssertNil(CreatorQuestionResponse(json: invalidJSON))
        }
    }
}
