import React from 'react';
import { Download, Smartphone, CheckCircle, ExternalLink, Trophy, Users, Palette, Sparkles } from 'lucide-react';

export default function App() {
  const handleDownload = () => {
    const link = document.createElement('a');
    link.href = '/MellClicker.ipa';
    link.download = 'MellClicker.ipa';
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <main className="min-h-screen w-full bg-slate-950 text-slate-100 flex flex-col items-center justify-center p-6 antialiased">
      <div className="w-full max-w-md bg-slate-900/90 border border-slate-800 rounded-3xl p-8 shadow-2xl flex flex-col items-center text-center backdrop-blur-sm">
        {/* App Icon */}
        <div className="w-24 h-24 rounded-2xl overflow-hidden shadow-2xl border border-slate-700/80 mb-5 bg-black flex items-center justify-center">
          <img
            src="/mellclickericon.png"
            alt="Логотип MellClicker"
            className="w-full h-full object-cover"
          />
        </div>

        <h1 className="text-2xl font-bold tracking-tight text-white mb-1">
          MellClicker
        </h1>
        <p className="text-xs font-semibold px-3 py-1 rounded-full bg-orange-500/10 text-orange-400 border border-orange-500/20 mb-6">
          Обновление 1.2.0 • Удвоение «Чекунца», Комбо & Frenzy
        </p>

        {/* Feature Highlights */}
        <div className="w-full bg-slate-950/60 border border-slate-800/80 rounded-2xl p-4 mb-6 text-left space-y-2.5 text-xs text-slate-300">
          <div className="flex items-center gap-2.5">
            <Sparkles className="w-4 h-4 text-emerald-400 shrink-0" />
            <span><strong>Чекунец (x2):</strong> каждая покупка удваивает пассивный доход (+1, +2, +4, +8/сек)</span>
          </div>
          <div className="flex items-center gap-2.5">
            <Trophy className="w-4 h-4 text-yellow-400 shrink-0" />
            <span><strong>Комбо & Frenzy:</strong> быстрые клики дают множители x1.5, x2.0 и x3.0 FRENZY</span>
          </div>
          <div className="flex items-center gap-2.5">
            <Users className="w-4 h-4 text-sky-400 shrink-0" />
            <span><strong>Звания и уровни:</strong> от «Новичка» до «Легенды Меллстроя»</span>
          </div>
          <div className="flex items-center gap-2.5">
            <CheckCircle className="w-4 h-4 text-orange-400 shrink-0" />
            <span><strong>Улучшенный аудиодвижок:</strong> tap.mp3 и chekunec.mp3 с тестом звука в Настройках</span>
          </div>
        </div>

        {/* Download Action */}
        <button
          id="download-ipa-button"
          onClick={handleDownload}
          className="w-full py-4 px-5 bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-600 hover:to-amber-600 active:scale-[0.98] text-white font-bold rounded-2xl shadow-xl shadow-orange-500/20 transition-all flex items-center justify-center gap-2.5 cursor-pointer"
        >
          <Download className="w-5 h-5" />
          <span>Скачать MellClicker.ipa</span>
        </button>

        <div className="mt-6 pt-5 border-t border-slate-800/80 w-full flex items-center justify-between text-xs text-slate-400">
          <span className="flex items-center gap-1.5">
            <Smartphone className="w-3.5 h-3.5 text-slate-400" />
            iOS 16.0+ (SwiftUI)
          </span>
          <a
            href="https://t.me/VityaV"
            target="_blank"
            rel="noopener noreferrer"
            className="text-orange-400 hover:text-orange-300 hover:underline flex items-center gap-1 font-medium transition-colors"
          >
            Telegram: @VityaV
            <ExternalLink className="w-3 h-3" />
          </a>
        </div>
      </div>
    </main>
  );
}
