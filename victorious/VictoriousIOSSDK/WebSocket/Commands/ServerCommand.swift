import Foundation

///
/// A command sent *from* the cleint *to* the server.
///
/// NOTE: A `ServerCommand` very much looks like a `ClientCommand` but they are intentionally
/// specified separate so that there can be no confusion between them.
///
public struct ServerCommand {

    // FUTURE: document params
    // Required
    let id: String
    let functionName: String
    let timestamp: Timestamp

    // Optional
    let data: String?

    // MARK: - Initialization

    init(with json: JSON) throws {
        guard
            let id = json["id"].string,
            let functionName = json["functionName"].string,
            let timestamp = json["timestamp"].int64
            else {
                throw ResponseParsingError()
        }

        self.id = id
        self.functionName = functionName
        self.timestamp = Timestamp(value: timestamp)
        self.data = json["data"].string
    }
}
