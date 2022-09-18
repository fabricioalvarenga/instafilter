//
//  ContentView.swift
//  Instafilter
//
//  Created by FABRICIO ALVARENGA on 13/09/22.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 50.0
    @State private var filterScale = 2.5
    @State private var filterSaturation = 2.5

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    private var disableSave: Bool {
        (image == nil)
    }
    
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
                
                HStack {
                    Text("Intensity")
                    Slider(value: $filterIntensity, in: 0...10)
                        .onChange(of: filterIntensity) { _ in applyProcessing() }
                }
                .padding(.vertical, 5)
                
                HStack {
                    Text("Radius")
                    Slider(value: $filterRadius, in: 0...1000)
                        .onChange(of: filterRadius) { _ in applyProcessing() }
                }
                .padding(.vertical, 5)

                HStack {
                    Text("Scale")
                    Slider(value: $filterScale, in: 0...50)
                        .onChange(of: filterScale) { _ in applyProcessing() }
                }
                .padding(.vertical, 5)

                HStack {
                    Text("Saturation")
                    Slider(value: $filterSaturation, in: 0...50)
                        .onChange(of: filterSaturation) { _ in applyProcessing() }
                }
                .padding(.vertical, 5)

                HStack {
                    Button("Change filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save", action: save)
                        .disabled(disableSave)
                }
                .padding([.horizontal, .bottom])
                .navigationTitle("Instafilter")
                .onChange(of: inputImage) { _ in loadImage() }
                .sheet(isPresented: $showingImagePicker) {
                    ImagePicker(image: $inputImage)
                }
                .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                    Group {
                        Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                        Button("Edges") { setFilter(CIFilter.edges()) }
                        Button("Guassian Blur") { setFilter(CIFilter.gaussianBlur()) }
                        Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                        Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                    }
                    Group {
                        Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                        Button("Vignette") { setFilter(CIFilter.vignette()) }
                        Button("Color Controls") { setFilter(CIFilter.colorControls()) }
                        Button("Color Monochrome") { setFilter(CIFilter.colorMonochrome()) }
                        Button("Bump Distorcion") { setFilter(CIFilter.bumpDistortion()) }
                        Button("Cancel", role: .cancel) { }
                    }
                }
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func save() {
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = { print("Success!") }
        
        imageSaver.errorHandler = { print("Oops! \($0.localizedDescription)") }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)

    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale, forKey: kCIInputScaleKey) }
        if inputKeys.contains(kCIInputSaturationKey) {
            currentFilter.setValue(filterSaturation, forKey: kCIInputSaturationKey) }

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
