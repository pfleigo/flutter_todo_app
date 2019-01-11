import 'package:flutter/material.dart';
import 'package:todo_app/model/todo.dart';
import 'package:todo_app/util/dbhelper.dart';
import 'package:intl/intl.dart';

DbHelper helper = DbHelper();
final List<String> choices = const <String> [
  'Save Todo & Back',
  'Delete Todo',
  'Back to List'
];

const mnuSave = 'Save Todo & Back';
const mnuDelete = 'Delete Todo';
const mnuBack = 'Back to List';

class TodoDetail extends StatefulWidget {
  final Todo todo;
  // TodoDetail(this.todo);

  TodoDetail({Key key, @required this.todo}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodoDetailState();
}

class _TodoDetailState extends State<TodoDetail> {
  Todo todo;
  final _priorities = ['High', 'Medium', 'Low'];
  String _priority = 'Low';
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    debugPrint('Hello   ' + widget.todo.toString());
    titleController.text = widget.todo.title;
    descriptionController.text = widget.todo.description;
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.todo.title),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: select,
              itemBuilder: (BuildContext context) {
                return choices.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: Padding(
            padding: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      style: textStyle,
                      onChanged: (value) => this.updateTitle(),
                      decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: textStyle,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextField(
                          controller: descriptionController,
                          style: textStyle,
                          onChanged: (value) => this.updateDescription(),
                          decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: textStyle,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        )),
                    ListTile(
                        title: DropdownButton(
                      items: _priorities.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      style: textStyle,
                      value: retrievePriority(widget.todo.priority),
                      onChanged: (value) => updatePriority(value),
                    ))
                  ],
                )
              ],
            )));
  }

  void select (String value) async {
    int result;
    switch (value) {
      case mnuSave:
        save();
        break;
      
      case mnuDelete:
        Navigator.pop(context, true);
        if (widget.todo.id == null) {
          return;
        }
        result = await helper.deleteTodo(widget.todo.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
            title: Text('Delete Todo'),
            content: Text('The Todo has been deleted'),
          );
          showDialog(
            context: context,
            builder: (_) => alertDialog
          );
        }
        break;
      
      case mnuBack:
        Navigator.pop(context, true);
        break;
      default:
    }
  }

  void save() {
    widget.todo.date = DateFormat.yMd().format(DateTime.now());
    if (widget.todo.id != null) {
      helper.updateTodo(todo);
    } else {
      helper.insertTodo(todo);
    }
    Navigator.pop(context, true);
  }

  void updatePriority(String value) {
    switch (value) {
      case 'High':
        widget.todo.priority = 1;
        break;
      
      case 'Medium':
        widget.todo.priority = 2;
        break;

      case 'Low':
        widget.todo.priority = 3;
        break;
    }
    setState(() {
      _priority = value;
    });
  }

  String retrievePriority(int value) {
    return _priorities[value - 1];
  }

  void updateTitle() {
    widget.todo.title = titleController.text;
  }

  void updateDescription() {
    widget.todo.description = descriptionController.text;
  }
}
