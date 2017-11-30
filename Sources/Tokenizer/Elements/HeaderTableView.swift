//
//  HeaderTableView.swift
//  ReactantUI
//
//  Created by Matous Hybl on 06/09/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
    import Reactant
    import RxDataSources
#endif

public class HeaderTableView: View, ComponentDefinitionContainer {
    override class var availableProperties: [PropertyDescription] {
        return Properties.view.allProperties
    }

    override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.headerTableView.allProperties
    }

    public var cellType: String
    public var headerType: String
    public var cellDefinition: ComponentDefinition?
    public var headerDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return (cellDefinition?.componentTypes ?? [cellType]) + (headerDefinition?.componentTypes ?? [headerType])
    }

    public var isAnonymous: Bool {
        return (cellDefinition?.isAnonymous ?? false) || (headerDefinition?.isAnonymous ?? false)
    }

    public var componentDefinitions: [ComponentDefinition] {
        return (cellDefinition?.componentDefinitions ?? []) + (headerDefinition?.componentDefinitions ?? [])
    }

    public class override var runtimeType: String {
        return "UITableView"
    }

    public override var initialization: String {
        return "HeaderTableView<\(headerType), \(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        headerType = try node.value(ofAttribute: "header")
        if let cellElement = try node.singleOrNoElement(named: "cell") {
            cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
        } else {
            cellDefinition = nil
        }

        if let headerElement = try node.singleOrNoElement(named: "header") {
            headerDefinition = try ComponentDefinition(node: headerElement, type: headerType)
        } else {
            headerDefinition = nil
        }

        try super.init(node: node)
    }

    public override func serialize() -> MagicElement {
        var element = super.serialize()
        element.attributes.append(MagicAttribute(name: "cell", value: cellType))
        element.attributes.append(MagicAttribute(name: "header", value: headerType))
        return element
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        let createCell = try ReactantLiveUIManager.shared.componentInstantiation(named: cellType)
        let createHeader = try ReactantLiveUIManager.shared.componentInstantiation(named: headerType)
        let sectionCount = ToolingProperties.headerTableView.sectionCount.get(from: self.toolingProperties) ?? 5
        let itemCount = ToolingProperties.headerTableView.itemCount.get(from: self.toolingProperties) ?? 5
        let tableView = Reactant.HeaderTableView<CellHack, CellHack>(
            cellFactory: {
                CellHack(wrapped: createCell())
            },
            headerFactory: {
                CellHack(wrapped: createHeader())
            })
            .with(state: .items(Array(repeating: SectionModel(model: (), items: Array(repeating: (), count: itemCount)), count: sectionCount)))

        tableView.tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableView.sectionHeaderHeight = UITableViewAutomaticDimension

        return tableView
    }

    public final class CellHack: ViewBase<Void, Void> {
        private let wrapped: UIView

        public init(wrapped: UIView) {
            self.wrapped = wrapped
            super.init()
        }

        public override func loadView() {
            children(
                wrapped
            )
        }

        public override func setupConstraints() {
            wrapped.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    #endif
}

public class HeaderTableViewToolingProperties: PropertyContainer {
    public let sectionCount: ValuePropertyDescription<Int>
    public let itemCount: ValuePropertyDescription<Int>

    public required init(configuration: Configuration) {
        sectionCount = configuration.property(name: "tools:sectionCount")
        itemCount = configuration.property(name: "tools:exampleCount")

        super.init(configuration: configuration)
    }
}
