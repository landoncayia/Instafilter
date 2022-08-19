//
//  ContentView.swift
//  Instafilter
//
//  Created by Landon Cayia on 8/14/22.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5  // range of 0-1
    @State private var filterRadius = 100.0   // range of 0-200
    @State private var filterScale = 25.0      // range of 0-50
    
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    // By default, this is a sepiaTone filter; can by any, though
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(.headline)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                VStack {
                    HStack {
                        Text("Intensity")
                            .frame(width: 70, alignment: .trailing)
                        
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity) { _ in applyProcessing() }
                    }
                    .padding(.vertical)
                    
                    HStack {
                        Text("Radius")
                            .frame(width: 70, alignment: .trailing)
                        
                        Slider(value: $filterRadius, in: 0...200)
                            .onChange(of: filterRadius) { _ in applyProcessing() }
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Text("Scale")
                            .frame(width: 70, alignment: .trailing)
                        
                        Slider(value: $filterScale, in: 0...50)
                            .onChange(of: filterScale) { _ in applyProcessing() }
                    }
                    .padding(.bottom)
                }
                
                HStack {
                    Button("Change Filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    // Save button is disabled if there is no image in the image view
                    Button("Save", action: save)
                        .disabled(image == nil)
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Group {
                    // Just a handful of CIFilters; there are many more
                    Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                    Button("Edges") { setFilter(CIFilter.edges()) }
                    Button("Gaussian Blur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                    Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                    Button("Comic Effect") { setFilter(CIFilter.comicEffect()) }
                    Button("Photo Effect Chrome") { setFilter(CIFilter.photoEffectChrome()) }
                    Button("Color Invert") { setFilter(CIFilter.colorInvert()) }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    /// Loads a SwiftUI Image view from a UIImage input.
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    /// Saves an image with a filter applied to the photo library.
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
    /// Applies the value of the effect strength slider to the chosen filter.
    func applyProcessing() {
        // Read which keys the filter supports, and apply the effect if supported
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale, forKey: kCIInputScaleKey)
        }
        
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
