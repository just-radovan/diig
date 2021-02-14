//
//  ContentView.swift
//  diig
//
//  Created by Radovan Paška on 12.02.2021.
//

import SwiftUI

struct ImageView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isPickerPresented = false
    @State private var isDithering = false
    @State private var isDitheringAvailable = true

    @State private var ditheringProgress: Float = 0.0

    @State private var image: UIImage? = nil
    @State private var imageDithered: UIImage? = nil
    @State private var frameColor: UIColor? = .white
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                    imageView
                    Spacer()
                }
                .blur(radius: isDithering ? 10 : 0)
                .navigationBarTitle(Text("diig"), displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.primaryAction) {
                        Button(action: {
                            image = nil
                            imageDithered = nil
                            
                            isDitheringAvailable = true
                            isPickerPresented = true
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .disabled(isDithering)
                    }
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(action: ditherImage) { () -> Image in
                            if isDithering {
                                let icon: String
                                if ditheringProgress <= 0.333 {
                                    icon = "hourglass.bottomhalf.fill"
                                } else if ditheringProgress <= 0.666 {
                                    icon = "hourglass"
                                } else {
                                    icon = "hourglass.tophalf.fill"
                                }
                                
                                return Image(systemName: icon)
                            } else {
                                return Image(systemName: "wand.and.stars")
                            }
                        }
                        .frame(minWidth: 64, minHeight: 64)
                        .disabled(image == nil || !isDitheringAvailable || isDithering)
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                if self.frameColor == nil || self.frameColor == .white {
                                    self.frameColor = .black
                                } else {
                                    self.frameColor = .white
                                }
                            }) {
                                if self.frameColor == nil || self.frameColor == .white {
                                    Image(systemName: "square.righthalf.fill")
                                } else {
                                    Image(systemName: "square.lefthalf.fill")
                                }
                            }
                            .frame(minWidth: 64, minHeight: 64)
                            .disabled(imageDithered == nil)
                            
                            Divider()
                                .frame(maxHeight: 32)
                            
                            Button(action: {
                                self.frameColor = nil
                            }) {
                                if self.frameColor == nil || self.frameColor == .white {
                                    Image(systemName: "square.slash.fill")
                                } else {
                                    Image(systemName: "square.slash")
                                }
                                
                            }
                            .frame(minWidth: 64, minHeight: 64)
                            .disabled(imageDithered == nil)
                        }
                        
                        Spacer()
                        
                        Button(action: shareImagePng) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .frame(minWidth: 64, minHeight: 64)
                        .disabled(imageDithered == nil)
                    }
                }
                .frame(minHeight: 72)
                .sheet(isPresented: $isPickerPresented) {
                    return ImagePicker(image: $image, isPresented: $isPickerPresented, sourceType: .photoLibrary)
                }
                
                progressView
            }
        }
    }
    
    private var progressView: some View {
        if isDithering {
            let background: Color
            if colorScheme == .dark {
                background = Color.black.opacity(0.3)
            } else {
                background = Color.white.opacity(0.3)
            }
            
            let view = ZStack {
                ProgressView("dithering…", value: ditheringProgress, total: Float(1.0))
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 50)
            }
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .background(background)
            
            return AnyView(view)
        } else {
            let view = EmptyView()
            
            return AnyView(view)
        }
    }
    
    private var imageView: some View {
        if let image = getFramedImage() {
            let view = Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            return AnyView(view)
        } else if let image = self.image {
            let view = Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            return AnyView(view)
        } else {
            let view = EmptyView()
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            return AnyView(view)
        }
    }
    
    private func getFramedImage() -> UIImage? {
        guard let imageDithered = self.imageDithered else {
            return nil
        }
        
        if let frameColor = self.frameColor {
            return imageDithered.frame(with: frameColor)
        } else {
            return imageDithered
        }
    }
    
    private func ditherImage() {
        ditheringProgress = 0.0
        
        guard let originalImage = self.image else {
            return
        }
        
        isDithering = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.imageDithered = originalImage.dither(progress: $ditheringProgress)
            
            isDithering = false
            isDitheringAvailable = false
        }
    }
    
    private func shareImagePng() {
        guard let png = getFramedImage()?.pngData() else {
            return
        }
        
        let viewController = UIActivityViewController(
            activityItems: [png],
            applicationActivities: nil
        )
        
        UIApplication.shared.windows.first?.rootViewController?.present(
            viewController,
            animated: true,
            completion: nil
        )
    }
    
    private func log(_ logging: () -> String) -> EmptyView {
        NSLog(logging())
        
        return EmptyView()
    }
}
