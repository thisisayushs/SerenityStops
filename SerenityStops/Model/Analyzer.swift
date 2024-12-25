//
//  Analyzer.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 16/12/24.
//

import Foundation
import NaturalLanguage

/// A utility class that performs sentiment analysis on text input using Natural Language Processing.
///
/// The Analyzer class provides methods to analyze text and determine its emotional content,
/// mapping numerical sentiment scores to human-readable labels with appropriate emoji representations.
///
/// - Important: This class requires the Natural Language framework.
/// - Note: Sentiment scores range from -1.0 (most negative) to 1.0 (most positive).
final class Analyzer {
    
    // MARK: - Types
    
    /// Represents the possible emotional states that can be detected
    enum EmotionalState: String {
        case euphoric = "✨ Euphoric"
        case joyful = "🌸 Joyful"
        case content = "🌼 Content"
        case neutral = "🌿 Neutral"
        case reflective = "🍂 Reflective"
        case melancholic = "🌫️ Melancholic"
        case distressed = "⛈️ Distressed"
    }
    
    // MARK: - Initialization
    
    /// Shared instance for sentiment analysis
    static let shared = Analyzer()
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    // MARK: - Sentiment Analysis Methods
    
    /// Converts a numerical sentiment score into a human-readable string with an emoji.
    /// - Parameter sentimentScore: A Double value between -1.0 and 1.0.
    /// - Returns: A string containing an emoji and sentiment description.
    func sentimentString(from sentimentScore: Double) -> String {
        let clampedScore = max(-1.0, min(1.0, sentimentScore))
        
        switch clampedScore {
        case 0.8...1.0: return EmotionalState.euphoric.rawValue
        case 0.5..<0.8: return EmotionalState.joyful.rawValue
        case 0.2..<0.5: return EmotionalState.content.rawValue
        case -0.2..<0.2: return EmotionalState.neutral.rawValue
        case -0.5 ... -0.2: return EmotionalState.reflective.rawValue
        case -0.8 ... -0.5: return EmotionalState.melancholic.rawValue
        case -1.0 ... -0.8: return EmotionalState.distressed.rawValue
        default: return EmotionalState.neutral.rawValue
        }
    }
    
    /// Analyzes text to determine its sentiment score.
    /// - Parameter text: The input text to analyze.
    /// - Returns: A sentiment score between -1.0 and 1.0, or nil if analysis fails.
    /// - Note: Returns nil for empty or invalid input text.
    func getSentimentScore(from text: String) -> Double? {
        guard !text.isEmpty else { return nil }
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        guard let sentiment = tagger.tag(at: text.startIndex,
                                        unit: .paragraph,
                                        scheme: .sentimentScore).0 else {
            return nil
        }
        
        return Double(sentiment.rawValue)
    }
    
    /// Converts input text to a sentiment label with emoji.
    /// - Parameter text: The input text to analyze.
    /// - Returns: A string containing an emoji and sentiment description.
    /// - Note: Returns neutral sentiment for empty or invalid input.
    func mapSentiment(from text: String) -> String {
        guard let sentimentScore = getSentimentScore(from: text) else {
            return EmotionalState.neutral.rawValue
        }
        return sentimentString(from: sentimentScore)
    }
    
    /// Analyzes text to provide detailed emotional context.
    /// - Parameter text: The input text to analyze.
    /// - Returns: A tuple containing the sentiment label and intensity score.
    /// - Note: Intensity is always positive, representing the strength of the emotion.
    func analyzeEmotion(from text: String) -> (label: String, intensity: Double) {
        let score = getSentimentScore(from: text) ?? 0.0
        let label = mapSentiment(from: text)
        let intensity = abs(score)
        
        return (label, intensity)
    }
}
