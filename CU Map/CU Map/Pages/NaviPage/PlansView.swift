import SwiftUI

struct PlansOnFootView: View {
    @Binding var plansOnFoot: [Plan]
    @Binding var selectedPlan: Plan?
    
    var body: some View {
        //ScrollView {
            List {
                ForEach(plansOnFoot) { plan in
                    Button(action: {
                        selectedPlan = plan
                    }) {
                        Text(String(Int(plan.dist)) + " " + NSLocalizedString("m", comment: ""))
                    }
                }
            }
        //}
    }
}

struct PlansByBusView: View {
    @Binding var plansByBus: [Plan]
    @Binding var selectedPlan: Plan?
    @Binding var searchTime: Date
    
    var body: some View {
        VStack {
            DatePicker("Depart at", selection: $searchTime).padding(.horizontal)
            List {
                ForEach(plansByBus) { plan in
                    PlansByBusItemView(plan: plan, selectedPlan: $selectedPlan)
                }
            }
        }
    }
    
    struct RouteToDisplayInPlan: Identifiable {
        var id = UUID()
        var bus: Bus?
        var time: Int // min
    }
    
    struct PlansByBusItemView: View {
        @State var plan: Plan
        @Binding var selectedPlan: Plan?
        
        var body: some View {
            var routes: [RouteToDisplayInPlan] = []
            for route in plan.routes {
                let thisBus = route.bus
                let thisTime = route.type == .byBus ? Int(route.dist / SPEED_BY_BUS / 60) : Int(route.dist / SPEED_ON_FOOT / 60)
                
                if let lastRoutes = routes.last { // has last item
                    let lastBus = lastRoutes.bus
                    let lastTime = lastRoutes.time
                    if let lastBus = lastBus { // lastBus != nil
                        if let thisBus = thisBus { // thisBus != nil
                            if lastBus.id == thisBus.id {
                                routes.removeLast()
                                routes.append(RouteToDisplayInPlan(bus: thisBus, time: lastTime + thisTime))
                            } else {
                                routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                            }
                        } else { // thisBus == nil
                            routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                        }
                    } else { // lastBus == nil
                        if let thisBus = thisBus { // thisBus != nil
                            routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                        } else { // thisBus == nil
                            routes.removeLast()
                            routes.append(RouteToDisplayInPlan(bus: thisBus, time: lastTime + thisTime))
                        }
                    }
                } else { // routes empty
                    routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                }
            }
            return
                Button(action: {
                    selectedPlan = plan
                }) {
                    HStack {
                        ForEach(routes) { route in
                            HStack(alignment: .bottom, spacing: 0) {
                                if let bus = route.bus { // by bus
                                    Text(bus.line)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.2)
                                        .frame(width: 18)
                                        .foregroundColor(Color.white)
                                        .padding(6)
                                        .background(BUS_COLORS[bus.line])
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(Color.primary.opacity(0.8))
                                }
                                Text(String(route.time))
                                    .font(.footnote)
                                    .foregroundColor(Color.secondary)
                            }
                            if route.id != routes.last?.id {
                                Image(systemName: "chevron.right")
                            }
                        }
                        Spacer()
                        HStack {
                            Text("\(Int(plan.time)) mins")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
        }
    }
}


