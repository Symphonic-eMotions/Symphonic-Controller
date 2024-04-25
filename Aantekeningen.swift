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

