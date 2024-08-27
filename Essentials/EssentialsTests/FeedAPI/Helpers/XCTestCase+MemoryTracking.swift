//
//  XCTestCase+MemoryTracking.swift
//  EssentialsTests
//
//  Created by Vishnu on 27/08/24.
//

import XCTest

extension XCTestCase {
    func trackMemeoryLeaks(_ instance: AnyObject, file: StaticString = #filePath,
                                   line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "instance should be deallocated. Potential memory leak", file: file, line: line)
        }
    }
}
