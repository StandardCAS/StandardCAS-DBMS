import SwiftUI

#if os(iOS)
import UIKit
typealias OSImage = UIImage
#elseif os(macOS)
import AppKit
typealias OSImage = NSImage
#endif



@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
import SwiftUI
import Foundation

import SwiftUI
import Combine

class UserData: ObservableObject {
    @Published var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @Published var id: String = UserDefaults.standard.string(forKey: "id") ?? ""
    @Published var bio: String = UserDefaults.standard.string(forKey: "bio") ?? ""
    @Published var timeSlots = Array(repeating: TimeSlot(), count: 10)
    @Published var calendars = Array(repeating: CalendarSlot(), count: 64)
    let subjects = ["NA","Math","English", "History", "Physics", "Chemistry","Biology","Chinese","IT","Human Geography","Physical Geography","Economics","Drama","Art","Music","P8 Training","P8 Club","P8 IT H+","P8 Other"]
    let levels = ["Non Native", "Standard", "Standard Plus", "Honors", "Honors Plus","AP","IB"]
    let weights = [0,6,6,5,4,4,4,3,4,4,4,4,4,4,4]
    let bonus = [0,0,1,2,3,4,5]
    let time = ["08:30-09:30","09:40-10:20","10:30-11:10","11:20-12:10","13:10-14:10","14:20-15:00","15:10-15:50","16:00-17:00"]
    func save() {
        if let data = try? JSONEncoder().encode(timeSlots) {
            UserDefaults.standard.set(data, forKey: "TimeSlots")
        }
        if let data2 = try? JSONEncoder().encode(calendars) {
            UserDefaults.standard.set(data2, forKey: "CalendarSlot")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "TimeSlots"),
           let decodedTimeSlots = try? JSONDecoder().decode([TimeSlot].self, from: data) {
            timeSlots = decodedTimeSlots
        }
        if let data2 = UserDefaults.standard.data(forKey: "CalendarSlot"),
           let decodedCalendarSlots = try? JSONDecoder().decode([CalendarSlot].self, from: data2) {
            calendars = decodedCalendarSlots
        }
    }

    func load2(){
        if let data2 = UserDefaults.standard.data(forKey: "TimeSlots"),
           let decodedCalendarSlots = try? JSONDecoder().decode([CalendarSlot].self, from: data2) {
            calendars = decodedCalendarSlots
        }
    }
}

struct QueryView: View {
    @StateObject private var userData = UserData()

    var body: some View {
        NavigationView {
            VStack {
                Text("StandardCAS™ Database Search")
                    .font(.system(size:36))
                    .bold()
                TextField("Username", text: $userData.username)
                    .padding()
                    .border(Color.gray)
                TextField("Code", text: $userData.id)
                    .padding()
                    .border(Color.gray)
                NavigationLink(destination: DataTableView(username: userData.username, id:userData.id)) {
                    Text("Submit")
                        .font(.title)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}


struct Row: Identifiable {
    var id = UUID()
    var user: String
    var code: String
    var data: String
    var timing: Int
    var proof: String
}


struct DataTableView: View {
    var username: String
    var id: String

    @State private var rows: [Row] = []

    func loadData() {
        // Assuming that "Contribution.csv" is in the app's main bundle.
        if let url = Bundle.main.url(forResource: "Contribution", withExtension: "csv"),
           let content = try? String(contentsOf: url) {
            // Split the file into lines.
            let lines = content.components(separatedBy: "\n")
            // Skip the first line (header).
            for line in lines.dropFirst() {
                // If the line is empty, skip it.
                if line.isEmpty {
                    continue
                }
                print(line)
                // Split the line into columns.
                var columns = line.components(separatedBy: ",")
                print(columns[2],columns.count)
                // Check if the username and ID match.
                if columns[0] == username && columns[1] == id {
                    // Create a new Row and add it to the 'rows' array.
                    if let timing = Int(columns[3]) {
                        let row = Row(user: columns[0], code: columns[1], data: columns[2], timing: timing, proof: columns[4])
                        rows.append(row)
                    }
                    
                }
            }
            print(rows)
        }
    }



    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text("User").bold()
                            .frame(width: geometry.size.width / 6, alignment: .center)
                            .font(.system(size:geometry.size.width/30))
                        Text("Code").bold()
                            .frame(width: geometry.size.width / 6, alignment: .center)
                            .font(.system(size:geometry.size.width/30))
                        Text("Data").bold()
                            .frame(width: geometry.size.width / 6, alignment: .center)
                            .font(.system(size:geometry.size.width/30))
                        Text("Timing").bold()
                            .frame(width: geometry.size.width / 6, alignment: .center)
                            .font(.system(size:geometry.size.width/30))
                        Text("Proof").bold()
                            .frame(width: geometry.size.width / 6, alignment: .center)
                            .font(.system(size:geometry.size.width/30))
                    }
                    ForEach(rows) { row in
                        Divider()
                        HStack {
                            Text(row.user)
                                .frame(width: geometry.size.width / 6, alignment: .center)
                                .font(.system(size:geometry.size.width/30))
                            Text(row.code)
                                .frame(width: geometry.size.width / 6, alignment: .center)
                                .font(.system(size:geometry.size.width/30))
                            Text(row.data)
                                .frame(width: geometry.size.width / 6, alignment: .center)
                                .font(.system(size:geometry.size.width/30))
                            Text("\(row.timing)")
                                .frame(width: geometry.size.width / 6, alignment: .center)
                                .font(.system(size:geometry.size.width/30))
                            Text(row.proof)
                                .frame(width: geometry.size.width / 6, alignment: .center)
                                .font(.system(size:geometry.size.width/30))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(username) (\(id))'s Data")
            .onAppear(perform: loadData)
        }

    }
}


import SwiftUI
import UIKit

struct AddView: View {
    @State private var selectedImage: Image?
    @State private var isImagePickerPresented = false

    var body: some View {
        VStack {
            Text("This is the Add page.")
            Button("Select Image") {
                isImagePickerPresented = true
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            if let image = selectedImage {
                image
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}




struct AddView_Previews: PreviewProvider {
    static var previews: some View {
        AddView()
    }
}



import SwiftUI

// Global variables
var globalusername: String = ""
var globalid: String = ""
/*
struct UserView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedin: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Username", text: $username)
                    .padding()
                    .border(Color.gray, width: 0.5)
                SecureField("Password", text: $password)
                    .padding()
                    .border(Color.gray, width: 0.5)
                Button(action: {
                    // Perform login operation here
                    // If login is successful, update the global variables and set isLoggedin to true
                    globalusername = username
                    globalid = "12345"  // Replace with actual id
                    isLoggedin = true
                }) {
                    Text("Login")
                }
                NavigationLink(destination: ProfileView(), isActive: $isLoggedin) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}
*/

import SwiftUI
#if os(iOS)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
#endif

//UserView Section
import SwiftUI

import SwiftUI
import SwiftUI
#if os(iOS)
struct iOSUserView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    @State private var bio: String = UserDefaults.standard.string(forKey: "bio") ?? "This is the Bio"
    @State private var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "username") != nil && UserDefaults.standard.string(forKey: "password") != nil
    @State private var isEditingBio: Bool = false
    @State private var selectedImage = UIImage(systemName: "person")
    @State private var isImagePickerDisplayed = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: { self.isImagePickerDisplayed = true }) {
                        Image(uiImage: selectedImage ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $isImagePickerDisplayed) {
                        Image(systemName: "person")
                    }
                    VStack(alignment: .leading) {
                        Text(username)
                            .font(.system(size:geometry.size.width/20))
                        if isEditingBio {
                            TextEditor(text: $bio)
                                .font(.system(size:geometry.size.width/20))
                                .frame(width:geometry.size.width/2, height:geometry.size.height/5)
                                .onTapGesture { }
                        } else {
                            Text(bio)
                                .font(.system(size:geometry.size.width/20))
                                .onTapGesture { self.isEditingBio = true }
                        }
                    }
                }
                .padding()
                
                if !isLoggedIn {
                    TextField("Username", text: $username)
                        .padding()
                        .border(Color.gray)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .border(Color.gray)
                    
                    Button(action: {
                        UserDefaults.standard.set(self.username, forKey: "username")
                        UserDefaults.standard.set(self.password, forKey: "password")
                        self.isLoggedIn = true
                    }) {
                        Text("Save Username and Password")
                            .font(.system(size:geometry.size.width/30))
                    }
                } else {
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "username")
                        UserDefaults.standard.removeObject(forKey: "password")
                        self.username = ""
                        self.password = ""
                        self.bio = "Click to Edit Bio"
                        self.isLoggedIn = false
                    }) {
                        Text("Logout")
                            .font(.system(size:geometry.size.width/30))
                    }
                }
            }
            .onTapGesture {
                if isEditingBio {
                    UserDefaults.standard.set(self.bio, forKey: "bio")
                    self.isEditingBio = false
                }
            }
        }
    }
}
#elseif os(macOS)
struct macOSUserView: View {
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    @State private var bio: String = UserDefaults.standard.string(forKey: "bio") ?? "This is the Bio"
    @State private var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "username") != nil && UserDefaults.standard.string(forKey: "password") != nil
    @State private var isEditingBio: Bool = false
    @State private var selectedImage = "person"
    @State private var isImagePickerDisplayed = false

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Button(action: { self.isImagePickerDisplayed = true }) {
                        Image(selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $isImagePickerDisplayed) {
                        Image(systemName: "person")
                    }
                    VStack(alignment: .leading) {
                        Text(username)
                            .font(.system(size:geometry.size.width/20))
                        if isEditingBio {
                            TextEditor(text: $bio)
                                .font(.system(size:geometry.size.width/20))
                                .frame(width:geometry.size.width/2, height:geometry.size.height/5)
                                .onTapGesture { }
                        } else {
                            Text(bio)
                                .font(.system(size:geometry.size.width/20))
                                .onTapGesture { self.isEditingBio = true }
                        }
                    }
                }
                .padding()
                
                if !isLoggedIn {
                    TextField("Username", text: $username)
                        .padding()
                        .border(Color.gray)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .border(Color.gray)
                    
                    Button(action: {
                        UserDefaults.standard.set(self.username, forKey: "username")
                        UserDefaults.standard.set(self.password, forKey: "password")
                        self.isLoggedIn = true
                    }) {
                        Text("Save Username and Password")
                            .font(.system(size:geometry.size.width/30))
                    }
                } else {
                    Button(action: {
                        UserDefaults.standard.removeObject(forKey: "username")
                        UserDefaults.standard.removeObject(forKey: "password")
                        self.username = ""
                        self.password = ""
                        self.bio = "Click to Edit Bio"
                        self.isLoggedIn = false
                    }) {
                        Text("Logout")
                            .font(.system(size:geometry.size.width/30))
                    }
                }
            }
            .onTapGesture {
                if isEditingBio {
                    UserDefaults.standard.set(self.bio, forKey: "bio")
                    self.isEditingBio = false
                }
            }
        }
    }
}
#endif

struct SchoolCourseView: View {
    @StateObject private var userData = UserData()
    @State private var selectedPage: Int = 0

    var body: some View {
        VStack {
            Picker("Pages", selection: $selectedPage) {
                Text("Level").tag(0)
                Text("Calendar").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedPage == 0 {
                LevelView(userData: userData)
            } else if selectedPage == 1 {
                CalendarView(userData: userData)
            }
        }
    }
}

struct LevelView: View {
    @ObservedObject var userData: UserData

    var body: some View {
        VStack {
            Text("StandardCAS™ Database Search")
                .font(.system(size:12))
                .bold()
            List(userData.timeSlots.indices, id: \.self) { index in
                HStack {
                    Text("Time Slot \(index + 1)")
                        .font(.system(size:12))
                    Spacer()
                    Picker("Subject", selection: $userData.timeSlots[index].subject) {
                        ForEach(userData.subjects, id: \.self) { subject in
                            Text(subject)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                    .font(.system(size: 12))

                    Picker("Level", selection: $userData.timeSlots[index].level) {
                        ForEach(userData.levels, id: \.self) { level in
                            Text(level)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .labelsHidden()
                    .font(.system(size: 12))

                }
            }
            .padding()
            #if os(iOS)
            .navigationBarItems(trailing: Button("Save") {
                userData.save()
            })
            #elseif os(macOS)
            .toolbar{
                ToolbarItem(){
                    Button("Save") {
                        userData.save()
                    }
                }
            }
            #endif
        }
        .onAppear(perform: userData.load)
    }
}

struct CalendarView: View {
    @ObservedObject var userData: UserData
    @State private var scale: CGFloat = 1.0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    ForEach(0..<8) { row in
                        CalendarRowView(userData: userData, row: row)
                    }
                }
                .scaleEffect(scale)
            }
            .padding()
            .gesture(MagnificationGesture()
                .onChanged { value in
                    scale = value
                }
            )
            .navigationBarItems(trailing: Button("Save") {
                userData.save()
            })
        }
    }
}




struct CalendarRowView: View {
    @ObservedObject var userData: UserData
    let row: Int

    var body: some View {
        HStack {
            #if os(macOS)
            Text(userData.time[row])
            ForEach(0..<5) { column in
                ClassPicker(userData: userData, index: row * 8 + column)
                    .frame(width: 100)
            }
            #elseif os(iOS)
            Text(userData.time[row])
                .font(.system(size: 20))
            ForEach(0..<5) { column in
                ClassPicker(userData: userData, index: row * 2 + column)
                    Spacer()
                    .labelsHidden() // Hide the editing symbol
            }
            #endif
        }
    }
}


struct ClassPicker: View {
    @ObservedObject var userData: UserData
    let index: Int
    var body: some View {
        Picker("",selection: $userData.calendars[index].subject) {
            ForEach(userData.subjects, id: \.self) { subject in
                Text(subject)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}


struct TimeSlot: Codable {
    var subject = "Math"
    var level = "Honors"
}
struct CalendarSlot: Codable {
    var subject = "Math"
}


struct ContentView: View {
    var body: some View {
        TabView {
            QueryView()
                .tabItem {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Query")
                    }
                }
            AddView()
                .tabItem {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                }
            SchoolCourseView()
                .tabItem {
                    HStack {
                        Image(systemName: "building")
                        Text("SC View")
                    }
                }
                #if os(iOS)
                iOSUserView()
                    .tabItem {
                        HStack {
                            Image(systemName: "person")
                            Text("User")
                        }
                    }
                #elseif os(macOS)
                macOSUserView()
                    .tabItem {
                        HStack {
                            Image(systemName: "person")
                            Text("User")
                        }
                    }
                #endif
            
            
        }
        .font(.largeTitle)
    }
}

