//
//  ContentView.swift
//  pomodoro-timer
//
//  Created by Adelina C on 7/3/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var receiver = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    @State var second: Double = 0
    @State var countdown: Double = 0
    @State var status: String = "Start"
    @State var section: Int = 1
    @State var colors = [Color](repeating: .red, count: 8)
    @State var phase: String = "Pomodoro Timer"
    @State var showPopUp = false
    
    var rectHeight: CGFloat = 15
    var rectWidthOffset: CGFloat = 75
    var rectWidthMult: CGFloat = 8
    
    var body: some View {
        ZStack {
            VStack {
                HStack { // Creates colored status bar
                    ForEach(0..<8) {i in
                        Rectangle()
                            .fill(colors[i])
                            .opacity(0.8)
                            .frame(width: (UIScreen.main.bounds.width - rectWidthOffset) / rectWidthMult, height: rectHeight, alignment: .center)
                    }
                }
                Spacer()
                Text(phase) // Shows the phase
                    .font(.system(size: 40))
                Spacer()
                ZStack { // Creates clock face
                    Circle()
                        .fill(Color.primary)
                        .opacity(0.2)
                        .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.width/1.2, alignment: .center)
                    ForEach(0..<60) {i in
                        Rectangle()
                            .fill(Color.primary)
                            .opacity(0.8)
                            .frame(width: 2, height: i % 5 == 0 ? 15 : 5)
                            .offset(x: 0, y: -UIScreen.main.bounds.width/2.5)
                            .rotationEffect(Angle(degrees: Double(6*i)))
                    }
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 3, height: UIScreen.main.bounds.width/2.9)
                        .offset(x: 0, y: -UIScreen.main.bounds.width/5.8)
                        .rotationEffect(Angle(degrees: Double(6*second)))
                }
                Spacer()
                .onAppear() { // Sets initial countdown and phase
                    countdown = Double(getTimeSegment(section: section).rawValue) * 60
                    phase = "Pomodoro Timer"
                }
                .onReceive(receiver, perform: { _ in // Updates the countdown and timer based on current section
                    if countdown > 0 && status == "Stop"{
                        withAnimation(Animation.linear(duration: 0.01)) {
                            second += 1
                            if second == 60 {
                                second = 0
                            }
                        }
                        countdown -= 1
                    }
                    if countdown == 0 {
                        if section == 8 {
                            self.showPopUp = true
                        }
                        status = "Start"
                    }
                })
                Text(getFormattedTime(iseconds: countdown)) // Shows the formatted time
                    .font(.system(size: 50))
                Spacer()
                Button(action: toggle) { // Start/Stop button
                    Text(status)
                        .font(.system(size: 20))
                }
                Button(action: { // Reset button
                    reset()
                }, label: {
                    Text("Reset")
                        .font(.system(size: 20))
                })
            }
            if showPopUp == true { // Shows the completion screen
                ZStack {
                    Color.white
                    VStack {
                        Spacer()
                        Text("Congrats! It's over!")
                            .font(.system(size: 30))
                        Spacer()
                        Button(action: {
                            reset()
                            self.showPopUp = false
                        }, label: {
                            Text("Start Another Cycle")
                        })
                    }.padding()
                }
                .frame(width: UIScreen.main.bounds.width / 1.2, height: UIScreen.main.bounds.height / 1.9, alignment: .center)
                .cornerRadius(20).shadow(radius: 20)
            }
        }.padding()
    }
    func getFormattedTime(iseconds: Double) -> String { // Gets the time based on seconds into a string
        let minutes: Int = Int(floor(iseconds/60))
        let seconds: Int = Int(Int(iseconds) % 60)
        
        return String(minutes) + ":" + ((seconds < 10) ? "0" : "") + String(seconds)
    }
    func toggle() { // Things that happen when start/stop button is pressed
        if status == "Start" {
            changeLabel(section: section)
            if countdown == 0 {
                if section != 8 { // Keep increasing section until it is at the last one
                    section += 1
                }
                second = 0
                countdown = Double(getTimeSegment(section: section).rawValue) * 60
            }
            colors[section - 1] = .green // Changes each color status bar to green
            status = "Stop"
        } else {
            status = "Start"
        }
    }
    func resetColors() { // Changes the color status bar back to red
        for i in (0..<8) {
            colors[i] = .red
        }
    }
    func changeLabel(section: Int) { // Returns the phase based on section
        if (section % 2 != 0) {
            phase = "Work Time"
        } else if (section == 8) {
            phase = "Long Break"
        } else {
            phase = "Short Break"
        }
    }
    func getTimeSegment(section: Int) -> Sections { // Keeps track of which time segment it is on and returns the corresponding time
        if (section % 2 != 0) {
            return .work
        } else if (section == 8) {
            return .long_break
        } else {
            return .short_break
        }
    }
    func reset() { // Resets the time, Start button, section, countdown, phase, and colors
        second = 0
        status = "Start"
        section = 1
        countdown = Double(getTimeSegment(section: section).rawValue) * 60
        phase = "Pomodoro Timer"
        resetColors()
    }
}
enum Sections: Int { // Keeps the case of the different work sections
    case work = 25
    case short_break = 5
    case long_break = 15
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
