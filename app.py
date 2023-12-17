# Description: Streamlit app for testing the model
# Dependencies: streamlit, requests
# Installation: pip install streamlit requests watchgod
# Usage: streamlit run app.py IP:PORT

import streamlit as st
import requests
import sys
import time

sb = st.sidebar
urlContainer = st.sidebar.container()
imageContainer = st.sidebar.container()

# Get for argument the IP:PORT of the model
ARG1 = sys.argv[1]
with sb:
    st.caption(f"Using model at {ARG1}")

imageUrl = urlContainer.text_input(
    'Image URL', 'https://i.imgur.com/3QZ7T4p.jpg',
    key="placeholder",
    help="Enter the URL of the image you want to use"
)

imageContainer.text("Loaded image")
if imageUrl != "":
    imageContainer.image(
        imageUrl,
        width=400, # Manually Adjust the width of the image as per requirement
    )

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Display chat messages from history on app rerun
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# React to user input
if prompt := st.chat_input("What is up?"):
    # Display user message in chat message container
    with st.chat_message("user"):
        st.markdown(prompt)
    # Add user message to chat history
    st.session_state.messages.append({"role": "user", "content": prompt})

    if imageUrl != "":
        data = requests.post("http://" + ARG1 + "/predictions", json={"input": {"image": imageUrl, "query": prompt}}).json()

        if data['output'] == None:
            if data['error'] != None:
                output = data['error']
            else:
                output = "Sorry, I don't know what you mean."
        else:
            output = data['output'].rstrip("</s>")

        with st.chat_message("ai"):
            #st.markdown(output)
            # Simulate stream of response with milliseconds delay
            message_placeholder = st.empty()
            full_response = ""
            for chunk in output.split():
                full_response += chunk + " "
                time.sleep(0.05)
                # Add a blinking cursor to simulate typing
                message_placeholder.markdown(full_response + "▌")
            message_placeholder.markdown(full_response)

        # Add ai message to chat history
        st.session_state.messages.append({"role": "ai", "content": output})
