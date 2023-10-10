import SwiftUI

struct RotaryPhoneView: View {
    @State private var number = ""
    
    @State private var startDegrees: Double = 0.0
    @State private var rotationAngle: Double = 0.0
    @State private var currentAngle: Double = 0.0
    @State private var isMoving: Bool = false
    @State private var permitsMovement: Bool = true
    @State private var showingAlert: Bool = false
    @State private var selectedNum: Int = -1
    
    let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    let haptic = UIImpactFeedbackGenerator(style: .rigid)
    
    
    func calcDegrees(hL: CGFloat, x: CGFloat, y: CGFloat) -> Double {
        let cX = x - hL;
        let cY = -y + hL;
        let t_rad = atan2(cY, cX)
        return (((t_rad / .pi) * 180) + (t_rad > 0 ? 0 : 360))
    }

    func rotationGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                selectedNum = -1
                
                if(!permitsMovement){
                    return;
                }
                // 0,0 is top left, 0, max is bottom left, max, 0 is top right, etc
                //                let len = geometry.size.width
                let hL = 160.0 // len/2;
                let newLoc = value.location
                let startLoc = value.startLocation
                
                if(!isMoving){
                    haptic.impactOccurred(intensity: 0.8)
                    currentAngle = calcDegrees(hL: hL, x: startLoc.x, y: startLoc.y)
                }
                
                let deg = calcDegrees(hL: hL, x: newLoc.x, y: newLoc.y)
                //                print(deg)
                
                
                print(currentAngle - deg)
                if(isMoving && deg >= 318.0 && deg <= 349.0){
                    haptic.impactOccurred(intensity: 1.0)
                    permitsMovement = false;
                    print("hit")
                } else {
                    rotationAngle = currentAngle - deg
                    isMoving = true;
                }
                
                
            }
            .onEnded { _ in
                isMoving = false;
                permitsMovement = true;
                currentAngle = rotationAngle
                print("Gesture ended. Rotation angle: \(rotationAngle)")
                
                if(rotationAngle > -20 || rotationAngle < -345){
                }
                else {
                    let estNum = 11.0 - ((abs(rotationAngle) - 20.0) / 32.5)
                    let actualNum = Int(estNum)
                    selectedNum = actualNum
                }
                
                showingAlert = true
                withAnimation(.snappy()){
                    if(rotationAngle < -10){
                        rotationAngle = -360
                    }
                    //rotationAngle = abs(rotationAngle)
                }
                if(rotationAngle == -360){
                    rotationAngle = 0;
                } else {
                    withAnimation(.snappy()){
                        rotationAngle = 0
                    }
                }
            }
    }
    
    
    private var staticOverlay: some View {
        Image("Static Overlay")
            .resizable()
            .renderingMode(.original)
            .aspectRatio(contentMode: .fit)
            .padding(.leading, 70)
            .frame(width: 324)
            .allowsHitTesting(false)
    }

    var body: some View {
        VStack {
            Text("Dial a number!")
                    .font(.headline)
            ZStack {
                
                Image("Bottom Static")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()

                
                GeometryReader() { geom in
                    
                    
                    Image("Rotary")
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(rotationAngle))
                        .gesture(rotationGesture(geometry: geom))
                        .overlay(staticOverlay)
                        .frame(width: 320, height: 320)
                        .offset(x: 46, y: 40)
                
                    
                        
                }.aspectRatio(contentMode: .fit)
                
            }
        }.alert(selectedNum != -1 ? "You dialed a " + String(selectedNum == 10 ? 0 : selectedNum) + "!" : "Oops! Something went wrong!", isPresented: $showingAlert, actions: {})
    }
}


@main
struct rotaryApp: App {
    var body: some Scene {
        WindowGroup {
            RotaryPhoneView()
        }
    }
}
