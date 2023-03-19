def hello_pubsub4(data, context):

    from google.cloud import pubsub_v1
    
    project_id = "lab6-project-380911"
    topic_id = "pubsub-lab6-be19b002"
    publisher1 = pubsub_v1.PublisherClient()
    topic_path1 = publisher1.topic_path(project_id, topic_id)
    pub_data1 = data['name']
    pub_data1 = pub_data1.encode("utf-8")
    future = publisher1.publish(topic_path1, pub_data1)
    print(future.result())
    print("Published ", pub_data1," to ", topic_path1)