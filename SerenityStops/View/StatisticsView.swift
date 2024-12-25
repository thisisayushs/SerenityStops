import SwiftUI
import Charts

struct StatisticsView: View {
    // MARK: - Properties
    let moodSummary: [String: Int]
    let recentMoods: [LocationAnnotation]
    let mostFrequentMood: String
    
    // MARK: - Chart Data Structure
    struct MoodData: Identifiable {
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
    
    // MARK: - Computed Properties
    private var chartData: [MoodData] {
        moodSummary.map { MoodData(mood: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
    }
    
    private var hasEnoughData: Bool {
        chartData.count >= 2
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            Group {
                if hasEnoughData {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Mood Distribution Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Mood Distribution")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.primary)
                                
                                Chart(chartData) { mood in
                                    BarMark(
                                        x: .value("Count", mood.count),
                                        y: .value("Mood", mood.mood)
                                    )
                                    .cornerRadius(8)
                                    .foregroundStyle(mood.color)
                                }
                                .frame(height: 200)
                                .chartLegend(.hidden)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                            )
                            
                            // Most Frequent Mood Card
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Most Frequent Mood")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.primary)
                                
                                Text(mostFrequentMood)
                                    .font(.system(.body, design: .rounded))
                                    .padding(.vertical, 8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                            )
                            
                            // Mood Timeline Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Mood Timeline")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.primary)
                                
                                Chart(recentMoods) { mood in
                                    LineMark(
                                        x: .value("Date", mood.createdAt),
                                        y: .value("Mood", mood.label)
                                    )
                                    .symbol(by: .value("Mood", mood.label))
                                    .lineStyle(StrokeStyle(lineWidth: 2))
                                }
                                .frame(height: 200)
                                .chartLegend(.hidden)
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                            )
                            
                            // Recent Entries Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Entries")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.primary)
                                
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
                                    if mood.id != recentMoods.last?.id {
                                        Divider()
                                    }
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.background)
                                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                            )
                        }
                        .padding(16)
                    }
                    .background(Color(.systemGroupedBackground))
                } else {
                    // Not enough data view
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis.ascending")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)
                        
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
            }
            .navigationTitle("Mood Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview
#Preview {
    StatisticsView(
        moodSummary: [" Joyful": 5, " Neutral": 3, " Reflective": 2],
        recentMoods: [],
        mostFrequentMood: " Joyful"
    )
}
