//
//  StreamsTests.swift
//
//
//  Created by Grady Zhuo on 2023/10/28.
//

import Foundation
@testable import KurrentDB
import Testing

package enum TestingError: Error {
    case exception(String)
}

@Suite("EventStoreDB Stream Tests", .serialized)
struct StreamTests: Sendable {
    let settings: ClientSettings

    init() {
        settings = .localhost()
    }

    @Test("Stream should be not found and throw an error.")
    func testStreamNoFound() async throws {
        let client = KurrentDBClient(settings: .localhost())
        
        await #expect(throws: KurrentError.self) {
            let responses = try await client
                .streams(of: .specified(UUID().uuidString))
                .read(from: .start)
            var responsesIterator = responses.makeAsyncIterator()
           _ = try await responsesIterator.next()
        }
    }

    @Test("It should be succeed when append event to stream.", arguments: [
        [
            EventData(eventType: "AppendEvent-AccountCreated", payload: ["Description": "Gears of War 4"]),
            EventData(eventType: "AppendEvent-AccountDeleted", payload: ["Description": "Gears of War 4"]),
        ],
    ])
    func testAppendEvent(events: [EventData]) async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let client = KurrentDBClient(settings: .localhost())        
        let streams = client.streams(of: .specified(streamIdentifier))
        let appendResponse = try await streams.append(events: events, options: .init().revision(expected: .any))
        
        let appendedRevision = try #require(appendResponse.currentRevision)
        let readResponses = try await streams.read(from: .revision(appendedRevision), options: .init().forward())
        
        let firstResponse = try await readResponses.first { _ in true }
        guard case let .event(readEvent) = firstResponse,
              let readPosition = readEvent.commitPosition,
              let position = appendResponse.position
        else {
            throw TestingError.exception("readResponse.content or appendResponse.position is not Event or Position")
        }
        
        #expect(readPosition == position)

        try await streams.delete()
    }

    @Test("It should be succeed when set metadata to stream.")
    func testMetadata() async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let metadata = StreamMetadata()
            .cacheControl(.seconds(3))
            .maxAge(.seconds(30))
            .acl(.userStream)

        let client = KurrentDBClient(settings: .localhost())
        let streams = client.streams(of: .specified(streamIdentifier))
        
        try await streams.setMetadata(metadata: metadata)

        let responseMetadata = try #require(try await streams.getMetadata(from: .end))
        #expect(metadata == responseMetadata)
        try await streams.delete()
    }

    @Test("It should be succeed when subscribe to stream.")
    func testSubscribe() async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let client = KurrentDBClient(settings: .localhost())
        let streams = client.streams(of: .specified(streamIdentifier))
        
        let subscription = try await streams.subscribe(from: .end)
        let response = try await streams.append(events: .init(
            eventType: "Subscribe-AccountCreated", payload: ["Description": "Gears of War 10"]
        ), options: .init().revision(expected: .any))

        var lastEvent: ReadEvent?
        for try await event in subscription.events {
            lastEvent = event
            break
        }

        let lastEventRevision = try #require(lastEvent?.record.revision)
        #expect(response.currentRevision == lastEventRevision)
        try await streams.delete()
    }

    @Test("It should be succeed when subscribe to all streams.")
    func testSubscribeAll() async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let eventForTesting = EventData(
            eventType: "SubscribeAll-AccountCreated", payload: ["Description": "Gears of War 10"]
        )
        let client = KurrentDBClient(settings: .localhost())
        let streams = client.streams(of: .specified(streamIdentifier))
        let subscription = try await client.streams(of: .all).subscribe(from: .end)
        
        let response = try await streams.append(events: eventForTesting, options: .init().revision(expected: .any))
        
        var lastEvent: ReadEvent?
        for try await event in subscription.events {
            if event.record.eventType == eventForTesting.eventType {
                lastEvent = event
                break
            }
        }

        let lastEventPosition = try #require(lastEvent?.record.position)
        #expect(response.position?.commit == lastEventPosition.commit)
        try await streams.delete()
    }
    
    @Test("It should be succeed when subscribe to all streams with filter the event type.")
    func testSubscribeAllWithFilter() async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let eventForTesting = EventData(
            eventType: "SubscribeAll-AccountCreated", payload: ["Description": "Gears of War 10"]
        )
        let client = KurrentDBClient(settings: .localhost())
        let streams = client.streams(of: .specified(streamIdentifier))
        let filter: SubscriptionFilter = .onEventType(prefixes: "SubscribeAll-AccountCreated")
        let subscription = try await client.streams(of: .all).subscribe(from: .end, options: .init().filter(filter))
        
        let response = try await streams.append(events: eventForTesting, options: .init().revision(expected: .any))
        
        var lastEvent: ReadEvent?
        for try await event in subscription.events {
            lastEvent = event
            break
        }

        let lastEventPosition = try #require(lastEvent?.record.position)
        #expect(response.position?.commit == lastEventPosition.commit)
        try await streams.delete()
    }
    
    @Test("It should be succeed when subscribe to all streams by excluding system events")
    func testSubscribeAllExcludeSystemEvents() async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let eventForTesting = EventData(
            eventType: "SubscribeAll-AccountCreated", payload: ["Description": "Gears of War 10"]
        )
        let client = KurrentDBClient(settings: .localhost())
        let streams = client.streams(of: .specified(streamIdentifier))
        let filter: SubscriptionFilter = .excludeSystemEvents()
        let subscription = try await client.streams(of: .all).subscribe(from: .end, options: .init().filter(filter))
        
        let response = try await streams.append(events: eventForTesting, options: .init().revision(expected: .any))
        
        var lastEvent: ReadEvent?
        for try await event in subscription.events {
            lastEvent = event
            break
        }

        let lastEventPosition = try #require(lastEvent?.record.position)
        #expect(response.position?.commit == lastEventPosition.commit)
        try await streams.delete()
    }
    
    @Test("It should be succeed when subscribe to all streams by excluding system events")
    func testSubscribeFilterOnStreamName() async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let eventForTesting = EventData(
            eventType: "SubscribeAll-AccountCreated", payload: ["Description": "Gears of War 10"]
        )
        let client = KurrentDBClient(settings: .localhost())
        let streams = client.streams(of: .specified(streamIdentifier))
        let filter: SubscriptionFilter = .onStreamName(prefix: streamIdentifier.name)
        let subscription = try await client.streams(of: .all).subscribe(from: .end, options: .init().filter(filter))
        
        let response = try await streams.append(events: eventForTesting, options: .init().revision(expected: .any))
        
        var lastEvent: ReadEvent?
        for try await event in subscription.events {
            lastEvent = event
            break
        }

        let lastEventPosition = try #require(lastEvent?.record.position)
        #expect(response.position?.commit == lastEventPosition.commit)
        try await streams.delete()
    }
    
    @Test("It should be failed when subscribe to all streams by filter on wrong stream name.")
    func testSubscribeFilterFailedOnStreamName() async throws {
        let streamIdentifier = StreamIdentifier(name: UUID().uuidString)
        let eventForTesting = EventData(
            eventType: "SubscribeAll-AccountCreated", payload: ["Description": "Gears of War 10"]
        )
        let client = KurrentDBClient(settings: .localhost())
        let streams = client.streams(of: .specified(streamIdentifier))
        let filter: SubscriptionFilter = .onStreamName(prefix: "wrong")
        let subscription = try await client.streams(of: .all).subscribe(from: .end, options: .init().filter(filter))
        
        _ = try await streams.append(events: eventForTesting, options: .init().revision(expected: .any))

        
        Task {
            try await Task.sleep(for: .microseconds(500))
            subscription.terminate()
        }
        
        for try await _ in subscription.events {
            break
        }

    }

    
    
    @Test("Testing streamAcl encoding and decoding should be succeed.", arguments: [
        (StreamMetadata.Acl.systemStream, "$systemStreamAcl"),
        (StreamMetadata.Acl.userStream, "$userStreamAcl"),
    ])
    func testSystemStreamAclEncodeAndDecode(acl: StreamMetadata.Acl, value: String) throws {
        let encoder = JSONEncoder()
        let encodedData = try #require(try encoder.encode(value))

        #expect(try acl.rawValue == encodedData)

        let decoder = JSONDecoder()
        #expect(try decoder.decode(StreamMetadata.Acl.self, from: encodedData) == acl)
    }
}

