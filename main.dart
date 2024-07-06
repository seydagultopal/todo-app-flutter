import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(TodoApp());

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: CategorySelection(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CategorySelection extends StatefulWidget {
  @override
  _CategorySelectionState createState() => _CategorySelectionState();
}

class _CategorySelectionState extends State<CategorySelection> {
  final List<String> _categories = ['All', 'Work', 'Personal', 'Shopping'];
  final Map<String, IconData> _categoryIcons = {
    'All': Icons.list,
    'Work': Icons.work,
    'Personal': Icons.person,
    'Shopping': Icons.shopping_cart,
  };
  final TextEditingController _newCategoryController = TextEditingController();
  IconData? _selectedIcon;
  final List<int> _selectedCategories = [];
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      List<dynamic> loadedData = jsonDecode(categoriesString);
      List<String> loadedCategories =
          List<String>.from(loadedData.map((data) => data['category']));
      Map<String, IconData> loadedIcons = Map<String, IconData>.fromIterable(
        loadedData,
        key: (data) => data['category'],
        value: (data) =>
            IconData(data['iconCode'], fontFamily: 'MaterialIcons'),
      );
      setState(() {
        _categories
          ..clear()
          ..addAll(loadedCategories);
        _categoryIcons
          ..clear()
          ..addAll(loadedIcons);
      });
    } else {
      print('Kayıtlı kategori bulunamadı.');
    }
  }

  Future<void> _saveCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> dataToSave = _categories
        .map((category) => {
              'category': category,
              'iconCode': _categoryIcons[category]!.codePoint,
            })
        .toList();
    await prefs.setString('categories', jsonEncode(dataToSave));
  }

  void _addCategory(String category, IconData icon) {
    if (category.isNotEmpty && !_categories.contains(category)) {
      List<String> updatedCategories = List.from(_categories)..add(category);
      Map<String, IconData> updatedIcons = Map.from(_categoryIcons)
        ..[category] = icon;

      setState(() {
        _categories.clear();
        _categories.addAll(updatedCategories);
        _categoryIcons.clear();
        _categoryIcons.addAll(updatedIcons);
      });

      _saveCategories();
    } else {
      _showDuplicateEntryDialog('Category');
    }
  }

  void _editCategory(int index, String newCategory, IconData newIcon) {
    if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
      List<String> updatedCategories = List.from(_categories);
      Map<String, IconData> updatedIcons = Map.from(_categoryIcons);

      updatedIcons.remove(_categories[index]);
      updatedCategories[index] = newCategory;
      updatedIcons[newCategory] = newIcon;

      setState(() {
        _categories.clear();
        _categories.addAll(updatedCategories);
        _categoryIcons.clear();
        _categoryIcons.addAll(updatedIcons);
      });

      _saveCategories();
    } else {
      _showDuplicateEntryDialog('Category');
    }
  }

  void _deleteCategory(int index) {
    if (_categories[index] == 'All') {
      _showCannotDeleteDialog();
      return;
    }

    List<String> updatedCategories = List.from(_categories);
    Map<String, IconData> updatedIcons = Map.from(_categoryIcons);

    updatedIcons.remove(updatedCategories[index]);
    updatedCategories.removeAt(index);

    setState(() {
      _categories.clear();
      _categories.addAll(updatedCategories);
      _categoryIcons.clear();
      _categoryIcons.addAll(updatedIcons);
    });

    _saveCategories();
  }

  void _deleteSelectedCategories() {
    setState(() {
      _selectedCategories.sort((a, b) => b.compareTo(a));
      for (var index in _selectedCategories) {
        _deleteCategory(index);
      }
      _selectedCategories.clear();
      _selectionMode = false;
    });
  }

  void _showDuplicateEntryDialog(String entryType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate $entryType'),
          content: Text('This $entryType already exists.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showCannotDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cannot Delete'),
          content: Text('The "All" category cannot be deleted.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _promptAddCategory() {
    _newCategoryController.clear();
    _selectedIcon = null;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a new category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newCategoryController,
                autofocus: true,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              DropdownButton<IconData>(
                hint: Text('Select Icon'),
                value: _selectedIcon,
                onChanged: (IconData? newValue) {
                  setState(() {
                    _selectedIcon = newValue;
                  });
                },
                items: <IconData>[
                  Icons.favorite, // Default icon olarak kalp
                  Icons.list,
                  Icons.work,
                  Icons.person,
                  Icons.shopping_cart,
                  Icons.star,
                  Icons.home,
                  Icons.school,
                  Icons.fitness_center,
                  Icons.local_cafe,
                  Icons.local_dining,
                  Icons.movie,
                  Icons.music_note,
                  Icons.pets,
                  Icons.shopping_bag,
                  Icons.sports_soccer,
                  Icons.travel_explore,
                  Icons.videogame_asset,
                  Icons.wb_sunny
                ].map<DropdownMenuItem<IconData>>((IconData value) {
                  return DropdownMenuItem<IconData>(
                    value: value,
                    child: Icon(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_selectedIcon == null) {
                  _selectedIcon = Icons.favorite;
                }
                _addCategory(_newCategoryController.text, _selectedIcon!);
                _newCategoryController.clear();
                _selectedIcon = null;
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _promptEditCategory(int index) {
    _newCategoryController.text = _categories[index];
    _selectedIcon = _categoryIcons[_categories[index]];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _newCategoryController,
                autofocus: true,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              DropdownButton<IconData>(
                hint: Text('Select Icon'),
                value: _selectedIcon,
                onChanged: (IconData? newValue) {
                  setState(() {
                    _selectedIcon = newValue;
                  });
                },
                items: <IconData>[
                  Icons.favorite,
                  Icons.list,
                  Icons.work,
                  Icons.person,
                  Icons.shopping_cart,
                  Icons.star,
                  Icons.home,
                  Icons.school,
                  Icons.fitness_center,
                  Icons.local_cafe,
                  Icons.local_dining,
                  Icons.movie,
                  Icons.music_note,
                  Icons.pets,
                  Icons.shopping_bag,
                  Icons.sports_soccer,
                  Icons.travel_explore,
                  Icons.videogame_asset,
                  Icons.wb_sunny
                ].map<DropdownMenuItem<IconData>>((IconData value) {
                  return DropdownMenuItem<IconData>(
                    value: value,
                    child: Icon(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _editCategory(
                    index, _newCategoryController.text, _selectedIcon!);
                _newCategoryController.clear();
                _selectedIcon = null;
                Navigator.pop(context);
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void openTodoList(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoList(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ToDo List',
          style: TextStyle(
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 253, 242, 224),
              fontSize: 40.0),
        ),
        backgroundColor: const Color.fromARGB(255, 159, 37, 0),
        centerTitle: true,
        actions: _selectionMode
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.delete,
                      color: Color.fromARGB(255, 253, 242, 224)),
                  onPressed: _deleteSelectedCategories,
                ),
              ]
            : <Widget>[
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: Color.fromARGB(255, 253, 242, 224)),
                  onSelected: (String result) {
                    if (result == 'delete') {
                      setState(() {
                        _selectionMode = true;
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
      ),
      body: Container(
        color: Color.fromARGB(
            255, 253, 242, 224), // Tüm ekranın arka planı krem rengi
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Kareler için sütun sayısı
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                openTodoList(_categories[index]);
              },
              onLongPress: () {
                if (_categories[index] != 'All') {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Edit'),
                            onTap: () {
                              Navigator.pop(context);
                              _promptEditCategory(index);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.delete),
                            title: Text('Delete'),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteCategory(index);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Card(
                color: Color.fromARGB(255, 173, 216,
                    230), // Kategoriler için mavimsi arka plan rengi
                margin: EdgeInsets.all(8.0),
                child: GridTile(
                  header: Align(
                    alignment: Alignment.topRight,
                    child: _selectionMode && _categories[index] != 'All'
                        ? Checkbox(
                            value: _selectedCategories.contains(index),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCategories.add(index);
                                } else {
                                  _selectedCategories.remove(index);
                                }
                              });
                            },
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_categoryIcons[_categories[index]], size: 50.0),
                      SizedBox(height: 8.0),
                      Text(
                        _categories[index],
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptAddCategory,
        tooltip: 'Add category',
        child: Icon(Icons.add, color: Color.fromARGB(255, 253, 242, 224)),
        backgroundColor: const Color.fromARGB(255, 159, 37, 0),
      ),
    );
  }
}

class TodoItem {
  String task;
  bool isDone;
  DateTime? dueDate;
  String category;

  TodoItem(this.task, this.isDone, this.category, {this.dueDate});

  Map<String, dynamic> toJson() => {
        'task': task,
        'isDone': isDone,
        'dueDate': dueDate?.toIso8601String(),
        'category': category,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      json['task'],
      json['isDone'],
      json['category'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    );
  }
}

class TodoList extends StatefulWidget {
  final String category;

  TodoList({required this.category});

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<TodoItem> _todoItems = [];
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDueDate;
  final List<int> _selectedTodoItems = [];
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadTodoItems();
  }

  Future<void> _loadTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoItemsString = prefs.getString('todoItems');
    if (todoItemsString != null) {
      List<dynamic> jsonList = jsonDecode(todoItemsString);
      List<TodoItem> loadedTodoItems = jsonList.map((jsonItem) {
        if (jsonItem is String) {
          return TodoItem.fromJson(jsonDecode(jsonItem));
        } else {
          return TodoItem.fromJson(jsonItem);
        }
      }).toList();
      setState(() {
        _todoItems.addAll(
          loadedTodoItems.where((item) =>
              item.category == widget.category || widget.category == 'All'),
        );
      });
      print('Görevler yüklendi: $_todoItems');
    } else {
      print('Kayıtlı görev bulunamadı.');
    }
  }

  Future<void> _saveTodoItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList =
        _todoItems.map((todoItem) => jsonEncode(todoItem.toJson())).toList();
    await prefs.setString('todoItems', jsonEncode(jsonList));
    print('Görevler kaydedildi: $jsonList');
  }

  void _addTodoItem(String task, {DateTime? dueDate}) {
    if (task.isNotEmpty && !_todoItems.any((item) => item.task == task)) {
      setState(() {
        _todoItems
            .add(TodoItem(task, false, widget.category, dueDate: dueDate));
      });
      _saveTodoItems();
    } else {
      _showDuplicateEntryDialog('Task');
    }
  }

  void _editTodoItem(int index, String newTask, {DateTime? newDueDate}) {
    if (newTask.isNotEmpty && !_todoItems.any((item) => item.task == newTask)) {
      setState(() {
        _todoItems[index].task = newTask;
        if (newDueDate != null) {
          _todoItems[index].dueDate = newDueDate;
        }
      });
      _saveTodoItems();
    } else {
      _showDuplicateEntryDialog('Task');
    }
  }

  void _toggleTodoItem(int index) {
    setState(() {
      _todoItems[index].isDone = !_todoItems[index].isDone;
    });
    _saveTodoItems();
  }

  void _deleteTodoItem(int index) {
    setState(() {
      _todoItems.removeAt(index);
    });
    _saveTodoItems();
  }

  void _deleteSelectedTodoItems() {
    setState(() {
      _selectedTodoItems.sort((a, b) => b.compareTo(a));
      for (var index in _selectedTodoItems) {
        _deleteTodoItem(index);
      }
      _selectedTodoItems.clear();
      _selectionMode = false;
    });
  }

  void _promptAddTodoItem() {
    _taskController.clear();
    _selectedDueDate = null;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add a new task',
            style: TextStyle(
                fontFamily: 'Times New Roman',
                color: Color.fromARGB(255, 53, 41, 125),
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Color.fromARGB(255, 253, 242, 224),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                autofocus: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedDueDate = await _selectDueDate(context);
                },
                child: Text('Select Due Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  _addTodoItem(_taskController.text, dueDate: _selectedDueDate);
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<DateTime?> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    return picked;
  }

  void _promptEditTodoItem(int index) {
    _taskController.text = _todoItems[index].task;
    _selectedDueDate = _todoItems[index].dueDate;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                autofocus: true,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  _selectedDueDate = await _selectDueDate(context);
                },
                child: Text('Select Due Date'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (_taskController.text.isNotEmpty) {
                  _editTodoItem(index, _taskController.text,
                      newDueDate: _selectedDueDate);
                  Navigator.pop(context);
                }
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _showDuplicateEntryDialog(String entryType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate $entryType'),
          content: Text('This $entryType already exists.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodoItem(TodoItem todoItem, int index) {
    return Column(
      children: <Widget>[
        Dismissible(
          key: UniqueKey(),
          background: Container(
            color: const Color.fromARGB(255, 159, 37, 0),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20.0),
            child: Text(
              'Delete',
              style: TextStyle(
                  fontFamily: 'Times New Roman',
                  color: Color.fromARGB(255, 253, 242, 224),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ),
          secondaryBackground: Container(
            color: Color.fromARGB(255, 53, 41, 125),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            child: Text(
              'Edit',
              style: TextStyle(
                  fontFamily: 'Times New Roman',
                  color: Color.fromARGB(255, 253, 242, 224),
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Text(
                      'Are you sure you want to delete this task?',
                      style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Times New Roman',
                          color: Color.fromARGB(255, 53, 41, 125),
                          fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Color.fromARGB(255, 253, 242, 224),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 20.0, fontFamily: 'Times New Roman'),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text(
                          'Delete',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'Times New Roman',
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else if (direction == DismissDirection.endToStart) {
              _promptEditTodoItem(index);
              return false;
            }
            return false;
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              _deleteTodoItem(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${todoItem.task} dismissed")),
              );
            }
          },
          child: ListTile(
            title: Text(
              todoItem.task,
              style: TextStyle(
                fontSize: 20.0,
                fontFamily: 'Times New Roman',
                fontWeight: FontWeight.bold,
                decoration: todoItem.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: todoItem.dueDate != null
                ? Text(
                    'Due: ${todoItem.dueDate!.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Times New Roman',
                    ),
                  )
                : null,
            trailing: _selectionMode
                ? Checkbox(
                    value: _selectedTodoItems.contains(index),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTodoItems.add(index);
                        } else {
                          _selectedTodoItems.remove(index);
                        }
                      });
                    },
                  )
                : null,
            onTap: () {
              if (_selectionMode) {
                setState(() {
                  if (_selectedTodoItems.contains(index)) {
                    _selectedTodoItems.remove(index);
                  } else {
                    _selectedTodoItems.add(index);
                  }
                });
              }
            },
          ),
        ),
        Divider(
          color: Colors.black,
          thickness: 1.0,
        ),
      ],
    );
  }

  Widget _buildTodoList() {
    return ReorderableListView(
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final TodoItem item = _todoItems.removeAt(oldIndex);
          _todoItems.insert(newIndex, item);
        });
        _saveTodoItems();
      },
      children: List.generate(
        _todoItems.length,
        (index) {
          return ListTile(
            key: UniqueKey(),
            title: _buildTodoItem(_todoItems[index], index),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category,
          style: TextStyle(
              fontFamily: 'Times New Roman',
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 253, 242, 224),
              fontSize: 40.0),
        ),
        backgroundColor: const Color.fromARGB(255, 159, 37, 0),
        centerTitle: true,
        actions: _selectionMode
            ? <Widget>[
                IconButton(
                  icon: Icon(Icons.delete,
                      color: Color.fromARGB(255, 253, 242, 224)),
                  onPressed: _deleteSelectedTodoItems,
                ),
              ]
            : <Widget>[
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: Color.fromARGB(255, 253, 242, 224)),
                  onSelected: (String result) {
                    if (result == 'delete') {
                      setState(() {
                        _selectionMode = true;
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 20.0),
        child: _buildTodoList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _promptAddTodoItem,
        tooltip: 'Add task',
        foregroundColor: Color.fromARGB(255, 253, 242, 224),
        child: Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 159, 37, 0),
      ),
      backgroundColor: Color.fromARGB(255, 253, 242, 224),
    );
  }
}
