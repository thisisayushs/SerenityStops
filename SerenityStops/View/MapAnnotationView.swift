//
//  AnnotationMarkerView.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import SwiftUI
import MapKit

/// A view that represents a map annotation marker displaying sentiment information.
/// This view provides:
/// - Visual representation of sentiment labels on the map
/// - Context menu for deletion
/// - Styled appearance with background and shadow

struct MapAnnotationView: View {
    // MARK: - Properties
    
    /// The annotation data to display
    let annotation: LocationAnnotation
    /// Index of the annotation in the annotations array
    let index: Int
    /// Callback triggered when the annotation is deleted
    var onDelete: () -> Void
    /// Callback triggered when the annotation is tapped
    var onTap: () -> Void
    
    var body: some View {
        
        
        Text(annotation.label)
            .font(.system(.caption, design: .rounded, weight: .medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.accentColor))
            .foregroundColor(.black.opacity(0.7))
            .shadow(color: .black.opacity(0.15), radius: 5, x: 0, y: 2)
            .onTapGesture {
                onTap()
            }
            .contextMenu {
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        
        
        
    }
    
    
}
// End of file
