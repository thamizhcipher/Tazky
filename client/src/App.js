import React from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';
import {BrowserRouter as Router, Routes, Route} from 'react-router-dom'
import Login from './components/Login/Login';
import Register from './components/Register/Register';
import Tasks from './components/Tasks/Tasks';
import PrivateRoute from './components/PrivateRoute';


function App() {
  return (
    <Router>
      <Routes>
        <Route path='/' element={<Login />} />
        <Route path='/register' element={<Register />} />
        
        <Route element={<PrivateRoute />}>
          <Route path='/home' element={<Tasks />} />
        </Route>

      </Routes>
    </Router>
  );
}

export default App;
