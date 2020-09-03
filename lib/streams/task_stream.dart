import 'package:flutter_sample_test_3/category.dart';
import 'package:flutter_sample_test_3/data_provider.dart';
import 'package:flutter_sample_test_3/task.dart';
import 'package:rxdart/rxdart.dart';

class TaskStream {
  BehaviorSubject<List<Task>> _homeSubject;
  BehaviorSubject<List<Task>> _categorySubject;

  List<Task> _taskListToShowHome;
  List<Task> _taskListToShowCategory;
  List<Task> _allTaskList;

  DateTime _selectedDate;
  DateTime _today;
  bool _showDatelessTasks;

  Category _selectedCategory;

  TaskStream(DataProvider provider) {
    var _now = DateTime.now();
    _today = DateTime(_now.year, _now.month, _now.day);

    _allTaskList = [];
    _taskListToShowHome = [];
    _taskListToShowCategory = [];

    _homeSubject = BehaviorSubject<List<Task>>();
    _categorySubject = BehaviorSubject<List<Task>>();

    _showDatelessTasks = provider.showDatelessTasks;
    _selectedDate = provider.selectedDate;

    _selectedCategory = null;

    provider.addListener(() {
      //Did anything taskStream care about change?
      if ((provider.showDatelessTasks != _showDatelessTasks) ||
          (provider.selectedDate != _selectedDate)) {
        _showDatelessTasks = provider.showDatelessTasks;
        _selectedDate = provider.selectedDate;

        //Emit a new stream based on these new values
        updateHomeStream();
      }
    });
  }

  ValueStream<List<Task>> get homePageStream => _homeSubject.stream;

  ValueStream<List<Task>> get categoryPageStream => _categorySubject.stream;

  updateHomeStream() {
    //Add the tasks from the selected date
    _taskListToShowHome = _allTaskList.where((task) => task.date == _selectedDate).toList();
    if (_showDatelessTasks && _selectedDate == _today)
      _taskListToShowHome += _allTaskList.where((task) => task.date == null).toList();

    _homeSubject.add(_taskListToShowHome);
  }

  updateCategoryStream() {
    //If no card is displaying right now, the selectedCategory should be null
    //Avoid emitting a stream in this null case
    if (_selectedCategory != null) {
      //Check if the category to show is "all"
      if (_selectedCategory.name == "all") {_taskListToShowCategory = _allTaskList;}

      //Otherwise try to find all tasks belonging to that category
      else _taskListToShowCategory = _allTaskList.where((task) => task.category == _selectedCategory.name).toList();



      _categorySubject.add(_taskListToShowCategory);
    }
  }

  closeCard() {
    _selectedCategory = null;
  }

  openCard(Category category) {
    //TODO null safety stuff?
    if (_selectedCategory == null) {
      _selectedCategory = category;
      updateCategoryStream();
    } else if (_selectedCategory != category) updateCategoryStream();
  }

  addTask(Task task) {
    //add task to list
    _allTaskList.add(task);
    //Emit a new stream of tasks to show using the current selected date
    updateHomeStream();
    updateCategoryStream();
  }

  removeTask(Task task) {
    //Remove Task from list
    _allTaskList.removeWhere((element) => element.databaseKey == task.databaseKey);
    //Emit a new stream of tasks to show using the current selected date
    updateHomeStream();
    updateCategoryStream();
  }

  dispose() {
    _categorySubject.close();
    _homeSubject.close();
  }
}
