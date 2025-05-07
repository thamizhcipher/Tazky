import {render, screen} from '@testing-library/react'
import Tasks from './components/Tasks/Tasks'
import axios from 'axios'
import { MemoryRouter } from 'react-router-dom';

jest.mock('axios');

const dummyData = [
    {
        id:1,
        user_id:1,
        task: 'new task',
        completed: 0
    },
    {
        id:2,
        user_id:5,
        task: 'completed task',
        completed: 1
    },

]

describe('fetching the task list', () => { 
    it("should render the task list", async()=>{

        axios.get.mockResolvedValueOnce({ data: { tasks: dummyData } })

        render (
            <MemoryRouter>
                <Tasks />
            </MemoryRouter>
        );
        
        expect(await screen.findByText("new task")).toBeInTheDocument()
    } )
 })