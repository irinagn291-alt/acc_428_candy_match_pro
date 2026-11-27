import SwiftUI
import UserNotifications

let cqInk=Color(red:0.29,green:0.17,blue:0.37)
let cqPink=Color(red:1,green:0.48,blue:0.67)
let cqLilac=Color(red:0.78,green:0.49,blue:1)
let cqPaper=Color(red:1,green:0.965,blue:0.985)

@main struct FvPetal:App {
 @UIApplicationDelegateAdaptor(FvBridge.self) var b
 @StateObject var j=JqPulse();@Environment(\.scenePhase) var phase
 var body:some Scene {WindowGroup{root.environmentObject(j).tint(cqInk).preferredColorScheme(.light).onOpenURL{url in if url.scheme=="petal174",url.host=="daily" {j.open(.daily())}}.onReceive(NotificationCenter.default.publisher(for:Notification.Name("petal-open"))){_ in j.open(.daily())}.onChange(of:phase){_,v in if v == .active{j.foreground()}}}}
 @ViewBuilder private var root: some View {
  #if DEBUG
  if let index = CandyCapture.index {
   switch index {
   case 0: FvMap()
   case 1, 4: FvBoard()
   case 2: FvSeason()
   case 3: FvSkins()
   default: FvProfile()
   }
  } else { FvRoot() }
  #else
  FvRoot()
  #endif
 }
}
#if DEBUG
@MainActor enum CandyCapture {
 static var index: Int? {
  let process = ProcessInfo.processInfo
  let args = process.arguments
  guard args.contains("-AppStoreScreenshots") || process.environment["APPSTORE_SCREENSHOTS"] == "1" else { return nil }
  var value = process.environment["APPSTORE_SCREENSHOT_SCREEN"].flatMap(Int.init) ?? 0
  if let flag = args.firstIndex(of: "-AppStoreScreenshotScreen"), flag + 1 < args.count {
   value = Int(args[flag + 1]) ?? 0
  }
  return (0...5).contains(value) ? value : nil
 }
 static func populate(_ game: JqPulse, screen: Int) {
  game.alertsOn = false
  game.sound = false
  for n in 1...23 { game.p.results[Lq.level(n).id] = Rq(stars: 2 + n % 2, score: 1600 + n * 43) }
  for n in 1...7 { game.p.results[Lq.season(n).id] = Rq(stars: 1 + n % 3, score: 1950 + n * 70) }
  for offset in 0..<22 where ![9,12,17].contains(offset) {
   if let date = Nq.cal.date(byAdding: .day, value: -offset, to: Date()) {
    game.p.results[Lq.daily(Nq.day(date)).id] = Rq(stars: 2, score: 1980)
   }
  }
  game.p.skin = 2
  if screen == 1 || screen == 4 {
   var board = Bq(screen == 1 ? .daily() : .level(24))
   for _ in 0..<5 {
    guard !board.done, let move = board.hint() else { break }
    _ = board.swap(move[0],move[1])
   }
   if screen == 4 {
    // Earn the finished screen with legal moves and the game's actual scoring rules.
    while !board.done {
     guard let move = board.hint() else { break }
     _ = board.swap(move[0], move[1])
    }
   }
   game.board = board
  }
 }
}
#endif
final class FvBridge:NSObject,UIApplicationDelegate,UNUserNotificationCenterDelegate {
 func application(_ application:UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey:Any]?=nil)->Bool {UNUserNotificationCenter.current().delegate=self;return true}
 func userNotificationCenter(_ center:UNUserNotificationCenter,didReceive response:UNNotificationResponse,withCompletionHandler completionHandler:@escaping()->Void) {DispatchQueue.main.async{NotificationCenter.default.post(name:Notification.Name("petal-open"),object:nil)};completionHandler()}
}
struct FvRoot:View {
 @EnvironmentObject var j:JqPulse
 var body:some View {TabView(selection:$j.page){FvMap().tabItem{Label(T("Journey"),systemImage:"map.fill")}.tag(0);FvSkins().tabItem{Label(T("Collection"),systemImage:"sparkles")}.tag(1);FvProfile().tabItem{Label(T("You"),systemImage:"person.crop.circle.fill")}.tag(2)}.foregroundStyle(cqInk).fullScreenCover(isPresented:Binding(get:{j.board != nil},set:{if !$0, j.board != nil {DispatchQueue.main.async {j.remember();j.board=nil}}})){FvBoard().environmentObject(j)}.alert(T("Candy Match"),isPresented:Binding(get:{!j.message.isEmpty && j.board == nil},set:{value in if !value {let old=j.message;DispatchQueue.main.async {if j.message==old {j.message=""}}}})){Button(T("OK")){}}message:{Text(j.message)}}
}
struct FvHeading:View {var title:String;var sub:String;var body:some View{VStack(alignment:.leading,spacing:5){Text(T(title)).font(.system(size:34,weight:.heavy,design:.rounded));Text(T(sub)).font(.subheadline).foregroundStyle(cqInk.opacity(0.7))}.frame(maxWidth:.infinity,alignment:.leading)}}
struct FvPill:View {var icon:String;var text:String;var body:some View{Label(text,systemImage:icon).font(.system(.subheadline,design:.rounded,weight:.bold)).padding(.horizontal,13).padding(.vertical,9).background(.white.opacity(0.85),in:Capsule())}}
struct FvMap:View {
 @EnvironmentObject var j:JqPulse;@State var chapter=0;@State var season=false
 var body:some View {NavigationStack{ScrollView{VStack(alignment:.leading,spacing:23){
 HStack(alignment:.top){FvHeading(title:"Candy Match",sub:"A sweet little adventure");FvPill(icon:"star.fill",text:"\(j.p.stars)")}
 Button{j.open(.daily())}label:{HStack(spacing:14){VStack(alignment:.leading,spacing:10){Text(T("DAILY CHALLENGE")).font(.system(.caption,design:.rounded,weight:.black)).tracking(1.4);Text(T("A fresh puzzle.\nA little joy.")).font(.system(size:27,weight:.heavy,design:.rounded)).multilineTextAlignment(.leading);HStack{Label(T("Play today"),systemImage:"play.fill");Spacer();Image(systemName:"arrow.right")}.font(.system(.subheadline,design:.rounded,weight:.bold))};Spacer(minLength:0);FvSweet(v:1,skin:j.p.skin).frame(width:88,height:108).rotationEffect(.degrees(12))}.foregroundStyle(cqInk).padding(23).background(LinearGradient(colors:[Color(red:1,green:0.8,blue:0.88),Color(red:0.9,green:0.78,blue:1)],startPoint:.topLeading,endPoint:.bottomTrailing),in:RoundedRectangle(cornerRadius:29)).overlay(alignment:.topTrailing){if j.p.days.contains(Nq.day()){Image(systemName:"checkmark.seal.fill").font(.title2).padding(13)}}}.buttonStyle(.plain).accessibilityIdentifier("daily")
 HStack{FvPill(icon:"flame.fill",text:"\(j.p.streak) "+qz8(j.p.streak,"day streak"));FvPill(icon:"checkmark.circle.fill",text:"\(j.p.campaignDone) / 160");Spacer(minLength:0)}
 HStack{Text(T("Your journey")).font(.system(.title2,design:.rounded,weight:.heavy));Spacer();Text(T("Chapter")+" \(chapter+1) / 10").font(.subheadline)}
 HStack{Button{chapter=max(0,chapter-1)}label:{Image(systemName:"chevron.left").frame(width:44,height:44)}.disabled(chapter==0);Spacer();Text(T(["Jelly Garden","Peach Meadow","Lilac Lane","Berry Grove","Sugar Clouds","Citrus Valley","Velvet Orchard","Twilight Treats","Starry Sweets","Candy Summit"][chapter])).font(.system(.headline,design:.rounded));Spacer();Button{chapter=min(9,chapter+1)}label:{Image(systemName:"chevron.right").frame(width:44,height:44)}.disabled(chapter==9)}.background(.white,in:Capsule())
 VStack(spacing:22){ForEach(0..<4,id:\.self){row in HStack(spacing:0){ForEach(0..<4,id:\.self){col in let n=chapter*16+row*4+(row%2==0 ? col:3-col)+1;let s=j.p.results["c\(n)"]?.stars ?? 0;let locked=n>j.p.unlocked
 Button{if locked{j.message=T("Complete the previous level to open this one")}else{j.open(.level(n))}}label:{VStack(spacing:6){ZStack{Circle().fill((locked ? Color.white.opacity(0.7):n==j.p.unlocked ? cqPink:cqLilac).gradient).frame(width:58,height:58).shadow(color:cqLilac.opacity(0.18),radius:5,y:4);if locked{Image(systemName:"lock.fill").font(.headline).foregroundStyle(cqInk.opacity(0.4))}else{Text("\(n)").font(.system(.title3,design:.rounded,weight:.heavy)).foregroundStyle(cqInk)}};HStack(spacing:2){ForEach(1...3,id:\.self){i in Image(systemName:i<=s ? "star.fill":"star").font(.system(size:10,weight:.bold)).foregroundStyle(i<=s ? cqInk:cqInk.opacity(0.22))}}}.frame(maxWidth:.infinity)}.buttonStyle(.plain).accessibilityLabel(T("Level")+" \(n), \(s) "+T("stars")+(locked ? ", "+T("Locked"):"")).accessibilityIdentifier("level-\(n)")}}}}.padding(.vertical,24).padding(.horizontal,8).background(Color(red:1,green:0.88,blue:0.93),in:RoundedRectangle(cornerRadius:28))
 Button{season=true}label:{HStack(spacing:15){Image(systemName:"leaf.fill").font(.largeTitle).foregroundStyle(cqLilac);VStack(alignment:.leading,spacing:4){Text(T("Seasonal collection")).font(.headline);Text(T("12 new puzzles every month")).font(.subheadline)};Spacer();Image(systemName:"arrow.right")}.padding(21).background(.white,in:RoundedRectangle(cornerRadius:24))}.buttonStyle(.plain).accessibilityIdentifier("season")
 Text(T("No lives to wait for. Play at your own pace.")).font(.footnote).frame(maxWidth:.infinity).foregroundStyle(cqInk.opacity(0.6))
 }.padding(22).frame(maxWidth:750).frame(maxWidth:.infinity)}.background(cqPaper).toolbar(.hidden,for:.navigationBar).sheet(isPresented:$season){FvSeason().environmentObject(j)}.onAppear{chapter=min(9,(j.p.unlocked-1)/16)}}}
}
struct FvSeason:View {
 @EnvironmentObject var j:JqPulse;@Environment(\.dismiss) var dismiss
 var body:some View{NavigationStack{ScrollView{VStack(alignment:.leading,spacing:22){FvHeading(title:"Seasonal collection",sub:"Twelve puzzles, a fresh start each month");Text(Nq.z9(Nq.day(),"MMMM yyyy")).font(.title2.bold());LazyVGrid(columns:[GridItem(.adaptive(minimum:100))],spacing:18){ForEach(1...12,id:\.self){n in Button{dismiss();DispatchQueue.main.asyncAfter(deadline:.now()+0.35){j.open(.season(n))}}label:{VStack(spacing:12){FvSweet(v:n%6,skin:j.p.skin).frame(width:48,height:48);Text(T("Puzzle")+" \(n)").font(.headline);Text(String(repeating:"★",count:j.p.results[Lq.season(n).id]?.stars ?? 0)).font(.caption)}.frame(maxWidth:.infinity,minHeight:120).background(.white,in:RoundedRectangle(cornerRadius:20))}.buttonStyle(.plain)}};Text(T("Seasonal progress is saved. The set changes on the first day of each month, using UTC.")).font(.footnote)}.padding(24)}.background(cqPaper).toolbar{Button(T("Done")){dismiss()}}}}
}
struct FvSkins:View {
 @EnvironmentObject var j:JqPulse
 let names=["Jelly Original","Orchard Picnic","Moonlight Candy","Peach Sorbet"]
 var body:some View{NavigationStack{ScrollView{VStack(alignment:.leading,spacing:24){FvHeading(title:"Your candy collection",sub:"A new look for every little milestone");FvPill(icon:"star.fill",text:"\(j.p.stars) "+qz8(j.p.stars,"stars collected"));Text(T("Collect stars to unlock new looks. Your stars stay with you.")).font(.subheadline);LazyVGrid(columns:[GridItem(.adaptive(minimum:260))],spacing:18){ForEach(0..<4,id:\.self){k in let threshold=[0,15,40,80][k];let ready=j.p.stars>=threshold;Button{j.choose(k)}label:{VStack(alignment:.leading,spacing:15){HStack(spacing:8){ForEach(0..<4,id:\.self){v in FvSweet(v:v,skin:k).frame(maxWidth:.infinity).frame(height:51)}}.padding(.vertical,12);HStack{VStack(alignment:.leading,spacing:4){Text(T(names[k])).font(.system(.headline,design:.rounded));Text(j.p.skin==k ? T("Selected"):ready ? T("Use this look"):"\(threshold) "+T("stars to unlock")).font(.caption)};Spacer();Image(systemName:j.p.skin==k ? "checkmark.circle.fill":ready ? "circle":"lock.fill")}}.foregroundStyle(cqInk).padding(21).background(.white,in:RoundedRectangle(cornerRadius:24)).overlay(RoundedRectangle(cornerRadius:24).stroke(j.p.skin==k ? cqLilac:.clear,lineWidth:3))}.buttonStyle(.plain).disabled(!ready).accessibilityIdentifier("skin-\(k)")}}}.padding(24).frame(maxWidth:850).frame(maxWidth:.infinity)}.background(cqPaper).toolbar(.hidden,for:.navigationBar)}}
}
struct FvProfile:View {
 @EnvironmentObject var j:JqPulse;@State var widgets=false;@State var help=false
 var body:some View{NavigationStack{ScrollView{VStack(alignment:.leading,spacing:24){FvHeading(title:"Your little wins",sub:"Every puzzle is a moment for you");HStack{FvStat(value:"\(j.p.streak)",label:"day streak",icon:"flame.fill");FvStat(value:"\(j.p.stars)",label:"stars",icon:"star.fill");FvStat(value:"\(j.p.campaignDone)",label:"levels",icon:"checkmark.circle.fill")};FvCalendar(days:j.p.days)
 VStack(alignment:.leading,spacing:16){Text(T("Make it yours")).font(.title2.bold());Toggle(T("Gentle touch feedback"),isOn:Binding(get:{j.sound},set:{j.sound=$0;UserDefaults.standard.set($0,forKey:"petal-touch")}));Divider();Text(T("Daily reminders")).font(.headline);Text(T("Choose a gentle morning invitation and an evening nudge. Notifications are scheduled on this device; permission is optional.")).font(.subheadline);Toggle(T("Remind me to play"),isOn:Binding(get:{j.alertsOn},set:{v in Task{await j.reminders(v)}})).accessibilityIdentifier("reminders");Divider();F68eec(encode: j.prepare68eec, apply: j.accept68eec)}.padding(22).background(.white,in:RoundedRectangle(cornerRadius:24))
 HStack{Button{widgets=true}label:{Label(T("Widgets"),systemImage:"square.grid.2x2")};Spacer();Button{help=true}label:{Label(T("How to play"),systemImage:"questionmark.circle")}}.font(.headline).padding(20).background(.white,in:RoundedRectangle(cornerRadius:22))
 VStack(alignment:.leading,spacing:9){Text(T("Private by design")).font(.headline);Text(T("Your progress stays on this device. Export a file to share results or import an earlier copy. Unfinished boards stay on the device where you started them.")).font(.footnote);Text(T("Daily challenges reset at midnight UTC. Reminders follow your device's local time.")).font(.footnote)}.foregroundStyle(cqInk.opacity(0.75));Text("Candy Match · " + (Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String ?? "")).font(.caption).frame(maxWidth:.infinity)
 }.padding(24).frame(maxWidth:750).frame(maxWidth:.infinity)}.background(cqPaper).toolbar(.hidden,for:.navigationBar).sheet(isPresented:$widgets){FvWidgets()}.sheet(isPresented:$help){FvHelp()}}}
}
struct FvStat:View{var value:String;var label:String;var icon:String;var body:some View{VStack(spacing:8){Image(systemName:icon).foregroundStyle(cqLilac);Text(value).font(.system(.title,design:.rounded,weight:.heavy));Text(label=="day streak" ? qz8(Int(value) ?? 0,label):T(label)).font(.caption)}.frame(maxWidth:.infinity).padding(.vertical,19).background(.white,in:RoundedRectangle(cornerRadius:21))}}
struct FvCalendar:View {
 var days:Set<String>
 var body:some View{let today=Nq.date(Nq.day());let range=Nq.cal.range(of:.day,in:.month,for:today)!;let first=Nq.cal.date(from:Nq.cal.dateComponents([.year,.month],from:today))!;let shift=(Nq.cal.component(.weekday,from:first)+5)%7
 VStack(alignment:.leading,spacing:17){Text(Nq.z9(Nq.day(),"MMMM yyyy")).font(.system(.title2,design:.rounded,weight:.bold));LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:7),spacing:9){ForEach(0..<7,id:\.self){i in Text(Nq.cal.veryShortStandaloneWeekdaySymbols[(i+1)%7]).font(.caption.bold()).foregroundStyle(cqInk.opacity(0.5))};ForEach(0..<(range.count+shift),id:\.self){n in if n<shift{Color.clear.frame(height:32)}else{let d=Nq.cal.date(byAdding:.day,value:n-shift,to:first)!;let key=Nq.day(d);let yes=days.contains(key);Text("\(n-shift+1)").font(.system(.caption,design:.rounded,weight:.bold)).frame(maxWidth:.infinity,minHeight:32).background(yes ? cqPink:Color.clear,in:Circle()).overlay(Circle().stroke(key==Nq.day() ? cqLilac:.clear,lineWidth:2)).accessibilityLabel(key+", "+T(yes ? "Completed":"Not completed"))}}}}.padding(21).background(.white,in:RoundedRectangle(cornerRadius:25))}
}
struct FvHelp:View {
 @Environment(\.dismiss) var dismiss
 var body:some View{NavigationStack{ScrollView{VStack(alignment:.leading,spacing:24){FvHeading(title:"A little guide",sub:"Easy to start, lovely to master");ForEach([("hand.draw.fill","Swap & match","Tap two neighboring sweets, or swipe. A move counts only if it makes a line of three or more. Invalid moves cost nothing."),("star.fill","A special sweet","Four in a line creates a striped sweet that clears a row. Five creates a burst sweet that clears nearby tiles. Match it again to activate it, or swap two special sweets together."),("heart.fill","Reach both goals","Fill the score goal and collect the pink hearts shown at the top. One, two or three stars depend on the moves you have left."),("sparkles","A helping hand","Burst clears a small area. Mix gives you a fresh board. Each tool starts with three uses; every three completed puzzles earns one more of each. Hints are always free."),("calendar","A puzzle every day","The daily seed and refill sequence are the same for everyone. Complete today's puzzle to grow your daily streak. You can replay without losing your best result.")],id:\.0){x in HStack(alignment:.top,spacing:15){Image(systemName:x.0).font(.title2).frame(width:30);VStack(alignment:.leading,spacing:8){Text(T(x.1)).font(.headline);Text(T(x.2)).font(.subheadline)}}}}.padding(25)}.background(cqPaper).toolbar{Button(T("Done")){dismiss()}}}}
}

import UniformTypeIdentifiers

private struct F68eec:View {
 let encode:() throws -> Data
 let apply:(Data) throws -> Void
 @State private var exporting=false
 @State private var importing=false
 @State private var document:Envelope?
 @State private var status=""
 private var labels: [String] { [T("Export file"), T("Import file"), T("File imported")] }
 private struct Envelope:FileDocument {
  static var readableContentTypes:[UTType]{[.json]}
  let contents:Data
  init(contents:Data){self.contents=contents}
  init(configuration:ReadConfiguration)throws{guard let data=configuration.file.regularFileContents else{throw CocoaError(.fileReadCorruptFile)};contents=data}
  func fileWrapper(configuration:WriteConfiguration)throws->FileWrapper{FileWrapper(regularFileWithContents:contents)}
 }
 var body:some View {
  VStack(alignment:.leading,spacing:12){
   Button {do {let payload=try encode();let obj=try JSONSerialization.jsonObject(with:payload,options:[.fragmentsAllowed])
    document=Envelope(contents:try JSONSerialization.data(withJSONObject:["format":"com.candymatch.app-4455c3fb18a1/1","payload":obj]));status="";exporting=true
   }catch{status=error.localizedDescription}} label:{Label(labels[0],systemImage:"square.and.arrow.up")}.buttonStyle(.borderless)
   Button {importing=true} label:{Label(labels[1],systemImage:"square.and.arrow.down")}.buttonStyle(.borderless)
   if !status.isEmpty{Text(status).font(.footnote).foregroundStyle(.secondary)}
  }.fileExporter(isPresented:$exporting,document:document,contentType:.json,defaultFilename:"Candy Match - Records"){
   if case .failure(let error)=$0{status=error.localizedDescription}
  }.fileImporter(isPresented:$importing,allowedContentTypes:[.json]){
   do {let url=try $0.get();let scoped=url.startAccessingSecurityScopedResource();defer{if scoped{url.stopAccessingSecurityScopedResource()}}
    guard let size=try url.resourceValues(forKeys:[.fileSizeKey]).fileSize,size>0,size<100_000_000 else{throw CocoaError(.fileReadTooLarge)}
    let raw=try JSONSerialization.jsonObject(with:Data(contentsOf:url))
    guard let envelope=raw as? [String:Any],envelope["format"] as? String=="com.candymatch.app-4455c3fb18a1/1",let payload=envelope["payload"] else{throw CocoaError(.fileReadCorruptFile)}
    try apply(JSONSerialization.data(withJSONObject:payload,options:[.fragmentsAllowed]));status=labels[2]
   }catch{status=error.localizedDescription}
  }
 }
}
