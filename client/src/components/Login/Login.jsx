import React, { useState } from 'react'
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import { Link, Navigate } from 'react-router-dom';
import './Login.css'
import axios from 'axios'
import { useNavigate } from 'react-router-dom';

const Login = () => {
    const [email,setEmail] = useState("");
    const [password,setPassword] = useState("");
    const navigate = useNavigate()
    const handleSubmit = async(e)=>
    {
        e.preventDefault();
        try {
            const response = await axios.post("http://localhost:4567/login",{
                email,
                password
            },{
                headers:{
                    'Content-Type' : 'application/json'
                }, 
                withCredentials: true
            })

            if (response.data.status === 200)
            {
                navigate('/home')
                alert("login successful");
                
            }
            
            else
                alert("login failed"+response.data.message)

        } catch (error) {
            console.log(error);
            
            
        }
    }

  return (
    <>
    <h4 className='text-center' style={{ marginTop:'7rem', fontSize:'2rem', letterSpacing:'5px'}}>Welcome to Tazky !</h4>
    <div className="container login-container">
        <h4 className='text-center'>Login here!</h4>
        <Form onSubmit={handleSubmit}>
            <Form.Group className="mb-3" controlId="formBasicEmail">
                <Form.Label>Email address</Form.Label>
                <Form.Control type="email" placeholder="Enter email" onChange={(e) => setEmail(e.target.value)} value={email} required />
            </Form.Group>

            <Form.Group className="mb-3" controlId="formBasicPassword">
                <Form.Label>Password</Form.Label>
                <Form.Control type="password" placeholder="Password" onChange={(e)=> setPassword(e.target.value)} value={password} required />
            </Form.Group>
            <Button variant="primary" type="submit" className='mb-3' >
                Submit
            </Button>
        </Form>
        <Link to="/register" className='register_text '>Register here !</Link>
    </div>
    </>
  )
}

export default Login