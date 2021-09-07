package com.oandmtech.schoolvillage;

import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;

import android.widget.Toast;

import java.io.IOException;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;


import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "schoolvillage.app/pdf_view";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            String key = call.arguments.toString();
//                  String key = getFlutterView().getLookupKeyForAsset(call.arguments.toString());
                            Toast.makeText(getApplicationContext(), key, Toast.LENGTH_SHORT).show();
                            getApplicationContext().startActivity(new Intent(getApplicationContext(), PdfViewerActivity.class).putExtra("URL", key));
                        }
                );
    }


}
