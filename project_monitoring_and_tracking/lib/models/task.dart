class Task {
  String taskId; // Unique identifier for the task
  String taskName; // Name of the task
  String taskDescription; // Description of the task
  DateTime dueDate; // Due date for the task
  int taskStatus; // Flag indicating whether the task is completed
  /*
  * try to make is completed different like it have status of 3 values instead of 2
  * 1: haven't started
  * 2: in progress
  * 3: completed
  * */

  // String assignedTo; // User ID of the assigned team member: in future update

  // Constructor
  Task({
    required this.taskId,
    required this.taskName,
    required this.taskDescription,
    required this.dueDate,
    required this.taskStatus,
    // required this.assignedTo,
  });


}
// Enum for task completion status
enum TaskStatus {
  notStarted,
  inProgress,
  completed,
}