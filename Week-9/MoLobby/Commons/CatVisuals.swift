//
//  CatVisuals.swift
//  MeowLobby
//
//  Cat-themed visual elements and kaomoji utilities
//

import SwiftUI

// MARK: - Kaomoji Collection
struct Kaomoji {
    // Happy cats
    static let happy = "(=^・ω・^=)"
    static let excited = "(=^‥^=)"
    static let love = "(=^・^=)"
    static let sparkle = "✧(=✪ ᆺ ✪=)✧"
    
    // Activity cats
    static let wave = "(=^・ェ・^=))ﾉ彡☆"
    static let play = "ฅ(^・ω・^ฅ)"
    static let stretch = "ᓚᘏᗢ"
    static let sleep = "(–ω–)"
    
    // Expression cats
    static let curious = "(=^‥^=)?"
    static let surprised = "∑(=ﾟωﾟ=;)"
    static let proud = "(=`ω´=)"
    static let shy = "(=；ェ；=)"
    
    // Paw and elements
    static let paw = "🐾"
    static let pawPrint = "ㅅ"
    static let whiskers = "ヾ(=ＴェＴ=)ﾉ〃"
    
    // Random cat
    static func random() -> String {
        let cats = [happy, excited, love, wave, play, curious, proud]
        return cats.randomElement() ?? happy
    }
}

// MARK: - Cat Profile Placeholder
struct CatProfilePlaceholder: View {
    var size: CGFloat = 80
    var catType: CatType = .random
    
    enum CatType {
        case sitting, sleeping, playing, random
        
        var ascii: String {
            switch self {
            case .sitting:
                return "/\\_/\\\n( o.o )\n > ^ <"
            case .sleeping:
                return "/\\_/\\\n( -.- )\n > ~ <"
            case .playing:
                return "/\\_/\\\n( ^.^ )\n > ω <"
            case .random:
                return [CatType.sitting, .sleeping, .playing].randomElement()!.ascii
            }
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            TuxedoColors.tuxedoBlack,
                            TuxedoColors.charcoalBlack
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text(catType.ascii)
                .font(.system(size: size * 0.25, design: .monospaced))
                .lineSpacing(-2)
                .multilineTextAlignment(.center)
                .foregroundColor(TuxedoColors.pureWhite)
        }
        .frame(width: size, height: size)
        .overlay(
            Circle()
                .stroke(TuxedoColors.whiskerSilver.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Paw Print Indicator
struct PawPrintIndicator: View {
    var isActive: Bool = true
    var size: CGFloat = 12
    
    var body: some View {
        ZStack {
            // Paw pad (main)
            Circle()
                .fill(isActive ? Color.orange : Color.gray.opacity(0.3))
                .frame(width: size, height: size)
            
            // Toe beans (top three small circles)
            HStack(spacing: size * 0.15) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(isActive ? Color.orange : Color.gray.opacity(0.3))
                        .frame(width: size * 0.4, height: size * 0.4)
                }
            }
            .offset(y: -size * 0.6)
        }
        .frame(width: size * 2, height: size * 2)
    }
}

// MARK: - Whisker Divider
struct WhiskerDivider: View {
    var color: Color = .gray.opacity(0.3)
    
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
            .fill(color)
            .frame(width: 30, height: 1)
            .rotationEffect(.degrees(angle))
    }
}

// MARK: - Cat Ear Shape (for decorative elements)
struct CatEarShape: Shape {
    var isLeft: Bool = true
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if isLeft {
            // Left ear - triangle pointing up-left
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        } else {
            // Right ear - triangle pointing up-right
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Cat Ear Decoration View
struct CatEarsDecoration: View {
    var size: CGFloat = 20
    var color: Color = .orange.opacity(0.6)
    
    var body: some View {
        HStack(spacing: size * 2) {
            CatEarShape(isLeft: true)
                .fill(color)
                .frame(width: size, height: size)
            
            CatEarShape(isLeft: false)
                .fill(color)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Cat Button Style
struct CatButtonStyle: ButtonStyle {
    var backgroundColor: Color = .orange
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Text("ฅ")
                .font(.title3)
            
            configuration.label
            
            Text("ฅ")
                .font(.title3)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
                .overlay(
                    CatEarsDecoration(size: 8, color: backgroundColor.opacity(0.3))
                        .offset(y: -20),
                    alignment: .top
                )
        )
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Loading Cat Animation
struct LoadingCat: View {
    @State private var currentFrame = 0
    
    let frames = [
        "ᓚᘏᗢ",
        "ᓚᘏᗢ.",
        "ᓚᘏᗢ..",
        "ᓚᘏᗢ..."
    ]
    
    let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(frames[currentFrame])
            .font(.system(size: 40, design: .monospaced))
            .onReceive(timer) { _ in
                currentFrame = (currentFrame + 1) % frames.count
            }
    }
}
