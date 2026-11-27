import SwiftUI

struct FvSweet:View {
 var v:Int;var skin=0;var special=0
 private var symbol:String {let sets=[["heart.fill","star.fill","leaf.fill","drop.fill","diamond.fill","seal.fill"],["heart.fill","oval.fill","leaf.fill","carrot.fill","diamond.fill","sun.max.fill"],["heart.fill","moon.fill","star.fill","drop.fill","diamond.fill","cloud.fill"],["heart.fill","star.fill","leaf.fill","circle.fill","diamond.fill","seal.fill"]];return sets[min(3,max(0,skin))][max(0,v)%6]}
 private var c:Color {let a:[Color]=[cqPink,cqLilac,Color(red:0.4,green:0.72,blue:0.58),Color(red:0.4,green:0.7,blue:0.95),Color(red:1,green:0.69,blue:0.38),Color(red:0.94,green:0.69,blue:0.3)];let b:[Color]=[cqPink,Color(red:0.82,green:0.44,blue:0.78),Color(red:0.35,green:0.66,blue:0.55),Color(red:0.45,green:0.58,blue:0.91),Color(red:0.96,green:0.63,blue:0.4),cqLilac];return (skin==2 ? b:a)[max(0,v)%6]}
 var body:some View{GeometryReader{g in let s=min(g.size.width,g.size.height);ZStack{Image(systemName:symbol).resizable().scaledToFit().foregroundStyle(LinearGradient(colors:[c.opacity(0.6),c,c.opacity(0.85)],startPoint:.topLeading,endPoint:.bottomTrailing)).shadow(color:c.opacity(0.45),radius:2,y:3);Image(systemName:symbol).resizable().scaledToFit().foregroundStyle(.white.opacity(0.12)).padding(s*0.15).offset(x:-s*0.05,y:-s*0.09);Ellipse().fill(.white.opacity(0.7)).frame(width:s*0.22,height:s*0.1).rotationEffect(.degrees(-35)).offset(x:-s*0.13,y:-s*0.2);if special>0{Image(systemName:special==1 ? "line.3.horizontal":"sparkle").font(.system(size:s*0.45,weight:.black)).foregroundStyle(.white).shadow(color:cqInk.opacity(0.5),radius:1)}}.padding(s*0.08).frame(width:g.size.width,height:g.size.height)}}
}
struct FvBoard:View {
 @EnvironmentObject var j:JqPulse;@Environment(\.dismiss) var dismiss
 @Environment(\.layoutDirection) private var readingDirection
 @State var selected:Int?;@State var hint:[Int]=[];@State var burst=false;@State var help=false;@State var retry=false
 var body:some View{GeometryReader{g in ScrollView{if let b=j.board {VStack(spacing:18){HStack{Button{j.remember();j.board=nil;dismiss()}label:{Image(systemName:"xmark").font(.headline).frame(width:44,height:44).background(.white,in:Circle())}.accessibilityLabel(T("Save and close"));Spacer();VStack(spacing:3){Text(T(b.l.id.hasPrefix("d") ? "Daily challenge":b.l.id.hasPrefix("s") ? "Seasonal puzzle":"Jelly journey")).font(.caption.bold()).textCase(.uppercase).tracking(1);Text(b.l.id.hasPrefix("d") ? Nq.z9(String(b.l.id.dropFirst()),"MMM d"):T("Level")+" \(b.l.n)").font(.system(.title2,design:.rounded,weight:.heavy))};Spacer();Button{help=true}label:{Image(systemName:"questionmark").font(.headline).frame(width:44,height:44).background(.white,in:Circle())}.accessibilityLabel(T("How to play"))}
 if b.done {resultHero(b);ending(b)} else if g.size.width>800 {HStack(alignment:.center,spacing:35){grid(b,width:min(510,g.size.width*0.57));VStack(spacing:22){goals(b);tools(b);ending(b)}.frame(maxWidth:300)}.frame(maxWidth:900)}else{goals(b);grid(b,width:min(g.size.width-36,490));tools(b);ending(b)}
 }.padding(18).frame(maxWidth:950).frame(maxWidth:.infinity)}}.background(cqPaper)}.foregroundStyle(cqInk).sheet(isPresented:$help){FvHelp()}.confirmationDialog(T("Start this puzzle again?"),isPresented:$retry,titleVisibility:.visible){Button(T("Start again"),role:.destructive){if let l=j.board?.l{j.board=Bq(l);j.remember();selected=nil;hint=[]}}}.alert(T("Candy Match"),isPresented:Binding(get:{!j.message.isEmpty},set:{value in if !value {let old=j.message;DispatchQueue.main.async {if j.message==old {j.message=""}}}})){Button(T("OK")){}}message:{Text(j.message)}}
 private func resultHero(_ board: Bq) -> some View {
  VStack(spacing: 20) {
   ZStack {
    Circle().fill(.white.opacity(0.14)).frame(width: 170, height: 170)
    Circle().stroke(.white.opacity(0.33), lineWidth: 1).frame(width: 206, height: 206)
    HStack(spacing: -12) {
     ForEach(0..<3) { star in
      FvSweet(v: 1, skin: 0).frame(width: star == 1 ? 105 : 65, height: star == 1 ? 105 : 65)
       .rotationEffect(.degrees(Double(star - 1) * 18))
       .offset(y: star == 1 ? -10 : 10)
       .opacity(star < board.stars ? 1 : 0.35)
     }
    }
   }.accessibilityHidden(true)
   HStack {
    FvStat(value: String(board.score), label: "Score", icon: "sparkles")
    FvStat(value: String(board.stars), label: "stars", icon: "star.fill")
    FvStat(value: String(board.left), label: "Moves", icon: "arrow.left.arrow.right")
   }
  }.padding(20).frame(maxWidth: 580)
   .background(LinearGradient(colors: [Color(red: 0.33, green: 0.14, blue: 0.47),
                                        Color(red: 0.67, green: 0.31, blue: 0.57)],
                              startPoint: .topLeading, endPoint: .bottomTrailing),
               in: RoundedRectangle(cornerRadius: 32))
 }
 private func goals(_ b:Bq)->some View{HStack(spacing:12){VStack(spacing:7){Text(T("Moves")).font(.caption.bold());Text("\(b.left)").accessibilityIdentifier("moves-count").font(.system(size:33,weight:.heavy,design:.rounded)).contentTransition(.numericText())}.frame(width:70);Divider().frame(height:58);VStack(alignment:.leading,spacing:9){HStack{Text(T("Score")).font(.caption.bold());Spacer();Text("\(b.score) / \(b.l.target)").font(.system(.subheadline,design:.rounded,weight:.bold)).monospacedDigit()};ProgressView(value:min(1,Double(b.score)/Double(b.l.target))).tint(cqLilac);if b.l.fruit>0 {HStack{Image(systemName:"heart.fill").foregroundStyle(cqPink);Text("\(min(b.fruit,b.l.fruit)) / \(b.l.fruit)");Spacer();Text(T("Collect hearts")).font(.caption)}.font(.subheadline.bold())}else{Text(T("Match sweets to fill the score bar")).font(.caption)}}}.padding(19).background(.white,in:RoundedRectangle(cornerRadius:23)).frame(maxWidth:530)}
 private func grid(_ b:Bq,width:CGFloat)->some View {
  let safe=width.isFinite ? max(210,width):210
  let cell=(safe-54)/7
  return VStack(spacing:5){ForEach(0..<7,id:\.self){r in HStack(spacing:5){ForEach(0..<7,id:\.self){c in tile(b,i:r*7+c,cell:cell)}}}}
   .padding(12).frame(width:safe).background(Color(red:0.95,green:0.82,blue:0.93),in:RoundedRectangle(cornerRadius:25))
   .shadow(color:cqInk.opacity(0.07),radius:12,y:7).animation(.spring(response:0.27,dampingFraction:0.75),value:selected)
 }
 private func tile(_ b:Bq,i:Int,cell:CGFloat)->some View {
  Button{tap(i)}label:{
   FvSweet(v:b.cells[i].v,skin:j.p.skin,special:b.cells[i].p).frame(width:cell,height:cell)
    .background(.white.opacity(0.8),in:RoundedRectangle(cornerRadius:11))
    .overlay(RoundedRectangle(cornerRadius:11).stroke(selected==i || hint.contains(i) ? cqInk:.clear,lineWidth:2.5))
    .scaleEffect(selected==i ? 1.07:1)
  }.buttonStyle(.plain).disabled(b.done)
   .simultaneousGesture(DragGesture(minimumDistance:15).onEnded{v in slide(b,i:i,v:v.translation)})
   .accessibilityIdentifier("tile-\(i)").accessibilityLabel(tileName(b,i))
   .accessibilityHint(T(burst ? "Tap to clear nearby sweets":"Select, then tap a neighboring sweet"))
 }
 private func tileName(_ b:Bq,_ i:Int)->String {
  let sets=[["Pink heart","Lilac star","Green leaf","Blue drop","Orange diamond","Golden flower"],
   ["Pink heart","Lilac fruit","Green leaf","Blue carrot","Orange diamond","Golden sun"],
   ["Pink heart","Lilac moon","Green star","Blue drop","Orange diamond","Lilac cloud"],
   ["Pink heart","Lilac star","Green leaf","Blue circle","Orange diamond","Golden flower"]]
  let name=T(sets[j.p.skin][b.cells[i].v]);let row=T("row")+" \(i/7+1)";let col=T("column")+" \(i%7+1)"
  let extra=b.cells[i].p>0 ? ", "+T(b.cells[i].p==1 ? "Striped sweet":"Burst sweet"):""
  return name+", "+row+", "+col+extra
 }
 private func slide(_ b:Bq,i:Int,v:CGSize) {guard !b.done else{return};let end=abs(v.width)>abs(v.height) ? i+(v.width>0 ? 1:-1)*(readingDirection == .rightToLeft ? -1:1) : i+(v.height>0 ? 7:-7);selected=nil;hint=[];j.move(i,end)}
 private func tools(_ b:Bq)->some View{VStack(spacing:13){HStack(spacing:12){tool("lightbulb.fill","Hint","∞"){hint=b.hint() ?? [];selected=nil;burst=false};tool("sparkles","Burst","\(j.p.boosters("burst"))"){if j.p.boosters("burst")>0 {burst.toggle();selected=nil;hint=[]}else{j.message=T("Earn more tools by completing levels")}};tool("arrow.triangle.2.circlepath","Mix","\(j.p.boosters("mix"))"){j.shuffle();selected=nil;hint=[];burst=false}}.disabled(b.done);Text(T(burst ? "Tap a sweet to clear the area around it":"Swap neighbors. Match three or more.")).font(.footnote).multilineTextAlignment(.center);if !b.done{Button(T("Start again")){retry=true}.font(.footnote.bold()).padding(8)}}.frame(maxWidth:510)}
 private func tool(_ symbol:String,_ title:String,_ count:String,action:@escaping()->Void)->some View{Button(action:action){VStack(spacing:6){HStack(spacing:6){Image(systemName:symbol).font(.title3);Text(count).font(.caption.bold())};Text(T(title)).font(.system(.caption,design:.rounded,weight:.bold))}.frame(maxWidth:.infinity).padding(.vertical,14).background(burst && title=="Burst" ? cqPink.opacity(0.45):.white,in:RoundedRectangle(cornerRadius:19))}.buttonStyle(.plain).accessibilityIdentifier(title.lowercased())}
 @ViewBuilder private func ending(_ b:Bq)->some View{if b.done{VStack(spacing:16){Text(T(b.won ? "Sweetly done!":"A little more practice")).font(.system(.title2,design:.rounded,weight:.heavy));if b.won{HStack(spacing:10){ForEach(1...3,id:\.self){i in Image(systemName:i<=b.stars ? "star.fill":"star").font(.largeTitle).foregroundStyle(cqLilac)}};Text(T("Your best result is saved")).font(.subheadline)}else{Text(T("Try a new approach. You can replay as often as you like.")).font(.subheadline).multilineTextAlignment(.center)};Button{selected=nil;hint=[];burst=false;if b.won,b.l.id.hasPrefix("c"),b.l.n<160{j.open(.level(b.l.n+1))}else{j.board=Bq(b.l);j.remember()}}label:{Text(T(b.won && b.l.id.hasPrefix("c") && b.l.n<160 ? "Next level":"Play again")).font(.headline).frame(maxWidth:.infinity).padding(16).background(cqPink,in:Capsule())}.buttonStyle(.plain).accessibilityIdentifier("continue");Button(T("Back to journey")){j.page=0;j.board=nil;dismiss()}.font(.subheadline.bold())}.padding(22).background(.white,in:RoundedRectangle(cornerRadius:26)).frame(maxWidth:510)}}
 private func tap(_ i:Int){guard let b=j.board,!b.done else{return};hint=[];if burst{j.boost(i);burst=false;selected=nil;return};if let a=selected {if a==i{selected=nil}else if Bq.near(a,i){selected=nil;j.move(a,i)}else{selected=i}}else{selected=i}}
}
