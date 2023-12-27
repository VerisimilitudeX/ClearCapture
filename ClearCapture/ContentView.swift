import SwiftUI

struct ContentView: View {
    @State private var isCameraPresented = false
    @State private var sharpImages: [UIImage] = []
    @State private var sharpnessMessage: String? // Add this line
    
    var body: some View {
        VStack {
            Button("Take Photo") {
                isCameraPresented = true
            }
            
            if let message = sharpnessMessage {
                Text(message) // Display the sharpness status message
                    .padding()
            }
            
            ScrollView {
                ForEach(sharpImages, id: \.self) { img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .padding()
                }
            }
        }
        .sheet(isPresented: $isCameraPresented) {
            CameraView { image in
                processCapturedImage(image)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension ContentView {
    func processCapturedImage(_ image: UIImage?) {
        guard let image = image else {
            sharpnessMessage = "No image captured or image is not valid."
            return
        }

        let vc = ViewController()
        if let variance = vc.getVariance(of: image), variance >= 50 { // The threshold value
            sharpImages.append(image)
            sharpnessMessage = "Captured image is sharp."
        } else {
            sharpnessMessage = "Captured image is blurry."
        }
    }
}
