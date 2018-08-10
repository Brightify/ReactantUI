//
//  FooterTableView.swift
//  ReactantUI
//
//  Created by Matous Hybl on 06/09/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
import Reactant
import RxDataSources
#endif

public class FooterTableView: View, ComponentDefinitionContainer {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.footerTableView.allProperties
    }

    public override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.footerTableView.allProperties
    }

    public var cellType: String
    public var footerType: String
    public var cellDefinition: ComponentDefinition?
    public var footerDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return (cellDefinition?.componentTypes ?? [cellType]) + (footerDefinition?.componentTypes ?? [footerType])
    }

    public var isAnonymous: Bool {
        return (cellDefinition?.isAnonymous ?? false) || (footerDefinition?.isAnonymous ?? false)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return (cellDefinition?.componentDefinitions ?? []) + (footerDefinition?.componentDefinitions ?? [])
    }

    public override class var parentModuleImport: String {
        return "Reactant"
    }

    public class override func runtimeType() throws -> String {
        return "ReactantTableView"
    }

    public override func initialization() -> String {
        return "FooterTableView<\(footerType), \(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        footerType = try node.value(ofAttribute: "footer")
        if let cellElement = try node.singleOrNoElement(named: "cell") {
            cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
        } else {
            cellDefinition = nil
        }

        if let footerElement = try node.singleOrNoElement(named: "footer") {
            footerDefinition = try ComponentDefinition(node: footerElement, type: footerType)
        } else {
            footerDefinition = nil
        }

        try super.init(node: node)
    }

    public override func serialize(context: DataContext) -> XMLSerializableElement {
        var element = super.serialize(context: context)
        element.attributes.append(XMLSerializableAttribute(name: "cell", value: cellType))
        element.attributes.append(XMLSerializableAttribute(name: "footer", value: footerType))

        // FIXME serialize footer and cell definition
        return element
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        let createCell = try context.componentInstantiation(named: cellType)
        let createFooter = try context.componentInstantiation(named: footerType)
        let sectionCount = ToolingProperties.footerTableView.sectionCount.get(from: self.toolingProperties) ?? 5
        let itemCount = ToolingProperties.footerTableView.itemCount.get(from: self.toolingProperties) ?? 5
        let tableView = Reactant.FooterTableView<CellWrapper, CellWrapper>(
            cellFactory: {
                CellWrapper(wrapped: createCell())
            },
            footerFactory: {
                CellWrapper(wrapped: createFooter())
            })
            .with(state: .items(Array(repeating: SectionModel(model: (), items: Array(repeating: (), count: itemCount)), count: sectionCount)))

        tableView.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableView.sectionFooterHeight = UITableViewAutomaticDimension

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
