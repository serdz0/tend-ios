// Draws the Tend app icon (the sprout) as three 1024 px PNGs: light, dark and tinted.
// Run from the project folder:  swift tools/make-icon.swift Tend/Assets.xcassets/AppIcon.appiconset
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

struct Palette {
    let backgroundTop: CGColor
    let backgroundBottom: CGColor
    let leaf: CGColor
    let faceFill: CGColor
    let feature: CGColor
}

func rgb(_ hex: UInt32) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
}

let palettes: [(name: String, palette: Palette)] = [
    ("light", Palette(backgroundTop: rgb(0xF8F3E6), backgroundBottom: rgb(0xDDE7D6),
                      leaf: rgb(0x3F6E4E), faceFill: rgb(0xFDFBF4), feature: rgb(0x22302A))),
    ("dark", Palette(backgroundTop: rgb(0x2A352E), backgroundBottom: rgb(0x171C19),
                     leaf: rgb(0x8DBB98), faceFill: rgb(0x2F3D34), feature: rgb(0xF2F2EC))),
    // iOS tints this one by its brightness, so: dark background, bright sprout, no colour.
    ("tinted", Palette(backgroundTop: rgb(0x000000), backgroundBottom: rgb(0x000000),
                       leaf: rgb(0xFFFFFF), faceFill: rgb(0x3A3A3A), feature: rgb(0xFFFFFF))),
]

func leafPath(in rect: CGRect) -> CGPath {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
    path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
    path.closeSubpath()
    return path
}

func draw(_ palette: Palette, to url: URL) {
    let side = 1024
    let space = CGColorSpace(name: CGColorSpace.sRGB)!
    let ctx = CGContext(data: nil, width: side, height: side, bitsPerComponent: 8, bytesPerRow: 0,
                        space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    // Work top-down like SwiftUI.
    ctx.translateBy(x: 0, y: CGFloat(side))
    ctx.scaleBy(x: 1, y: -1)

    let gradient = CGGradient(colorsSpace: space, colors: [palette.backgroundTop, palette.backgroundBottom] as CFArray,
                              locations: [0, 1])!
    ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: side), options: [])

    let s: CGFloat = 700          // sprout size
    let cx: CGFloat = 512
    let top: CGFloat = 512 - s * 0.46 + 45
    let raise: CGFloat = 24 * .pi / 180

    // Leaves. Each grows from the base next to the stem and is raised a little.
    let leafW = s * 0.4, leafH = s * 0.32, baseY = top + leafH
    ctx.setFillColor(palette.leaf)
    ctx.saveGState()
    ctx.translateBy(x: cx + s * 0.02, y: baseY)
    ctx.rotate(by: -raise)
    ctx.addPath(leafPath(in: CGRect(x: 0, y: -leafH, width: leafW, height: leafH)))
    ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState()
    ctx.translateBy(x: cx - s * 0.02, y: baseY)
    ctx.rotate(by: raise)
    ctx.scaleBy(x: -1, y: 1)
    ctx.addPath(leafPath(in: CGRect(x: 0, y: -leafH, width: leafW, height: leafH)))
    ctx.fillPath()
    ctx.restoreGState()

    // Face.
    let faceD = s * 0.7
    let faceCY = top + s * 0.22 + faceD / 2
    let line = s * 0.045
    let faceRect = CGRect(x: cx - faceD / 2, y: faceCY - faceD / 2, width: faceD, height: faceD)
    ctx.setFillColor(palette.faceFill)
    ctx.fillEllipse(in: faceRect)
    ctx.setStrokeColor(palette.leaf)
    ctx.setLineWidth(line)
    ctx.strokeEllipse(in: faceRect.insetBy(dx: line / 2, dy: line / 2))

    // Eyes and smile, a little bigger than in the app so they read at small sizes.
    ctx.setFillColor(palette.feature)
    let eyeR = s * 0.05
    for dx in [-s * 0.14, s * 0.14] {
        ctx.fillEllipse(in: CGRect(x: cx + dx - eyeR, y: faceCY - s * 0.045 - eyeR, width: eyeR * 2, height: eyeR * 2))
    }
    ctx.setStrokeColor(palette.feature)
    ctx.setLineWidth(s * 0.05)
    ctx.setLineCap(.round)
    let my = faceCY + s * 0.09
    ctx.move(to: CGPoint(x: cx - s * 0.1, y: my))
    ctx.addQuadCurve(to: CGPoint(x: cx + s * 0.1, y: my), control: CGPoint(x: cx, y: my + s * 0.16))
    ctx.strokePath()

    let image = ctx.makeImage()!
    let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
    CGImageDestinationAddImage(destination, image, nil)
    CGImageDestinationFinalize(destination)
}

let folder = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : ".")
try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
for (name, palette) in palettes {
    draw(palette, to: folder.appendingPathComponent("AppIcon-\(name).png"))
}

let contents = """
{
  "images" : [
    { "filename" : "AppIcon-light.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" },
    { "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ], "filename" : "AppIcon-dark.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" },
    { "appearances" : [ { "appearance" : "luminosity", "value" : "tinted" } ], "filename" : "AppIcon-tinted.png", "idiom" : "universal", "platform" : "ios", "size" : "1024x1024" }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
"""
try? contents.write(to: folder.appendingPathComponent("Contents.json"), atomically: true, encoding: .utf8)
