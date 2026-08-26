import React, { useState, useEffect } from 'react';
import { Download, Smartphone, CheckCircle, ExternalLink, Trophy, Users, RefreshCw, Volume2, VolumeX, Flame, Zap, Award, Sparkles } from 'lucide-react';

interface LeaderboardPlayer {
  id: string;
  rank: number;
  name: string;
  score: number;
  clicks?: number;
  passiveIncome?: number;
  avatarColorHex: string;
}

export default function App() {
  // Game State
  const [balance, setBalance] = useState<number>(() => {
    const saved = localStorage.getItem('mc_web_balance');
    return saved ? parseInt(saved, 10) : 0;
  });
  const [clickMultiplier, setClickMultiplier] = useState<number>(() => {
    const saved = localStorage.getItem('mc_web_multiplier');
    return saved ? parseInt(saved, 10) : 1;
  });
  const [chekushkaCost, setChekushkaCost] = useState<number>(() => {
    const saved = localStorage.getItem('mc_web_chekushka_cost');
    return saved ? parseInt(saved, 10) : 100;
  });
  const [autoClickerCount, setAutoClickerCount] = useState<number>(() => {
    const saved = localStorage.getItem('mc_web_autoclicker_count');
    return saved ? parseInt(saved, 10) : 0;
  });
  const [chekunecCost, setChekunecCost] = useState<number>(() => {
    const saved = localStorage.getItem('mc_web_chekunec_cost');
    return saved ? parseInt(saved, 10) : 1000;
  });

  const [username, setUsername] = useState<string>(() => {
    return localStorage.getItem('mc_web_username') || 'Игрок_' + Math.floor(1000 + Math.random() * 9000);
  });
  const [playerId] = useState<string>(() => {
    let id = localStorage.getItem('mc_web_player_id');
    if (!id) {
      id = 'web-' + Math.random().toString(36).substring(2, 11);
      localStorage.setItem('mc_web_player_id', id);
    }
    return id;
  });

  // Stats & Combo
  const [combo, setCombo] = useState<number>(0);
  const [isSoundEnabled, setIsSoundEnabled] = useState<boolean>(true);
  const [isClicking, setIsClicking] = useState<boolean>(false);
  const [activeTab, setActiveTab] = useState<'game' | 'leaderboard'>('game');

  // Online Leaderboard State
  const [leaderboard, setLeaderboard] = useState<LeaderboardPlayer[]>([]);
  const [isLoadingLeaderboard, setIsLoadingLeaderboard] = useState<boolean>(false);
  const [serverOnline, setServerOnline] = useState<boolean>(true);

  // Audio synthesis for instant web clicks without blocking
  const playWebSound = (type: 'tap' | 'chekunec') => {
    if (!isSoundEnabled) return;
    try {
      const audioCtx = new (window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext)();
      const osc = audioCtx.createOscillator();
      const gain = audioCtx.createGain();
      
      if (type === 'tap') {
        osc.frequency.setValueAtTime(440 + Math.min(combo * 10, 400), audioCtx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(180, audioCtx.currentTime + 0.08);
        gain.gain.setValueAtTime(0.3, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.08);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.09);
      } else {
        osc.type = 'triangle';
        osc.frequency.setValueAtTime(220, audioCtx.currentTime);
        osc.frequency.linearRampToValueAtTime(550, audioCtx.currentTime + 0.12);
        gain.gain.setValueAtTime(0.25, audioCtx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.12);
        osc.connect(gain);
        gain.connect(audioCtx.destination);
        osc.start();
        osc.stop(audioCtx.currentTime + 0.13);
      }
    } catch {
      // Audio context might be restricted before user gesture
    }
  };

  // Combo decay
  useEffect(() => {
    if (combo <= 0) return;
    const timer = setTimeout(() => {
      setCombo(prev => Math.max(0, prev - 1));
    }, 800);
    return () => clearTimeout(timer);
  }, [combo]);

  // Passive Income Timer
  useEffect(() => {
    if (autoClickerCount <= 0) return;
    const interval = setInterval(() => {
      setBalance(prev => {
        const next = prev + autoClickerCount;
        localStorage.setItem('mc_web_balance', next.toString());
        return next;
      });
      playWebSound('chekunec');
    }, 1000);
    return () => clearInterval(interval);
  }, [autoClickerCount, isSoundEnabled]);

  // Save changes
  useEffect(() => {
    localStorage.setItem('mc_web_balance', balance.toString());
    localStorage.setItem('mc_web_multiplier', clickMultiplier.toString());
    localStorage.setItem('mc_web_chekushka_cost', chekushkaCost.toString());
    localStorage.setItem('mc_web_autoclicker_count', autoClickerCount.toString());
    localStorage.setItem('mc_web_chekunec_cost', chekunecCost.toString());
    localStorage.setItem('mc_web_username', username);
  }, [balance, clickMultiplier, chekushkaCost, autoClickerCount, chekunecCost, username]);

  // Sync to database
  const syncScoreToDatabase = async () => {
    try {
      const res = await fetch('/api/leaderboard/submit', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          id: playerId,
          name: username,
          score: balance,
          clicks: 1,
          passiveIncome: autoClickerCount,
          avatarColorHex: '#34C759'
        })
      });
      if (res.ok) {
        const data = await res.json();
        if (data.leaderboard) {
          setLeaderboard(data.leaderboard);
        }
        setServerOnline(true);
      }
    } catch {
      setServerOnline(false);
    }
  };

  // Fetch online leaderboard
  const fetchLeaderboard = async () => {
    setIsLoadingLeaderboard(true);
    try {
      const res = await fetch('/api/leaderboard');
      if (res.ok) {
        const data = await res.json();
        setLeaderboard(data.leaderboard || []);
        setServerOnline(true);
      }
    } catch {
      setServerOnline(false);
    } finally {
      setIsLoadingLeaderboard(false);
    }
  };

  useEffect(() => {
    fetchLeaderboard();
  }, []);

  // Periodic score sync
  useEffect(() => {
    const timer = setTimeout(() => {
      syncScoreToDatabase();
    }, 2000);
    return () => clearTimeout(timer);
  }, [balance, username]);

  const comboMultiplier = combo >= 50 ? 3.0 : combo >= 25 ? 2.0 : combo >= 10 ? 1.5 : 1.0;
  const effectivePower = Math.max(1, Math.round(clickMultiplier * comboMultiplier));

  const handleTap = () => {
    setBalance(prev => prev + effectivePower);
    setCombo(prev => Math.min(100, prev + 1));
    setIsClicking(true);
    playWebSound('tap');
    setTimeout(() => setIsClicking(false), 80);
  };

  const buyChekushka = () => {
    if (balance < chekushkaCost) return;
    setBalance(prev => prev - chekushkaCost);
    setClickMultiplier(prev => prev + 1);
    setChekushkaCost(prev => Math.floor(prev * 1.5));
  };

  const buyChekunec = () => {
    if (balance < chekunecCost) return;
    setBalance(prev => prev - chekunecCost);
    // Double passive income: 0 -> 1 -> 2 -> 4 -> 8 -> 16
    setAutoClickerCount(prev => (prev === 0 ? 1 : prev * 2));
    setChekunecCost(prev => Math.floor(prev * 2.5));
  };

  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = '/MellClicker.ipa';
    link.download = 'MellClicker.ipa';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <main className="min-h-screen w-full bg-slate-950 text-slate-100 flex flex-col items-center justify-start p-4 sm:p-6 antialiased">
      {/* Top Header Card */}
      <header className="w-full max-w-md flex items-center justify-between py-3 px-4 bg-slate-900/80 border border-slate-800 rounded-2xl mb-4 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl overflow-hidden bg-black border border-slate-700 flex items-center justify-center shrink-0">
            <img src="/mellclickericon.png" alt="MellClicker" className="w-full h-full object-cover" />
          </div>
          <div>
            <h1 className="text-base font-bold text-white leading-tight">MellClicker</h1>
            <div className="flex items-center gap-1.5 text-xs text-slate-400">
              <span className={`w-2 h-2 rounded-full ${serverOnline ? 'bg-emerald-400 animate-pulse' : 'bg-amber-400'}`} />
              <span>{serverOnline ? 'База данных Онлайн' : 'Автономный режим'}</span>
            </div>
          </div>
        </div>

        <button
          id="sound-toggle-button"
          onClick={() => setIsSoundEnabled(!isSoundEnabled)}
          className="p-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 transition-colors"
          title={isSoundEnabled ? 'Выключить звук' : 'Включить звук'}
        >
          {isSoundEnabled ? <Volume2 className="w-4 h-4 text-emerald-400" /> : <VolumeX className="w-4 h-4 text-slate-500" />}
        </button>
      </header>

      {/* Navigation Tabs */}
      <nav className="w-full max-w-md grid grid-cols-2 gap-2 mb-4 bg-slate-900/60 p-1 rounded-2xl border border-slate-800">
        <button
          id="tab-game"
          onClick={() => setActiveTab('game')}
          className={`py-2 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
            activeTab === 'game' ? 'bg-orange-500 text-white shadow-lg shadow-orange-500/20' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Zap className="w-3.5 h-3.5" />
          Кликер & Магазин
        </button>
        <button
          id="tab-leaderboard"
          onClick={() => {
            setActiveTab('leaderboard');
            fetchLeaderboard();
          }}
          className={`py-2 px-4 rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-1.5 ${
            activeTab === 'leaderboard' ? 'bg-orange-500 text-white shadow-lg shadow-orange-500/20' : 'text-slate-400 hover:text-slate-200'
          }`}
        >
          <Trophy className="w-3.5 h-3.5" />
          Онлайн Лидеры ({leaderboard.length || 10})
        </button>
      </nav>

      {/* Main Content Area */}
      <section className="w-full max-w-md bg-slate-900/90 border border-slate-800 rounded-3xl p-6 shadow-2xl flex flex-col items-center backdrop-blur-sm">
        {activeTab === 'game' ? (
          <div className="w-full flex flex-col items-center">
            {/* Balance & Power Display */}
            <div className="w-full text-center mb-6">
              <div className="text-xs font-bold tracking-wider text-slate-400 uppercase mb-1">Баланс монет</div>
              <div className="text-4xl font-extrabold text-white tracking-tight flex items-center justify-center gap-2">
                <span>{balance.toLocaleString('ru-RU')}</span>
                <span className="text-orange-400 text-2xl">🪙</span>
              </div>
              <div className="flex items-center justify-center gap-4 mt-2 text-xs text-slate-400">
                <span>Сила клика: <strong className="text-emerald-400">+{effectivePower}</strong></span>
                <span>•</span>
                <span>Доход: <strong className="text-orange-400">+{autoClickerCount}/сек</strong></span>
              </div>
            </div>

            {/* Combo Streak Indicator */}
            {combo >= 10 && (
              <div className="w-full mb-4 px-3 py-1.5 rounded-xl bg-gradient-to-r from-orange-500/20 to-red-500/20 border border-orange-500/40 flex items-center justify-between text-xs animate-pulse">
                <div className="flex items-center gap-1.5 font-bold text-orange-400">
                  <Flame className="w-4 h-4 text-orange-500" />
                  {combo >= 50 ? '💥 FRENZY x3.0' : combo >= 25 ? '🔥 МЕГА x2.0' : '⚡️ КОМБО x1.5'}
                </div>
                <div className="text-slate-300 font-mono">{combo} кликов подряд</div>
              </div>
            )}

            {/* Central Clicker Button */}
            <div className="my-4 flex items-center justify-center">
              <button
                id="main-click-button"
                onClick={handleTap}
                className={`relative w-40 h-40 rounded-full border-4 border-orange-500/80 bg-gradient-to-b from-orange-500 to-amber-600 shadow-2xl shadow-orange-500/40 transition-transform active:scale-90 flex flex-col items-center justify-center cursor-pointer select-none overflow-hidden ${
                  isClicking ? 'scale-95' : 'hover:scale-105'
                }`}
              >
                <div className="absolute inset-0 bg-white/10 rounded-full pointer-events-none" />
                <span className="text-5xl drop-shadow-md">👑</span>
                <span className="text-xs font-black tracking-wider text-white mt-1 uppercase">КЛИК</span>
              </button>
            </div>

            {/* Shop Section */}
            <div className="w-full mt-4 space-y-3">
              <div className="text-xs font-bold text-slate-400 uppercase tracking-wider text-left">Магазин улучшений</div>
              
              {/* Chekushka Upgrade */}
              <div className="w-full p-3 rounded-2xl bg-slate-950/60 border border-slate-800 flex items-center justify-between">
                <div>
                  <div className="text-sm font-bold text-white flex items-center gap-1.5">
                    <span>🍺</span> «Чекушка» (+1 к клику)
                  </div>
                  <div className="text-xs text-slate-400">Уровень: {clickMultiplier}</div>
                </div>
                <button
                  id="buy-chekushka-button"
                  onClick={buyChekushka}
                  disabled={balance < chekushkaCost}
                  className="py-2 px-3 rounded-xl bg-orange-500 hover:bg-orange-600 disabled:opacity-40 disabled:hover:bg-orange-500 font-bold text-xs text-white transition-all cursor-pointer"
                >
                  {chekushkaCost.toLocaleString('ru-RU')} 🪙
                </button>
              </div>

              {/* Chekunec Auto-Clicker Upgrade (Duplicates x2) */}
              <div className="w-full p-3 rounded-2xl bg-slate-950/60 border border-orange-500/30 flex items-center justify-between">
                <div>
                  <div className="text-sm font-bold text-white flex items-center gap-1.5">
                    <span>🍾</span> «Чекунец» (Удвоение x2)
                  </div>
                  <div className="text-xs text-slate-400">
                    Автодоход: <strong className="text-emerald-400">+{autoClickerCount}/с</strong>
                  </div>
                </div>
                <button
                  id="buy-chekunec-button"
                  onClick={buyChekunec}
                  disabled={balance < chekunecCost}
                  className="py-2 px-3 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 disabled:opacity-40 disabled:hover:from-emerald-500 font-bold text-xs text-white transition-all cursor-pointer"
                >
                  {chekunecCost.toLocaleString('ru-RU')} 🪙
                </button>
              </div>
            </div>
          </div>
        ) : (
          /* Leaderboard Tab */
          <div className="w-full flex flex-col items-center">
            {/* Header & Refresh */}
            <div className="w-full flex items-center justify-between mb-4">
              <div className="text-left">
                <div className="text-sm font-bold text-white flex items-center gap-1.5">
                  <Trophy className="w-4 h-4 text-yellow-400" />
                  Глобальная база данных
                </div>
                <div className="text-xs text-slate-400">Реальные игроки онлайн</div>
              </div>

              <button
                id="refresh-leaderboard-button"
                onClick={fetchLeaderboard}
                disabled={isLoadingLeaderboard}
                className="flex items-center gap-1 text-xs py-1.5 px-3 rounded-xl bg-slate-800 hover:bg-slate-700 text-orange-400 font-semibold transition-colors cursor-pointer"
              >
                <RefreshCw className={`w-3.5 h-3.5 ${isLoadingLeaderboard ? 'animate-spin' : ''}`} />
                <span>Обновить</span>
              </button>
            </div>

            {/* User Profile Card */}
            <div className="w-full p-3 rounded-2xl bg-gradient-to-r from-orange-500/10 to-amber-500/10 border border-orange-500/30 mb-4 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-emerald-500/20 border border-emerald-500/50 flex items-center justify-center font-bold text-emerald-400 text-sm">
                  {username.charAt(0).toUpperCase()}
                </div>
                <div className="text-left">
                  <div className="flex items-center gap-1.5">
                    <input
                      id="username-input"
                      type="text"
                      value={username}
                      onChange={e => setUsername(e.target.value)}
                      className="bg-transparent border-b border-dashed border-slate-600 focus:border-orange-400 outline-none text-xs font-bold text-white w-28"
                      title="Кликните чтобы сменить ник"
                    />
                    <span className="text-[10px] font-bold bg-orange-500/20 text-orange-400 px-1.5 py-0.5 rounded">ВЫ</span>
                  </div>
                  <div className="text-xs text-slate-400 mt-0.5">{balance.toLocaleString('ru-RU')} монет</div>
                </div>
              </div>
              <div className="text-right">
                <div className="text-[10px] font-bold text-slate-400 uppercase">Автодоход</div>
                <div className="text-xs font-bold text-emerald-400">+{autoClickerCount}/с</div>
              </div>
            </div>

            {/* Leaderboard Table */}
            <div className="w-full space-y-2 max-h-72 overflow-y-auto pr-1">
              {leaderboard.length === 0 ? (
                <div className="py-8 text-center text-xs text-slate-400">Загрузка данных...</div>
              ) : (
                leaderboard.map((item, idx) => {
                  const isCurrent = item.id === playerId;
                  const rank = idx + 1;
                  return (
                    <div
                      key={item.id || idx}
                      className={`w-full p-2.5 rounded-xl flex items-center justify-between text-xs transition-all ${
                        isCurrent
                          ? 'bg-orange-500/15 border border-orange-500/40 text-white'
                          : 'bg-slate-950/60 border border-slate-800/80 text-slate-300'
                      }`}
                    >
                      <div className="flex items-center gap-2.5">
                        <span className={`w-5 font-bold text-center ${rank === 1 ? 'text-yellow-400' : rank === 2 ? 'text-slate-300' : rank === 3 ? 'text-amber-500' : 'text-slate-500'}`}>
                          #{rank}
                        </span>
                        <div
                          className="w-7 h-7 rounded-full flex items-center justify-center text-white text-[11px] font-bold shrink-0"
                          style={{ backgroundColor: item.avatarColorHex || '#FF9500' }}
                        >
                          {item.name.charAt(0).toUpperCase()}
                        </div>
                        <span className="font-semibold text-slate-200 truncate max-w-[120px]">
                          {item.name} {isCurrent && <strong className="text-orange-400 ml-1">(Вы)</strong>}
                        </span>
                      </div>
                      <div className="font-bold font-mono text-white text-right">
                        {item.score.toLocaleString('ru-RU')} 🪙
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        )}

        {/* Download IPA Section */}
        <div className="w-full mt-6 pt-5 border-t border-slate-800/80">
          <button
            id="download-ipa-button"
            onClick={handleDownload}
            className="w-full py-3.5 px-4 bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-600 hover:to-amber-600 active:scale-[0.98] text-white font-bold rounded-2xl shadow-lg shadow-orange-500/20 transition-all flex items-center justify-center gap-2 text-xs cursor-pointer"
          >
            <Download className="w-4 h-4" />
            <span>Скачать MellClicker.ipa (iOS)</span>
          </button>
        </div>

        {/* Footer info */}
        <footer className="mt-4 w-full flex items-center justify-between text-[11px] text-slate-400">
          <span className="flex items-center gap-1">
            <Smartphone className="w-3.5 h-3.5 text-slate-400" />
            iOS 16.0+ (SwiftUI & Ad-Hoc Signed)
          </span>
          <a
            href="https://t.me/VityaV"
            target="_blank"
            rel="noopener noreferrer"
            className="text-orange-400 hover:text-orange-300 flex items-center gap-1 font-medium transition-colors"
          >
            Telegram: @VityaV
            <ExternalLink className="w-3 h-3" />
          </a>
        </footer>
      </section>
    </main>
  );
}
