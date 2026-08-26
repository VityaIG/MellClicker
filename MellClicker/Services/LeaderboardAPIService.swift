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
    
    // Candidate backend server hosts for high-availability synchronization
    private var candidateHosts: [String] {
        var hosts: [String] = []
        
        // 1. User-customized server endpoint if specified in Settings
        if let custom = UserDefaults.standard.string(forKey: "mc_custom_server_url"),
           !custom.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hosts.append(custom.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        // 2. Production & Preview Live Cloud Server instances
        hosts.append("https://ais-pre-fr25lodey44lr32qocqq4y-550830551338.europe-west2.run.app")
        hosts.append("https://ais-dev-fr25lodey44lr32qocqq4y-550830551338.europe-west2.run.app")
        hosts.append("http://localhost:3000")
        
        return hosts
    }
    
    private init() {}
    
    // MARK: - Ping / Diagnostics
    
    func pingServer() async -> (isOnline: Bool, latencyMs: Int, host: String) {
        let hosts = candidateHosts
        for host in hosts {
            guard let url = URL(string: "\(host)/api/health") else { continue }
            let startTime = CFAbsoluteTimeGetCurrent()
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.timeoutInterval = 3.0
            
            do {
                let (_, response) = try await URLSession.shared.data(for: req)
                if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                    let elapsed = Int((CFAbsoluteTimeGetCurrent() - startTime) * 1000)
                    return (true, elapsed, host)
                }
            } catch {
                continue
            }
        }
        return (false, 0, "")
    }
    
    // MARK: - Fetch Global Online Leaderboard
    
    func fetchOnlineLeaderboard() async throws -> [LeaderboardEntry] {
        var lastError: Error = URLError(.cannotConnectToHost)
        
        for host in candidateHosts {
            guard let url = URL(string: "\(host)/api/leaderboard") else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 4.0
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    continue
                }
                
                let decoded = try JSONDecoder().decode(ServerLeaderboardResponse.self, from: data)
                guard decoded.success else { continue }
                
                return decoded.leaderboard.map { item in
                    LeaderboardEntry(
                        id: item.id,
                        name: item.name,
                        score: item.score,
                        isUser: false,
                        avatarColorHex: item.avatarColorHex
                    )
                }
            } catch {
                lastError = error
                continue
            }
        }
        
        throw lastError
    }
    
    // MARK: - Submit Player Score to Online DB
    
    func submitPlayerScore(
        playerId: String,
        name: String,
        score: Int,
        clicks: Int,
        passiveIncome: Int,
        avatarColorHex: String
    ) async throws -> (rank: Int, entries: [LeaderboardEntry]) {
        var lastError: Error = URLError(.cannotConnectToHost)
        
        let payload: [String: Any] = [
            "id": playerId,
            "name": name,
            "score": score,
            "clicks": clicks,
            "passiveIncome": passiveIncome,
            "avatarColorHex": avatarColorHex
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            throw URLError(.badURL)
        }
        
        for host in candidateHosts {
            guard let url = URL(string: "\(host)/api/leaderboard/submit") else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.timeoutInterval = 4.0
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.httpBody = jsonData
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    continue
                }
                
                let decoded = try JSONDecoder().decode(ServerSubmitResponse.self, from: data)
                guard decoded.success else { continue }
                
                let userRank = decoded.userRank ?? 1
                let list = decoded.leaderboard.map { item in
                    LeaderboardEntry(
                        id: item.id,
                        name: item.name,
                        score: item.score,
                        isUser: item.id == playerId,
                        avatarColorHex: item.avatarColorHex
                    )
                }
                
                return (userRank, list)
            } catch {
                lastError = error
                continue
            }
        }
        
        throw lastError
    }
}
