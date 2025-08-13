using TodoApi;

namespace TodoApi.Tests;

public class UnitTest1
{
    [Fact]
    public void Todo_Model_Should_Have_Properties()
    {
        var todo = new Todo
        {
            Id = 1,
            Title = "Test Todo",
            IsCompleted = false
        };

        Assert.Equal(1, todo.Id);
        Assert.Equal("Test Todo", todo.Title);
        Assert.False(todo.IsCompleted);
    }

    [Fact]
    public void Todo_IsCompleted_Should_Be_Settable()
    {
        var todo = new Todo
        {
            Id = 1,
            Title = "Test Todo",
            IsCompleted = false
        };

        todo.IsCompleted = true;

        Assert.True(todo.IsCompleted);
    }

    [Fact]
    public void Todo_Should_Have_Default_Title()
    {
        var todo = new Todo
        {
            Id = 1,
            IsCompleted = false
        };

        Assert.Equal(string.Empty, todo.Title);
    }
}
