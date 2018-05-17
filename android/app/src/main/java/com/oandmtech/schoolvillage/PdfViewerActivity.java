package com.oandmtech.schoolvillage;

import android.app.Activity;
import android.content.res.AssetManager;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;

import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.util.FitPolicy;

import java.io.File;
import java.io.IOException;

public class PdfViewerActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pdf_viewer);
        PDFView pdfView = (PDFView) findViewById(R.id.pdfView);

        pdfView.fromFile(new File(getIntent().getStringExtra("URL")))
                .pageFitPolicy(FitPolicy.WIDTH)
                .spacing(12)
                .load();

//        try {
//            pdfView.fromStream( getAssets().openFd(getIntent().getStringExtra("URL")).createInputStream())
//                    .pageFitPolicy(FitPolicy.WIDTH)
//                    .spacing(12)
//                    .load();
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
    }
}
