from langchain_aws import ChatBedrockConverse
from langchain_core.prompts import ChatPromptTemplate

# Initialize the Bedrock LLM
llm = ChatBedrockConverse(
    model_id="MODEL GOES HERE",
    region_name="us-east-1",
)

# Define a simple prompt
prompt = ChatPromptTemplate.from_messages([
    ("system", "{prompt}"),
    ("human", "{human_prompt}")
])

# Create the chain
chain = prompt | llm

# Run the chain
response = chain.invoke(
    {
        "prompt": "Lol example prompt",
        "human_prompt" : "Lol example human prompt"
    }
    
)
print(response)
