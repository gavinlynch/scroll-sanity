//
//  ScrollMonitor.swift
//  scroll-sanity
//
//  Created by Gavin Lynch on 4/20/18.
//  Copyright © 2018 Gavin Lynch. All rights reserved.
//

import Cocoa

/**
 * Provides scroll wheel interception/manipulation via event taps.
 */
extension AppDelegate {
  /**
   * Global scroll event observer.
   */
  func watchScroll() {
    let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())
    let mask = 1 << CGEventType.scrollWheel.rawValue

    guard let eventTap = CGEvent.tapCreate(
      tap: .cgSessionEventTap,
      place: .headInsertEventTap,
      options: .defaultTap,
      eventsOfInterest: CGEventMask(mask),
      callback: {(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
        if let observer = refcon {
          let mySelf = Unmanaged<AppDelegate>.fromOpaque(observer).takeUnretainedValue()
          return mySelf.onScroll(proxy: proxy, type: type, event: event)
        }
        return Unmanaged.passUnretained(event)
    },
      userInfo: observer) else {
        print("Failed to create event tap, check CGEVent or App Entitlements (Sandbox).")
        return
    }

    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    CFRunLoopRun()
  }

  /**
   * Scroll event handler, intercepting and modifying wheel delta value when the user
   * is in a wheel scroll versus a trackpad scroll (continuous scroll event).
   */
  func onScroll(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
    if self.isEnabled && event.getIntegerValueField(.scrollWheelEventIsContinuous) == 0 {
      var delta: Int64 = event.getIntegerValueField(.scrollWheelEventPointDeltaAxis1)
      delta = delta > 0 ? min(delta, 1) : max(delta, -1)
      event.setIntegerValueField(.scrollWheelEventDeltaAxis1, value: delta * Int64(self.linesPerScroll))
    }

    return Unmanaged.passRetained(event)
  }
}
