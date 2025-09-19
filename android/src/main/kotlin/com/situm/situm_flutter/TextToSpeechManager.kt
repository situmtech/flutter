package com.situm.situm_flutter

import android.content.Context
import android.os.Build
import android.speech.tts.TextToSpeech
import android.speech.tts.TextToSpeech.OnInitListener
import java.util.Locale


class TextToSpeechManager(context: Context) : OnInitListener {

    private val DEFAULT_SPEECH_RATE_VALUE = 1.0f
    private var textToSpeech: TextToSpeech

    init {
        val enginePackage = getPreferredTtsEnginePackage(context)
        textToSpeech = if (enginePackage != null) {
            TextToSpeech(context, this, enginePackage)
        } else {
            TextToSpeech(context, this)
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            // Establece el idioma (opcional)
            textToSpeech.language = Locale.getDefault()
        }
    }

    fun speak(arguments: Map<String, Any>) {
        if (arguments["text"] == null) return

        arguments["lang"]?.let {
            textToSpeech.setLanguage(Locale(it as String))
        }
        arguments["pitch"]?.let {
            textToSpeech.setPitch((it as Double).toFloat())
        }
        arguments["rate"]?.let {
            textToSpeech.setSpeechRate(convertToAndroidSpeechRate((it as Double).toFloat()))
        }

        textToSpeech.speak(arguments["text"] as String, TextToSpeech.QUEUE_FLUSH, null, null)
    }

    // ui.speak_aloud_text message sends the speech rate in FlutterTts scale [0.0f,1.0f],
    // so convert it to the Android scale [0.0f,2.0f].
    private fun convertToAndroidSpeechRate(value: Float): Float {
        if (value < 0 || value > 1.0f) {
            return DEFAULT_SPEECH_RATE_VALUE
        }
        return 2 * value
    }

    fun stop() {
        textToSpeech.stop()
        textToSpeech.shutdown()
    }

    private fun getPreferredTtsEnginePackage(context: Context): String? {
        val ttsTemp = TextToSpeech(context) { }
        val engines = ttsTemp.engines
        ttsTemp.shutdown()

        val googleTts = "com.google.android.tts"
        return if (Build.MANUFACTURER.equals("Samsung", ignoreCase = true) &&
            engines.any { it.name == googleTts }
        ) {
            googleTts
        } else {
            null
        }
    }

}

