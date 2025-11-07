//
//  CaptionTemplates.swift
//  MeowLobby
//
//  Quick caption templates for users
//

import SwiftUI

struct CaptionTemplate: Identifiable {
    let id = UUID()
    let text: String
    let kaomoji: String
    let category: Category
    
    enum Category: String, CaseIterable {
        case social = "Social"
        case activity = "Activity"
        case mood = "Mood"
        case fun = "Fun"
        
        var icon: String {
            switch self {
            case .social: return "ฅ(^・ω・^ฅ)"
            case .activity: return "ᓚᘏᗢ"
            case .mood: return "(=^･ω･^=)"
            case .fun: return "✧(=✪ ᆺ ✪=)✧"
            }
        }
    }
    
    var fullText: String {
        "\(text) \(kaomoji)"
    }
}

// MARK: - Template Collection
struct CaptionTemplates {
    static let all: [CaptionTemplate] = [
        // Social
        CaptionTemplate(text: "Looking for playmates", kaomoji: "ฅ(^・ω・^ฅ)", category: .social),
        CaptionTemplate(text: "Always happy to chat", kaomoji: "(=^・ω・^=)", category: .social),
        CaptionTemplate(text: "Making new friends", kaomoji: "(=^‥^=)", category: .social),
        CaptionTemplate(text: "Part of the clowder", kaomoji: "ฅ(^・ω・^ฅ)", category: .social),
        
        // Activity
        CaptionTemplate(text: "Taking a catnap", kaomoji: "(–ω–)", category: .activity),
        CaptionTemplate(text: "On the prowl", kaomoji: "(=`ω´=)", category: .activity),
        CaptionTemplate(text: "Chasing laser dots", kaomoji: "(=^･ｪ･^=))ﾉ彡", category: .activity),
        CaptionTemplate(text: "Sunbathing right meow", kaomoji: "(=˘ω˘=)", category: .activity),
        CaptionTemplate(text: "Grooming my whiskers", kaomoji: "(=^･ｪ･^=)", category: .activity),
        CaptionTemplate(text: "Exploring the territory", kaomoji: "ᓚᘏᗢ", category: .activity),
        
        // Mood
        CaptionTemplate(text: "Feeling purr-fect today", kaomoji: "(=^・ω・^=)", category: .mood),
        CaptionTemplate(text: "Living my best nine lives", kaomoji: "✧(=✪ ᆺ ✪=)✧", category: .mood),
        CaptionTemplate(text: "Zen cat mode activated", kaomoji: "(–ω–)", category: .mood),
        CaptionTemplate(text: "Curious about everything", kaomoji: "(=^‥^=)?", category: .mood),
        CaptionTemplate(text: "In a playful mood", kaomoji: "ฅ(^・ω・^ฅ)", category: .mood),
        
        // Fun
        CaptionTemplate(text: "Professional nap taker", kaomoji: "(–ω–)", category: .fun),
        CaptionTemplate(text: "Master of mischief", kaomoji: "(=`ω´=)", category: .fun),
        CaptionTemplate(text: "Knock things off tables", kaomoji: "(=^･ｪ･^=))ﾉ彡", category: .fun),
        CaptionTemplate(text: "If I fits, I sits", kaomoji: "(=^・ェ・^=)", category: .fun),
        CaptionTemplate(text: "Paws-itively adorable", kaomoji: "ฅ(^・ω・^ฅ)", category: .fun),
        CaptionTemplate(text: "Meow is the time", kaomoji: "(=^・ω・^=)", category: .fun),
    ]
    
    static func templates(for category: CaptionTemplate.Category) -> [CaptionTemplate] {
        all.filter { $0.category == category }
    }
}

// MARK: - Template Picker View
struct CaptionTemplatePicker: View {
    @Binding var caption: String
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCategory: CaptionTemplate.Category = .social
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category picker
                categoryPickerView()
                
                Divider()
                
                // Templates list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(CaptionTemplates.templates(for: selectedCategory)) { template in
                            TemplateButton(template: template) {
                                caption = template.fullText
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("ฅ Caption Templates ฅ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func categoryPickerView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CaptionTemplate.Category.allCases, id: \.self) { category in
                    CategoryTab(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: {
                            selectedCategory = category
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                        }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Category Tab
struct CategoryTab: View {
    let category: CaptionTemplate.Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(category.icon)
                    .font(.title2)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.orange.opacity(0.2) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Template Button
struct TemplateButton: View {
    let template: CaptionTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Kaomoji icon
                Text(template.kaomoji)
                    .font(.title2)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color.orange.opacity(0.1))
                    )
                
                // Template text
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.text)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text("Tap to use")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Arrow indicator
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.orange.opacity(0.6))
                    .font(.title3)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Template Chips (for inline display)
struct QuickTemplatePill: View {
    let template: CaptionTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(template.kaomoji)
                    .font(.caption)
                Text(template.text)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.orange.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Templates Bar (shows popular templates)
struct QuickTemplatesBar: View {
    @Binding var caption: String
    
    let popularTemplates = [
        CaptionTemplates.all[0], // Looking for playmates
        CaptionTemplates.all[4], // Taking a catnap
        CaptionTemplates.all[5], // On the prowl
        CaptionTemplates.all[10], // Feeling purr-fect
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("ㅅ")
                    .font(.caption)
                Text("Quick Templates")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(popularTemplates) { template in
                        QuickTemplatePill(template: template) {
                            caption = template.fullText
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                    }
                }
            }
        }
    }
}
