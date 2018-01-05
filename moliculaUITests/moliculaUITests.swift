//
//  moliculaUITests.swift
//  moliculaUITests
//
//  Created by Eric Wolter on 19.12.17.
//  Copyright © 2017 Eric Wolter. All rights reserved.
//

import XCTest

class moliculaUITests: XCTestCase {
        
  override func setUp() {
    super.setUp()
  
    // Put setup code here. This method is called before the invocation of each test method in the class.
  
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    let app = XCUIApplication()
    setupSnapshot(app)
    XCUIApplication().launch()

    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func flip(controls:XCUIElement) {
    let start = controls.coordinate(withNormalizedOffset: CGVector(dx:0.1, dy:-0.01))
    let finish = controls.coordinate(withNormalizedOffset: CGVector(dx:0.9, dy:-0.01))
    start.press(forDuration: 0, thenDragTo: finish)
  }
  
  func rotateCounterClockwise(controls:XCUIElement) {
    let start = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.2))
    let finish = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.8))
    start.press(forDuration: 0, thenDragTo: finish)
  }
  
  func rotateClockwise(controls:XCUIElement) {
    let finish = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.2))
    let start = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.8))
    start.press(forDuration: 0, thenDragTo: finish)
  }
  
  func getHolesCenterPoint(query: XCUIElementQuery, holeIdentifers: [String]) -> XCUICoordinate {
    
    var center = CGPoint.zero
    for holeIdentifier in holeIdentifers {
      let holeElement = query.matching(identifier: holeIdentifier).element
      let coordinate = holeElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
      center = CGPoint(x: center.x + coordinate.screenPoint.x, y: center.y + coordinate.screenPoint.y)
    }
    center = CGPoint(x: center.x / CGFloat(holeIdentifers.count), y: center.y / CGFloat(holeIdentifers.count))
    
    let holeElement = query.matching(identifier: holeIdentifers[0]).element
    let coordinate = holeElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    
    let offsetVector = CGVector(dx: center.x - coordinate.screenPoint.x, dy: center.y - coordinate.screenPoint.y)
    let centerCoordinate = coordinate.withOffset(offsetVector)
    return centerCoordinate
  }
  
  func move(element: XCUIElement, target: XCUICoordinate) {
    let start = element.coordinate(withNormalizedOffset: CGVector(dx:0.5, dy:0.5))
    start.press(forDuration: 0, thenDragTo: target)
  }
  
  func testScreenSelected() {
    let app = XCUIApplication()
    let gameView = app.otherElements.matching(identifier: "GameView").firstMatch
    let whiteMolecule = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "w").element
    whiteMolecule.tap()
    snapshot("01Selected")
  }
  
  func testScreenSolution() {
    let app = XCUIApplication()
    let gameView = app.otherElements.matching(identifier: "GameView").element
    let gameQuery = gameView.children(matching: XCUIElement.ElementType.other)
    
    let controls = gameQuery.matching(identifier: "controls").element
    let holeElement = gameQuery.matching(identifier: "0;2").element
    
    let blueMolecule = gameQuery.matching(identifier: "b").element
    let purpleMolecule = gameQuery.matching(identifier: "p").element
    let redMolecule = gameQuery.matching(identifier: "r").element
    let orangeMolecule = gameQuery.matching(identifier: "o").element
    let whiteMolecule = gameQuery.matching(identifier: "w").element
//    let yellowMolecule = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "y").element
    let greenMolecule = gameQuery.matching(identifier: "g").element

    let blueTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["1;1", "2;0", "3;-1", "4;-1", "5;-1"])
    let purpleTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["0;4", "1;3", "1;4", "2;3", "2;4"])
    let redTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["0;2", "0;3", "1;2", "2;1", "3;0"])
    let orangeTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["2;2", "3;2", "3;3", "3;4", "4;3"])
    let whiteTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["4;2", "5;1", "5;2", "6;0", "6;1"])
//    let yellowTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["4;2", "5;1", "5;2", "6;0", "6;1"])
    let greenTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["3;1", "4;0", "4;1", "5;0", "6;-1"])
    
    blueMolecule.tap()
    move(element: blueMolecule, target: blueTarget)

    redMolecule.tap()
    rotateClockwise(controls: controls)
    rotateClockwise(controls: controls)
    rotateClockwise(controls: controls)
    move(element: redMolecule, target: redTarget)

    greenMolecule.tap()
    flip(controls: controls)
    rotateClockwise(controls: controls)
    rotateClockwise(controls: controls)
    move(element: greenMolecule, target: greenTarget)
    
    whiteMolecule.tap()
    rotateCounterClockwise(controls: controls)
    rotateCounterClockwise(controls: controls)
    rotateCounterClockwise(controls: controls)
    move(element: whiteMolecule, target: whiteTarget)

    purpleMolecule.tap()
    rotateClockwise(controls: controls)
    move(element: purpleMolecule, target: purpleTarget)

    orangeMolecule.tap()
    flip(controls: controls)
    rotateClockwise(controls: controls)
    move(element: orangeMolecule, target: orangeTarget.withOffset(CGVector(dx: holeElement.frame.width * 0.5, dy: -holeElement.frame.width * 0.5)))

    snapshot("02Solution")
  }
  
  func testScreenLibrary() {
    let app = XCUIApplication()
    
    let gameView = app.otherElements.matching(identifier: "GameView").element
    let gameQuery = gameView.children(matching: XCUIElement.ElementType.other)
    
    let controls = gameQuery.matching(identifier: "controls").element
    
    let blueMolecule = gameQuery.matching(identifier: "b").element
    let purpleMolecule = gameQuery.matching(identifier: "p").element
    let redMolecule = gameQuery.matching(identifier: "r").element
    let orangeMolecule = gameQuery.matching(identifier: "o").element
    let whiteMolecule = gameQuery.matching(identifier: "w").element
    //    let yellowMolecule = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "y").element
    let greenMolecule = gameQuery.matching(identifier: "g").element
    
    let blueTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["1;1", "2;0", "3;-1", "4;-1", "5;-1"])
    let purpleTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["0;4", "1;3", "1;4", "2;3", "2;4"])
    let redTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["0;2", "0;3", "1;2", "2;1", "3;0"])
    let orangeTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["2;2", "3;2", "3;3", "3;4", "4;3"])
    let whiteTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["4;2", "5;1", "5;2", "6;0", "6;1"])
    //    let yellowTarget = getHolesCenterPoint(game: gameQuery, holeIdentifers: ["4;2", "5;1", "5;2", "6;0", "6;1"])
    let greenTarget = getHolesCenterPoint(query: gameQuery, holeIdentifers: ["3;1", "4;0", "4;1", "5;0", "6;-1"])
    
    blueMolecule.tap()
    move(element: blueMolecule, target: blueTarget)
    
    redMolecule.tap()
    rotateClockwise(controls: controls)
    rotateClockwise(controls: controls)
    rotateClockwise(controls: controls)
    move(element: redMolecule, target: redTarget)
    
    greenMolecule.tap()
    flip(controls: controls)
    rotateClockwise(controls: controls)
    rotateClockwise(controls: controls)
    move(element: greenMolecule, target: greenTarget)
    
    whiteMolecule.tap()
    rotateCounterClockwise(controls: controls)
    rotateCounterClockwise(controls: controls)
    rotateCounterClockwise(controls: controls)
    move(element: whiteMolecule, target: whiteTarget)
    
    purpleMolecule.tap()
    rotateClockwise(controls: controls)
    move(element: purpleMolecule, target: purpleTarget)
    
    orangeMolecule.tap()
    flip(controls: controls)
    rotateClockwise(controls: controls)
    move(element: orangeMolecule, target: orangeTarget)

    app.navigationBars["GameView"].children(matching: .button).element.tap()
    snapshot("03Library")
  }
}
