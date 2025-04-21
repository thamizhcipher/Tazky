import {render, screen, fireEvent, waitFor} from '@testing-library/react'
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

        
        // axios.get.mockImplementation((url) => {
        //     if (url === "http://localhost:4567/verify") {
        //       return Promise.resolve({ data: { status: 200 } });
        //     } else if (url === "http://localhost:4567/tasks") {
        //       return Promise.resolve({ data: dummyData });
        //     }
        //   });
        render (
            <MemoryRouter>
                <Tasks />
            </MemoryRouter>
        );
        axios.get.mockResolvedValueOnce({ data: { tasks: {dummyData} } })
        screen.debug()
        expect(await screen.findByText("new task")).toBeInTheDocument()
    } )
 })