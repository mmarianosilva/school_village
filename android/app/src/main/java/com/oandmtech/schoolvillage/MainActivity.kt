package com.oandmtech.schoolvillage

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import android.os.Bundle
import android.app.NotificationChannel
import android.app.NotificationManager
import android.net.Uri
import android.media.AudioAttributes
import android.widget.Toast
import android.content.Intent

class MainActivity : FlutterActivity() {

    protected override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        AppCenter.start(getApplication(), "c5b4ce38-f8e5-458b-8f10-8328d37d76a3",
                Analytics::class.java, Crashes::class.java)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            // Amber alert channel
            val CHANNEL_ID = "sv_alert"
            val name: CharSequence = "Amber Alert"
            val importance: Int = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance)
            val uri: Uri = Uri.parse("android.resource://" + this.getPackageName().toString() + "/" + R.raw.alarm)
            val att: AudioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build()
            channel.setSound(uri, att)

            // Default channel
            val defaultChannel = NotificationChannel("default_channel", "Default", NotificationManager.IMPORTANCE_HIGH)
            val defaultSoundUri: Uri = Uri.parse("android.resource://" + this.getPackageName().toString() + "/" + R.raw.message)
            defaultChannel.setSound(defaultSoundUri, att)

            val notificationManager: NotificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.deleteNotificationChannel("my_channel_01") // Delete old one
            notificationManager.createNotificationChannel(channel)
            notificationManager.createNotificationChannel(defaultChannel)
        }
        MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                object : MethodChannel.MethodCallHandler {
                    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result): Unit {
                        val key: String = call.arguments.toString()
                        Toast.makeText(getApplicationContext(), key, Toast.LENGTH_SHORT).show()
                        getApplicationContext().startActivity(Intent(getApplicationContext(), PdfViewerActivity::class.java).putExtra("URL", key))
                    }
                })
    }

    companion object {
        private const val CHANNEL = "schoolvillage.app/pdf_view"
    }
}