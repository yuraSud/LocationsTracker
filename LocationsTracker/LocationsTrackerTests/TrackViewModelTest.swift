//
//  TrackViewModelTest.swift
//  LocationsTrackerTests
//
//  Created by Yura Sabadin on 27.02.2024.
//
@testable import LocationsTracker
import Combine
import XCTest

final class TrackViewModelTest: XCTestCase {
    
    var sut: TrackViewModel!
    let authMngr = AuthorizedManager.shared
    
    override func setUp() async throws {
        authMngr.logOut()
        try await authMngr.logIn(email: "andrey@iphone.com", pasword: "123456")
        try await super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
    
    func testFetchTracks() {
        let expectation = expectation(description: "wait load userInfo")
        
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            self.sut = TrackViewModel(self.authMngr)
            
            XCTAssertNotNil(self.sut.userProfile)
            XCTAssert(self.sut.tracksData.isEmpty)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                print(self.sut.tracksData)
                XCTAssertFalse(self.sut.tracksData.isEmpty)
                
                XCTAssertTrue(self.sut.numberOfSections() != 0)
                XCTAssertFalse(self.sut.numberOfItems(in: 0) == 0)
                XCTAssertNotNil(self.sut.titleForHeader(in: 0))
                
                self.sut.filterDate = .now
                
                XCTAssertTrue(self.sut.tracksData.isEmpty)
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }

}
