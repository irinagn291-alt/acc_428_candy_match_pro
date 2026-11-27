import SwiftUI
import WidgetKit
import UserNotifications

@MainActor final class JqPulse:ObservableObject {
 @Published var p=Pq(); @Published var board:Bq?; @Published var page=0
 @Published var message=""
 private let silentQA = ProcessInfo.processInfo.environment["GF_SILENT_QA"] == "1"
 @Published var alertsOn=UserDefaults.standard.bool(forKey:"petal-alerts")
 @Published var sound=UserDefaults.standard.object(forKey:"petal-touch") as? Bool ?? true
 private var sessions:[String:Bq]=[:]
 private let file:URL
 init() {
  file=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("petal-ledger.json")
  #if DEBUG
  if let screen = CandyCapture.index {
   CandyCapture.populate(self, screen: screen)
   return
  }
  #endif
  if let data=try? Data(contentsOf:file),let x=try? JSONDecoder().decode(JqDisk.self,from:data) {p=x.p;sessions=x.sessions}
  save(); if ProcessInfo.processInfo.arguments.contains("-ui-profile") {page=2}; if ProcessInfo.processInfo.arguments.contains("-ui-skins"){page=1}
  if ProcessInfo.processInfo.arguments.contains("-ui-daily"){open(.daily())}
 }
 func open(_ l:Lq) { board=sessions[l.id].flatMap{ $0.done ? nil:$0 } ?? Bq(l);remember() }
 func remember() {if let b=board {sessions[b.l.id]=b};save()}
 func finish() { guard let b=board else{return}; sessions[b.l.id]=b; if b.won { let old=p.results[b.l.id] ?? Rq(stars:0,score:0);p.results[b.l.id]=Rq(stars:max(old.stars,b.stars),score:max(old.score,b.score)); };save() }
 func move(_ a:Int,_ b:Int) {guard var x=board else{return};if x.swap(a,b){board=x;touch();finish()}else{message=T("Match three to make a move")}}
 func boost(_ pos:Int) { guard p.boosters("burst")>0,var b=board,b.boost(pos) else{message=T("Earn more tools by completing levels");return};p.uses[UUID().uuidString]="burst";board=b;touch();finish() }
 func shuffle() {guard p.boosters("mix")>0,var b=board,b.shuffle() else {message=T("Earn more tools by completing levels");return};p.uses[UUID().uuidString]="mix";board=b;touch();finish()}
 func choose(_ k:Int) {guard p.stars >= [0,15,40,80][k] else{return};p.skin=k;p.skinStamp=Date().timeIntervalSince1970;save()}
 func touch() {if sound && !silentQA {UIImpactFeedbackGenerator(style:.soft).impactOccurred()}}
 func save() {
  #if DEBUG
  if CandyCapture.index != nil { return }
  #endif
  try? FileManager.default.createDirectory(at:file.deletingLastPathComponent(),withIntermediateDirectories:true)
  do {try JSONEncoder().encode(JqDisk(p:p,sessions:sessions)).write(to:file,options:.atomic)} catch {message=T("Could not save progress. Please check device storage.")}
  let b=sessions[Lq.daily().id];let result=p.results[Lq.daily().id];var w=Wq();w.streak=p.streak;w.stars=p.stars;w.completed=Array(p.days);w.moves=b?.left ?? 25;w.progress=(result?.stars ?? 0)>0 ? 1 : b?.progress ?? 0;w.season=(1...12).filter{(p.results[Lq.season($0).id]?.stars ?? 0)>0}.count
  if let d=try? JSONEncoder().encode(w) {UserDefaults(suiteName:Nq.group)?.set(d,forKey:Wq.key)};WidgetCenter.shared.reloadAllTimelines()
  if alertsOn {Task{await schedule()}}
 }
 func foreground() { save();Task {let s=await UNUserNotificationCenter.current().notificationSettings();if s.authorizationStatus == .denied {alertsOn=false;UserDefaults.standard.set(false,forKey:"petal-alerts")}} }
 func reminders(_ enable:Bool) async {
  let c=UNUserNotificationCenter.current();if !enable || silentQA {alertsOn=false;c.removeAllPendingNotificationRequests();UserDefaults.standard.set(false,forKey:"petal-alerts");return}
  do {let ok=try await c.requestAuthorization(options:[.alert,.sound,.badge]);alertsOn=ok;UserDefaults.standard.set(ok,forKey:"petal-alerts");if ok{await schedule()}else{message=T("Reminders are off. You can enable them in Settings.")}} catch {message=T("Reminders could not be enabled")}
 }
 func schedule() async {
  guard alertsOn && !silentQA else{return}
  let c=UNUserNotificationCenter.current();c.removeAllPendingNotificationRequests()
  var local=Calendar(identifier:.gregorian);local.timeZone=TimeZone.current
  for fire in Nq.c8(Date(),TimeZone.current) {
   if !alertsOn{return};let day=Nq.day(fire);if p.days.contains(day){continue}
   let hour=local.component(.hour,from:fire);var parts=local.dateComponents([.year,.month,.day,.hour,.minute],from:fire);parts.calendar=local;parts.timeZone=TimeZone.current
   let note=UNMutableNotificationContent();note.title=T(hour==9 ? "A fresh candy puzzle":"A little puzzle time");note.body=T(hour==9 ? "Your daily challenge is ready to play offline.":"Enjoy today's challenge and keep your streak growing.");note.sound = .default;note.userInfo=["route":"daily"]
   let id="petal-\(day)-\(hour)";try? await c.add(UNNotificationRequest(identifier:id,content:note,trigger:UNCalendarNotificationTrigger(dateMatching:parts,repeats:false)))
   if !alertsOn || p.days.contains(day){c.removePendingNotificationRequests(withIdentifiers:[id])}
  }
 }
 func prepare68eec() throws -> Data {
  let value: Pq = p
  return try JSONEncoder().encode(value)
 }
 func accept68eec(_ data:Data) throws {
  let incoming = try JSONDecoder().decode(Pq.self, from:data)
  guard incoming.validForImport else { throw CocoaError(.fileReadCorruptFile) }
  var merged = p
  merged.merge(incoming)
  let snapshot = try JSONEncoder().encode(JqDisk(p: merged, sessions: sessions))
  try snapshot.write(to: file, options: .atomic)
  p = merged
  save()
 }

}
private struct JqDisk:Codable {var p:Pq;var sessions:[String:Bq]}
