import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/settings_service.dart';

class TolongTukarApp extends StatefulWidget {
  const TolongTukarApp({super.key, this.skipSplash=false}); final bool skipSplash;
  @override State<TolongTukarApp> createState()=>_TolongTukarAppState();
}
class _TolongTukarAppState extends State<TolongTukarApp> {
  SettingsService? settings; bool splash=true; ThemeMode mode=ThemeMode.light;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { final s=await SettingsService.create(); final pref=s.getString(SettingsService.darkMode,'false'); if(!mounted)return; setState((){settings=s; mode=pref=='system'?ThemeMode.system:pref=='true'?ThemeMode.dark:ThemeMode.light;}); if(widget.skipSplash){setState(()=>splash=false);}else{await Future<void>.delayed(const Duration(milliseconds:1400));if(mounted)setState(()=>splash=false);}}
  void setMode(ThemeMode m){setState(()=>mode=m);settings?.putString(SettingsService.darkMode,m==ThemeMode.system?'system':m==ThemeMode.dark?'true':'false');}
  @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,title:'TolongTukar',themeMode:mode,theme:_theme(false),darkTheme:_theme(true),home:settings==null||splash?const SplashScreen():HomeScreen(settings:settings!,themeMode:mode,onThemeChanged:setMode));
  ThemeData _theme(bool dark){const ink=Color(0xFF111111),yellow=Color(0xFFFFD02B),cream=Color(0xFFF6F3E6);final scheme=ColorScheme.fromSeed(seedColor:yellow,brightness:dark?Brightness.dark:Brightness.light,surface:dark?const Color(0xFF202020):Colors.white);return ThemeData(colorScheme:scheme,scaffoldBackgroundColor:dark?const Color(0xFF161616):cream,useMaterial3:true,fontFamily:'sans-serif',cardTheme:CardThemeData(shape:RoundedRectangleBorder(side:BorderSide(color:dark?Colors.white:ink,width:2),borderRadius:BorderRadius.circular(4)),elevation:0),inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:scheme.surface,border:const OutlineInputBorder(borderSide:BorderSide(color:ink,width:2),borderRadius:BorderRadius.zero)),filledButtonTheme:FilledButtonThemeData(style:FilledButton.styleFrom(backgroundColor:yellow,foregroundColor:ink,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.zero),side:const BorderSide(color:ink,width:2))),extensions:const <ThemeExtension<dynamic>>[]);}
}
class SplashScreen extends StatelessWidget {const SplashScreen({super.key});@override Widget build(BuildContext context)=>Scaffold(body:Center(child:TweenAnimationBuilder<double>(duration:const Duration(milliseconds:900),tween:Tween(begin:.75,end:1),builder:(_,v,child)=>Opacity(opacity:v,child:Transform.scale(scale:v,child:child)),child:Column(mainAxisSize:MainAxisSize.min,children:[Image.asset('assets/icon.png',width:120),const SizedBox(height:16),const Text('TolongTukar',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900))]))));}
