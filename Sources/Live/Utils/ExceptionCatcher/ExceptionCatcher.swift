import Foundation

internal func catchException<T>(in closure: () -> T) throws -> T {
    return try RUIExceptionCatcher.catchException(in: {
        return closure()
    }) as! T
}
