//
//  ClickMonitor.swift
//  scroll-sanity
//
//  Created by Gavin Lynch on 4/20/18.
//  Copyright © 2018 Gavin Lynch. All rights reserved.
//

import Cocoa

/**
 * Provides simple interface for attaching click events.
 */
public class ClickMonitor {
  private var monitor: Any?
  private let mask: NSEvent.EventTypeMask = [.leftMouseDown, .rightMouseDown]
  private let handler: (NSEvent?) -> Void

  public init(handler: @escaping (NSEvent?) -> Void) {
    self.handler = handler
  }

  deinit {
    self.stop();
  }

  public func start() {
    monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
  }

  public func stop() {
    if monitor != nil {
      NSEvent.removeMonitor(monitor!)
      monitor = nil
    }
  }
}
