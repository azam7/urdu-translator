# Urdu → English Real-Time Translator
## Bachy ke liye Bluetooth Hearing Device App

---

## App kya karti hai?

- **Mic se Urdu sunti hai** (surroundings ya YouTube speaker se)
- **Real-time English mein translate karti hai**
- **English audio Bluetooth device pe bhejti hai**
- **History save karti hai** (last 20 translations)
- **Auto-speak ON/OFF** toggle available

---

## Setup Instructions (Step by Step)

### Step 1 — Flutter Install karo
```
https://flutter.dev/docs/get-started/install
```
Flutter SDK download karo aur PATH mein add karo.

### Step 2 — Project folder mein jao
```bash
cd urdu_translator
```

### Step 3 — Dependencies install karo
```bash
flutter pub get
```

### Step 4 — Android phone connect karo
- Phone mein **Developer Options** enable karo
- **USB Debugging** ON karo
- Cable se PC se connect karo

### Step 5 — App run karo
```bash
flutter run
```

Ya release APK banao:
```bash
flutter build apk --release
```
APK milega: `build/outputs/flutter-apk/app-release.apk`

---

## Packages Used (Sab Free)

| Package | Kaam |
|---------|------|
| `speech_to_text` | Urdu speech recognize karna |
| `translator` | Google Translate (free, no API key) |
| `flutter_tts` | English bolna (TTS) |
| `permission_handler` | Mic permission |
| `shared_preferences` | Settings save karna |

---

## Bluetooth Kaise Kaam Karega?

Android automatically audio ko **default audio output** pe bhejta hai.
Agar Bluetooth device paired hai → automatically uspe jaayega.

**No extra code needed** — Android OS handle karta hai.

---

## Cost?

- Development/Testing: **$0**
- Google Translate (translator package): **Free** (unofficial API)
- Google STT: **Free** (device-based)
- Bluetooth: **Free**
- App install (side-load): **Free**
- Google Play publish: **$25 one-time** (optional)

---

## Features

- [x] Real-time Urdu speech recognition
- [x] Urdu → English translation
- [x] English text-to-speech (Bluetooth compatible)
- [x] Auto-speak toggle
- [x] Translation history (last 20)
- [x] Copy to clipboard
- [x] Speed/Volume/Pitch settings
- [x] Dark mode support
- [x] Simple 1-tap UI

---

## Troubleshooting

**Mic kaam nahi kar raha?**
→ Phone Settings > Apps > Urdu Translator > Permissions > Microphone ON

**Urdu recognize nahi ho raha?**
→ Phone Settings > General > Language & Input > Urdu (Pakistan) download karo

**Bluetooth audio nahi ja raha?**
→ Bluetooth device pehle pair karo, phir app open karo
→ Android audio output: Settings > Bluetooth > Device settings

---

## Support
Azam bhai, koi issue ho toh batao — fix kar deta hoon!
