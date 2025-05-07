import React, { useEffect, useState } from 'react'
import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import { Link, useNavigate } from 'react-router-dom';
import './Register.css'
import axios from '../../axiosInstance'
 
const Register = () => {
    const [name,setName] = useState("")
    const [email,setEmail] = useState("")
    const [password,setPassword] = useState("")
    const [errors,setErrors] = useState({})
    const [formValid,setFormValid] = useState(false)
    const navigate =useNavigate()

    useEffect(()=>{
        validateForm()
    },[email,password])

    const validateForm=()=>{
        console.log("insinde validate");
        console.log(password.length);
        const newErrors = {};
        const emailRegex=/^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const passwordRegex=/^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*]).{8,}$/;
        if(!email || !emailRegex.test(email))
                 newErrors.email="Enter a valid email address"
        if(!password || parseInt(password.length)<8)
                 newErrors.password="Password must be atleast 8 characters long"
        else if(!password || !passwordRegex.test(password))
                 newErrors.password="Password must include at least one symbol,one number,one UpperCase and one lowercase letter"

        setErrors(newErrors)
        console.log(newErrors);
        
        setFormValid(Object.keys(newErrors).length===0)

    }


    const handleRegister = async (e)=>{
        e.preventDefault();
        if(formValid)
        {
            try {
                const res= await axios.post("/register",{
                    name,
                    email,
                    password
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

    }


  return (
    <>
   <h4 className='text-center' style={{ marginTop:'7rem', fontSize:'2rem', letterSpacing:'5px'}}>Welcome to Tazky !</h4>
    <div className="container register-container">
        <h4 className='text-center'>Register here!</h4>
        <Form onSubmit={handleRegister}>
            <Form.Group className="mb-3" >
                <Form.Label>Name</Form.Label>
                <Form.Control type="text" placeholder="Enter your name" onChange={(e)=> setName(e.target.value)} required />
            </Form.Group>
            <Form.Group className="mb-3" >
                <Form.Label>Email address</Form.Label>
                <Form.Control type="email" placeholder="Enter your email" onChange={(e)=> setEmail(e.target.value)} required style={{border: errors.email ? '2px solid red':''}} />

                {errors.email && (<Form.Text className="text" style={{color:'red',fontSize:'.875rem'}}>
                {errors.email}
                </Form.Text>) }
                
            </Form.Group>

            <Form.Group className="mb-3" >
                <Form.Label>Password</Form.Label>
                <Form.Control type="password" placeholder="Enter your password" required onChange={(e) => setPassword(e.target.value)} style={{border: errors.password ? '2px solid red':''}} />
                {errors.password && (<Form.Text className="text" style={{color:'red',fontSize:'.875rem'}}>
                {errors.password}
                </Form.Text>) }
            </Form.Group>

            <Button disabled={!formValid} variant="primary" type="submit" className='mb-3' >
                Submit
            </Button>
        </Form>
        <Link to="/" className='login_text'>Login here !</Link>
    </div>
    </>
  )
}

export default Register