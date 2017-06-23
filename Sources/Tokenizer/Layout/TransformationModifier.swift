//
//  TransformationModifier.swift
//  Pods
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

public enum TransformationModifier {
    case identity
    case rotate(by: Double)
    case scale(byX: Double, byY: Double)
    case translate(byX: Double, byY: Double)
}
