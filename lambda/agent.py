import uuid
import boto3
import json
from datetime import datetime
from langchain_aws import ChatBedrockConverse
from langchain_core.tools import tool
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate

# Initialize DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('Tasks')  # Replace 'tasks' with your actual table name

#GET
@tool
def get_tasks_from_dynamodb() -> str:
    """Get all tasks from the planner."""
    try:
        response = table.scan()
        tasks = response.get('Items', [])
        if not tasks:
            return "No tasks found."
        
        result = f"Found {len(tasks)} task(s):\n"
        for task in tasks:
            result += f"- {task['task_name']} (Due: {task['due_date']}, Status: {task['status']}, ID: {task['task_id']})\n"
        return result
    except Exception as err:
        return f"Error getting tasks from DynamoDB: {str(err)}"

#Helps other CRUD operations find the id given the name
def find_task_id_by_name(task_name: str) -> str:
    """Helper function to find task_id by task_name."""
    response = table.scan()
    items = response.get('Items', [])
    
    # First try exact case-insensitive match
    for item in items:
        if item['task_name'].lower() == task_name.lower():
            return item['task_id']
    
    # If no exact match, try partial match
    for item in items:
        if task_name.lower() in item['task_name'].lower():
            return item['task_id']
            
    return None

#POST
@tool
def add_task_to_dynamodb(task_name: str, due_date: str, status: str = "pending") -> str:
    """Add a task to the planner with name, due_date (YYYY-MM-DD), description, and status."""
    try:
        item = {
            'task_id': str(uuid.uuid4()),
            'task_name': task_name,
            'due_date': due_date,
            'status': status,
            'created_at': datetime.now().isoformat()
        }
        table.put_item(Item=item)
        return f"Successfully added task '{task_name}' to planner"
    except Exception as err:
        return f"Error adding task to DynamoDB: {str(err)}"

#PUT
@tool
def update_task_status(task_name: str, new_status: str) -> str:
    """Update the status of a task by name. Status can be 'pending', 'completed', or 'in_progress'."""
    try:
        if new_status not in ["pending", "completed", "in_progress"]:
            return "Invalid status. Must be 'pending', 'completed', or 'in_progress'."
        
        task_id = find_task_id_by_name(task_name)
        if not task_id:
            return f"Task '{task_name}' not found."
            
        table.update_item(
            Key={'task_id': task_id},
            UpdateExpression="SET #status = :status",
            ExpressionAttributeNames={"#status": "status"},
            ExpressionAttributeValues={":status": new_status}
        )
        return f"Successfully updated '{task_name}' status to '{new_status}'"
    except Exception as err:
        return f"Error updating task status: {str(err)}"

#DELETE
@tool
def delete_task_from_dynamodb(task_name: str) -> str:
    """Delete a task from the planner using its name."""
    try:
        task_id = find_task_id_by_name(task_name)
        if not task_id:
            return f"Task '{task_name}' not found."
            
        table.delete_item(Key={'task_id': task_id})
        return f"Successfully deleted task '{task_name}'"
    except Exception as err:
        return f"Error deleting task from DynamoDB: {str(err)}"

# Initialize Bedrock LLM
llm = ChatBedrockConverse(
    model="anthropic.claude-3-haiku-20240307-v1:0",
    region_name="us-east-1"
)

# Create prompt template
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are an AI powered conversation planner. You will assist in adding tasks, deleting tasks, updating the status of tasks, and showing tasks to users."),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

# Create agent
tools = [add_task_to_dynamodb, get_tasks_from_dynamodb, update_task_status, delete_task_from_dynamodb]
agent = create_tool_calling_agent(llm, tools, prompt)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# Make the call
"""
Test Code
response = agent_executor.invoke({"input": "Add 1 and 1"})
output = response['output']
print(output)
"""
#Lambda Handler function
def lambda_handler(event, context):
    try:
        # Parse the JSON string into a Python dictionary
        event = json.loads(event['body'])
        if not event['message']:
            return {
                'statusCode': 400,
                'body': json.dumps('Input was not given')
            }
        response = agent_executor.invoke({"input": event['message']})
        output = response['output']
        return {
            'statusCode': 200,
            'body': json.dumps(output)
        }
    except Exception as err:
        return {
            'statusCode': 500,
            'body': json.dumps(str(err))
        }

