//
//  LocationsTrackerTests.swift
//  LocationsTrackerTests
//
//  Created by Yura Sabadin on 15.02.2024.
//
import CoreLocation
import XCTest
@testable import LocationsTracker
import Combine

final class LocationsTrackerTests: XCTestCase {
    
    var sut: UserViewModel!
    
    override func setUp() {
        super.setUp()
        sut = UserViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testStartRecording()  {
        let isRecording = sut.isRecording
        let uidTrack = sut.uidUserTrack
        
        XCTAssertEqual(isRecording, false)
        
        XCTAssert(uidTrack.isEmpty, "Now uidTrack must be empty. ")
        
        sut.startRecording()
        
        XCTAssertEqual(sut.isRecording, true)
        XCTAssertFalse(sut.uidUserTrack.isEmpty, "Now, uidTrack must be not emty")
        let countCoordinates = sut.trackCoordinates.count
        XCTAssertEqual(0, countCoordinates)
        
        let expectation = XCTestExpectation(description: "Recording completed")
        
        let startCoordinates = CLLocation(latitude: 50.336364746, longitude: 26.648949742)
        let secondCoordinates = CLLocation(latitude: 50.336222088, longitude: 26.649082658)
        let thirdCoordinates = CLLocation(latitude: 50.335666087, longitude: 26.649627403)
        let fourCoordinates = CLLocation(latitude: 50.3350949377, longitude: 26.64924050318)
        let fiveCoordinates = CLLocation(latitude: 50.3350977509, longitude: 26.64908923444)
        let sixCoordinates = CLLocation(latitude: 50.33509738231, longitude: 26.64894456703)
        let sevenCoordinates = CLLocation(latitude: 50.33523883157, longitude: 26.64757758034)
        let eightCoordinates = CLLocation(latitude: 50.33514985387, longitude: 26.64760631285)
        let nineCoordinates = CLLocation(latitude: 50.3350571589, longitude: 26.6475724186)
        
        sut.trackCoordinates.append(startCoordinates)
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.sut.currentCoordinates = secondCoordinates
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.sut.currentCoordinates = thirdCoordinates
                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                    self.sut.currentCoordinates = fourCoordinates
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        XCTAssertEqual(4, self.sut.trackCoordinates.count)
                        XCTAssertFalse(self.sut.trackCoordinates.count < 4)
                        XCTAssert(self.sut.trackInfo.trackDistance > 0)
                        expectation.fulfill()
                    }
                }
            }
        }
        wait(for: [expectation], timeout: 25.0)
        
        sut.pauseRecTrack()
        XCTAssertFalse(sut.isRecording)
        
        let expectationTwo = XCTestExpectation(description: "add part two")
        sut.pauseRecTrack()
        XCTAssert(sut.isRecording)
        
        sut.currentCoordinates = fiveCoordinates
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.sut.currentCoordinates = sixCoordinates
            DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                self.sut.currentCoordinates = sevenCoordinates
                DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                    self.sut.currentCoordinates = eightCoordinates
                    DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                        self.sut.currentCoordinates = nineCoordinates
                        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
                            XCTAssertEqual(9, self.sut.trackCoordinates.count)
                            XCTAssertFalse(self.sut.trackCoordinates.count > 10)
                            expectationTwo.fulfill()
                        }
                    }
                }
            }
        }
        
        wait(for: [expectationTwo], timeout: 27.0)
        
        XCTAssertNil(sut.error)
        
        sut.stopRecording()
        
        XCTAssertFalse(sut.isRecording)
    }

}
