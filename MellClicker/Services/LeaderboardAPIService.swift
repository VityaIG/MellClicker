import Foundation

// MARK: - Server Response Models

struct ServerLeaderboardResponse: Codable {
    let success: Bool
    let totalPlayers: Int?
    let leaderboard: [ServerLeaderboardItem]
    let updatedAt: Double?
}

struct ServerSubmitResponse: Codable {
    let success: Bool
    let userRank: Int?
    let totalPlayers: Int?
    let leaderboard: [ServerLeaderboardItem]
}

struct ServerLeaderboardItem: Codable {
    let id: String
    let name: String
    let score: Int
    let clicks: Int?
    let passiveIncome: Int?
    let avatarColorHex: String
    let updatedAt: Double?
}

// MARK: - Leaderboard API Service

final class LeaderboardAPIService {
    static let shared = LeaderboardAPIService()
    
    // Default server endpoint (supports live cloud backend and local development)
    private var baseURLString: String {
        // Reads custom server URL from UserDefaults if set by user or defaults to the official live cloud instance
        if let customURL = UserDefaults.standard.string(forKey: "mc_custom_server_url"), !customURL.isEmpty {
            return customURL
        }
        return "https://ais-pre-fr25lodey44lr32qocqq4y-550830551338.europe-west2.run.app"
    }
    
    private init() {}
    
    // MARK: - Fetch Global Online Leaderboard
    
    func fetchOnlineLeaderboard() async throws -> [LeaderboardEntry] {
        guard let url = URL(string: "\(baseURLString)/api/leaderboard") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8.0
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ServerLeaderboardResponse.self, from: data)
        guard decoded.success else {
            throw URLError(.cannotParseResponse)
        }
        
        return decoded.leaderboard.map { item in
            LeaderboardEntry(
                id: UUID(uuidString: item.id) ?? UUID(),
                name: item.name,
                score: item.score,
                isUser: false,
                avatarColorHex: item.avatarColorHex
            )
        }
    }
    
    // MARK: - Submit Player Score to Online Database
    
    func submitPlayerScore(
        playerId: UUID,
        name: String,
        score: Int,
        clicks: Int,
        passiveIncome: Int,
        avatarColorHex: String
    ) async throws -> (userRank: Int, entries: [LeaderboardEntry]) {
        guard let url = URL(string: "\(baseURLString)/api/leaderboard/submit") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let payload: [String: Any] = [
            "id": playerId.uuidString,
            "name": name,
            "score": score,
            "clicks": clicks,
            "passiveIncome": passiveIncome,
            "avatarColorHex": avatarColorHex
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(ServerSubmitResponse.self, from: data)
        guard decoded.success else {
            throw URLError(.cannotParseResponse)
        }
        
        let entries = decoded.leaderboard.map { item in
            LeaderboardEntry(
                id: UUID(uuidString: item.id) ?? UUID(),
                name: item.name,
                score: item.score,
                isUser: item.id == playerId.uuidString,
                avatarColorHex: item.avatarColorHex
            )
        }
        
        return (decoded.userRank ?? 1, entries)
    }
}
