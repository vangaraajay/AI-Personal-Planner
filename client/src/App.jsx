import { useState } from 'react'
import './App.css'

function App() {
  const [agentMessage, setAgentMessage] = useState('')
  const [chatReply, setChatReply] = useState('')
  
  const apiCallToAgent = async (e) => {
    e.preventDefault()
    
    try {
      const res = await fetch(`${process.env.REACT_APP_API_URL}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          message: agentMessage
        })
      })
      
      const data = await res.json()
      setChatReply(data.response)
      console.log(data.response)
    } catch (error) {
      console.error('Error:', error)
    }
  }

  

  return (
    <>
      <h1>This is your list of tasks</h1>
      <input onChange={(e) => setAgentMessage(e.target.value)} type="text" name="agentMessage" placeholder="Add, update the status, and delete tasks here."/>
      <p>{chatReply}</p>
      <button onClick={apiCallToAgent} variant="primary" type="submit">Submit</button>
    </>
  )
}

export default App
