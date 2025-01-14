import ollama

# Needs Ollama installed
# See https://github.com/ollama/ollama-python

def main():
    response = ollama.chat(
        model='llama3.2-vision',
        messages=[{
            'role': 'user',
            'content': 'Y\'a-t-il une pompe à chaleur?',
            # 'images': ['image.jpg']
            # 'images': ['fenetre.pdf'] # TODO: test with pdf
        }]
    )
    print(response)

if __name__ == '__main__':
    main()
