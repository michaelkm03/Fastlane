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
    }
    
    override func tearDown() {
        super.tearDown()
        
        LSNocilla.sharedInstance().clearStubs()
        LSNocilla.sharedInstance().stop()
    }
    
    func testInitializationSuccess() {
        let expectation = self.expectation(description: "testInitializationSuccess")
        stubRequest("GET", "https://vapi-dev.getvictorious.com/v1/content/18181/user/1016" as NSString)
        stubRequest("GET", "https://vapi-dev.getvictorious.com/v1/content/18182/user/1016" as NSString)
        
        guard let operation = CreatorQuestionResponseFetchOperation(apiPath: validAPIPath, creatorQuestionResponse: creatorQuestionResponse, currentUserID: currentUserID) else {
            XCTFail("Operation initialization failed")
            return
        }
        
        XCTAssertEqual(operation.executionQueue, .background)
        
        operation.execute { result in
            switch result {
                case .success(_), .cancelled:
                    XCTFail("Operation shouldn't have been cancelled or succeeded because we stubbed the requests")
                case .failure(let error):
                    XCTAssertEqual((error as NSError).code, 2)
                    expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
}
