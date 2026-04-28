# Using Hugging Face ASL Dataset Integration

## Overview
The Hugging Face ASL dataset (`akasheroor/American-Sign-Language-Dataset`) contains **108,618 videos** representing **2,208 ASL words**. This guide explains how to integrate it into your sign-to-text module.

## Dataset Details
- **Total Videos**: 108,618
- **Total Words**: 2,208
- **Videos per Word**: Minimum 30
- **License**: MIT (free to use)
- **Size**: ~54.3 GB
- **Format**: MP4 videos organized in folders

## Dataset URL
```
https://huggingface.co/datasets/akasheroor/American-Sign-Language-Dataset
```

## Implementation Approaches

### Option 1: Use CSV for Training Data (RECOMMENDED)
**Best for**: Improving your k-NN classifier accuracy

1. **Download the dataset.csv** from Hugging Face
2. **Extract hand landmarks** from each video using MediaPipe
3. **Convert landmarks to CSV format** (63 features per hand)
4. **Use enhanced classifier** to load both local + HF data

**Advantages**:
- ✅ Offline usage (no API calls at runtime)
- ✅ Fast predictions
- ✅ Better accuracy with more training data
- ✅ Privacy-friendly

**Steps**:
```python
# Python script to extract landmarks from HF videos
# 1. Download dataset.csv from Hugging Face
# 2. For each video path:
#    - Load video
#    - Extract frames
#    - Get hand landmarks using MediaPipe
#    - Save as CSV: landmark_values + word_label
```

---

### Option 2: Browse Dataset in App
**Best for**: Learning and exploring available signs

Use the **ASLDatasetBrowserScreen** to:
- Search for specific words
- See how many videos available per word
- View video statistics
- Link to Hugging Face videos

**Usage**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const ASLDatasetBrowserScreen(),
  ),
);
```

---

### Option 3: Backend API Integration
**Best for**: Real-time processing or continuous updates

Create a Python backend that:
1. Downloads videos from HF on-demand
2. Extracts landmarks
3. Returns predictions via API

**Setup**:
```dart
// In your app
final response = await http.post(
  Uri.parse('https://your-backend.com/predict'),
  body: jsonEncode({'landmarks': features}),
);
```

---

## Implementation Steps

### Step 1: Install Dependencies
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
  csv: ^6.0.0
```

Run: `flutter pub get`

### Step 2: Use ASLDatasetLoader Service
```dart
import 'package:signbridge/core/services/asl_dataset_loader.dart';

// Fetch dataset metadata
final info = await ASLDatasetLoader.getDatasetInfo();

// Fetch CSV mapping
final entries = await ASLDatasetLoader.fetchDatasetCSV();

// Get video URL for a word
final url = ASLDatasetLoader.getVideoUrl('part1/12345-HELLO.mp4');

// Search/filter
final results = ASLDatasetLoader.filterEntries(entries, 'HELLO');

// Get statistics
final uniqueWords = ASLDatasetLoader.getUniqueWords(entries);
final frequency = ASLDatasetLoader.getWordFrequency(entries);
```

### Step 3: Use Enhanced Classifier
```dart
import 'package:signbridge/core/services/sign_to_text_classifier_enhanced.dart';

final classifier = SignToTextClassifier(k: 5);

// Load local data
await classifier.load();

// Add Hugging Face training data
final csvData = await loadYourProcessedHFData();
await classifier.addSamplesFromCSV(csvData);

// Make predictions
final prediction = classifier.predictFromLandmarks(landmarks);
print('Predicted: ${prediction.label} (${prediction.confidence}%)');
print('Samples: Local=${classifier.localSampleCount}, HF=${classifier.huggingFaceSampleCount}');
```

### Step 4: Add Dataset Browser to Navigation
```dart
// In your main navigation
ListTile(
  leading: const Icon(Icons.dataset),
  title: const Text('Browse ASL Dataset'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ASLDatasetBrowserScreen(),
    ),
  ),
),
```

---

## Data Format

### CSV Format (for classifier training)
```csv
x1,y1,z1,x2,y2,z2,...,x21,y21,z21,label
0.123,0.456,0.789,...,0.345,0.678,0.901,HELLO
```

**Breakdown**:
- **x1-z21**: 21 hand landmarks × 3 coordinates = 63 values
- **label**: The word being signed (e.g., "HELLO", "THANK YOU")

### Dataset CSV Structure
```csv
word,video_path
HELLO,part1/12345-HELLO.mp4
THANKS,part2/67890-THANKS.mp4
```

---

## Converting Hugging Face Videos to Training Data

### Python Script Template
```python
import mediapipe as mp
import cv2
import pandas as pd
import csv
from pathlib import Path

mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=True)

# Load dataset.csv from Hugging Face
df = pd.read_csv('dataset.csv')

# Process each video
with open('processed_landmarks.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    
    for _, row in df.iterrows():
        video_path = row['video_path']
        word = row['word']
        
        # Download and process video
        cap = cv2.VideoCapture(download_video_from_hf(video_path))
        
        # Extract frames
        frame_count = 0
        while cap.isOpened() and frame_count < 5:  # Sample frames
            ret, frame = cap.read()
            if not ret:
                break
                
            # Get hand landmarks
            results = hands.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
            
            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    features = []
                    for landmark in hand_landmarks.landmark:
                        features.extend([landmark.x, landmark.y, landmark.z])
                    
                    # Write: 63 features + word label
                    writer.writerow(features + [word])
            
            frame_count += 1
        
        cap.release()

print("Processing complete!")
```

---

## API Endpoints

### Hugging Face Endpoints
```
# Dataset info
GET https://huggingface.co/api/datasets/akasheroor/American-Sign-Language-Dataset

# CSV file (raw)
GET https://huggingface.co/datasets/akasheroor/American-Sign-Language-Dataset/raw/main/dataset.csv

# Video file
GET https://huggingface.co/datasets/akasheroor/American-Sign-Language-Dataset/resolve/main/{video_path}
```

---

## Performance Tips

1. **Cache the CSV**: Download once and save locally
   ```dart
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString('asl_dataset_cache', csvContent);
   ```

2. **Lazy Load Videos**: Only fetch when user requests
   ```dart
   final url = entry.getFullUrl();
   // Don't download all videos at once
   ```

3. **Batch Processing**: Extract landmarks in background
   ```dart
   for (final batch in entries.batches(100)) {
     await processVideoBatch(batch);
   }
   ```

4. **Use Larger k-value**: With more data, better accuracy
   ```dart
   final classifier = SignToTextClassifier(k: 10);  // More neighbors
   ```

---

## Troubleshooting

### Issue: 404 errors when fetching videos
**Solution**: Videos aren't actually stored on web server. Use the dataset repo directly or download the full dataset.

### Issue: Slow CSV loading
**Solution**: Process and cache locally after first load
```dart
// Save to local file
final file = File('${appDir.path}/asl_dataset.csv');
await file.writeAsString(csvContent);
```

### Issue: Low prediction accuracy
**Solution**: Add more training samples from HF dataset
```dart
// Extract more videos per word
for (final word in uniqueWords) {
  final samples = entries.where((e) => e.word == word).toList();
  // Process more samples for this word
}
```

---

## Next Steps

1. ✅ **Phase 1**: Implement dataset browser (done)
2. 🔄 **Phase 2**: Download and process HF dataset to extract landmarks
3. 🔄 **Phase 3**: Integrate processed data into classifier
4. 🔄 **Phase 4**: A/B test accuracy with/without HF data
5. 🔄 **Phase 5**: Fine-tune model hyperparameters

---

## References
- Dataset: https://huggingface.co/datasets/akasheroor/American-Sign-Language-Dataset
- MediaPipe Hands: https://mediapipe.dev/solutions/hands
- Dataset License: MIT

