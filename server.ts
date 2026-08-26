import express from "express";
import cors from "cors";
import path from "path";
import fs from "fs";
import { createServer as createViteServer } from "vite";

interface LeaderboardRecord {
  id: string;
  name: string;
  score: number;
  clicks?: number;
  passiveIncome?: number;
  avatarColorHex: string;
  updatedAt: number;
}

const DB_FILE = path.join(process.cwd(), "leaderboard.json");

// Initial active players seed
const SEED_PLAYERS: LeaderboardRecord[] = [
  { id: "seed-1", name: "Mellstroy_VIP", score: 8540200, clicks: 124500, passiveIncome: 64, avatarColorHex: "#FF9500", updatedAt: Date.now() - 60000 },
  { id: "seed-2", name: "Александр_Топ", score: 4120800, clicks: 87300, passiveIncome: 32, avatarColorHex: "#34C759", updatedAt: Date.now() - 120000 },
  { id: "seed-3", name: "CryptoKing99", score: 2980000, clicks: 65400, passiveIncome: 16, avatarColorHex: "#007AFF", updatedAt: Date.now() - 180000 },
  { id: "seed-4", name: "Чекушечник228", score: 1450000, clicks: 42100, passiveIncome: 8, avatarColorHex: "#AF52DE", updatedAt: Date.now() - 240000 },
  { id: "seed-5", name: "MaxPower_PRO", score: 980500, clicks: 28900, passiveIncome: 4, avatarColorHex: "#FF2D55", updatedAt: Date.now() - 300000 },
  { id: "seed-6", name: "СтримХайп", score: 620400, clicks: 19500, passiveIncome: 2, avatarColorHex: "#FF9500", updatedAt: Date.now() - 360000 },
  { id: "seed-7", name: "ClickGod", score: 380100, clicks: 12400, passiveIncome: 2, avatarColorHex: "#5856D6", updatedAt: Date.now() - 420000 },
  { id: "seed-8", name: "Иван_Чекунец", score: 195000, clicks: 8200, passiveIncome: 1, avatarColorHex: "#34C759", updatedAt: Date.now() - 480000 },
  { id: "seed-9", name: "MellFan2026", score: 98400, clicks: 4900, passiveIncome: 1, avatarColorHex: "#FF3B30", updatedAt: Date.now() - 540000 },
  { id: "seed-10", name: "Тапер_3000", score: 45200, clicks: 2300, passiveIncome: 0, avatarColorHex: "#007AFF", updatedAt: Date.now() - 600000 }
];

function loadDatabase(): Map<string, LeaderboardRecord> {
  const map = new Map<string, LeaderboardRecord>();
  try {
    if (fs.existsSync(DB_FILE)) {
      const data = fs.readFileSync(DB_FILE, "utf-8");
      const records: LeaderboardRecord[] = JSON.parse(data);
      records.forEach(r => map.set(r.id, r));
    } else {
      SEED_PLAYERS.forEach(r => map.set(r.id, r));
      saveDatabase(map);
    }
  } catch (err) {
    console.error("Error loading leaderboard database:", err);
    SEED_PLAYERS.forEach(r => map.set(r.id, r));
  }
  return map;
}

function saveDatabase(map: Map<string, LeaderboardRecord>) {
  try {
    const list = Array.from(map.values()).sort((a, b) => b.score - a.score);
    fs.writeFileSync(DB_FILE, JSON.stringify(list, null, 2), "utf-8");
  } catch (err) {
    console.error("Error saving leaderboard database:", err);
  }
}

const database = loadDatabase();

async function startServer() {
  const app = express();
  const PORT = 3000;

  app.use(cors());
  app.use(express.json());

  // Health check
  app.get("/api/health", (_req, res) => {
    res.json({ status: "ok", timestamp: Date.now() });
  });

  // GET /api/leaderboard - Return global online rankings
  app.get("/api/leaderboard", (_req, res) => {
    const sorted = Array.from(database.values())
      .sort((a, b) => b.score - a.score)
      .slice(0, 100)
      .map((entry, index) => ({
        ...entry,
        rank: index + 1
      }));

    res.json({
      success: true,
      totalPlayers: database.size,
      leaderboard: sorted,
      updatedAt: Date.now()
    });
  });

  // POST /api/leaderboard/submit - Update or register a player's score
  app.post("/api/leaderboard/submit", (req, res) => {
    try {
      const { id, name, score, clicks, passiveIncome, avatarColorHex } = req.body;

      if (!id || typeof id !== "string") {
        return res.status(400).json({ success: false, error: "Missing or invalid playerId (id)" });
      }

      const cleanName = (typeof name === "string" && name.trim().length > 0)
        ? name.trim().substring(0, 30)
        : "Игрок";

      const numericScore = Math.max(0, parseInt(score, 10) || 0);
      const numericClicks = Math.max(0, parseInt(clicks, 10) || 0);
      const numericPassive = Math.max(0, parseInt(passiveIncome, 10) || 0);
      const cleanAvatar = (typeof avatarColorHex === "string" && avatarColorHex.startsWith("#"))
        ? avatarColorHex
        : "#FF9500";

      const record: LeaderboardRecord = {
        id,
        name: cleanName,
        score: numericScore,
        clicks: numericClicks,
        passiveIncome: numericPassive,
        avatarColorHex: cleanAvatar,
        updatedAt: Date.now()
      };

      database.set(id, record);
      saveDatabase(database);

      const allSorted = Array.from(database.values()).sort((a, b) => b.score - a.score);
      const userRank = allSorted.findIndex(r => r.id === id) + 1;

      res.json({
        success: true,
        userRank,
        totalPlayers: database.size,
        leaderboard: allSorted.slice(0, 100).map((entry, idx) => ({
          ...entry,
          rank: idx + 1
        }))
      });
    } catch (err) {
      console.error("Error submitting score:", err);
      res.status(500).json({ success: false, error: "Internal server error" });
    }
  });

  // Vite middleware for frontend development
  if (process.env.NODE_ENV !== "production") {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: "spa",
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), "dist");
    app.use(express.static(distPath));
    app.get("*", (_req, res) => {
      res.sendFile(path.join(distPath, "index.html"));
    });
  }

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
  });
}

startServer();
