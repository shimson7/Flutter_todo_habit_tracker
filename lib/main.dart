import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => TodoProvider(),
    child: TodoApp(),
  ));
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo & Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class TodoProvider with ChangeNotifier {
  List<String> _todos = [];

  List<String> get todos => _todos;

  TodoProvider() {
    _loadTodos();
  }

  void _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedTodos = prefs.getStringList('todos');
    if (savedTodos != null) {
      _todos = savedTodos;
      notifyListeners();
    }
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('todos', _todos);
  }

  void addTodo(String todo) {
    _todos.add(todo);
    _saveTodos();
    notifyListeners();
  }

  void removeTodo(int index) {
    _todos.removeAt(index);
    _saveTodos();
    notifyListeners();
  }
}

class TodoListScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  void _addTodo(BuildContext context) {
    if (_controller.text.isNotEmpty) {
      Provider.of<TodoProvider>(context, listen: false).addTodo(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo & Habit Tracker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Enter a new task'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _addTodo(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, todoProvider, child) {
                return ListView.builder(
                  itemCount: todoProvider.todos.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(todoProvider.todos[index]),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => todoProvider.removeTodo(index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
