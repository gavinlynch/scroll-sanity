//
//  PreferencesViewController.swift
//  scroll-sanity
//
//  Created by Gavin Lynch on 4/18/18.
//  Copyright © 2018 Gavin Lynch. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  @IBOutlet weak var label: NSTextFieldCell!
  @IBOutlet weak var slider: NSSlider!

  @IBAction func sliderChanged(_ sender: Any?) {
    appDelegate.setLinesPerScroll(Int(slider.intValue))
    label.stringValue = slider.stringValue
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    slider.intValue = Int32(appDelegate.linesPerScroll)
    label.stringValue = slider.stringValue
  }
}

/**
 * Create a fresh instance of the UI from storyboard, used each time popover is rendered.
 */
extension PreferencesViewController {
  static func freshController() -> PreferencesViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier(rawValue: "PreferencesViewController")

    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? PreferencesViewController else {
      fatalError("Unable to create view controller.")
    }

    return viewcontroller
  }
}

/**
 * Only allow users to enter numbers into input.
 */
class IntegerFormatter: NumberFormatter {
  override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    return partialString.count == 0 ? true : Int(partialString) != nil
  }
}
