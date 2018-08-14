//
//  SimpleProcedure.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 11/07/2018.
//

import Foundation

struct SimpleProcedure {
    typealias Parameter = (label: String?, value: String)

    let name: String
    let parameters: [Parameter]
}

extension SimpleProcedure {
    init(from procedure: String) throws {
        let components = procedure.components(separatedBy: "(")
        let name = components[0]
        guard !name.isEmpty else {
            throw ParseError.message("Procedure name is empty.")
        }
        guard components.count == 2, let parametersString = components.last else {
            throw ParseError.message("Wrong number of parameters in procedure \(name).")
        }

        let parameters: [Parameter] =
            try parametersString.replacingOccurrences(of: ")", with: "").components(separatedBy: ",")
                .map { parameter in
                    let parameterComponents = parameter.components(separatedBy: ":")
                    guard parameterComponents.count <= 2 else {
                        throw ParseError.message("Too many semicolons inside parameter \(parameter).")
                    }
                    guard let firstElement = parameterComponents.first else {
                        throw ParseError.message("No value as part of parameter inside procedure \(name).")
                    }

                    let parsedParameter: Parameter
                    if let secondElement = parameterComponents.dropFirst().first {
                        parsedParameter = (label: firstElement, value: secondElement)
                    } else {
                        parsedParameter = (label: nil, value: firstElement)
                    }

                    return parsedParameter
        }

        self.name = name
        self.parameters = parameters
    }
}
