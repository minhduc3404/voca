package com.voca.remember

import com.ryanheise.audioservice.AudioServiceActivity

// audio_service (phát TTS nền + lock-screen control): AudioServiceActivity
// (subclass FlutterFragmentActivity) chia sẻ đúng Flutter engine với
// foreground service — thay FlutterActivity trơn trước đây.
class MainActivity : AudioServiceActivity()
