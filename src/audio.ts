// Web Audio engine for MellClicker sound effects (tap.mp3 & chekunec.mp3)

class SoundEngine {
  private audioCtx: AudioContext | null = null;
  private tapBuffer: AudioBuffer | null = null;
  private chekunecBuffer: AudioBuffer | null = null;
  private isLoaded = false;
  private isLoading = false;

  constructor() {
    // Lazy or proactive initialization
    if (typeof window !== 'undefined') {
      window.addEventListener('click', () => this.unlockContext(), { once: true });
      window.addEventListener('touchstart', () => this.unlockContext(), { once: true });
      this.loadBuffers();
    }
  }

  private getAudioContext(): AudioContext | null {
    if (!this.audioCtx && typeof window !== 'undefined') {
      const AudioContextClass = window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext;
      if (AudioContextClass) {
        this.audioCtx = new AudioContextClass();
      }
    }
    return this.audioCtx;
  }

  public unlockContext() {
    const ctx = this.getAudioContext();
    if (ctx && ctx.state === 'suspended') {
      ctx.resume().catch(() => {});
    }
  }

  private async loadBuffers() {
    if (this.isLoading || this.isLoaded || typeof window === 'undefined') return;
    this.isLoading = true;

    try {
      const ctx = this.getAudioContext();
      if (!ctx) return;

      const [tapRes, chekunecRes] = await Promise.all([
        fetch('/tap.mp3'),
        fetch('/chekunec.mp3')
      ]);

      if (tapRes.ok) {
        const tapData = await tapRes.arrayBuffer();
        this.tapBuffer = await ctx.decodeAudioData(tapData);
      }

      if (chekunecRes.ok) {
        const chekunecData = await chekunecRes.arrayBuffer();
        this.chekunecBuffer = await ctx.decodeAudioData(chekunecData);
      }

      this.isLoaded = true;
    } catch (e) {
      console.warn('Audio preloading failed, will use HTML5 Audio fallback', e);
    } finally {
      this.isLoading = false;
    }
  }

  public playTap(volume: number = 0.8) {
    this.unlockContext();
    const ctx = this.getAudioContext();

    if (ctx && this.tapBuffer) {
      try {
        const source = ctx.createBufferSource();
        source.buffer = this.tapBuffer;
        const gainNode = ctx.createGain();
        gainNode.gain.setValueAtTime(volume, ctx.currentTime);
        source.connect(gainNode);
        gainNode.connect(ctx.destination);
        source.start(0);
        return;
      } catch (err) {
        console.warn('Web Audio tap playback error', err);
      }
    }

    // Fallback to HTMLAudioElement
    try {
      const audio = new Audio('/tap.mp3');
      audio.volume = volume;
      audio.play().catch(() => {});
    } catch {
      // Ignored if blocked by browser policy
    }
  }

  public playChekunec(volume: number = 0.7) {
    this.unlockContext();
    const ctx = this.getAudioContext();

    if (ctx && this.chekunecBuffer) {
      try {
        const source = ctx.createBufferSource();
        source.buffer = this.chekunecBuffer;
        const gainNode = ctx.createGain();
        gainNode.gain.setValueAtTime(volume, ctx.currentTime);
        source.connect(gainNode);
        gainNode.connect(ctx.destination);
        source.start(0);
        return;
      } catch (err) {
        console.warn('Web Audio chekunec playback error', err);
      }
    }

    // Fallback to HTMLAudioElement
    try {
      const audio = new Audio('/chekunec.mp3');
      audio.volume = volume;
      audio.play().catch(() => {});
    } catch {
      // Ignored if blocked by browser policy
    }
  }
}

export const soundEngine = new SoundEngine();
