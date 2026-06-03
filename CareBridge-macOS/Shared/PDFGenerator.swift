// PDFGenerator.swift
// NurseryConnect — Setting Manager
// PDFKit & AppKit utility to generate paginated PDFs from HTML or text

import SwiftUI
import AppKit
import PDFKit

@MainActor
class PDFGenerator {
    
    /// Generates a paginated PDF document from an HTML string and returns the PDF data.
    static func generatePDF(from html: String) -> Data? {
        let paperSize = NSSize(width: 595.2, height: 841.8) // A4
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: paperSize.width, height: paperSize.height))
        
        // Convert HTML to NSAttributedString
        guard let data = html.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            let attrString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            textView.textStorage?.setAttributedString(attrString)
        } catch {
            print("HTML to PDF conversion failed: \(error)")
            return nil
        }
        
        textView.backgroundColor = .white
        
        let printInfo = NSPrintInfo.shared
        printInfo.paperSize = paperSize
        printInfo.topMargin = 50
        printInfo.bottomMargin = 50
        printInfo.leftMargin = 50
        printInfo.rightMargin = 50
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".pdf")
        
        let printDict = NSMutableDictionary(dictionary: printInfo.dictionary())
        printDict[NSPrintInfo.AttributeKey.jobDisposition] = NSPrintInfo.JobDisposition.save
        printDict[NSPrintInfo.AttributeKey.jobSavingURL] = tempURL
        
        let customPrintInfo = NSPrintInfo(dictionary: printDict as! [NSPrintInfo.AttributeKey: Any])
        
        let printOp = NSPrintOperation(view: textView, printInfo: customPrintInfo)
        printOp.showsPrintPanel = false
        printOp.showsProgressPanel = false
        
        printOp.run()
        
        if let pdfDocument = PDFDocument(url: tempURL) {
            let data = pdfDocument.dataRepresentation()
            try? FileManager.default.removeItem(at: tempURL)
            return data
        }
        
        return nil
    }
    
    /// Shows a macOS save panel to allow the user to save the PDF.
    static func savePDF(from html: String, defaultFileName: String) {
        guard let pdfData = generatePDF(from: html) else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.pdf]
        savePanel.nameFieldStringValue = defaultFileName
        savePanel.title = "Save Report as PDF"
        savePanel.prompt = "Save"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try pdfData.write(to: url)
                    HapticManager.notification(.success)
                } catch {
                    print("Error saving PDF: \(error.localizedDescription)")
                }
            }
        }
    }
}
