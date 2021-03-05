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
    
    var body: some View {
        //ScrollView {
            List {
                ForEach(plansByBus) { plan in
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
