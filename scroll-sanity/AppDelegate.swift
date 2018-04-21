//
//  AppDelegate.swift
//  scroll-sanity
//
//  Created by Gavin Lynch on 4/18/18.
//  Copyright © 2018 Gavin Lynch. All rights reserved.
//

import Cocoa

let DEFAULT_LINES = 3

fileprivate struct Actions {
  static let toggle = #selector(AppDelegate.toggleEnabled(_:))
  static let change = #selector(AppDelegate.showPopover(_:))
  static let quit = #selector(NSApplication.terminate(_:))
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  var isEnabled = false
  var linesPerScroll:Int = DEFAULT_LINES
  var clickMonitor: ClickMonitor?

  let fileManager = FileManager.default
  let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  let popover = NSPopover()

  let itemToggle = NSMenuItem(title: "Enable", action: Actions.toggle, keyEquivalent: "")
  let itemChange = NSMenuItem(title: "Change Speed", action: Actions.change, keyEquivalent: "")
  let itemQuit = NSMenuItem(title: "Quit", action: Actions.quit, keyEquivalent: "")

  /**
   * Application startup.
   */
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // load preferences
    let preferences: NSDictionary = readPreferences()
    self.linesPerScroll = preferences["linesPerScroll"] as! Int
    self.isEnabled = preferences["isEnabled"] as! Bool

    // set up the UI
    self.renderMenuBarIcon()
    self.renderMenu()
    self.popover.appearance = NSAppearance(named: .vibrantLight)
    self.popover.contentViewController = PreferencesViewController.freshController()

    // set up scroll wheel interceptor and popover hide click events
    self.watchScroll()
    clickMonitor = ClickMonitor() { [weak self] event in
      if let weakSelf = self, weakSelf.popover.isShown {
        weakSelf.closePopover(event)
      }
    }
  }

  /**
   * Update lines per scroll and save preferences.
   */
  func setLinesPerScroll(_ lines: Int) {
    self.linesPerScroll = lines;
    self.writePreferences()
  }

  /**
   * Get and/or initialize stored preferences.
   * @return {NSDictionary} dictionary of user preferences.
   */
  func readPreferences() -> NSDictionary {
    let preferencesPath = self.documentDirectory.appending("/preferences.plist")
    if !self.fileManager.fileExists(atPath: preferencesPath) {
      return self.writePreferences();
    } else {
      return NSDictionary(contentsOfFile: preferencesPath)!
    }
  }

  /**
   * Write current settings to storage.
   * @return {NSDictionary} dictionary of user preferences.
   */
  @discardableResult
  func writePreferences() -> NSDictionary {
    let preferences:[String : Any] = [
      "isEnabled" : self.isEnabled,
      "linesPerScroll" : self.linesPerScroll
    ]
    let plistContent = NSDictionary(dictionary: preferences)
    let preferencesPath = self.documentDirectory.appending("/preferences.plist")
    plistContent.write(toFile: preferencesPath, atomically: true)
    return plistContent;
  }

  /**
   * Application teardown.
   */
  func applicationWillTerminate(_ aNotification: Notification) {}

  /**
   * Create and update menu bar icon based on enabled status.
   */
  func renderMenuBarIcon() {
    let iconName = "statusIcon-" + (self.isEnabled ? "enabled" : "disabled")
    let icon = NSImage(named: NSImage.Name(iconName))
    icon?.isTemplate = true
    self.statusItem.image = icon
  }

  /**
   * Create menu.
   */
  func renderMenu() {
    if (self.statusItem.menu == nil) {
      let menu = NSMenu()
      menu.addItem(itemToggle)
      menu.addItem(NSMenuItem.separator())
      menu.addItem(itemChange)
      menu.addItem(NSMenuItem.separator())
      menu.addItem(itemQuit)
      self.statusItem.menu = menu
    }

    self.itemToggle.title = self.isEnabled ? "Disable" : "Enable"
  }

  /**
   * Enable/Disable scroll event tap, save preferences, and update the UI to reflect all of it.
   */
  @objc func toggleEnabled(_ sender: Any?) {
    self.isEnabled = !self.isEnabled
    self.renderMenuBarIcon()
    self.renderMenu()
    self.writePreferences()
  }

  /**
   * Show the preferences popover panel.
   */
  @objc func showPopover(_ sender: Any?) {
    if let button = statusItem.button {
      clickMonitor?.start()
      self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
    }
  }

  /**
   * Hide the preferences popover panel.
   */
  @objc func closePopover(_ sender: Any?) {
    clickMonitor?.stop()
    self.popover.performClose(sender)
  }
}
