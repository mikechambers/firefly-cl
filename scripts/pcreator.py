import argparse
import sys
from firefly_lib import sanitize_filename, run_firefly_command
import time
import requests
import json
import os

# Function to prompt the user for input based on the structured questions
def get_user_input():
    responses = {}
    questions = {
        "subject": "What is the main subject of your image? (e.g., person, animal, object)",
        "action": "Are there any specific actions or poses you'd like the subject to be in?",
        "additional_subjects": "Do you want any additional subjects or objects in the scene? If so, please describe them.",
        "setting": "Where is the scene set? (e.g., indoors, outdoors, fantasy world)",
        "key_elements": "Can you describe the key elements of this setting? (e.g., forest, cityscape, room)",
        "time_of_day": "Is there a specific time of day or atmospheric conditions you envision? (e.g., sunset, foggy, clear night)",
        "artistic_style": "What artistic style are you aiming for? (e.g., realistic, impressionist, manga)",
        "colors": "Are there any specific colors or tones that should dominate the image?",
        "mood": "Do you prefer the image to convey a certain mood or emotion? If so, what is it?",
        "perspective": "From what perspective do you want the image to be viewed? (e.g., first-person, aerial, side view)",
        "viewer_distance": "How close or far should the viewer feel from the main subject? (e.g., close-up, wide shot)",
        "emphasis": "Is there a specific aspect of the subject or scene you'd like to emphasize?",
        "detail_level": "How detailed do you want the image to be? (e.g., high detail, abstract)",
        "special_attention": "Are there any specific elements or textures that need special attention? (e.g., clothing details, facial expressions)",
        "exclusions": "Is there anything you definitely do not want included in the image?",
        "lighting_preferences": "Do you have any preferences for lighting or shadow effects?",
        "inspirations": "Are there any existing artworks or images that inspire this creation? Please describe them.",
        "artist_influence": "Do you want the image to evoke the work of a certain artist or art movement?"
    }

    for key, question in questions.items():
        print(question)
        responses[key] = input("> ").strip()

    return responses

# Function to send user responses to ChatGPT and get a prompt
def generate_prompts_with_chatgpt(responses, num_prompts, output_dir):
    openai_api_key = os.getenv("OPENAI_API_KEY")
    if openai_api_key is None:
        print("Error: OPENAI_API_KEY environment variable is not set.", file=sys.stderr)
        sys.exit(1)
    
    # Construct the conversation string from user responses
    conversation = "\n".join([f"{question}: {answer}" for question, answer in responses.items()])
    
    model = "gpt-3.5-turbo-0125"

    headers = {
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {openai_api_key}'
    }

    data = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": f"you are a generative ai prompt master for Adobe's firefly text to image engine. Given a set of questions and responses, you will create {num_prompts} prompts for the user to use generate images. Return the results as a json object"
            },
            {
                "role": "user",
                "content": conversation
            }
        ]
    }

    response = requests.post('https://api.openai.com/v1/chat/completions', headers=headers, json=data)

    response.raise_for_status()


    content = json.loads(response.json()['choices'][0]['message']['content'])

    for item in content['prompts']:
        
        prompt = item
        print(f"Processing prompt: {prompt}")
    
        filename = f"{sanitize_filename(prompt)}.jpg"

        run_firefly_command(prompt, output_dir, filename)

        time.sleep(10)

def main(output_dir, num_prompts):
    responses = get_user_input()
    prompts = generate_prompts_with_chatgpt(responses, num_prompts, output_dir)
    #rint("\nGenerated Prompt:\n", generated_prompt)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate images based on prompts using the firefly command.")

    parser.add_argument("--output_dir", type=str, required=True, help="The directory where the generated image will be saved.")
    parser.add_argument("--num_prompts", type=int, default=5, help="Number of prompts to generate.")

    # Parse the command-line arguments
    args = parser.parse_args()

    main(args.output_dir, args.num_prompts)
