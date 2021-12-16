//
//  MKPointAnnotation.swift
//  BucketList
//
//  Created by Daichi Morihara on 2021/11/14.
//

import Foundation
import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            title ?? "no value"
        }
        set {
            title = newValue
        }
    }
    public var wrappedSubtitle: String {
        get {
            subtitle ?? "no value"
        }
        set {
            subtitle = newValue
        }
    }
}
