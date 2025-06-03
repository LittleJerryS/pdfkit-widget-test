#!/usr/bin/env swift
import Cocoa          // brings in Foundation, AppKit, PDFKit
import PDFKit
import CoreGraphics

// 1) Create a new PDFDocument
let pdf = PDFDocument()
guard let page = PDFPage() else {
    fatalError("❌ Could not create a new PDFPage")
}
pdf.insert(page, at: 0)

// Helper to add a widget annotation to the page:
func addWidget(_ annotation: PDFAnnotation) {
    page.addAnnotation(annotation)
}

// === 1) TEXT FIELD ===
let tfRect = CGRect(x: 50, y: 700, width: 300, height: 24)
let textField = PDFAnnotation(bounds: tfRect, forType: .widget, withProperties: nil)
textField.widgetFieldType = .text
textField.fieldName = "TextField1"
textField.widgetStringValue = "Sample text"
addWidget(textField)

// === 2) CHECKBOX ===
let cbRect = CGRect(x: 50, y: 650, width: 20, height: 20)
let checkBox = PDFAnnotation(bounds: cbRect, forType: .widget, withProperties: nil)
checkBox.widgetFieldType = .button
checkBox.widgetControlType = .checkBox
checkBox.fieldName = "CheckBox1"
checkBox.buttonWidgetState = .off
addWidget(checkBox)

// === 3) RADIO BUTTON GROUP ===
let rbRect1 = CGRect(x: 50, y: 600, width: 20, height: 20)
let radio1 = PDFAnnotation(bounds: rbRect1, forType: .widget, withProperties: nil)
radio1.widgetFieldType = .button
radio1.widgetControlType = .radioButton
radio1.fieldName = "RadioGroup1"
radio1.buttonWidgetState = .off
addWidget(radio1)

let rbRect2 = CGRect(x: 100, y: 600, width: 20, height: 20)
let radio2 = PDFAnnotation(bounds: rbRect2, forType: .widget, withProperties: nil)
radio2.widgetFieldType = .button
radio2.widgetControlType = .radioButton
radio2.fieldName = "RadioGroup1"
radio2.buttonWidgetState = .off
addWidget(radio2)

// === 4) CHOICE LIST (COMBO BOX) ===
let choiceRect = CGRect(x: 50, y: 550, width: 200, height: 24)
let choice = PDFAnnotation(bounds: choiceRect, forType: .widget, withProperties: nil)
choice.widgetFieldType = .choice
choice.fieldName = "ChoiceField1"
choice.widgetOptions = ["Option A", "Option B", "Option C"]
choice.widgetStringValue = "Option A"
addWidget(choice)

// === 5) SIGNATURE FIELD ===
let sigRect = CGRect(x: 50, y: 480, width: 300, height: 100)
let signatureField = PDFAnnotation(bounds: sigRect, forType: .widget, withProperties: nil)
signatureField.widgetFieldType = .signature
signatureField.fieldName = "SignatureField1"
addWidget(signatureField)

// (Optional) LABELS FOR CLARITY
func addLabel(text: String, at origin: CGPoint) {
    let labelBounds = CGRect(x: origin.x, y: origin.y, width: 200, height: 16)
    let label = PDFAnnotation(bounds: labelBounds,
                              forType: .freeText,
                              withProperties: [
                                  .font: NSFont.systemFont(ofSize: 12),
                                  .foregroundColor: NSColor.black,
                                  .contents: text
                              ])
    page.addAnnotation(label)
}
addLabel(text: "Text Field:",       at: CGPoint(x: 50,  y: 726))
addLabel(text: "Checkbox:",         at: CGPoint(x: 50,  y: 676))
addLabel(text: "Radio Buttons:",    at: CGPoint(x: 50,  y: 626))
addLabel(text: "(two circles)",     at: CGPoint(x: 150, y: 626))
addLabel(text: "Choice List:",      at: CGPoint(x: 50,  y: 576))
addLabel(text: "Signature Field:",  at: CGPoint(x: 50,  y: 588))

// 6) Write out the PDF to disk
let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                  .appendingPathComponent("WidgetTest.pdf")
if pdf.write(to: outputURL) {
    print("✔️  Saved PDF to \(outputURL.path)")
} else {
    print("❌  Failed to write WidgetTest.pdf")
}
