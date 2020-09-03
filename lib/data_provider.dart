import 'package:flutter/cupertino.dart';
import 'package:flutter_sample_test_3/color_constants.dart';
import 'package:flutter_sample_test_3/streams/category_stream.dart';
import 'package:flutter_sample_test_3/streams/task_stream.dart';
import 'package:flutter_sample_test_3/task.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DataProvider extends ChangeNotifier {
  CategoryStream categoryStream;
  TaskStream taskStream;
  ColorConstants colorConstants;
  bool showDatelessTasks;
  bool nightMode;
  bool autoDelete; //AutoDeletes old-done tasks during load-time
  bool defaultToSticky;
  bool suggestCategory;

  DateTime selectedDate;
  String dayString;
  String _todayString;
  DateTime _now;
  DateTime _today;
  StoreRef _store;
  Database _db;

  DataProvider();

  //Need to load data from internal database
  //Dart does not support async instantiation
  ///Loads preferences and saved tasks from memory
  init() async {
    await loadDatabase();
    await loadPrefs();

    categoryStream = CategoryStream();
    taskStream = TaskStream(this);

    colorConstants = ColorConstants(nightMode);
    loadData();

    _now = DateTime.now();
    _today = DateTime(_now.year, _now.month, _now.day);

    //The app should start out with the starting date selected as today
    selectedDate = _today;
    _todayString = "Today's tasks";
    dayString = _todayString;
  }

  toggleNightMode() {
    nightMode = !nightMode;
    colorConstants = ColorConstants(nightMode);
    notifyListeners();
    savePrefs();
  }

  setSelectedDate(DateTime date) {
    //The DateTime supplied by the Calendar widget has a different format
    //Need to reformat it to match the rest of the code
    selectedDate = DateTime(date.year, date.month, date.day);
    dayString =
        (selectedDate == _today) ? _todayString : "${DateFormat.MMMMd().format(selectedDate)}";
    notifyListeners();
  }

  updateTask(Task task) {
    categoryStream.toggleTask(task);
    notifyListeners();
    _store.record(task.databaseKey).update(_db, {'isDone': task.isDone});
  }

  update() {
    notifyListeners();
  }

  ///Add task to the cache-memory list, notify all listeners for repaint and add it to database
  addTask(Task task, [bool notifyRightNow = true, bool addToDatabase = true]) async {
    categoryStream.addTask(task);
    taskStream.addTask(task);

    if (notifyRightNow) {
      notifyListeners();
    }
    if (addToDatabase) {
      int _key = await _store.add(_db, task.toJson());
      task.databaseKey = _key;
    }
  }

  addTaskBatch(List<Task> tasks, [bool addToDatabase = true]) async {
    tasks.forEach((task) => addTask(task, false, addToDatabase));
    notifyListeners();
  }

  removeTask(Task task) {
    //Remove task from 1. All Category list, Its own category list and database
    categoryStream.removeTask(task);
    taskStream.removeTask(task);

    _store.record(task.databaseKey).delete(_db);
    notifyListeners();
  }

  loadDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    String dbPath = dir.path + 'tasks.db';
    DatabaseFactory dbFactory = databaseFactoryIo;
    _db = await dbFactory.openDatabase(dbPath);
    _store = StoreRef.main();
  }

  ///Loads data from the database [_db] using store [_store]
  ///Be sure to open the database and load the prefs before calling [loadData]
  loadData() async {
    var _allTasksInMemory = await _store.find(_db, finder: Finder(filter: Filter.notNull("name")));
    List<Task> _loaded = _allTasksInMemory.map((e) {
      Task _task = Task.fromJson(e.value);
      _task.databaseKey = e.key;
      return _task;
    }).toList();

    ///Delete old ticked out tasks from database if [autoDelete] is enabled
    if (autoDelete) autoDeleteOnLoad(_loaded);
    addTaskBatch(_loaded, false);
  }

  ///Removes old tasks from database that are older than [maxDaysToKeep]
  ///Although it still loads these tasks for this session
  autoDeleteOnLoad(List<Task> loaded, [int maxDaysToKeep = 2]) {
    loaded.where((task) {
      if (task.date != null)
        return task.date.isBefore(_today.subtract(Duration(days: maxDaysToKeep))) && task.isDone;
      else
        return false;
    }).forEach((task) {
      _store.record(task.databaseKey).delete(_db);
      print("deleted ${task.name}");
    });
  }

  ///Loads saved preferences from the database [_db] using store [_store]
  ///Be sure to open the database before calling [loadPrefs]
  loadPrefs() async {
    //Edit both save and load prefs when adding new prefs
    //Find previously saved Prefs
    var _prefs = await _store.findFirst(_db, finder: Finder(filter: Filter.byKey('prefs')));
    if (_prefs != null) {
      nightMode = _prefs.value["nightMode"] ?? false;
      showDatelessTasks = _prefs.value["showDatelessTasks"] ?? true;
      autoDelete = _prefs.value["autoDelete"] ?? false;
      defaultToSticky = _prefs.value["defaultToSticky"] ?? false;
      suggestCategory = _prefs.value["suggestCategory"] ?? true;
    }
    //If nothing found, save it defaults

    else
      _store.record('prefs').put(_db, {
        "nightMode": false,
        "showDatelessTasks": true,
        "autoDelete": false,
        "defaultToSticky": false,
        "suggestCategory": true
      });
  }

  ///Save the current preferences in the database using a the record key "prefs"
  ///Call each time a pref is changed and needs saving
  savePrefs() async {
    notifyListeners();
    await _store.record('prefs').put(_db, {
      "nightMode": nightMode,
      "showDatelessTasks": showDatelessTasks,
      "autoDelete": autoDelete,
      "defaultToSticky": defaultToSticky,
      "suggestCategory": suggestCategory
    });
  }

  @override
  void dispose() {
    _db.close();
    categoryStream.dispose();
    taskStream.dispose();
    super.dispose();
  }
}
