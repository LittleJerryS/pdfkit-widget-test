#!/usr/bin/env swift

import Cocoa      // Brings in Foundation, AppKit, PDFKit
import PDFKit

// -----------------------------------------------------
// This script produces a one-page PDF containing exactly:
//   1) A single‐line text field
//   2) A checkbox
//   3) Two radio buttons (same group)
//   4) A dropdown (combo) list
//   5) A signature field
//
// It does this by manually setting the AcroForm dictionary entries
// that older PDFKit versions expect, rather than using the newer
// widgetControlType / widgetCellState enums.
// -----------------------------------------------------

let pdf = PDFDocument()
let page = PDFPage()
pdf.insert(page, at: 0)

// Helper to add an annotation to the page
func addWidget(_ annotation: PDFAnnotation) {
    page.addAnnotation(annotation)
}

// Convenience: set a dictionary entry (key: PDFName, value: PDFObject)
func setDict(_ dict: PDFDictionary, key: String, value: PDFObject) {
    dict.setObject(value, forKey: PDFName(stringLiteral: key))
}

// 1) Single‐line text field (“TextField1”)
do {
    let tfRect = CGRect(x: 50, y: 700, width: 300, height: 24)
    // Create a “widget” annotation with no initial dictionary
    let textField = PDFAnnotation(bounds: tfRect, forType: .widget, withProperties: nil)
    
    // PDFKit automatically sets /Subtype /Widget. We need to add:
    //   /FT /Tx          (field type = Text)
    //   /T  (name)       (field name)
    //   /V  (value)      (initial contents, can be empty)
    //   /Ff <flags>      (if any; leave default = 0)
    if let dict = textField.dictionary {
        setDict(dict, key: "FT",  value: PDFName("Tx"))
        setDict(dict, key: "T",   value: PDFString("TextField1"))
        setDict(dict, key: "V",   value: PDFString(""))          // empty default
        // No special flags (Ff = 0) needed for a plain text field
    }
    addWidget(textField)
}

// 2) Checkbox (“CheckBox1”)
do {
    let cbRect = CGRect(x: 50, y: 650, width: 20, height: 20)
    let checkBox = PDFAnnotation(bounds: cbRect, forType: .widget, withProperties: nil)
    
    // We need to tell PDFKit / PDF dictionary:
    //   /FT /Btn            (field type = button)
    //   /T  (name)
    //   /V  /Off            (initial “Off” state)
    //   /Ff <value>         (bit 16 = checkbox)
    //   /AP (appearance dictionary) – we can omit a custom appearance and rely on default
    if let dict = checkBox.dictionary {
        setDict(dict, key: "FT", value: PDFName("Btn"))
        setDict(dict, key: "T",  value: PDFString("CheckBox1"))
        // “/Off” is the off‐value; most PDF viewers know how to render a default checkbox appearance
        setDict(dict, key: "V",  value: PDFName("Off"))
        // PDF spec: bit 16 (0x10000) = “checkbox” flag
        setDict(dict, key: "Ff", value: PDFNumber(1 << 16))
    }
    addWidget(checkBox)
}

// 3) Radio button group (“RadioGroup1” with two buttons)
do {
    // First radio button at (50, 600)
    let rbRect1 = CGRect(x: 50, y: 600, width: 20, height: 20)
    let radio1 = PDFAnnotation(bounds: rbRect1, forType: .widget, withProperties: nil)
    
    if let dict = radio1.dictionary {
        setDict(dict, key: "FT",  value: PDFName("Btn"))                     // field type = button
        setDict(dict, key: "T",   value: PDFString("RadioGroup1"))           // same name = same radio group
        setDict(dict, key: "V",   value: PDFName("Off"))                     // initial “Off”
        // PDF spec: bit 15 = radio button
        setDict(dict, key: "Ff",  value: PDFNumber(1 << 15))
        // PDF spec: “/Opt” provides the export values. The export value for “selected” can be “Yes” or similar.
        setDict(dict, key: "Opt", value: PDFArray([PDFString("Off"), PDFString("Yes")]))
    }
    addWidget(radio1)
    
    // Second radio button at (100, 600)
    let rbRect2 = CGRect(x: 100, y: 600, width: 20, height: 20)
    let radio2 = PDFAnnotation(bounds: rbRect2, forType: .widget, withProperties: nil)
    
    if let dict = radio2.dictionary {
        setDict(dict, key: "FT",  value: PDFName("Btn"))
        setDict(dict, key: "T",   value: PDFString("RadioGroup1"))
        setDict(dict, key: "V",   value: PDFName("Off"))
        setDict(dict, key: "Ff",  value: PDFNumber(1 << 15))
        setDict(dict, key: "Opt", value: PDFArray([PDFString("Off"), PDFString("Yes")]))
    }
    addWidget(radio2)
}

// 4) Choice list / Combo box (“ChoiceField1”)
do {
    let choiceRect = CGRect(x: 50, y: 550, width: 200, height: 24)
    let choice = PDFAnnotation(bounds: choiceRect, forType: .widget, withProperties: nil)
    
    if let dict = choice.dictionary {
        // Field type = choice
        setDict(dict, key: "FT", value: PDFName("Ch"))
        setDict(dict, key: "T",  value: PDFString("ChoiceField1"))
        // Provide the option array under “Opt”
        setDict(dict, key: "Opt", value: PDFArray([
            PDFString("Option A"),
            PDFString("Option B"),
            PDFString("Option C")
        ]))
        // Combo‐box vs list‐box: bit 17 = 1 means “combo” (drop‐down)
        setDict(dict, key: "Ff", value: PDFNumber(1 << 17))
        // Set initial value to “Option A”
        setDict(dict, key: "V", value: PDFString("Option A"))
    }
    addWidget(choice)
}

// 5) Signature field (“SignatureField1”)
do {
    let sigRect = CGRect(x: 50, y: 480, width: 300, height: 100)
    let signatureField = PDFAnnotation(bounds: sigRect, forType: .widget, withProperties: nil)
    
    if let dict = signatureField.dictionary {
        // Field type = signature
        setDict(dict, key: "FT", value: PDFName("Sig"))
        setDict(dict, key: "T",  value: PDFString("SignatureField1"))
        // No Ff flags needed for a signature (the default is fine)
    }
    addWidget(signatureField)
}

// (Optional) Add simple free‐text labels so we can visually identify each widget:
func addLabel(_ text: String, at origin: CGPoint) {
    let labelRect = CGRect(x: origin.x, y: origin.y, width: 200, height: 16)
    let label = PDFAnnotation(bounds: labelRect, forType: .freeText, withProperties: nil)
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

// Finally, write the PDF out to disk as “WidgetTest.pdf”
let outputURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                  .appendingPathComponent("WidgetTest.pdf")
if pdf.write(to: outputURL) {
    print("✔️  Saved PDF to \(outputURL.path)")
} else {
    print("❌  Failed to write WidgetTest.pdf")
}
