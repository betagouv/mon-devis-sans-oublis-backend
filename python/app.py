from transformers import AutoTokenizer, AutoModelForQuestionAnswering, DistilBertForQuestionAnswering, pipeline
import torch

print("Running...")

with open("prompt.txt", "r") as file:
    prompt = file.read()
print(prompt)

with open("quote.txt", "r") as file:
    quote = file.read()
print(quote)

# def distilbert():
#     tokenizer = AutoTokenizer.from_pretrained("distilbert-base-uncased")
#     model = DistilBertForQuestionAnswering.from_pretrained("distilbert-base-uncased")

#     question, text = "Who was Jim Henson?", "Jim Henson was a nice puppet"

#     inputs = tokenizer(question, text, return_tensors="pt")
#     with torch.no_grad():
#         outputs = model(**inputs)

#     answer_start_index = outputs.start_logits.argmax()
#     answer_end_index = outputs.end_logits.argmax()

#     predict_answer_tokens = inputs.input_ids[0, answer_start_index : answer_end_index + 1]

#     # target is "nice puppet"
#     target_start_index = torch.tensor([14])
#     target_end_index = torch.tensor([15])

#     outputs = model(**inputs, start_positions=target_start_index, end_positions=target_end_index)
#     loss = outputs.loss

def deepset():
    model_name = "deepset/xlm-roberta-large-squad2"

    # a) Get predictions
    # nlp = pipeline('question-answering', model=model_name, tokenizer=model_name)
    # QA_input = {
    #     'question': 'Why is model conversion important?',
    #     'context': 'The option to convert models between FARM and transformers gives freedom to the user and let people easily switch between frameworks.'
    # }
    # result = nlp(QA_input)
    # print(result['answer'])
    # return result['answer']

    # b) Load model & tokenizer
    # model = AutoModelForQuestionAnswering.from_pretrained(model_name)
    # tokenizer = AutoTokenizer.from_pretrained(model_name)



    # qa_pipeline = pipeline("question-answering", model=model_name)
    # context = "Napoléon Bonaparte est né le 15 août 1769 à Ajaccio."
    # question = "Quand est né Napoléon Bonaparte ?"
    # result = qa_pipeline(question=question, context=context)
    # print(result['answer'])
    # return result['answer']



    qa_pipeline = pipeline("question-answering", model=model_name)
    context = quote
    question = prompt
    result = qa_pipeline(question=question, context=context)
    print(result['answer'])
    return result['answer']

# print(distilbert())
print(deepset())

print("Done")
