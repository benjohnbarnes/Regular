import XCTest

import RegularTests

var tests = [XCTestCaseEntry]()
tests += RegularTests.allTests()
XCTMain(tests)
