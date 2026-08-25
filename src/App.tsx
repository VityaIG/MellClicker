import React from 'react';

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
    <div className="min-h-screen w-full flex items-center justify-center p-4">
      <button
        onClick={handleDownload}
        className="px-6 py-3 bg-black hover:bg-gray-800 text-white font-semibold rounded-lg shadow-md transition-all active:scale-95 cursor-pointer flex items-center gap-2"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          className="w-5 h-5"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
          strokeWidth={2}
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
          />
        </svg>
        Download IPA
      </button>
    </div>
  );
}

