//
//  HomeKitView.swift
//  Symphonic eMotions
//
//  Created by Frans-Jan Wind on 01/09/2022.
//

import SwiftUI
import HomeKit

struct HomeKitView: View {
    
    @EnvironmentObject private var homeKitStore: HomeKitManager
    
    var body: some View {
        VStack {
            
            if homeKitStore.homes.isEmpty {
                Button(action: homeKitStore.load) {
                    Text("Koppel lamp")
                        .font(.title)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(20)
                }
                .onAppear{
                    //Load once up front so button click loads for real
                    homeKitStore.load()
                    homeKitStore.reload()
                }
            }
            
//            else {
//
//                Button(action: homeKitStore.lampAan) {
//                    Text("Lamp aan").font(.title)
//                }
//                Button(action: homeKitStore.lampUit) {
//                    Text("Lamp uit").font(.title)
//                }
//            }
            Spacer()
        }
    }
}

class HomeKitManager : NSObject, ObservableObject, HMHomeManagerDelegate {
    
    @Published var homes: [HMHome] = []
    private var manager: HMHomeManager!
    var accessories: [HMAccessory] = []
    
    func load() {
        
        // Initializing the manager here instead of in an init allows you to control when the permissions box shows up.
        if manager == nil {
            manager = .init()
            manager.delegate = self
        }
        
        homes = manager.homes
    }
    
    func reload(){
        homes = manager.homes
    }
    
    func lampAan(){
        if homes.count > 0 {
            let home = homes[0]
            let homeAccessories = home.accessories
            
            let accessory = homeAccessories[1]
            let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool)
            characteristic?.writeValue(NSNumber(value: true))  { error in
                if error != nil {
                  print("Ik kan de lamp aan uitzeten!")
                }
            }
        }
    }
    
    func lampUit(){
        if homes.count > 0 {
            let home = homes[0]
            let homeAccessories = home.accessories
            
            let accessory = homeAccessories[1]
            let characteristic = accessory.find(serviceType: HMServiceTypeLightbulb, characteristicType: HMCharacteristicMetadataFormatBool)
            characteristic?.writeValue(NSNumber(value: false))  { error in
                if error != nil {
                  print("Ik kan de lamp uit uitzeten!")
                }
            }
        }
    }
    
    deinit {
        manager.delegate = nil
    }
}

extension HMAccessory {
  func find(serviceType: String, characteristicType: String) -> HMCharacteristic? {
    return services.lazy
      .filter { $0.serviceType == serviceType }
      .flatMap { $0.characteristics }
      .first { $0.metadata?.format == characteristicType }
  }
}
