import UIKit
import CoreImage

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var images: [UIImage] = [] // An array to store the images
    var variances: [Double] = [] // An array to store the variance values
    var sharpImages: [UIImage] = [] // An array to store the sharp images

    @IBAction func takePictures(_ sender: UIButton) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .camera
        pickerController.allowsEditing = true
        pickerController.delegate = self
        present(pickerController, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            images.append(image)
        } else if let image = info[.originalImage] as? UIImage {
            images.append(image)
        }
        dismiss(animated: true)
    }

    func getVariance(of image: UIImage) -> Double? {
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
        let laplacianFilter = CIFilter(name: "CILaplacian")
        laplacianFilter?.setValue(ciImage, forKey: kCIInputImageKey)

        guard let outputCIImage = laplacianFilter?.outputImage,
              let outputCGImage = CIContext().createCGImage(outputCIImage, from: outputCIImage.extent) else {
            return nil
        }

        let width = outputCGImage.width
        let height = outputCGImage.height
        let bytesPerRow = outputCGImage.bytesPerRow
        let bitsPerComponent = outputCGImage.bitsPerComponent
        let colorSpace = outputCGImage.colorSpace
        let bitmapInfo = outputCGImage.bitmapInfo

        guard let pixelBuffer = malloc(bytesPerRow * height) else { return nil }
        defer { free(pixelBuffer) }

        let context = CGContext(data: pixelBuffer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(outputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let count = width * height
        var sum: Double = 0
        var sumSquared: Double = 0

        for i in 0..<height {
            for j in 0..<width {
                let offset = i * bytesPerRow + j * 4
                let pixel = pixelBuffer.load(fromByteOffset: offset, as: UInt8.self)
                let value = Double(pixel)
                sum += value
                sumSquared += value * value
            }
        }

        let mean = sum / Double(count)
        let variance = sumSquared / Double(count) - mean * mean

        return variance
    }

    func checkSharpness() {
        for image in images {
            if let variance = getVariance(of: image) {
                variances.append(variance)
                let threshold = Double(100) // Convert threshold to Double
                if variance >= threshold {
                    sharpImages.append(image)
                }
            }
        }
    }
}
