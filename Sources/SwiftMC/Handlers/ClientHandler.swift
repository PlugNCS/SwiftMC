/*
*  Copyright (C) 2020 Groupe MINASTE
*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*
*/

import Foundation
import NIO

public final class ClientHandler: ChannelInboundHandler, ChannelHandler {
    
    // Requirements
    public typealias InboundIn = Packet
    public typealias OutboundOut = Packet
    
    // Variables
    let channelWrapper: ChannelWrapper
    var handler: PacketHandler?
    
    // Initializer
    init(channelWrapper: ChannelWrapper) {
        self.channelWrapper = channelWrapper
        self.channelWrapper.handler = self
        self.channelWrapper.setHandler(handler: InitialHandler())
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // Close if server is not ready
        if !channelWrapper.server.ready {
            channelWrapper.close()
            return
        }
        
        // Read wrapper
        let packet = unwrapInboundIn(data)
        
        // Check for debug
        if channelWrapper.server.configuration.debug {
            channelWrapper.server.log("CLIENT -> SERVER: \(packet.toString())")
        }
        
        // Handle packet
        if let handler = handler {
            let sendPacket = handler.shouldHandle(packet: packet)
            if sendPacket {
                handler.handle(packet: packet)
            }
        }
    }
    
    // This method is called if the socket is closed in a clean way.
    public func channelInactive(context: ChannelHandlerContext) {
        // Mark as closed
        channelWrapper.close()
    }
    
    // Called if an error happens. Log and close the socket.
    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        // Mark as closed
        channelWrapper.close()
    }
    
}
