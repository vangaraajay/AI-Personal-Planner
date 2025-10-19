from langchain_aws import ChatBedrockConverse
from langchain_core.tools import tool
from langchain.agents import create_tool_calling_agent, AgentExecutor
from langchain_core.prompts import ChatPromptTemplate

@tool
def add_numbers(a: int, b: int) -> int:
    """Add two numbers together."""
    return a + b

# Initialize Bedrock LLM
llm = ChatBedrockConverse(
    model="anthropic.claude-3-haiku-20240307-v1:0",
    region_name="us-east-1"
)

# Create prompt template
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant"),
    ("human", "{input}"),
    ("placeholder", "{agent_scratchpad}")
])

# Create agent
agent = create_tool_calling_agent(llm, [add_numbers], prompt)
agent_executor = AgentExecutor(agent=agent, tools=[add_numbers], verbose=True)

# Make the call
response = agent_executor.invoke({"input": "Add 1 and 1"})
output = response['output']
print(output[0]['text'].strip())
