//
//  ComponentContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

/**
 * The "file"'s context. This context is available throughout a Component's file.
 * It's used to resolve local styles and delegate global style resolving to global context.
 */
public struct ComponentContext: DataContext {
    public let globalContext: GlobalContext
    public let component: ComponentDefinition
    public let allDefinitions: [String: ComponentDefinition]

    public init(globalContext: GlobalContext, component: ComponentDefinition, allDefinitions: [String: ComponentDefinition]) {
        self.globalContext = globalContext
        self.component = component
        self.allDefinitions = allDefinitions
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        guard case .local(let name) = styleName else {
            return globalContext.resolvedStyleName(named: styleName)
        }
        return component.stylesName + "Styles." + name
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .local(let name) = styleName else {
            return globalContext.style(named: styleName)
        }
        return component.styles.first { $0.name.name == name }
    }

    public struct ResolvedStateItem {
        public var name: String
        public var type: SupportedPropertyType.Type
        public var defaultValue: SupportedPropertyType
        public var applications: [Application]

        public struct Application {
            public var element: UIElementBase
            public var property: StateProperty
        }
    }

    public func resolve(state: ComponentDefinition) throws -> [String: ResolvedStateItem] {
        let stateProperties = state.allStateProperties.flatMap { element, properties in
            properties.map { (element: element, property: $0) }
        }

        let applicationsToVerify: [String: [ResolvedStateItem.Application]] = Dictionary(grouping: stateProperties.map { element, property in
            ResolvedStateItem.Application(element: element, property: property) //name: property.name, type: property.type, defaultValue: property.property.anyDescription.anyDefaultValue, element: element)
        }, by: { $0.property.name })

        for (name, applications) in applicationsToVerify {
            guard let firstApplication = applications.first else { continue }
            let verificationResult = applications.dropFirst().allSatisfy { application in
                firstApplication.property.type == application.property.type
            }

            #warning("FIXME Improve error reporting")
            guard verificationResult else {
                throw TokenizationError(message: "Incompatible state item found for name: \(name)!")
            }
        }

        return applicationsToVerify.mapValues { applications in
            let firstApplication = applications.first!
            return ResolvedStateItem(
                name: firstApplication.property.name,
                type: firstApplication.property.type,
                defaultValue: firstApplication.property.property.anyDescription.anyDefaultValue,
                applications: applications)
        }
    }

    public func resolve(actions: [(element: UIElementBase, actions: [HyperViewAction])]) throws -> [ResolvedHyperViewAction] {
        let elementActions: [(element: UIElementBase, action: HyperViewAction, elementAction: UIElementAction)] = actions.flatMap { element, actions in
            actions.compactMap { action in
                guard let elementAction = element.supportedActions.first(where: { $0.matches(action: action) }) else { return nil }
                return (element: element, action: action, elementAction: elementAction)
            }
        }

        #warning("Compute state once in init, not here for improved performance")
        let state = try resolve(state: component)

        let sourcesToVerify: [String: [ResolvedHyperViewAction.Source]] = try Dictionary(grouping: elementActions.map { element, action, elementAction in
            let parameters = try action.parameters.flatMap { label, parameter -> [ResolvedHyperViewAction.Parameter] in
                switch parameter {
                case .inheritedParameters:
                    return elementAction.parameters
                case .constant(let type, let value):
                    guard let foundType = RuntimePlatform.iOS.supportedTypes.first(where: {
                        $0.runtimeType(for: .iOS).name == type && $0 is AttributeSupportedPropertyType.Type
                    }) as? AttributeSupportedPropertyType.Type else {
                        throw TokenizationError(message: "Unknown type \(type) for value \(value)")
                    }

                    let typedValue = try foundType.materialize(from: value)

                return [ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value: typedValue))]
//                    return ResolvedHyperViewAction.Parameter(label: label, kind: .constant(value:     ))
                case .stateVariable(let name):
                    return [ResolvedHyperViewAction.Parameter(label: label, kind: .reference(type: state[name]!.type))]
                case .reference(let targetId, let property):
                    return []
                }
            }

            return ResolvedHyperViewAction.Source(actionName: action.name, element: element, action: elementAction, parameters: parameters)
        }, by: { $0.actionName })

        for (name, actions) in sourcesToVerify {
            guard let firstAction = actions.first else { continue }
            let verificationResult = actions.dropFirst().allSatisfy { action in
                guard action.parameters.count == firstAction.parameters.count else { return false }

                return action.parameters.enumerated().allSatisfy { index, parameter in
                    let firstActionParameter = firstAction.parameters[index]
                    return firstActionParameter.type == parameter.type
                }
            }

            #warning("FIXME Improve error reporting")
            guard verificationResult else {
                throw TokenizationError(message: "Incompatible actions found for name: \(name)!")
            }
        }

        return sourcesToVerify.map { name, sources in
            ResolvedHyperViewAction(name: name, parameters: sources.first!.parameters, sources: sources)
        }

//        return actionsToVerify.values.flatMap { $0 }

//        return [
//            ResolvedHyperViewAction(name: "a", parameters: [
//                ResolvedHyperViewAction.Parameter(label: "abc", kind: .constant(value: 100)),
//                ResolvedHyperViewAction.Parameter(label: "efg", kind: .reference(type: TransformedText.self))
//            ])
//        ]


//        action.parameters.map { label, parameter -> ResolvedHyperViewAction.Parameter in
//            switch parameter {
//            case .inheritedParameters:
//                break
//            case .constant(let type, let value):
//                break
//            case .stateVariable(let name):
//                break
//            case .reference(let targetId, let property):
//                break
//            }
//        }
    }
}

extension ComponentContext: HasGlobalContext { }
