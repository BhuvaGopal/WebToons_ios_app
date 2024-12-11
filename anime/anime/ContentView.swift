import SwiftUI
import AVKit

// Model for Webtoon
struct Webtoon: Identifiable, Codable {
    let id: UUID
    let title: String
    let category: String
    let audioURL: String 
    let description: String
    var rating: Int
}

// ViewModel to manage webtoons and favorites
class WebtoonViewModel: ObservableObject {
    @Published var webtoons: [Webtoon] = []
    @Published var favorites: [Webtoon] = []
    
    let webtoonKey = "FavoriteWebtoons"
    
    init() {
        loadWebtoons()
        loadFavorites()
    }
    
   //take sample url
    func loadWebtoons() {
        webtoons = [
            // Romance category
            Webtoon(id: UUID(), title: "Lore Olympus", category: "Romance", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", description: "A modern retelling of the myth of Hades and Persephone.", rating: 5),
            Webtoon(id: UUID(), title: "True Beauty", category: "Romance", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3", description: "A young woman becomes a social media star thanks to her makeup skills.", rating: 4),
            // Action category
            Webtoon(id: UUID(), title: "Tower of God", category: "Action", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3", description: "Follow Bam as he climbs the mysterious Tower of God.", rating: 5),
            Webtoon(id: UUID(), title: "The God of High School", category: "Action", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3", description: "The top fighters from across Korea compete in an epic martial arts tournament.", rating: 4),
            Webtoon(id: UUID(), title: "Solo Leveling", category: "Action", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3", description: "Jinwoo Sung goes from being the weakest hunter to the strongest.", rating: 5),
            // Horror category
            Webtoon(id: UUID(), title: "Sweet Home", category: "Horror", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3", description: "A psychological thriller set in a monster-infested world.", rating: 5),
            Webtoon(id: UUID(), title: "Bastard", category: "Horror", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3", description: "A psychological thriller about a boy with a deadly secret.", rating: 4),
            // Drama category
            Webtoon(id: UUID(), title: "Unordinary", category: "Drama", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3", description: "A high school where students possess extraordinary powers.", rating: 4),
            Webtoon(id: UUID(), title: "Let's Play", category: "Drama", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3", description: "Sam, a game developer, navigates her social and work life.", rating: 4),
            // Thriller category
            Webtoon(id: UUID(), title: "Bastard", category: "Thriller", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3", description: "A boy with a murderous father, living in constant fear.", rating: 5),
            Webtoon(id: UUID(), title: "Pigpen", category: "Thriller", audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-11.mp3", description: "A psychological horror about a man trapped on an island.", rating: 4),
        ]
    }
    
    // Load favorites from UserDefaults
    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: webtoonKey),
           let savedFavorites = try? JSONDecoder().decode([Webtoon].self, from: data) {
            favorites = savedFavorites
        }
    }
    
    // Save favorites to UserDefaults
    func saveFavorites() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: webtoonKey)
        }
    }
    
    // Add or remove from favorites
    func toggleFavorite(_ webtoon: Webtoon) {
        if favorites.contains(where: { $0.id == webtoon.id }) {
            favorites.removeAll { $0.id == webtoon.id }
        } else {
            favorites.append(webtoon)
        }
        saveFavorites()
    }
    
    // Update rating
    func updateRating(for webtoon: Webtoon, rating: Int) {
        if let index = webtoons.firstIndex(where: { $0.id == webtoon.id }) {
            webtoons[index].rating = rating
        }
    }
}

// Home Screen
struct HomeScreen: View {
    @ObservedObject var viewModel: WebtoonViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.webtoons.isEmpty {
                Text("No webtoons available.")
                    .foregroundColor(.gray)
                    .padding()
                    .navigationTitle("Webtoon Categories")
            } else {
                List {
                    // Convert Set to Array for ForEach
                    ForEach(Array(Set(viewModel.webtoons.map { $0.category })), id: \.self) { category in
                        NavigationLink(destination: WebtoonCategoryScreen(category: category, viewModel: viewModel)) {
                            HStack {
                                Text(category)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .navigationTitle("Webtoon Categories")
            }
        }
    }
}

// Webtoon Category Screen
struct WebtoonCategoryScreen: View {
    let category: String
    @ObservedObject var viewModel: WebtoonViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.webtoons.filter { $0.category == category }) { webtoon in
                NavigationLink(destination: WebtoonDetailScreen(webtoon: webtoon, viewModel: viewModel)) {
                    VStack(alignment: .leading) {
                        Text(webtoon.title)
                            .font(.headline)
                        Text(webtoon.category)
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle(category)
    }
}

// Webtoon Detail Screen
struct WebtoonDetailScreen: View {
    let webtoon: Webtoon
    @ObservedObject var viewModel: WebtoonViewModel
    @State private var audioPlayer: AVPlayer?
    @State private var isPlaying: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(webtoon.description)
                .font(.body)
                .padding()
            
            // Audio Player Controls (Play and Pause)
            HStack {
                Button(action: {
                    if isPlaying {
                        audioPlayer?.pause()
                    } else {
                        if audioPlayer == nil {
                            audioPlayer = AVPlayer(url: URL(string: webtoon.audioURL)!)
                        }
                        audioPlayer?.play()
                    }
                    isPlaying.toggle()
                }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            
            Button(action: {
                viewModel.toggleFavorite(webtoon)
            }) {
                Text(viewModel.favorites.contains(where: { $0.id == webtoon.id }) ? "Remove from Favorites" : "Add to Favorites")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // Rating Feature
            RatingView(webtoon: webtoon, viewModel: viewModel)
            
            Spacer()
        }
        .padding()
        .navigationTitle(webtoon.title)
    }
}

// Rating View
struct RatingView: View {
    let webtoon: Webtoon
    @ObservedObject var viewModel: WebtoonViewModel
    
    var body: some View {
        HStack {
            Text("Rate this Webtoon:")
                .font(.headline)
            ForEach(1..<6) { star in
                Image(systemName: webtoon.rating >= star ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        viewModel.updateRating(for: webtoon, rating: star)
                    }
            }
        }
    }
}

// Favorites Screen
struct FavoritesScreen: View {
    @ObservedObject var viewModel: WebtoonViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.favorites) { webtoon in
                    NavigationLink(destination: WebtoonDetailScreen(webtoon: webtoon, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(webtoon.title)
                                .font(.headline)
                            Text(webtoon.category)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

// Main ContentView
struct ContentView: View {
    @StateObject var viewModel = WebtoonViewModel() // Create a single instance of ViewModel
    
    var body: some View {
        TabView {
            HomeScreen(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            FavoritesScreen(viewModel: viewModel) // Use the same ViewModel instance
                .tabItem {
                    Image(systemName: "star")
                    Text("Favorites")
                }
        }
    }
}

#Preview {
    ContentView()
}

