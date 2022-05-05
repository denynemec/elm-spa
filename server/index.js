const express = require('express');

const error = false;

let id = 1;
let todos = [
  {
    id: id++,
    label: 'Finish AFP HW09',
    completed: false,
  },
  {
    id: id++,
    label: 'Create something useful',
    completed: false,
  },
];

const app = express();

app.use((_, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header(
    'Access-Control-Allow-Headers',
    'Origin, X-Requested-With, Content-Type, Accept',
  );
  res.header('Access-Control-Allow-Methods', 'PUT, POST, GET, DELETE, OPTIONS');
  next();
});

app.use((req, res, next) => {
  if (error && req.method !== 'OPTIONS') {
    res.status(400).send();
  } else {
    next();
  }
});

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.get('/todos', (_, res) => {
  res.send(todos);
});

app.post('/todos', (req, res) => {
  todos.unshift({ id: id++, completed: false, label: req.body.label });
  res.status(201).send();
});

app.put('/todos/:id', (req, res) => {
  todos = todos.map((todo) => {
    if (todo.id.toString() === req.params.id) {
      todo.label = req.body.label;
      todo.completed = req.body.completed;
    }
    return todo;
  });
  res.status(201).send();
});

app.listen(4000);
