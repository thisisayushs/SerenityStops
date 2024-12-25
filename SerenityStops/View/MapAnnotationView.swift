//
//  AnnotationMarkerView.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import SwiftUI
import MapKit

/// A customizable view that represents a sentiment annotation on the map.
///
/// This view displays emotional experience markers on the map with:
/// - Custom styling and animations
/// - Interactive features (tap and context menu)
/// - Accessibility support
///
/// - Note: Uses system rounded fonts for consistent styling
struct MapAnnotationView: View {
    // MARK: - Properties
    
    /// The annotation data to display on the map
    let annotation: LocationAnnotation
    /// Index of the annotation in the collection
    let index: Int
    /// Callback triggered when the annotation is deleted
    var onDelete: () -> Void
    /// Callback triggered when the annotation is tapped
    var onTap: () -> Void
    
    // MARK: - Private Properties
    
    private let cornerRadius: CGFloat = 20
    private let shadowRadius: CGFloat = 5
    
    var body: some View {
        
        
        annotationLabel
            .transition(.scale.combined(with: .opacity))
        
    }
    
    // MARK: - View Components
    
    private var annotationLabel: some View {
        Text(annotation.label)
            .font(.system(.caption, design: .rounded, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.accentColor)
            )
            .foregroundColor(.black.opacity(0.7))
            .shadow(
                color: .black.opacity(0.15),
                radius: shadowRadius,
                x: 0,
                y: 2
            )
            .onTapGesture(perform: onTap)
            .contextMenu {
                deleteButton
            }
            
    }
    
    private var deleteButton: some View {
        Button(role: .destructive) {
            onDelete()
        } label: {
            Label("Delete marker", systemImage: "trash")
        }
    }
}
// End of file
