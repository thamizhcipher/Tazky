import React from 'react';
import {render, screen,fireEvent} from '@testing-library/react'
import Login from './components/Login/Login';
import { MemoryRouter } from 'react-router-dom';

test('shows message after clicking login', () => {
    render(
      <MemoryRouter>
          <Login />
        </MemoryRouter>
    );
    const emailInput = screen.getByPlaceholderText('Enter email');
    const passwordInput = screen.getByPlaceholderText('Password');
    const submitButton = screen.getByRole('button', { name: /submit/i });
  
    fireEvent.change(emailInput, { target: { value: 'user@test.com' } });
    fireEvent.change(passwordInput, { target: { value: 'test1234' } });
    fireEvent.click(submitButton);
  expect(emailInput.value).toBe('user@test.com');
    expect(passwordInput.value).toBe('test1234');
  }
);