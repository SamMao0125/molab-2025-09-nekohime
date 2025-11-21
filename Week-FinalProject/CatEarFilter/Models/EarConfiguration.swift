import SwiftUI
import Foundation

@Observable
class EarConfiguration: Identifiable {
    var id = UUID()
    var name: String = "Untitled"
    
    // Position
    var xPosition: Float = 0.0
    var yPosition: Float = 0.0
    var zPosition: Float = 0.0
    
    // Transform
    var size: Float = 1.0
    var leftRotation: Float = 0.0
    var rightRotation: Float = 0.0
    var syncRotation: Bool = true
    
    // Colors
    var outerColor: CodableColor
    var innerColor: CodableColor
    var hasOutline: Bool = true
    var outlineColor: CodableColor = CodableColor(color: .black)
    var outlineWidth: Float = 0.02
    
    // Gradient
    var useGradient: Bool = false
    var gradientStops: [GradientStop] = [
        GradientStop(color: CodableColor(color: .gray), position: 0.0),
        GradientStop(color: CodableColor(color: .white), position: 1.0)
    ]
    var gradientAngle: Float = 0.0
    
    // Shadow
    var shadowOpacity: Float = 0.5
    var shadowBlur: Float = 0.01
    var shadowOffsetX: Float = 0.0
    var shadowOffsetY: Float = -0.01
    
    // Metadata
    var createdDate: Date = Date()
    var thumbnailData: Data?
    
    // MARK: - Initializers
    
    init() {
        self.outerColor = CodableColor(color: .gray)
        self.innerColor = CodableColor(color: Color(white: 0.8))
    }
    
    // Codable required initializer - MUST be in class body, not extension
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        xPosition = try container.decode(Float.self, forKey: .xPosition)
        yPosition = try container.decode(Float.self, forKey: .yPosition)
        zPosition = try container.decode(Float.self, forKey: .zPosition)
        size = try container.decode(Float.self, forKey: .size)
        leftRotation = try container.decode(Float.self, forKey: .leftRotation)
        rightRotation = try container.decode(Float.self, forKey: .rightRotation)
        syncRotation = try container.decode(Bool.self, forKey: .syncRotation)
        outerColor = try container.decode(CodableColor.self, forKey: .outerColor)
        innerColor = try container.decode(CodableColor.self, forKey: .innerColor)
        hasOutline = try container.decode(Bool.self, forKey: .hasOutline)
        outlineColor = try container.decode(CodableColor.self, forKey: .outlineColor)
        outlineWidth = try container.decode(Float.self, forKey: .outlineWidth)
        useGradient = try container.decode(Bool.self, forKey: .useGradient)
        gradientStops = try container.decode([GradientStop].self, forKey: .gradientStops)
        gradientAngle = try container.decode(Float.self, forKey: .gradientAngle)
        shadowOpacity = try container.decode(Float.self, forKey: .shadowOpacity)
        shadowBlur = try container.decode(Float.self, forKey: .shadowBlur)
        shadowOffsetX = try container.decode(Float.self, forKey: .shadowOffsetX)
        shadowOffsetY = try container.decode(Float.self, forKey: .shadowOffsetY)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        thumbnailData = try container.decodeIfPresent(Data.self, forKey: .thumbnailData)
    }
    
    // For creating copies
    func copy() -> EarConfiguration {
        let config = EarConfiguration()
        config.name = self.name
        config.xPosition = self.xPosition
        config.yPosition = self.yPosition
        config.zPosition = self.zPosition
        config.size = self.size
        config.leftRotation = self.leftRotation
        config.rightRotation = self.rightRotation
        config.syncRotation = self.syncRotation
        config.outerColor = self.outerColor
        config.innerColor = self.innerColor
        config.hasOutline = self.hasOutline
        config.outlineColor = self.outlineColor
        config.outlineWidth = self.outlineWidth
        config.useGradient = self.useGradient
        config.gradientStops = self.gradientStops.map { $0.copy() }
        config.gradientAngle = self.gradientAngle
        config.shadowOpacity = self.shadowOpacity
        config.shadowBlur = self.shadowBlur
        config.shadowOffsetX = self.shadowOffsetX
        config.shadowOffsetY = self.shadowOffsetY
        config.createdDate = self.createdDate
        config.thumbnailData = self.thumbnailData
        return config
    }
}

// MARK: - Codable Conformance
extension EarConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, xPosition, yPosition, zPosition
        case size, leftRotation, rightRotation, syncRotation
        case outerColor, innerColor, hasOutline, outlineColor, outlineWidth
        case useGradient, gradientStops, gradientAngle
        case shadowOpacity, shadowBlur, shadowOffsetX, shadowOffsetY
        case createdDate, thumbnailData
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(xPosition, forKey: .xPosition)
        try container.encode(yPosition, forKey: .yPosition)
        try container.encode(zPosition, forKey: .zPosition)
        try container.encode(size, forKey: .size)
        try container.encode(leftRotation, forKey: .leftRotation)
        try container.encode(rightRotation, forKey: .rightRotation)
        try container.encode(syncRotation, forKey: .syncRotation)
        try container.encode(outerColor, forKey: .outerColor)
        try container.encode(innerColor, forKey: .innerColor)
        try container.encode(hasOutline, forKey: .hasOutline)
        try container.encode(outlineColor, forKey: .outlineColor)
        try container.encode(outlineWidth, forKey: .outlineWidth)
        try container.encode(useGradient, forKey: .useGradient)
        try container.encode(gradientStops, forKey: .gradientStops)
        try container.encode(gradientAngle, forKey: .gradientAngle)
        try container.encode(shadowOpacity, forKey: .shadowOpacity)
        try container.encode(shadowBlur, forKey: .shadowBlur)
        try container.encode(shadowOffsetX, forKey: .shadowOffsetX)
        try container.encode(shadowOffsetY, forKey: .shadowOffsetY)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(thumbnailData, forKey: .thumbnailData)
    }
}

// Codable wrapper for SwiftUI Color
struct CodableColor: Codable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    init(color: Color) {
        // Convert Color to components
        let uiColor = UIColor(color)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
        self.alpha = Double(a)
    }
}

struct GradientStop: Codable, Identifiable {
    var id = UUID()
    var color: CodableColor
    var position: Float // 0.0 to 1.0
    
    func copy() -> GradientStop {
        GradientStop(color: self.color, position: self.position)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, color, position
    }
}
