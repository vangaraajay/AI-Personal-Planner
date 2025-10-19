import { useState } from 'react'
import './App.css'

function App() {
  const [agentMessage, setAgentMessage] = useState('')
  
  /*
  const apiCall = async (e) => {
    e.preventDefault()
    
    try {
      const res = await fetch('YOUR_API_GATEWAY_URL/agent', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          input: agentMessage
        })
      })
      
      const data = await res.json()
      console.log(data.response)
    } catch (error) {
      console.error('Error:', error)
    }
  }
  */

  return (
    <>
      <h1>This is your list of tasks</h1>
      <input onChange={(e) => setAgentMessage(e.target.value)} type="text" name="agentMessage" placeholder="Add, update the status, and delete tasks here."/>
      <button /*onClick={apiCall}*/ variant="primary" type="submit">Submit</button>
    </>
  )
}

export default App
