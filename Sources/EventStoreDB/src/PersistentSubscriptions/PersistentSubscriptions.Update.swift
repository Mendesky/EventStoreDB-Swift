//
//  PersistentSubscriptions.Update.swift
//
//
//  Created by Grady Zhuo on 2023/12/7.
//

import Foundation
import GRPCSupport

extension PersistentSubscriptionsClient {
    public struct Update: UnaryUnary {
        public typealias Response = DiscardedResponse<EventStore_Client_PersistentSubscriptions_UpdateResp>

        var streamSelection: StreamSelection
        var groupName: String
        var options: Options

        public func build() throws -> Request.UnderlyingMessage {
            try .with {
                $0.options = options.build()
                try streamSelection.build(options: &$0.options)
            }
        }
    }
}

extension PersistentSubscriptionsClient.Update {
    public enum StreamSelection {
        case all(position: StreamClient.Cursor<StreamClient.Read.Position>)
        case specified(streamIdentifier: StreamClient.Identifier, revision: StreamClient.Cursor<UInt64>)

        func build(options: inout PersistentSubscriptionsClient.Update.Request.UnderlyingMessage.Options) throws {
            switch self {
            case let .all(cursor):
                switch cursor {
                case .start:
                    options.all.start = .init()
                case .end:
                    options.all.end = .init()
                case let .at(pointer):
                    options.all.position = .with {
                        $0.commitPosition = pointer.commit
                        $0.preparePosition = pointer.prepare
                    }
                }

            case let .specified(identifier, revisionCursor):

                options.streamIdentifier = try identifier.build()
                switch revisionCursor {
                case .start:
                    options.stream.start = .init()
                case .end:
                    options.stream.end = .init()
                case let .at(pointer):
                    options.stream.revision = pointer
                }
            }
        }
    }

    public struct Request: GRPCRequest {
        public typealias UnderlyingMessage = EventStore_Client_PersistentSubscriptions_UpdateReq
    }

    public final class Options: EventStoreOptions {
        public typealias UnderlyingMessage = Request.UnderlyingMessage.Options

        public var options: UnderlyingMessage

        public init() {
            options = .with {
                $0.settings = .init()
            }
        }

        public func build() -> UnderlyingMessage {
            options
        }

        @discardableResult
        public func set(resolveLinks: Bool) -> Self {
            options.settings.resolveLinks = resolveLinks
            return self
        }

        @discardableResult
        public func set(extraStatistics: Bool) -> Self {
            options.settings.extraStatistics = extraStatistics
            return self
        }

        @discardableResult
        public func set(maxRetryCount: Int32) -> Self {
            options.settings.maxRetryCount = maxRetryCount
            return self
        }

        @discardableResult
        public func set(minCheckpointCount: Int32) -> Self {
            options.settings.minCheckpointCount = minCheckpointCount
            return self
        }

        @discardableResult
        public func set(maxCheckpointCount: Int32) -> Self {
            options.settings.maxCheckpointCount = maxCheckpointCount
            return self
        }

        @discardableResult
        public func set(maxSubscriberCount: Int32) -> Self {
            options.settings.maxSubscriberCount = maxSubscriberCount
            return self
        }

        @discardableResult
        public func set(liveBufferSize: Int32) -> Self {
            options.settings.liveBufferSize = liveBufferSize
            return self
        }

        @discardableResult
        public func set(readBatchSize: Int32) -> Self {
            options.settings.readBatchSize = readBatchSize
            return self
        }

        @discardableResult
        public func set(historyBufferSize: Int32) -> Self {
            options.settings.historyBufferSize = historyBufferSize
            return self
        }

        @discardableResult
        public func set(namedConsumerStrategy: PersistentSubscriptionsClient.Update.Request.UnderlyingMessage.ConsumerStrategy) -> Self {
            options.settings.namedConsumerStrategy = namedConsumerStrategy
            return self
        }

        @discardableResult
        public func setMessageTimeout(_ timeout: PersistentSubscriptionsClient.TimeSpan) -> Self {
            switch timeout {
            case let .ticks(messageTimeoutTicks):
                options.settings.messageTimeoutTicks = messageTimeoutTicks
            case let .ms(messageTimeoutMs):
                options.settings.messageTimeoutMs = messageTimeoutMs
            }
            return self
        }

        @discardableResult
        public func setCheckpoint(after span: PersistentSubscriptionsClient.TimeSpan) -> Self {
            switch span {
            case let .ticks(checkpointAfterTicks):
                options.settings.checkpointAfterTicks = checkpointAfterTicks
            case let .ms(checkpointAfterMs):
                options.settings.checkpointAfterMs = checkpointAfterMs
            }
            return self
        }
    }
}
