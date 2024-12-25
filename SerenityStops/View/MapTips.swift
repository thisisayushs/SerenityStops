//
//  MapTips.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import SwiftUI
import TipKit

/// A tip that guides users on how to interact with the map.
/// This tip explains that users can tap on the map to share their feelings about specific

struct MapTapTip: Tip {
    
    // MARK: - Tip Events
    static let mapTipDisplayed = Event(id: "mapTipDisplayed")
    
    // MARK: - Tip Content
    
    /// The main title of the tip
    var title: Text {
        Text("Start Your Journey")
            .foregroundStyle(.primary)
            .font(.headline)
    }
    
    /// Additional explanatory message for the tip
    var message: Text? {
        Text("Tap anywhere on the map to mark a location and share how you felt there")
            .foregroundStyle(.secondary)
            .font(.body)
    }
    
    var image: Image? {
        Image(systemName: "hand.tap")
            .resizable()
        
    }
}

/// A tip that shows how to delete annotations
/// This tip appears after the user creates their first annotation
struct DeleteAnnotationTip: Tip {
    // MARK: - Tip Content
    
    /// The main title of the tip
    var title: Text {
        Text("Managing Your Markers")
            .foregroundStyle(.primary)
            .font(.headline)
    }
    
    /// Additional explanatory message for the tip
    var message: Text? {
        Text("Press and hold any marker to reveal deletion options")
            .foregroundStyle(.secondary)
            .font(.body)
    }
    
    var image: Image? {
        Image(systemName: "trash")
            .resizable()
            
    }
    
    /// Rules for when this tip should be displayed
    var rules: [Rule] {
        [#Rule(MapTapTip.mapTipDisplayed) { $0.donations.count > 0 }]
    }
}
