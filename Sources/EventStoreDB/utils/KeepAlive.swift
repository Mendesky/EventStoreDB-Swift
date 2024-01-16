//
//  KeepAlive.swift
//
//
//  Created by Grady Zhuo on 2024/1/1.
//

import Foundation

public struct KeepAlive {
    public static var `default`: Self = .init(interval: 10.0, timeout: 10.0)

    var interval: TimeInterval
    var timeout: TimeInterval
}
