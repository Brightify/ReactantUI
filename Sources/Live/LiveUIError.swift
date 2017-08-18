import Foundation

public struct LiveUIError: Error {
    let message: String

    public init(message: String) {
        self.message = message
    }
}
