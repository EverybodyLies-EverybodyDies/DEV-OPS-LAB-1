
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

# Створення вебдодатка
app = FastAPI(
    title="Task API",
    description="REST API для управління завданнями",
    version="1.0.0"
)


# Модель даних завдання
class TaskCreate(BaseModel):
    title: str = Field(
        min_length=1,
        max_length=100,
        description="Назва завдання"
    )


# Модель відповіді
class Task(TaskCreate):
    id: int
    completed: bool = False


# Тимчасове сховище завдань
tasks = {}
next_id = 1


# Головний endpoint
@app.get("/")
def home():
    return {
        "message": "Task API працює!",
        "docs": "/docs"
    }


# Отримання всіх завдань
@app.get("/tasks")
def get_tasks():
    return list(tasks.values())


# Отримання завдання за ID
@app.get("/tasks/{task_id}")
def get_task(task_id: int):

    if task_id not in tasks:
        raise HTTPException(
            status_code=404,
            detail="Завдання не знайдено"
        )

    return tasks[task_id]


# Створення нового завдання
@app.post("/tasks", response_model=Task, status_code=201)
def create_task(task_data: TaskCreate):

    global next_id

    task = Task(
        id=next_id,
        title=task_data.title,
        completed=False
    )

    tasks[next_id] = task

    next_id += 1

    return task


# Зміна статусу завдання
@app.patch("/tasks/{task_id}")
def complete_task(task_id: int):

    if task_id not in tasks:
        raise HTTPException(
            status_code=404,
            detail="Завдання не знайдено"
        )

    task = tasks[task_id]

    task.completed = not task.completed

    return task


# Видалення завдання
@app.delete("/tasks/{task_id}")
def delete_task(task_id: int):

    if task_id not in tasks:
        raise HTTPException(
            status_code=404,
            detail="Завдання не знайдено"
        )

    del tasks[task_id]

    return {
        "message": "Завдання успішно видалено",
        "task_id": task_id
    }
