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
        case 0.8...1.0:
            return "✨ Euphoric"
        case 0.5...0.8:
            return "🌸 Joyful"
        case 0.2...0.5:
            return "🌼 Content"
        case -0.2...0.2:
            return "🌿 Neutral"
        case -0.5 ... -0.2:
            return "🍂 Reflective"
        case -0.8 ... -0.5:
            return "🌫️ Melancholic"
        case -1.0 ... -0.8:
            return "⛈️ Distressed"
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
    
    /// Enhanced method to analyze text and provide more context
    /// - Parameter text: The input text to analyze
    /// - Returns: A tuple containing the sentiment label and intensity score
    func analyzeEmotion(from text: String) -> (label: String, intensity: Double) {
        var intensity = 0.0
        let label = mapSentiment(from: text)
        
        if let score = getSentimentScore(from: text) {
            intensity = abs(score)  // Convert score to intensity (0.0 to 1.0)
        }
        
        return (label, intensity)
    }
}
// End of file
