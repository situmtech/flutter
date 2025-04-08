package com.situm.situm_flutter

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import java.util.Locale


class TextToSpeechManager(context: Context) : OnInitListener {

    private var textToSpeech = TextToSpeech(context, this)

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            // Establece el idioma (opcional)
            textToSpeech.setLanguage(Locale.getDefault())
        }
    }

    fun speak(text: String, lang: String, pitch: Float, rate: Float) {
        textToSpeech.setLanguage(Locale(lang))
        textToSpeech.setPitch(pitch)
        textToSpeech.setSpeechRate(convertToAndroidSpeechRate(rate))
        textToSpeech.speak(text, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    // ui.speak_aloud_text message sends the speech rate in FlutterTts scale [0.0f,1.0f],
    // so convert it to the Android scale [0.0f,2.0f].
    private fun convertToAndroidSpeechRate(value: Float): Float {
        return 2 * value
    }

    fun stop() {
        textToSpeech.stop()
        textToSpeech.shutdown()
    }

}

