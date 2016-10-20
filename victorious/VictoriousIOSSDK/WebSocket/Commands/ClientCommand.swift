import Foundation

///
/// A command sent *from* the server *to* the client.
///
/// NOTE: A `ClientCommand` very much looks like a `ServerCommand` but they are intentionally
/// specified separate so that there can be no confusion between them.
///
public struct ClientCommand {

    // FUTURE: document params
    // Required
    let id: String
    let functionName: String
    let timestamp: Timestamp

    // Optional
    let data: String?
    let error: WebSocketError?

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
        self.error = WebSocketError(json: json["json"])
    }
}
