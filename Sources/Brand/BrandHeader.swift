//
//  SwiftUIView.swift
//  
//
//  Created by lxthyme on 2023/9/8.
//

import SwiftUI

// MARK: - 👀
public extension BrandHeader {
    enum HeaderSize: Double, RawRepresentable {
        case standard = 1.0
        case reduced = 0.5
    }
}

public struct BrandHeader: View {
    public var animated: Bool
    public var headerSize: HeaderSize

    public init(animated: Bool = true, headerSize: HeaderSize = .standard) {
        self.animated = animated
        self.headerSize = headerSize
    }

    var skyGradient: Gradient {
        Gradient(colors: [
            Color("header/Sky Start", bundle: .module),
            Color("header/Sky End", bundle: .module)
        ])
    }
    public var body: some View {
        TimelineView(.animation(paused: !animated)) { context in
            let director = AnimationDirector(timeInterval: context.date.timeIntervalSince1970)
            Canvas { context, size in
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                let centerX = size.width * 0.5
                let scale = self.headerSize.rawValue

                context.fill(
                    Rectangle().path(in: rect),
                    with: .radialGradient(
                        skyGradient,
                        center: CGPoint(x: rect.midX, y: 400 * scale),
                        startRadius: 0,
                        endRadius: 600
                    )
                )

                for layer in director.backgroundLayers {
                    context.drawLayer { context in
                        context.translateBy(x: centerX, y: (750 + layer.yOffset) * scale)
                        context.rotate(by: -layer.rotation)
                        context.scaleBy(x: scale, y: scale)
                        context.draw(layer.image, at: .zero)
                    }
                }

                context.drawLayer { context in
                    context.translateBy(x: centerX, y: 350 * scale)
                    context.scaleBy(x: scale, y: scale)
                    context.draw(Image("header/layer/8 Road", bundle: .module), at: .zero)
                }

                context.drawLayer { context in
                    context.translateBy(x: centerX, y: 307 * scale)
                    context.scaleBy(x: scale, y: scale)
                    context.draw(director.truckImage, at: .zero)
                }

                for layer in director.foregroundLayers {
                    context.drawLayer { context in
                        context.translateBy(x: centerX, y: 770 * scale)
                        context.rotate(by: -layer.rotation)
                        context.scaleBy(x: scale, y: scale)
                        context.draw(layer.image, at: .zero)
                    }
                }
            }
            .padding(.top, -200 * headerSize.rawValue)
        }
        .frame(height: 200 * headerSize.rawValue)
    }
}

extension BrandHeader {
    struct RotatedLayer {
        var image: Image
        var rotation: Angle
        var yOffset: Double = 0
    }
}
extension BrandHeader {
    struct AnimationDirector {
        var foregroundLayers: [RotatedLayer]
        var truckImage: Image
        var backgroundLayers: [RotatedLayer]

        init(timeInterval: TimeInterval) {
            func layerImage(_ name: String) -> Image {
                Image("header/layer/\(name)", bundle: .module)
            }
            func rotationPercent(duration: TimeInterval) -> Angle {
                Angle.radians(timeInterval.percent(truncation: duration) * .pi * 2)
            }

            backgroundLayers = [
                RotatedLayer(
                    image: layerImage("1 Small Clouds"),
                    rotation: rotationPercent(duration: 760),
                    yOffset: 0
                ),
                RotatedLayer(
                    image: layerImage("2 Medium Clouds"),
                    rotation: rotationPercent(duration: 720),
                    yOffset: -15
                ),
                RotatedLayer(
                    image: layerImage("3 Mountains"),
                    rotation: rotationPercent(duration: 840),
                    yOffset: -10
                ),
                RotatedLayer(
                    image: layerImage("4 Big Clouds"),
                    rotation: rotationPercent(duration: 400)
                ),
                RotatedLayer(
                    image: layerImage("5 Ocean"),
                    rotation: rotationPercent(duration: 480)
                ),
                RotatedLayer(
                    image: layerImage("6 Balloons"),
                    rotation: rotationPercent(duration: 540)
                ),
                RotatedLayer(
                    image: layerImage("7 Trees"),
                    rotation: rotationPercent(duration: 180),
                    yOffset: -10
                )
            ]

            foregroundLayers = [
                RotatedLayer(
                    image: layerImage("9 Foreground"),
                    rotation: rotationPercent(duration: 96)
                )
            ]

            let truckFrame: Int = {
                let framePerSecond = 12.0
                let totalFrames = 4.0
                let percent = timeInterval.percent(truncation: (1 / framePerSecond) * totalFrames)
                return Int(floor(percent * totalFrames))
            }()
            print("header/truck/Frame \(truckFrame + 1)")

            truckImage = Image("header/truck/Frame \(truckFrame + 1)", bundle: .module)
        }

    }
}

struct BrandHeader_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            BrandHeader()
        }
        .previewDisplayName("In Scroll View")

        BrandHeader()
            .border(.red.opacity(0.5))
            .frame(height: 400, alignment: .bottom)
            .border(.green.opacity(0.5))
            .frame(width: 1200, height: 1200, alignment: .top)
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Full Size")
    }
}
