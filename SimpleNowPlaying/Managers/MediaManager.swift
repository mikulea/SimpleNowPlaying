import AppKit
import Combine
import Foundation
import MediaPlayer
import SwiftUI

enum MediaStatus {
    case stopped
    case playing
    case paused
    case unknown
}

class MediaManager: ObservableObject {

    @AppStorage("alternateTitleArtist") private var alternateTitleArtist: Bool =
        false

    private let mediaRemoteBundle: CFBundle
    private let MRMediaRemoteGetNowPlayingInfo:
        @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) ->
            Void
    private let MRMediaRemoteRegisterForNowPlayingNotifications:
        @convention(c) (DispatchQueue) -> Void

    private var cancellables = Set<AnyCancellable>()

    @Published var title: String = "nil"
    @Published var artist: String = "nil"

    @Published var image: NSImage? = nil

    @Published var playbackState = MediaStatus.unknown
    var playbackManager = PlaybackManager()

    init?() {
        guard
            let bundle = CFBundleCreate(
                kCFAllocatorDefault,
                NSURL(
                    fileURLWithPath:
                        "/System/Library/PrivateFrameworks/MediaRemote.framework"
                ))
        else {
            print("Failed to load MediaRemote.framework")
            return nil
        }

        self.mediaRemoteBundle = bundle

        guard
            let MRMediaRemoteGetNowPlayingInfoPointer =
                CFBundleGetFunctionPointerForName(
                    bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString),
            let MRMediaRemoteRegisterForNowPlayingNotificationsPointer =
                CFBundleGetFunctionPointerForName(
                    bundle,
                    "MRMediaRemoteRegisterForNowPlayingNotifications"
                        as CFString)
        else {
            print("Failed to get function pointers")
            return nil
        }

        self.MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(
            MRMediaRemoteGetNowPlayingInfoPointer,
            to: (@convention(c) (
                DispatchQueue, @escaping ([String: Any]) -> Void
            ) -> Void).self)
        self.MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(
            MRMediaRemoteRegisterForNowPlayingNotificationsPointer,
            to: (@convention(c) (DispatchQueue) -> Void).self)

        setupObservers()
        fetchCurrentlyPlaying()
    }

    deinit {
        cancellables.removeAll()
        NotificationCenter.default.removeObserver(self)
    }

    private func parseNewData(_ title: String, _ artist: String, _ image: NSImage?) {
        if image != nil {
            self.image = image
        }
        
        if !title.isEmpty  {
            self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if !artist.isEmpty {
            self.artist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if alternateTitleArtist {
            let splitTitle = title.split(separator: "-")

            if splitTitle.count > 1 {
                self.artist = String(splitTitle[1]).trimmingCharacters(
                    in: .whitespacesAndNewlines)
                self.title = String(splitTitle[0]).trimmingCharacters(
                    in: .whitespacesAndNewlines)
                return
            }
        }

        self.objectWillChange.send()
    }

    private func handlePlaybackStateChange(_ state: Int) {
        switch state {
        case 0:
            self.playbackState = .stopped
        case 1:
            self.playbackState = .playing
        case 2:
            self.playbackState = .paused
        default:
            self.playbackState = .unknown
        }
    }

    private func setupObservers() {
        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main)

        NotificationCenter.default.publisher(
            for: NSNotification.Name(
                "kMRMediaRemoteNowPlayingInfoDidChangeNotification")
        )
        .sink { [weak self] _ in
            self?.fetchCurrentlyPlaying()
        }
        .store(in: &cancellables)

        NotificationCenter.default.publisher(
            for: NSNotification.Name(
                "kMRMediaRemoteNowPlayingPlaybackStateDidChangeNotification")
        )
        .sink { [weak self] notification in
            if let userInfo = notification.userInfo,
                let playbackState = userInfo[
                    "kMRMediaRemoteNowPlayingPlaybackState"] as? Int
            {
                self!.handlePlaybackStateChange(playbackState)
            }
        }
        .store(in: &cancellables)
    }

    @objc private func fetchCurrentlyPlaying() {
        MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main) {
            [weak self] information in
            guard let self = self else { return }

            let newSongTitle =
                information["kMRMediaRemoteNowPlayingInfoTitle"] as? String
                ?? ""
            let newArtistName =
                information["kMRMediaRemoteNowPlayingInfoArtist"] as? String
                ?? ""
            let newArtworkData =
                information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
            let playbackState =
                information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Int
                ?? 6  // Default to 0 if not available

            self.handlePlaybackStateChange(playbackState)

            self.parseNewData(
                newSongTitle, newArtistName,
                (newArtworkData != nil) ? NSImage(data: newArtworkData!) : nil)
        }
    }
    
    func playPause() {
        playbackManager.playPause((playbackState == .playing ? true : false))
    }
}
