//
//  Streams.ReadAll.swift
//  KurrentStreams
//
//  Created by 卓俊諺 on 2025/1/3.
//

import GRPCCore
import GRPCEncapsulates

extension Streams where Target == AllStreams {
    public struct ReadAll: UnaryStream {
        package typealias ServiceClient = UnderlyingClient
        package typealias UnderlyingRequest = ServiceClient.UnderlyingService.Method.Read.Input
        package typealias UnderlyingResponse = ServiceClient.UnderlyingService.Method.Read.Output
        public typealias Response = ReadResponse
        public typealias Responses = AsyncThrowingStream<Response, Error>

        public let options: Options

        init(options: Options) {
            self.options = options
        }

        package func requestMessage() throws -> UnderlyingRequest {
            .with {
                $0.options = options.build()
            }
        }

        package func send(client: ServiceClient, request: ClientRequest<UnderlyingRequest>, callOptions: CallOptions) async throws -> Responses {
            try await withThrowingTaskGroup(of: Void.self) { _ in
                let (stream, continuation) = AsyncThrowingStream.makeStream(of: Response.self)
                try await client.read(request: request, options: callOptions) {
                    for try await message in $0.messages {
                        try continuation.yield(handle(message: message))
                    }
                }
                return stream
            }
        }
    }
}

extension Streams.ReadAll where Target == AllStreams {
    public struct CursorPointer: Sendable {
        public let position: StreamPosition
        public let direction: Direction

        public static func forwardOn(commitPosition: UInt64, preparePosition: UInt64) -> Self {
            .init(position: .at(commitPosition: commitPosition, preparePosition: preparePosition), direction: .forward)
        }

        public static func backwardFrom(commitPosition: UInt64, preparePosition: UInt64) -> Self {
            .init(position: .at(commitPosition: commitPosition, preparePosition: preparePosition), direction: .backward)
        }
    }
}

extension Streams.ReadAll{
    public struct Options: EventStoreOptions {
        package typealias UnderlyingMessage = UnderlyingRequest.Options

        private var cursor: PositionCursor
        public package(set) var direction: Direction
        public private(set) var resolveLinksEnabled: Bool
        public private(set) var limit: UInt64
        public private(set) var uuidOption: UUIDOption
        public private(set) var compatibility: UInt32

        public init() {
            self.resolveLinksEnabled = false
            self.limit = .max
            self.uuidOption = .string
            self.compatibility = 0
            self.cursor = .start
            self.direction = .forward
        }

        package func build() -> UnderlyingMessage {
            .with {
                $0.noFilter = .init()

                switch uuidOption {
                case .structured:
                    $0.uuidOption.structured = .init()
                case .string:
                    $0.uuidOption.string = .init()
                }

                $0.controlOption = .with {
                    $0.compatibility = compatibility
                }
                $0.resolveLinks = resolveLinksEnabled
                $0.count = limit
                
                switch cursor {
                case .start:
                    $0.stream.start = .init()
                case .end:
                    $0.stream.end = .init()
                case let .position(commitPosition, preparePosition):
                    $0.all.position = .with {
                        $0.commitPosition = commitPosition
                        $0.preparePosition = preparePosition
                    }
                }
                
                $0.readDirection = switch direction {
                case .forward:
                    .forwards
                case .backward:
                    .backwards
                }
            }
        }

        @discardableResult
        public func resolveLinks() -> Self {
            withCopy { options in
                options.resolveLinksEnabled = true
            }
        }

        @discardableResult
        public func limit(_ limit: UInt64) -> Self {
            withCopy { options in
                options.limit = limit
            }
        }

        @discardableResult
        public func uuidOption(_ uuidOption: UUIDOption) -> Self {
            withCopy { options in
                options.uuidOption = uuidOption
            }
        }

        @discardableResult
        public func compatibility(_ compatibility: UInt32) -> Self {
            withCopy { options in
                options.compatibility = compatibility
            }
        }
        @discardableResult
        public func forward() -> Self {
            withCopy{ options in
                options.direction = .forward
            }
        }
        
        @discardableResult
        public func backward() -> Self {
            withCopy{ options in
                options.direction = .backward
            }
        }
        
        @discardableResult
        internal func curosr(_ cursor: PositionCursor) -> Self {
            withCopy{ options in
                options.cursor = cursor
            }
        }
    }
}


//MARK: - Deprecated
extension Streams.ReadAll.Options {
    @available(*, deprecated, renamed: "limit")
    @discardableResult
    public func set(limit: UInt64) -> Self {
        withCopy { options in
            options.limit = limit
        }
    }
    
    @available(*, deprecated, renamed: "resolveLinks")
    @discardableResult
    public func set(resolveLinks: Bool) -> Self {
        withCopy { options in
            options.resolveLinksEnabled = resolveLinks
        }
    }
    
    @available(*, deprecated, renamed: "uuidOption")
    @discardableResult
    public func set(uuidOption: UUIDOption) -> Self {
        withCopy { options in
            options.uuidOption = uuidOption
        }
    }
    
    
    @available(*, deprecated, renamed: "compatibility")
    @discardableResult
    public func set(compatibility: UInt32) -> Self {
        withCopy { options in
            options.compatibility = compatibility
        }
    }
    
}
