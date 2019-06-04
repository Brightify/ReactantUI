//
//  SimulatedSeparatorTableView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
import Hyperdrive
import RxDataSources
#endif

extension Module.UIKit {
    public class SimulatedSeparatorTableView: View, ComponentDefinitionContainer {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.simulatedSeparator.allProperties
        }
        
        public override class var availableToolingProperties: [PropertyDescription] {
            return ToolingProperties.simulatedSeparatorTableView.allProperties
        }
        
        public var cellType: String?
        public var cellDefinition: ComponentDefinition?
        
        public var componentTypes: [String] {
            return cellDefinition?.componentTypes ?? [cellType].compactMap { $0 }
        }
        
        public var isAnonymous: Bool {
            return cellDefinition?.isAnonymous ?? false
        }
        
        public var componentDefinitions: [ComponentDefinition] {
            return cellDefinition?.componentDefinitions ?? []
        }
        
        public override class var parentModuleImport: String {
            return "Hyperdrive"
        }
        
        public class override func runtimeType() -> String {
            return "ReactantTableView & UITableView"
        }
        
        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            guard let cellType = cellType else {
                throw TokenizationError(message: "Initialization should never happen as the view was referenced via field.")
            }
            return RuntimeType(name: "SimulatedSeparatorTableView<\(cellType)>", module: "Hyperdrive")
        }
        
        #if canImport(SwiftCodeGen)
        public override func initialization(for platform: RuntimePlatform) throws -> Expression {
            return .constant("\(try runtimeType(for: platform).name)()")
        }
        #endif
        
        public required init(context: UIElementDeserializationContext) throws {
            let node = context.element
            if let field = node.value(ofAttribute: "field") as String?, !field.isEmpty {
                cellType = nil
                cellDefinition = nil
            } else {
                guard let cellType = node.value(ofAttribute: "cell") as String? else {
                    throw TokenizationError(message: "cell for SimulatedSeparatorTableView was not defined.")
                }
                self.cellType = cellType
                
                if let cellElement = try node.singleOrNoElement(named: "cell") {
                    cellDefinition = try context.deserialize(element: cellElement, type: cellType)
                } else {
                    cellDefinition = nil
                }
            }
            
            try super.init(context: context)
        }
        
        public override func serialize(context: DataContext) -> XMLSerializableElement {
            var element = super.serialize(context: context)
            if let cellType = cellType {
                element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
            }
            
            // FIXME serialize anonymous components
            return element
        }
        
        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            guard let cellType = cellType else {
                throw LiveUIError(message: "cell for SimulatedSeparatorTableView was not defined.")
            }
            let createCell = try context.componentInstantiation(named: cellType)
            let exampleCount = ToolingProperties.simulatedSeparatorTableView.exampleCount.get(from: self.toolingProperties)?.value ?? 5
            let tableView =  Hyperdrive.SimulatedSeparatorTableView<CellWrapper>(cellFactory: {
                CellWrapper(wrapped: createCell())
            }, options: []).with(state: .items(Array(repeating: EmptyState(), count: exampleCount)))
            
            tableView.tableView.rowHeight = UITableView.automaticDimension
            
            return tableView
        }
        #endif
    }
    
    public class SimulatedSeparatorTableViewProperties: PropertyContainer {
        public let separatorHeight: AssignablePropertyDescription<Double>
        public let separatorColor: AssignablePropertyDescription<UIColorPropertyType?>
        public let tableViewProperties: TableViewProperties
        public let emptyLabelProperties: LabelProperties
        public let loadingIndicatorProperties: ActivityIndicatorProperties
        
        public required init(configuration: Configuration) {
            separatorHeight = configuration.property(name: "separatorHeight", defaultValue: -1)
            separatorColor = configuration.property(name: "separatorColor")
            tableViewProperties = configuration.namespaced(in: "tableView", TableViewProperties.self)
            emptyLabelProperties = configuration.namespaced(in: "emptyLabel", LabelProperties.self)
            loadingIndicatorProperties = configuration.namespaced(in: "loadingIndicator", ActivityIndicatorProperties.self)
            
            super.init(configuration: configuration)
        }
    }
    
    public class SimulatedSeparatorTableViewToolingProperties: PropertyContainer {
        public let exampleCount: ValuePropertyDescription<Int>
        
        public required init(configuration: Configuration) {
            exampleCount = configuration.property(name: "tools:exampleCount")
            
            super.init(configuration: configuration)
        }
    }
}
