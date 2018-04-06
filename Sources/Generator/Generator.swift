import Foundation
import Tokenizer

public enum SwiftVersion: Int {
    case swift4_0
    case swift4_1

    public init?(raw: String) {
        switch raw {
        case "4.0":
            self = .swift4_0
        case "4.1":
            self = .swift4_1
        default:
            return nil
        }
    }
}

extension SwiftVersion: Comparable {
    public static func <(lhs: SwiftVersion, rhs: SwiftVersion) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct GeneratorConfiguration {
    public let minimumMajorVersion: Int
    public let localXmlPath: String
    public let isLiveEnabled: Bool
    public let swiftVersion: SwiftVersion
    
    public init(minimumMajorVersion: Int, localXmlPath: String, isLiveEnabled: Bool, swiftVersion: SwiftVersion) {
        self.minimumMajorVersion = minimumMajorVersion
        self.localXmlPath = localXmlPath
        self.isLiveEnabled = isLiveEnabled
        self.swiftVersion = swiftVersion
    }
}

public struct GeneratorError: Error, LocalizedError {
    public let message: String

    public var errorDescription: String? {
        return message
    }

    public var localizedDescription: String {
        return message
    }
}

public class Generator {

    let configuration: GeneratorConfiguration

    var nestLevel: Int = 0

    init(configuration: GeneratorConfiguration) {
        self.configuration = configuration
    }
    
    var output = ""

    func generate(imports: Bool) throws -> String {
        return output
    }

    func l(_ line: String = "") {
        output.append((0..<nestLevel).map { _ in "    " }.joined() + line + "\n")
    }

    func l(_ line: String = "", _ f: () throws -> Void) throws {
        output.append((0..<nestLevel).map { _ in "    " }.joined() + line)

        nestLevel += 1
        output.append(" {" + "\n")
        try f()
        nestLevel -= 1
        l("}")
    }

    func l(_ line: String = "", _ f: () -> Void) {
        output.append((0..<nestLevel).map { _ in "    " }.joined() + line)

        nestLevel += 1
        output.append(" {" + "\n")
        f()
        nestLevel -= 1
        l("}")
    }
    
    func ifSimulator(_ commands: String) -> String {
        if configuration.swiftVersion >= .swift4_1 {
            return """
            #if targetEnvironment(simulator)
                \(commands)
            #endif
            """
        } else {
            return """
            #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))
                \(commands)
            #endif
            """
        }
    }
}
