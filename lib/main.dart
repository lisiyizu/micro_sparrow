import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:micro_sparrow/sparrow/Config.dart';
import 'package:micro_sparrow/sparrow/EventEntity.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:micro_sparrow/sparrow/LoginWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';






void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '微语雀',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: '工作台'),
      routes: {
        "/web_login":(_) => new WebviewScaffold(url: Config.login,
        withLocalStorage: true,
        userAgent: "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36",
        appBar: new AppBar(
          centerTitle: true ,
          title: new Text("需求分配"),
        ),),
        "/login":(_)=>new LoginPage(title: "test",),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;


  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  EventEntity _event = new EventEntity();
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  String cookie = "";


  @override
  void initState() {
    super.initState();
    _readCookie();
  }



  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(length: 3,
        child:Scaffold(
          appBar: _getAppBar(),
          drawer: new Drawer(
            child: new ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                new UserAccountsDrawerHeader(accountName: Text("yami"), accountEmail: Text("yaminet@sina.com"),
                  currentAccountPicture: new GestureDetector(
                    child: new CircleAvatar(
                      backgroundImage: new ExactAssetImage("res/icon.jpg"),
                    ),
                  ),
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                        fit: BoxFit.cover,
                        image: new ExactAssetImage("res/backgroup.jpg"),)
                  ),),
                new ListTile(
                  title: new Text("工作台"),
                  leading: new Icon(Icons.apps),
                ),
                new ListTile(
                  title: new Text("团队"),
                  leading: new Icon(Icons.people_outline),
                ),
                new ListTile(
                  title: new Text("知识库"),
                  leading: new Icon(Icons.book),
                ),
                new ListTile(
                  title: new Text("文档"),
                  leading: new Icon(Icons.event_note),
                ),
                new Divider(),
                new ListTile(
                  title: new Text("设置"),
                  leading: new Icon(Icons.settings),
                ),
                new ListTile(
                  title: new Text("关于"),
                  leading: new Icon(Icons.web),
                )
              ],
            ),
          ),
          body: new TabBarView(
              children: <Widget>[
                new Center(
                  child: new ListView.builder(
                    itemCount: _getLength(),
                      itemBuilder: (BuildContext context,int position){
                      return _getListData(position);
                      })
                ),
                new Center(
                  child: new ListView(
                  children: _getHistoryData(),
                ),),
                new Center(child:
                    _getWebView()
                ),
          ]),
        )
    );

  }

  _getListData(int position) {
      return new GestureDetector(
        child: new Card(
          shape: null,
          elevation: 0,
          child: new Padding(padding: new EdgeInsets.all(8.0),
              child: new Column(
                children: <Widget>[
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Row(
                        children: <Widget>[
                          new Container(
                            margin: new EdgeInsets.only(right: 8),
                            child:new Container(width: 20,height: 20,
                              child: new CircleAvatar(
                                backgroundImage: new Image.network(_event.data[position].actor.avatarUrl,).image,
                              ),
                            ),
                          ),
                          new Text(_event.data[position].actor.name + "在 " + _event.data[position].book.name + " 发布了" + "文档"),
                        ],
                      )
                    ],
                  ),
                  new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Divider(),
                      new Row(
                        children: <Widget>[
                          new Container(
                            margin: EdgeInsets.only(bottom: 8),
                            child: new Text(_event.data[position].subject.title,style: new TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                          ),
                          new Container(
                            margin: EdgeInsets.only(left: 8),
                            child: new Text(_getTimeFormat(_event.data[position].updatedAt),style: new TextStyle(color: Colors.grey),),
                          )
                        ],
                      ),

                      new Text(
                        _event.data[position].subject.description,
                        softWrap: true,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,

                      ),
                      new Container(
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        child: new FlatButton(onPressed: null, child: new Text("查看全文",style: new TextStyle(color: Colors.blue),)),)
                    ],
                  ),
                ],
              )
          ),
        ),
        onTap: (){
          String uri = "https://www.yuque.com/"+ _event.data[position].book.user.login + "/"+_event.data[position].secondSubject.slug +  "/" + _event.data[position].subject.slug;

        }
      );
  }

  _getHistoryData() {
    List<Widget> widgets = [];
    for(int i=0;i<50;i++){
      widgets.add(new ListTile(
        leading: new Icon(Icons.event_note),
        title: new Text("阿里 | 2020年阿里校招实习生"),
        subtitle: new Text("2019春招备战....."),
        trailing: Icon(Icons.edit),
      ));
      widgets.add(new Divider());
    }
    return widgets;
  }

   _getHttpData() async{
    Map<String,String> hearders;
    hearders = getHeaders();
    http.Response response = await http.get(Uri.parse("https://www.yuque.com/api/events?offset=0"),
        headers: hearders);
    var user1 = json.decode(response.body);
    setState(() {
      _event = new EventEntity.fromJson(user1);
      if(_event.data.length == 0){
        print("event is null ");
        Navigator.of(context).pushNamed("/web_login");
        _webViewLogin();
      }
    });
  }

  _getLength() {
    if(_event == null){
      return 0;
    }else if(_event.data == null){
      return 0;
    }else{
      return _event.data.length;
    }
  }

  String _getTimeFormat(String updatedAt) {
    String s = updatedAt.split(".")[0].replaceAll("T", " ");
    return s;
  }

  _getAppBar() {
    return new AppBar(
      // Here we take the value from the MyHomePage object that was created by
      // the App.build method, and use it to set our appbar title.
      title: Text(widget.title),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add,color: Colors.white,),
          onPressed: (){
          },
        )
      ],
      bottom: new TabBar(
        tabs: <Widget>[
          new Tab(
            //icon: new Icon(Icons.image_aspect_ratio),
            text: "动态",
          ),
          new Tab(
            //icon: new Icon(Icons.history),
            text: "最近",
          ),
          new Tab(
            //icon: new Icon(Icons.grain),
            text: "发现",
          )
        ],
      ),
    );
  }

  _getWebView() {
    return new Container(
      color: Colors.blue,
      child: null);
  }

  Map<String, String> getHeaders() {
    Map<String,String> hearders = new Map();
    hearders["Content-Type"] = "application/x-www-form-urlencoded";
    hearders["User-Agent"] = "sparrow";
    hearders["cookie"] = cookie;
    return hearders;
  }

  void _webViewLogin() {
    flutterWebviewPlugin.getCookies();
    flutterWebviewPlugin.onUrlChanged.listen((String url){
      flutterWebviewPlugin.getCookies().then((Map<dynamic,dynamic> map){
        print(map);
      });
      flutterWebviewPlugin.evalJavascript("document.session").then((String test){
        print("hello" + test );
      });
      var _uri = Uri.parse(url);
      print(_uri.path);
      if(_uri.path == "/dashboard"){
        print("登陆成功");
      }
    });
  }

  void _saveCookie() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("cookies", cookie);
  }

  void _readCookie() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    cookie = preferences.getString("cookies");
    _getHttpData();
  }

}