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

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "schoolvillage.app/pdf_view";


  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

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
