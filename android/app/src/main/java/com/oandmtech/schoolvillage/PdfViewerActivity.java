package com.oandmtech.schoolvillage;

import android.app.Activity;
import android.os.Bundle;

import com.github.barteksc.pdfviewer.PDFView;
import com.github.barteksc.pdfviewer.util.FitPolicy;

import java.io.File;

public class PdfViewerActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pdf_viewer);
        PDFView pdfView = findViewById(R.id.pdfView);

        pdfView.fromFile(new File(getIntent().getStringExtra("URL")))
                .pageFitPolicy(FitPolicy.WIDTH)
                .spacing(12)
                .load();
    }

}
