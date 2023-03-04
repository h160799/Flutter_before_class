import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget { // ← 無狀態的 widget，內容一旦被渲染就不會改變。
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),  // ← the "home" widget—the starting point of app.
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

/* 新的 getNext() 重新指派 current 作爲作爲一個新的隨機 WordPair, 並且
呼叫 notifyListeners(a method of ChangeNotifier),確保所有觀察 MyAppState 的人都會被通知到。 */
  void getNext() { 
    current = WordPair.random();  // ← WordPair 是由兩個隨機字詞組成的組合。常用於創建隨機文字生成器應用程式中。
    notifyListeners();
  }
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
      favorites.remove(pair);
    notifyListeners();
  }

}

class MyHomePage extends StatefulWidget { // ← 從無狀態的 widget，改為有狀態的 widget．
  State<MyHomePage> createState() => _MyHomePageState();  // ← '_' makes that class private and is enforced by the compiler
}

/*the build method from the old, stateless widget has moved to the _MyHomePageState (instead of staying in the widget). 
It was moved verbatim—nothing inside the build method changed. */

class _MyHomePageState extends State<MyHomePage> {  

var selectedIndex = 0;  // ← The new stateful widget only needs to track one variable.

  @override
  Widget build(BuildContext context) {

/* The code declares a new variable, page, of the type Widget.
Then, a switch statement assigns a screen to page, according to the current value in selectedIndex.*/

Widget page;
switch (selectedIndex) {
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
    break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}

    return LayoutBuilder(
      builder: (context, Constraints) {  //  ← Modify the callback parameter list from (context) to (context, constraints).
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: Constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {  // ← 類似 notifyListeners() 確保 UI 更新.
                    
                    setState(() {
                      selectedIndex = value;
                    });                         // ← This instead of ' print('selected: $value')'
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {        // ← 定義了一個 build()，在 widget 的環境發生變化時自動調用，讓 widget 始終保持最新狀態。
    var appState = context.watch<MyAppState>();  // ← 透過 watch 追蹤當前狀態改變
    var pair = appState.current; 

// Like 心型圖案設置
  IconData icon;  
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
        child: Column(  // ← one of the most basic layout widgets。可以接收任意數量的 children,從上到下排列成一個垂直的列,彈性設置。
          mainAxisAlignment: MainAxisAlignment.center,  // ← Center the UI
          children: [
          //Text('A random AWESOME idea:'), // ← cleaner that way.
          //Text(pair.asLowerCase)  // ← WordPair 提供了幾個有用的 getters，例如 asPascalCase 或 asSnakeCase。在這裡使用的是 asLowerCase
            BIGCARD(pair: pair), // ← refactor 後 Extract Widget
            SizedBox(height: 10), // ← more separation between the two widgets. SizedBox widgets 只佔用空間，並不會自己渲染任何內容。
            Row(   // ← let 'Like' button on the left to the 'Next' button, needs 'Row'
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },                          //connect 'Like' button to toggleFavorites().
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () {
                    appState.getNext();  // ← This instead of 'print('button pressed!')'.
                  },
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      );
  }
}

class BIGCARD extends StatelessWidget {
  const BIGCARD({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);  // ← to requests the app's current theme.
    final frontCaptialLetter = RegExp(r"(?=[A-Z])"); // ← 定義大寫開頭的字
    var style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary,fontStyle: FontStyle.italic);
    var pairList = pair.asCamelCase.split(frontCaptialLetter); // ← 先以駝峰式編排單詞，再以 ‘frontCaptialLetter’ 分割兩個單詞
  
    return Card(  // ← refactor 後 Wrap with Padding
      color: theme.colorScheme.primary,    // ←  keep a consistent color scheme
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: RichText(    // ← RichText 控件使用這個 TextSpan 對象來顯示兩個組合單詞。
          text: TextSpan (
            style: style,
            children: <TextSpan>[
              TextSpan(text: pairList[0]),
              TextSpan(
                text: pairList[1],
                style: TextStyle(fontWeight: FontWeight.bold)
              ),
            ]
            )
          ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return GridView.count(
      crossAxisCount: 2, // 設置列數為 2
      childAspectRatio: 5.1,
 
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text('You have '
              '${appState.favorites.length} favorites:')
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text('')
        ),
        for (var pair in appState.favorites)
          GridTile(
              child: ListTile(
                leading: Icon(Icons.delete_outlined),
                title: Text(pair.asCamelCase),
                onTap: (){ appState.removeFavorite(pair);
                           // 刪除對應的項目
                },
              ),
          ),
      ],
    );
  }
}
