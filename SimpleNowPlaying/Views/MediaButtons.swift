import SwiftUI

struct MediaButtons: View {
    
    var mediaManager: MediaManager!

    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                mediaManager.playbackManager.skip(true)
            }) {
                Image(systemName: "backward.fill")
                    .clipShape(Rectangle())
            }

            Button(action: {
                mediaManager.playPause()
            }) {
                if mediaManager.playbackState != .playing {
                    Image(systemName: "pause.fill")
                        .clipShape(Rectangle())
                } else {
                    Image(systemName: "play.fill")
                        .clipShape(Rectangle())
                }
            }

            Button(action: {
                mediaManager.playbackManager.skip()
            }) {
                Image(systemName: "forward.fill")
                    .clipShape(Rectangle())
            }
        }
        .background(Color.clear)
    }
}
