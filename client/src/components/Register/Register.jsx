import React, { useState } from 'react'
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import { Link, Navigate, useNavigate } from 'react-router-dom';
import './Register.css'
import axios from 'axios';

const Register = () => {
    const [name,setName] = useState("")
    const [email,setEmail] = useState("")
    const [password,setPassword] = useState("")
    const navigate =useNavigate()
    const handleRegister = async (e)=>{
        e.preventDefault();

        try {
            const res= await axios.post("http://localhost:4567/register",{
                name,
                email,
                password
            },{
                headers:{
                    "Content-Type" :"application/json"
                }
            })
            if(res.data.status ==="success"){
                alert("registered successfully")
                navigate("/")
            }
                    
            else
                alert(res.data.message)
        } catch (error) {
            console.log(error);
            
        }
    }


  return (
    <>
   <h4 className='text-center' style={{ marginTop:'7rem', fontSize:'2rem', letterSpacing:'5px'}}>Welcome to Tazky !</h4>
    <div className="container register-container">
        <h4 className='text-center'>Register here!</h4>
        <Form onSubmit={handleRegister}>
            <Form.Group className="mb-3" controlId="formBasicName">
                <Form.Label>Name</Form.Label>
                <Form.Control type="text" placeholder="Enter Name" onChange={(e)=> setName(e.target.value)} required />
            </Form.Group>
            <Form.Group className="mb-3" controlId="formBasicEmail">
                <Form.Label>Email address</Form.Label>
                <Form.Control type="email" placeholder="Enter email" onChange={(e)=> setEmail(e.target.value)} required />
                <Form.Text className="text" style={{color:'white'}}>
                We'll never share your email with anyone else.
                </Form.Text>
            </Form.Group>

            <Form.Group className="mb-3" controlId="formBasicPassword">
                <Form.Label>Password</Form.Label>
                <Form.Control type="password" placeholder="Password" required onChange={(e) => setPassword(e.target.value)} />
            </Form.Group>
            <Button variant="primary" type="submit" className='mb-3' >
                Submit
            </Button>
        </Form>
        <Link to="/" className='login_text'>Login here !</Link>
    </div>
    </>
  )
}

export default Register