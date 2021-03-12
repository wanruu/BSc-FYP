import SwiftUI

struct PCPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 30) {
                Image(systemName: "person.fill")
                    .resizable()
                    .foregroundColor(Color.secondary)
                    .frame(width: 40, height: 40)
                    .padding(10)
                    .background(Circle().stroke(Color.secondary, lineWidth: 4))
                Text("Your name")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            Divider()
            SavedListView()
        }
        .navigationBarHidden(true)
    }
}
