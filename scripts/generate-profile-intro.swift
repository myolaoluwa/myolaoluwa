import CoreGraphics
import CoreText
import Foundation
import ImageIO
import UniformTypeIdentifiers

let width = 1200
let height = 300
let framesPerLine = 22
let fadeFrames = 5
let frames = framesPerLine * 3
let greeting = Array("Hi, I'm Olaoluwa Moshood")
let greetingHoldFrames = 8
let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "assets/intro.gif")
let colorSpace = CGColorSpaceCreateDeviceRGB()

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: colorSpace, components: [red, green, blue, alpha])!
}

let forest = color(0.094, 0.129, 0.114)
let panel = color(0.126, 0.169, 0.145)
let lime = color(0.816, 0.969, 0.404)
let coral = color(0.929, 0.408, 0.290)
let white = color(0.957, 0.953, 0.929)
let muted = color(0.690, 0.741, 0.702)
let quiet = color(0.420, 0.490, 0.439)

func roundedRect(_ context: CGContext, _ rect: CGRect, radius: CGFloat, fill: CGColor) {
    context.setFillColor(fill)
    context.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
    context.fillPath()
}

func drawText(_ text: String, context: CGContext, x: CGFloat, y: CGFloat, size: CGFloat, font: String, fill: CGColor, alpha: CGFloat = 1, tracking: CGFloat = 0) -> CGFloat {
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): CTFontCreateWithName(font as CFString, size, nil),
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): fill,
        NSAttributedString.Key(kCTKernAttributeName as String): tracking
    ]
    let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
    let width = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
    context.saveGState()
    context.setAlpha(alpha)
    context.textPosition = CGPoint(x: x, y: y)
    CTLineDraw(line, context)
    context.restoreGState()
    return width
}

func drawLogo(context: CGContext, x: CGFloat, y: CGFloat, size: CGFloat) {
    context.saveGState()
    context.translateBy(x: x, y: y + size)
    context.scaleBy(x: size / 64, y: -size / 64)

    let tile = CGPath(roundedRect: CGRect(x: 2, y: 2, width: 60, height: 60), cornerWidth: 18, cornerHeight: 18, transform: nil)
    context.addPath(tile)
    context.setFillColor(forest)
    context.fillPath()

    let bowl = CGMutablePath()
    bowl.move(to: CGPoint(x: 39, y: 13))
    bowl.addLine(to: CGPoint(x: 31, y: 13))
    bowl.addCurve(to: CGPoint(x: 12, y: 32), control1: CGPoint(x: 20.507, y: 13), control2: CGPoint(x: 12, y: 21.507))
    bowl.addCurve(to: CGPoint(x: 31, y: 51), control1: CGPoint(x: 12, y: 42.493), control2: CGPoint(x: 20.507, y: 51))
    bowl.addLine(to: CGPoint(x: 39, y: 51))
    context.addPath(bowl)
    context.setStrokeColor(lime)
    context.setLineWidth(5.5)
    context.setLineCap(.round)
    context.strokePath()

    let arrow = CGMutablePath()
    arrow.move(to: CGPoint(x: 28, y: 38))
    arrow.addLine(to: CGPoint(x: 50, y: 16))
    arrow.move(to: CGPoint(x: 38, y: 16))
    arrow.addLine(to: CGPoint(x: 50, y: 16))
    arrow.addLine(to: CGPoint(x: 50, y: 28))
    context.addPath(arrow)
    context.setStrokeColor(coral)
    context.setLineWidth(5.5)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.strokePath()
    context.restoreGState()
}

func makeFrame(index: Int) -> CGImage {
    let context = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    )!

    context.setFillColor(forest)
    context.fill(CGRect(x: 0, y: 0, width: width, height: height))
    roundedRect(context, CGRect(x: 1, y: 1, width: width - 2, height: height - 2), radius: 15, fill: panel)
    roundedRect(context, CGRect(x: 2, y: 2, width: width - 4, height: height - 4), radius: 14, fill: forest)

    context.setStrokeColor(color(1, 1, 1, 0.045))
    context.setLineWidth(1)
    for x in stride(from: 40, through: width - 40, by: 48) {
        context.move(to: CGPoint(x: x, y: 24))
        context.addLine(to: CGPoint(x: x, y: height - 24))
    }
    context.strokePath()

    context.setStrokeColor(color(1, 1, 1, 0.10))
    context.setLineWidth(1)
    context.move(to: CGPoint(x: 54, y: 65))
    context.addLine(to: CGPoint(x: width - 54, y: 65))
    context.strokePath()

    drawLogo(context: context, x: 54, y: 158, size: 54)
    _ = drawText("DELIGHTECH  /  PRODUCT ENGINEERING", context: context, x: 140, y: 242, size: 12, font: "AvenirNext-DemiBold", fill: lime, tracking: 1.25)

    let greetingFrame = index % frames
    let typingEnd = greeting.count
    let holdEnd = typingEnd + greetingHoldFrames
    let eraseEnd = holdEnd + greeting.count
    let visibleCharacters: Int
    let caretIsVisible: Bool
    if greetingFrame < typingEnd {
        visibleCharacters = greetingFrame + 1
        caretIsVisible = true
    } else if greetingFrame < holdEnd {
        visibleCharacters = greeting.count
        caretIsVisible = greetingFrame % 8 < 5
    } else if greetingFrame < eraseEnd {
        visibleCharacters = greeting.count - (greetingFrame - holdEnd) - 1
        caretIsVisible = true
    } else {
        visibleCharacters = 0
        caretIsVisible = false
    }

    let visibleGreeting = String(greeting.prefix(max(0, visibleCharacters)))
    let greetingWidth = drawText(visibleGreeting, context: context, x: 138, y: 177, size: 43, font: "AvenirNext-DemiBold", fill: white)
    if caretIsVisible {
        roundedRect(context, CGRect(x: 145 + greetingWidth, y: 167, width: 3, height: 44), radius: 1.5, fill: coral)
    }

    let titles = [
        "Full-Stack Developer",
        "Founder of DelighTech",
        "Building Web · Mobile · SaaS · AI Products"
    ]
    let phase = index / framesPerLine
    let localFrame = index % framesPerLine
    let currentTitle = titles[phase]
    let currentAlpha: CGFloat
    if localFrame < fadeFrames {
        currentAlpha = 0
    } else if localFrame < fadeFrames * 2 {
        currentAlpha = CGFloat(localFrame - fadeFrames) / CGFloat(fadeFrames)
    } else {
        currentAlpha = 1
    }
    let currentWidth = drawText(currentTitle, context: context, x: 140, y: 111, size: 23, font: "AvenirNext-Medium", fill: lime, alpha: currentAlpha, tracking: 0.05)

    if localFrame < fadeFrames {
        let previousTitle = titles[(phase + titles.count - 1) % titles.count]
        let previousAlpha = 1 - CGFloat(localFrame) / CGFloat(fadeFrames)
        _ = drawText(previousTitle, context: context, x: 140, y: 111, size: 23, font: "AvenirNext-Medium", fill: lime, alpha: previousAlpha, tracking: 0.05)
    }

    let cursorX = 140 + currentWidth + 12
    roundedRect(context, CGRect(x: cursorX, y: 107, width: 2, height: 26), radius: 1, fill: color(0.929, 0.408, 0.290, currentAlpha))

    _ = drawText("WEB  ·  MOBILE  ·  SAAS  ·  AI", context: context, x: 140, y: 38, size: 10, font: "AvenirNext-Medium", fill: muted, tracking: 1.3)

    let indicatorStart: CGFloat = 1030
    for dot in 0..<3 {
        let active = dot == phase
        context.setFillColor(active ? lime : quiet)
        context.fillEllipse(in: CGRect(x: indicatorStart + CGFloat(dot) * 24, y: 239, width: active ? 8 : 5, height: active ? 8 : 5))
    }

    context.setStrokeColor(color(0.816, 0.969, 0.404, 0.20))
    context.setLineWidth(1)
    let route = CGMutablePath()
    route.move(to: CGPoint(x: 918, y: 91))
    route.addCurve(to: CGPoint(x: 1080, y: 178), control1: CGPoint(x: 980, y: 172), control2: CGPoint(x: 1014, y: 105))
    route.addCurve(to: CGPoint(x: 1138, y: 99), control1: CGPoint(x: 1114, y: 235), control2: CGPoint(x: 1166, y: 158))
    context.addPath(route)
    context.strokePath()

    context.setFillColor(color(0.816, 0.969, 0.404, 0.20))
    context.fillEllipse(in: CGRect(x: 910, y: 83, width: 16, height: 16))
    context.setFillColor(coral)
    let movingX = 930 + CGFloat(phase) * 78 + CGFloat(localFrame % framesPerLine) * 2
    context.fillEllipse(in: CGRect(x: min(movingX, 1132), y: 137 + CGFloat((localFrame % 8) - 4), width: 7, height: 7))
    context.setFillColor(color(0.816, 0.969, 0.404, 0.28))
    context.fillEllipse(in: CGRect(x: 1131, y: 92, width: 14, height: 14))

    return context.makeImage()!
}

let destination = CGImageDestinationCreateWithURL(outputURL as CFURL, UTType.gif.identifier as CFString, frames, nil)!
CGImageDestinationSetProperties(destination, [
    kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]
] as CFDictionary)

for index in 0..<frames {
    let image = makeFrame(index: index)
    let delay = 0.12
    CGImageDestinationAddImage(destination, image, [
        kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: delay]
    ] as CFDictionary)
}

guard CGImageDestinationFinalize(destination) else {
    fatalError("Could not write animated profile intro to \(outputURL.path)")
}
print("Wrote \(frames)-frame animated intro to \(outputURL.path)")
