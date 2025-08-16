module SendMessage::TaskManager {

    use aptos_framework::signer;
    use std::string::String;
    use std::vector;

    /// Struct representing a task
    struct Task has store, key {
        title: String,
        description: String,
        is_completed: bool,
        created_at: u64,
    }

    /// Struct to store user's tasks
    struct UserTasks has store, key {
        tasks: vector<Task>,
    }

    /// Function to create a new task
    public fun create_task(
        user: &signer,
        title: String,
        description: String
    ) acquires UserTasks {
        let user_addr = signer::address_of(user);
        
        // Check if UserTasks exists, if not create it
        if (!exists<UserTasks>(user_addr)) {
            let user_tasks = UserTasks {
                tasks: vector::empty(),
            };
            move_to(user, user_tasks);
        };

        let user_tasks = borrow_global_mut<UserTasks>(user_addr);
        let new_task = Task {
            title,
            description,
            is_completed: false,
            created_at: 0, // You can use timestamp::now_seconds() if needed
        };
        vector::push_back(&mut user_tasks.tasks, new_task);
    }

    /// Function to mark a task as completed
    public fun complete_task(user: &signer, task_index: u64) acquires UserTasks {
        let user_addr = signer::address_of(user);
        let user_tasks = borrow_global_mut<UserTasks>(user_addr);
        
        // Ensure task index is valid
        assert!(task_index < vector::length(&user_tasks.tasks), 1);
        
        let task = vector::borrow_mut(&mut user_tasks.tasks, task_index);
        task.is_completed = true;
    }
}
