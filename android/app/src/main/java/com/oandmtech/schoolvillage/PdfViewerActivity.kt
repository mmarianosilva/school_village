package com.oandmtech.schoolvillage

import com.github.barteksc.pdfviewer.PDFView
import com.github.barteksc.pdfviewer.util.FitPolicy
import android.app.Activity
import android.os.Bundle

class PdfViewerActivity : Activity() {

    protected override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_pdf_viewer)
        val pdfView: PDFView = findViewById(R.id.pdfView)
        pdfView.fromFile(java.io.File(getIntent().getStringExtra("URL")))
                .pageFitPolicy(FitPolicy.WIDTH)
                .spacing(12)
                .load()
    }

}