import Foundation
import VictoriousIOSSDK

/// A controller to handle receiving, sending, and presenting CreatorQuestionResponse events
class CreatorQuestionResponseController {
    private let dependencyManager: VDependencyManager
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
}
