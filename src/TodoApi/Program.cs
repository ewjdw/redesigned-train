using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Check if we should use database or in-memory storage
var useDatabase = !string.IsNullOrEmpty(builder.Configuration.GetConnectionString("DefaultConnection"))
                  && builder.Configuration.GetValue<bool>("UseDatabase", true);

// Add Entity Framework
builder.Services.AddDbContext<TodoDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Replace in-memory list with database context
var todos = new List<Todo>(); // Fallback for local development without SQL Server

// Ensure database is created (only if using database)
if (useDatabase)
{
    try
    {
        using var scope = app.Services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<TodoDbContext>();
        context.Database.EnsureCreated();
    }
    catch (Exception ex)
    {
        // Log error but don't crash - fall back to in-memory storage
        app.Logger.LogWarning("Database initialization failed: {Error}. Using in-memory storage.", ex.Message);
        useDatabase = false;
    }
}

// Health check endpoint
app.MapGet("/health", () => "Healthy");

// Get all todos
app.MapGet("/api/todos", async (TodoDbContext? db) =>
{
    try
    {
        return useDatabase && db != null ? await db.Todos.ToListAsync() : todos;
    }
    catch
    {
        return todos; // Fallback to in-memory if database fails
    }
});

// Get todo by id
app.MapGet("/api/todos/{id}", async (int id, TodoDbContext? db) =>
{
    try
    {
        if (useDatabase && db != null)
        {
            var todo = await db.Todos.FindAsync(id);
            return todo is not null ? Results.Ok(todo) : Results.NotFound();
        }
        else
        {
            var todo = todos.FirstOrDefault(t => t.Id == id);
            return todo is not null ? Results.Ok(todo) : Results.NotFound();
        }
    }
    catch
    {
        var todo = todos.FirstOrDefault(t => t.Id == id);
        return todo is not null ? Results.Ok(todo) : Results.NotFound();
    }
});

// Create a new todo
app.MapPost("/api/todos", async (CreateTodoRequest request, TodoDbContext? db) =>
{
    try
    {
        if (useDatabase && db != null)
        {
            var todo = new Todo
            {
                Title = request.Title,
                IsCompleted = false,
                CreatedAt = DateTime.UtcNow
            };
            db.Todos.Add(todo);
            await db.SaveChangesAsync();
            return Results.Created($"/api/todos/{todo.Id}", todo);
        }
        else
        {
            var todo = new Todo
            {
                Id = todos.Count + 1,
                Title = request.Title,
                IsCompleted = false,
                CreatedAt = DateTime.UtcNow
            };
            todos.Add(todo);
            return Results.Created($"/api/todos/{todo.Id}", todo);
        }
    }
    catch
    {
        var todo = new Todo
        {
            Id = todos.Count + 1,
            Title = request.Title,
            IsCompleted = false,
            CreatedAt = DateTime.UtcNow
        };
        todos.Add(todo);
        return Results.Created($"/api/todos/{todo.Id}", todo);
    }
});

// Update a todo
app.MapPut("/api/todos/{id}", async (int id, UpdateTodoRequest request, TodoDbContext? db) =>
{
    try
    {
        if (useDatabase && db != null)
        {
            var todo = await db.Todos.FindAsync(id);
            if (todo is null) return Results.NotFound();

            todo.Title = request.Title ?? todo.Title;
            todo.IsCompleted = request.IsCompleted ?? todo.IsCompleted;
            await db.SaveChangesAsync();
            return Results.Ok(todo);
        }
        else
        {
            var todo = todos.FirstOrDefault(t => t.Id == id);
            if (todo is null) return Results.NotFound();

            todo.Title = request.Title ?? todo.Title;
            todo.IsCompleted = request.IsCompleted ?? todo.IsCompleted;
            return Results.Ok(todo);
        }
    }
    catch
    {
        var todo = todos.FirstOrDefault(t => t.Id == id);
        if (todo is null) return Results.NotFound();

        todo.Title = request.Title ?? todo.Title;
        todo.IsCompleted = request.IsCompleted ?? todo.IsCompleted;
        return Results.Ok(todo);
    }
});

// Delete a todo
app.MapDelete("/api/todos/{id}", async (int id, TodoDbContext? db) =>
{
    try
    {
        if (useDatabase && db != null)
        {
            var todo = await db.Todos.FindAsync(id);
            if (todo is null) return Results.NotFound();

            db.Todos.Remove(todo);
            await db.SaveChangesAsync();
            return Results.NoContent();
        }
        else
        {
            var todo = todos.FirstOrDefault(t => t.Id == id);
            if (todo is null) return Results.NotFound();

            todos.Remove(todo);
            return Results.NoContent();
        }
    }
    catch
    {
        var todo = todos.FirstOrDefault(t => t.Id == id);
        if (todo is null) return Results.NotFound();

        todos.Remove(todo);
        return Results.NoContent();
    }
});

// Serve a simple HTML page for testing
app.MapGet("/", () => Results.Content("""
<!DOCTYPE html>
<html>
<head>
    <title>Todo API</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .todo-item { background: #f9f9f9; margin: 10px 0; padding: 15px; border-radius: 5px; border: 1px solid #ddd; }
        .completed { text-decoration: line-through; color: #888; }
        input[type="text"] { width: 70%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; }
        button { padding: 12px 20px; margin: 5px; background: #007cba; color: white; border: none; border-radius: 5px; cursor: pointer; }
        button:hover { background: #005a8b; }
        .delete-btn { background: #dc3545; }
        .delete-btn:hover { background: #c82333; }
        .complete-btn { background: #28a745; }
        .complete-btn:hover { background: #218838; }
        .stats { background: #e7f3ff; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Simple Todo Application</h1>
        <p>A minimal API sample application for Azure deployment</p>
        
        <div>
            <input type="text" id="todoInput" placeholder="Enter a new todo..." />
            <button onclick="addTodo()">Add Todo</button>
        </div>
        
        <div class="stats">
            <strong>Stats:</strong> <span id="stats">0 total, 0 completed</span>
        </div>
        
        <div id="todoList"></div>
        
        <div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 5px;">
            <h3>API Endpoints:</h3>
            <ul>
                <li><strong>GET /api/todos</strong> - Get all todos</li>
                <li><strong>POST /api/todos</strong> - Create a new todo</li>
                <li><strong>PUT /api/todos/{id}</strong> - Update a todo</li>
                <li><strong>DELETE /api/todos/{id}</strong> - Delete a todo</li>
                <li><strong>GET /health</strong> - Health check</li>
            </ul>
        </div>
    </div>

    <script>
        let todos = [];

        async function loadTodos() {
            try {
                const response = await fetch('/api/todos');
                todos = await response.json();
                renderTodos();
                updateStats();
            } catch (error) {
                console.error('Error loading todos:', error);
                document.getElementById('todoList').innerHTML = '<p style="color: red;">Error loading todos. Please try again.</p>';
            }
        }

        async function addTodo() {
            const input = document.getElementById('todoInput');
            const title = input.value.trim();
            if (!title) return;

            try {
                const response = await fetch('/api/todos', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ title })
                });
                if (response.ok) {
                    input.value = '';
                    loadTodos();
                }
            } catch (error) {
                console.error('Error adding todo:', error);
            }
        }

        async function toggleTodo(id, isCompleted) {
            try {
                await fetch(`/api/todos/${id}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ isCompleted: !isCompleted })
                });
                loadTodos();
            } catch (error) {
                console.error('Error updating todo:', error);
            }
        }

        async function deleteTodo(id) {
            if (!confirm('Are you sure you want to delete this todo?')) return;
            
            try {
                await fetch(`/api/todos/${id}`, { method: 'DELETE' });
                loadTodos();
            } catch (error) {
                console.error('Error deleting todo:', error);
            }
        }

        function updateStats() {
            const total = todos.length;
            const completed = todos.filter(t => t.isCompleted).length;
            document.getElementById('stats').textContent = `${total} total, ${completed} completed`;
        }

        function renderTodos() {
            const list = document.getElementById('todoList');
            if (todos.length === 0) {
                list.innerHTML = '<p style="text-align: center; color: #666; margin: 30px 0;">No todos yet. Add one above!</p>';
                return;
            }
            
            list.innerHTML = todos.map(todo => `
                <div class="todo-item">
                    <span class="${todo.isCompleted ? 'completed' : ''}" style="display: block; margin-bottom: 10px;">
                        ${todo.title}
                    </span>
                    <button class="complete-btn" onclick="toggleTodo(${todo.id}, ${todo.isCompleted})">
                        ${todo.isCompleted ? 'Mark Incomplete' : 'Mark Complete'}
                    </button>
                    <button class="delete-btn" onclick="deleteTodo(${todo.id})">Delete</button>
                    <small style="display: block; color: #666; margin-top: 10px;">
                        Created: ${new Date(todo.createdAt).toLocaleString()}
                    </small>
                </div>
            `).join('');
        }

        // Load todos on page load
        loadTodos();
        
        // Allow Enter key to add todo
        document.getElementById('todoInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') addTodo();
        });
    </script>
</body>
</html>
""", "text/html"));

app.Run();

// Make Program class accessible to tests
public partial class Program { }

// DbContext for Todo data
public class TodoDbContext : DbContext
{
    public TodoDbContext(DbContextOptions<TodoDbContext> options) : base(options) { }

    public DbSet<Todo> Todos { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Todo>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).IsRequired().HasMaxLength(500);
            entity.Property(e => e.CreatedAt).HasDefaultValueSql("GETUTCDATE()");
        });
    }
}

// Todo model
public record Todo
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public bool IsCompleted { get; set; }
    public DateTime CreatedAt { get; set; }
}

// Request models
public record CreateTodoRequest(string Title);
public record UpdateTodoRequest(string? Title, bool? IsCompleted);
