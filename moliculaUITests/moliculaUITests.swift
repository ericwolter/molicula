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
  
//  func testScreenMoleculeSelected() {
//    let app = XCUIApplication()
//    let gameView = app.otherElements.matching(identifier: "GameView").firstMatch
//    let whiteMolecule = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "w").element
//    whiteMolecule.tap()
//    snapshot("01MoleculeSelected")
//  }
  
  func flip(game:XCUIElement, controls:XCUIElement) {
    let controls = game.children(matching: XCUIElement.ElementType.other).matching(identifier: "controls").element
    let start = controls.coordinate(withNormalizedOffset: CGVector(dx:0.1, dy:-0.01))
    let finish = controls.coordinate(withNormalizedOffset: CGVector(dx:0.9, dy:-0.01))
    start.press(forDuration: 0, thenDragTo: finish)
  }
  
  func rotateCounterClockwise(game:XCUIElement, controls:XCUIElement) {
    let start = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.2))
    let finish = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.8))
    start.press(forDuration: 0, thenDragTo: finish)
  }
  
  func rotateClockwise(game:XCUIElement, controls:XCUIElement) {
    let finish = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.2))
    let start = controls.coordinate(withNormalizedOffset: CGVector(dx:-0.01, dy:0.8))
    start.press(forDuration: 0, thenDragTo: finish)
  }
  
  func testScreenMoleculeSelected() {
    let app = XCUIApplication()
    let gameView = app.otherElements.matching(identifier: "GameView").firstMatch
    let controls = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "controls").element

    let whiteMolecule = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "w").element
    let purpleMolecule = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "p").element
    let orangeMolecule = gameView.children(matching: XCUIElement.ElementType.other).matching(identifier: "o").element

    whiteMolecule.tap()
    rotateCounterClockwise(game: gameView, controls: controls)
    rotateCounterClockwise(game: gameView, controls: controls)
    rotateCounterClockwise(game: gameView, controls: controls)

    purpleMolecule.tap()
    rotateClockwise(game: gameView, controls: controls)
    
    orangeMolecule.tap()
    flip(game: gameView, controls: controls)
    rotateClockwise(game: gameView, controls: controls)
  }
  
//  func testScreenLibrary() {
//    let app = XCUIApplication()
//
//    let button = app.navigationBars["GameView"].children(matching: .button).element
//    button.tap()
//    snapshot("03Library")
//  }
}
