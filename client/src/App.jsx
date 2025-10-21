import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [agentMessage, setAgentMessage] = useState('')
  const [chatReply, setChatReply] = useState('')
  const [tasks, setTasks] = useState([])
  
  //API Call to interact with the agent
  const apiCallToAgent = async (e) => {
    e.preventDefault()
    
    try {
      const res = await fetch(`${process.env.REACT_APP_API_URL}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': process.env.REACT_APP_API_KEY,
        },
        body: JSON.stringify({
          message: agentMessage
        })
      })
      
      const data = await res.json()
      setChatReply(data)

      // Refresh tasks after chat interaction
      await apiCallToTasks()
    } catch (err) {
      console.error('Error:', err)
    }
  }

  //API call to get tasks as an array
  const apiCallToTasks = async () => {
    try {
      const res = await fetch(`${process.env.REACT_APP_API_URL}/tasks`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'X-API-Key': process.env.REACT_APP_API_KEY,
        }
      })
      
      const data = await res.json()
      setTasks(data)
    } catch (err) {
      console.error('Error fetching tasks:', err)
      setTasks([])
    }
  }

  useEffect(() => {
    apiCallToTasks()
  }, [])

  return (
    <>
      <h1>This is your list of tasks</h1>
          <ul>
            {tasks.map(task => (
              <li key={task.task_id}>
                {task.task_name} - Due: {task.due_date} - Status: {task.status}
              </li>
            ))}
          </ul>
      <input onChange={(e) => setAgentMessage(e.target.value)} type="text" name="agentMessage" placeholder="Add, update the status, and delete tasks here."/>
      <p>{chatReply}</p>
      <button onClick={apiCallToAgent} variant="primary" type="submit">Submit</button>
    </>
  )
}

export default App
