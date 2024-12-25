//
//  LocationSheet.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import SwiftUI
import MapKit

/// A sheet view for capturing emotional experiences at specific locations.
///
/// This view provides an interface for users to:
/// - Input their feelings about a location
/// - See real-time sentiment analysis feedback
/// - Submit their emotional experience
///
/// - Important: Requires the Analyzer singleton for sentiment analysis
/// - Note: Uses SwiftUI animations for smooth transitions
struct LocationSheet: View {
    // MARK: - Properties
    
    /// Controls the visibility of the sheet
    @Binding var isPresented: Bool
    
    /// The user's description of their feelings at the location
    @Binding var locationDescription: String
    
    /// The analyzed sentiment label from the input text
    @Binding var sentimentLabel: String
    
    /// The geographical coordinate of the selected location
    let coordinate: CLLocationCoordinate2D
    
    /// Callback executed when the user submits their entry
    let onSubmit: () -> Void
    
    /// Focus state for the text input field
    @FocusState private var isTextFieldFocused: Bool
    
    /// Namespace for matched geometry animations
    @Namespace private var animation
    
    // MARK: - View Components
    
    /// The emoji and label display for the current sentiment
    private var sentimentDisplay: some View {
        VStack(spacing: 12) {
            Circle()
                .foregroundStyle(Color.accentColor.opacity(0.1))
                .frame(width: 100, height: 100)
                .overlay(
                    Text(locationDescription.isEmpty ? "💭" : sentimentEmoji)
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundColor(.accentColor)
                        .scaleEffect(1.0)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.5)
                            .repeatCount(1),
                            value: sentimentLabel
                        )
                        .accessibilityLabel(sentimentDescription)
                )
            
            if !locationDescription.isEmpty && !sentimentLabel.isEmpty {
                Text(sentimentDescription)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
    }
    
    /// The text input section for feeling description
    private var inputSection: some View {
        VStack(spacing: 16) {
            Text("How did you feel here?")
                .font(.system(.title3, design: .rounded, weight: .semibold))
            
            TextField("", text: $locationDescription, prompt: Text("Share your feelings...").foregroundColor(.secondary.opacity(0.7)))
                .font(.system(.body, design: .rounded))
                .padding()
                .background(
                    Capsule()
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
                .focused($isTextFieldFocused)
                .onChange(of: locationDescription) { _, newValue in
                    sentimentLabel = Analyzer.shared.mapSentiment(from: newValue)
                }
                .onSubmit(handleSubmit)
                .accessibilityLabel("Feeling description input")
                .accessibilityHint("Describe how you feel at this location")
        }
    }
    
    // MARK: - Computed Properties
    
    private var sentimentEmoji: String {
        sentimentLabel.isEmpty ? "💭" :
        sentimentLabel.components(separatedBy: " ").first ?? "💭"
    }
    
    private var sentimentDescription: String {
        sentimentLabel.isEmpty ? "No sentiment yet" :
        sentimentLabel.components(separatedBy: " ").dropFirst().joined(separator: " ")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                sentimentDisplay
                inputSection
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarItems(
                leading: cancelButton,
                trailing: doneButton
            )
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    // MARK: - Navigation Bar Items
    
    private var cancelButton: some View {
        Button("Cancel") {
            isPresented = false
        }
        .foregroundColor(.accentColor)
        .font(.system(.body, design: .rounded, weight: .medium))
    }
    
    private var doneButton: some View {
        Button("Done") {
            handleDone()
        }
        .foregroundColor(.accentColor)
        .font(.system(.body, design: .rounded, weight: .medium))
    }
    
    // MARK: - Private Methods
    
    private func handleSubmit() {
        guard !locationDescription.isEmpty else { return }
        onSubmit()
    }
    
    private func handleDone() {
        if isTextFieldFocused && !locationDescription.isEmpty {
            onSubmit()
        } else {
            isPresented = false
        }
    }
}
