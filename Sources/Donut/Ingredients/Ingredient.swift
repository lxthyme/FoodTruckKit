//
//  File.swift
//  
//
//  Created by lxthyme on 2023/9/1.
//

import Foundation
import SwiftUI

public protocol Ingredient: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var flavors: FlavorProfile { get }
    var imageAssetName: String { get }
    static var imageAssetPrefix: String { get }
}

// MARK: - 👀
public extension Ingredient {
    var id: String { "\(Self.imageAssetPrefix)/\(name)"}
}

// MARK: - 👀
public extension Ingredient {
    func image(thumbnail: Bool) -> Image {
        let path = "\(Self.imageAssetPrefix)/\(imageAssetName)-\(thumbnail ? "thumb" : "full")"
        let img = Image(path, bundle: .module)
        print("-->thumbnail: \(path)")
        return img
    }
}
