import WidgetKit
import SwiftUI

private let wInk=Color(red:0.29,green:0.17,blue:0.37)
private let wPink=Color(red:1,green:0.48,blue:0.67)
struct QqEntry:TimelineEntry {var date:Date;var w:Wq}
struct QqFeed:TimelineProvider {
 func placeholder(in context:Context)->QqEntry {.init(date:Date(),w:Wq())}
 func getSnapshot(in context:Context,completion:@escaping(QqEntry)->Void){completion(.init(date:Date(),w:current()))}
 func getTimeline(in context:Context,completion:@escaping(Timeline<QqEntry>)->Void){let now=Date();let next=Nq.cal.date(byAdding:.day,value:1,to:Nq.cal.startOfDay(for:now))!;completion(Timeline(entries:[.init(date:now,w:current()),.init(date:next,w:reset(current()))],policy:.after(next)))}
 private func reset(_ w:Wq)->Wq {var x=w;x.day=Nq.day(Nq.cal.date(byAdding:.day,value:1,to:Date())!);x.progress=0;x.moves=25;if x.day.prefix(7) != w.day.prefix(7){x.season=0};if !w.completed.contains(Nq.day()){x.streak=0};return x}
 func current()->Wq {var x=Wq.read();if x.day != Nq.day(){if x.day.prefix(7) != Nq.day().prefix(7){x.season=0};x.progress=0;x.moves=25;x.day=Nq.day();var p=Pq();for d in x.completed{p.results["d"+d]=Rq(stars:1,score:0)};x.streak=p.streak};return x}
}
struct QqCard:View {
 var w:Wq;var family:WidgetFamily
 var body:some View{Group{switch family {
 case .accessoryCircular:Gauge(value:w.progress){Image(systemName:"heart.fill")}currentValueLabel:{Text("\(Int(w.progress*100))%").font(.caption2)}.gaugeStyle(.accessoryCircular).accessibilityLabel(T("Daily challenge")+", \(Int(w.progress*100))%")
 case .systemSmall:VStack(alignment:.leading,spacing:9){Label(T("Candy Match"),systemImage:"heart.fill").font(.caption.bold());Spacer(minLength:0);HStack(alignment:.firstTextBaseline,spacing:5){Text("\(w.streak)").font(.system(size:38,weight:.heavy,design:.rounded));Text(qz8(w.streak,"day streak")).font(.caption.bold())};ProgressView(value:w.progress).tint(wPink);Text(T("Daily challenge")+" · \(Int(w.progress*100))%").font(.caption2)}
 case .systemLarge:VStack(alignment:.leading,spacing:12){HStack{Label(T("Candy Match"),systemImage:"heart.fill").font(.headline);Spacer();Text("★ \(w.stars)").font(.caption.bold())};HStack{Text(T("Daily challenge")).font(.subheadline.bold());Spacer();Text("\(w.streak) "+qz8(w.streak,"day streak")).font(.caption)};QqMonth(days:Set(w.completed));HStack{VStack(alignment:.leading,spacing:4){Text(T("Seasonal collection")).font(.caption.bold());Text("\(w.season) / 12 "+qz8(w.season,"puzzles completed")).font(.caption2)};Spacer();Link(destination:URL(string:"petal174://daily")!){Label(T("Play"),systemImage:"play.fill").font(.caption.bold()).padding(10).background(wPink.opacity(0.3),in:Capsule())}}}
 default:HStack(spacing:18){VStack(alignment:.leading,spacing:9){Label(T("Daily challenge"),systemImage:"heart.fill").font(.headline);Text("\(w.moves) "+qz8(w.moves,"moves left")).font(.system(.title2,design:.rounded,weight:.heavy));ProgressView(value:w.progress).tint(wPink);Text("\(w.streak) "+qz8(w.streak,"day streak")).font(.caption)};Spacer(minLength:0);Link(destination:URL(string:"petal174://daily")!){VStack(spacing:8){Image(systemName:"play.fill").font(.title);Text(T("Play")).font(.caption.bold())}.padding(20).background(wPink.opacity(0.3),in:RoundedRectangle(cornerRadius:22))}}
 }}.foregroundStyle(family == .accessoryCircular ? Color.primary:wInk).widgetURL(URL(string:"petal174://daily"))}
}
struct QqMonth:View {
 var days:Set<String>
 var body:some View{let date=Nq.date(Nq.day());let first=Nq.cal.date(from:Nq.cal.dateComponents([.year,.month],from:date))!;let count=Nq.cal.range(of:.day,in:.month,for:date)!.count;let shift=(Nq.cal.component(.weekday,from:first)+5)%7
 VStack(alignment:.leading,spacing:5){Text(Nq.z9(Nq.day(),"MMMM")).font(.caption.bold());LazyVGrid(columns:Array(repeating:GridItem(.flexible(),spacing:3),count:7),spacing:4){ForEach(0..<count+shift,id:\.self){i in if i<shift{Color.clear.frame(height:21)}else{let key=Nq.day(Nq.cal.date(byAdding:.day,value:i-shift,to:first)!);Text("\(i-shift+1)").font(.system(size:10,weight:.semibold,design:.rounded)).frame(maxWidth:.infinity,minHeight:21).background(days.contains(key) ? wPink:Color.white.opacity(0.6),in:Circle()).overlay(Circle().stroke(key==Nq.day() ? wInk:Color.clear,lineWidth:1))}}}}}
}
#if WIDGET_EXTENSION
@main struct QqPetal:Widget {
 var body:some WidgetConfiguration{StaticConfiguration(kind:"petal-daily-174",provider:QqFeed()){e in QqHost(w:e.w)}.configurationDisplayName(T("Candy Match")).description(T("Your daily puzzle, streak and seasonal progress.")).supportedFamilies([.systemSmall,.systemMedium,.systemLarge,.accessoryCircular])}
}
struct QqHost:View{@Environment(\.widgetFamily) var family;var w:Wq;var body:some View{QqCard(w:w,family:family).containerBackground(for:.widget){Color(red:1,green:0.965,blue:0.985)}}}
#else
struct FvWidgets:View {
 @Environment(\.dismiss) var dismiss
 var body:some View{NavigationStack{ScrollView{VStack(alignment:.leading,spacing:23){Text(T("Your day, at a glance")).font(.system(.title,design:.rounded,weight:.heavy));Text(T("Touch and hold your Home Screen, choose Edit, then Add Widget, and search for Candy Match. Add the progress ring from your Lock Screen's widget picker.")).font(.subheadline);Text(T("These previews show your saved progress. Widgets update when you play and at the start of a new UTC day.")).font(.footnote);let w=QqFeed().current();QqCard(w:w,family:.systemSmall).padding(16).frame(width:172,height:172).background(.white,in:RoundedRectangle(cornerRadius:24));QqCard(w:w,family:.systemMedium).padding(16).frame(maxWidth:350).frame(height:170).background(.white,in:RoundedRectangle(cornerRadius:24));QqCard(w:w,family:.systemLarge).padding(16).frame(maxWidth:350).frame(height:360).background(.white,in:RoundedRectangle(cornerRadius:24));QqCard(w:w,family:.accessoryCircular).frame(width:76,height:76).padding().background(Color.white,in:RoundedRectangle(cornerRadius:24))}.padding(24).frame(maxWidth:650).frame(maxWidth:.infinity)}.background(Color(red:1,green:0.965,blue:0.985)).toolbar{Button(T("Done")){dismiss()}}}}
}
#endif
