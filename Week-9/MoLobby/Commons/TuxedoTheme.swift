//
//  TuxedoTheme.swift
//  MeowLobby
//
//  Tuxedo cat color system - Black with white accents
//

import SwiftUI

// MARK: - Tuxedo Color System
struct TuxedoColors {
    
    // MARK: Primary Colors (Black Spectrum)
    static let tuxedoBlack = Color(hex: "1a1a1a")          // Rich black
    static let charcoalBlack = Color(hex: "2d2d2d")        // Lighter black
    static let softBlack = Color(hex: "3d3d3d")            // Soft black for cards
    
    // MARK: White Accents (White Spectrum)
    static let pureWhite = Color.white                      // Pure white
    static let creamWhite = Color(hex: "f8f8f8")           // Soft white
    static let pearlWhite = Color(hex: "f0f0f0")           // Pearl white
    
    // MARK: Gray Midtones (Tuxedo Blend)
    static let silverGray = Color(hex: "b8b8b8")           // Silver
    static let smokyGray = Color(hex: "8a8a8a")            // Smoky gray
    static let slateGray = Color(hex: "6d6d6d")            // Slate gray
    
    // MARK: Accent Colors (Subtle Highlights)
    static let tuxedoGold = Color(hex: "d4af37")           // Gold accent (collar)
    static let eyeGreen = Color(hex: "7cb342")             // Cat eye green
    static let noseRose = Color(hex: "ff9ea5")             // Pink nose accent
    static let whiskerSilver = Color(hex: "e8e8e8")        // Whisker highlight
    
    // MARK: Mood Colors (Tuxedo-adapted)
    static let availableGreen = Color(hex: "66bb6a")       // Muted green
    static let busyAmber = Color(hex: "ffa726")            // Soft amber
    static let awayGray = Color(hex: "90a4ae")             // Cool gray
    static let nappingIndigo = Color(hex: "7e57c2")        // Dreamy purple
    static let playingCyan = Color(hex: "26c6da")          // Playful cyan
    static let huntingRed = Color(hex: "ef5350")           // Alert red
    
    // MARK: Gradients
    
    // Background gradients
    static let darkGradient = LinearGradient(
        colors: [tuxedoBlack, charcoalBlack],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let midGradient = LinearGradient(
        colors: [charcoalBlack, softBlack],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let lightGradient = LinearGradient(
        colors: [pearlWhite, creamWhite],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Card gradients (subtle)
    static let cardGradient = LinearGradient(
        colors: [softBlack, charcoalBlack.opacity(0.9)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Shimmer gradient (for loading)
    static let shimmerGradient = LinearGradient(
        colors: [
            slateGray.opacity(0.3),
            silverGray.opacity(0.5),
            slateGray.opacity(0.3)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Gold accent gradient (for premium elements)
    static let goldGradient = LinearGradient(
        colors: [
            tuxedoGold.opacity(0.8),
            Color(hex: "f4e5c2")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // White highlight gradient (for buttons)
    static let whiteGradient = LinearGradient(
        colors: [pureWhite, creamWhite],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Tuxedo Card Style
struct TuxedoCardStyle: ViewModifier {
    var mood: CatMood?
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(TuxedoColors.cardGradient)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                mood?.tuxedoAccentColor ?? TuxedoColors.whiskerSilver.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
    }
}

// MARK: - Tuxedo Button Style
struct TuxedoButtonStyle: ButtonStyle {
    var backgroundColor: Color = TuxedoColors.tuxedoBlack
    var foregroundColor: Color = TuxedoColors.pureWhite
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Text("ฅ")
                .font(.title3)
            
            configuration.label
            
            Text("ฅ")
                .font(.title3)
        }
        .foregroundColor(foregroundColor)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [backgroundColor, backgroundColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
                .overlay(
                    // Tuxedo cat ears on top
                    TuxedoCatEarsDecoration(size: 8, color: TuxedoColors.tuxedoBlack)
                        .offset(y: -20),
                    alignment: .top
                )
        )
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Tuxedo Cat Ears (Black)
struct TuxedoCatEarsDecoration: View {
    var size: CGFloat = 20
    var color: Color = TuxedoColors.tuxedoBlack
    
    var body: some View {
        HStack(spacing: size * 2) {
            CatEarShape(isLeft: true)
                .fill(color)
                .frame(width: size, height: size)
                .overlay(
                    // White inner ear
                    CatEarShape(isLeft: true)
                        .fill(TuxedoColors.creamWhite)
                        .frame(width: size * 0.5, height: size * 0.5)
                        .offset(x: size * 0.15, y: size * 0.15)
                )
            
            CatEarShape(isLeft: false)
                .fill(color)
                .frame(width: size, height: size)
                .overlay(
                    // White inner ear
                    CatEarShape(isLeft: false)
                        .fill(TuxedoColors.creamWhite)
                        .frame(width: size * 0.5, height: size * 0.5)
                        .offset(x: -size * 0.15, y: size * 0.15)
                )
        }
        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Tuxedo Whisker Divider (White on Dark)
struct TuxedoWhiskerDivider: View {
    var color: Color = TuxedoColors.whiskerSilver
    
    var body: some View {
        HStack(spacing: 8) {
            // Left whiskers
            VStack(spacing: 2) {
                whiskerLine(angle: -15)
                whiskerLine(angle: 0)
                whiskerLine(angle: 15)
            }
            
            // Cat face in middle
            Text("(=^･ω･^=)")
                .font(.caption2)
                .foregroundColor(color)
            
            // Right whiskers
            VStack(spacing: 2) {
                whiskerLine(angle: 15)
                whiskerLine(angle: 0)
                whiskerLine(angle: -15)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
    
    private func whiskerLine(angle: Double) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [color.opacity(0.2), color, color.opacity(0.2)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 30, height: 1)
            .rotationEffect(.degrees(angle))
            .shadow(color: TuxedoColors.pureWhite.opacity(0.3), radius: 1, x: 0, y: 0)
    }
}

// MARK: - Tuxedo Paw Print (White)
struct TuxedoPawPrintIndicator: View {
    var isActive: Bool = true
    var size: CGFloat = 12
    
    var body: some View {
        ZStack {
            // Paw pad (main) - white
            Circle()
                .fill(isActive ? TuxedoColors.pureWhite : TuxedoColors.slateGray)
                .frame(width: size, height: size)
                .shadow(color: isActive ? TuxedoColors.pureWhite.opacity(0.5) : .clear, radius: 4, x: 0, y: 0)
            
            // Toe beans (top three small circles)
            HStack(spacing: size * 0.15) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(isActive ? TuxedoColors.pureWhite : TuxedoColors.slateGray)
                        .frame(width: size * 0.4, height: size * 0.4)
                }
            }
            .offset(y: -size * 0.6)
        }
        .frame(width: size * 2, height: size * 2)
    }
}

// MARK: - Extend CatMood with Tuxedo Colors
extension CatMood {
    var tuxedoAccentColor: Color {
        switch self {
        case .available:
            return TuxedoColors.availableGreen
        case .busy:
            return TuxedoColors.busyAmber
        case .away:
            return TuxedoColors.awayGray
        case .napping:
            return TuxedoColors.nappingIndigo
        case .playing:
            return TuxedoColors.playingCyan
        case .hunting:
            return TuxedoColors.huntingRed
        }
    }
    
    var tuxedoBackgroundColor: Color {
        tuxedoAccentColor.opacity(0.15)
    }
}

// MARK: - View Extension for Easy Application
extension View {
    func tuxedoCard(mood: CatMood? = nil) -> some View {
        modifier(TuxedoCardStyle(mood: mood))
    }
}
