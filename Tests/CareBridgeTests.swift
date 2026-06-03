// CareBridgeTests.swift
// NurseryConnect — Setting Manager (macOS)
// Automated Unit Tests covering Edge Cases and Validation

import XCTest
@testable import CareBridge_macOS

final class CareBridgeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSentimentAnalysisEmptyStringEdgeCase() throws {
        let nlService = NLAnalysisService.shared
        let result = nlService.analyzeSentimentResult(text: "")
        
        // Edge Case: Empty strings should not crash and should return a neutral score (0.0 raw -> 50.0 normalized)
        XCTAssertEqual(result.rawSentimentScore, 0.0, "Empty string raw score should be 0.0")
        XCTAssertEqual(result.normalizedScore, 50.0, "Empty string normalized score should be 50.0")
    }
    
    func testWellbeingScoreDivideByZeroProtection() throws {
        let nlService = NLAnalysisService.shared
        let score = nlService.computeWellbeingScore(entries: [])
        
        // Edge Case: Empty array of entries should not cause a divide by zero (NaN).
        // It should return the default neutral score of 50.0
        XCTAssertEqual(score, 50.0, "Empty array should return a default score of 50.0, avoiding NaN.")
    }

    func testAppErrorValidation() throws {
        let error = AppError.validationError(message: "Missing Name")
        XCTAssertEqual(error.localizedDescription, "Validation Error: Missing Name", "AppError should map descriptions correctly.")
    }
}
