//
//  FooterTableView.swift
//  ReactantUI
//
//  Created by Matous Hybl on 06/09/2017.
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
    public class FooterTableView: View, ComponentDefinitionContainer {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.footerTableView.allProperties
        }
        
        public override class var availableToolingProperties: [PropertyDescription] {
            return ToolingProperties.footerTableView.allProperties
        }
        
        public var cellType: String?
        public var footerType: String?
        public var cellDefinition: ComponentDefinition?
        public var footerDefinition: ComponentDefinition?
        
        public var componentTypes: [String] {
            return (cellDefinition?.componentTypes ?? [cellType].compactMap { $0 }) + (footerDefinition?.componentTypes ?? [footerType].compactMap { $0 })
        }
        
        public var isAnonymous: Bool {
            return (cellDefinition?.isAnonymous ?? false) || (footerDefinition?.isAnonymous ?? false)
        }
        
        public var componentDefinitions: [ComponentDefinition] {
            return (cellDefinition?.componentDefinitions ?? []) + (footerDefinition?.componentDefinitions ?? [])
        }
        
        public override class var parentModuleImport: String {
            return "Hyperdrive"
        }
        
        public class override func runtimeType() throws -> String {
            return "ReactantTableView & UITableView"
        }
        
        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            guard let cellType = cellType, let footerType = footerType else {
                throw TokenizationError(message: "Initialization should never happen as the view was referenced via field.")
            }
            return RuntimeType(name: "FooterTableView<\(footerType), \(cellType)>", module: "Hyperdrive")
        }
        
        #if canImport(SwiftCodeGen)
        public override func initialization(for platform: RuntimePlatform) throws -> Expression {
            return .constant("\(try runtimeType(for: platform).name)()")
        }
        #endif
        
        public required init(context: UIElementDeserializationContext) throws {
            let node = context.element
            guard let cellType = node.value(ofAttribute: "cell") as String? else {
                throw TokenizationError(message: "cell for FooterTableView was not defined.")
            }
            self.cellType = cellType
            
            guard let footerType = node.value(ofAttribute: "footer") as String? else {
                throw TokenizationError(message: "Footer for FooterTableView was not defined.")
            }
            self.footerType = footerType
            
            if let cellElement = try node.singleOrNoElement(named: "cell") {
                cellDefinition = try context.deserialize(element: cellElement, type: cellType)
            } else {
                cellDefinition = nil
            }
            
            if let footerElement = try node.singleOrNoElement(named: "footer") {
                footerDefinition = try context.deserialize(element: footerElement, type: footerType)
            } else {
                footerDefinition = nil
            }
            
            
            try super.init(context: context)
        }
        
        public override func serialize(context: DataContext) -> XMLSerializableElement {
            var element = super.serialize(context: context)
            if let cellType = cellType, let footerType = footerType {
                element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
                element.attributes.append(XMLSerializableAttribute(name: "footer", value: footerType))
            }
            
            // FIXME serialize footer and cell definition
            return element
        }
        
        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            guard let cellType = cellType, let footerType = footerType else {
                throw LiveUIError(message: "cell or footer for FooterTableView was not defined.")
            }
            let createCell = try context.componentInstantiation(named: cellType)
            let createFooter = try context.componentInstantiation(named: footerType)
            let sectionCount = ToolingProperties.footerTableView.sectionCount.get(from: self.toolingProperties)?.value ?? 5
            let itemCount = ToolingProperties.footerTableView.itemCount.get(from: self.toolingProperties)?.value ?? 5
            let tableView = Hyperdrive.FooterTableView<CellWrapper, CellWrapper>(
                cellFactory: {
                    CellWrapper(wrapped: createCell())
            },
                footerFactory: {
                    CellWrapper(wrapped: createFooter())
            },
                options: [])
                .with(state: .items(Array(repeating: SectionModel(model: EmptyState(), items: Array(repeating: EmptyState(), count: itemCount)), count: sectionCount)))
            
            tableView.tableView.rowHeight = UITableView.automaticDimension
            tableView.tableView.sectionFooterHeight = UITableView.automaticDimension
            
            return tableView
        }
        #endif
    }
    
    public class FooterTableViewProperites: PropertyContainer {
        public let tableViewProperties: TableViewProperties
        public let emptyLabelProperties: LabelProperties
        public let loadingIndicatorProperties: ActivityIndicatorProperties
        
        public required init(configuration: Configuration) {
            tableViewProperties = configuration.namespaced(in: "tableView", TableViewProperties.self)
            emptyLabelProperties = configuration.namespaced(in: "emptyLabel", LabelProperties.self)
            loadingIndicatorProperties = configuration.namespaced(in: "loadingIndicator", ActivityIndicatorProperties.self)
            
            super.init(configuration: configuration)
        }
    }
    
    public class FooterTableViewToolingProperties: PropertyContainer {
        public let sectionCount: ValuePropertyDescription<Int>
        public let itemCount: ValuePropertyDescription<Int>
        
        public required init(configuration: Configuration) {
            sectionCount = configuration.property(name: "tools:sectionCount")
            itemCount = configuration.property(name: "tools:exampleCount")
            
            super.init(configuration: configuration)
        }
    }
}
