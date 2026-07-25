import SwiftUI
import SwiftData

public struct QuestListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query private var quests: [Quest]
    @StateObject private var viewModel = QuestViewModel()
    
    public init() {}
    
    private var filteredQuests: [Quest] {
        quests.filter { $0.category == viewModel.selectedFilter }
    }
    
    public var body: some View {
        ZStack {
            ALIVEColor.backgroundDark.ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Category Filter Segment Picker
                HStack(spacing: 8) {
                    ForEach(QuestCategory.allCases) { cat in
                        Button {
                            viewModel.selectedFilter = cat
                            HapticManager.shared.triggerImpact(style: .light)
                        } label: {
                            Text(cat.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedFilter == cat ? ALIVEColor.neonCyan : ALIVEColor.glassSurface)
                                .foregroundColor(viewModel.selectedFilter == cat ? .white : ALIVEColor.textSecondary)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 14) {
                        if filteredQuests.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "scroll.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(ALIVEColor.textMuted)
                                Text("No quests available in this category.")
                                    .font(.subheadline)
                                    .foregroundColor(ALIVEColor.textSecondary)
                            }
                            .padding(.top, 50)
                        } else {
                            if let profile = profiles.first {
                                ForEach(filteredQuests) { quest in
                                    QuestCardView(quest: quest, profile: profile)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("QUEST BOARD")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
