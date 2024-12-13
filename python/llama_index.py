from llama_index.core import VectorStoreIndex, SimpleDirectoryReader

def main():
    documents = SimpleDirectoryReader("data").load_data()
    index = VectorStoreIndex.from_documents(documents)
    query_engine = index.as_query_engine()
    response = query_engine.query("Some question about the data should go here")
    print(response)

if __name__ == '__main__':
    main()
