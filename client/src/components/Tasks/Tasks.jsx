import React, { useEffect, useState } from 'react'
import axios from '../../axiosInstance'
import './Tasks.css'
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import InputGroup from 'react-bootstrap/InputGroup';
import { useNavigate } from 'react-router-dom';
const Tasks = () => {
    const [newTask,setNewTask] = useState("")
    const [tasks,setTasks] = useState([])
    const [originalTasks,setOriginalTasks] = useState([])
    const [isSorted,setIsSorted] = useState(false)
    const navigate = useNavigate()

    useEffect(()=>{
        fetchTasks()
    },[])

    const fetchTasks= async ()=>{
        try 
        {
            const res= await axios.get("/tasks")    
           console.log(res.data.tasks);
           
            setTasks(res.data.tasks);
            setOriginalTasks(res.data.tasks)
            
        } catch (error) {
            console.log(error);
            
        }
    }
    const addTask= async()=>{
        try 
        {
            const res= await axios.post("/tasks",{title:newTask}) 
            
            if(res.status===200)
            {
                setNewTask('')
                fetchTasks()
                setIsSorted(false)
                alert("Task added successfully")    
            }
            else
                alert("Task was not added")   
        } catch (error) {
            console.log(error);
            
        }
    }

    const deleteTask= async (taskId)=>{
        try {
            await axios.delete(`/tasks/${taskId}`)
            fetchTasks();
            alert("task deleted successfully")
        } catch (error) {
            console.log(error);
            
        }
    }

    const markCompleted = async (taskId)=>{
        try {
            await axios.put(`/tasks/${taskId}`)
            fetchTasks()
            alert("task marked as completed")
        } catch (error) {
            console.log(error);
        }
    }

    const handleLogout=async()=>{
        await axios.post("/logout")
        navigate("/")

    }

    const sort=()=>{
        if(isSorted)
        {
            setTasks(originalTasks)
            setIsSorted(false)
        }
        else
        {
            const sortedTasks = [...tasks].sort((a,b)=>{
                return a.task.localeCompare(b.task)
            });
            setTasks(sortedTasks)
            setIsSorted(true)
        }
    }


  return (
    <>
    <Button className='logout-btn' onClick={handleLogout} variant='warning'>Logout</Button>
    <h4 className='text-center header'>Welcome to Tazky ! Your task companion</h4>
        <div className="container task-container">
            
            <div className="container task-input">
                <p style={{fontWeight:'bold'}}>Enter your task</p>
                <InputGroup >
                    <Form.Control value={newTask} onChange={(e)=>setNewTask(e.target.value)}
                    placeholder="Enter the task"
                    />
                </InputGroup>
                <br />
                <span>
                    <Button className='add-btn' variant="primary" onClick={addTask}>Add</Button>
                </span>
            </div>
            <Button variant='info' style={{ marginTop:'1.5rem'}} onClick={sort}>
                { isSorted ? "Unsort" : "Sort A-Z" }
            </Button>
            <div className="container task-list">
                <ul>
                     {
                        tasks.length >0 ? (
                            tasks.map((task)=>(
                                <li key={task.id} className='each-task'>
                                    <span className='task-text' style={{textDecoration: task.completed === 't' ? 'line-through':'none'}}>
                                        {task.task}
                                    </span>
                                   <span className='complete-btn'>
                                        {task.completed === 'f' && (
                                            <Button  variant="success" onClick={()=>markCompleted(task.id)}>Done</Button>
                                        )}
                                   </span>
                                   <span className='del-btn'>
                                        <Button  variant="danger" onClick={()=> deleteTask(task.id)}>Delete</Button>
                                   </span>
                                </li>
                            )
                            )
                        ) : (
                            <p style={{ fontSize:'1.25rem', fontWeight:'bold'}}>Hey,Its your free time ! you don't have any tasks :)!</p>
                        )
                     } 
                </ul>
            </div>
        </div>
    </>
  )
}

export default Tasks