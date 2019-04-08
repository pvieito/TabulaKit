#  TabulaKit

Swift framework to extract tables from PDFs, wrapping Java [`tabula`](https://github.com/tabulapdf/tabula-java).

## Requirements

`TabulaKit` requires [**Swift 5**](https://swift.org/download/) and **Java**. It has been tested on macOS, Linux and Windows.

## Usage

You can extract tables from a PDF document using a `TabulaPDF` instance:

```swift
import TabulaKit

let inputURL = URL(fileURLWithPath: "Invoice.pdf")
let inputPDF = try TabulaPDF(contentsOf: inputURL)
let extractedTables = try inputPDF.extractTables()
print(extractedTables.count) // 1
print(extractedTables[0]) // [["Service", "Cost"], ["mobilR", "13.95€"]]
```

### Swift Package Manager

Add the following dependency to your `Package.swift` manifest:

```swift
.package(url: "https://github.com/pvieito/TabulaKit.git", .branch("master")),
```

## Notes

`TabulaKit` is heavily inspired by [`tabula-py`](https://github.com/chezou/tabula-py), a Python wrapper of `tabula-java`.
