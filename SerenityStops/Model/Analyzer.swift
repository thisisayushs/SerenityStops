//
//  Analyzer.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 16/12/24.
//

import Foundation
import NaturalLanguage

/// A class that performs sentiment analysis on text input.
/// This analyzer uses Natural Language Processing to determine the emotional content of text
/// and maps it to appropriate sentiment labels with emojis.

class Analyzer {
    
    // MARK: - Sentiment Analysis Methods
    
    /// Converts a numerical sentiment score into a human-readable string with an emoji
    /// - Parameter sentimentScore: A Double value between -1.0 and 1.0
    /// - Returns: A string containing an emoji and sentiment description
    func sentimentString(from sentimentScore: Double) -> String {
        switch sentimentScore {
        case 0.5...1.0:
            return "🌸 Joyful"
            
        case 0.2...0.5:
            return "🌼 Content"
            
        case -0.2...0.2:
            return "🌿 Neutral"
            
        case -0.5...0.2:
            return "🌿 Reflective"
            
        case -1.0...0.5:
            return "🍂 Stressed"
        default:
            return ""
        }
    }
    
    /// Analyzes text to determine its sentiment score
    /// - Parameter text: The input text to analyze
    /// - Returns: A sentiment score between -1.0 and 1.0, or nil if analysis fails
    
    func getSentimentScore(from text: String) -> Double? {
        
        let tagger = NLTagger(tagSchemes: [.tokenType, .sentimentScore])
        tagger.string = text
        var detectedSentiment: Double?
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .sentimentScore, options: []) { sentiment, _ in
            if let sentimentScore = sentiment {
                detectedSentiment = Double(sentimentScore.rawValue)
            }
            return true
        }
        
        return detectedSentiment
    }
    
    /// Converts input text to a sentiment label with emoji
    /// - Parameter text: The input text to analyze
    /// - Returns: A string containing an emoji and sentiment description
    
    func mapSentiment(from text: String) -> String {
        var sentimentEmoji: String = ""
        if let sentimentScore = getSentimentScore(from: text) {
            sentimentEmoji = sentimentString(from: sentimentScore)
        }
        
        return sentimentEmoji
        
    }
}
// End of file
