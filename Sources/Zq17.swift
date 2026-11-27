import Foundation

struct Zq17: RandomNumberGenerator, Codable, Equatable {
 var q: UInt64
 mutating func next() -> UInt64 { q &+= 0x9E3779B97F4A7C15; var x = q; x = (x ^ (x >> 30)) &* 0xBF58476D1CE4E5B9; x = (x ^ (x >> 27)) &* 0x94D049BB133111EB; return x ^ (x >> 31) }
 mutating func pick(_ n:Int)->Int { Int(next() % UInt64(n)) }
}
enum Nq {
 static let group = "group.com.candymatch.app-4455c3fb18a1"
 static func day(_ d:Date = Date())->String { let f=DateFormatter(); f.calendar=Calendar(identifier:.gregorian); f.locale=Locale(identifier:"en_US_POSIX"); f.timeZone=TimeZone(secondsFromGMT:0); f.dateFormat="yyyy-MM-dd"; return f.string(from:d) }
 static func date(_ s:String)->Date { let f=ISO8601DateFormatter(); return f.date(from:s+"T12:00:00Z") ?? Date() }
 static func z9(_ key:String,_ template:String)->String {let f=DateFormatter();f.locale=Locale.current;f.calendar=cal;f.timeZone=TimeZone(secondsFromGMT:0);f.setLocalizedDateFormatFromTemplate(template);return f.string(from:date(key))}
 static func c8(_ now:Date,_ zone:TimeZone)->[Date] {var cal=Calendar(identifier:.gregorian);cal.timeZone=zone;var dates=[Date]();for i in 0..<7 {let day=cal.date(byAdding:.day,value:i,to:now)!;for hour in [9,20] {var p=cal.dateComponents([.year,.month,.day],from:day);p.timeZone=zone;p.hour=hour;p.minute=0;if let fire=cal.date(from:p),fire>now{dates.append(fire)}}};return dates.sorted()}
 static var month:String { String(day().prefix(7)) }
 static func hash(_ s:String)->UInt64 { s.utf8.reduce(14695981039346656037) { ($0 ^ UInt64($1)) &* 1099511628211 } }
 static var cal:Calendar { var x=Calendar(identifier:.gregorian); x.locale = .current; x.timeZone=TimeZone(secondsFromGMT:0)!; return x }
}
struct Vq:Codable,Equatable {
 var v:Int; var p:Int = 0 // 1: row, 2: area
}
struct Lq:Codable,Equatable,Identifiable {
 var id:String; var n:Int; var seed:UInt64; var moves:Int; var target:Int; var fruit:Int
 static func level(_ n:Int)->Self { .init(id:"c\(n)",n:n,seed:UInt64(n)*174091+91,moves:max(22,31-n/22),target:650+min(n,160)*12,fruit:n>8 ? 8+n/8:0) }
 static func daily(_ day:String=Nq.day())->Self { .init(id:"d\(day)",n:0,seed:Nq.hash(day),moves:25,target:1600,fruit:14) }
 static func season(_ n:Int,month:String=Nq.month)->Self { .init(id:"s\(month)-\(n)",n:n,seed:Nq.hash(month+"-\(n)"),moves:28,target:1050+n*90,fruit:10+n) }
}
struct Bq:Codable,Equatable {
 var l:Lq; var cells:[Vq]; var rng:Zq17; var left:Int; var score=0; var fruit=0; var done=false; var won=false
 var cleared:[Int]=[]; var bursts=0
 init(_ l:Lq) { self.l=l; left=l.moves; rng=Zq17(q:l.seed); cells=Array(repeating:Vq(v:0),count:49); generate() }
 mutating func generate() { for i in cells.indices { var c=rng.pick(6); while (i%7>1 && cells[i-1].v==c && cells[i-2].v==c) || (i>=14 && cells[i-7].v==c && cells[i-14].v==c) { c=rng.pick(6) }; cells[i]=Vq(v:c) }; if hint()==nil { generate() } }
 func runs()->[[Int]] { var out=[[Int]](); for line in 0..<14 { let ids=(0..<7).map { line<7 ? line*7+$0 : $0*7+(line-7) }; var i=0; while i<7 { var j=i+1; while j<7 && cells[ids[i]].v>=0 && cells[ids[j]].v==cells[ids[i]].v { j+=1 }; if j-i>=3 { out.append(Array(ids[i..<j])) }; i=j } }; return out }
 static func near(_ a:Int,_ b:Int)->Bool { abs(a/7-b/7)+abs(a%7-b%7)==1 }
 func hint()->[Int]? { for a in cells.indices { for b in [a+1,a+7] where b<49 && Self.near(a,b) { if cells[a].p>0 && cells[b].p>0 { return [a,b] }; var x=self; x.cells.swapAt(a,b); if !x.runs().isEmpty { return [a,b] } } }; return nil }
 mutating func swap(_ a:Int,_ b:Int)->Bool { guard !done, cells.indices.contains(a),cells.indices.contains(b),Self.near(a,b) else{return false}; cells.swapAt(a,b); let duo=cells[a].p>0 && cells[b].p>0; guard duo || !runs().isEmpty else { cells.swapAt(a,b); return false }; left-=1; settle(preferred:b,forced:duo ? [a,b]:[]); return true }
 mutating func boost(_ index:Int)->Bool { guard !done,cells.indices.contains(index) else{return false}; settle(preferred:nil,forced:Array(Set((0..<49).filter { abs($0/7-index/7)<=1 && abs($0%7-index%7)<=1 })));return true }
 mutating func shuffle()->Bool { guard !done else{return false}; generate(); cleared=[]; return true }
 mutating func settle(preferred:Int?,forced:[Int]) {
  cleared=[]; bursts=0; var force=Set(forced); var cycles=0
  while cycles<80 {
   let groups=runs(); if groups.isEmpty && force.isEmpty { break }; cycles+=1
   var hits=Set(groups.flatMap{$0}); hits.formUnion(force); force=[]
   var special=[Int:Int]()
   for g in groups where g.count>=4 { let pos = preferred.flatMap { g.contains($0) ? $0:nil } ?? g[g.count/2]; if cells[pos].p==0 { special[pos] = max(special[pos] ?? 0,g.count>=5 ? 2:1) } }
   var pending=Array(hits); var seen=Set<Int>()
   while let i=pending.popLast() { if !seen.insert(i).inserted {continue}; if cells[i].p>0 { bursts+=1; let extra=(0..<49).filter { cells[i].p==1 ? $0/7==i/7 : abs($0/7-i/7)<=1 && abs($0%7-i%7)<=1 }; for j in extra where hits.insert(j).inserted { pending.append(j) }; special[i]=nil } }
   for i in hits { if cells[i].v==0 {fruit+=1}; score+=40; cleared.append(i) }
   for (i,p) in special { cells[i].p=p; hits.remove(i) }
   for col in 0..<7 { var kept=(0..<7).reversed().map{$0*7+col}.filter{!hits.contains($0)}.map{cells[$0]}; while kept.count<7 {kept.append(Vq(v:rng.pick(6)))}; for r in 0..<7 {cells[(6-r)*7+col]=kept[r]} }
  }
  won=score>=l.target && fruit>=l.fruit; done=won || left<=0
  if !done && hint()==nil {generate()}
 }
 var stars:Int { guard won else{return 0}; return left>=l.moves/3 ? 3 : (left>=l.moves/7 ? 2:1) }
 var progress:Double { min(1,min(Double(score)/Double(l.target),l.fruit>0 ? Double(fruit)/Double(l.fruit):1)) }
}
struct Rq:Codable,Equatable {var stars:Int; var score:Int}
struct Pq:Codable {
 var results:[String:Rq]=[:]; var uses:[String:String]=[:]; var skin=0; var skinStamp:Double=0
 var validForImport: Bool {
  guard (0...3).contains(skin), skinStamp.isFinite, skinStamp >= 0,
        uses.values.allSatisfy({ $0 == "mix" || $0 == "burst" }) else { return false }
  return results.allSatisfy { key, result in
   guard (1...3).contains(result.stars), result.score >= 0 else { return false }
   if key.first == "c", let level = Int(key.dropFirst()) {
    return (1...160).contains(level) && key == "c" + String(level)
   }
   if key.first == "d" {
    let day = String(key.dropFirst())
    return day.count == 10 && Nq.day(Nq.date(day)) == day
   }
   if key.first == "s", let split = key.lastIndex(of: "-"), let index = Int(key.suffix(from: key.index(after: split))) {
    let month = String(key[key.index(after:key.startIndex)..<split])
    let day = month + "-01"
    return month.count == 7 && (1...12).contains(index) && Nq.day(Nq.date(day)) == day
   }
   return false
  }
 }
 mutating func merge(_ x:Self) { for (k,v) in x.results { if let o=results[k] {results[k]=Rq(stars:max(o.stars,v.stars),score:max(o.score,v.score))}else{results[k]=v} }; uses.merge(x.uses){a,_ in a}; if x.skinStamp>skinStamp {skin=x.skin;skinStamp=x.skinStamp} }
 var stars:Int { results.values.reduce(0){$0+$1.stars} }
 var campaignDone:Int {results.filter{$0.key.hasPrefix("c") && $0.value.stars>0}.count}
 var unlocked:Int { min(160, (1...160).first(where:{results["c\($0)"]?.stars ?? 0 == 0}) ?? 160) }
 func boosters(_ kind:String)->Int {max(0,3+results.values.filter{$0.stars>0}.count/3-uses.values.filter{$0==kind}.count)}
 var days:Set<String> {Set(results.filter{$0.key.hasPrefix("d") && $0.value.stars>0}.map{String($0.key.dropFirst())})}
 var streak:Int { var d=Nq.date(Nq.day()); if !days.contains(Nq.day(d)){d=Nq.cal.date(byAdding:.day,value:-1,to:d)!}; var n=0; while days.contains(Nq.day(d)){n+=1;d=Nq.cal.date(byAdding:.day,value:-1,to:d)!};return n }
}
struct Wq:Codable {
 var day=Nq.day();var streak=0;var stars=0;var moves=25;var progress:Double=0;var completed:[String]=[];var season=0
 static let key="petal-widget-v1"
 static func read()->Self {guard let d=UserDefaults(suiteName:Nq.group)?.data(forKey:key),let x=try? JSONDecoder().decode(Self.self,from:d) else{return Self()};return x}
}
func T(_ s:String)->String { NSLocalizedString(s,comment:"") }

func qz8(_ n:Int,_ key:String)->String {T(n==1 ? key+" one":key)}
