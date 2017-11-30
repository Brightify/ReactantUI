//
//  SimulatedSeparatorTableView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
import Reactant
import RxDataSources
#endif

public class SimulatedSeparatorTableView: View, ComponentDefinitionContainer {
    override class var availableProperties: [PropertyDescription] {
        return Properties.simulatedSeparator.allProperties
    }

    override class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.simulatedSeparatorTableView.allProperties
    }

    public var cellType: String
    public var cellDefinition: ComponentDefinition?

    public var componentTypes: [String] {
        return cellDefinition?.componentTypes ?? [cellType]
    }

    public var isAnonymous: Bool {
        return cellDefinition?.isAnonymous ?? false
    }

    public var componentDefinitions: [ComponentDefinition] {
        return cellDefinition?.componentDefinitions ?? []
    }

    public class override var runtimeType: String {
        return "UITableView"
    }

    public override var initialization: String {
        return "SimulatedSeparatorTableView<\(cellType)>()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        cellType = try node.value(ofAttribute: "cell")
        if let cellElement = try node.singleOrNoElement(named: "cell") {
            cellDefinition = try ComponentDefinition(node: cellElement, type: cellType)
        } else {
            cellDefinition = nil
        }

        try super.init(node: node)
    }

    public override func serialize() -> MagicElement {
        var element = super.serialize()
        element.attributes.append(MagicAttribute(name: "cell", value: cellType))
        return element
    }

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        let createCell = try ReactantLiveUIManager.shared.componentInstantiation(named: cellType)
        let tableView =  Reactant.SimulatedSeparatorTableView<CellHack>(cellFactory: {
            CellHack(wrapped: createCell())
    }).with(state: .items(Array(repeating: (), count: ToolingProperties.simulatedSeparatorTableView.exampleCount.get(from: self.toolingProperties) ?? 5)))

        tableView.tableView.rowHeight = UITableViewAutomaticDimension

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

public class SimulatedSeparatorTableViewProperties: PropertyContainer {
    public let separatorHeight: AssignablePropertyDescription<Float>
    public let separatorColor: AssignablePropertyDescription<UIColorPropertyType>

    public required init(configuration: Configuration) {
        separatorHeight = configuration.property(name: "separatorHeight")
        separatorColor = configuration.property(name: "separatorColor")

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
