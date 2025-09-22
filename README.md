# HeartSpeak

**HeartSpeak** is a Flutter-based Augmentative and Alternative Communication (AAC) app that helps individuals with communication impairments express themselves more easily. The app provides a simple, customizable interface where users can select words or phrases that are then converted into speech.

## Why AAC?
AAC (Augmentative and Alternative Communication) tools are designed to support people who have limited or unreliable natural speech (e.g., individuals with autism, cerebral palsy, aphasia, or after a stroke). A good AAC system:
- Keeps frequently used words and phrases easy to access.
- Allows customization to reflect the user’s unique needs.
- Converts text selections into clear, spoken output with one tap.

## Features
- 🔤 **Customizable vocabulary and categories**
- 🗣️ **Text-to-Speech integration** (adjust voice, pitch, and speed)
- 🤖 **Smart phrase suggestions** using TF-IDF + cosine similarity
- 📊 **Basic data tracking** for commonly used phrases
- ☁️ **Firebase integration** for saving user preferences
- 📶 **Offline-first** local storage with optional sync

---

## How the Smart Suggestions Work
HeartSpeak goes beyond static phrase boards by offering **intelligent suggestions** based on text similarity.

- **TF-IDF Vectorization**: Each stored phrase is represented as a vector of word weights. Common words get lower weights, while distinctive words get higher weights.
- **Cosine Similarity**: When the user starts typing or selecting, the app compares the input vector to all stored phrase vectors and calculates similarity scores. The phrases with the highest scores are suggested first.

This approach allows HeartSpeak to surface **semantically relevant phrases**, making communication faster and more natural.

**Example (simplified in Dart-like pseudocode):**
```dart
import 'package:vector_math/vector_math.dart' show dot;

double cosineSimilarity(List<double> v1, List<double> v2) {
  final dotProduct = dot(v1, v2);
  final normV1 = v1.map((x) => x * x).reduce((a, b) => a + b).sqrt();
  final normV2 = v2.map((x) => x * x).reduce((a, b) => a + b).sqrt();
  return dotProduct / (normV1 * normV2);
}
