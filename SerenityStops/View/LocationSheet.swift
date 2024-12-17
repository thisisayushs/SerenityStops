//
//  LocationSheet.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import SwiftUI
import MapKit

/// A sheet view that allows users to input their feelings about a specific location.
/// This view provides:
/// - A text input field for describing feelings
/// - Real-time sentiment analysis feedback
/// - Visual representation of the sentiment

struct LocationSheet: View {
    // MARK: - Properties
    
    /// Controls the visibility of the sheet
    @Binding var isPresented: Bool
    /// The user's description of their feelings at the location
    @Binding var locationDescription: String
    /// The analyzed sentiment label
    @Binding var sentimentLabel: String
    /// The geographical coordinate of the selected location
    let coordinate: CLLocationCoordinate2D
    /// Callback for when the user submits their entry
    let onSubmit: () -> Void
    
    /// Tracks the focus state of the text input field
    @FocusState private var isTextFieldFocused: Bool
    
    // MARK: - Animation Properties
    @Namespace private var animation
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            
            // MARK: - Sentiment Display
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Circle()
                        .foregroundStyle(Color.accentColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text(sentimentLabel.isEmpty ? "?" : sentimentLabel.components(separatedBy: " ").first ?? "?")
                                .font(.system(.largeTitle, design: .rounded, weight: .medium))
                                .foregroundColor(.accentColor)
                                .scaleEffect(1.0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.5)
                                    .repeatCount(1),
                                    value: sentimentLabel
                                )
                        )
                    
                    if !sentimentLabel.isEmpty {
                        Text(sentimentLabel.components(separatedBy: " ").dropFirst().joined(separator: " "))
                            .font(.system(.body, design: .rounded, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                
                // MARK: - Input Section
                Text("How did you feel here?")
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                
                TextField("", text: $locationDescription, prompt: Text("Share your feelings...").foregroundColor(.gray.opacity(0.7)))
                    .font(.system(.body, design: .rounded))
                    .padding()
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    .focused($isTextFieldFocused)
                    .onChange(of: locationDescription) { _, newValue in
                        sentimentLabel = analyzer.mapSentiment(from: newValue)
                    }
                    .onSubmit {
                        if !locationDescription.isEmpty {
                            onSubmit()
                        }
                    }
            }
            .background(Color(UIColor.systemBackground))
            
            
            // MARK: - Navigation Bar
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
                    .foregroundColor(.accentColor)
                    .font(.system(.body, design: .rounded, weight: .medium)),
                
                trailing: Button("Done") {
                    if isTextFieldFocused && !locationDescription.isEmpty {
                        onSubmit()
                    } else {
                        isPresented = false
                    }
                }
                    .foregroundColor(.accentColor)
                    .font(.system(.body, design: .rounded, weight: .medium))
            )
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        
        .onAppear {
                isTextFieldFocused = true
        }
    }
}
