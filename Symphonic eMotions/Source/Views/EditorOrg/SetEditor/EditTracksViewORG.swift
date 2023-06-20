////
////  EditTracksView.swift
////  Symphonic eMotions Pro
////
////  Created by Frans-Jan Wind on 01/04/2023.
////
//
//import SwiftUI
//
//struct EditTracksView: View {
//
//    @ObservedObject var setInfoModel: SetInfoModel
//    @Binding var showEditorPart: EditorParts
//    
//    //Levels
//    @Binding var trackLevels: [String: [Int]]
//    @Binding var noteNumbersLevels: [String: [Int]]
//    @Binding var midiClipsLevels: [String: [Int]]
//    
//    //Position
//    @Binding var gridRow: Int
//    @Binding var noteNumbersPositions: [String: [Int]]
//    @Binding var midiClipPositions: [String: [Int]]
//    
//    //Note numbers per track
//    @Binding var noteNumbers: [String: [Int]]
//    @Binding var noteNumberLetters: [String: [Int]]
//    
//    //Midi cips per track
//    @Binding var midiClips: [String: [Double]]
//    @Binding var midiClipLetters: [String: [Int]]
//    
//    //Types per tracks
//    @Binding var noteSources: [String: NoteSource]
//    @Binding var startTypes: [String: StartType]
//    @Binding var variationTypes: [String: VariationType]
//    @Binding var instrumentTypes: [String: InstrumentsSet.Track.InstrumentType]
//    
//    //Part variables
//    @Binding var areaOfInterest: [String: [Int]]
//    @Binding var minimalLevel: [String: Double]
//    
////    @State var variationTypeLocal: [String: VariationType]
////    @State var noteSourceLocal: [String: NoteSource]
////    //Linear representation of the midi clips.
////    //Modified by MidiClipsInFile
////    @State var midiClipLetters: [String: [Int]]
////    //Representation note numbers NoteNumberToGrid indexed by trackId
////    @State var noteNumbersPerTrack: [String: [Int]]
////    //Representation active areas per PART ID
////    @State var areaOfInterest: [String: [Int]]
////    
////    
////    init(
////        setInfoModel: SetInfoModel,
////        showEditorPart: Binding<EditorParts>
////    ) {
////        self.setInfoModel = setInfoModel
////        _showEditorPart = showEditorPart
////        
////        var tmpVariationType = [String: VariationType]()
////        var tmpNoteSource = [String: NoteSource]()
////        //Make for all tracks a shared variationType and noteSource dictionary
////        for track in setInfoModel.setSettings.tracks {
////            tmpVariationType[track.value.trackId] = track.value.variationType
////            tmpNoteSource[track.value.trackId] = track.value.noteSource
////        }
////        _variationTypeLocal = State(initialValue: tmpVariationType)
////        _noteSourceLocal = State(initialValue: tmpNoteSource)
////        
////        //Translate loopLengths its clipLetters Counterpart
////        //First is A, Second is B etc So the length is the amount
////        var tmpClipLetters = [String: [Int]]()
////        for track in setInfoModel.setSettings.tracks {
////            let clips = track.value.loopLength
////            tmpClipLetters[track.value.trackId] = Array(0..<clips.count).map{$0}
////            
////        }
////        _midiClipLetters = State(initialValue: tmpClipLetters)
////        
////        var tmpNoteNumberLetters = [String: [Int]]()
////        var tmpAreaOfInterest = [String: [Int]]()
////        
////        for track in setInfoModel.setSettings.tracks {
////            let clips = track.value.midiGroup
////            tmpNoteNumberLetters[track.value.trackId] = Array(0..<clips.count)
////            .map{track.value.midiGroup[$0]}
////            
////            for part in track.value.parts {
////                tmpAreaOfInterest[part.value.partId] = part.value.areaOfInterest
////            }
////        }
////        _noteNumbersPerTrack = State(initialValue: tmpNoteNumberLetters)
////        _areaOfInterest = State(initialValue: tmpAreaOfInterest)
////    }
//    
//    var body: some View {
//
//        VStack(alignment: .leading) {
//            
//            //Create a clickable row header per track
//            ForEach(setInfoModel.setSettings.tracks.keys, id: \.self) { key in
//                
//                let track = setInfoModel.setSettings.tracks[key]!
//                let editorPart = EditorParts(rawValue: "track\(track.trackIndex)")
//                
//                //Track navigation header
//                HStack{
//                    Group{
//                        Image("track")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30)
//                            .padding(4)
//                            .overlay(RoundedRectangle(cornerRadius: 8.0).stroke(.white))
//                    }
//                    .padding(.leading)
//
//                    Text("Track \(track.trackName)")
//                        .font(.system(size: 20))
//                        .padding()
//                    
//                    Spacer()
//                    
//                    VStack(alignment: .trailing){
//                        Text(track.startType.description)
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                        Text(track.noteSource.description)
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                        Text(track.variationType.description)
//                            .font(.system(size: 14))
//                            .foregroundColor(.gray)
//                    }
//                    .padding(.trailing)
//                }
//                .onTapGesture {
//                    withAnimation {
//                        if showEditorPart != editorPart {
//                            showEditorPart = editorPart ?? .none
////                            variationTypes[key] = setInfoModel.setSettings.tracks[key]!.variationType
//                        } else {
//                            showEditorPart = .none
//                        }
//                    }
//                }
//                
//                
//                //If editor parts is selected OR If navigation header is tapped
//                if showEditorPart == editorPart || showEditorPart == .levels {
//                    
//                    InLevelView(
//                        setInfoModel: setInfoModel,
//                        currentTrack: setInfoModel.setSettings.tracks[key]!,
//                        trackId: key
//                    )
//                    
//                }
//                if showEditorPart == editorPart || showEditorPart == .source {
//                    
//                    //Source of notes
//                    NoteSourceView(
//                        setInfoModel: setInfoModel,
//                        currentTrack: setInfoModel.setSettings.tracks[key]!,
//                        trackId: key,
//                        noteSources: $noteSources
//                    )
//                }
//                if showEditorPart == editorPart || showEditorPart == .start {
//                    //Start type
//                    StartTypeView(
//                        setInfoModel: setInfoModel,
//                        currentTrack: setInfoModel.setSettings.tracks[key]!,
//                        trackId: key
//                    )
//                }
//                if showEditorPart == editorPart || showEditorPart == .variation {
//                    
//                    //Variation type (position, level)
//                    VariationTypeView(
//                        setInfoModel: setInfoModel,
//                        currentTrack: setInfoModel.setSettings.tracks[key]!,
//                        trackId: key,
//                        variationTypes: $variationTypes
//                    )
//                    
//                    if variationTypes[key] == .variationByLevel {
//                        
//                        if noteSources[key] == .midiFile {
//                            LoopsToLevelView(
//                                setInfoModel: setInfoModel,
//                                currentTrack: setInfoModel.setSettings.tracks[key]!,
//                                trackId: key,
//                                clipLetters: $midiClipLetters
//                            )
//                        }
//                        else if noteSources[key] == .noteNumbers {
//                            NoteNumberToLevelView(
//                                setInfoModel: setInfoModel,
//                                currentTrack: setInfoModel.setSettings.tracks[key]!,
//                                trackId: key,
//                                noteNumbersPerTrack: $noteNumbersPerTrack
//                            )
//                        }
//                    }
//                    
//                    else if variationTypeLocal[key] == .variationByPosition {
//                        
//                        if noteSourceLocal[key] == .midiFile {
//                            LoopsToGridView(
//                                setInfoModel: setInfoModel,
//                                currentTrack: setInfoModel.setSettings.tracks[key]!,
//                                trackId: key,
//                                clipLetters: $midiClipLetters
//                            )
//                        }
//                        else if noteSourceLocal[key] == .noteNumbers {
//                            
//                            NoteNumberToGridView(
//                                setInfoModel: setInfoModel,
//                                currentTrack: setInfoModel.setSettings.tracks[key]!,
//                                trackId: key,
//                                noteNumbersPerTrack: $noteNumbersPerTrack
//                            )
//                        }
//                    }
//                    
//                    else if variationTypeLocal[key] == .variationSequencial {
//                        
//                        if noteSourceLocal[key] == .midiFile {
//                            Text("Currently note number only feature")
//                                .padding(.leading)
//                        }
//                        else if noteSourceLocal[key] == .noteNumbers {
//                            NoteNumberSequenceView(
//                                setInfoModel: setInfoModel,
//                                currentTrack: setInfoModel.setSettings.tracks[key]!,
//                                trackId: key,
//                                noteNumbersPerTrack: $noteNumbersPerTrack
//                            )
//                        }
//                    }
//                    
//                    
//                    //Sampler files
////                    if noteSourceLocal[key] == .midiFile {
////                        SamplerFilesView(
////                            setInfoModel: setInfoModel,
////                            currentTrack: setInfoModel.setSettings.tracks[key]!,
////                            currentTrackSampler: setInfoModel.conductor.trackSamplers[key]!,
////                            trackId: key
//////                            ,
//////                            noteNumbersPerTrack: $noteNumberLetter
////                        )
////                    }
//                }
//                if showEditorPart == editorPart || showEditorPart == .location {
//                    AreaOfInterestView(
//                        setInfoModel: setInfoModel,
//                        currentTrack: setInfoModel.setSettings.tracks[key]!,
//                        trackId: key,
//                        areaOfInterest: $areaOfInterest
//                    )
//                    
//                    //Dampertarget view
//                    
//                    MinimalLevelView(
//                        setInfoModel: setInfoModel,
//                        currentTrack: setInfoModel.setSettings.tracks[key]!,
//                        trackId: key
//                    )
//                }
//                Divider()
//            }
//        }
//    }
//}
