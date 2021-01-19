import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_todo_app/database/db_helper.dart';

class HomeTodo extends StatefulWidget {
  @override
  _HomeTodoState createState() => _HomeTodoState();
}

class _HomeTodoState extends State<HomeTodo> {

  // Database Helper
  final dbHelper = Databasehelper.instance;

  // TextEditing Controller Functions
  final textEditingController = TextEditingController();
  bool validated = true;
  String errText = "";
  String  todoEdit = "";
  var myItems = List();
  List<Widget> children = new List<Widget>();

  void addTodo() async{
    Map<String, dynamic> row ={
      Databasehelper.columnName : todoEdit,
    };
    final id = await dbHelper.insert(row);
    print(id);
    Navigator.pop(context);
    todoEdit = "";
    setState(() {
      validated = true;
      errText = "";
    });
  }

  Future<bool> query() async{
    myItems = [];
    children = [];
    var allRows = await dbHelper.queryall();
    allRows.forEach((row) {
      myItems.add(row.toString());
      children.add(
          Card(
            color: Colors.grey,
            elevation: 10.0,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Container(
              padding: EdgeInsets.all(5),
              child: ListTile(
                title: Text(row['todo'], style: TextStyle(color: Colors.white),),
                onLongPress: () {
                  dbHelper.deletedata(row['id']);
                  setState(() {

                  });
               },
              ),
            ),
          ),
      );
    });
    return Future.value(true);
  }

  // show dialog
  void showAlertDialog() {
    textEditingController.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              title: Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (_val){
                      todoEdit = _val;
                    },
                    controller: textEditingController,
                    autofocus: true,
                    decoration: InputDecoration(
                        errorText: validated ? null : errText,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top: 10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        // Validation should not be Empty
                        onPressed: () {
                          if(textEditingController.text.isEmpty){
                            setState((){
                              errText = "Can't be Empty";
                              validated = false;
                            });
                          } else if(textEditingController.text.length > 512){
                            setState((){
                              errText = "Too many Characters";
                              validated = false;
                            });
                          } else{
                            addTodo();
                          }
                        },
                        child: Text('ADD', style: TextStyle(
                            color: Colors.white, fontSize: 18),),
                        color: Colors.black,
                      )
                    ],
                  )
                ],
              ),
            );
          },);
        }
    );
  }

  // Card widget
//  Widget myCard(String task) {
//    return
//  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // ignore: missing_return
      builder: (context, snap){
        if(snap.hasData == null){
          return Center(
            child: Text('No Data'),
          );
        } else{
          if(myItems.length == 0){
            return  Scaffold(
              backgroundColor: Colors.grey[500],
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'Tasks',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.black,
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  showAlertDialog();
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
              body: Center(
                child: Text(
                  'No Task Available', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white
                ),
                ),
              ),
            );
          } else{
            return Scaffold(
              backgroundColor: Colors.grey[500],
              appBar: AppBar(
                centerTitle: true,
                title: Text(
                  'Tasks',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.black,
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.black,
                onPressed: () {
                  showAlertDialog();
                },
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
               body: SingleChildScrollView(
                 child: Column(
                   children: children,
                 ),
               ),
            );
          }
        }
      },
      future: query(),
    );
  }
}
