from flask import Flask, request, jsonify
from flask_cors import CORS
import firebase_admin
from firebase_admin import credentials, firestore
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
import random
import numpy as np
from datetime import datetime

cred = credentials.Certificate("firebase-service-account.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

app = Flask(__name__)
CORS(app)

positive_words = ['Hello', 'Please', 'Thank you', 'Help', 'More', 'Happy', 'Good',
                  'Morning', 'Play', 'Read', 'Write', 'Listen', 'Look', 'Want',
                  'Need', 'Like', 'Friend', 'Family', 'Mom', 'Dad', 'Brother',
                  'Sister', 'Teacher', 'School', 'Home', 'Outside', 'Yes',
                  'Enjoy', 'Love', 'Smile', 'Welcome', 'Peace', 'Rest',
                  'Cheer', 'Try', 'Kind', 'Brave', 'Respect', 'Nice',
                  'Share', 'Learn', 'Hope', 'Sing', 'Dance', 'Give',
                  'Grow', 'Good Job', 'Playful', 'Fun', 'Joy', 'Help Out',
                  'Big', 'Small', 'Warm', 'Friendly', 'Thankful', 'Easy',
                  'Sweet', 'Care', 'Clean', 'Soft', 'Fast', 'Safe',
                  'Strong', 'Cool', 'Bright', 'Quiet', 'Yummy', 'Calm',
                  'Gentle', 'Smile', 'Listen', 'Try Hard', 'Smart', 'Glad',
                  'Together', 'Best', 'Helpful', 'Quick', 'Ready']

negative_words = ['Goodbye', 'Sorry', 'Stop', 'Hurt', 'Pain', 'Sad', 'Angry',
                  'Tired', 'Hungry', 'Thirsty', 'Hot', 'Cold', 'Bad', 'Night',
                  'Dislike', 'No', 'Mad', 'Scared', 'Lonely', 'Slow', 'Lost',
                  'Mean', 'Cry', 'Yucky', 'Hard', 'Messy', 'Lazy', 'Wrong',
                  'Sick', 'Dark', 'Bored', 'Broken', 'Rude', 'Loud', 'Busy',
                  'Dirty', 'Weak', 'Late', 'Afraid', 'Confused', 'Jealous',
                  'Trouble', 'Dizzy', 'Forget', 'Stuck', 'Sorry', 'Annoy',
                  'Cold', 'Fussy', 'Noisy', 'Fall', 'Bad Day', 'Oops']

# Fixed Word lists
fixed_words = ['Yes', 'No', 'Thank you', 'More']

def calculate_positive_similarity(user_clicks):
    # TF-IDF for positive words
    positive_tfidf_vectorizer = TfidfVectorizer()
    positive_tfidf_matrix = positive_tfidf_vectorizer.fit_transform(positive_words)
    positive_similarity_matrix = cosine_similarity(positive_tfidf_matrix)

    # Words Index!
    clicked_positive_indices = [positive_words.index(word) for word in user_clicks if word in positive_words]

    # Calculation!
    positive_summed_similarity = np.sum(positive_similarity_matrix[clicked_positive_indices], axis=0) if clicked_positive_indices else np.zeros(len(positive_words))
    positive_recommended_indices = positive_summed_similarity.argsort()[-3:][::-1]

    #No repeat!
    positive_recommended_words = [positive_words[i] for i in positive_recommended_indices if
                                  positive_words[i] not in user_clicks]

    additional_positives = [word for word in positive_words if word not in user_clicks]
    if len(positive_recommended_words) < 2:
        additional_needed = 2 - len(positive_recommended_words)
        positive_recommended_words += random.sample(additional_positives, min(len(additional_positives), additional_needed))

    return positive_recommended_words[:2]

def calculate_negative_similarity(user_clicks):
    # Negative Word -  TF-IDF
    negative_tfidf_vectorizer = TfidfVectorizer()
    negative_tfidf_matrix = negative_tfidf_vectorizer.fit_transform(negative_words)
    negative_similarity_matrix = cosine_similarity(negative_tfidf_matrix)

    # Index of Negative Words
    clicked_negative_indices = [negative_words.index(word) for word in user_clicks if word in negative_words]

    # Calculation fo Neg.
    negative_summed_similarity = np.sum(negative_similarity_matrix[clicked_negative_indices], axis=0) if clicked_negative_indices else np.zeros(len(negative_words))
    negative_recommended_indices = negative_summed_similarity.argsort()[-3:][::-1]

    # Recommend
    negative_recommended_words = [negative_words[i] for i in negative_recommended_indices if
                                  negative_words[i] not in user_clicks]

    # 충분한 추천 단어가 없는 경우 무작위 요소 추가
    additional_negatives = [word for word in negative_words if word not in user_clicks]
    if len(negative_recommended_words) < 2:
        additional_needed = 2 - len(negative_recommended_words)
        negative_recommended_words += random.sample(additional_negatives, min(len(additional_negatives), additional_needed))

    return negative_recommended_words[:2]
@app.route('/recommend', methods=['POST'])
def recommend():
    data = request.json
    user_id = data.get('user_id', None)

    print(f"Received request for user_id: {user_id}")

    if not user_id:
        print("No user_id provided in request.")
        return jsonify({'error': 'No user_id provided'}), 400

    user_clicks_ref = db.collection('users').document(user_id).collection('word_clicks')
    user_clicks = [doc.id for doc in user_clicks_ref.stream()]

    print(f"User clicks retrieved: {user_clicks}")

    positive_recommended_words = calculate_positive_similarity(user_clicks)
    negative_recommended_words = calculate_negative_similarity(user_clicks)

    print(f"Positive recommendations: {positive_recommended_words}")
    print(f"Negative recommendations: {negative_recommended_words}")

    return jsonify({
        'positive_recommendations': positive_recommended_words,
        'negative_recommendations': negative_recommended_words
    })

@app.route('/update_click', methods=['POST'])
def update_click():
    data = request.json
    user_id = data['user_id']
    word = data['word']
    current_time = datetime.utcnow()

    collection_name = 'word_clicks'
    doc_ref = db.collection('users').document(user_id).collection(collection_name).document(word)

    doc = doc_ref.get()
    if doc.exists:
        current_count = doc.to_dict().get('count', 0)
        new_count = current_count + 1
    else:
        new_count = 1

    # Update
    doc_ref.set({
        'count': new_count
    }, merge=True)

    clicks_ref = doc_ref.collection('clicks').document()
    clicks_ref.set({
        'clicked_at': current_time
    })

    return jsonify({'status': 'success'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)