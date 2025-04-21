import React, { useEffect, useState } from 'react'
import {Navigate,Outlet, useNavigate} from 'react-router-dom'
import axios from 'axios'

const PrivateRoute = () => {
    const[auth,setAuth]=useState(null);
    const navigate=useNavigate();
    useEffect(()=>{
        const checkAuth = async()=>{
            try {
                await axios.get("http://localhost:4567/verify",{withCredentials:true})
                setAuth(true)
            } catch (error) {
                setAuth(false)
            }
        }
        checkAuth()
    },[]);

    if(auth==null)
        return <h2>Loading...</h2>
    
    return auth ? <Outlet /> : <Navigate to="/" replace/>;
   
}

export default PrivateRoute