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
    
    // MARK: - Tip Content
    
    /// The main title of the tip
    var title: Text {
        Text("Tap on the map")
    }
    
    /// Additional explanatory message for the tip
    var message: Text? {
        Text("Tap anywhere on the map to share how you felt at that location")
        
    }
}
// End of file
