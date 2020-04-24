import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _valid = true;

  void _invertValidity() {
    setState(() {
      _valid = !_valid;
    });
  }

  TextEditingValue _textInputFormatter(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var startIndex = oldValue.selection.baseOffset;
    return oldValue.copyWith(
        text: newValue.text.substring(startIndex, startIndex + 1));
  }

  int _dimension = 5;
  double _cellWidth = 60;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latin squares game'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: _cellWidth),
        child: Align(
          alignment: Alignment.topCenter,
          child: Builder(builder: _buildTable),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _invertValidity,
        tooltip: 'Invert',
        child: Icon(Icons.invert_colors),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Color get _validityColor => _valid ? Colors.black : Colors.red;

  Widget _buildTable(BuildContext context) => Table(
        border: TableBorder.all(color: _validityColor),
        defaultColumnWidth: FixedColumnWidth(_cellWidth),
        children: List.generate(
          _dimension,
          (i) => TableRow(
            children: List.generate(
              _dimension,
              (j) => _buildCell(context, i, j),
            ),
          ),
        ),
      );

  Widget _buildCell(BuildContext context, int i, int j) => TextFormField(
        initialValue: (1 + (i + j) % _dimension).toString(),
        inputFormatters: [TextInputFormatter.withFunction(_textInputFormatter)],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.display1,
      );
}
