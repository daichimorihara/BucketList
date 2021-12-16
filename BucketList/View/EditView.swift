//
//  EditView.swift
//  BucketList
//
//  Created by Daichi Morihara on 2021/11/14.
//

import SwiftUI
import MapKit


struct EditView: View {

    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void
    @StateObject var viewModel = ViewModel()
    @State private var name: String
    @State private var description: String

    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Place name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Nearby...") {
                    switch viewModel.loadingState {
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .loading:
                        Text("Loading...")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode(Result.self, from: data)
                viewModel.pages = items.query.pages.values.sorted()
                viewModel.loadingState = .loaded
        } catch {
            viewModel.loadingState = .failed
        }
    }
    
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        EditView(location: Location.example) { newLocation in }
    }
}

//struct EditView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @ObservedObject var placemark: MKPointAnnotation
//    @State private var loadingState = LoadingState.loading
//    @State private var pages = [Page]()
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section {
//                    TextField("Place name", text: $placemark.wrappedTitle)
//                    TextField("Description", text: $placemark.wrappedSubtitle)
//                }
//                Section("Nearby...") {
//                    if loadingState == .loaded {
//                        List(pages, id: \.pageid) { page in
//                            Text(page.title).font(.headline)
//                            + Text(": ") +
//                            Text(page.description).italic()
//                        }
//                    } else if loadingState == .loading {
//                        Text("Loading...")
//                    } else {
//                        Text("Please try again later.")
//                    }
//
//                }
//            }
//            .navigationTitle("Edit place")
//            .navigationBarItems(trailing: Button("Done") {
//                self.presentationMode.wrappedValue.dismiss()
//            })
//            .onAppear(perform: fetchNearbyPlaces )
//        }
//    }
//
//    enum LoadingState {
//        case loading, loaded, failed
//    }
//
//    func fetchNearbyPlaces() {
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "en.wikipedia.org"
//        components.path = "/w/api.php"
//        components.queryItems = [
//            URLQueryItem(name: "ggscoord", value: "\(placemark.coordinate.latitude)|\(placemark.coordinate.longitude)"),
//            URLQueryItem(name: "action", value: "query"),
//            URLQueryItem(name: "prop", value: "coordinates|pageimages|pageterms"),
//            URLQueryItem(name: "colimit", value: "50"),
//            URLQueryItem(name: "piprop", value: "thumbnail"),
//            URLQueryItem(name: "pithumbsize", value: "500"),
//            URLQueryItem(name: "pilimit", value: "50"),
//            URLQueryItem(name: "wbptterms", value: "description"),
//            URLQueryItem(name: "generator", value: "geosearch"),
//            URLQueryItem(name: "ggsradius", value: "10000"),
//            URLQueryItem(name: "ggslimit", value: "50"),
//            URLQueryItem(name: "format", value: "json")
//        ]
//        guard let url = components.url else {
//            print("Invalid URL")
//            return
//        }
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            if let data = data {
//                if let items = try? JSONDecoder().decode(Result.self, from: data) {
//                    self.pages = Array(items.query.pages.values).sorted()
//                    self.loadingState = .loaded
//                    return
//                }
//            }
//            self.loadingState = .failed
//        }.resume()
//    }
//
//}

