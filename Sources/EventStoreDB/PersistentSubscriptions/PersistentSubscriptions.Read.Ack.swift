//
//  PersistentSubscriptions.Read.Ack.swift
//
//
//  Created by Grady Zhuo on 2023/12/10.
//

import Foundation
import GRPCSupport

extension PersistentSubscriptionsClient {
    public struct Ack: StreamStream {
        public typealias Request = GenericGRPCRequest<EventStore_Client_PersistentSubscriptions_ReadReq>
        public typealias Response = DiscardedResponse<EventStore_Client_PersistentSubscriptions_ReadResp>

        let subscriptionId: String
        let eventIds: [UUID]

        public func build() throws -> [Request.UnderlyingMessage] {
            [
                .with {
                    $0.ack = .with {
                        $0.id = subscriptionId.data(using: .utf8) ?? Data()
                        $0.ids = eventIds.map {
                            $0.toEventStoreUUID()
                        }
                    }
                }
            ]
        }
    }
}