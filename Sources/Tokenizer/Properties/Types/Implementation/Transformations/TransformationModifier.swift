//
//  TransformationModifier.swift
//  Pods
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

// FIXME Shouldn't this be XMLDeserializable/Serializable?
public enum TransformationModifier {
    case identity
    case rotate(by: Double)
    case scale(byX: Double, byY: Double)
    case translate(byX: Double, byY: Double)
}

extension TransformationModifier {
    
    public var generated: String {
        switch self {
        case .identity:
            return ".identity"
        case .rotate(let degrees):
            // FIXME when #41 is fixed in Hyperdrive, rework this
            return "rotate(\((.pi/180) * degrees))"
        case .scale(let x, let y):
            return "scale(x: \(x), y: \(y))"
        case .translate(let x, let y):
            return "translate(x: \(x), y: \(y))"
        }
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        switch self {
        case .identity:
            return "identity"
        case .rotate(let degrees):
            return "rotate(\(degrees))"
        case .scale(let x, let y):
            return "scale(x: \(x), y: \(y))"
        case .translate(let x, let y):
            return "translate(x: \(x), y: \(y))"
        }
    }
    #endif
}
