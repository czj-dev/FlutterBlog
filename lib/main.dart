import 'package:flutter/material.dart';
import 'package:flutter_blog/style/theme/application_theme_data.dart';
import 'package:flutter_blog/style/theme/markdown_theme_data.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'codeviewer/code_style.dart';
import 'codeviewer/prehighlighter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data = "";
  String title = "";
  String subTitle = "";

  void _incrementCounter() async {
    var content = await DefaultAssetBundle.of(context).loadString("README.md");
    // search config
    RegExp configPattern = new RegExp(r'---[\s\S]+(.*?)[\s\S]+---');
    var allMatches = configPattern.stringMatch(content);
    var yaml = allMatches!.replaceAll("---", "");
    var config = loadYaml(yaml);
    title = config["title"];
    subTitle = config["subtitle"];

    // search img list
    RegExp imagesPattern = new RegExp(r'!\[(.*?)\]\((.*?)\)');
    Iterable<RegExpMatch> allMatches2 = imagesPattern.allMatches(content);
    int historyAddStringCount = 0;
    allMatches2.toList().forEach((element) {
      var imgContent = content.substring(element.start + historyAddStringCount,
          element.end + historyAddStringCount);
      if (!imgContent.contains("http") && !imgContent.contains("resource:")) {
        var start = imgContent.indexOf("(") + 1;
        var imgHeader = "resource:static/images/";
        content = content.replaceRange(
            element.start + start + historyAddStringCount,
            element.end + historyAddStringCount - 1,
            imgHeader + imgContent.substring(start, imgContent.length - 1));
        historyAddStringCount += imgHeader.length;
      }
    });
    data = content.substring(allMatches.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var markdownStyleSheet =
        MarkdownThemeData.markdownStyleSheet(ApplicationThemeData.lightThemeData);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [Container(child: Text(subTitle))],
      ),
      body: Markdown(
        onTapLink: (String text, String? href, String title) =>
            href != null ? launch(href) : null,
        selectable: true,
        styleSheet: markdownStyleSheet,
        syntaxHighlighter: DartSyntaxPrehighlighter(CodeStyle(
          baseStyle: TextStyle(color: const Color(0xFFFAFBFB)),
          numberStyle: TextStyle(color: const Color(0xFFBD93F9)),
          commentStyle: TextStyle(color: const Color(0xFF808080)),
          keywordStyle: TextStyle(color: const Color(0xFF1CDEC9)),
          stringStyle: TextStyle(color: const Color(0xFFFFA65C)),
          punctuationStyle: TextStyle(color: const Color(0xFF8BE9FD)),
          classStyle: TextStyle(color: const Color(0xFFD65BAD)),
          constantStyle: TextStyle(color: const Color(0xFFFF8383)),
          child: Container(),
        )),
        data: data ?? "loading...",
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
