#!/usr/bin/env swift

import Cocoa    // Brings in Foundation, AppKit, PDFKit
import PDFKit
import CoreGraphics

// 1) Create a new PDFDocument and a single PDFPage
let pdf = PDFDocument()
let page = PDFPage()
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
textField.widgetStringValue = ""       // empty default
addWidget(textField)

// === 2) CHECKBOX ===
// In recent PDFKit, control type “CheckBox” is specified via rawValue:
let cbRect = CGRect(x: 50, y: 650, width: 20, height: 20)
let checkBox = PDFAnnotation(bounds: cbRect, forType: .widget, withProperties: nil)
checkBox.widgetFieldType = .button
if let cbType = PDFAnnotationWidgetControlType(rawValue: "CheckBox") {
    checkBox.widgetControlType = cbType
}
checkBox.fieldName = "CheckBox1"
if let offState = PDFAnnotationWidgetCellState(rawValue: 0) {
    checkBox.buttonWidgetState = offState
}
addWidget(checkBox)

// === 3) RADIO BUTTON GROUP ===
let rbRect1 = CGRect(x: 50, y: 600, width: 20, height: 20)
let radio1 = PDFAnnotation(bounds: rbRect1, forType: .widget, withProperties: nil)
radio1.widgetFieldType = .button
if let rbType = PDFAnnotationWidgetControlType(rawValue: "RadioButton") {
    radio1.widgetControlType = rbType
}
radio1.fieldName = "RadioGroup1"
if let offState2 = PDFAnnotationWidgetCellState(rawValue: 0) {
    radio1.buttonWidgetState = offState2
}
addWidget(radio1)

let rbRect2 = CGRect(x: 100, y: 600, width: 20, height: 20)
let radio2 = PDFAnnotation(bounds: rbRect2, forType: .widget, withProperties: nil)
radio2.widgetFieldType = .button
if let rbType2 = PDFAnnotationWidgetControlType(rawValue: "RadioButton") {
    radio2.widgetControlType = rbType2
}
radio2.fieldName = "RadioGroup1"
if let offState3 = PDFAnnotationWidgetCellState(rawValue: 0) {
    radio2.buttonWidgetState = offState3
}
addWidget(radio2)

// === 4) CHOICE LIST (COMBO BOX) ===
let choiceRect = CGRect(x: 50, y: 550, width: 200, height: 24)
let choice = PDFAnnotation(bounds: choiceRect, forType: .widget, withProperties: nil)
choice.widgetFieldType = .choice
choice.fieldName = "ChoiceField1"
// PDFKit expects options array under widget dictionary's "Opt" key:
choice.widgetDictionary![PDFAnnotationKey.widgetOptions] = ["Option A", "Option B", "Option C"]
choice.widgetStringValue = "Option A"
addWidget(choice)

// === 5) SIGNATURE FIELD ===
let sigRect = CGRect(x: 50, y: 480, width: 300, height: 100)
let signatureField = PDFAnnotation(bounds: sigRect, forType: .widget, withProperties: nil)
signatureField.widgetFieldType = .signature
signatureField.fieldName = "SignatureField1"
addWidget(signatureField)


// (Optional) ADD SIMPLE FREE-TEXT LABELS ABOVE EACH FIELD
func addLabel(_ text: String, at origin: CGPoint) {
    let labelRect = CGRect(x: origin.x, y: origin.y, width: 200, height: 16)
    let label = PDFAnnotation(bounds: labelRect,
                              forType: .freeText,
                              withProperties: nil)
    label.font = NSFont.systemFont(ofSize: 12)
    label.color = .black
    label.contents = text
    page.addAnnotation(label)
}
addLabel("Text Field:",       at: CGPoint(x: 50,  y: 726))
addLabel("Checkbox:",         at: CGPoint(x: 50,  y: 676))
addLabel("Radio Buttons:",    at: CGPoint(x: 50,  y: 626))
addLabel("(two circles)",     at: CGPoint(x: 150, y: 626))
addLabel("Choice List:",      at: CGPoint(x: 50,  y: 576))
addLabel("Signature Field:",  at: CGPoint(x: 50,  y: 588))


// 6) Write out to disk as “WidgetTest.pdf”
let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                  .appendingPathComponent("WidgetTest.pdf")
if pdf.write(to: outputURL) {
    print("✔️  Saved PDF to \(outputURL.path)")
} else {
    print("❌  Failed to write WidgetTest.pdf")
}
