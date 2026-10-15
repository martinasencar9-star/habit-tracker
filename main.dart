import 'package:flutter/material.dart';

void main() {
  runApp(const HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF48FB1),
          primary: const Color(0xFFF48FB1),
          secondary: const Color(0xFF80CBC4),
          surface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

// Modelo de Hábitos
class Habit {
  String id;
  String title;
  int streak;
  Map<String, bool> history;
  TimeOfDay? reminderTime;

  Habit({
    required this.id,
    required this.title,
    this.streak = 0,
    required this.history,
    this.reminderTime,
  });
}

// Modelo de Tareas
class TaskItem {
  String id;
  String title;
  String date;
  bool isCompleted;
  TimeOfDay? reminderTime;

  TaskItem({
    required this.id,
    required this.title,
    required this.date,
    this.isCompleted = false,
    this.reminderTime,
  });
}

// Pantalla Principal de Navegación
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  
  // Controlador persistente para notas
  final TextEditingController _noteController = TextEditingController();

  DateTime today = DateTime.now();
  String get todayKey =>
      "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

  List<Habit> habits = [];
  List<TaskItem> tasks = [];
  List<String> notes = [];

  @override
  void initState() {
    super.initState();
    // Inicialización dinámica con la fecha de hoy real
    habits = [
      Habit(id: '1', title: 'Meditar 10 minutos', streak: 4, history: {todayKey: false}),
      Habit(id: '2', title: 'Beber 2L de agua', streak: 12, history: {todayKey: true}),
    ];
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHabitsTab(),
      _buildTasksTab(),
      _buildNotesTab(),
      _buildAnalyticsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hoy, ${today.day}/${today.month}/${today.year}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFF48FB1),
        elevation: 0,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF26A69A),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Hábitos'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Tareas'),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt_outlined), label: 'Notas'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Balance'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF80CBC4),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => _showAddDialog(_selectedIndex),
            )
          : null,
    );
  }

  // --- SECCIÓN HÁBITOS ---
  Widget _buildHabitsTab() {
    final completedCount = habits.where((h) => h.history[todayKey] == true).length;
    final double completionRate = habits.isEmpty ? 0 : completedCount / habits.length;

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8BBD0).withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progreso Diario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('$completedCount de ${habits.length} completados (${(completionRate * 100).toStringAsFixed(0)}%)'),
                ],
              ),
              CircularProgressIndicator(
                value: completionRate,
                backgroundColor: Colors.white,
                color: const Color(0xFF4DB6AC),
              )
            ],
          ),
        ),
        Expanded(
          child: habits.isEmpty
              ? const Center(child: Text('No hay hábitos registrados.'))
              : ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    bool isDone = habit.history[todayKey] ?? false;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Checkbox(
                          activeColor: const Color(0xFF80CBC4),
                          value: isDone,
                          onChanged: (val) {
                            setState(() {
                              bool nextVal = val ?? false;
                              habit.history[todayKey] = nextVal;
                              if (nextVal) {
                                habit.streak += 1;
                              } else {
                                habit.streak = (habit.streak > 0) ? habit.streak - 1 : 0;
                              }
                            });
                          },
                        ),
                        title: Text(
                          habit.title,
                          style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8BBD0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🔥 ${habit.streak} días',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- SECCIÓN TAREAS ---
  Widget _buildTasksTab() {
    final todayTasks = tasks.where((t) => t.date == todayKey).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Lista de Tareas Específicas del Día', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: todayTasks.isEmpty
              ? const Center(child: Text('No hay tareas programadas para hoy.'))
              : ListView.builder(
                  itemCount: todayTasks.length,
                  itemBuilder: (context, index) {
                    final task = todayTasks[index];
                    return ListTile(
                      leading: Checkbox(
                        activeColor: const Color(0xFF4DB6AC),
                        value: task.isCompleted,
                        onChanged: (val) {
                          setState(() {
                            task.isCompleted = val ?? false;
                          });
                        },
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- SECCIÓN NOTAS ---
  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: 'Nueva Nota / Reflexión',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF4DB6AC)),
                onPressed: () {
                  if (_noteController.text.trim().isNotEmpty) {
                    setState(() {
                      notes.add(_noteController.text.trim());
                      _noteController.clear();
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: notes.isEmpty
                ? const Center(child: Text('No tienes notas guardadas.'))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(notes[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => setState(() => notes.removeAt(index)),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  // --- SECCIÓN BALANCE SEMANAL ---
  Widget _buildAnalyticsTab() {
    final completedCount = habits.where((h) => h.history[todayKey] == true).length;
    final maxStreak = habits.fold<int>(0, (max, h) => h.streak > max ? h.streak : max);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Balance del Día', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_view_week, color: Color(0xFFF48FB1)),
                    title: const Text('Completados hoy'),
                    trailing: Text(
                      '$completedCount / ${habits.length}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.local_fire_department, color: Color(0xFF4DB6AC)),
                    title: const Text('Mejor racha activa'),
                    trailing: Text(
                      '$maxStreak Días',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showAddDialog(int type) {
    final TextEditingController dialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 0 ? 'Crear Nuevo Hábito' : 'Crear Tarea del Día'),
        content: TextField(
          controller: dialogController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre o descripción'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF48FB1)),
            onPressed: () {
              final text = dialogController.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (type == 0) {
                    habits.add(Habit(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: text,
                      history: {todayKey: false},
                    ));
                  } else {
                    tasks.add(TaskItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: text,
                      date: todayKey,
                    ));
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}