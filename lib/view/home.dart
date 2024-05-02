// imported_files
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Box? _todosBox;
  final TextEditingController _textController = TextEditingController();

  // alert_dialogue
  Future<void> _displayInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text('Add Input'),
            content:  TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Add Text Input'
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: (){
                    _todosBox?.add({
                      'content': _textController.text,
                      'time' : DateTime.now().toIso8601String(),
                      'isDone' : false,
                    });
                    Navigator.pop(context);
                    _textController.clear();
                  },
                  child: const Text('Ok')
              )
            ],
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    Hive.openBox('todos_box').then((_boxValue){
      setState(() {
        _todosBox = _boxValue;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('To Do App'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: _buildHomeUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayInputDialog(context),
        child: const Icon(
          Icons.add
        ),
      ),
    );
  }
  Widget _buildHomeUI (){
    if(_todosBox == null){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return ValueListenableBuilder(
        valueListenable: _todosBox!.listenable(),
        builder: (context, boxValue, widget){
          final todoKeys = boxValue.keys.toList();
          return SizedBox.expand(
            child: ListView.builder(
                itemCount: todoKeys.length,
                itemBuilder: (context, index){
                  Map todo = _todosBox!.get(todoKeys[index]);
                  print('$todo');
                  return ListTile(
                    onLongPress: () async {
                      await _todosBox!.delete(todoKeys[index]);
                    },
                    title: Text(todo['content']),
                    // title: Text(index.toString()),
                    // subtitle: Text(todo['time']),
                    trailing: Checkbox(
                      value: todo['isDone'],
                      onChanged: (value) async {
                        todo['isDone'] = value;
                        await _todosBox!.put(todoKeys[index], todo);
                      },
                    ),
                  );
                }
            ),
          );
        }
    );
  }
}

