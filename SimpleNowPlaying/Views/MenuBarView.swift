import Foundation
import SwiftUI

struct MenuBarView: View {

    @ObservedObject var mediaManager: MediaManager

    init(_ mediaManager: MediaManager) {
        self.mediaManager = mediaManager
    }

    var body: some View {
        HStack(alignment: .center) {
            if mediaManager.image != nil {
                Image(nsImage: mediaManager.image!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 5))  // Round the corners
                    .padding(
                        EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 2))
            }

            Spacer()

            VStack(alignment: .leading) {

                VStack(alignment: .leading) {
                    Text(mediaManager.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .truncationMode(.tail)
                        .lineLimit(2)
                    Text(mediaManager.artist)
                        .font(.subheadline)
                        .fontWeight(.light)
                        .truncationMode(.tail)
                        .lineLimit(1)
                }
                MediaButtons(mediaManager: mediaManager)
            }
            Spacer()
        }
        .frame(width: 250, height: 110)
    }
}
