import SwiftUI
import Charts

/// A view that displays statistics and visualizations of user's emotional experiences.
///
/// This view provides:
/// - Mood distribution charts
/// - Most frequent mood analysis
/// - Recent mood timeline
/// - Detailed entry history
///
/// - Important: Requires at least two different moods to display statistics
/// - Note: Uses SwiftUI Charts for data visualization
struct StatisticsView: View {
    // MARK: - Properties
    
    /// Summary of mood occurrences
    let moodSummary: [String: Int]
    
    /// Collection of recent mood entries
    let recentMoods: [LocationAnnotation]
    
    /// The most frequently recorded mood
    let mostFrequentMood: String
    
    // MARK: - Chart Data Structure
    
    /// Structure representing mood data for charts
    private struct MoodData: Identifiable {
        let id = UUID()
        let mood: String
        let count: Int
        
        var color: Color {
            switch mood {
            case "✨ Euphoric": return .pink
            case "🌸 Joyful": return .purple
            case "🌼 Content": return .yellow
            case "🌿 Neutral": return .green
            case "🍂 Reflective": return .orange
            case "🌫️ Melancholic": return .gray
            case "⛈️ Distressed": return .blue
            default: return .secondary
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let cardCornerRadius: CGFloat = 16
    private let cardPadding: CGFloat = 20
    private let chartHeight: CGFloat = 200
    
    // MARK: - Computed Properties
    
    private var chartData: [MoodData] {
        moodSummary.map { MoodData(mood: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private var hasEnoughData: Bool {
        chartData.count >= 2
    }
    
    // MARK: - View Components
    
    /// Card view for mood distribution chart
    private var moodDistributionCard: some View {
        StatisticsCard(title: "Mood Distribution") {
            Chart(chartData) { mood in
                BarMark(
                    x: .value("Count", mood.count),
                    y: .value("Mood", mood.mood)
                )
                .cornerRadius(8)
                .foregroundStyle(mood.color)
            }
            .frame(height: chartHeight)
            .chartLegend(.hidden)
            .accessibilityLabel("Mood distribution chart showing frequency of different moods")
        }
    }
    
    /// Card view for most frequent mood
    private var mostFrequentMoodCard: some View {
        StatisticsCard(title: "Most Frequent Mood") {
            Text(mostFrequentMood)
                .font(.system(.body, design: .rounded))
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityAddTraits(.isStaticText)
        }
    }
    
    /// Card view for mood timeline
    private var moodTimelineCard: some View {
        StatisticsCard(title: "Mood Timeline") {
            Chart(recentMoods) { mood in
                LineMark(
                    x: .value("Date", mood.createdAt),
                    y: .value("Mood", mood.label)
                )
                .symbol(by: .value("Mood", mood.label))
                .lineStyle(StrokeStyle(lineWidth: 2))
            }
            .frame(height: chartHeight)
            .chartLegend(.hidden)
            .accessibilityLabel("Timeline showing mood changes over time")
        }
    }
    
    /// Card view for recent entries
    private var recentEntriesCard: some View {
        StatisticsCard(title: "Recent Entries") {
            ForEach(recentMoods) { mood in
                HStack {
                    Text(mood.label)
                        .font(.system(.body, design: .rounded))
                    Spacer()
                    Text(mood.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(.callout, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
                .accessibilityElement(children: .combine)
                
                if mood.id != recentMoods.last?.id {
                    Divider()
                }
            }
        }
    }
    
    /// View shown when there isn't enough data
    private var notEnoughDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis.ascending")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            Text("Not Enough Data")
                .font(.title2)
                .bold()
            
            Text("Add at least 2 different moods\nto see statistics")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if hasEnoughData {
                    ScrollView {
                        VStack(spacing: 24) {
                            moodDistributionCard
                            mostFrequentMoodCard
                            moodTimelineCard
                            recentEntriesCard
                        }
                        .padding(16)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    notEnoughDataView
                }
            }
            .navigationTitle("Mood Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Supporting Views

/// A card view for displaying statistics sections
private struct StatisticsCard<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preview Provider

#Preview {
    StatisticsView(
        moodSummary: ["✨ Euphoric": 5, "🌿 Neutral": 3, "🍂 Reflective": 2],
        recentMoods: [],
        mostFrequentMood: "✨ Euphoric"
    )
}
