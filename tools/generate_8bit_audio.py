from __future__ import annotations

import math
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RATE = 44100


def clamp(value: float, lo: float, hi: float) -> float:
    return max(lo, min(hi, value))


def square(freq: float, t: float, duty: float = 0.5) -> float:
    if freq <= 0:
        return 0.0
    phase = (t * freq) % 1.0
    return 1.0 if phase < duty else -1.0


def triangle(freq: float, t: float) -> float:
    if freq <= 0:
        return 0.0
    phase = (t * freq) % 1.0
    return 4.0 * abs(phase - 0.5) - 1.0


def envelope(pos: int, length: int, attack: float = 0.015, release: float = 0.08) -> float:
    if length <= 0:
        return 0.0
    a = max(1, int(RATE * attack))
    r = max(1, int(RATE * release))
    if pos < a:
        return pos / a
    if pos > length - r:
        return max(0.0, (length - pos) / r)
    return 1.0


def render_segments(segments: list[tuple[float, float]], volume: float = 0.75) -> bytes:
    samples: list[int] = []
    for freq, duration in segments:
        length = int(RATE * duration)
        for i in range(length):
            t = i / RATE
            env = envelope(i, length)
            value = square(freq, t, 0.45) * env * volume
            samples.append(int(clamp(128 + value * 92, 0, 255)))
    return bytes(samples)


def render_music(duration: float = 16.0) -> bytes:
    melody = [659, 784, 880, 784, 659, 587, 659, 0, 523, 659, 784, 988, 880, 784, 659, 0]
    bass = [131, 131, 196, 196, 147, 147, 220, 220]
    step = 0.25
    total = int(RATE * duration)
    samples = bytearray()
    for i in range(total):
        t = i / RATE
        beat = int(t / step)
        local = t - beat * step
        m = melody[beat % len(melody)]
        b = bass[(beat // 2) % len(bass)]
        env = envelope(int(local * RATE), int(step * RATE), 0.005, 0.045)
        lead = square(m, local, 0.35) * 0.45 * env
        low = triangle(b, t) * 0.22
        arp_note = [1046, 988, 880, 784][beat % 4]
        arp = square(arp_note, local, 0.25) * 0.12 * env
        value = lead + low + arp
        samples.append(int(clamp(128 + value * 86, 0, 255)))
    return bytes(samples)


def write_wav(name: str, data: bytes) -> None:
    out_dir = ROOT / "sounds" / name
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{name}.wav"
    with wave.open(str(out_path), "wb") as wav:
        wav.setnchannels(1)
        wav.setsampwidth(1)
        wav.setframerate(RATE)
        wav.writeframes(data)
    print(f"Wrote {out_path}")


def main() -> None:
    write_wav("snd_action", render_segments([(880, 0.045), (1320, 0.055), (1760, 0.06)], 0.65))
    write_wav("snd_event", render_segments([(392, 0.07), (0, 0.025), (262, 0.08), (196, 0.11)], 0.7))
    write_wav("snd_success", render_segments([(523, 0.07), (659, 0.07), (784, 0.08), (1046, 0.14)], 0.72))
    write_wav("snd_fail", render_segments([(392, 0.09), (330, 0.09), (262, 0.13)], 0.68))
    write_wav("snd_music_ecochip", render_music(16.0))


if __name__ == "__main__":
    main()
