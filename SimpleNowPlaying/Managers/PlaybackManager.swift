import AppKit
import Combine
import SwiftUI

class PlaybackManager: ObservableObject {
    @Published var MrMediaRemoteSendCommandFunction:
        @convention(c) (Int, AnyObject?) -> Void
    @Published var MrMediaRemoteSetElapsedTimeFunction:
        @convention(c) (Double) -> Void

    init() {
        self.MrMediaRemoteSendCommandFunction = { _, _ in }
        self.MrMediaRemoteSetElapsedTimeFunction = { _ in }
        handleLoadMediaHandlerApis()
    }

    private func handleLoadMediaHandlerApis() {
        guard
            let bundle = CFBundleCreate(
                kCFAllocatorDefault,
                NSURL(
                    fileURLWithPath:
                        "/System/Library/PrivateFrameworks/MediaRemote.framework"
                ))
        else { return }

        guard
            let MRMediaRemoteSendCommandPointer =
                CFBundleGetFunctionPointerForName(
                    bundle, "MRMediaRemoteSendCommand" as CFString)
        else { return }

        typealias MRMediaRemoteSendCommandFunction = @convention(c) (
            Int, AnyObject?
        ) -> Void

        MrMediaRemoteSendCommandFunction = unsafeBitCast(
            MRMediaRemoteSendCommandPointer,
            to: MRMediaRemoteSendCommandFunction.self)

        guard
            let MRMediaRemoteSetElapsedTimePointer =
                CFBundleGetFunctionPointerForName(
                    bundle, "MRMediaRemoteSetElapsedTime" as CFString)
        else { return }

        typealias MRMediaRemoteSetElapsedTimeFunction = @convention(c) (Double)
            -> Void
        MrMediaRemoteSetElapsedTimeFunction = unsafeBitCast(
            MRMediaRemoteSetElapsedTimePointer,
            to: MRMediaRemoteSetElapsedTimeFunction.self)
    }

    deinit {
        self.MrMediaRemoteSendCommandFunction = { _, _ in }
        self.MrMediaRemoteSetElapsedTimeFunction = { _ in }
    }

    
    func playPause(_ playing:Bool) {
        if playing {
            MrMediaRemoteSendCommandFunction(2, nil)
            return
        }
        MrMediaRemoteSendCommandFunction(0, nil)
    }

    func skip(_ back:Bool=false) {
        if back {
            MrMediaRemoteSendCommandFunction(5, nil)
            return
        }
        MrMediaRemoteSendCommandFunction(4, nil)
    }

    func seekTrack(to time: TimeInterval) {
        MrMediaRemoteSetElapsedTimeFunction(time)
    }
}
