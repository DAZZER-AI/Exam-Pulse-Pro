# PR Ready Checklist

This repository has been checked for merge conflict markers and validated for PR readiness.

## Conflict check

- No unresolved git conflict markers were found (`<<<<<<<`, `=======`, `>>>>>>>`).

## Validation checks

- `node --check web/app.js` ✅
- SVG preview assets parse check using Python `xml.etree.ElementTree` ✅
- `swiftc -typecheck ios/ExamPulsePro/Models/Exam.swift` ✅
- Full iOS SwiftUI typecheck in Linux container ⚠️ (expected to fail due to unavailable Apple `SwiftUI` module outside Xcode/macOS)

## Notes

- Web app is ready for static hosting/local execution.
- iOS app should be built and verified in Xcode on macOS for end-to-end compile/runtime validation.
