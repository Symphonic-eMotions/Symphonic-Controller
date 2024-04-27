import SwiftUI

struct MainView: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
            
        NavigationView {
            
            //Set Navigation
            SideBarView(
                setInfoModel: setInfoModel
            )
            //TODO: Hide SideBar on fullscreen
//            .navigationBarHidden(showLevelPlayerFullScreen)

            SetInfo(
                setInfoModel: setInfoModel
            )
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct SideBarView: View {

    @ObservedObject var setInfoModel: SetInfoModel
    
    init(
        setInfoModel: SetInfoModel
        
    ) {
        self.setInfoModel = setInfoModel
    }
    
    var body: some View {
        
        //Making this conditional (if showNavigation) leaves a blanc space
        NavigationView {
            List {
                //Main menu itemms
                ForEach(sidebarItems, id: \.setName) { item in
                    Button(action: {}) {
                        SidebarItemView(
                            item: item,
                            active: selectedMainItem == item.sessionDisplay,
                            showDisabled: $showDisabled
                        )
                    }
                }
                
            }
            .navigationTitle(setInfoModel.setInfoLocalState.sideBarHead)
        }
    }
}

struct SetInfo: View {
    
    @ObservedObject var setInfoModel: SetInfoModel
    
    var body: some View {
        VStack{
            Button(action: {
                //What to call here to hide NavigationView in it's native way
            }, {
                Text("Close navigation")
            }
        }
    }
}

                   
                   
                   
import SwiftUI

struct SettingsSheetView: View {
   
   @ObservedObject var userSettings: UserSettings
   @ObservedObject var setInfoModel: SetInfoModel
   @Binding public var sessionDisplaySub: SessionDisplay
   @Binding var showingSheet: Bool
   @State private(set) var localTempo: Int = 0
   
   var body: some View {
       
       let sensitivityBinding = Binding(
           get: { userSettings.sensitivityDeviation },
           set: {
               userSettings.sensitivityDeviation = $0
               setInfoModel.imageDifference.sensitivityDeviationSubject.send(Float($0))
               
               
               let sensitivityPlusDeviation: Float = Float(userSettings.sensitivitySession + userSettings.sensitivityDeviation)
               setInfoModel.imageDifference.sensitivityToMaxValue(sensitivityPlusDeviation: sensitivityPlusDeviation)
               
               
               print("SENDING SESSION PRESET PLUS DEVIATION: \(userSettings.sensitivitySession) + \(userSettings.sensitivityDeviation)")
           }
       )
       
       
       
       return GeometryReader { geometry in
           
           ScrollView{
               
               VStack(alignment: .leading, spacing: 15) {
                   
                   Spacer().frame(height:50)
                   
                   //Sensitivity deviation
                   VStack(alignment: .leading){
                       Text("Sensitivity").padding(.top)
                       HStack {
                           Text("-")
                           Spacer()
                           Text("0")
                           Spacer()
                           Text("+")
                       }
                       Slider(value: sensitivityBinding, in: -0.25...0.25, onEditingChanged: { editing in
                           if editing {
                               AnalyticsAction.sensitivity.logEvent(
                                   sessionDisplay: .none,
                                   fileGroup: setInfoModel.setSettings.fileGroup,
                                   setName: setInfoModel.setSettings.setName
                               )
                           }
                       })
                       
                   }
               }
               
               FeedbackButtonsView(
                   setInfoModel: setInfoModel,
                   imageSide: UIScreen.main.bounds.width * 0.05,
                   userSettings: userSettings
               )
               
               //Level speed
               VStack(alignment: .leading){
                   Text("Level speed \(String(format: "%.2f", userSettings.levelSpeed))").padding(.top)
                   Slider(value: userSettings.levelSpeedBinding, in: 0.01...1, onEditingChanged: { editing in
                       if editing {
                           AnalyticsAction.levelSpeed.logEvent(
                               sessionDisplay: .none,
                               fileGroup: setInfoModel.setSettings.fileGroup,
                               setName: setInfoModel.setSettings.setName
                           )
                       }
                   })
               }
               
               HStack(){
                   VStack(alignment: .leading){
                       Text("Level progress exponent \(String(format: "%.1f", userSettings.levelProgressExponent))").padding(.top)
                       Slider(value: userSettings.$levelProgressExponent, in: 0...4)
                   }
                   VStack(alignment: .leading){
                       Text("Level difficulty \(String(format: "%.2f", userSettings.levelDifficulty))").padding(.top)
                       Slider(value: userSettings.$levelDifficulty, in: 0...1)
                   }
               }
               
               HStack {
                   
                   //Tempo
                   if setInfoModel.setSettings.hasTempo {
                       
                       VStack(alignment: .leading){
                           Text("Tempo").padding(.top)
                           HStack{
                               
                               EMButton(action: {
                                   AnalyticsAction.setSpeed.logEvent(
                                       sessionDisplay: .none,
                                       fileGroup: setInfoModel.setSettings.fileGroup,
                                       setName: setInfoModel.setSettings.setName
                                   )
                                   setInfoModel.tapSetTempoBPMMin()
                                   localTempo -= 1
                               }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                   Image(systemName: "minus")
                               }
                               
                               EMButton(action: {
                                   AnalyticsAction.setSpeed.logEvent(
                                       sessionDisplay: .none,
                                       fileGroup: setInfoModel.setSettings.fileGroup,
                                       setName: setInfoModel.setSettings.setName
                                   )
                                   print("Reset pressed")
                                   localTempo = 0
                                   setInfoModel.tapSetTempoReset()
                               }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                   Text(String(localTempo))
                               }
                               
                               EMButton(action: {
                                   AnalyticsAction.setSpeed.logEvent(
                                       sessionDisplay: .none,
                                       fileGroup: setInfoModel.setSettings.fileGroup,
                                       setName: setInfoModel.setSettings.setName
                                   )
                                   setInfoModel.tapSetTempoBPMPlus()
                                   localTempo += 1
                               }, color: .accentColor, isSolid: true, maxWidth: geometry.size.width * 0.111) {
                                   Image(systemName: "plus")
                               }
                           }
                       }
                   }
                   Spacer().frame(height:50)
//                    //Volume
//                    VStack(alignment: .leading){
//                        Text("Volume").padding(.top)
//                        VolumeSlider()
//                            .frame(height: 10)
//                            .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
//                            .zIndex(101)
//                    }
               }
               Spacer().frame(height:50)
               
               HStack {
                   
                   Spacer()
                   
                   //Continue
                   EMButton(action: {
                       showingSheet = false
                   }, color: .green, isSolid: true) {
                       Text(NSLocalizedString("Continue", comment: ""))
                   }
                   .frame(width: geometry.size.width * 0.333)
                   
                   //Start stop
                   EMButton(action: {
                           if userSettings.isSetPlaying {
                               AnalyticsAction.stopSet.logEvent(
                                   sessionDisplay: .none,
                                   fileGroup: setInfoModel.setSettings.fileGroup,
                                   setName: setInfoModel.setSettings.setName
                               )
                               sessionDisplaySub = .stopped
                               setInfoModel.tapStopAudioEngine()
                               userSettings.isSetPlaying = false
                           }
                           else{
                               AnalyticsAction.startSet.logEvent(
                                   sessionDisplay: .none,
                                   fileGroup: setInfoModel.setSettings.fileGroup,
                                   setName: setInfoModel.setSettings.setName
                               )
                               sessionDisplaySub = .playing
                               setInfoModel.tapStartAudioEngine()
                               userSettings.isSetPlaying = true
                           }
                           
                       }, color: .accentColor) {
                       Image(systemName: userSettings.isSetPlaying ? "stop.fill" : "play.fill")
                   }
                   .frame(width: geometry.size.width * 0.333)
                       
                   Spacer()
               }
               
           }
           .padding()
       }
   }
}

                   
