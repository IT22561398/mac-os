// PDFPreviewView.swift
// NurseryConnect — Setting Manager
// NSViewRepresentable wrapper for PDFKit's PDFView to display PDFs in SwiftUI

import SwiftUI
import PDFKit

struct PDFPreviewView: NSViewRepresentable {
    let pdfData: Data
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.pageShadowsEnabled = true
        pdfView.backgroundColor = NSColor.windowBackgroundColor
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {
        if let document = PDFDocument(data: pdfData) {
            nsView.document = document
        }
    }
}
