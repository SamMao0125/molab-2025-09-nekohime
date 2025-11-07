//
//  CatMood.swift
//  MeowLobby
//
//  Cat mood status system
//

import SwiftUI

enum CatMood: String, Codable, CaseIterable, Identifiable {
    case available = "Available"
    case busy = "Busy"
    case away = "Away"
    case napping = "Napping"
    case playing = "Playing"
    case hunting = "Hunting"
    
    var id: String { self.rawValue }
    
    // Kaomoji for each mood
    var kaomoji: String {
        switch self {
        case .available:
            return "(=^・ω・^=)"
        case .busy:
            return "(=`ω´=)"
        case .away:
            return "(=；ェ；=)"
        case .napping:
            return "(–ω–)"
        case .playing:
            return "ฅ(^・ω・^ฅ)"
        case .hunting:
            return "(=^･ｪ･^=))ﾉ彡"
        }
    }
    
    // Description for UI
    var description: String {
        switch self {
        case .available:
            return "Ready to chat"
        case .busy:
            return "Focused on something"
        case .away:
            return "Away from device"
        case .napping:
            return "Sleeping"
        case .playing:
            return "Having fun"
        case .hunting:
            return "On the prowl"
        }
    }
    
    // Color theme for each mood
    var color: Color {
        switch self {
        case .available:
            return .green
        case .busy:
            return .orange
        case .away:
            return .gray
        case .napping:
            return .purple
        case .playing:
            return .blue
        case .hunting:
            return .red
        }
    }
    
    // Icon background for mood picker
    var backgroundColor: Color {
        color.opacity(0.2)
    }
    
    // Border color for mood picker
    var borderColor: Color {
        color.opacity(0.6)
    }
}

// MARK: - Mood Picker Component
struct CatMoodPicker: View {
    @Binding var selectedMood: CatMood
    var onMoodChange: (CatMood) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ㅅ")
                    .font(.title2)
                Text("Set Your Cat Mood")
                    .font(.headline)
            }
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(CatMood.allCases) { mood in
                    MoodButton(
                        mood: mood,
                        isSelected: selectedMood == mood,
                        action: {
                            selectedMood = mood
                            onMoodChange(mood)
                        }
                    )
                }
            }
        }
        .padding()
    }
}

// MARK: - Individual Mood Button
struct MoodButton: View {
    let mood: CatMood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.kaomoji)
                    .font(.title)
                
                Text(mood.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .bold : .regular)
                
                Text(mood.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? mood.backgroundColor : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? mood.borderColor : Color.gray.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Mood Display (for user rows)
struct CompactMoodDisplay: View {
    let mood: CatMood
    let showLabel: Bool
    
    init(mood: CatMood, showLabel: Bool = true) {
        self.mood = mood
        self.showLabel = showLabel
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(mood.kaomoji)
                .font(.callout)
            
            if showLabel {
                Text(mood.rawValue)
                    .font(.caption)
                    .foregroundColor(mood.tuxedoAccentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(mood.tuxedoBackgroundColor)
                            .overlay(
                                Capsule()
                                    .stroke(mood.tuxedoAccentColor.opacity(0.5), lineWidth: 1)
                            )
                    )
            }
        }
    }
}

// MARK: - Mood Change Sheet
struct MoodPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedMood: CatMood
    var onSave: (CatMood) -> Void
    
    @State private var tempMood: CatMood
    
    init(selectedMood: Binding<CatMood>, onSave: @escaping (CatMood) -> Void) {
        self._selectedMood = selectedMood
        self.onSave = onSave
        self._tempMood = State(initialValue: selectedMood.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Cat ears decoration
                    CatEarsDecoration(size: 20, color: .orange.opacity(0.6))
                        .padding(.top, 20)
                    
                    // Current mood display
                    VStack(spacing: 8) {
                        Text("Current Mood")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(tempMood.kaomoji)
                            .font(.system(size: 60))
                        
                        Text(tempMood.rawValue)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(tempMood.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(tempMood.backgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(tempMood.borderColor, lineWidth: 2)
                            )
                    )
                    .padding(.horizontal)
                    
                    WhiskerDivider()
                    
                    // Mood picker
                    CatMoodPicker(selectedMood: $tempMood) { newMood in
                        // Haptic feedback on selection
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("ฅ Change Mood ฅ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        selectedMood = tempMood
                        onSave(tempMood)
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}
