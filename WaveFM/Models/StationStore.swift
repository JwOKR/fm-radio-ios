import Foundation

final class StationStore: ObservableObject {
    @Published var stations: [Station] = []
    @Published var favoriteIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(favoriteIDs), forKey: "wavefm.favorites")
        }
    }

    private static let favoritesKey = "wavefm.favorites"

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: Self.favoritesKey) ?? []
        favoriteIDs = Set(saved)
        stations = Self.loadStations()
    }

    func isFavorite(_ station: Station) -> Bool {
        favoriteIDs.contains(station.id)
    }

    func toggleFavorite(_ station: Station) {
        if favoriteIDs.contains(station.id) {
            favoriteIDs.remove(station.id)
        } else {
            favoriteIDs.insert(station.id)
        }
    }

    /// 优先读取 bundle 中的 stations.json（便于自定义音源），
    /// 读取失败则回退到内置列表，保证 App 永远有电台可用。
    private static func loadStations() -> [Station] {
        if let url = Bundle.main.url(forResource: "stations", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([Station].self, from: data),
           !list.isEmpty {
            return list
        }
        return builtinStations
    }

    private static let builtinStations: [Station] = [
        Station(id: "cnr-zgzs", name: "中国之声", desc: "中央广播电视总台 · 新闻与资讯", group: "中央广播电视总台", category: "新闻资讯", url: "https://ngcdn001.cnr.cn/live/zgzs/index.m3u8", color: "E0533D"),
        Station(id: "cnr-jjzs", name: "经济之声", desc: "财经资讯 · 市场动态", group: "中央广播电视总台", category: "新闻资讯", url: "https://ngcdn002.cnr.cn/live/jjzs/index.m3u8", color: "E39B34"),
        Station(id: "cnr-yyzs", name: "音乐之声", desc: "流行音乐 · 早安中国", group: "中央广播电视总台", category: "音乐", url: "https://ngcdn001.cnr.cn/live/yyzs/index.m3u8", color: "E75A9E"),
        Station(id: "cnr-dszs", name: "经典音乐广播", desc: "经典音乐 · 典藏时光", group: "中央广播电视总台", category: "音乐", url: "https://ngcdn001.cnr.cn/live/dszs/index.m3u8", color: "9B6DE0"),
        Station(id: "cnr-wyzs", name: "文艺之声", desc: "文化 · 阅读 · 故事", group: "中央广播电视总台", category: "文化", url: "https://ngcdn001.cnr.cn/live/wyzs/index.m3u8", color: "4FA88C"),
        Station(id: "cnr-lnzs", name: "老年之声", desc: "银发时光 · 健康生活", group: "中央广播电视总台", category: "文化", url: "https://satellitepull.cnr.cn/live/wxlnzs/playlist.m3u8", color: "5BA8C4"),
        Station(id: "cnr-mzzs", name: "民族之声", desc: "民族音乐 · 各地风情", group: "中央广播电视总台", category: "文化", url: "https://satellitepull.cnr.cn/live/wxmzzs/playlist.m3u8", color: "C97B4A"),
        Station(id: "cnr-yyzs-bak", name: "音乐之声 · 备线", desc: "卫星线路 · 音质备选", group: "央广备线源", category: "音乐", url: "https://satellitepull.cnr.cn/live/wxyyzs/playlist.m3u8", color: "D96A9E"),
        Station(id: "cnr-dszs-bak", name: "经典音乐 · 备线", desc: "卫星线路 · 音质备选", group: "央广备线源", category: "音乐", url: "https://satellitepull.cnr.cn/live/wxdszs/playlist.m3u8", color: "8E68D0"),
        Station(id: "cnr-jjzs-bak", name: "经济之声 · 备线", desc: "卫星线路 · 音质备选", group: "央广备线源", category: "新闻资讯", url: "https://satellitepull.cnr.cn/live/wxjjzs/playlist.m3u8", color: "D18F33"),
        Station(id: "cnr-wyzs-bak", name: "文艺之声 · 备线", desc: "卫星线路 · 音质备选", group: "央广备线源", category: "文化", url: "https://satellitepull.cnr.cn/live/wxwyzs/playlist.m3u8", color: "45A080"),
        Station(id: "cri-nhzs", name: "南海之声", desc: "国际在线 · 南海频道", group: "国际在线 CRI", category: "国际", url: "https://sk.cri.cn/nhzs.m3u8", color: "3D9BE0"),
        Station(id: "cri-hyhq", name: "华语环球", desc: "国际在线 · 全球华语", group: "国际在线 CRI", category: "国际", url: "https://sk.cri.cn/hyhq.m3u8", color: "4E83D8"),
        Station(id: "cri-hqzx", name: "环球资讯", desc: "国际在线 · 环球新闻", group: "国际在线 CRI", category: "国际", url: "https://sk.cri.cn/905.m3u8", color: "5E7FD0"),
        Station(id: "cri-sjhs", name: "世界华声", desc: "国际在线 · 世界之声", group: "国际在线 CRI", category: "国际", url: "https://sk.cri.cn/hxfh.m3u8", color: "6F7BC8"),
        Station(id: "cri-cp", name: "China Plus Radio", desc: "国际在线 · 英语广播 AM846", group: "国际在线 CRI", category: "国际", url: "https://sk.cri.cn/am846.m3u8", color: "7A74BE"),
        Station(id: "qtfm-zgzs", name: "中国之声 · 蜻蜓源", desc: "蜻蜓FM · 64K 备线", group: "其他音源", category: "新闻资讯", url: "https://lhttp.qtfm.cn/live/15318317/64k.mp3", color: "C25B72"),
    ]
}
