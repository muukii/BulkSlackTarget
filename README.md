# BulkSlackTarget

## Usage

```swift
AsyncPipeline(
  plugins: [],
  bulkConfiguration: Pipeline.BulkConfiguration.init(buffer: MemoryBuffer(size: 10), timeout: .seconds(10)),
  targetConfiguration: Pipeline.TargetConfiguration.init(
    formatter: RawFormatter(),
    target: SlackTarget.init(
      incomingWebhookURLString: config.slack.logIncomingWebhookURL,
      username: "RoomKeeper"
    )
  ),
  queue: DispatchQueue.global(qos: .utility)
)
```
