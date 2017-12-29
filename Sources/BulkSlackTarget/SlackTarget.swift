//
// SlackTarget.swift
//
// Copyright (c) 2017 muukii
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Bulk

public final class SlackTarget : Bulk.Target {

  public struct LevelColor {
    public var verbose: String = "#EEEEEE"
    public var debug: String = "#C1CAD6"
    public var info: String = "66C7F4"
    public var warn: String = "6C6EA0"
    public var error: String = "FF1053"
  }

  public typealias FormatType = Log

  public var levelColor: LevelColor = .init()

  private let incomingWebhookURLString: String
  private let username: String
  private let channelIdentifier: String?

  public init(
    incomingWebhookURLString: String,
    username: String,
    channelIdentifier: String? = nil
  ) {
    self.incomingWebhookURLString = incomingWebhookURLString
    self.username = username
    self.channelIdentifier = channelIdentifier
  }

  public func write(formatted items: [Bulk.Log], completion: @escaping () -> Void) {

    let attachments: [SlackMessage.Attachment] = items.map { log in

      var color: String {
        switch log.level {
        case .verbose: return levelColor.verbose
        case .debug: return levelColor.debug
        case .info: return levelColor.info
        case .warn: return levelColor.warn
        case .error: return levelColor.error
        }
      }

      var levelString: String {
        switch log.level {
        case .verbose: return "verbose"
        case .debug: return "debug"
        case .info: return "info"
        case .warn: return "warn"
        case .error: return "error"
        }
      }
      
      let name: String
      #if os(iOS)
        name = UIDevice.current.name
      #else
        name = Host.current().name ?? "Unknown"
      #endif

      return SlackMessage.Attachment(
        color: color,
        text: log.body,
        footer: "\(name) | \(log.file):\(log.line.description) \(log.function)",
        ts: log.date.timeIntervalSince1970,
        fields: [
        ])
    }

    let m = SlackMessage.init(
      channel: channelIdentifier,
      text: "",
      as_user: true,
      parse: "full",
      username: username,
      attachments: attachments
    )

    send(message: m) {
      completion()
    }
  }

  private func send(message: SlackMessage, completion: @escaping () -> Void) {

    SlackTarget.send(message: message, to: incomingWebhookURLString, completion: completion)
  }

  public static func send(message: SlackMessage, to urlString: String, completion: @escaping () -> Void) {

    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
    guard let url = URL(string: urlString) else {return}
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

    let encoder = JSONEncoder()
    let data = try! encoder.encode(message)
    request.httpBody = data

    let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in

      completion()

    })
    task.resume()
    session.finishTasksAndInvalidate()
  }
}

extension SlackTarget {

  public struct SlackMessage : Codable {

    public struct Attachment : Codable {

      public struct Field : Codable {
        public var title: String
        public var value: String
        public var short: Bool

        public init(
          title: String,
          value: String,
          short: Bool
          ) {
          self.title = title
          self.value = value
          self.short = short
        }
      }

      public var color: String
      public var pretext: String
      public var author_name: String
      public var author_icon: String
      public var title: String
      public var title_link: String
      public var text: String
      public var fields: [Field]
      public var image_url: String
      public var thumb_url: String
      public var footer: String
      public var footer_icon: String
      public var ts: Double?

      public init(
        color: String = "",
        pretext: String = "",
        authorName: String = "",
        authorIcon: String = "",
        title: String = "",
        titleLink: String = "",
        text: String,
        imageURL: String = "",
        thumbURL: String = "",
        footer: String = "",
        footerIcon: String = "",
        ts: Double? = nil,
        fields: [Field]
        ) {

        self.color = color
        self.pretext = pretext
        self.author_name = authorName
        self.author_icon = authorIcon
        self.title = title
        self.title_link = titleLink
        self.text = text
        self.image_url = imageURL
        self.thumb_url = thumbURL
        self.footer = footer
        self.footer_icon = footerIcon
        self.fields = fields
        self.ts = ts
      }
    }

    public var channel: String?
    public var text: String?
    public var as_user: Bool
    public var parse: String
    public var username: String
    public var attachments: [Attachment]?
  }
}
