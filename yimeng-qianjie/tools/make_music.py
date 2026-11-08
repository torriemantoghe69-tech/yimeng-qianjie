"""Generate seamless ambient loops for 《一梦千劫》.

The loops are synthesized from scratch with numpy and written as 22.05 kHz,
16-bit mono WAV files. Notes and reverb tails wrap around the loop boundary so
the tracks repeat without a click. No external samples are used.
"""

from __future__ import annotations

import math
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets" / "audio"
SR = 22050
RNG = np.random.default_rng(20261031)


def midi_hz(note: int) -> float:
    return 440.0 * (2.0 ** ((note - 69) / 12.0))


def _wrapped_add(out: np.ndarray, sound: np.ndarray, at_seconds: float) -> None:
    n = out.size
    start = int(round(at_seconds * SR)) % n
    if sound.size >= n:
        sound = sound[:n]
    index = (start + np.arange(sound.size)) % n
    np.add.at(out, index, sound)


def _pad(out: np.ndarray, note: int, amp: float, cycles: int = 2) -> None:
    """A slow periodic drone whose frequencies are exact loop harmonics."""
    n = out.size
    t = np.arange(n) / SR
    base = midi_hz(note)
    for ratio, level in ((1.0, 1.0), (1.5, 0.45), (2.0, 0.28), (3.0, 0.12)):
        target = base * ratio
        cycles_count = max(1, int(round(target * n / SR)))
        freq = cycles_count * SR / n
        phase = RNG.uniform(0.0, math.tau)
        lfo_phase = RNG.uniform(0.0, math.tau)
        lfo = 0.78 + 0.22 * np.sin(math.tau * cycles * t / (n / SR) + lfo_phase)
        out += amp * level * lfo * np.sin(math.tau * freq * t + phase)


def _air(out: np.ndarray, amp: float) -> None:
    """Band-limited periodic noise, used as wind/room texture."""
    n = out.size
    freqs = np.fft.rfftfreq(n, 1.0 / SR)
    shape = 1.0 / (1.0 + (freqs / 720.0) ** 2.2)
    spectrum = (RNG.normal(0.0, 1.0, freqs.size) + 1j * RNG.normal(0.0, 1.0, freqs.size)) * shape
    spectrum[0] = 0.0
    noise = np.fft.irfft(spectrum, n=n)
    noise /= max(1e-9, np.max(np.abs(noise)))
    t = np.arange(n) / SR
    duration = n / SR
    swell = 0.62 + 0.38 * np.sin(math.tau * 2.0 * t / duration + 0.9)
    out += noise * swell * amp


def _pluck(note: int, duration: float, amp: float, softness: float = 1.0) -> np.ndarray:
    n = int(duration * SR)
    t = np.arange(n) / SR
    freq = midi_hz(note)
    # A tiny downward pitch bend gives the string a guqin-like "press" feel.
    bend = 2.0 ** (-0.055 * (1.0 - np.exp(-t * 7.0)) / 12.0)
    phase = math.tau * freq * np.cumsum(bend) / SR + RNG.uniform(0.0, 0.2)
    signal = np.zeros(n)
    for index, ratio in enumerate((1.0, 2.003, 3.009, 4.018, 5.04)):
        level = (1.0, 0.46, 0.22, 0.10, 0.052)[index]
        decay = (1.0, 1.5, 2.4, 3.4, 5.0)[index] * softness
        signal += level * np.sin(phase * ratio + index * 0.37) * np.exp(-t * decay)
    attack = 1.0 - np.exp(-t * 130.0)
    # Short filtered string noise.
    grain = RNG.normal(0.0, 1.0, n)
    for _ in range(2):
        grain = np.convolve(grain, np.ones(9) / 9.0, mode="same")
    signal += grain * np.exp(-t * 38.0) * 0.18
    signal *= attack * np.exp(-t * 0.32)
    peak = np.max(np.abs(signal))
    if peak > 1e-9:
        signal /= peak
    # Wrap the tail rather than fading; this keeps every layer loop-periodic.
    return signal * amp


def _bell(note: int, duration: float, amp: float) -> np.ndarray:
    n = int(duration * SR)
    t = np.arange(n) / SR
    freq = midi_hz(note)
    signal = np.zeros(n)
    for index, ratio in enumerate((1.0, 2.01, 2.72, 4.12, 5.48, 7.03)):
        level = (1.0, 0.54, 0.32, 0.18, 0.10, 0.05)[index]
        decay = (0.75, 1.05, 1.45, 2.0, 2.8, 3.8)[index]
        signal += level * np.sin(math.tau * freq * ratio * t + index * 0.73) * np.exp(-t * decay)
    attack = 1.0 - np.exp(-t * 70.0)
    signal *= attack
    peak = np.max(np.abs(signal))
    if peak > 1e-9:
        signal /= peak
    return signal * amp


def _flute(note: int, duration: float, amp: float) -> np.ndarray:
    n = int(duration * SR)
    t = np.arange(n) / SR
    freq = midi_hz(note)
    vibrato = 1.0 + 0.0065 * np.sin(math.tau * 4.4 * t + RNG.uniform(0, math.tau))
    breath = RNG.normal(0.0, 1.0, n)
    for _ in range(3):
        breath = np.convolve(breath, np.ones(17) / 17.0, mode="same")
    shape = np.sin(np.pi * np.clip(t / duration, 0.0, 1.0)) ** 1.35
    signal = np.sin(math.tau * freq * np.cumsum(vibrato) / SR + RNG.uniform(0, 0.3))
    signal += 0.24 * np.sin(math.tau * freq * 2.0 * np.cumsum(vibrato) / SR + 0.6)
    signal += breath * 0.06
    signal *= shape
    peak = np.max(np.abs(signal))
    if peak > 1e-9:
        signal /= peak
    return signal * amp


def _drum(note: int, duration: float, amp: float) -> np.ndarray:
    n = int(duration * SR)
    t = np.arange(n) / SR
    freq = midi_hz(note)
    sweep = freq * (1.0 + 0.75 * np.exp(-t * 24.0))
    phase = math.tau * np.cumsum(sweep) / SR
    signal = np.sin(phase) * np.exp(-t * 5.2)
    noise = RNG.normal(0.0, 1.0, n)
    for _ in range(4):
        noise = np.convolve(noise, np.ones(23) / 23.0, mode="same")
    signal += noise * np.exp(-t * 26.0) * 0.24
    signal *= 1.0 - np.exp(-t * 180.0)
    peak = np.max(np.abs(signal))
    if peak > 1e-9:
        signal /= peak
    return signal * amp


def _reverb(x: np.ndarray, amount: float) -> np.ndarray:
    """Circular convolution reverb keeps the loop seamless and wrapped."""
    n = x.size
    impulse_len = int(1.35 * SR)
    t = np.arange(impulse_len) / SR
    impulse = RNG.normal(0.0, 1.0, impulse_len) * np.exp(-t * 3.8)
    kernel = np.hanning(45)
    impulse = np.convolve(impulse, kernel / kernel.sum(), mode="same")
    for delay, gain in ((0.031, 0.42), (0.073, 0.27), (0.129, 0.16), (0.211, 0.1)):
        at = int(delay * SR)
        impulse[at] += gain
    impulse /= max(1e-9, np.max(np.abs(impulse)))
    wet = np.fft.irfft(np.fft.rfft(x, n=n) * np.fft.rfft(impulse, n=n), n=n)
    return x * (1.0 - amount) + wet * amount


def _finish(x: np.ndarray, name: str) -> np.ndarray:
    x = x.astype(np.float64)
    x -= x.mean()
    # Gentle low-pass sparkle control.
    x = np.convolve(x, np.array([0.12, 0.76, 0.12]), mode="same")
    peak = np.max(np.abs(x))
    if peak > 1e-9:
        x = x / peak * 0.82
    x = np.tanh(x * 1.05)
    x /= max(1e-9, np.max(np.abs(x)))
    x = (x * 0.84 * 32767.0).astype(np.int16)
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    with wave.open(str(path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(2)
        wav.setframerate(SR)
        wav.writeframes(x.tobytes())
    print(f"{name}: {x.size / SR:.1f}s, peak={np.max(np.abs(x.astype(float)))/32767:.2f}, rms={np.sqrt(np.mean((x.astype(float)/32767)**2)):.3f}")
    return x


def make_menu() -> np.ndarray:
    duration = 32.0
    n = int(duration * SR)
    out = np.zeros(n, dtype=np.float64)
    _pad(out, 38, 0.070, cycles=2)   # D2
    _pad(out, 45, 0.042, cycles=3)   # A2
    _pad(out, 50, 0.028, cycles=3)   # D3
    _air(out, 0.011)
    melody = [
        (0.8, 62, 6.0, 0.15), (4.2, 65, 5.5, 0.14), (7.6, 69, 6.0, 0.13),
        (10.9, 67, 5.5, 0.12), (14.8, 74, 7.0, 0.12), (18.1, 69, 5.5, 0.13),
        (22.4, 65, 6.0, 0.13), (25.7, 62, 6.0, 0.14), (29.2, 69, 5.0, 0.10),
    ]
    for at, note, length, amp in melody:
        _wrapped_add(out, _pluck(note, length, amp, 1.0), at)
    for at, note, length, amp in [
        (3.1, 81, 8.0, 0.045), (12.6, 79, 8.0, 0.042),
        (21.8, 86, 7.0, 0.034), (30.5, 81, 6.0, 0.030),
    ]:
        _wrapped_add(out, _bell(note, length, amp), at)
    return _finish(_reverb(out, 0.30), "menu_theme.wav")


def make_cultivation() -> np.ndarray:
    duration = 32.0
    n = int(duration * SR)
    out = np.zeros(n, dtype=np.float64)
    _pad(out, 45, 0.075, cycles=2)   # A2
    _pad(out, 52, 0.040, cycles=3)   # E3
    _pad(out, 57, 0.022, cycles=2)   # A3
    _air(out, 0.013)
    melody = [
        (0.5, 57, 5.5, 0.10), (5.5, 60, 5.0, 0.09), (10.2, 64, 5.5, 0.09),
        (14.8, 67, 6.0, 0.10), (20.7, 69, 5.5, 0.10), (25.0, 72, 5.0, 0.09),
        (29.5, 64, 5.0, 0.08),
    ]
    for at, note, length, amp in melody:
        _wrapped_add(out, _pluck(note, length, amp, 1.35), at)
    _wrapped_add(out, _flute(69, 7.0, 0.055), 7.0)
    _wrapped_add(out, _flute(64, 6.0, 0.045), 22.0)
    _wrapped_add(out, _bell(81, 8.0, 0.028), 17.0)
    return _finish(_reverb(out, 0.34), "cultivation_theme.wav")


def make_event() -> np.ndarray:
    duration = 28.0
    n = int(duration * SR)
    out = np.zeros(n, dtype=np.float64)
    _pad(out, 38, 0.050, cycles=2)   # D2
    _pad(out, 41, 0.034, cycles=3)   # F2, minor colour
    _pad(out, 50, 0.020, cycles=4)
    _air(out, 0.016)
    for at in (0.0, 4.0, 8.0, 12.0, 16.0, 20.0, 24.0):
        _wrapped_add(out, _drum(38, 1.6, 0.075), at)
    melody = [
        (0.8, 50, 3.0, 0.10), (2.4, 53, 2.8, 0.10), (4.3, 55, 3.0, 0.095),
        (6.1, 57, 2.8, 0.10), (8.0, 60, 3.0, 0.11), (10.2, 62, 3.0, 0.10),
        (12.1, 65, 3.0, 0.10), (14.5, 69, 3.2, 0.10), (16.2, 62, 2.8, 0.09),
        (18.8, 57, 3.0, 0.10), (20.5, 60, 2.8, 0.095), (22.8, 55, 3.0, 0.09),
        (24.4, 53, 2.8, 0.095), (26.1, 50, 2.5, 0.09),
    ]
    for at, note, length, amp in melody:
        _wrapped_add(out, _pluck(note, length, amp, 0.85), at)
    for at, note in ((3.0, 74), (11.0, 77), (19.0, 74), (25.0, 70)):
        _wrapped_add(out, _bell(note, 5.0, 0.035), at)
    return _finish(_reverb(out, 0.24), "event_theme.wav")


def make_ending() -> np.ndarray:
    duration = 36.0
    n = int(duration * SR)
    out = np.zeros(n, dtype=np.float64)
    _pad(out, 33, 0.072, cycles=2)   # A1
    _pad(out, 40, 0.038, cycles=2)   # E2
    _pad(out, 45, 0.020, cycles=3)   # A2
    _air(out, 0.014)
    melody = [
        (0.5, 69, 7.0, 0.13), (5.0, 67, 7.0, 0.12), (9.5, 64, 7.5, 0.12),
        (14.0, 62, 7.0, 0.11), (18.5, 60, 7.5, 0.11), (23.0, 57, 7.0, 0.12),
        (27.5, 55, 7.0, 0.11), (31.5, 52, 4.0, 0.09),
    ]
    for at, note, length, amp in melody:
        _wrapped_add(out, _pluck(note, length, amp, 1.5), at)
    for at, note in ((2.0, 81), (13.0, 77), (24.0, 76), (34.0, 69)):
        _wrapped_add(out, _bell(note, 7.0, 0.032), at)
    _wrapped_add(out, _flute(64, 8.0, 0.04), 17.0)
    return _finish(_reverb(out, 0.38), "ending_theme.wav")


def main() -> None:
    make_menu()
    make_cultivation()
    make_event()
    make_ending()


if __name__ == "__main__":
    main()
