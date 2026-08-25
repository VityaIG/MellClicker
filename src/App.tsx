import React from 'react';
import { Download, Smartphone, CheckCircle, ExternalLink } from 'lucide-react';

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
    <main className="min-h-screen w-full bg-slate-900 text-slate-100 flex flex-col items-center justify-center p-6 antialiased">
      <div className="w-full max-w-md bg-slate-800/90 border border-slate-700/80 rounded-2xl p-8 shadow-2xl flex flex-col items-center text-center">
        <div className="w-24 h-24 rounded-2xl overflow-hidden shadow-lg border border-slate-600/50 mb-6 bg-slate-950 flex items-center justify-center">
          <img
            src="/mellclickericon.png"
            alt="Логотип MellClicker"
            className="w-full h-full object-cover"
          />
        </div>

        <h1 className="text-2xl font-bold tracking-tight text-white mb-1">
          MellClicker
        </h1>
        <p className="text-sm font-medium text-orange-400 mb-6">
          Релиз 1.0.0 (Версия 1.0.0)
        </p>

        <div className="w-full bg-slate-900/70 border border-slate-800 rounded-xl p-4 mb-6 text-left space-y-2 text-sm text-slate-300">
          <div className="flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Нативный интерфейс SwiftUI</span>
          </div>
          <div className="flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Аудиодвижок AVFoundation</span>
          </div>
          <div className="flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Тактильный отклик Taptic Engine</span>
          </div>
          <div className="flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400 shrink-0" />
            <span>Магазин улучшений («Чекушка» и «Чекунец»)</span>
          </div>
        </div>

        <button
          id="download-ipa-button"
          onClick={handleDownload}
          className="w-full py-3.5 px-5 bg-orange-500 hover:bg-orange-600 active:bg-orange-700 text-white font-semibold rounded-xl shadow-lg shadow-orange-500/20 transition-all flex items-center justify-center gap-2.5 cursor-pointer"
        >
          <Download className="w-5 h-5" />
          <span>Скачать MellClicker.ipa (Релиз 1.0.0)</span>
        </button>

        <div className="mt-6 pt-6 border-t border-slate-700/60 w-full flex items-center justify-between text-xs text-slate-400">
          <span className="flex items-center gap-1.5">
            <Smartphone className="w-3.5 h-3.5" />
            iOS 16.0+
          </span>
          <a
            href="https://t.me/VityaV"
            target="_blank"
            rel="noopener noreferrer"
            className="text-orange-400 hover:underline flex items-center gap-1"
          >
            Telegram: @VityaV
            <ExternalLink className="w-3 h-3" />
          </a>
        </div>
      </div>
    </main>
  );
}


