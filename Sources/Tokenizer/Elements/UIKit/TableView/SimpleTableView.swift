//
//  SimpleTableView.swift
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
    public class SimpleTableView: View, ComponentDefinitionContainer {
        public override class var availableProperties: [PropertyDescription] {
            return Properties.simpleTableView.allProperties
        }

        public override class var availableToolingProperties: [PropertyDescription] {
            return ToolingProperties.simpleTableView.allProperties
        }

        public var cellType: String?
        public var headerType: String?
        public var footerType: String?
        public var cellDefinition: ComponentDefinition?
        public var headerDefinition: ComponentDefinition?
        public var footerDefinition: ComponentDefinition?

        public var componentTypes: [String] {
            return (cellDefinition?.componentTypes ?? [cellType].compactMap { $0 })
                + (headerDefinition?.componentTypes ?? [headerType].compactMap { $0 })
                + (footerDefinition?.componentTypes ?? [footerType].compactMap { $0 })
        }

        public var isAnonymous: Bool {
            return (cellDefinition?.isAnonymous ?? false)
                || (headerDefinition?.isAnonymous ?? false)
                || (footerDefinition?.isAnonymous ?? false)
        }

        public var componentDefinitions: [ComponentDefinition] {
            return (cellDefinition?.componentDefinitions ?? [])
                + (headerDefinition?.componentDefinitions ?? [])
                + (footerDefinition?.componentDefinitions ?? [])
        }

        public class override func runtimeType() -> String {
            return "ReactantTableView & UITableView"
        }

        public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
            guard let headerType = headerType, let cellType = cellType, let footerType = footerType else {
                throw TokenizationError(message: "Initialization should never happen as the view was referenced via field.")
            }
            return RuntimeType(name: "SimpleTableView<\(headerType), \(cellType), \(footerType)>", module: "Hyperdrive")
        }

        public override class var parentModuleImport: String {
            return "Hyperdrive"
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
                headerType = nil
                footerType = nil
                cellDefinition = nil
                headerDefinition = nil
                footerDefinition = nil
            } else {
                guard let cellType = node.value(ofAttribute: "cell") as String? else {
                    throw TokenizationError(message: "cell for SimpleTableView was not defined.")
                }
                self.cellType = cellType

                guard let headerType = node.value(ofAttribute: "header") as String? else {
                    throw TokenizationError(message: "header for SimpleTableView was not defined.")
                }
                self.headerType = headerType

                guard let footerType = node.value(ofAttribute: "footer") as String? else {
                    throw TokenizationError(message: "footer for SimpleTableView was not defined.")
                }
                self.footerType = footerType

                if let cellElement = try node.singleOrNoElement(named: "cell") {
                    cellDefinition = try context.deserialize(element: cellElement, type: cellType)
                } else {
                    cellDefinition = nil
                }

                if let headerElement = try node.singleOrNoElement(named: "header") {
                    headerDefinition = try context.deserialize(element: headerElement, type: headerType)
                } else {
                    headerDefinition = nil
                }

                if let footerElement = try node.singleOrNoElement(named: "footer") {
                    footerDefinition = try context.deserialize(element: footerElement, type: footerType)
                } else {
                    footerDefinition = nil
                }
            }

            try super.init(context: context)
        }

        public override func serialize(context: DataContext) -> XMLSerializableElement {
            var element = super.serialize(context: context)
            if let cellType = cellType, let headerType = headerType, let footerType = footerType {
                element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
                element.attributes.append(XMLSerializableAttribute(name: "header", value: headerType))
                element.attributes.append(XMLSerializableAttribute(name: "footer", value: footerType))
            }

            // FIXME serialize anonymous cells
            return element
        }

        #if canImport(UIKit)
        public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
            guard let cellType = cellType, let headerType = headerType, let footerType = footerType else {
                throw LiveUIError(message: "cell, header or footer for SimpleTableView was not defined.")
            }
            let createCell = try context.componentInstantiation(named: cellType)
            let createHeader = try context.componentInstantiation(named: headerType)
            let createFooter = try context.componentInstantiation(named: footerType)
            let sectionCount = ToolingProperties.headerTableView.sectionCount.get(from: self.toolingProperties)?.value ?? 5
            let itemCount = ToolingProperties.headerTableView.itemCount.get(from: self.toolingProperties)?.value ?? 5
            let tableView = Hyperdrive.SimpleTableView<CellWrapper, CellWrapper, CellWrapper>(
                cellFactory: {
                    CellWrapper(wrapped: createCell())
            },
                headerFactory: {
                    CellWrapper(wrapped: createHeader())
            },
                footerFactory: {
                    CellWrapper(wrapped: createFooter())
            },
                options: [])
                .with(state: .items(Array(repeating: SectionModel(model: (header: EmptyState(), footer: EmptyState()),
                                                                  items: Array(repeating: EmptyState(), count: itemCount)),
                                          count: sectionCount)))

            tableView.tableView.rowHeight = UITableView.automaticDimension
            tableView.tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.tableView.sectionFooterHeight = UITableView.automaticDimension

            return tableView
        }
        #endif
    }

    public class SimpleTableViewProperites: PropertyContainer {
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


    public class SimpleTableViewToolingProperties: PropertyContainer {
        public let sectionCount: ValuePropertyDescription<Int>
        public let itemCount: ValuePropertyDescription<Int>

        public required init(configuration: Configuration) {
            sectionCount = configuration.property(name: "tools:sectionCount")
            itemCount = configuration.property(name: "tools:exampleCount")

            super.init(configuration: configuration)
        }
    }
}
