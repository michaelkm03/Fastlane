import XCTest
@testable import VictoriousIOSSDK
@testable import victorious
import Nocilla

class CreatorQuestionResponseFetchOperationTests: XCTestCase {
    var validAPIPath: APIPath!
    var currentUserID: User.ID!
    var creatorQuestionResponse: CreatorQuestionResponse!
    
    override func setUp() {
        super.setUp()
        validAPIPath = APIPath(templatePath: "https://vapi-dev.getvictorious.com/v1/content/%%CONTENT_ID%%/user/%%USER_ID%%")
        currentUserID = 1016
        creatorQuestionResponse = CreatorQuestionResponse(questionContentID: "18181", answerContentID: "18182")
        
        LSNocilla.sharedInstance().start()
        
        stubRequest("GET", "https://vapi-dev.getvictorious.com/v1/content" as NSString)
    }
    
    override func tearDown() {
        LSNocilla.sharedInstance().stop()
        super.tearDown()
    }
    
    func testInitializationSuccess() {
        guard let operation = CreatorQuestionResponseFetchOperation(apiPath: validAPIPath, creatorQuestionResponse: creatorQuestionResponse, currentUserID: currentUserID) else {
            XCTFail("Operation initialization failed")
            return
        }
        
        XCTAssertEqual(operation.executionQueue, .background)
        
        operation.queue() { result in
            switch result {
                case .success(_), .cancelled: XCTFail("Operation shouldn't have been cancelled or succeeded because we stubbed the requests")
                case .failure(let error): XCTAssertEqual((error as NSError).code, 2)
            }
        }
    }
}
