package com.oandmtech.schoolvillage;

import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.os.Bundle;
import android.widget.Toast;

import java.io.IOException;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "schoolvillage.app/pdf_view";


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    AppCenter.start(getApplication(), "c5b4ce38-f8e5-458b-8f10-8328d37d76a3",
              Analytics.class, Crashes.class);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                // TODO
                  String key = call.arguments.toString();
//                  String key = getFlutterView().getLookupKeyForAsset(call.arguments.toString());
                  Toast.makeText(getApplicationContext(),key, Toast.LENGTH_SHORT).show();
                  getApplicationContext().startActivity(new Intent(getApplicationContext(), PdfViewerActivity.class).putExtra("URL", key));

              }
            });
  }
}
