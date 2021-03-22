import SwiftUI

struct SearchAreaView: View {
    @Environment(\.colorScheme) var colorScheme
    // input data
    @State var locations: [Location]
    
    // user selected
    @Binding var startLoc: Location?
    @Binding var endLoc: Location?
    @Binding var planType: PlanType
    
    // part of result
    @Binding var minTimeByBus: Double
    @Binding var minTimeOnFoot: Double
    
    // showing control
    @State var showStartLocList = false
    @State var showEndLocList = false
    @Binding var showing: Bool
    
    // animation for 􀅌
    @State var angle = 0.0
    
    var body: some View {
        VStack {
            // search box
            HStack(spacing: 20) {
                // back button
                
                Image(systemName: "arrowshape.turn.up.left.fill")
                    .onTapGesture { showing.toggle() }
                    .padding(.bottom, 60)
                

                // text field
                VStack {
                    VStack(spacing: 12) {
                        NavigationLink(destination: LocListView(
                                        placeholder: "From",
                                        keyword: startLoc?.nameEn ?? "",
                                        locations: locations,
                                        showCurrent: !(endLoc?.type == LocationType.user),
                                        selectedLoc: $startLoc,
                                        showing: $showStartLocList), isActive: $showStartLocList) {
                            Text(startLoc?.nameEn ?? NSLocalizedString("From", comment: ""))
                                .foregroundColor(startLoc == nil ? .secondary : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                        
                        NavigationLink(destination: LocListView(
                                        placeholder: "To",
                                        keyword: endLoc?.nameEn ?? "",
                                        locations: locations,
                                        showCurrent: !(startLoc?.type == LocationType.user),
                                        selectedLoc: $endLoc,
                                        showing: $showEndLocList), isActive: $showEndLocList) {
                            Text(endLoc?.nameEn ?? NSLocalizedString("To", comment: ""))
                                .foregroundColor(endLoc == nil ? .secondary : .primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                    }
                }
                // switch button
                Image(systemName: "arrow.2.squarepath")
                    .imageScale(.large)
                    .rotationEffect(.degrees(angle))
                    .animation(Animation.easeInOut(duration: 0.1), value: angle)
                    .onTapGesture {
                        angle += 180
                        let tmp = startLoc
                        startLoc = endLoc
                        endLoc = tmp
                    }
            }
            .padding(.top)
            .padding(.horizontal, 20)

            // search mode
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    PlanTypeSelectorView(thisPlanType: .byBus, time: $minTimeByBus, planType: $planType)
                    PlanTypeSelectorView(thisPlanType: .onFoot, time: $minTimeOnFoot, planType: $planType)
                }
                .padding()
            }
        }
        .background(colorScheme == .light ? Color.white : Color.black)
    }
    
    struct PlanTypeSelectorView: View {
        var thisPlanType: PlanType
        @Binding var time: Double // s
        @Binding var planType: PlanType
        
        var body: some View {
            HStack {
                thisPlanType.toImage()
                time == .infinity ? nil : Text(String(Int(time / 60)) + " " + NSLocalizedString("mins", comment: ""))
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(planType == thisPlanType ? CU_PURPLE.opacity(0.2) : nil)
            .cornerRadius(20)
            .onTapGesture {
                planType = thisPlanType
            }
        }
    }
}
