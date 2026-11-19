import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StationStore
    @EnvironmentObject var player: AudioPlayer
    @State private var selectedCategory = "全部"
    @State private var searchText = ""
    @State private var showNowPlaying = false

    private var categories: [String] {
        var set = Set(store.stations.map { $0.category })
        return categoryOrder.filter { set.contains($0) } + set.subtracting(categoryOrder).sorted()
    }

    private var filteredStations: [Station] {
        var list = store.stations
        if selectedCategory != "全部" {
            list = list.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.name.lowercased().contains(q) || $0.desc.lowercased().contains(q) || $0.group.lowercased().contains(q)
            }
        }
        return list
    }

    private var groupedStations: [(key: String, values: [Station])] {
        let groups = Dictionary(grouping: filteredStations, by: { $0.group })
        return groups.keys.sorted().compactMap { key in
            guard let values = groups[key] else { return nil }
            return (key, values)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // 标题
                        HStack(alignment: .lastTextBaseline) {
                            Text("波形电台")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundStyle(Theme.text)
                            Text("FM")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.primary)
                        }
                        Text("听见世界的声音")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)

                        // 分类
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 9) {
                                ForEach(categories, id: \.self) { cat in
                                    Button {
                                        withAnimation { selectedCategory = cat }
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: categoryIcon(cat)).font(.system(size: 12))
                                            Text(cat).font(.system(size: 13, weight: .medium))
                                        }
                                        .padding(.horizontal, 13)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? Theme.primary : Theme.surface)
                                        .foregroundStyle(selectedCategory == cat ? .white : Theme.textSecondary)
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // 电台列表
                        ForEach(groupedStations, id: \.key) { group in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(group.key)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.textSecondary)
                                    .padding(.leading, 4)
                                ForEach(group.values) { station in
                                    StationRow(
                                        station: station,
                                        isCurrent: player.current?.id == station.id,
                                        isPlaying: player.isPlaying,
                                        isFavorite: store.isFavorite(station),
                                        onPlay: {
                                            player.play(station)
                                            showNowPlaying = true
                                        },
                                        onFavorite: { store.toggleFavorite(station) }
                                    )
                                }
                            }
                        }

                        if filteredStations.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "radio")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Theme.textSecondary)
                                Text("没有找到电台").foregroundStyle(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }

                        // 底部留白给迷你播放器
                        if player.current != nil {
                            Color.clear.frame(height: 90)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .searchable(text: $searchText, prompt: "搜索电台名称")
            }
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                if let station = player.current {
                    miniPlayer(station)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $showNowPlaying) {
                NowPlayingView()
                    .environmentObject(store)
                    .environmentObject(player)
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func miniPlayer(_ station: Station) -> some View {
        Button { showNowPlaying = true } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Theme.color(hex: station.color).opacity(0.22))
                    Image(systemName: categoryIcon(station.category))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.color(hex: station.color))
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 3) {
                    Text(station.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    HStack(spacing: 5) {
                        if player.isBuffering {
                            Text("连接中…")
                        } else if player.isPlaying {
                            WaveformView(color: Theme.primary, active: true).frame(width: 16)
                            Text("直播中")
                        } else {
                            Text("已暂停")
                        }
                    }
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Button {
                    player.toggle()
                } label: {
                    ZStack {
                        Circle().fill(Theme.primary.opacity(0.2))
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.primary)
                            .padding(.leading, player.isPlaying ? 0 : 2)
                    }
                }
                .frame(width: 36, height: 36)
                .buttonStyle(.plain)
            }
            .padding(10)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.4), radius: 18, y: 8)
        }
        .buttonStyle(.plain)
    }
}
