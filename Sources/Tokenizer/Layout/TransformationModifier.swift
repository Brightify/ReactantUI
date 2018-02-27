//
//  TransformationModifier.swift
//  Pods
//
//  Created by Matyáš Kříž on 23/06/2017.
//
//

public enum TransformationModifier {
    case identity
    case rotate(by: Float)
    case scale(byX: Float, byY: Float)
    case translate(byX: Float, byY: Float)
}
